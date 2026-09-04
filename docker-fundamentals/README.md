# Docker Fundamentals

Six independent applications demonstrate common Dockerfile patterns while serving distinct, exact Hello World text.

| Service | Implementation | Container port | Default host port | Expected text |
|---|---|---:|---:|---|
| `nodejs` | Express on Node.js | 3000 | 3000 | `Hello World from Node.js` |
| `python` | Flask via Gunicorn | 5000 | 5000 | `Hello World from Python` |
| `java` | JDK standard-library HTTP server | 8080 | 8081 | `Hello World from Java` |
| `apache` | Static page on official `httpd` | 80 | 8082 | `Hello World from Apache` |
| `react` | Vite build served by Nginx | 80 | 8083 | `Hello World from React` |
| `nginx` | Static page on official Nginx | 80 | 8084 | `Hello World from Nginx` |

## Build and run everything

```bash
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

If a default port is busy, override only that mapping:

```bash
NODE_HOST_PORT=13000 PYTHON_HOST_PORT=15000 docker compose up --build -d
```

Available variables are `NODE_HOST_PORT`, `PYTHON_HOST_PORT`, `JAVA_HOST_PORT`, `APACHE_HOST_PORT`, `REACT_HOST_PORT`, and `NGINX_HOST_PORT`. Each mapping binds to `127.0.0.1` by default so the homework service is not exposed to the LAN. Set `HOST_BIND_ADDRESS=0.0.0.0` only when LAN access is intentional and host firewall policy has been reviewed.

Every child folder has its own source, Dockerfile, `.dockerignore`, and concise build/run notes. `scripts/verify-all.sh` chooses available high ports, asserts every expected string with `curl`, captures real evidence, and cleans up containers afterward.
