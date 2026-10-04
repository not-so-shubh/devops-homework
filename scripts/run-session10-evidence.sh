#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="$ROOT_DIR/09-kubernetes-pods-replicasets-deployments"
NAMESPACE="session10-evidence"

section() { printf '\n===== %s =====\n' "$1"; }
cleanup() { kubectl delete namespace "$NAMESPACE" --ignore-not-found --wait=false >/dev/null 2>&1 || true; }
trap cleanup EXIT

kubectl delete namespace "$NAMESPACE" --ignore-not-found --wait=true >/dev/null 2>&1 || true
kubectl create namespace "$NAMESPACE"
kubectl config set-context --current --namespace="$NAMESPACE" >/dev/null

section "CLUSTER HEALTH"
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -n kube-system -l k8s-app=kube-dns

section "POD OPERATIONS"
kubectl apply -f "$LAB_DIR/pod.yml"
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=120s
kubectl get pod nginx-pod -o wide
kubectl describe pod nginx-pod | sed -n '1,45p'
kubectl logs nginx-pod | head -5 || true
kubectl delete -f "$LAB_DIR/pod.yml" --wait=true

section "IMAGEPULLBACKOFF"
kubectl apply -f "$LAB_DIR/pod-lifecycle/06-imagepullbackoff.yaml"
sleep 8
kubectl get pod lifecycle-image-error
kubectl describe pod lifecycle-image-error | sed -n '/Events:/,$p'
kubectl delete -f "$LAB_DIR/pod-lifecycle/06-imagepullbackoff.yaml" --wait=true

section "POD LIFECYCLE AND PROBES"
kubectl apply -f "$LAB_DIR/hello.yml"
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/hello-pod --timeout=120s
kubectl get pod hello-pod
kubectl logs hello-pod
kubectl apply -f "$LAB_DIR/pod-lifecycle/02-pending.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/03-succeeded.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/04-failed.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/05-crashloopbackoff.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/07-readiness.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/08-liveness.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/09-startup.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/10-init-container.yaml"
kubectl apply -f "$LAB_DIR/pod-lifecycle/11-multi-container.yaml"
sleep 18
kubectl get pods -o wide
kubectl describe pod lifecycle-pending | sed -n '/Events:/,$p'
kubectl logs lifecycle-crashloop --previous || true
kubectl logs lifecycle-multi-container -c sidecar | tail -5

section "REPLICASET STATEFULSET DAEMONSET"
kubectl apply -f "$LAB_DIR/replicaset.yml"
kubectl wait --for=condition=Ready pod -l app=nginx-rs --timeout=180s
OLD_POD="$(kubectl get pod -l app=nginx-rs -o jsonpath='{.items[0].metadata.name}')"
kubectl delete pod "$OLD_POD" --wait=true
sleep 3
kubectl get rs,pods -l app=nginx-rs -o wide
kubectl apply -f "$LAB_DIR/statefulset.yml"
kubectl rollout status statefulset/mysql --timeout=240s
kubectl get statefulset,pods,pvc -l app=mysql -o wide
kubectl apply -f "$LAB_DIR/daemonset.yml"
kubectl rollout status daemonset/node-exporter --timeout=180s
kubectl get daemonset,pods -l app=node-exporter -o wide

section "ROLLING UPDATE AND ROLLBACK"
kubectl apply -f "$LAB_DIR/01-rolling-update/deployment-v1.yaml" -f "$LAB_DIR/01-rolling-update/service.yaml"
kubectl rollout status deployment/app-rolling --timeout=180s
kubectl apply -f "$LAB_DIR/01-rolling-update/deployment-v2.yaml"
kubectl rollout status deployment/app-rolling --timeout=180s
kubectl get pods -l app=app-rolling --show-labels
kubectl rollout history deployment/app-rolling
kubectl rollout undo deployment/app-rolling
kubectl rollout status deployment/app-rolling --timeout=180s
kubectl rollout history deployment/app-rolling

section "TROUBLESHOOTING DRILLS"
kubectl apply -f "$LAB_DIR/troubleshooting/healthy-deployment.yaml"
kubectl rollout status deployment/yatri-backend --timeout=180s
kubectl apply -f "$LAB_DIR/troubleshooting/broken-image.yaml"
sleep 8
kubectl get pods -l app=yatri-backend
kubectl describe deployment yatri-backend | sed -n '/Conditions:/,/Events:/p'
kubectl rollout undo deployment/yatri-backend
kubectl rollout status deployment/yatri-backend --timeout=180s
kubectl apply -f "$LAB_DIR/troubleshooting/selector-mismatch.yaml" || true
kubectl apply -f "$LAB_DIR/troubleshooting/selector-match-fixed.yaml"
kubectl rollout status deployment/selector-error-demo --timeout=180s
kubectl get deployment selector-error-demo

section "BLUE GREEN CUTOVER"
kubectl apply -f "$LAB_DIR/02-blue-green/deployment-blue.yaml" -f "$LAB_DIR/02-blue-green/deployment-green.yaml"
kubectl rollout status deployment/app-blue --timeout=180s
kubectl rollout status deployment/app-green --timeout=180s
kubectl apply -f "$LAB_DIR/02-blue-green/service-blue.yaml"
kubectl get endpoints myapp-service
kubectl run blue-probe --image=busybox:1.36 --restart=Never -- sh -c 'wget -qO- http://myapp-service'
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/blue-probe --timeout=120s
printf 'Blue response: '; kubectl logs blue-probe
kubectl apply -f "$LAB_DIR/02-blue-green/service-green.yaml"
kubectl get endpoints myapp-service
kubectl run green-probe --image=busybox:1.36 --restart=Never -- sh -c 'wget -qO- http://myapp-service'
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/green-probe --timeout=120s
printf 'Green response: '; kubectl logs green-probe

section "CANARY TRAFFIC"
kubectl apply -f "$LAB_DIR/03-canary/deployment-stable.yaml" -f "$LAB_DIR/03-canary/deployment-canary.yaml" -f "$LAB_DIR/03-canary/service.yaml"
kubectl rollout status deployment/app-stable --timeout=240s
kubectl rollout status deployment/app-canary --timeout=180s
kubectl get pods -l app=myapp-canary --show-labels
kubectl get endpoints myapp-canary-service
kubectl run canary-probe --image=busybox:1.36 --restart=Never -- sh -c 'for i in $(seq 1 30); do wget -qO- http://myapp-canary-service; done'
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/canary-probe --timeout=180s
kubectl logs canary-probe | sort | uniq -c

section "RECREATE DOWNTIME"
kubectl apply -f "$LAB_DIR/04-recreate/deployment-v1.yaml" -f "$LAB_DIR/04-recreate/service.yaml"
kubectl rollout status deployment/app-recreate --timeout=180s
kubectl run recreate-observer --image=busybox:1.36 --restart=Never -- sh -c 'for i in $(seq 1 24); do wget -qO- -T 1 http://app-recreate 2>/dev/null || echo OUTAGE; sleep 1; done'
sleep 2
kubectl apply -f "$LAB_DIR/04-recreate/deployment-v2.yaml"
kubectl rollout status deployment/app-recreate --timeout=180s
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/recreate-observer --timeout=180s
kubectl logs recreate-observer | sort | uniq -c
kubectl rollout history deployment/app-recreate

section "SESSION 10 RESULT"
echo "PASS: Pods, lifecycle states, probes, controllers, four deployment strategies and troubleshooting were exercised."

kubectl config set-context --current --namespace=default >/dev/null
cleanup
trap - EXIT
