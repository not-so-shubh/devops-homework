# 10 — Kubernetes Networking & Services

This section implements the Lecture 11 Service and DNS labs.

## 1. Kubernetes port architecture

```text
External client
   |
   v
nodePort (Node IP, only NodePort/LoadBalancer)
   |
   v
port (Service virtual IP)
   |
   v
targetPort (Pod destination port)
   |
   v
containerPort (documented application port)
```

Useful references:

```bash
kubectl explain pod.spec.containers.ports.containerPort
kubectl explain service.spec.ports
```

## 2. ClusterIP

```bash
kubectl apply -f 01-clusterip/
kubectl get pods -l app=web-clusterip -o wide
kubectl get svc web-service-clusterip
kubectl get endpoints web-service-clusterip
kubectl exec curl-client -- curl -s http://web-service-clusterip:8080
kubectl exec curl-client -- curl -s http://web-service-clusterip.default.svc.cluster.local:8080
```

## 3. NodePort

```bash
kubectl apply -f 02-nodeport/
kubectl get svc web-service-nodeport
minikube service web-service-nodeport --url
```

On macOS with the Minikube Docker driver, prefer the URL returned by `minikube service ... --url`; direct `<minikube-ip>:nodePort` routing may not behave like a native Linux node.

## 4. LoadBalancer

```bash
kubectl apply -f 03-loadbalancer/
kubectl get svc web-service-loadbalancer
# separate terminal
minikube tunnel
```

A `LoadBalancer` Service still has an internal ClusterIP and normally allocates a NodePort unless configured otherwise.

## 5. ExternalName

```bash
kubectl apply -f 04-externalname/
kubectl get svc external-api
kubectl exec dns-test-client -- nslookup external-api
```

`ExternalName` creates a DNS CNAME-style alias. It has no selector and does not create Pod endpoints.

## 6. Headless Service

```bash
kubectl apply -f 05-headless/
kubectl get svc web-service-headless
kubectl get pods -l app=web-headless -o wide
kubectl exec headless-dns-client -- nslookup web-service-headless
kubectl exec headless-dns-client -- nslookup web-stateful-0.web-service-headless.default.svc.cluster.local
```

`clusterIP: None` means DNS can return the individual backing Pod addresses instead of one Service VIP.

## 7. Service without selectors

`06-no-selector-service/` demonstrates a Service that is manually backed by an `Endpoints` object. This pattern can front legacy/external infrastructure, but the example IP is documentation-only and may not be reachable from your machine.

## 8. FQDN and CoreDNS

Kubernetes Service FQDN:

```text
<service>.<namespace>.svc.cluster.local
```

Inspect a Pod resolver:

```bash
kubectl exec curl-client -- cat /etc/resolv.conf
kubectl exec curl-client -- nslookup web-service-clusterip
kubectl exec curl-client -- nslookup api.github.com
```

With the common `ndots:5` resolver setting, names containing fewer than five dots may first be expanded through cluster search suffixes before being tried as absolute external names. That can add unnecessary DNS queries for external APIs.

## 9. Deployment vs StatefulSet identity

Deployments create replaceable Pod names containing rollout/replica hashes. StatefulSets preserve ordered identities such as `web-stateful-0`, `web-stateful-1`, and recreate the same ordinal after deletion.

## 10. Controller comparison

| Property | Deployment | StatefulSet | DaemonSet |
|---|---|---|---|
| Identity | Replaceable | Stable ordinal | One per eligible node |
| Typical storage | Shared/ephemeral | Per-Pod PVC | Host/node-oriented |
| Ordering | Not guaranteed | Ordered by default | Node-driven |
| Common use | Stateless APIs/web | Databases, queues | Agents, logging, monitoring |
| Common Service | ClusterIP | Often headless + ClusterIP | Usually no user-facing Service |

## 11. Service selection and cloud cost

Use `ClusterIP` for internal microservices. Use NodePort primarily for simple labs/debugging. Use `LoadBalancer` when a workload truly needs a dedicated cloud load balancer. In larger production systems, an Ingress/Gateway layer commonly fronts many internal ClusterIP Services so you do not pay for a separate external load balancer per microservice.

## 12. Minikube Docker-driver networking note

Docker-driver Minikube runs the Kubernetes node inside a container/VM-like network boundary. On macOS/Windows, that boundary differs from native Linux routing. Standard workarounds are:

```bash
minikube service <service-name> --url
minikube tunnel
```

See `screenshots/README.md` for the evidence checklist.
