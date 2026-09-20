#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="$ROOT_DIR/evidence/command-outputs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/devops-homework-verify.XXXXXX")"
PASS_COUNT=0
FAIL_COUNT=0
BLOCKED_COUNT=0

mkdir -p "$EVIDENCE_DIR"
trap 'rm -rf -- "$TMP_DIR"' EXIT

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS: %s\n' "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: %s\n' "$1" >&2; }
blocked() { BLOCKED_COUNT=$((BLOCKED_COUNT + 1)); printf 'BLOCKED/SKIP: %s\n' "$1"; }

printf '=== Repository structure ===\n'
REQUIRED_PATHS=(
  README.md AUDIT.md .gitignore
  01-linux-fundamentals/README.md
  02-shell-scripting/README.md
  03-networking-fundamentals/README.md
  04-git-github/README.md
  05-docker-fundamentals/README.md
  06-dockerfiles-images/README.md
  07-docker-networking-volumes/README.md
  08-kubernetes-fundamentals/README.md
  09-kubernetes-pods-replicasets-deployments/README.md
  09-kubernetes-pods-replicasets-deployments/pod.yml
  09-kubernetes-pods-replicasets-deployments/hello.yml
  09-kubernetes-pods-replicasets-deployments/replicaset.yml
  09-kubernetes-pods-replicasets-deployments/statefulset.yml
  09-kubernetes-pods-replicasets-deployments/daemonset.yml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/01-running.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/02-pending.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/03-succeeded.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/04-failed.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/05-crashloopbackoff.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/06-imagepullbackoff.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/07-readiness.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/08-liveness.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/09-startup.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/10-init-container.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/11-multi-container.yaml
  09-kubernetes-pods-replicasets-deployments/pod-lifecycle/12-termination.yaml
  09-kubernetes-pods-replicasets-deployments/01-rolling-update/deployment-v1.yaml
  09-kubernetes-pods-replicasets-deployments/01-rolling-update/deployment-v2.yaml
  09-kubernetes-pods-replicasets-deployments/02-blue-green/deployment-blue.yaml
  09-kubernetes-pods-replicasets-deployments/02-blue-green/deployment-green.yaml
  09-kubernetes-pods-replicasets-deployments/03-canary/deployment-stable.yaml
  09-kubernetes-pods-replicasets-deployments/03-canary/deployment-canary.yaml
  09-kubernetes-pods-replicasets-deployments/04-recreate/deployment-v1.yaml
  09-kubernetes-pods-replicasets-deployments/04-recreate/deployment-v2.yaml
  09-kubernetes-pods-replicasets-deployments/troubleshooting/healthy-deployment.yaml
  09-kubernetes-pods-replicasets-deployments/troubleshooting/broken-image.yaml
  09-kubernetes-pods-replicasets-deployments/troubleshooting/selector-mismatch.yaml
  09-kubernetes-pods-replicasets-deployments/troubleshooting/selector-match-fixed.yaml
  10-kubernetes-networking-services/README.md
  10-kubernetes-networking-services/01-clusterip/app-deployment.yaml
  10-kubernetes-networking-services/01-clusterip/service.yaml
  10-kubernetes-networking-services/01-clusterip/client-pod.yaml
  10-kubernetes-networking-services/02-nodeport/service.yaml
  10-kubernetes-networking-services/03-loadbalancer/service.yaml
  10-kubernetes-networking-services/04-externalname/service.yaml
  10-kubernetes-networking-services/05-headless/service.yaml
  10-kubernetes-networking-services/06-no-selector-service/service.yaml
  10-kubernetes-networking-services/06-no-selector-service/endpoints.yaml
  11-kubernetes-ingress-configmaps-secrets/README.md
  11-kubernetes-ingress-configmaps-secrets/01-configmap/app-config.yaml
  11-kubernetes-ingress-configmaps-secrets/02-secret/db-secret.yaml
  11-kubernetes-ingress-configmaps-secrets/03-ingress/ingress-tls.yaml
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/configmap.yaml
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/secret.yaml
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/backend.yaml
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/frontend.yaml
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/ingress.yaml
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/run-demo.sh
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/cleanup.sh
)

MISSING=0
for path in "${REQUIRED_PATHS[@]}"; do
  if [[ ! -e "$ROOT_DIR/$path" ]]; then
    printf 'Missing: %s\n' "$path" >&2
    MISSING=1
  fi
done
if [[ "$MISSING" -eq 0 ]]; then pass 'required 1–11 assignment structure exists'; else fail 'required repository files are missing'; fi

printf '\n=== Bash syntax ===\n'
SYNTAX_FAILED=0
while IFS= read -r -d '' script; do
  if ! bash -n "$script"; then SYNTAX_FAILED=1; fi
done < <(find "$ROOT_DIR" -path "$ROOT_DIR/.git" -prune -o -type f -name '*.sh' -print0)
if [[ "$SYNTAX_FAILED" -eq 0 ]]; then pass 'all shell scripts pass bash -n'; else fail 'one or more shell scripts have syntax errors'; fi

printf '\n=== Safe local demonstrations ===\n'
if "$ROOT_DIR/01-linux-fundamentals/link-practice.sh" > "$EVIDENCE_DIR/linux-link-demo.txt" 2>&1; then pass 'Linux link demonstration'; else fail 'Linux link demonstration'; fi
if printf 'verification-output\n' | SYSTEM_INFO_BASE_DIR="$TMP_DIR" "$ROOT_DIR/02-shell-scripting/system-info.sh" > "$EVIDENCE_DIR/shell-script-output.txt" 2>&1; then pass 'shell system-information script'; else fail 'shell system-information script'; fi
if NETWORK_EXTERNAL=0 "$ROOT_DIR/03-networking-fundamentals/collect-network-info.sh" > "$EVIDENCE_DIR/network-info.txt" 2>&1; then pass 'network information collector'; else fail 'network information collector'; fi
if "$ROOT_DIR/04-git-github/git-practice-demo.sh" > "$EVIDENCE_DIR/git-practice-output.txt" 2>&1; then pass 'Git commit/cherry-pick demonstration'; else fail 'Git commit/cherry-pick demonstration'; fi

printf '\n=== Docker configuration ===\n'
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  DOCKER_CONFIG_OK=1
  docker compose -f "$ROOT_DIR/05-docker-fundamentals/docker-compose.yml" config >/dev/null 2>&1 || DOCKER_CONFIG_OK=0
  docker compose -f "$ROOT_DIR/07-docker-networking-volumes/container-networking/docker-compose.yml" config >/dev/null 2>&1 || DOCKER_CONFIG_OK=0
  if [[ -f "$ROOT_DIR/07-docker-networking-volumes/bind-mount/docker-compose.yml" ]]; then
    docker compose -f "$ROOT_DIR/07-docker-networking-volumes/bind-mount/docker-compose.yml" config >/dev/null 2>&1 || DOCKER_CONFIG_OK=0
  fi
  if [[ "$DOCKER_CONFIG_OK" -eq 1 ]]; then pass 'Docker Compose files parse successfully'; else fail 'one or more Docker Compose files are invalid'; fi
else
  blocked 'Docker Compose CLI unavailable; config checks skipped'
fi

printf '\n=== Kubernetes YAML syntax ===\n'
YAML_PARSER=''
if command -v ruby >/dev/null 2>&1; then
  YAML_PARSER='ruby'
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
  YAML_PARSER='python'
fi

if [[ -z "$YAML_PARSER" ]]; then
  blocked 'No local YAML parser available (Ruby/PyYAML); Kubernetes syntax parse skipped'
else
  YAML_FAILED=0
  while IFS= read -r -d '' manifest; do
    if [[ "$YAML_PARSER" == 'ruby' ]]; then
      ruby -e 'require "yaml"; YAML.load_stream(File.read(ARGV[0]))' "$manifest" >/dev/null 2>&1 || { printf 'Invalid YAML: %s\n' "${manifest#$ROOT_DIR/}" >&2; YAML_FAILED=1; }
    else
      python3 - "$manifest" <<'PY' >/dev/null 2>&1 || { printf 'Invalid YAML: %s\n' "${manifest#$ROOT_DIR/}" >&2; YAML_FAILED=1; }
import sys, yaml
with open(sys.argv[1], 'r', encoding='utf-8') as handle:
    list(yaml.safe_load_all(handle))
PY
    fi
  done < <(find "$ROOT_DIR/08-kubernetes-fundamentals" "$ROOT_DIR/09-kubernetes-pods-replicasets-deployments" "$ROOT_DIR/10-kubernetes-networking-services" "$ROOT_DIR/11-kubernetes-ingress-configmaps-secrets" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 2>/dev/null)
  if [[ "$YAML_FAILED" -eq 0 ]]; then pass 'all Kubernetes YAML files are syntactically valid'; else fail 'one or more Kubernetes YAML files have syntax errors'; fi
fi

printf '\n=== Assignment-specific static checks ===\n'
STATIC_FAILED=0
grep -q 'nodePort: 30020' "$ROOT_DIR/09-kubernetes-pods-replicasets-deployments/02-blue-green/service-blue.yaml" || STATIC_FAILED=1
grep -q 'nodePort: 30030' "$ROOT_DIR/09-kubernetes-pods-replicasets-deployments/03-canary/service.yaml" || STATIC_FAILED=1
grep -q 'nodePort: 30040' "$ROOT_DIR/09-kubernetes-pods-replicasets-deployments/04-recreate/service.yaml" || STATIC_FAILED=1
grep -q 'clusterIP: None' "$ROOT_DIR/10-kubernetes-networking-services/05-headless/service.yaml" || STATIC_FAILED=1
grep -q 'type: ExternalName' "$ROOT_DIR/10-kubernetes-networking-services/04-externalname/service.yaml" || STATIC_FAILED=1
grep -q 'rewrite-target: /$2' "$ROOT_DIR/11-kubernetes-ingress-configmaps-secrets/04-full-demo/ingress.yaml" || STATIC_FAILED=1
grep -q 'secretName: campus-tls-cert' "$ROOT_DIR/11-kubernetes-ingress-configmaps-secrets/03-ingress/ingress-tls.yaml" || STATIC_FAILED=1
if [[ "$STATIC_FAILED" -eq 0 ]]; then pass 'assignment-critical Kubernetes settings are present'; else fail 'one or more assignment-critical Kubernetes settings are missing'; fi

printf '\n=== Kubernetes tooling ===\n'
if command -v kubectl >/dev/null 2>&1; then kubectl version --client >/dev/null 2>&1 && pass 'kubectl client is available' || fail 'kubectl client check failed'; else blocked 'kubectl is not installed'; fi
if command -v minikube >/dev/null 2>&1; then minikube version >/dev/null 2>&1 && pass 'Minikube is available' || fail 'Minikube version check failed'; else blocked 'Minikube is not installed'; fi

SUMMARY_FILE="$EVIDENCE_DIR/verification-summary.txt"
{
  echo 'DevOps Homework verification summary'
  echo "Generated: $(date)"
  echo "PASS: $PASS_COUNT"
  echo "FAIL: $FAIL_COUNT"
  echo "BLOCKED/SKIP: $BLOCKED_COUNT"
} | tee "$SUMMARY_FILE"

if [[ "$FAIL_COUNT" -gt 0 ]]; then exit 1; fi
exit 0
