# Java App

Dependency-free Java 21 HTTP server. The build stage compiles the source; the smaller JRE stage runs the class as numeric non-root user `10001` on port `8080`.

```bash
docker build -t devops-homework-java .
docker run --rm -p 8081:8080 devops-homework-java
curl -fsS http://localhost:8081/
```

Expected text: `Hello World from Java`.
