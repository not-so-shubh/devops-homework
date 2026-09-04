# Docker Multi-Stage Build

The original instructor repository URL was not present in the supplied project. This folder therefore contains a correct local equivalent instead of an invented clone source.

`multistage-app/Dockerfile` uses a Go compiler image only to build a static binary, then copies that binary into a small Alpine runtime with a non-root user. Compiler tools and source code are absent from the final image.

## Build, run, and verify

```bash
docker build -t devops-multistage-app ./multistage-app
docker run -d --name devops-multistage -p 8080:8080 devops-multistage-app
curl -fsS http://localhost:8080/
docker ps --filter name=devops-multistage
docker rm -f devops-multistage
```

The response clearly includes the exact required phrase:

```text
Hello World from Docker multi-stage build
```

## Three application types

The assignment's “at least three types” requirement is satisfied without redundant copies by the independently containerized applications under Docker Fundamentals:

- [Node.js / Express](../docker-fundamentals/nodejs-app/)
- [Python / Flask](../docker-fundamentals/python-app/)
- [Java 21](../docker-fundamentals/java-app/)

All three can run together using [the fundamentals Compose file](../docker-fundamentals/docker-compose.yml). See [submission.md](submission.md) for the student-facing evidence format.
