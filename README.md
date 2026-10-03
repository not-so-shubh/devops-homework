# Complete DevOps Homework Portfolio

**Student:** Shubh Jaiswal
**Enrollment Number:** 24BCS10601

This public repository implements the complete assignment path from Linux fundamentals through a final cloud-native DevSecOps project. Every practical section contains executable source/configuration, reproduction commands, cleanup instructions and an evidence location. Runtime output is kept separate from explanatory samples so a reviewer can distinguish actual execution from documentation.

## Assignment map

| Repository section | PDF assignment coverage |
|---|---|
| [`01-linux-fundamentals`](01-linux-fundamentals/) | Links, account creation, journalctl and command practice |
| [`02-shell-scripting`](02-shell-scripting/) | Interactive system-information script and process redirection |
| [`03-networking-fundamentals`](03-networking-fundamentals/) | Linux networking commands, output and explanations |
| [`04-git-github`](04-git-github/) | `commit -a`, branches, log and cherry-pick |
| [`05-docker-fundamentals`](05-docker-fundamentals/) | Six Hello World applications and Dockerfiles |
| [`06-dockerfiles-images`](06-dockerfiles-images/) | Multi-stage build, port 8080 and deployment evidence |
| [`07-docker-networking-volumes`](07-docker-networking-volumes/) | Three networks, host mode, bind mounts and overlay research |
| [`08-kubernetes-fundamentals`](08-kubernetes-fundamentals/) | Minikube, architecture, objects and Kubernetes tutorial |
| [`09-kubernetes-pods-replicasets-deployments`](09-kubernetes-pods-replicasets-deployments/) | Session 10: lifecycle and four deployment strategies |
| [`10-kubernetes-networking-services`](10-kubernetes-networking-services/) | Session 11: five Service types, FQDN and CoreDNS |
| [`11-kubernetes-ingress-configmaps-secrets`](11-kubernetes-ingress-configmaps-secrets/) | Session 12: ConfigMaps, Secrets, Ingress and troubleshooting |
| [`12-kubernetes-storage-hpa-probes`](12-kubernetes-storage-hpa-probes/) | Session 13: storage, HPA, probes and mini-project |
| [`13-kubernetes-troubleshooting`](13-kubernetes-troubleshooting/) | Session 14: eight failure modes and troubleshooting mini-project |
| [`14-helm`](14-helm/) | Session 15: chart, commands, upgrades, rollback and Helm test |
| [`15-cicd-github-actions`](15-cicd-github-actions/) | Session 16: application, tests, image, CI/CD and artifacts |
| [`16-devsecops-pipeline`](16-devsecops-pipeline/) | Session 17: SAST, SCA, secrets, image scan and security gate |
| [`17-terraform-aws`](17-terraform-aws/) | Session 18: S3 project and five AWS service studies |
| [`18-cloud-terraform-project`](18-cloud-terraform-project/) | Session 19: VPC, subnet, Security Group, EC2 and S3 |
| [`19-monitoring-observability-gitops`](19-monitoring-observability-gitops/) | Session 20: metrics, logs, traces, alerts and GitOps |
| [`20-final-devops-project`](20-final-devops-project/final-devops-project/) | Session 21: complete application-to-cloud final project |

## End-to-end verification

```bash
chmod +x scripts/verify-all.sh scripts/cleanup.sh
./scripts/verify-all.sh
```

The verifier checks required structure, shell/Python syntax, unit tests, Compose rendering, Kubernetes YAML, Helm charts, Terraform formatting/validation when the CLI is available, and security-sensitive settings. Runtime exercises use the section READMEs because they intentionally create containers, cluster resources or cloud infrastructure.

## GitHub Actions

- [CI/CD demo](.github/workflows/ci-cd.yml)
- [DevSecOps pipeline](.github/workflows/devsecops.yml)
- [Final project pipeline](.github/workflows/final-project.yml)

All workflows follow least-privilege permissions. Publishing uses the short-lived `GITHUB_TOKEN`; cluster deployment is disabled unless the documented variable and namespace-scoped kubeconfig secret are configured.

## Evidence policy

- `evidence/command-outputs/` contains genuine local execution transcripts.
- Browser screenshots and terminal captures are stored in the relevant `evidence/` or `screenshots/` directories.
- Examples in documentation are never presented as observed output.
- Real credentials, private keys, kubeconfigs, Terraform state and cloud account identifiers must not be committed.
- AWS apply/destroy and GitHub-hosted pipeline screenshots must come from the student's authorized account.

## Safety and cleanup

Each lab uses scoped names/namespaces. Cleanup scripts remove only homework resources and never run global Docker or Kubernetes prune operations. Terraform plans must be reviewed before apply; billable AWS resources must be destroyed when the evidence is captured.
