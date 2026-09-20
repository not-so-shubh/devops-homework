#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

docker compose -p devops-hw-network down --volumes --remove-orphans
echo "Removed the networking lab's containers, three networks, and demo volume."
