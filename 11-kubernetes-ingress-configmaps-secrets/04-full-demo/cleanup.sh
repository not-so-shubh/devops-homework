#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete -f "$HERE/ingress.yaml" --ignore-not-found
kubectl delete -f "$HERE/frontend.yaml" --ignore-not-found
kubectl delete -f "$HERE/backend.yaml" --ignore-not-found
kubectl delete -f "$HERE/secret.yaml" --ignore-not-found
kubectl delete -f "$HERE/configmap.yaml" --ignore-not-found

echo
echo 'Verification after cleanup:'
kubectl get ingress yatri-ingress >/dev/null 2>&1 && echo 'WARN: yatri-ingress still exists' || echo 'PASS: ingress deleted'
kubectl get deployment yatri-backend >/dev/null 2>&1 && echo 'WARN: yatri-backend still exists' || echo 'PASS: backend deployment deleted'
kubectl get deployment yatri-frontend >/dev/null 2>&1 && echo 'WARN: yatri-frontend still exists' || echo 'PASS: frontend deployment deleted'

echo 'Lab resources removed. Minikube and the ingress addon were left intact.'
