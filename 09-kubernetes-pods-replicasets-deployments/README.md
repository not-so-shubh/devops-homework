# 09 — Kubernetes Pods, ReplicaSets & Deployments

This section implements the Lecture 10 workload-controller labs: Pod lifecycle states, probes, ReplicaSet/StatefulSet/DaemonSet behavior, rollout strategies, and troubleshooting.

## Baseline cluster checks

```bash
minikube start
kubectl version --output=yaml
kubectl cluster-info
kubectl get nodes -o wide
```

## Standard Pod

```bash
kubectl apply -f pod.yml
kubectl get pods -o wide
kubectl logs nginx-pod
kubectl delete -f pod.yml
```

## Short-lived Pod lifecycle

Run `kubectl get pods -w` in one terminal and apply `hello.yml` in another. Capture `ContainerCreating -> Running -> Completed` when timing permits.

## Lifecycle and probe manifests

`pod-lifecycle/` contains the 12 requested examples:

1. running
2. pending/unschedulable
3. succeeded
4. failed
5. CrashLoopBackOff
6. ImagePullBackOff
7. readiness
8. liveness
9. startup
10. init container
11. multi-container Pod
12. graceful termination

## Controllers

- `replicaset.yml` — delete one matching Pod and verify the ReplicaSet restores the desired count.
- `statefulset.yml` — demonstrates deterministic ordinal identity and PVC templates.
- `daemonset.yml` — one node-agent Pod per eligible node.

## Deployment strategies

- `01-rolling-update/` — RollingUpdate with `maxSurge: 1`, `maxUnavailable: 0`, plus rollback.
- `02-blue-green/` — Blue and Green run simultaneously; Service selector flips traffic atomically.
- `03-canary/` — 9 stable + 1 canary replicas behind one Service; scale ratios to shift traffic.
- `04-recreate/` — old replicas are removed before new replicas are started, creating an intentional outage window.

## Troubleshooting

- `troubleshooting/broken-image.yaml` intentionally references a bad image tag.
- `troubleshooting/selector-mismatch.yaml` is intentionally invalid because selector/template labels do not match. Fix the labels before a successful apply.

## Core concepts

### Kubernetes ports

- `containerPort` documents the application port inside a container.
- `targetPort` is the backend Pod port a Service forwards to.
- `port` is the Service's internal cluster port.
- `nodePort` is the high node-level port exposed by a NodePort/LoadBalancer Service.

### Labels vs selectors

Labels are key/value metadata attached to objects. Selectors are queries/controllers use to choose matching objects.

### Requests vs limits

Requests influence scheduling and guaranteed capacity. Limits are runtime ceilings. Memory limit violations can lead to OOM termination; CPU limits can cause throttling.

### GB vs GiB

`1 GB = 10^9 bytes`; `1 GiB = 2^30 bytes`.

See `screenshots/README.md` for the evidence checklist.
