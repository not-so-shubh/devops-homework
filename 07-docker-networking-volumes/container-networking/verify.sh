#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! docker info >/dev/null 2>&1; then
  echo "BLOCKED: Docker daemon is unavailable." >&2
  exit 2
fi

echo "=== Project networks ==="
docker network ls --filter name=devops_hw_

for network in devops_hw_frontend_net devops_hw_backend_net devops_hw_database_net; do
  echo
  echo "=== Inspect $network ==="
  docker network inspect "$network" --format '{{json .Containers}}'
done

echo
echo "=== Frontend -> backend by service DNS ==="
FRONTEND_RESPONSE="$(docker compose -p devops-hw-network exec -T frontend wget -qO- http://backend/)"
printf '%s\n' "$FRONTEND_RESPONSE"
grep -Fq "Hello from the backend service" <<< "$FRONTEND_RESPONSE"

echo
echo "=== Backend -> database TCP/3306 by service DNS ==="
docker compose -p devops-hw-network exec -T backend nc -z -w 5 database 3306
echo "PASS: backend reached database:3306."

echo
echo "=== Database health ==="
docker compose -p devops-hw-network exec -T database sh -c 'mysqladmin ping -h 127.0.0.1 -uroot -p"$MYSQL_ROOT_PASSWORD" --silent'

echo
echo "=== Frontend isolation from database ==="
if docker compose -p devops-hw-network exec -T frontend nc -z -w 2 database 3306 >/dev/null 2>&1; then
  echo "FAIL: frontend unexpectedly reached the database directly." >&2
  exit 1
else
  echo "PASS: frontend cannot directly reach database:3306."
fi

echo
echo "PASS: expected connectivity and isolation were verified."
