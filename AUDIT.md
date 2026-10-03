# Completion Audit

This audit distinguishes **implementation**, **local verification**, and **account-dependent evidence**. A repository file is not falsely treated as proof of a real cluster, workflow or AWS operation.

| Area | Implementation | Verification route |
|---|---|---|
| Linux, shell, networking and Git | Complete scripts and explanations | Repository verifier and captured command output |
| Docker applications/builds/networking/volumes | Complete source, Dockerfiles and scoped labs | Compose builds, curl checks and browser/output evidence |
| Kubernetes Sessions 9-14 | Complete manifests, commands, cleanup and failure scenarios | Minikube evidence scripts and section checklists |
| Helm | Complete application chart and rollback workflow | `helm lint`, install/upgrade/rollback/test transcript |
| CI/CD | Complete app, tests, Dockerfile, workflow, artifacts and optional CD | Local tests/build plus GitHub Actions run |
| DevSecOps | Complete SAST, SCA, secret and image scanning gates | Local scanners plus GitHub Actions reports |
| Terraform/AWS | Complete S3, EC2/VPC and optional EKS configurations | `fmt`, `validate`, reviewed account-authorized plan/apply/destroy |
| Monitoring/observability | Complete Prometheus, Alertmanager, Grafana, Loki, Tempo and OTel configs | Compose health, targets, dashboards/logs/traces/alerts |
| GitOps | Complete Argo CD Applications and desired state | Argo CD Sync/Healthy plus deliberate self-heal test |
| Final project | Complete self-contained source-to-cloud implementation | Final workflow and end-to-end evidence checklist |

## Quality controls

- Non-root/read-only/capability-dropped containers and resource limits in production examples.
- Startup/readiness/liveness probes, HPA, storage, disruption budget and NetworkPolicy.
- Immutable SHA image tags in deployment workflows and security gates before publishing.
- Private/encrypted S3 resources, IMDSv2 and no public SSH in Terraform demos.
- No real secret, TLS key, kubeconfig, Terraform state or access key is committed.
- Every destructive cleanup targets a named container, namespace, Helm release or reviewed Terraform plan.

## Account-dependent gates

The following evidence cannot be manufactured locally: a successful GitHub-hosted run after pushing, GHCR package visibility, an authorized AWS apply/destroy and cloud console screenshots. Complete them only in the student's own accounts using the supplied commands, then add redacted evidence without credentials or private account details.
