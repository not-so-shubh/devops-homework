#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo 'Removing only DevOps homework Docker resources...'

  for container in devops-multistage devops-hw-bind-mount apache-host; do
    docker container inspect "$container" >/dev/null 2>&1 && docker rm -f "$container" >/dev/null || true
  done

  if [[ -f "$ROOT_DIR/05-docker-fundamentals/docker-compose.yml" ]]; then
    (cd "$ROOT_DIR/05-docker-fundamentals" && docker compose -p devops-hw-fundamentals down --remove-orphans) >/dev/null 2>&1 || true
  fi

  if [[ -f "$ROOT_DIR/07-docker-networking-volumes/container-networking/docker-compose.yml" ]]; then
    (cd "$ROOT_DIR/07-docker-networking-volumes/container-networking" && docker compose -p devops-hw-network down --volumes --remove-orphans) >/dev/null 2>&1 || true
  fi
else
  echo 'SKIP: Docker daemon unavailable; Docker cleanup not run.'
fi

cat <<'EOF'
Kubernetes resources are not deleted globally by this script.
Use the cleanup script inside the Kubernetes lab you ran, for example:
  11-kubernetes-ingress-configmaps-secrets/04-full-demo/cleanup.sh
This prevents accidental deletion from an unrelated cluster/context.
EOF

echo 'PASS: scoped cleanup completed; no global prune/delete-all command was used.'
