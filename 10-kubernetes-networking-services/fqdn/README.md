# Kubernetes FQDN

A Fully Qualified Domain Name identifies a DNS record from the leaf name through the cluster domain. Kubernetes Services normally use:

```text
<service>.<namespace>.svc.cluster.local
```

For Service `api` in namespace `production`, the FQDN is `api.production.svc.cluster.local`. A Pod in the same namespace can normally use `api`; another namespace can use `api.production`; the full name is unambiguous everywhere in the cluster.

CoreDNS synthesizes Service records from Kubernetes API objects. A normal ClusterIP Service resolves to its virtual IP. A headless Service (`clusterIP: None`) returns endpoint/Pod addresses directly. StatefulSet Pods can receive stable records such as `web-0.web.default.svc.cluster.local` when paired with a governing headless Service.

```bash
kubectl exec -n service-lab dns-client -- nslookup clusterip-app
kubectl exec -n service-lab dns-client -- nslookup clusterip-app.service-lab.svc.cluster.local
kubectl exec -n service-lab dns-client -- cat /etc/resolv.conf
```

Pod-to-Service communication resolves DNS, connects to the Service IP/port and is load-balanced to a Ready endpoint selected by labels.
