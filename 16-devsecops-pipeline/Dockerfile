FROM alpine:3.24
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PORT=8080
RUN apk add --no-cache python3 \
    && addgroup -S app \
    && adduser -S -G app -u 10001 app
WORKDIR /app
COPY --chown=app:app application/app.py /app/app.py
USER 10001:10001
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O- http://127.0.0.1:8080/health >/dev/null || exit 1
ENTRYPOINT ["python3", "/app/app.py"]
