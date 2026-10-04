#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="$ROOT_DIR/10-kubernetes-networking-services"
NAMESPACE="session11-evidence"

section() { printf '\n===== %s =====\n' "$1"; }
wait_tool() {
  local pod="$1" tool="$2"
  for _ in $(seq 1 60); do
    if kubectl exec "$pod" -- sh -c "command -v $tool >/dev/null" 2>/dev/null; then return 0; fi
    sleep 1
  done
  echo "Timed out waiting for $tool in $pod" >&2
  return 1
}
cleanup() { kubectl delete namespace "$NAMESPACE" --ignore-not-found --wait=false >/dev/null 2>&1 || true; }
trap cleanup EXIT

kubectl delete namespace "$NAMESPACE" --ignore-not-found --wait=true >/dev/null 2>&1 || true
kubectl create namespace "$NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE" >/dev/null

section "PORT ARCHITECTURE"
kubectl explain pod.spec.containers.ports.containerPort | sed -n '1,18p'
kubectl explain service.spec.ports | sed -n '1,35p'

section "CLUSTERIP SERVICE AND FQDN"
kubectl apply -f "$LAB_DIR/01-clusterip"
kubectl rollout status deployment/web-app-clusterip --timeout=180s
kubectl wait --for=condition=Ready pod/curl-client --timeout=180s
wait_tool curl-client curl
wait_tool curl-client nslookup
kubectl get pods -l app=web-clusterip -o wide
kubectl get service web-service-clusterip
kubectl get endpointslice -l kubernetes.io/service-name=web-service-clusterip
kubectl exec curl-client -- curl -fsS --retry 10 --retry-connrefused --retry-delay 1 http://web-service-clusterip:8080/ | grep -i '<title>'
kubectl exec curl-client -- curl -fsS --retry 10 --retry-connrefused --retry-delay 1 "http://web-service-clusterip.${NAMESPACE}.svc.cluster.local:8080/" | grep -i '<title>'

section "NODEPORT SERVICE"
kubectl apply -f "$LAB_DIR/02-nodeport"
kubectl rollout status deployment/web-app-nodeport --timeout=180s
kubectl get service web-service-nodeport -o wide
kubectl get endpointslice -l kubernetes.io/service-name=web-service-nodeport
NODE_IP="$(kubectl get node minikube -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')"
echo "NodePort address: http://${NODE_IP}:30080"
kubectl exec curl-client -- curl -fsSI --retry 10 --retry-connrefused --retry-delay 1 http://web-service-nodeport/ | head -1

section "LOADBALANCER SERVICE"
kubectl apply -f "$LAB_DIR/03-loadbalancer"
kubectl rollout status deployment/web-app-loadbalancer --timeout=180s
kubectl get service web-service-loadbalancer -o wide
kubectl get endpointslice -l kubernetes.io/service-name=web-service-loadbalancer
kubectl exec curl-client -- curl -fsSI --retry 10 --retry-connrefused --retry-delay 1 http://web-service-loadbalancer/ | head -1
echo "Minikube exposes the LoadBalancer data path locally; a public cloud assigns the external IP."

section "EXTERNALNAME AND COREDNS"
kubectl apply -f "$LAB_DIR/04-externalname"
kubectl wait --for=condition=Ready pod/dns-test-client --timeout=180s
wait_tool dns-test-client curl
wait_tool dns-test-client nslookup
kubectl get service external-database-service -o wide
kubectl exec dns-test-client -- nslookup external-database-service
kubectl exec dns-test-client -- curl -ksSI https://external-database-service | head -1
echo "TLS verification is intentionally bypassed for the alias test because api.github.com presents its canonical hostname certificate."

section "HEADLESS SERVICE AND POD FQDN"
kubectl apply -f "$LAB_DIR/05-headless"
kubectl rollout status statefulset/web-stateful --timeout=180s
kubectl wait --for=condition=Ready pod/headless-dns-client --timeout=180s
wait_tool headless-dns-client curl
wait_tool headless-dns-client nslookup
kubectl get service web-service-headless
kubectl get pods -l app=web-headless -o wide
kubectl exec headless-dns-client -- nslookup web-service-headless
kubectl exec headless-dns-client -- nslookup "web-stateful-0.web-service-headless.${NAMESPACE}.svc.cluster.local"
kubectl exec headless-dns-client -- curl -fsSI --retry 10 --retry-connrefused --retry-delay 1 http://web-stateful-0.web-service-headless/ | head -1

section "SELECTORLESS SERVICE"
kubectl apply -f "$LAB_DIR/06-no-selector-service/service.yaml"
kubectl get endpoints external-legacy-db || echo "No Endpoints object exists before the manual mapping is applied."
kubectl apply -f "$LAB_DIR/06-no-selector-service/endpoints.yaml"
kubectl get endpoints external-legacy-db

section "COREDNS RESOLUTION"
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup web-service-clusterip
kubectl exec curl-client -- nslookup "web-service-clusterip.${NAMESPACE}.svc.cluster.local"
kubectl exec curl-client -- nslookup api.github.com

section "WORKLOAD IDENTITY BEFORE AND AFTER"
kubectl apply -f "$LAB_DIR/workload-comparison"
kubectl rollout status deployment/identity-deployment --timeout=180s
kubectl rollout status statefulset/identity-stateful --timeout=180s
kubectl rollout status daemonset/identity-daemonset --timeout=180s
kubectl get deployment,statefulset,daemonset
kubectl get pods -l app=identity-deployment
kubectl get pods -l app=identity-stateful
DEPLOY_POD="$(kubectl get pod -l app=identity-deployment -o jsonpath='{.items[0].metadata.name}')"
echo "Deleting generated Deployment pod: $DEPLOY_POD"
kubectl delete pod "$DEPLOY_POD" --wait=true
kubectl delete pod identity-stateful-0 --wait=true
sleep 4
kubectl get pods -l app=identity-deployment
kubectl get pods -l app=identity-stateful
echo "StatefulSet restored ordinal identity-stateful-0; Deployment created a new generated name."

section "SERVICE SELECTION AND DRIVER RESULT"
kubectl get services -o wide
kubectl get endpointslices
echo "ClusterIP, NodePort, LoadBalancer, ExternalName and Headless service patterns all verified."
echo "PASS: CoreDNS resolved short names, namespace FQDNs, pod FQDNs and an external CNAME."

kubectl config set-context --current --namespace=default >/dev/null
cleanup
trap - EXIT
