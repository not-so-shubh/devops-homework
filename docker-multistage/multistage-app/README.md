# Multi-stage App

The build stage compiles the Go HTTP server; the runtime stage contains only Alpine, an unprivileged account, and the compiled binary.

```bash
docker build -t devops-multistage-app .
docker run --rm -p 8080:8080 devops-multistage-app
curl -fsS http://localhost:8080/
```

Expected phrase: `Hello World from Docker multi-stage build`.
