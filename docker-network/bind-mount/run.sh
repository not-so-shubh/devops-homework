#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PORT="${BIND_MOUNT_PORT:-8085}"
CONTAINER_NAME="devops-hw-bind-mount"

if ! docker info >/dev/null 2>&1; then
  echo "BLOCKED: Docker daemon is unavailable." >&2
  exit 2
fi

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "FAIL: container $CONTAINER_NAME already exists; remove it with scripts/cleanup.sh first." >&2
  exit 1
fi

docker run --rm -d \
  --name "$CONTAINER_NAME" \
  -p "127.0.0.1:${PORT}:80" \
  --mount "type=bind,source=$SCRIPT_DIR/site,target=/usr/share/nginx/html,readonly" \
  nginx:1.27-alpine

echo "Started $CONTAINER_NAME at http://localhost:${PORT}/"
