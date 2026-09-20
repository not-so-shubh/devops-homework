# Multi-Stage Build Submission

## Student

- **Student Name:** Shubh Jaiswal
- **Enrollment Number:** 24BCS10601

## Build

```bash
docker build -t devops-multistage-app ./06-dockerfiles-images/multistage-app
```

## Run on port 8080

```bash
docker run -d --name devops-multistage -p 8080:8080 devops-multistage-app
```

## Verify

```bash
curl -fsS http://localhost:8080/
docker ps --filter name=devops-multistage --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
```

Success requires `Hello World from Docker multi-stage build` plus a running container whose host port maps to container port 8080.

Existing genuine evidence is stored under `../evidence/command-outputs/`. Do not replace runtime evidence with invented terminal output.
