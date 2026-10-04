# Final Project Evidence Checklist

Capture: local tests; container health; SAST/SCA/secret/image scan reports; successful GitHub pipeline; registry image and immutable SHA; Terraform plan/apply/outputs/destroy; Kubernetes resources; ConfigMap/Secret injection; TLS Ingress; HPA/probes/storage; Helm install/upgrade/rollback/test; Prometheus metrics and alerts; logs/traces; Argo CD Synced/Healthy and self-healing; and the complete broken/fixed troubleshooting challenge.

Completed local evidence:

- [Kubernetes and Helm lifecycle](01-kubernetes-helm.png)
- [Broken troubleshooting state](02-troubleshooting-broken.png)
- [Fixed troubleshooting state and HTTP 200](03-troubleshooting-fixed.png)
- [Full troubleshooting transcript](troubleshooting-output.txt)

The hosted pipeline/GHCR evidence and final Argo CD proof are generated only from successful hosted runs. AWS apply/output/destroy evidence must come from an authorized AWS account and is intentionally never fabricated.
