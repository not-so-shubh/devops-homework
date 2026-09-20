# 10 — Kubernetes Networking & Services

**Student:** Shubh Jaiswal  
**Enrollment:** 24BCS10601  
**Lecture mapping:** Lecture 11

This section implements all 12 networking/service tasks from the assignment: the four Kubernetes port concepts, five major Service patterns, selectorless Services, CoreDNS/FQDN behavior, workload identity, controller comparison, production Service selection, and the Minikube Docker-driver networking gotcha.

> Run commands from `10-kubernetes-networking-services/` with Minikube running.

---

## Task 1 — Kubernetes Port Architecture

```text
External client
      |
      v
nodePort : 30080        (node-level entry; NodePort/LoadBalancer)
      |
      v
Service port : 8080     (Service virtual IP)
      |
      v
targetPort : 80         (destination on selected Pod)
      |
      v
containerPort : 80      (application/container declaration)
```

Schema inspection:

```bash
kubectl explain pod.spec.containers.ports.containerPort
kubectl explain service.spec.ports
```

**Screenshot:** `screenshots/01-port-architecture.png`

---

## Task 2 — ClusterIP: Default Internal Networking

```bash
kubectl apply -f 01-clusterip/app-deployment.yaml
kubectl apply -f 01-clusterip/service.yaml
kubectl apply -f 01-clusterip/client-pod.yaml
kubectl rollout status deployment/web-app-clusterip
kubectl wait --for=condition=ready pod/curl-client --timeout=120s

kubectl get pods -l app=web-clusterip -o wide
kubectl get svc web-service-clusterip
kubectl get endpoints web-service-clusterip
kubectl get endpointslices -l kubernetes.io/service-name=web-service-clusterip

kubectl exec curl-client -- curl -s http://web-service-clusterip:8080/ | grep -i '<title>'
kubectl exec curl-client -- curl -s http://web-service-clusterip.default.svc.cluster.local:8080/ | grep -i '<title>'
```

The Service exposes port `8080` inside the cluster and forwards to Nginx on Pod port `80`.

**Screenshots:**
- `screenshots/02-clusterip-service.png`
- `screenshots/02-clusterip-fqdn.png`

---

## Task 3 — NodePort: Node-Level External Ingress

```bash
kubectl apply -f 02-nodeport/app-deployment.yaml
kubectl apply -f 02-nodeport/service.yaml
kubectl rollout status deployment/web-app-nodeport
kubectl get svc web-service-nodeport

NODE_IP=$(minikube ip)
curl -I --connect-timeout 3 "http://${NODE_IP}:30080" || true

# Reliable Docker-driver path on macOS:
minikube service web-service-nodeport --url
```

`service.yaml` explicitly reserves node port `30080`.

**Screenshots:**
- `screenshots/03-nodeport-service.png`
- `screenshots/03-nodeport-access.png`

---

## Task 4 — LoadBalancer: Cloud-Native Ingress Simulation

```bash
kubectl apply -f 03-loadbalancer/app-deployment.yaml
kubectl apply -f 03-loadbalancer/service.yaml
kubectl rollout status deployment/web-app-loadbalancer
kubectl get svc web-service-loadbalancer
```

In a second terminal:

```bash
minikube tunnel
```

Back in the first terminal:

```bash
kubectl get svc web-service-loadbalancer
EXTERNAL_IP=$(kubectl get svc web-service-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "$EXTERNAL_IP"
curl -s "http://${EXTERNAL_IP}:80/" | grep -i '<title>'
```

A normal `LoadBalancer` Service also owns a ClusterIP and generally allocates a NodePort underneath it.

**Screenshots:**
- `screenshots/04-loadbalancer-service.png`
- `screenshots/04-loadbalancer-access.png`

---

## Task 5 — ExternalName: CoreDNS CNAME Alias

```bash
kubectl apply -f 04-externalname/service.yaml
kubectl apply -f 04-externalname/client-pod.yaml
kubectl wait --for=condition=ready pod/dns-test-client --timeout=120s

kubectl get svc external-database-service
kubectl get endpoints external-database-service
kubectl exec dns-test-client -- nslookup external-database-service
kubectl exec dns-test-client -- curl -s -I https://external-database-service
```

`ExternalName` has no selector or backing Pod endpoints. DNS maps the internal Service name to the configured external FQDN (`api.github.com` in this lab).

**Screenshots:**
- `screenshots/05-externalname-service.png`
- `screenshots/05-externalname-dns.png`

---

## Task 6 — Headless Service + Stateful Workload

```bash
kubectl apply -f 05-headless/service.yaml
kubectl apply -f 05-headless/app-statefulset.yaml
kubectl apply -f 05-headless/client-pod.yaml
kubectl rollout status statefulset/web-stateful --timeout=180s
kubectl wait --for=condition=ready pod/headless-dns-client --timeout=120s

kubectl get svc web-service-headless
kubectl get pods -l app=web-headless -o wide
kubectl exec headless-dns-client -- nslookup web-service-headless
kubectl exec headless-dns-client -- nslookup web-stateful-0.web-service-headless.default.svc.cluster.local
kubectl exec headless-dns-client -- curl -s http://web-stateful-0.web-service-headless:80/ | grep -i '<title>'
```

Because `clusterIP: None`, CoreDNS can return individual Pod addresses and stable StatefulSet hostnames instead of one Service VIP.

**Screenshots:**
- `screenshots/06-headless-dns.png`
- `screenshots/06-headless-pod-fqdn.png`

---

## Task 7 — Service Without Selectors / Manual Endpoints

First show that a selectorless Service has no endpoints:

```bash
kubectl apply -f 06-no-selector-service/service.yaml
kubectl get endpoints external-legacy-db
```

Then attach the manual endpoint object:

```bash
kubectl apply -f 06-no-selector-service/endpoints.yaml
kubectl get endpoints external-legacy-db
```

The assignment's example endpoint is `192.168.1.150:3306`. It demonstrates API mapping to legacy/external infrastructure; it is not claimed to be reachable from this Mac.

**Screenshots:**
- `screenshots/07-selectorless-empty.png`
- `screenshots/07-selectorless-endpoint.png`

---

## Task 8 — FQDN & CoreDNS Deep Dive

Service FQDN format:

```text
<service>.<namespace>.svc.cluster.local
```

Commands:

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup web-service-clusterip
kubectl exec curl-client -- nslookup web-service-clusterip.default.svc.cluster.local
kubectl exec curl-client -- nslookup api.github.com
```

Typical Kubernetes resolver configuration contains cluster search domains and `options ndots:5`. With `ndots:5`, names with fewer than five dots may be attempted through search suffixes before the absolute query, which can add DNS lookups for external hostnames.

**Screenshots:**
- `screenshots/08-coredns-resolv-conf.png`
- `screenshots/08-coredns-resolution.png`

---

## Task 9 — Deployment vs StatefulSet Identity Invariance

```bash
kubectl apply -f 01-clusterip/app-deployment.yaml
kubectl apply -f 05-headless/service.yaml
kubectl apply -f 05-headless/app-statefulset.yaml
kubectl rollout status deployment/web-app-clusterip
kubectl rollout status statefulset/web-stateful

kubectl get pods -l app=web-clusterip
kubectl get pods -l app=web-headless

DEPLOY_POD=$(kubectl get pods -l app=web-clusterip -o jsonpath='{.items[0].metadata.name}')
echo "Deleting stateless Pod: $DEPLOY_POD"
kubectl delete pod "$DEPLOY_POD"
kubectl get pods -l app=web-clusterip -w

kubectl delete pod web-stateful-0
kubectl get pods -l app=web-headless -w
```

A Deployment replacement receives a new generated Pod name, while the StatefulSet recreates the exact ordinal identity `web-stateful-0`.

**Screenshots:**
- `screenshots/09-identity-before.png`
- `screenshots/09-identity-after.png`

---

## Task 10 — Deployment vs StatefulSet vs DaemonSet Matrix

```bash
kubectl explain deployment.spec
kubectl explain statefulset.spec
kubectl explain daemonset.spec
```

| Architectural metric | Deployment | StatefulSet | DaemonSet |
|---|---|---|---|
| Primary workload | Stateless APIs/web apps | Stateful clustered systems | Node-level agents |
| Pod identity | Replaceable generated names | Stable ordinal identity | One Pod per eligible node |
| Startup/shutdown | Parallel/unordered by default | Ordered by default | Node-driven/parallel |
| Storage | Shared or ephemeral | Per-Pod PVC via `volumeClaimTemplates` | Commonly node/host-oriented |
| Service pattern | ClusterIP/NodePort/LoadBalancer | Often Headless + internal Service | Often no user-facing Service |
| Scaling | Explicit replica count | Explicit ordered replica count | Follows eligible node count |
| Examples | Nginx/API services | Kafka, PostgreSQL, Cassandra | Fluentd, node exporter, security agents |

**Screenshot:** `screenshots/10-controller-matrix.png`

---

## Task 11 — Production Cost Optimization & Service Selection

The assignment uses an **illustrative** cloud-pricing example to explain why one external load balancer per microservice can become expensive. The architectural point is that HTTP/HTTPS services can commonly remain internal `ClusterIP` Services behind one Ingress/Gateway entry point.

```text
Many public LBs (anti-pattern for many HTTP services)
service A -> load balancer A
service B -> load balancer B
service C -> load balancer C

Shared Layer-7 entry point
Internet -> one external load balancer -> Ingress Controller
                                      |-> ClusterIP A
                                      |-> ClusterIP B
                                      `-> ClusterIP C
```

Service selection tree:

```text
Need external access?
|
+-- No --> Need direct per-Pod discovery?
|          +-- Yes --> Headless Service
|          `-- No  --> ClusterIP
|
`-- Yes -> Is the destination itself an external DNS service?
           +-- Yes --> ExternalName
           `-- No  --> Public cloud HTTP/HTTPS?
                       +-- Yes --> Ingress/Gateway over internal ClusterIP Services
                       `-- No  --> NodePort for simple dev/on-prem exposure

For dedicated non-HTTP cloud exposure, a LoadBalancer Service may be appropriate.
```

**Screenshot:** `screenshots/11-service-decision-tree.png`

---

## Task 12 — Minikube Docker-Driver Port Binding / Tunnel Gotcha

On macOS/Windows with Minikube's Docker driver, the Minikube node address sits behind the Docker networking boundary and may not be directly routable from the host in the same way as a native Linux node.

```bash
kubectl get svc web-service-nodeport
NODE_IP=$(minikube ip)
echo "Testing ${NODE_IP}:30080"
curl --connect-timeout 2 -I "http://${NODE_IP}:30080" || echo 'Direct NodePort path not reachable from this host'

# NodePort workaround
NODEPORT_URL=$(minikube service web-service-nodeport --url)
echo "$NODEPORT_URL"
curl -I "$NODEPORT_URL"

# LoadBalancer routing simulation used in Task 4 (separate terminal)
minikube tunnel
```

`minikube service ... --url` is the direct workaround demonstrated for the NodePort lab; `minikube tunnel` is also required by the assignment's LoadBalancer simulation.

**Screenshots:**
- `screenshots/12-docker-driver-direct.png`
- `screenshots/12-minikube-service-url.png`

---

## Cleanup

```bash
kubectl delete -f 01-clusterip/ --ignore-not-found
kubectl delete -f 02-nodeport/ --ignore-not-found
kubectl delete -f 03-loadbalancer/ --ignore-not-found
kubectl delete -f 04-externalname/ --ignore-not-found
kubectl delete -f 05-headless/ --ignore-not-found
kubectl delete -f 06-no-selector-service/ --ignore-not-found
```

See [`screenshots/README.md`](screenshots/README.md) for the evidence checklist. Runtime screenshots must come from this student's cluster.
