#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="$ROOT_DIR/11-kubernetes-ingress-configmaps-secrets"
NAMESPACE="session12-evidence"
TROUBLE_NAMESPACE="ingress-lab"
TLS_DIR="$(mktemp -d "${TMPDIR:-/tmp}/session12-tls.XXXXXX")"

section() { printf '\n===== %s =====\n' "$1"; }
cleanup() {
  kubectl delete namespace "$NAMESPACE" "$TROUBLE_NAMESPACE" --ignore-not-found --wait=false >/dev/null 2>&1 || true
  rm -rf -- "$TLS_DIR"
}
trap cleanup EXIT

kubectl delete namespace "$NAMESPACE" "$TROUBLE_NAMESPACE" --ignore-not-found --wait=true >/dev/null 2>&1 || true
kubectl create namespace "$NAMESPACE"
kubectl create namespace "$TROUBLE_NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE" >/dev/null

section "CONFIGMAP CREATION AND INJECTION"
kubectl apply -f "$LAB_DIR/04-full-demo/configmap.yaml" -f "$LAB_DIR/04-full-demo/secret.yaml" -f "$LAB_DIR/04-full-demo/backend.yaml"
kubectl rollout status deployment/yatri-backend --timeout=180s
kubectl get configmap yatri-app-config
kubectl describe configmap yatri-app-config
kubectl exec deployment/yatri-backend -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|DEFAULT_CURRENCY'

section "CONFIGMAP LIVE UPDATE"
kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"staging"}}'
printf 'Existing process environment: '
kubectl exec deployment/yatri-backend -- printenv ENVIRONMENT
kubectl rollout restart deployment/yatri-backend
kubectl rollout status deployment/yatri-backend --timeout=180s
printf 'New process environment: '
kubectl exec deployment/yatri-backend -- printenv ENVIRONMENT
kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"production"}}'
kubectl rollout restart deployment/yatri-backend
kubectl rollout status deployment/yatri-backend --timeout=180s

section "SECRET AND BASE64"
kubectl get secret yatri-db-secret
kubectl describe secret yatri-db-secret
printf 'Decoded lab user: '
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_USER}' | base64 --decode; echo
printf 'Decoded lab password: '
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode; echo
printf 'With newline bytes: '; printf 'secretpassword\n' | xxd -p
printf 'Without newline bytes: '; printf 'secretpassword' | xxd -p
echo "Base64 is reversible encoding, not encryption; these values are lab-only."
kubectl get crds | grep -i secret || echo 'Standard native Kubernetes Secrets are in use.'

section "CONFIGMAP AND SECRET COMBINED"
kubectl exec deployment/yatri-backend -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|POSTGRES_USER|DEFAULT_CURRENCY' | sort
kubectl run backend-probe --image=curlimages/curl:8.17.0 --restart=Never -- curl -fsS --retry 10 --retry-connrefused http://yatri-backend:8080/
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/backend-probe --timeout=180s
kubectl logs backend-probe

section "INGRESS RESOURCE AND CONTROLLER"
kubectl api-resources | grep -i ingress
kubectl get pods,service -n ingress-nginx
kubectl wait --namespace ingress-nginx --for=condition=Ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
kubectl run ingress-client --image=curlimages/curl:8.17.0 --restart=Never -- sleep 3600
kubectl wait --for=condition=Ready pod/ingress-client --timeout=180s
echo "Minikube IP: $(kubectl get node minikube -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')"
echo "Host routing is tested without modifying /etc/hosts by sending explicit Host headers."

section "PATH ROUTING FULL DEMO"
kubectl apply -f "$LAB_DIR/04-full-demo/frontend.yaml" -f "$LAB_DIR/04-full-demo/ingress.yaml"
kubectl rollout status deployment/yatri-frontend --timeout=180s
kubectl get ingress yatri-ingress
kubectl describe ingress yatri-ingress | sed -n '1,55p'
CONTROLLER_URL='http://ingress-nginx-controller.ingress-nginx.svc.cluster.local'
sleep 5
kubectl exec ingress-client -- curl -fsS --retry 12 --retry-all-errors --retry-delay 1 -H 'Host: yatri.local' "$CONTROLLER_URL/" | grep -i '<title>'
kubectl exec ingress-client -- curl -fsS --retry 12 --retry-all-errors --retry-delay 1 -H 'Host: yatri.local' "$CONTROLLER_URL/api/"

section "HOST AND HYBRID ROUTING"
kubectl apply -f "$LAB_DIR/03-ingress/frontend.yaml" -f "$LAB_DIR/03-ingress/backend.yaml"
kubectl rollout status deployment/campus-frontend --timeout=180s
kubectl rollout status deployment/campus-backend --timeout=180s
kubectl apply -f "$LAB_DIR/03-ingress/host-ingress.yaml"
kubectl get ingress campus-host-ingress
sleep 5
kubectl exec ingress-client -- curl -fsS --retry 12 --retry-all-errors --retry-delay 1 -H 'Host: portal.campus.local' "$CONTROLLER_URL/" | grep -i '<title>'
kubectl exec ingress-client -- curl -fsS --retry 12 --retry-all-errors --retry-delay 1 -H 'Host: api.campus.local' "$CONTROLLER_URL/"
kubectl delete -f "$LAB_DIR/03-ingress/host-ingress.yaml" --wait=true
kubectl apply -f "$LAB_DIR/03-ingress/hybrid-ingress.yaml"
kubectl get ingress campus-hybrid-ingress
sleep 5
kubectl exec ingress-client -- curl -fsS --retry 12 --retry-all-errors --retry-delay 1 -H 'Host: portal.campus.local' "$CONTROLLER_URL/api"

section "TLS INGRESS"
openssl req -x509 -nodes -days 30 -newkey rsa:2048 -keyout "$TLS_DIR/tls.key" -out "$TLS_DIR/tls.crt" -subj '/CN=portal.campus.local/O=CampusDevOps' >/dev/null 2>&1
kubectl create secret tls campus-tls-cert --cert="$TLS_DIR/tls.crt" --key="$TLS_DIR/tls.key"
kubectl delete -f "$LAB_DIR/03-ingress/hybrid-ingress.yaml" --wait=true
kubectl apply -f "$LAB_DIR/03-ingress/ingress-tls.yaml"
kubectl get secret campus-tls-cert
kubectl get ingress campus-ingress-tls
sleep 5
kubectl exec ingress-client -- curl -ksSI --retry 12 --retry-connrefused -H 'Host: portal.campus.local' 'https://ingress-nginx-controller.ingress-nginx.svc.cluster.local/' | head -1

section "TROUBLESHOOTING BEFORE"
kubectl apply -f "$LAB_DIR/troubleshooting/broken.yaml"
sleep 8
kubectl get pods,service,ingress -n "$TROUBLE_NAMESPACE"
BROKEN_POD="$(kubectl get pod -n "$TROUBLE_NAMESPACE" -l app=session12-trouble -o jsonpath='{.items[0].metadata.name}')"
kubectl describe pod -n "$TROUBLE_NAMESPACE" "$BROKEN_POD" | sed -n '/Containers:/,/Conditions:/p'
kubectl get events -n "$TROUBLE_NAMESPACE" --sort-by=.lastTimestamp | tail -12

section "TROUBLESHOOTING AFTER"
kubectl apply -f "$LAB_DIR/troubleshooting/fixed.yaml"
kubectl rollout status deployment/session12-trouble -n "$TROUBLE_NAMESPACE" --timeout=180s
kubectl get pods,service,ingress -n "$TROUBLE_NAMESPACE"
kubectl exec -n "$TROUBLE_NAMESPACE" deployment/session12-trouble -- printenv APP_MODE
kubectl exec ingress-client -- curl -fsSI --retry 12 --retry-connrefused "http://session12-trouble.${TROUBLE_NAMESPACE}.svc.cluster.local/" | head -1

section "SESSION 12 RESULT"
kubectl get configmap,secret,ingress,deployment,service,pods -l app=yatri-app
echo "PASS: ConfigMap, Secret, path/host/hybrid/TLS Ingress and broken/fixed troubleshooting were exercised."

kubectl config set-context --current --namespace=default >/dev/null
cleanup
trap - EXIT
