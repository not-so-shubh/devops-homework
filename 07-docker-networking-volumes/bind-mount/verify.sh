#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INDEX_FILE="$SCRIPT_DIR/site/index.html"
PORT="${BIND_MOUNT_PORT:-8085}"
CONTAINER_NAME="devops-hw-bind-mount"
ORIGINAL_CONTENT="$(<"$INDEX_FILE")"
UPDATED_FILE=""

restore_original() {
  if [[ -n "$UPDATED_FILE" && -e "$UPDATED_FILE" ]]; then
    rm -f -- "$UPDATED_FILE"
  fi
  printf '%s\n' "$ORIGINAL_CONTENT" > "$INDEX_FILE"
}
trap restore_original EXIT

if ! docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "FAIL: $CONTAINER_NAME is not running; start it with ./run.sh." >&2
  exit 1
fi

echo "=== Before host edit ==="
BEFORE="$(curl -fsS "http://localhost:${PORT}/")"
printf '%s\n' "$BEFORE"
grep -Fq "Hello students" <<< "$BEFORE"

UPDATED_FILE="$(mktemp "$SCRIPT_DIR/site/.index.updated.XXXXXX")"
cat > "$UPDATED_FILE" <<'HTML'
<!doctype html>
<html lang="en">
  <head><meta charset="utf-8"><title>Bind Mount Updated</title></head>
  <body><h1>Hello students — updated through the host bind mount</h1></body>
</html>
HTML
chmod 0644 "$UPDATED_FILE"
mv -f -- "$UPDATED_FILE" "$INDEX_FILE"
UPDATED_FILE=""

echo
echo "=== After host edit; container was not restarted ==="
AFTER=""
for _ in $(seq 1 15); do
  if AFTER="$(curl -fsS --max-time 2 "http://localhost:${PORT}/" 2>/dev/null)" \
    && grep -Fq "updated through the host bind mount" <<< "$AFTER"; then
    break
  fi
  sleep 1
done
printf '%s\n' "$AFTER"
grep -Fq "updated through the host bind mount" <<< "$AFTER"

RUNNING="$(docker inspect --format '{{.State.Running}}' "$CONTAINER_NAME")"
test "$RUNNING" = "true"
echo
echo "PASS: host edit appeared through the read-only container mount without restart."
