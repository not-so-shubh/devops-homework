#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="$ROOT_DIR/evidence/command-outputs"
TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/devops-homework-verify.XXXXXX")"
PASS_COUNT=0
FAIL_COUNT=0
BLOCKED_COUNT=0

mkdir -p "$EVIDENCE_DIR"

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

blocked() {
  BLOCKED_COUNT=$((BLOCKED_COUNT + 1))
  printf 'BLOCKED/SKIP: %s\n' "$1"
}

cleanup_on_exit() {
  "$ROOT_DIR/scripts/cleanup.sh" >/dev/null 2>&1 || true
  rm -rf -- "$TEST_TMP"
}
trap cleanup_on_exit EXIT

wait_for_text() {
  local url="$1"
  local expected="$2"
  local output_file="$3"
  local response=""
  local attempt
  for attempt in $(seq 1 30); do
    if response="$(curl -fsS --max-time 3 "$url" 2>/dev/null)" && grep -Fq "$expected" <<< "$response"; then
      {
        printf 'URL: %s\n' "$url"
        printf 'Expected: %s\n' "$expected"
        printf 'Response: %s\n\n' "$response"
      } >> "$output_file"
      return 0
    fi
    sleep 1
  done
  printf 'URL did not return expected text: %s (%s)\n' "$url" "$expected" >> "$output_file"
  return 1
}

find_free_port() {
  local port="$1"
  while [[ "$port" -le 65535 ]]; do
    if command -v lsof >/dev/null 2>&1; then
      if ! lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
        printf '%s\n' "$port"
        return 0
      fi
    elif command -v nc >/dev/null 2>&1; then
      if ! nc -z 127.0.0.1 "$port" >/dev/null 2>&1; then
        printf '%s\n' "$port"
        return 0
      fi
    else
      # Docker will still report a clear bind error if this conservative fallback collides.
      printf '%s\n' "$port"
      return 0
    fi
    port=$((port + 1))
  done
  return 1
}

normalize_evidence() {
  local evidence_file
  local normalized_file
  for evidence_file in "$EVIDENCE_DIR"/*.txt; do
    [[ -f "$evidence_file" ]] || continue
    normalized_file="${evidence_file}.normalized.$$"
    # Keep real command content while removing renderer-added trailing spaces
    # and redundant blank lines at EOF so Git whitespace checks stay clean.
    awk '
      { sub(/[[:space:]]+$/, ""); lines[NR] = $0 }
      END {
        last = NR
        while (last > 0 && lines[last] == "") last--
        for (line = 1; line <= last; line++) print lines[line]
      }
    ' "$evidence_file" > "$normalized_file"
    mv -f -- "$normalized_file" "$evidence_file"
  done
}

echo "=== Required repository structure ==="
REQUIRED_PATHS=(
  README.md AUDIT.md .gitignore
  linux-fundamentals/README.md linux-fundamentals/link-practice.sh
  linux-fundamentals/user-practice.md linux-fundamentals/journalctl-practice.md
  linux-fundamentals/linux-command-cheatsheet.md
  shell-scripting/README.md shell-scripting/system-info.sh
  networking/README.md networking/networking-commands.md networking/collect-network-info.sh
  git-github/README.md git-github/commit-a-vs-commit-m.md git-github/cherry-pick.md
  git-github/git-practice-demo.sh docker-fundamentals/docker-compose.yml
  docker-multistage/multistage-app/Dockerfile docker-multistage/submission.md
  docker-network/container-networking/docker-compose.yml
  docker-network/host-network/README.md docker-network/host-network/verify.sh
  docker-network/bind-mount/site/index.html
  docker-network/overlay-network.md evidence/README.md evidence/screenshots/README.md
  scripts/cleanup.sh scripts/verify-all.sh
)
MISSING=0
for path in "${REQUIRED_PATHS[@]}"; do
  if [[ ! -e "$ROOT_DIR/$path" ]]; then
    printf 'Missing: %s\n' "$path" >&2
    MISSING=1
  fi
done
if [[ "$MISSING" -eq 0 ]]; then pass "required repository files exist"; else fail "required repository files are missing"; fi

echo
echo "=== Bash syntax ==="
SYNTAX_FAILED=0
while IFS= read -r -d '' script; do
  if ! bash -n "$script"; then
    SYNTAX_FAILED=1
  fi
done < <(find "$ROOT_DIR" -path "$ROOT_DIR/.git" -prune -o -type f -name '*.sh' -print0)
if [[ "$SYNTAX_FAILED" -eq 0 ]]; then pass "all shell scripts pass bash -n"; else fail "one or more shell scripts have syntax errors"; fi

echo
echo "=== Linux link demonstration ==="
if "$ROOT_DIR/linux-fundamentals/link-practice.sh" > "$EVIDENCE_DIR/linux-link-demo.txt" 2>&1; then
  pass "symbolic/hard link behavior"
else
  fail "link-practice.sh (see evidence output)"
fi

echo
echo "=== System information script ==="
if printf 'automated-output\n' | SYSTEM_INFO_BASE_DIR="$TEST_TMP" "$ROOT_DIR/shell-scripting/system-info.sh" > "$EVIDENCE_DIR/shell-script-output.txt" 2>&1 \
  && [[ -s "$TEST_TMP/automated-output/running-processes.txt" ]]; then
  pass "system-info.sh piped-input run and process redirection"
else
  fail "system-info.sh or its process report"
fi

echo
echo "=== Networking collector ==="
if NETWORK_EXTERNAL=0 "$ROOT_DIR/networking/collect-network-info.sh" > "$EVIDENCE_DIR/network-info.txt" 2>&1; then
  pass "available networking information collected"
else
  fail "network information collector"
fi

echo
echo "=== Disposable Git demonstration ==="
if "$ROOT_DIR/git-github/git-practice-demo.sh" > "$EVIDENCE_DIR/git-practice-output.txt" 2>&1; then
  pass "commit -a limitation and cherry-pick workflow"
else
  fail "Git practice demonstration (see evidence output)"
fi

echo
echo "=== Static expected-message checks ==="
STATIC_MESSAGES=(
  "docker-fundamentals/nodejs-app:Hello World from Node.js"
  "docker-fundamentals/python-app:Hello World from Python"
  "docker-fundamentals/java-app:Hello World from Java"
  "docker-fundamentals/Apache-app:Hello World from Apache"
  "docker-fundamentals/React-app:Hello World from React"
  "docker-fundamentals/nginx-app:Hello World from Nginx"
  "docker-multistage/multistage-app:Hello World from Docker multi-stage build"
)
STATIC_FAILED=0
for item in "${STATIC_MESSAGES[@]}"; do
  directory="${item%%:*}"
  message="${item#*:}"
  if ! grep -R -Fq --exclude='README.md' "$message" "$ROOT_DIR/$directory"; then
    printf 'Missing message in %s: %s\n' "$directory" "$message" >&2
    STATIC_FAILED=1
  fi
done
if [[ "$STATIC_FAILED" -eq 0 ]]; then pass "all seven exact response phrases exist in application source"; else fail "one or more application response phrases are missing"; fi

DOCKER_AVAILABLE=1
if ! command -v docker >/dev/null 2>&1; then
  printf 'BLOCKED: Docker CLI is not installed.\n' > "$EVIDENCE_DIR/docker-environment.txt"
  DOCKER_AVAILABLE=0
elif ! docker info > "$EVIDENCE_DIR/docker-environment.txt" 2>&1; then
  printf '\nBLOCKED: Docker CLI exists but its daemon is unavailable.\n' >> "$EVIDENCE_DIR/docker-environment.txt"
  DOCKER_AVAILABLE=0
else
  {
    echo
    docker version
    echo
    docker compose version
  } >> "$EVIDENCE_DIR/docker-environment.txt" 2>&1
fi

if [[ "$DOCKER_AVAILABLE" -eq 0 ]]; then
  echo
  blocked "Docker Fundamentals: six image builds and curl checks"
  blocked "Docker multi-stage build/run/curl/docker ps"
  blocked "Docker three-network connectivity and isolation"
  blocked "Docker bind-mount before/after test"
else
  pass "Docker daemon and Compose v2 are available"

  echo
  echo "=== Docker Fundamentals ==="
  export HOST_BIND_ADDRESS=127.0.0.1
  export NODE_HOST_PORT="$(find_free_port 23000)"
  export PYTHON_HOST_PORT="$(find_free_port 23100)"
  export JAVA_HOST_PORT="$(find_free_port 23200)"
  export APACHE_HOST_PORT="$(find_free_port 23300)"
  export REACT_HOST_PORT="$(find_free_port 23400)"
  export NGINX_HOST_PORT="$(find_free_port 23500)"
  : > "$EVIDENCE_DIR/docker-fundamentals-curl.txt"
  if (
    cd "$ROOT_DIR/docker-fundamentals" || exit 1
    docker compose -p devops-hw-fundamentals up --build -d
  ) > "$EVIDENCE_DIR/docker-fundamentals-build.txt" 2>&1; then
    FUNDAMENTALS_OK=1
    wait_for_text "http://127.0.0.1:$NODE_HOST_PORT/" "Hello World from Node.js" "$EVIDENCE_DIR/docker-fundamentals-curl.txt" || FUNDAMENTALS_OK=0
    wait_for_text "http://127.0.0.1:$PYTHON_HOST_PORT/" "Hello World from Python" "$EVIDENCE_DIR/docker-fundamentals-curl.txt" || FUNDAMENTALS_OK=0
    wait_for_text "http://127.0.0.1:$JAVA_HOST_PORT/" "Hello World from Java" "$EVIDENCE_DIR/docker-fundamentals-curl.txt" || FUNDAMENTALS_OK=0
    wait_for_text "http://127.0.0.1:$APACHE_HOST_PORT/" "Hello World from Apache" "$EVIDENCE_DIR/docker-fundamentals-curl.txt" || FUNDAMENTALS_OK=0
    wait_for_text "http://127.0.0.1:$REACT_HOST_PORT/" "Hello World from React" "$EVIDENCE_DIR/docker-fundamentals-curl.txt" || FUNDAMENTALS_OK=0
    wait_for_text "http://127.0.0.1:$NGINX_HOST_PORT/" "Hello World from Nginx" "$EVIDENCE_DIR/docker-fundamentals-curl.txt" || FUNDAMENTALS_OK=0
    (
      cd "$ROOT_DIR/docker-fundamentals" || exit 1
      echo "=== docker compose ps ==="
      docker compose -p devops-hw-fundamentals ps
    ) >> "$EVIDENCE_DIR/docker-fundamentals-curl.txt" 2>&1
    if [[ "$FUNDAMENTALS_OK" -eq 1 ]]; then pass "all six Docker applications returned expected text"; else fail "one or more Docker application curl assertions"; fi
  else
    fail "Docker Fundamentals Compose build/start (see build evidence)"
  fi
  (
    cd "$ROOT_DIR/docker-fundamentals" || exit 1
    docker compose -p devops-hw-fundamentals down --remove-orphans
  ) >/dev/null 2>&1 || true

  echo
  echo "=== Docker Multi-Stage ==="
  MULTI_PORT="$(find_free_port 8080)"
  if docker build -t devops-multistage-app:local "$ROOT_DIR/docker-multistage/multistage-app" > "$EVIDENCE_DIR/docker-multistage-build.txt" 2>&1 \
    && docker run -d --name devops-multistage -p "127.0.0.1:${MULTI_PORT}:8080" devops-multistage-app:local > "$EVIDENCE_DIR/docker-multistage-output.txt" 2>&1; then
    if wait_for_text "http://127.0.0.1:$MULTI_PORT/" "Hello World from Docker multi-stage build" "$EVIDENCE_DIR/docker-multistage-output.txt"; then
      docker ps --filter name=devops-multistage --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' >> "$EVIDENCE_DIR/docker-multistage-output.txt" 2>&1
      if [[ "$MULTI_PORT" == "8080" ]]; then
        pass "multi-stage image returned exact text on host port 8080"
      else
        pass "multi-stage image returned exact text (port 8080 was occupied; used $MULTI_PORT)"
      fi
    else
      fail "multi-stage application curl assertion"
    fi
  else
    fail "multi-stage build or container start (see evidence)"
  fi
  docker rm -f devops-multistage >/dev/null 2>&1 || true

  echo
  echo "=== Docker Network Segmentation ==="
  export FRONTEND_HOST_PORT="$(find_free_port 23600)"
  if "$ROOT_DIR/docker-network/container-networking/start.sh" > "$EVIDENCE_DIR/docker-network-output.txt" 2>&1 \
    && "$ROOT_DIR/docker-network/container-networking/verify.sh" >> "$EVIDENCE_DIR/docker-network-output.txt" 2>&1; then
    pass "three Docker networks, connectivity, and isolation"
  else
    fail "Docker network lab (see evidence output)"
  fi
  "$ROOT_DIR/docker-network/container-networking/stop.sh" >> "$EVIDENCE_DIR/docker-network-output.txt" 2>&1 || true

  echo
  echo "=== Docker Bind Mount ==="
  export BIND_MOUNT_PORT="$(find_free_port 23700)"
  if "$ROOT_DIR/docker-network/bind-mount/run.sh" > "$EVIDENCE_DIR/bind-mount-output.txt" 2>&1 \
    && "$ROOT_DIR/docker-network/bind-mount/verify.sh" >> "$EVIDENCE_DIR/bind-mount-output.txt" 2>&1; then
    pass "bind mount changed live content without restart and restored source"
  else
    fail "bind-mount lab (see evidence output)"
  fi
  docker rm -f devops-hw-bind-mount >> "$EVIDENCE_DIR/bind-mount-output.txt" 2>&1 || true
fi

SUMMARY_FILE="$EVIDENCE_DIR/verification-summary.txt"
{
  echo "DevOps Homework verification summary"
  echo "Generated: $(date)"
  echo "PASS: $PASS_COUNT"
  echo "FAIL: $FAIL_COUNT"
  echo "BLOCKED/SKIP: $BLOCKED_COUNT"
} | tee "$SUMMARY_FILE"

normalize_evidence

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi

exit 0
