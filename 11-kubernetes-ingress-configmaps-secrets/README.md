# 11 — Kubernetes Ingress, ConfigMaps & Secrets

This section implements the Lecture 12 ConfigMap, Secret, Ingress, TLS, and end-to-end microservice labs.

## 1. ConfigMap

```bash
kubectl apply -f 01-configmap/app-config.yaml
kubectl get configmap yatri-app-config
kubectl describe configmap yatri-app-config
kubectl get configmap yatri-app-config -o jsonpath='{.data.ENVIRONMENT}' && echo
```

The ConfigMap contains only non-sensitive values such as environment, logging level, application port, currency, and booking limits.

## 2. ConfigMap live update behavior

Environment variables sourced from a ConfigMap are read when a Pod starts. Updating the ConfigMap does not mutate already-running container environment variables.

```bash
kubectl patch configmap yatri-app-config --type merge -p '{"data":{"ENVIRONMENT":"staging"}}'
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT
kubectl rollout restart deployment/yatri-backend
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep ENVIRONMENT
```

## 3. Secrets and Base64

`02-secret/db-secret.yaml` uses lab-only credentials. Base64 is an encoding mechanism, **not encryption**.

```bash
kubectl apply -f 02-secret/db-secret.yaml
kubectl describe secret yatri-db-secret
kubectl get secret yatri-db-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode && echo
```

## 4. Trailing newline gotcha

```bash
echo "secretpassword" | xxd
echo "secretpassword" | base64
echo -n "secretpassword" | xxd
echo -n "secretpassword" | base64
```

The normal `echo` form appends a newline byte; `echo -n` encodes the intended password bytes only.

## 5. Enterprise secret management

Committing Base64 secrets to Git is unsafe because Git history is durable, Base64 is reversible, access may be broader than intended, and rotation is difficult. Production systems commonly retrieve secrets from stores such as AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault and synchronize/inject them through an External Secrets Operator, Vault injector, or CI/CD secret mechanism.

```text
External secret store
        |
        v
Secrets operator / CI-CD deployment identity
        |
        v
Kubernetes Secret
        |
        v
Pod env / volume
```

## 6. Combined ConfigMap + Secret injection

`04-full-demo/backend.yaml` consumes the ConfigMap using `envFrom` and maps the database credentials from Secret keys.

```bash
kubectl apply -f 04-full-demo/configmap.yaml
kubectl apply -f 04-full-demo/secret.yaml
kubectl apply -f 04-full-demo/backend.yaml
kubectl rollout status deployment/yatri-backend
kubectl exec deploy/yatri-backend -- env | grep -E 'ENVIRONMENT|LOG_LEVEL|POSTGRES|DEFAULT_CURRENCY'
```

## 7. Ingress resource vs controller

| Ingress resource | Ingress controller |
|---|---|
| Declarative Layer-7 routing rules | Active reverse proxy/controller implementation |
| Stores hosts, paths, TLS references and Services | Watches Kubernetes API and configures NGINX/Traefik/etc. |
| Does not route traffic by itself | Performs the actual request routing |

## 8. Enable NGINX Ingress on Minikube

```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
```

## 9. Local host mapping

```bash
MINIKUBE_IP=$(minikube ip)
echo "$MINIKUBE_IP yatri.local" | sudo tee -a /etc/hosts
grep yatri.local /etc/hosts
```

Avoid adding duplicate lines. Remove temporary lab host mappings after the assignment if no longer needed.

## 10. Path-based routing

`04-full-demo/ingress.yaml` routes `yatri.local/` to the frontend and `yatri.local/api` to the backend.

## 11. Host-based routing

`03-ingress/host-ingress.yaml` uses separate virtual hosts for `portal.campus.local` and `api.campus.local`.

## 12. Hybrid routing

`03-ingress/hybrid-ingress.yaml` demonstrates multiple hosts combined with multiple paths.

## 13. TLS termination

Generate the certificate locally; private keys are ignored by Git.

```bash
cd 03-ingress
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj '/CN=campus.local/O=CampusDevOps'
kubectl create secret tls campus-tls-cert --cert=tls.crt --key=tls.key
kubectl apply -f tls-ingress.yaml
INGRESS_IP=$(minikube ip)
curl -k --resolve portal.campus.local:443:${INGRESS_IP} https://portal.campus.local/
```

## 14. Full demo automation

```bash
bash 04-full-demo/run-demo.sh
kubectl get configmap,secret,ingress,deploy,svc,pods -l app=yatri-app
bash 04-full-demo/cleanup.sh
```

The scripts only create/delete resources belonging to this lab. See `screenshots/README.md` for the evidence checklist.
