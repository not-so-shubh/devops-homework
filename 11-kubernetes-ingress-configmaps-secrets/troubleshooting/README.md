# Session 12 Troubleshooting Exercise

The broken Deployment uses the wrong ConfigMap key and the Ingress routes to a nonexistent Service port. This produces a configuration/startup failure and an HTTP 503/routing failure.

## Identify and investigate

```bash
kubectl apply -f broken.yaml
kubectl get pod,service,ingress -n ingress-lab -o wide
kubectl describe pod -n ingress-lab -l app=session12-trouble
kubectl describe ingress session12-trouble -n ingress-lab
kubectl get endpointslice -n ingress-lab -l kubernetes.io/service-name=session12-trouble
kubectl logs -n ingress-lab -l app=session12-trouble
kubectl events -n ingress-lab --sort-by=.metadata.creationTimestamp
```

## Root cause and fix

- The Pod requests ConfigMap key `APP_MODE`, but the broken ConfigMap supplies `MODE`.
- The Ingress refers to Service port 8080, while the Service exposes port 80.

```bash
kubectl delete -f broken.yaml --ignore-not-found
kubectl apply -f fixed.yaml
kubectl wait --for=condition=available deployment/session12-trouble -n ingress-lab --timeout=180s
kubectl get pod,service,endpointslice,ingress -n ingress-lab -o wide
curl -H 'Host: trouble.local' "http://$(minikube ip)/"
```

Capture before/after output and explain both root causes; merely restarting the Pod does not correct either configuration error.
