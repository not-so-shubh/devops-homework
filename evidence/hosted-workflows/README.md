# Hosted Workflow Evidence

These transcripts were captured from successful GitHub-hosted runs, and the PNGs are readable terminal-style renders of those transcripts.

| Workflow | Successful run | Evidence |
|---|---|---|
| CI/CD | [37197231672](https://github.com/not-so-shubh/devops-homework/actions/runs/37197231672) | [transcript](ci-cd-success.txt) · [capture](01-ci-cd-success.png) |
| DevSecOps | [37197332796](https://github.com/not-so-shubh/devops-homework/actions/runs/37197332796) | [transcript](devsecops-success.txt) · [capture](02-devsecops-success.png) |
| Final project | [37197332795](https://github.com/not-so-shubh/devops-homework/actions/runs/37197332795) | [transcript](final-project-success.txt) · [capture](03-final-project-success.png) |

Each transcript records every job conclusion, the Kubernetes deployment job's steps, and the published OCI image index. All three Kubernetes smoke deployments succeeded. Each published image includes `linux/amd64` and `linux/arm64` manifests plus BuildKit attestations.
