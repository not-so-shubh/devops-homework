# Lecture 12 Screenshot Checklist

1. `01-configmap.png` — all five ConfigMap values plus JSONPath output.
2. `02-configmap-update.png` — existing Pod remains `production`, rollout restart, replacement Pod reads `staging`.
3. `03-secret.png` — Secret describe output plus decoded lab user/password.
4. `04-newline-gotcha.png` — hex/Base64 comparison with and without trailing `0a`.
5. `05-secret-architecture.png` — documented external secret-management / CI-CD flow.
6. `06-config-secret-injection.png` — running backend env contains both ConfigMap and Secret values.
7. `07-ingress-vs-controller.png` — comparison table/architecture plus Ingress API resource listing.
8. `08-ingress-controller.png` — NGINX Ingress controller `Running`/Ready and successful wait.
9. `09-hosts-mapping.png` — Minikube IP matches `yatri.local` entry in `/etc/hosts`.
10. `10-path-routing.png` — frontend response at `/` and backend response at `/api/`.
11. `11-host-routing.png` — portal and API virtual hosts route to separate Services.
12. `12-hybrid-routing.png` — `kubectl describe ingress` shows combined host/path table.
13. `13-tls-ingress.png` — HTTPS handshake and successful HTTP response over TLS.
14. `14-full-demo.png` — `run-demo.sh` healthy stack followed by `cleanup.sh` and deletion proof.

All screenshots must be captured from the student's own machine and cluster.
