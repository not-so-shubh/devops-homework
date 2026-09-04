#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="apache-host"

cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if ! docker info >/dev/null 2>&1; then
  echo "BLOCKED: Docker daemon is unavailable." >&2
  exit 2
fi

if command -v ss >/dev/null 2>&1; then
  if ss -ltn '( sport = :80 )' | grep -q ':80'; then
    echo "BLOCKED: host port 80 is already in use; no container was started." >&2
    exit 2
  fi
elif command -v lsof >/dev/null 2>&1; then
  if lsof -nP -iTCP:80 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "BLOCKED: host port 80 is already in use; no container was started." >&2
    exit 2
  fi
else
  echo "BLOCKED: neither ss nor lsof is available to verify that host port 80 is free." >&2
  exit 2
fi

docker run --rm -d --name "$CONTAINER_NAME" --network host httpd:2.4-alpine

NETWORK_MODE="$(docker inspect --format '{{.HostConfig.NetworkMode}}' "$CONTAINER_NAME")"
echo "Network mode: $NETWORK_MODE"
test "$NETWORK_MODE" = "host"

for _ in $(seq 1 15); do
  if RESPONSE="$(curl -fsS --max-time 2 http://localhost/ 2>/dev/null)"; then
    printf 'Response: %s\n' "$RESPONSE"
    grep -Fq "It works!" <<< "$RESPONSE"
    echo "PASS: Apache responded directly on host port 80 in host network mode."
    exit 0
  fi
  sleep 1
done

echo "BLOCKED: host mode was configured, but localhost:80 was not reachable." >&2
echo "On Docker Desktop, enable host networking in Settings if the feature is supported." >&2
exit 2
