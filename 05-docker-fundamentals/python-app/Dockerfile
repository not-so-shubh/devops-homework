FROM python:3.13-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

RUN addgroup -S app && adduser -S app -G app
COPY requirements.txt ./
RUN pip install --no-cache-dir --requirement requirements.txt
COPY --chown=app:app app.py ./app.py

USER app
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "app:app"]
