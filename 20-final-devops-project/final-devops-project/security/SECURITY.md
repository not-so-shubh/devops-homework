# Security Design

- SAST: Bandit examines Python source.
- SCA: pip-audit checks dependency advisories.
- Secret scanning: Gitleaks scans full Git history.
- Container scanning: Trivy blocks unfixed HIGH/CRITICAL findings.
- Registry: immutable SHA tags are published to GHCR; Kubernetes deploys the scanned SHA, not an unverified mutable build.
- Runtime: non-root UID, read-only root filesystem, dropped Linux capabilities, RuntimeDefault seccomp, no service-account token and NetworkPolicies.
- Supply chain: CI jobs use minimal permissions and production deployment requires an environment gate plus a namespace-scoped kubeconfig.

The committed Secret value is an explicit lab placeholder. Production should use AWS Secrets Manager or another external manager through External Secrets/Secrets Store CSI. Never store real credentials in Git, Terraform variables, container layers or workflow logs.
