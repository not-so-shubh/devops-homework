#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_BASE_DIR="${SYSTEM_INFO_BASE_DIR:-$SCRIPT_DIR}"
DEFAULT_OUTPUT_NAME="system-info-output"

CURRENT_DATE="$(date)"
HOST_NAME="$(hostname)"
CURRENT_USER="$(id -un)"

OUTPUT_DIR_NAME=""
IFS= read -r -p "Output directory name [$DEFAULT_OUTPUT_NAME]: " OUTPUT_DIR_NAME || true
OUTPUT_DIR_NAME="${OUTPUT_DIR_NAME:-$DEFAULT_OUTPUT_NAME}"

case "$OUTPUT_DIR_NAME" in
  .|..|*/*)
    printf 'ERROR: enter a directory name only (slashes, . and .. are not allowed).\n' >&2
    exit 2
    ;;
esac

OUTPUT_DIR="$OUTPUT_BASE_DIR/$OUTPUT_DIR_NAME"
PROCESS_FILE="$OUTPUT_DIR/running-processes.txt"

mkdir -p "$OUTPUT_DIR"
touch "$PROCESS_FILE"
ps aux > "$PROCESS_FILE"

echo "=== System Information ==="
echo "Current date : $CURRENT_DATE"
echo "Hostname     : $HOST_NAME"
echo "Current user : $CURRENT_USER"

echo
echo "=== Disk Usage ==="
df -h

echo
echo "=== Running Process Summary (PID and command) ==="
if ps -eo pid=,comm= >/dev/null 2>&1; then
  ps -eo pid=,comm= | sed -n '1,10p'
else
  # Portable fallback for systems whose ps does not support -eo.
  ps | sed -n '1,10p'
fi

echo
echo "Full process list saved to: $PROCESS_FILE"
echo "PASS: system information collected successfully."
