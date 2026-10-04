#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HELM_BIN="${HELM_BIN:-helm}"
CHART="$ROOT_DIR/14-helm/devops-web"
NAMESPACE="session15-evidence"
RELEASE="devops-web-evidence"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/helm-evidence.XXXXXX")"
export XDG_CONFIG_HOME="$SCRATCH/xdg-config"
export XDG_CACHE_HOME="$SCRATCH/xdg-cache"
export XDG_DATA_HOME="$SCRATCH/xdg-data"

section() { printf '\n===== %s =====\n' "$1"; }
cleanup() {
  "$HELM_BIN" uninstall "$RELEASE" -n "$NAMESPACE" >/dev/null 2>&1 || true
  kubectl delete namespace "$NAMESPACE" --ignore-not-found --wait=false >/dev/null 2>&1 || true
  rm -rf -- "$SCRATCH"
}
trap cleanup EXIT

section "HELM CREATE LINT TEMPLATE"
"$HELM_BIN" version --short
"$HELM_BIN" create "$SCRATCH/scratch-chart"
"$HELM_BIN" lint "$SCRATCH/scratch-chart"
"$HELM_BIN" lint "$CHART"
"$HELM_BIN" template "$RELEASE" "$CHART" --namespace "$NAMESPACE" >/dev/null
echo "PASS: helm create, lint and template"

section "HELM REPOSITORY AND SEARCH"
if ! "$HELM_BIN" repo list 2>/dev/null | grep -q '^bitnami'; then
  "$HELM_BIN" repo add bitnami https://charts.bitnami.com/bitnami
fi
"$HELM_BIN" repo update
"$HELM_BIN" repo list
"$HELM_BIN" search repo bitnami/nginx | head -8

section "HELM INSTALL STATUS GET TEST"
"$HELM_BIN" install "$RELEASE" "$CHART" -n "$NAMESPACE" --create-namespace --wait --timeout 5m
"$HELM_BIN" list -n "$NAMESPACE"
"$HELM_BIN" status "$RELEASE" -n "$NAMESPACE"
"$HELM_BIN" get values "$RELEASE" -n "$NAMESPACE"
"$HELM_BIN" get manifest "$RELEASE" -n "$NAMESPACE" | sed -n '1,35p'
"$HELM_BIN" test "$RELEASE" -n "$NAMESPACE" --logs --timeout 3m

section "HELM UPGRADE AND ROLLBACK"
"$HELM_BIN" upgrade "$RELEASE" "$CHART" -n "$NAMESPACE" --set page.message='Evidence revision two' --wait --timeout 5m
"$HELM_BIN" upgrade "$RELEASE" "$CHART" -n "$NAMESPACE" --set page.message='Evidence revision three' --set replicaCount=3 --wait --timeout 5m
"$HELM_BIN" history "$RELEASE" -n "$NAMESPACE"
"$HELM_BIN" rollback "$RELEASE" 1 -n "$NAMESPACE" --wait --timeout 5m
"$HELM_BIN" history "$RELEASE" -n "$NAMESPACE"
kubectl get deployment,pods,service -n "$NAMESPACE" -o wide
"$HELM_BIN" test "$RELEASE" -n "$NAMESPACE" --logs --timeout 3m

section "HELM UNINSTALL"
"$HELM_BIN" uninstall "$RELEASE" -n "$NAMESPACE" --wait
"$HELM_BIN" list -n "$NAMESPACE"
echo "PASS: install, list, status, get, test, upgrade, history, rollback and uninstall"

kubectl delete namespace "$NAMESPACE" --ignore-not-found --wait=false >/dev/null
rm -rf -- "$SCRATCH"
trap - EXIT
