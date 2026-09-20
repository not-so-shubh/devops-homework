# 11 — Kubernetes Ingress, ConfigMaps & Secrets

**Student:** Shubh Jaiswal  
**Enrollment:** 24BCS10601  
**Lecture mapping:** Lecture 12

This section implements all 14 assignment tasks covering ConfigMaps, Secrets, configuration-update behavior, secret hygiene, Ingress architecture, NGINX Ingress activation, host/path routing, TLS termination, and the final multi-tier automated demo.

> Run commands from `11-kubernetes-ingress-configmaps-secrets/`. Values in Secret manifests are lab-only placeholders, never real credentials.

---

## Task 1 — Non-Sensitive Configuration via ConfigMap

`01-configmap/app-config.yaml` stores exactly the five assignment values: `ENVIRONMENT`, `LOG_LEVEL`, `PORT`, `DEFAULT_CURRENCY`, and `MAX_BOOKING_DAYS`.

```bash
kubectl apply -f 01-configmap/app-config.yaml
kubectl get configmap yatri-app-config
kubectl describe configmap yatri-app-config
kubectl get configmap yatri-app-config -o jsonpath='{.data.ENVIRONMENT}' && echo
kubectl get configmap yatri-app-config -o jsonpath='{.data.LOG_LEVEL}' && echo
```

**Screenshot:** `screenshots/01-configmap.png`

---

## Task 2 — ConfigMap Live Update & Existing-Pod Immutability

Prepare the full-demo backend first so the environment variable has a running consumer:

```bash
kubectl apply -f 04-full-demo/configmap.yaml
kubectl apply -f 04-full-demo/secret.yaml
kubectl apply -f 04-full-demo/backend.yaml
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT
```

Patch the ConfigMap, prove the already-running Pod still has its old process environment, restart, then prove a new Pod receives the updated value:

```bash
kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"staging"}}'
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT

kubectl rollout restart deployment/yatri-backend
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT

# Restore production for later tasks
kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"production"}}'
kubectl rollout restart deployment/yatri-backend
kubectl rollout status deployment/yatri-backend
```

**Screenshot:** `screenshots/02-configmap-update.png`

---

## Task 3 — Kubernetes Secrets & Base64 Mechanics

```bash
kubectl apply -f 02-secret/db-secret.yaml
kubectl get secret yatri-db-secret
kubectl describe secret yatri-db-secret
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode && echo
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_USER}' | base64 --decode && echo
```

Base64 is reversible encoding, not encryption. `kubectl describe secret` hides values from normal display, but anyone authorized to read the Secret object can retrieve the encoded data.

**Screenshot:** `screenshots/03-secret.png`

---

## Task 4 — Trailing-Newline Secret Gotcha

```bash
echo 'secretpassword' | xxd
echo 'secretpassword' | base64

echo -n 'secretpassword' | xxd
echo -n 'secretpassword' | base64

echo "Wrong (with newline): $(echo 'secretpassword' | base64)"
echo "Right (no newline):   $(echo -n 'secretpassword' | base64)"
```

Standard `echo` appends byte `0a`; `echo -n` avoids encoding that newline into the credential.

**Screenshot:** `screenshots/04-newline-gotcha.png`

---

## Task 5 — Enterprise Secret Management & CI/CD Integration

Hardcoding Base64 Secret values in a Git repository is an anti-pattern because Git history is durable, Base64 is reversible, access can spread beyond the workload, and rotation is harder.

A common production flow is:

```text
AWS Secrets Manager / Azure Key Vault / HashiCorp Vault
                      |
                      v
      External Secrets Operator / Vault injector
                      |
                      v
              Kubernetes Secret
                      |
                      v
               Pod env / volume
```

CI/CD systems can also resolve secrets from protected GitHub Actions secrets or Azure DevOps Variable Groups at deployment time rather than committing clear/reversible credential material into manifests.

Check the current cluster for secret-related CRDs:

```bash
kubectl get crds | grep -i secret || echo 'Standard native secrets in use'
```

**Screenshot:** `screenshots/05-secret-architecture.png`

---

## Task 6 — Combined ConfigMap + Secret Injection

`04-full-demo/backend.yaml` uses `envFrom.configMapRef` for non-sensitive configuration and `env.valueFrom.secretKeyRef` for database credentials.

```bash
kubectl apply -f 04-full-demo/configmap.yaml
kubectl apply -f 04-full-demo/secret.yaml
kubectl apply -f 04-full-demo/backend.yaml
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|POSTGRES|DEFAULT_CURRENCY'
```

**Screenshot:** `screenshots/06-config-secret-injection.png`

---

## Task 7 — Ingress Resource vs Ingress Controller

| Ingress resource | Ingress controller |
|---|---|
| Declarative Kubernetes Layer-7 routing API object | Active reverse proxy/controller implementation |
| Stores hosts, paths, TLS references and target Services | Watches the Kubernetes API and turns rules into proxy configuration |
| Does not forward requests by itself | Performs actual request routing (for example NGINX/Traefik/HAProxy/Envoy-based implementations) |

Architecture:

```text
Ingress YAML -> kube-apiserver <- watched by Ingress Controller
                                      |
                                      v
                               reverse proxy config
                                      |
                           +----------+----------+
                           v                     v
                    frontend Service      backend Service
```

```bash
kubectl api-resources | grep -i ingress
```

**Screenshot:** `screenshots/07-ingress-vs-controller.png`

---

## Task 8 — Enable and Verify NGINX Ingress Controller

```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
kubectl get service -n ingress-nginx
```

**Screenshot:** `screenshots/08-ingress-controller.png`

---

## Task 9 — Local DNS / `/etc/hosts` Mapping

```bash
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP is: ${MINIKUBE_IP}"

if ! grep -qE '(^|[[:space:]])yatri\.local([[:space:]]|$)' /etc/hosts; then
  echo "${MINIKUBE_IP}  yatri.local" | sudo tee -a /etc/hosts
fi

grep 'yatri.local' /etc/hosts
```

On Docker-driver Minikube, Ingress reachability can vary by host networking. If direct host-to-Minikube-IP access is unavailable, keep the `/etc/hosts` evidence required by the assignment and use the host-access method exposed by the local Minikube setup for the actual HTTP test.

**Screenshot:** `screenshots/09-hosts-mapping.png`

---

## Task 10 — Layer-7 Path-Based Routing

`04-full-demo/ingress.yaml` uses NGINX regex routing and `rewrite-target: /$2`:

- `http://yatri.local/` → `yatri-frontend`
- `http://yatri.local/api/...` → `yatri-backend`

```bash
kubectl apply -f 04-full-demo/configmap.yaml
kubectl apply -f 04-full-demo/secret.yaml
kubectl apply -f 04-full-demo/backend.yaml
kubectl apply -f 04-full-demo/frontend.yaml
kubectl apply -f 04-full-demo/ingress.yaml
kubectl rollout status deployment/yatri-backend
kubectl rollout status deployment/yatri-frontend
kubectl get ingress yatri-ingress
kubectl describe ingress yatri-ingress

curl -s http://yatri.local/ | grep -i '<title>'
curl -s http://yatri.local/api/
```

**Screenshot:** `screenshots/10-path-routing.png`

---

## Task 11 — Virtual Host / Subdomain Routing

Deploy the dedicated campus frontend/backend and host-routing rule:

```bash
kubectl apply -f 03-ingress/frontend.yaml
kubectl apply -f 03-ingress/backend.yaml
kubectl apply -f 03-ingress/host-ingress.yaml
kubectl rollout status deployment/campus-frontend
kubectl rollout status deployment/campus-backend

MINIKUBE_IP=$(minikube ip)
if ! grep -q 'portal.campus.local' /etc/hosts; then
  echo "${MINIKUBE_IP}  portal.campus.local api.campus.local" | sudo tee -a /etc/hosts
fi

kubectl describe ingress campus-host-ingress
curl -s -H 'Host: portal.campus.local' "http://${MINIKUBE_IP}/" | grep -i '<title>'
curl -s -H 'Host: api.campus.local' "http://${MINIKUBE_IP}/"
```

**Screenshot:** `screenshots/11-host-routing.png`

---

## Task 12 — Hybrid Host + Path Routing

`03-ingress/ingress-tls.yaml` is the assignment-aligned hybrid manifest: two virtual hosts, path routing, and a TLS binding that is activated after Task 13 creates the certificate Secret.

Before the TLS Secret exists, use the non-TLS hybrid manifest for plain HTTP inspection:

```bash
kubectl apply -f 03-ingress/hybrid-ingress.yaml
kubectl get ingress campus-hybrid-ingress
kubectl describe ingress campus-hybrid-ingress
```

After Task 13 creates `campus-tls-cert`, apply the assignment-aligned combined manifest:

```bash
kubectl apply -f 03-ingress/ingress-tls.yaml
kubectl get ingress campus-ingress-tls
kubectl describe ingress campus-ingress-tls
```

**Screenshot:** `screenshots/12-hybrid-routing.png`

---

## Task 13 — TLS / HTTPS Termination & Secret Binding

Private key/certificate files are generated locally and ignored by Git.

```bash
cd 03-ingress
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj '/CN=campus.local/O=CampusDevOps'

kubectl create secret tls campus-tls-cert --cert=tls.crt --key=tls.key \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl get secret campus-tls-cert

kubectl apply -f frontend.yaml
kubectl apply -f backend.yaml
kubectl apply -f ingress-tls.yaml
kubectl get ingress campus-ingress-tls

INGRESS_IP=$(minikube ip)
curl -k -v --resolve portal.campus.local:443:${INGRESS_IP} \
  https://portal.campus.local/ 2>&1 | grep -E 'Server certificate|subject:|HTTP/|SSL connection'
cd ..
```

**Screenshot:** `screenshots/13-tls-ingress.png`

---

## Task 14 — End-to-End Multi-Tier Integration & Automation

The final manifests intentionally use multi-document YAML (`---`) so each application file can colocate its Deployment and Service.

```bash
bash 04-full-demo/run-demo.sh

kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
kubectl describe ingress yatri-ingress

bash 04-full-demo/cleanup.sh

kubectl get ingress yatri-ingress || echo 'Ingress deleted'
kubectl get deployment yatri-backend yatri-frontend || echo 'Deployments deleted'
```

**Screenshot:** `screenshots/14-full-demo.png`

---

## Cleanup notes

The lab cleanup script deletes only the `yatri-*` resources created by the full demo; it does not delete all resources from the cluster and does not disable Minikube globally. Remove temporary `/etc/hosts` entries and the local `campus-tls-cert` Secret when the corresponding lab is finished if they are no longer needed.

See [`screenshots/README.md`](screenshots/README.md) for the exact evidence checklist. No example output from the assignment document or another student's repository counts as runtime evidence.
