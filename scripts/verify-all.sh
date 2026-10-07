#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/devops-homework-verify.XXXXXX")"
PASS_COUNT=0
FAIL_COUNT=0
BLOCKED_COUNT=0
trap 'rm -rf -- "$TMP_DIR"' EXIT

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS: %s\n' "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: %s\n' "$1" >&2; }
blocked() { BLOCKED_COUNT=$((BLOCKED_COUNT + 1)); printf 'BLOCKED/SKIP: %s\n' "$1"; }

printf '=== Complete assignment structure ===\n'
REQUIRED_PATHS=(
  README.md AUDIT.md .gitignore
  01-linux-fundamentals/README.md
  02-shell-scripting/system-info.sh
  03-networking-fundamentals/networking-commands.md
  04-git-github/git-practice-demo.sh
  05-docker-fundamentals/docker-compose.yml
  06-dockerfiles-images/multistage-app/Dockerfile
  07-docker-networking-volumes/container-networking/docker-compose.yml
  08-kubernetes-fundamentals/README.md
  09-kubernetes-pods-replicasets-deployments/README.md
  10-kubernetes-networking-services/README.md
  11-kubernetes-ingress-configmaps-secrets/README.md
  12-kubernetes-storage-hpa-probes/02-hpa/hpa.yaml
  12-kubernetes-storage-hpa-probes/03-mini-project/project.yaml
  13-kubernetes-troubleshooting/mini-project/fixed.yaml
  14-helm/devops-web/Chart.yaml
  15-cicd-github-actions/Dockerfile
  16-devsecops-pipeline/security/.gitleaks.toml
  17-terraform-aws/terraform-s3-demo/main.tf
  18-cloud-terraform-project/main.tf
  19-monitoring-observability-gitops/docker-compose.yml
  19-monitoring-observability-gitops/gitops/application.yaml
  20-final-devops-project/final-devops-project/README.md
  20-final-devops-project/final-devops-project/backend/app/main.py
  20-final-devops-project/final-devops-project/frontend/package-lock.json
  20-final-devops-project/final-devops-project/docker-compose.yml
  20-final-devops-project/final-devops-project/kubernetes/kustomization.yaml
  20-final-devops-project/final-devops-project/helm/final-app/Chart.yaml
  20-final-devops-project/final-devops-project/terraform/main.tf
  20-final-devops-project/final-devops-project/terraform/terraform.tfvars.example
  .github/workflows/ci-cd.yml
  .github/workflows/devsecops.yml
  .github/workflows/final-project.yml
)

MISSING=0
for path in "${REQUIRED_PATHS[@]}"; do
  if [[ ! -e "$ROOT_DIR/$path" ]]; then
    printf 'Missing: %s\n' "$path" >&2
    MISSING=1
  fi
done
if [[ "$MISSING" -eq 0 ]]; then pass 'all Sessions 1-21 deliverable roots exist'; else fail 'required assignment files are missing'; fi

printf '\n=== Bash and Python ===\n'
SYNTAX_FAILED=0
while IFS= read -r -d '' script; do
  bash -n "$script" || SYNTAX_FAILED=1
done < <(find "$ROOT_DIR" -path "$ROOT_DIR/.git" -prune -o -type f -name '*.sh' -print0)
if [[ "$SYNTAX_FAILED" -eq 0 ]]; then pass 'all shell scripts pass bash -n'; else fail 'shell syntax error'; fi

PYTHON_FAILED=0
for tests in \
  "$ROOT_DIR/15-cicd-github-actions/application/tests" \
  "$ROOT_DIR/16-devsecops-pipeline/application/tests"; do
  python3 -m unittest discover -s "$tests" -v || PYTHON_FAILED=1
done
if [[ -x "$ROOT_DIR/20-final-devops-project/final-devops-project/backend/.venv/bin/pytest" ]]; then
  (cd "$ROOT_DIR/20-final-devops-project/final-devops-project/backend" && .venv/bin/pytest -q) || PYTHON_FAILED=1
elif python3 -c 'import fastapi, pytest, sqlalchemy' >/dev/null 2>&1; then
  (cd "$ROOT_DIR/20-final-devops-project/final-devops-project/backend" && python3 -m pytest -q) || PYTHON_FAILED=1
else
  blocked 'final-project Python dependencies unavailable; hosted workflow runs its pytest suite'
fi
if [[ "$PYTHON_FAILED" -eq 0 ]]; then pass 'all application unit tests pass'; else fail 'application unit tests failed'; fi

printf '\n=== Safe demonstrations ===\n'
if "$ROOT_DIR/01-linux-fundamentals/link-practice.sh" >"$TMP_DIR/linux.txt" 2>&1; then pass 'Linux link behavior'; else fail 'Linux link behavior'; fi
if ps aux >/dev/null 2>&1; then
  if printf 'verification-output\n' | SYSTEM_INFO_BASE_DIR="$TMP_DIR" "$ROOT_DIR/02-shell-scripting/system-info.sh" >"$TMP_DIR/system.txt" 2>&1; then pass 'system-information script'; else fail 'system-information script'; fi
elif command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  if docker run --rm -i -v "$ROOT_DIR/02-shell-scripting:/lab:ro" ubuntu:24.04 bash -lc "printf 'verification-output\\n' | SYSTEM_INFO_BASE_DIR=/tmp /lab/system-info.sh" >"$TMP_DIR/system.txt" 2>&1; then pass 'system-information script (Ubuntu container fallback)'; else fail 'system-information script'; fi
else
  blocked 'host sandbox denies process listing; system-information runtime check skipped'
fi
if NETWORK_EXTERNAL=0 "$ROOT_DIR/03-networking-fundamentals/collect-network-info.sh" >"$TMP_DIR/network.txt" 2>&1; then pass 'network collector'; else fail 'network collector'; fi
if "$ROOT_DIR/04-git-github/git-practice-demo.sh" >"$TMP_DIR/git.txt" 2>&1; then pass 'Git commit/cherry-pick demonstration'; else fail 'Git demonstration'; fi

printf '\n=== YAML and workflow syntax ===\n'
YAML_FAILED=0
if command -v ruby >/dev/null 2>&1; then
  while IFS= read -r -d '' manifest; do
    ruby -e 'require "yaml"; YAML.load_stream(File.read(ARGV[0]))' "$manifest" >/dev/null 2>&1 || { printf 'Invalid YAML: %s\n' "${manifest#$ROOT_DIR/}" >&2; YAML_FAILED=1; }
  done < <(find "$ROOT_DIR" \( -path "$ROOT_DIR/.git" -o -path "$ROOT_DIR/14-helm/devops-web/templates" -o -path "$ROOT_DIR/20-final-devops-project/final-devops-project/helm/final-app/templates" \) -prune -o -type f \( -name '*.yaml' -o -name '*.yml' \) -print0)
elif python3 -c 'import yaml' >/dev/null 2>&1; then
  while IFS= read -r -d '' manifest; do
    python3 -c 'import sys,yaml; list(yaml.safe_load_all(open(sys.argv[1], encoding="utf-8")))' "$manifest" >/dev/null 2>&1 || { printf 'Invalid YAML: %s\n' "${manifest#$ROOT_DIR/}" >&2; YAML_FAILED=1; }
  done < <(find "$ROOT_DIR" \( -path "$ROOT_DIR/.git" -o -path "$ROOT_DIR/14-helm/devops-web/templates" -o -path "$ROOT_DIR/20-final-devops-project/final-devops-project/helm/final-app/templates" \) -prune -o -type f \( -name '*.yaml' -o -name '*.yml' \) -print0)
else
  blocked 'Ruby or PyYAML is required for YAML parse checks'
fi
if [[ "$YAML_FAILED" -eq 0 ]]; then pass 'all YAML and workflow files parse'; else fail 'one or more YAML files are invalid'; fi

printf '\n=== Docker and Compose ===\n'
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE_FAILED=0
  for compose_file in \
    "$ROOT_DIR/05-docker-fundamentals/docker-compose.yml" \
    "$ROOT_DIR/07-docker-networking-volumes/container-networking/docker-compose.yml" \
    "$ROOT_DIR/19-monitoring-observability-gitops/docker-compose.yml" \
    "$ROOT_DIR/20-final-devops-project/final-devops-project/docker-compose.yml"; do
    docker compose -f "$compose_file" config -q || COMPOSE_FAILED=1
  done
  if [[ "$COMPOSE_FAILED" -eq 0 ]]; then pass 'all Docker Compose configurations render'; else fail 'Docker Compose rendering failed'; fi
else
  blocked 'Docker Compose CLI unavailable'
fi

printf '\n=== Helm ===\n'
if command -v helm >/dev/null 2>&1; then
  HELM_FAILED=0
  helm lint "$ROOT_DIR/14-helm/devops-web" || HELM_FAILED=1
  helm lint "$ROOT_DIR/20-final-devops-project/final-devops-project/helm/final-app" || HELM_FAILED=1
  if [[ "$HELM_FAILED" -eq 0 ]]; then pass 'both Helm charts lint successfully'; else fail 'Helm lint failed'; fi
else
  blocked 'Helm CLI unavailable'
fi

printf '\n=== Terraform ===\n'
if command -v terraform >/dev/null 2>&1; then
  TERRAFORM_FAILED=0
  for tf_dir in \
    "$ROOT_DIR/17-terraform-aws/terraform-s3-demo" \
    "$ROOT_DIR/18-cloud-terraform-project" \
    "$ROOT_DIR/20-final-devops-project/final-devops-project/terraform"; do
    terraform -chdir="$tf_dir" fmt -check || TERRAFORM_FAILED=1
    terraform -chdir="$tf_dir" init -backend=false -input=false >/dev/null || TERRAFORM_FAILED=1
    terraform -chdir="$tf_dir" validate || TERRAFORM_FAILED=1
  done
  if [[ "$TERRAFORM_FAILED" -eq 0 ]]; then pass 'all Terraform projects format and validate'; else fail 'Terraform validation failed'; fi
else
  blocked 'Terraform CLI unavailable'
fi

printf '\n=== Assignment-critical controls ===\n'
STATIC_FAILED=0
grep -q 'averageUtilization: 50' "$ROOT_DIR/12-kubernetes-storage-hpa-probes/02-hpa/hpa.yaml" || STATIC_FAILED=1
grep -q 'kind: HorizontalPodAutoscaler' "$ROOT_DIR/20-final-devops-project/final-devops-project/kubernetes/autoscaling.yaml" || STATIC_FAILED=1
grep -q 'readOnlyRootFilesystem: true' "$ROOT_DIR/20-final-devops-project/final-devops-project/kubernetes/workload.yaml" || STATIC_FAILED=1
grep -q 'kind: Application' "$ROOT_DIR/20-final-devops-project/final-devops-project/gitops/application.yaml" || STATIC_FAILED=1
grep -q 'trivy-action' "$ROOT_DIR/.github/workflows/final-project.yml" || STATIC_FAILED=1
grep -q 'gitleaks' "$ROOT_DIR/.github/workflows/final-project.yml" || STATIC_FAILED=1
grep -q 'aws_eks_cluster' "$ROOT_DIR/20-final-devops-project/final-devops-project/terraform/main.tf" || STATIC_FAILED=1
grep -q '@app.post("/api/releases"' "$ROOT_DIR/20-final-devops-project/final-devops-project/backend/app/main.py" || STATIC_FAILED=1
grep -q '@app.put("/api/releases/{release_id}"' "$ROOT_DIR/20-final-devops-project/final-devops-project/backend/app/main.py" || STATIC_FAILED=1
grep -q '@app.delete("/api/releases/{release_id}"' "$ROOT_DIR/20-final-devops-project/final-devops-project/backend/app/main.py" || STATIC_FAILED=1
grep -q 'release-tracker-backend' "$ROOT_DIR/.github/workflows/final-project.yml" || STATIC_FAILED=1
grep -q 'release-tracker-frontend' "$ROOT_DIR/.github/workflows/final-project.yml" || STATIC_FAILED=1
if [[ "$STATIC_FAILED" -eq 0 ]]; then pass 'HPA, runtime hardening, GitOps, security gates and cloud resources are present'; else fail 'assignment-critical control is missing'; fi

printf '\n=== Summary ===\n'
printf 'PASS: %s\nFAIL: %s\nBLOCKED/SKIP: %s\n' "$PASS_COUNT" "$FAIL_COUNT" "$BLOCKED_COUNT"
if [[ "$FAIL_COUNT" -gt 0 ]]; then exit 1; fi
