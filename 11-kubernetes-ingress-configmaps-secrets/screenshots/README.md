# Section 11 Screenshot Checklist

Capture genuine evidence from your local cluster:

1. `01-configmap.png` — ConfigMap describe + JSONPath value.
2. `02-configmap-update.png` — running Pod retains old env, then rollout restart picks up the new value.
3. `03-secret.png` — Secret describe plus decoded lab values.
4. `04-newline-gotcha.png` — `echo` vs `echo -n` byte/Base64 difference.
5. `05-enterprise-secrets.png` — documented enterprise secret-management architecture.
6. `06-config-secret-injection.png` — backend env contains ConfigMap and Secret values.
7. `07-ingress-resource-controller.png` — comparison plus API/controller proof.
8. `08-ingress-controller.png` — ingress-nginx controller Running/Ready.
9. `09-hosts-mapping.png` — Minikube/Ingress IP mapped to `yatri.local`.
10. `10-path-routing.png` — `/` frontend and `/api` backend responses.
11. `11-host-routing.png` — different virtual hosts route to different Services.
12. `12-hybrid-routing.png` — describe output showing multi-host/multi-path routing.
13. `13-tls-ingress.png` — successful HTTPS handshake using the self-signed lab certificate.
14. `14-full-demo.png` — `run-demo.sh`, resource audit, then `cleanup.sh` and deletion proof.

Do not commit `tls.key` or any real credential. The repository `.gitignore` excludes local TLS key/certificate files.
