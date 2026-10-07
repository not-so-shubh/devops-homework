# Evidence Index

This directory preserves genuine runtime evidence from the earlier DevOps sections. It is deliberately separate from sample commands in README files.

## Existing evidence

| Evidence file | Producing check |
|---|---|
| `linux-link-demo.txt` | `01-linux-fundamentals/link-practice.sh` |
| `linux-user-practice.txt` | Ubuntu 24.04 `adduser` account creation and cleanup |
| `linux-journalctl-practice.txt` | Ubuntu 24.04 systemd service and `journalctl -u` practice |
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
| `host-network-linux-output.txt` | Section 07 successful native-Linux host-network verification in a disposable daemon |
| `verification-summary.txt` | Current full verifier run: 12 passed, 0 failed, 0 skipped |
| `aws-session18-live.txt` | Authorized AWS Terraform plan, apply, state/output and successful seven-resource destroy |
| `../18-cloud-terraform-project/evidence/aws-session19-live.txt` | Authorized AWS Terraform plan, 11-resource apply, live HTTP verification and successful 11-resource destroy |
| `../20-final-devops-project/final-devops-project/evidence/aws-final-infrastructure-live.txt` | Authorized final AWS Terraform plan, 12-resource apply/output and successful destroy with EKS cost controls retained |

## Hosted pipeline evidence

[`hosted-workflows/`](hosted-workflows/) contains genuine successful GitHub Actions transcripts and captures for the CI/CD, DevSecOps and final-project pipelines. The records include the real Kind/Helm deployment jobs and multi-architecture GHCR manifests.

## Kubernetes evidence

Kubernetes evidence belongs beside the Kubernetes section that generated it:

- `08-kubernetes-fundamentals/screenshots/`
- `09-kubernetes-pods-replicasets-deployments/screenshots/`
- `10-kubernetes-networking-services/screenshots/`
- `11-kubernetes-ingress-configmaps-secrets/screenshots/`
- `12-kubernetes-storage-hpa-probes/evidence/`
- `13-kubernetes-troubleshooting/evidence/`
- `14-helm/evidence/`
- `19-monitoring-observability-gitops/evidence/`
- `20-final-devops-project/final-devops-project/evidence/`

Do not copy example terminal output or another student's screenshots into these folders. Pod names, image IDs, cluster versions, IPs, node ages, timestamps, and rollout timing should come from the real local Minikube run.

Review all screenshots for tokens, passwords, unrelated terminal history, personal filesystem paths, and unnecessary private-network details before publishing.
