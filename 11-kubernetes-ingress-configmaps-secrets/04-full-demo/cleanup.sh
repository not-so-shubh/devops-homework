#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete -f "$HERE/ingress.yaml" --ignore-not-found
kubectl delete -f "$HERE/frontend.yaml" --ignore-not-found
kubectl delete -f "$HERE/backend.yaml" --ignore-not-found
kubectl delete -f "$HERE/secret.yaml" --ignore-not-found
kubectl delete -f "$HERE/configmap.yaml" --ignore-not-found

echo 'Lab resources removed. Minikube and the ingress addon were left intact.'
