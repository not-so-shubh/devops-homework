# Session 17 - Complete CI/CD and DevSecOps

**Student:** Shubh Jaiswal
**Enrollment:** 24BCS10601

This project implements the required security-aware delivery flow in [`.github/workflows/devsecops.yml`](../.github/workflows/devsecops.yml).

```text
Code -> Build -> Unit Test -> SAST -> SCA -> Secret Scan
     -> Docker Build -> Container Scan -> Security Gate
     -> Push Image -> Deploy to Kubernetes
```

## Security controls

| Stage | Tool/control | Gate |
|---|---|---|
| Unit test | Python `unittest` | Any failed test stops dependent jobs |
| SAST | Bandit | High-severity source findings fail the job |
| SCA | pip-audit | Known vulnerable dependencies fail the job |
| Secret scan | Gitleaks | Verified secret patterns fail the job |
| Container scan | Trivy | Unfixed HIGH/CRITICAL OS or library vulnerabilities fail the job |
| Kubernetes smoke deployment | Ephemeral Kind cluster | Deploys the gated revision and verifies `/health` before publication |
| Image publishing | GHCR + immutable SHA tag | Runs only after every security and deployment job succeeds |
| Kubernetes admission posture | Non-root, dropped capabilities, read-only root FS, limits and probes | Manifest is statically validated before deployment |

## Local verification

```bash
python3 -m unittest discover -s application/tests -v
python3 -m pip install --user bandit pip-audit
bandit -q -r application
pip-audit -r requirements.txt
gitleaks detect --source .. --config security/.gitleaks.toml --no-banner
docker build -t devsecops-demo:local .
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 devsecops-demo:local
kubectl apply --dry-run=client -f kubernetes/
```

## Secrets and registry

The workflow uses only the short-lived built-in `GITHUB_TOKEN` to publish a multi-architecture image to GHCR. It always proves deployment in an ephemeral Kind cluster. A second deployment to an external cluster is gated by repository variable `ENABLE_DEVSECOPS_DEPLOY=true` and secret `KUBE_CONFIG`. The kubeconfig should grant only namespace-scoped deployment permissions. No cloud or registry password is committed.

SARIF and plain-text reports are uploaded as workflow artifacts even when a security job fails, making findings auditable. Production should also protect the environment with required reviewers and branch protection.
