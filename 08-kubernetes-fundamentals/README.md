# 08 — Kubernetes Fundamentals

**Student:** Shubh Jaiswal  
**Enrollment:** 24BCS10601  
**Course:** SST DevOps & Cloud [SWE]  
**Lecture mapping:** Lecture 9

This section follows the Lecture 9 assignment: verify the local Kubernetes tooling, execute the complete Minikube cluster lifecycle, and document Kubernetes control-plane and worker-node architecture. Runtime output below must be generated on the student's own machine; sample version numbers or IP addresses are not treated as evidence.

---

## Task 1 — Minikube Installation & Environment Setup

**One-line description:** Verify that `minikube` and `kubectl` are installed and available from the shell.

### Commands

```bash
minikube version
kubectl version --client
```

### Terminal output

Run the commands above and capture the real version output from this Mac. Do not paste the example versions from the assignment document.

### Screenshot placeholder

`./screenshots/01-version-check.png`

---

## Task 2 — Minikube Cluster Lifecycle Execution

**One-line description:** Start the local cluster, verify every Minikube component and the Kubernetes node, then stop the cluster cleanly.

### Start

```bash
minikube start
```

**Terminal output:** capture the real successful cluster-start output.

**Screenshot placeholder:** `./screenshots/02-minikube-start.png`

### Verify cluster health

```bash
minikube status
kubectl cluster-info
kubectl get nodes -o wide
```

Success means Minikube reports the host, kubelet and API server as running and `kubectl get nodes` reports the node as `Ready`.

**Screenshot placeholder:** `./screenshots/03-minikube-status.png`

### Stop cleanly

```bash
minikube stop
minikube status
```

**Terminal output:** capture the real stop/status output from the local cluster.

**Screenshot placeholder:** `./screenshots/04-minikube-stop.png`

> Start Minikube again before continuing with Sections 09–11.

---

## Task 3 — Kubernetes Architecture & Core Components

Kubernetes uses a control plane to store desired state and make cluster-wide decisions, while worker-node components run and network application Pods.

### Control Plane

| Component | Responsibility |
|---|---|
| `kube-apiserver` | REST API front door for `kubectl`, controllers, schedulers and other clients. It validates API requests and exposes cluster state. |
| `etcd` | Strongly consistent key-value store containing Kubernetes API state. |
| `kube-scheduler` | Finds unscheduled Pods and assigns them to suitable nodes using resources, constraints, affinity/anti-affinity and other scheduling rules. |
| `kube-controller-manager` | Runs reconciliation loops such as Deployment, ReplicaSet and node controllers so actual state moves toward desired state. |
| `cloud-controller-manager` | Integrates Kubernetes with cloud-provider APIs for infrastructure such as routes and load balancers; a local Minikube lab does not depend on a public-cloud implementation. |

### Worker Node

| Component | Responsibility |
|---|---|
| `kubelet` | Node agent that watches assigned PodSpecs and asks the container runtime to keep their containers running. |
| Container runtime | Runs containers through the Kubernetes CRI; common runtimes include containerd and CRI-O. |
| `kube-proxy` | Implements Service traffic forwarding/routing rules on nodes. |
| Pod | Smallest deployable Kubernetes unit; its containers share the Pod network namespace and can share volumes. |

### What happens when a manifest is applied

```text
kubectl
   |
   v
kube-apiserver <----> etcd
   |
   +----> scheduler chooses a node
   |
   +----> controllers reconcile desired state
                    |
                    v
                 kubelet
                    |
                    v
            container runtime
                    |
                    v
                   Pod
```

A typical flow is:

1. `kubectl apply` sends the object to `kube-apiserver`.
2. The API server validates the request and stores desired state in `etcd`.
3. The scheduler assigns an unscheduled Pod to a node.
4. The node's kubelet asks the container runtime to create the containers.
5. Controllers continuously observe the API and reconcile failures or changes.
6. Service networking components route traffic to eligible Pods.

### Architecture verification commands

When Minikube is running:

```bash
kubectl get pods -n kube-system -o wide
kubectl get nodes -o wide
kubectl cluster-info
```

These commands connect the written architecture to the components visible in the local cluster.

---

## Submission evidence checklist

- [ ] `screenshots/01-version-check.png` — actual Minikube + kubectl versions.
- [ ] `screenshots/02-minikube-start.png` — successful local cluster start.
- [ ] `screenshots/03-minikube-status.png` — running components and a `Ready` node.
- [ ] `screenshots/04-minikube-stop.png` — clean Minikube stop/status.
- [x] Control-plane and worker-node architecture documented above.

No terminal transcript or screenshot in this section should be copied from another student's repository.
