# Security Design

- SAST: Bandit examines Python source.
- SCA: pip-audit checks dependency advisories.
- Secret scanning: Gitleaks scans full Git history.
- Container scanning: separate Trivy jobs block any HIGH/CRITICAL finding in either application image and upload both SARIF reports.
- Registry: immutable SHA tags are published to GHCR; Kubernetes deploys the scanned SHA, not an unverified mutable build.
- Runtime: both app tiers use non-root UIDs, read-only root filesystems, dropped Linux capabilities, RuntimeDefault seccomp, no service-account tokens and NetworkPolicies.
- Supply chain: CI jobs use minimal permissions and production deployment requires an environment gate plus a namespace-scoped kubeconfig.

The committed Secret value is an explicit lab placeholder. Production should use AWS Secrets Manager or another external manager through External Secrets/Secrets Store CSI. Never store real credentials in Git, Terraform variables, container layers or workflow logs.
