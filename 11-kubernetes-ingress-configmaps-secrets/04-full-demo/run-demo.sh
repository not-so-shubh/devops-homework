#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
command -v minikube >/dev/null || { echo 'minikube is required' >&2; exit 1; }

if ! minikube status >/dev/null 2>&1; then
  echo 'Minikube is not running. Start it with: minikube start' >&2
  exit 1
fi

minikube addons enable ingress >/dev/null
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

kubectl apply -f "$HERE/configmap.yaml"
kubectl apply -f "$HERE/secret.yaml"
kubectl apply -f "$HERE/backend.yaml"
kubectl apply -f "$HERE/frontend.yaml"
kubectl apply -f "$HERE/ingress.yaml"

kubectl rollout status deployment/yatri-backend --timeout=180s
kubectl rollout status deployment/yatri-frontend --timeout=180s

echo
kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app

echo
echo 'Demo deployed.'
echo 'Map yatri.local to the Minikube/Ingress IP as documented in ../README.md before browser/curl testing.'
