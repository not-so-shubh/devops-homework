# 05 — Docker Fundamentals

This section contains six independent Hello World applications packaged with Docker.

| Service | Implementation | Container port | Default host port | Expected response |
|---|---|---:|---:|---|
| `nodejs` | Express / Node.js | 3000 | 3000 | `Hello World from Node.js` |
| `python` | Flask / Gunicorn | 5000 | 5000 | `Hello World from Python` |
| `java` | Java HTTP server | 8080 | 8081 | `Hello World from Java` |
| `apache` | Apache httpd | 80 | 8082 | `Hello World from Apache` |
| `react` | Vite build served by Nginx | 80 | 8083 | `Hello World from React` |
| `nginx` | Nginx static page | 80 | 8084 | `Hello World from Nginx` |

## Run all six applications

```bash
cd 05-docker-fundamentals
docker compose up --build -d
docker compose ps

curl -fsS http://localhost:3000/
curl -fsS http://localhost:5000/
curl -fsS http://localhost:8081/
curl -fsS http://localhost:8082/
curl -fsS http://localhost:8083/
curl -fsS http://localhost:8084/

docker compose down
```

The Compose file allows host-port overrides through the existing environment variables when a default port is occupied.

## Implementation map

- `nodejs-app/` — Node/Express source, Dockerfile, lockfile, and `.dockerignore`.
- `python-app/` — Python/Flask application with Gunicorn.
- `java-app/` — Java server compiled into the container image.
- `Apache-app/` — static page served by the official Apache image.
- `React-app/` — production frontend build with an Nginx runtime stage.
- `nginx-app/` — static page served by Nginx.
- `docker-compose.yml` — builds and starts all six services together.

## Verification and evidence

The root `scripts/verify-all.sh` now performs repository structure, shell-syntax, Docker Compose configuration, and Kubernetes-manifest checks. It intentionally does not rebuild every Docker image on every repository verification run.

Previously captured genuine Docker build/curl evidence is retained under [`../evidence/command-outputs/`](../evidence/command-outputs/). Browser screenshots are retained under [`../evidence/screenshots/`](../evidence/screenshots/).

To re-verify the runtime behavior, use the commands above and confirm each service returns its expected response before submission.
