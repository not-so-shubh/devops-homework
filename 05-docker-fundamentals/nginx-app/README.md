# Nginx App

Static `Hello World from Nginx` page copied into the official Nginx document root.

```bash
docker build -t devops-homework-nginx .
docker run --rm -p 8084:80 devops-homework-nginx
curl -fsS http://localhost:8084/
```
