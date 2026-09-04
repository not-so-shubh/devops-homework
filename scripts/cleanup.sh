#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v docker >/dev/null 2>&1; then
  echo "SKIP: Docker CLI is not installed; no project Docker resources to remove."
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "SKIP: Docker daemon is unavailable; no cleanup commands were run."
  exit 0
fi

echo "Removing only DevOps homework Docker resources..."

for container in devops-multistage devops-hw-bind-mount apache-host; do
  if docker container inspect "$container" >/dev/null 2>&1; then
    docker rm -f "$container"
  fi
done

if [[ -f "$ROOT_DIR/docker-fundamentals/docker-compose.yml" ]]; then
  (
    cd "$ROOT_DIR/docker-fundamentals" || exit 1
    docker compose -p devops-hw-fundamentals down --remove-orphans
  )
fi

if [[ -f "$ROOT_DIR/docker-network/container-networking/docker-compose.yml" ]]; then
  (
    cd "$ROOT_DIR/docker-network/container-networking" || exit 1
    docker compose -p devops-hw-network down --volumes --remove-orphans
  )
fi

for image in \
  devops-homework-nodejs:local \
  devops-homework-python:local \
  devops-homework-java:local \
  devops-homework-apache:local \
  devops-homework-react:local \
  devops-homework-nginx:local \
  devops-multistage-app:local \
  devops-multistage-app; do
  if docker image inspect "$image" >/dev/null 2>&1; then
    docker image rm "$image" || echo "WARN: image $image is still in use and was retained." >&2
  fi
done

echo "PASS: scoped cleanup completed. No global prune command was used."
