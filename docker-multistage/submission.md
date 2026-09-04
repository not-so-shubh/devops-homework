# Multi-Stage Build Submission

## Student

- **Student Name:** Shubh Jaiswal
- **Enrollment Number:** 24BCS10601

These values were derived from local Git configuration. Confirm them before submission.

## Build

```bash
docker build -t devops-multistage-app ./docker-multistage/multistage-app
```

## Run on port 8080

```bash
docker run -d --name devops-multistage -p 8080:8080 devops-multistage-app
```

## Curl verification

```bash
curl -fsS http://localhost:8080/
```

Success requires a response containing exactly this phrase:

```text
Hello World from Docker multi-stage build
```

Real captured output, when Docker was available, is stored in `../evidence/command-outputs/docker-multistage-output.txt`. If that file records a blocked daemon, rerun the global verifier on a Docker-capable machine rather than inserting invented output.

## `docker ps` evidence

```bash
docker ps --filter name=devops-multistage --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
```

The row must show container `devops-multistage` and a published host mapping to container port `8080`.

## Screenshot checklist

1. With the container running, open `http://localhost:8080/` and capture the exact heading.
2. Run the formatted `docker ps` command and capture its real row with the port mapping.
3. Save the files as `12-multistage-browser.png` and `13-multistage-docker-ps.png` under `evidence/screenshots/`.

Never replace these proof points with a screenshot of static source text.
