# Evidence Index

This directory preserves genuine runtime evidence from the earlier DevOps sections. It is deliberately separate from sample commands in README files.

## Existing evidence

| Evidence file | Producing check |
|---|---|
| `linux-link-demo.txt` | `01-linux-fundamentals/link-practice.sh` |
| `shell-script-output.txt` | `02-shell-scripting/system-info.sh` |
| `network-info.txt` | `03-networking-fundamentals/collect-network-info.sh` |
| `git-practice-output.txt` | `04-git-github/git-practice-demo.sh` |
| `docker-environment.txt` | Docker/Compose environment check |
| `docker-fundamentals-build.txt` | Section 05 Compose build/start |
| `docker-fundamentals-curl.txt` | Section 05 curl assertions and `docker compose ps` |
| `docker-multistage-build.txt` | Section 06 multi-stage build |
| `docker-multistage-output.txt` | Section 06 run/curl/`docker ps` proof |
| `docker-network-output.txt` | Section 07 network connectivity/isolation lab |
| `bind-mount-output.txt` | Section 07 bind-mount before/after lab |
| `host-network-output.txt` | Section 07 guarded host-network attempt |
| `verification-summary.txt` | Historical pre-refactor verifier summary; rerun the repaired verifier before relying on its totals |

## Kubernetes evidence

Kubernetes evidence belongs beside the Kubernetes section that generated it:

- `08-kubernetes-fundamentals/screenshots/`
- `09-kubernetes-pods-replicasets-deployments/screenshots/`
- `10-kubernetes-networking-services/screenshots/`
- `11-kubernetes-ingress-configmaps-secrets/screenshots/`

Do not copy example terminal output or another student's screenshots into these folders. Pod names, image IDs, cluster versions, IPs, node ages, timestamps, and rollout timing should come from the real local Minikube run.

Review all screenshots for tokens, passwords, unrelated terminal history, personal filesystem paths, and unnecessary private-network details before publishing.
