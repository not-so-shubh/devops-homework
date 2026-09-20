# Section 10 Screenshot Checklist

Capture these from the real cluster:

1. `01-port-architecture.png` — four-port mapping/explain output.
2. `02-clusterip-service.png` — Service + endpoints and successful short-name/FQDN curl.
3. `03-nodeport-service.png` — NodePort mapping plus reachable URL.
4. `04-loadbalancer-service.png` — populated external IP while `minikube tunnel` is active.
5. `05-externalname-service.png` — ExternalName object and CNAME resolution.
6. `06-headless-service.png` — headless Service plus individual Pod DNS records.
7. `07-no-selector-endpoints.png` — empty-to-manual endpoints demonstration.
8. `08-coredns-resolv-conf.png` — resolver config and DNS queries.
9. `09-workload-identity.png` — Deployment vs StatefulSet Pod naming/recreation.
10. `10-controller-matrix.png` — documented controller comparison.
11. `11-service-selection.png` — documented Service/Ingress decision explanation.
12. `12-minikube-networking.png` — macOS/Docker-driver workaround proof (`minikube service --url` or tunnel).
