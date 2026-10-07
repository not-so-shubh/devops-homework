import logging
import time
from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI, HTTPException, Request, Response, status
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session

from . import models, schemas
from .database import Base, engine, get_db


logging.basicConfig(
    level=logging.INFO,
    format='{"level":"%(levelname)s","message":"%(message)s"}',
)
logger = logging.getLogger("release-tracker")

REQUESTS = Counter(
    "release_tracker_http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"],
)
LATENCY = Histogram(
    "release_tracker_http_request_duration_seconds",
    "HTTP request duration",
    ["method", "path"],
)

@asynccontextmanager
async def lifespan(_app: FastAPI):
    # Alembic owns production migrations. This makes disposable labs self-starting.
    # The advisory lock prevents two Kubernetes replicas racing during first boot.
    with engine.begin() as connection:
        if engine.dialect.name == "postgresql":
            connection.execute(text("SELECT pg_advisory_xact_lock(2410601)"))
        Base.metadata.create_all(bind=connection)
    yield


app = FastAPI(
    title="Release Tracker API",
    description="Track application releases across delivery environments.",
    version="1.0.0",
    lifespan=lifespan,
)


@app.middleware("http")
async def observe_requests(request: Request, call_next):
    started = time.perf_counter()
    response = await call_next(request)
    route = request.scope.get("route")
    path = getattr(route, "path", request.url.path)
    REQUESTS.labels(request.method, path, response.status_code).inc()
    LATENCY.labels(request.method, path).observe(time.perf_counter() - started)
    logger.info("%s %s %s", request.method, request.url.path, response.status_code)
    return response


@app.get("/")
def root():
    return {"service": "release-tracker", "docs": "/docs", "health": "/health"}


@app.get("/health")
def health():
    return {"status": "healthy", "service": "release-tracker"}


@app.get("/ready")
def ready(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"status": "ready", "database": "connected"}


@app.get("/metrics", include_in_schema=False)
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/releases", response_model=list[schemas.ReleaseRead])
def list_releases(db: Session = Depends(get_db)):
    return db.scalars(select(models.Release).order_by(models.Release.id.desc())).all()


@app.get("/api/releases/stats", response_model=schemas.ReleaseStats)
def release_stats(db: Session = Depends(get_db)):
    counts = dict(
        db.execute(
            select(models.Release.status, func.count(models.Release.id)).group_by(models.Release.status)
        ).all()
    )
    return schemas.ReleaseStats(
        total=sum(counts.values()),
        healthy=counts.get("healthy", 0),
        deploying=counts.get("deploying", 0),
        failed=counts.get("failed", 0),
    )


@app.get("/api/releases/{release_id}", response_model=schemas.ReleaseRead)
def get_release(release_id: int, db: Session = Depends(get_db)):
    release = db.get(models.Release, release_id)
    if release is None:
        raise HTTPException(status_code=404, detail="Release not found")
    return release


@app.post("/api/releases", response_model=schemas.ReleaseRead, status_code=status.HTTP_201_CREATED)
def create_release(payload: schemas.ReleaseCreate, db: Session = Depends(get_db)):
    release = models.Release(**payload.model_dump())
    db.add(release)
    db.commit()
    db.refresh(release)
    return release


@app.put("/api/releases/{release_id}", response_model=schemas.ReleaseRead)
def update_release(release_id: int, payload: schemas.ReleaseUpdate, db: Session = Depends(get_db)):
    release = db.get(models.Release, release_id)
    if release is None:
        raise HTTPException(status_code=404, detail="Release not found")
    for field, value in payload.model_dump().items():
        setattr(release, field, value)
    db.commit()
    db.refresh(release)
    return release


@app.delete("/api/releases/{release_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_release(release_id: int, db: Session = Depends(get_db)):
    release = db.get(models.Release, release_id)
    if release is None:
        raise HTTPException(status_code=404, detail="Release not found")
    db.delete(release)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
