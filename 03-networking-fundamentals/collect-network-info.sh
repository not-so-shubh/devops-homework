#!/usr/bin/env bash
set -u

EXTERNAL_TESTS="${NETWORK_EXTERNAL:-0}"

section() {
  printf '\n===== %s =====\n' "$1"
}

run_if_available() {
  local command_name="$1"
  shift
  if command -v "$command_name" >/dev/null 2>&1; then
    "$@" 2>&1 || printf '[WARN] Command exited non-zero: %s\n' "$*"
  else
    printf '[SKIP] %s is not installed.\n' "$command_name"
  fi
}

echo "Network information collected at: $(date)"
echo "Values are machine-specific; review before sharing."

section "Hostname"
hostname
if hostname -I >/dev/null 2>&1; then
  hostname -I
else
  echo "[SKIP] hostname -I is not supported on this host."
fi

section "Interfaces and addresses"
if command -v ip >/dev/null 2>&1; then
  ip addr
  ip link
else
  run_if_available ifconfig ifconfig
fi

section "Routes"
if command -v ip >/dev/null 2>&1; then
  ip route
else
  run_if_available netstat netstat -rn
fi

section "Neighbor / ARP table"
if command -v ip >/dev/null 2>&1; then
  ip neigh
else
  run_if_available arp arp -an
fi

section "Listening sockets"
if command -v ss >/dev/null 2>&1; then
  # Omit process command lines to keep the saved report safer to share.
  ss -tuln
elif command -v lsof >/dev/null 2>&1; then
  # macOS fallback: restrict output to listening TCP sockets, with no remote peers.
  lsof -nP -iTCP -sTCP:LISTEN 2>&1 || echo "[WARN] lsof could not list listening sockets."
else
  # Legacy fallback: filter out established connections and remote endpoints.
  if command -v netstat >/dev/null 2>&1; then
    netstat -an 2>&1 | grep -E '^(Active|Proto)|LISTEN' || echo "[WARN] No listening TCP sockets were reported."
  else
    echo "[SKIP] Neither ss, lsof, nor netstat is installed."
  fi
fi

section "/etc/hosts"
if [[ -r /etc/hosts ]]; then
  cat /etc/hosts
else
  echo "[SKIP] /etc/hosts is not readable."
fi

section "/etc/resolv.conf"
if [[ -r /etc/resolv.conf ]]; then
  cat /etc/resolv.conf
else
  echo "[SKIP] /etc/resolv.conf is not readable."
fi

section "Optional external tests"
if [[ "$EXTERNAL_TESTS" == "1" ]]; then
  if command -v dig >/dev/null 2>&1; then
    dig +short example.com A
  elif command -v nslookup >/dev/null 2>&1; then
    nslookup example.com
  else
    echo "[SKIP] Neither dig nor nslookup is installed."
  fi
  run_if_available ping ping -c 2 1.1.1.1
  run_if_available curl curl -fsSI --max-time 10 https://example.com
  if command -v tracepath >/dev/null 2>&1; then
    tracepath -m 5 example.com
  elif command -v traceroute >/dev/null 2>&1; then
    traceroute -m 5 example.com
  else
    echo "[SKIP] Neither tracepath nor traceroute is installed."
  fi
else
  echo "[SKIP] Set NETWORK_EXTERNAL=1 to run public DNS, ping, curl, and trace tests."
fi

echo
echo "PASS: available local networking information was collected."
