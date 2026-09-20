# 06 — Dockerfiles & Images / Multi-Stage Build

This section preserves the previously verified multi-stage Docker exercise while aligning it with the numbered cumulative homework structure.

`multistage-app/Dockerfile` uses a Go compiler image only for the build stage, then copies the resulting binary into a small Alpine runtime image. Compiler tools and source code are therefore absent from the final runtime stage.

## Build, run, and verify

From the repository root:

```bash
docker build -t devops-multistage-app ./06-dockerfiles-images/multistage-app
docker run -d --name devops-multistage -p 8080:8080 devops-multistage-app
curl -fsS http://localhost:8080/
docker ps --filter name=devops-multistage
docker rm -f devops-multistage
```

The required response contains:

```text
Hello World from Docker multi-stage build
```

## Three application types

The related container examples remain in Section 05:

- [Node.js / Express](../05-docker-fundamentals/nodejs-app/)
- [Python / Flask](../05-docker-fundamentals/python-app/)
- [Java 21](../05-docker-fundamentals/java-app/)

All six Section 05 applications can be started from [its Compose file](../05-docker-fundamentals/docker-compose.yml).

Existing genuine build/runtime evidence is retained under `../evidence/command-outputs/`, and the screenshot checklist is under `../evidence/screenshots/`.
