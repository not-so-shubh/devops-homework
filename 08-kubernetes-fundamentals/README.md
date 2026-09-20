# 08 — Kubernetes Fundamentals

This section covers the Lecture 9 Minikube setup and Kubernetes architecture work.

## Task 1 — Verify Minikube and kubectl

```bash
minikube version
kubectl version --client
```

Capture the real output as `screenshots/01-version-check.png`.

## Task 2 — Start the cluster

```bash
minikube start
```

Capture `screenshots/02-minikube-start.png`.

## Task 3 — Verify health and node readiness

```bash
minikube status
kubectl cluster-info
kubectl get nodes -o wide
```

Capture `screenshots/03-minikube-status.png`.

## Task 4 — Stop the cluster

```bash
minikube stop
minikube status
```

Capture `screenshots/04-minikube-stop.png`.

## Task 5 — Kubernetes architecture

### Control plane

- **kube-apiserver** — API front door used by kubectl and internal controllers.
- **etcd** — strongly consistent key-value store containing cluster state.
- **kube-scheduler** — assigns unscheduled Pods to suitable nodes.
- **kube-controller-manager** — runs reconciliation loops that continuously move current state toward desired state.

### Worker node

- **kubelet** — node agent that receives PodSpecs and ensures containers are running.
- **kube-proxy** — implements Service networking rules on each node.
- **Container runtime** — runs containers through the CRI, commonly containerd or CRI-O.
- **Pod** — smallest Kubernetes deployable unit; one or more containers share networking and volumes.

### Interaction flow

```text
kubectl -> kube-apiserver -> etcd
                     |-> scheduler
                     |-> controller-manager
                     |-> kubelet -> container runtime -> Pods
                                      |
                                   kube-proxy
```

Do not paste example version/IP output into this README. The screenshots must come from the real machine.
