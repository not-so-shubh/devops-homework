# CoreDNS in Kubernetes

CoreDNS is the default cluster DNS server. Kubernetes runs it as a Deployment in `kube-system` and exposes it through the `kube-dns` Service for compatibility.

## Resolution flow

1. A Pod sends a query to the nameserver listed in `/etc/resolv.conf`.
2. Search domains allow short names to expand through namespace and cluster suffixes.
3. CoreDNS's `kubernetes` plugin watches Services, EndpointSlices, namespaces and Pods through the API.
4. Cluster names are answered from that state; the `forward` plugin sends external queries to upstream resolvers.
5. Positive and negative results may be cached.

Inspect configuration and health:

```bash
kubectl get deployment,service,pods -n kube-system -l k8s-app=kube-dns
kubectl get configmap coredns -n kube-system -o yaml
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl exec -n service-lab dns-client -- nslookup kubernetes.default.svc.cluster.local
```

Troubleshoot by checking the Pod's `resolv.conf`, the queried namespace/name, Service and EndpointSlices, CoreDNS Pods/logs, the Corefile, NetworkPolicies permitting UDP/TCP 53 and upstream DNS health. `SERVFAIL` often indicates upstream/configuration problems; `NXDOMAIN` commonly indicates a wrong or absent name.
