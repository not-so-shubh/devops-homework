# 09 — Kubernetes Pods, ReplicaSets & Deployments

**Student:** Shubh Jaiswal  
**Enrollment:** 24BCS10601  
**Lecture mapping:** Lecture 10

This section implements all 13 Lecture 10 tasks: baseline cluster verification, Pod lifecycle/error states, health probes, ReplicaSet, StatefulSet, DaemonSet, rolling updates, troubleshooting, and Blue-Green/Canary/Recreate deployment strategies.

> All commands below are intended to be run from `09-kubernetes-pods-replicasets-deployments/` unless a subdirectory is explicitly entered. Screenshots must be captured from the real Minikube cluster.

---

## Task 1 — Cluster Health Verification & Baseline Environment Checks

```bash
minikube start
kubectl version --output=yaml
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

**Success:** control plane/CoreDNS respond and every local node used by the lab is `Ready`.

**Screenshot:** `screenshots/01-cluster-health.png`

---

## Task 2 — Standard Pod Deployment, Inspection & Teardown

`pod.yml` contains the four required top-level Kubernetes fields: `apiVersion`, `kind`, `metadata`, and `spec`.

```bash
kubectl apply -f pod.yml
kubectl get pods
kubectl get pods -o wide
kubectl describe pod nginx-pod
kubectl logs nginx-pod
kubectl delete -f pod.yml
kubectl get pods
```

**Screenshot:** `screenshots/02-nginx-pod-operations.png`

---

## Task 3 — `ErrImagePull` / `ImagePullBackOff`

```bash
kubectl apply -f pod-lifecycle/06-imagepullbackoff.yaml
kubectl get pod lifecycle-image-error -w
kubectl describe pod lifecycle-image-error
kubectl delete -f pod-lifecycle/06-imagepullbackoff.yaml
```

The API object can be accepted and stored even though kubelet later fails to pull the referenced image. Repeated pull attempts back off, producing `ErrImagePull` and then `ImagePullBackOff`.

**Screenshot:** `screenshots/03-imagepullbackoff-error.png`

---

## Task 4 — Transient Pod Lifecycle Stages (`hello.yml`)

Terminal 1:

```bash
kubectl get pods -w
```

Terminal 2:

```bash
kubectl apply -f hello.yml
kubectl get pod hello-pod
kubectl logs hello-pod
kubectl delete -f hello.yml
```

Capture the short-lived workload moving through `ContainerCreating` → `Running` → `Completed` (`Succeeded`). The transition can be fast, so start the watch before applying the manifest.

**Screenshot:** `screenshots/04-pod-lifecycle-stages.png`

---

## Task 5 — Exhaustive Pod Lifecycle States & Probes

The `pod-lifecycle/` directory contains all 12 required manifests.

| # | Manifest | Demonstration |
|---:|---|---|
| 1 | `01-running.yaml` | Long-running healthy Pod |
| 2 | `02-pending.yaml` | Unschedulable/Pending due to impossible resource pressure |
| 3 | `03-succeeded.yaml` | Exit code 0 with `restartPolicy: Never` |
| 4 | `04-failed.yaml` | Exit code 1 with `restartPolicy: Never` |
| 5 | `05-crashloopbackoff.yaml` | Repeated crash + exponential restart backoff |
| 6 | `06-imagepullbackoff.yaml` | Invalid image pull |
| 7 | `07-readiness.yaml` | Container can be Running before it becomes Ready |
| 8 | `08-liveness.yaml` | Failed liveness check forces a restart |
| 9 | `09-startup.yaml` | Startup probe protects a slow-starting application |
| 10 | `10-init-container.yaml` | Init container completes before app containers start |
| 11 | `11-multi-container.yaml` | App + sidecar in one Pod |
| 12 | `12-termination.yaml` | SIGTERM/graceful shutdown handling |

Representative verification:

```bash
# Pending
kubectl apply -f pod-lifecycle/02-pending.yaml
kubectl describe pod lifecycle-pending
kubectl delete -f pod-lifecycle/02-pending.yaml

# CrashLoopBackOff
kubectl apply -f pod-lifecycle/05-crashloopbackoff.yaml
kubectl get pod lifecycle-crashloop -w
kubectl logs lifecycle-crashloop --previous
kubectl delete -f pod-lifecycle/05-crashloopbackoff.yaml

# Readiness: watch READY transition independently of STATUS=Running
kubectl apply -f pod-lifecycle/07-readiness.yaml
kubectl get pod lifecycle-readiness -w
kubectl delete -f pod-lifecycle/07-readiness.yaml

# Liveness restart
kubectl apply -f pod-lifecycle/08-liveness.yaml
kubectl get pod lifecycle-liveness -w
kubectl delete -f pod-lifecycle/08-liveness.yaml

# Startup probe
kubectl apply -f pod-lifecycle/09-startup.yaml
kubectl describe pod lifecycle-startup
kubectl delete -f pod-lifecycle/09-startup.yaml

# Init container
kubectl apply -f pod-lifecycle/10-init-container.yaml
kubectl describe pod lifecycle-init
kubectl delete -f pod-lifecycle/10-init-container.yaml

# Multi-container / sidecar
kubectl apply -f pod-lifecycle/11-multi-container.yaml
kubectl get pod lifecycle-multi-container
kubectl logs lifecycle-multi-container -c sidecar
kubectl delete -f pod-lifecycle/11-multi-container.yaml

# Graceful termination
kubectl apply -f pod-lifecycle/12-termination.yaml
kubectl delete -f pod-lifecycle/12-termination.yaml
```

**Screenshots:**
- `screenshots/05-lifecycle-probes-crashloop.png`
- `screenshots/05-lifecycle-init-multicontainer.png`

---

## Task 6 — ReplicaSet & StatefulSet

### ReplicaSet self-healing

```bash
kubectl apply -f replicaset.yml
kubectl get rs nginx-rs
kubectl get pods -l app=nginx
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod "$POD_NAME"
kubectl get pods -l app=nginx -w
kubectl delete -f replicaset.yml
```

The desired count is maintained even after one matching Pod is manually deleted.

### StatefulSet identity + PVCs

```bash
kubectl apply -f statefulset.yml
kubectl rollout status statefulset/mysql --timeout=180s
kubectl get statefulset mysql
kubectl get pods -l app=mysql
kubectl get pvc
kubectl delete -f statefulset.yml
```

Observe ordered names such as `mysql-0`, `mysql-1` and the per-Pod PVCs generated by `volumeClaimTemplates`.

**Screenshot:** `screenshots/06-controllers-rs-statefulset.png`

---

## Task 7 — DaemonSet Architecture & Host Agent Deployment

```bash
kubectl apply -f daemonset.yml
kubectl get ds node-exporter
kubectl get pods -l app=node-exporter -o wide
kubectl get nodes
kubectl delete -f daemonset.yml
```

A DaemonSet schedules one matching agent Pod on each eligible node rather than maintaining an arbitrary replica count.

**Screenshot:** `screenshots/07-daemonset-verification.png`

---

## Task 8 — Rolling Update & Rollback

```bash
cd 01-rolling-update
kubectl apply -f deployment-v1.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/app-rolling

kubectl apply -f deployment-v2.yaml
kubectl rollout status deployment/app-rolling
kubectl get pods -l app=app-rolling --show-labels
kubectl rollout history deployment/app-rolling

kubectl rollout undo deployment/app-rolling
kubectl rollout status deployment/app-rolling
kubectl rollout history deployment/app-rolling

kubectl delete -f service.yaml -f deployment-v1.yaml
cd ..
```

The manifests use `maxSurge: 1` and `maxUnavailable: 0`, so a three-replica rollout may temporarily create a fourth Pod while keeping all three desired replicas available.

**Screenshot:** `screenshots/08-rolling-update-and-rollback.png`

---

## Task 9 — Real-World Troubleshooting Drills

### Drill A: broken image during an existing healthy Deployment

A healthy baseline is created first so `rollout undo` has a real previous revision.

```bash
kubectl apply -f troubleshooting/healthy-deployment.yaml
kubectl rollout status deployment/yatri-backend

kubectl apply -f troubleshooting/broken-image.yaml
kubectl rollout status deployment/yatri-backend --timeout=30s || true
kubectl get pods -l app=yatri-backend
kubectl describe deployment yatri-backend

kubectl rollout undo deployment/yatri-backend
kubectl rollout status deployment/yatri-backend
kubectl delete -f troubleshooting/healthy-deployment.yaml
```

With `maxUnavailable: 0`, the broken replacement cannot become Ready while the previous healthy replicas remain available.

### Drill B: selector mismatch API rejection and correction

```bash
kubectl apply -f troubleshooting/selector-mismatch.yaml || true
kubectl apply -f troubleshooting/selector-match-fixed.yaml
kubectl get deployment selector-error-demo
kubectl delete -f troubleshooting/selector-match-fixed.yaml
```

The invalid manifest deliberately has `spec.selector.matchLabels` that do not match `spec.template.metadata.labels`; the API server rejects it before workload creation.

**Screenshot:** `screenshots/09-troubleshooting-drills.png`

---

## Task 10 — Core Concepts

### `containerPort` vs `targetPort` vs `port` vs `nodePort`

| Field | Scope |
|---|---|
| `containerPort` | Documents the application port used inside a container/Pod. |
| `targetPort` | Pod-side destination a Service forwards to. |
| `port` | Port exposed by the Service inside the cluster. |
| `nodePort` | High port (normally 30000–32767) opened by a NodePort/LoadBalancer Service on cluster nodes. |

### Labels vs selectors

**Labels** are key/value metadata attached to Kubernetes objects. **Selectors** are queries used by Services/controllers to find objects carrying matching labels.

### Four deployment strategies

- **RollingUpdate:** replaces old replicas progressively while maintaining availability.
- **Blue-Green:** operates two complete environments and flips the Service selector from old to new.
- **Canary:** sends a controlled fraction of traffic to a new release before wider promotion.
- **Recreate:** removes the old replica set before creating the new one, intentionally allowing downtime.

### `maxSurge` vs `maxUnavailable`

For `replicas: 4`, `maxSurge: 1`, `maxUnavailable: 0`:

- maximum Pods during the rollout = `4 + 1 = 5`;
- minimum available replicas = `4 - 0 = 4`.

### Requests vs limits

- **Requests** are used by the scheduler when deciding whether a node has capacity for a Pod.
- **Limits** are runtime ceilings; CPU can be throttled and exceeding a memory limit can lead to OOM termination.
- `1 GB = 1,000,000,000` bytes; `1 GiB = 1,073,741,824` bytes.

---

## Task 11 — Blue-Green Deployment & Instant Selector Cutover

```bash
cd 02-blue-green
kubectl apply -f deployment-blue.yaml
kubectl apply -f deployment-green.yaml
kubectl get pods -l app=myapp --show-labels

kubectl apply -f service-blue.yaml
kubectl describe svc myapp-service | grep Selector
kubectl get endpoints myapp-service
BLUE_URL=$(minikube service myapp-service --url)
curl -s "$BLUE_URL"

kubectl apply -f service-green.yaml
kubectl describe svc myapp-service | grep Selector
kubectl get endpoints myapp-service
curl -s "$BLUE_URL"

kubectl apply -f service-blue.yaml
curl -s "$BLUE_URL"

kubectl delete -f service-blue.yaml -f deployment-blue.yaml -f deployment-green.yaml
cd ..
```

Expected behavioral sequence is **BLUE ENVIRONMENT → GREEN ENVIRONMENT → BLUE ENVIRONMENT**. On macOS with the Minikube Docker driver, the URL returned by `minikube service ... --url` is more reliable than assuming direct reachability of the Minikube container IP.

**Screenshot:** `screenshots/11-blue-green-cutover.png`

---

## Task 12 — Canary Deployment & Pod-Ratio Traffic Split

```bash
cd 03-canary
kubectl apply -f deployment-stable.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/app-stable

kubectl apply -f deployment-canary.yaml
kubectl rollout status deployment/app-canary
kubectl get pods -l app=myapp-canary --show-labels
kubectl get endpoints myapp-canary-service

CANARY_URL=$(minikube service myapp-canary-service --url)
for i in $(seq 1 20); do
  curl -s "$CANARY_URL"
done

kubectl scale deployment app-canary --replicas=3
kubectl scale deployment app-stable --replicas=7
kubectl get endpoints myapp-canary-service

kubectl scale deployment app-canary --replicas=0
kubectl scale deployment app-stable --replicas=9
for i in $(seq 1 5); do curl -s "$CANARY_URL"; done

kubectl delete -f service.yaml -f deployment-canary.yaml -f deployment-stable.yaml
cd ..
```

With 9 stable Pods and 1 canary Pod, kube-proxy endpoint selection gives an approximate 90/10 distribution over enough requests; it is not a guaranteed exactly-every-tenth-request algorithm.

**Screenshot:** `screenshots/12-canary-traffic-split.png`

---

## Task 13 — Recreate Deployment & Downtime Demonstration

```bash
cd 04-recreate
kubectl apply -f deployment-v1.yaml
kubectl apply -f service.yaml
kubectl rollout status deployment/app-recreate
kubectl get pods -l app=app-recreate

RECREATE_URL=$(minikube service app-recreate --url)
```

Keep this loop running in a second terminal:

```bash
while true; do
  curl -s --connect-timeout 1 "$RECREATE_URL" || echo '[OUTAGE] Connection refused / 0 Ready pods'
  sleep 0.5
done
```

Then trigger the update from the first terminal:

```bash
kubectl apply -f deployment-v2.yaml
kubectl rollout status deployment/app-recreate
kubectl rollout history deployment/app-recreate
kubectl rollout undo deployment/app-recreate
kubectl rollout status deployment/app-recreate
kubectl delete -f service.yaml -f deployment-v2.yaml
cd ..
```

The v2 manifest deliberately waits before becoming Ready so the Recreate outage is visible in the curl loop: `VERSION: v1` → outage → `VERSION: v2 (UPGRADED)`.

**Screenshot:** `screenshots/13-recreate-downtime-outage.png`

---

## Required evidence

See [`screenshots/README.md`](screenshots/README.md) for the exact Lecture 10 screenshot checklist. All screenshots must come from this student's cluster and must show the commands/states described above.
