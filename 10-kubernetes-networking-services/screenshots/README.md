# Lecture 11 Screenshot Checklist

1. `01-port-architecture.png` — four-port routing diagram or schema output.
2. `02-clusterip-service.png` — ClusterIP plus all healthy endpoints.
3. `02-clusterip-fqdn.png` — successful short-name and full-FQDN requests.
4. `03-nodeport-service.png` — `80:30080/TCP` NodePort mapping.
5. `03-nodeport-access.png` — successful response through the Minikube service URL / NodePort path available on the host.
6. `04-loadbalancer-service.png` — populated LoadBalancer `EXTERNAL-IP` while tunnel is active.
7. `04-loadbalancer-access.png` — successful HTTP response on standard port 80.
8. `05-externalname-service.png` — `TYPE ExternalName` with no ClusterIP/endpoints.
9. `05-externalname-dns.png` — DNS CNAME resolution to the configured external FQDN.
10. `06-headless-dns.png` — multiple Pod A records for the Headless Service.
11. `06-headless-pod-fqdn.png` — direct ordinal Pod hostname resolution/request.
12. `07-selectorless-empty.png` — selectorless Service before manual Endpoints.
13. `07-selectorless-endpoint.png` — manual endpoint mapping after apply.
14. `08-coredns-resolv-conf.png` — `nameserver`, `search`, and `ndots` from `/etc/resolv.conf`.
15. `08-coredns-resolution.png` — short Service name, FQDN, and external DNS resolution.
16. `09-identity-before.png` — generated Deployment names vs StatefulSet ordinals.
17. `09-identity-after.png` — new Deployment Pod identity vs recreated `web-stateful-0`.
18. `10-controller-matrix.png` — controller comparison table/schema inspection.
19. `11-service-decision-tree.png` — rendered Service selection/cost architecture documentation.
20. `12-docker-driver-direct.png` — direct NodePort attempt on Docker-driver Minikube.
21. `12-minikube-service-url.png` — successful `minikube service ... --url` request.

Use only genuine local-cluster evidence.
