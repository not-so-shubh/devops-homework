# Apache App

Static `Hello World from Apache` page on the official Apache HTTP Server image (`httpd`, not a fictitious `apache2` image).

```bash
docker build -t devops-homework-apache .
docker run --rm -p 8082:80 devops-homework-apache
curl -fsS http://localhost:8082/
```
