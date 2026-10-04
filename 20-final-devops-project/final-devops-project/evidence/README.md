# Final Project Evidence Checklist

Capture: local tests; container health; SAST/SCA/secret/image scan reports; successful GitHub pipeline; registry image and immutable SHA; Terraform plan/apply/outputs/destroy; Kubernetes resources; ConfigMap/Secret injection; TLS Ingress; HPA/probes/storage; Helm install/upgrade/rollback/test; Prometheus metrics and alerts; logs/traces; Argo CD Synced/Healthy and self-healing; and the complete broken/fixed troubleshooting challenge.

Completed local evidence:

- [Kubernetes and Helm lifecycle](01-kubernetes-helm.png)
- [Broken troubleshooting state](02-troubleshooting-broken.png)
- [Fixed troubleshooting state and HTTP 200](03-troubleshooting-fixed.png)
- [Full troubleshooting transcript](troubleshooting-output.txt)
- [Argo CD Synced/Healthy proof](04-argocd-sync.png)
- [Argo CD configuration and deleted-Service self-healing](05-argocd-self-heal.png)
- [Full Argo CD transcript](argocd-output.txt)
- [Successful hosted final-project pipeline and multi-architecture image](../../../evidence/hosted-workflows/final-project-success.txt)

AWS apply/output/destroy evidence must come from an authorized AWS account and is intentionally never fabricated. Use `scripts/run-aws-evidence.sh final` only after reviewing the cost and credential safeguards.
