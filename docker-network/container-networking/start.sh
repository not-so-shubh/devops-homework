#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! docker info >/dev/null 2>&1; then
  echo "BLOCKED: Docker daemon is unavailable." >&2
  exit 2
fi

docker compose -p devops-hw-network up -d

echo "Waiting for MySQL health check..."
for _ in $(seq 1 40); do
  STATUS="$(docker compose -p devops-hw-network ps --format json database 2>/dev/null || true)"
  if printf '%s' "$STATUS" | grep -q 'healthy'; then
    docker compose -p devops-hw-network ps
    echo "PASS: networking lab is running and MySQL is healthy."
    exit 0
  fi
  sleep 2
done

docker compose -p devops-hw-network ps >&2
docker compose -p devops-hw-network logs database >&2
echo "FAIL: MySQL did not become healthy in time." >&2
exit 1
