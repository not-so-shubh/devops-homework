# Hosted Workflow Evidence

These transcripts were captured from successful GitHub-hosted runs, and the PNGs are readable terminal-style renders of those transcripts.

| Workflow | Successful run | Evidence |
|---|---|---|
| CI/CD | [37212766677](https://github.com/not-so-shubh/devops-homework/actions/runs/37212766677) | [transcript](ci-cd-success.txt) · [capture](01-ci-cd-success.png) |
| DevSecOps | [37212766674](https://github.com/not-so-shubh/devops-homework/actions/runs/37212766674) | [transcript](devsecops-success.txt) · [capture](02-devsecops-success.png) |
| Final project | [37212766713](https://github.com/not-so-shubh/devops-homework/actions/runs/37212766713) | [transcript](final-project-success.txt) · [capture](03-final-project-success.png) |

Each transcript records every job conclusion, publish/deploy timestamps, the Kubernetes deployment steps, registry pull output, workload health, and the published OCI image index. All three runs prove that publishing completed before Kubernetes pulled and deployed the immutable SHA tag. Each published image includes `linux/amd64` and `linux/arm64` manifests plus BuildKit attestations.
