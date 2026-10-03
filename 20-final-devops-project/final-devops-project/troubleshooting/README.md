# Final Troubleshooting Challenge

The broken manifest intentionally combines three faults: a nonexistent image tag, a Service selector mismatch and a missing ConfigMap reference. Do not inspect the fixed file until the diagnosis is recorded.

## Required investigation

```bash
kubectl apply -f broken.yaml
kubectl get all -n final-troubleshooting -o wide
kubectl describe pod -n final-troubleshooting -l app=trouble-app
kubectl logs -n final-troubleshooting -l app=trouble-app --all-containers --previous
kubectl get endpoints trouble-app -n final-troubleshooting
kubectl events -n final-troubleshooting --sort-by=.metadata.creationTimestamp
kubectl explain deployment.spec.template.spec.containers.image
```

## Root causes

1. `nginx:this-tag-does-not-exist` causes `ErrImagePull`/`ImagePullBackOff`.
2. Service selector `app: wrong-app` produces no endpoints.
3. Environment injection references ConfigMap `missing-config`, preventing healthy startup after the image is corrected.

## Repair and verification

```bash
kubectl delete namespace final-troubleshooting
kubectl apply -f fixed.yaml
kubectl wait --for=condition=available deployment/trouble-app -n final-troubleshooting --timeout=180s
kubectl get deployment,pod,service,endpoints -n final-troubleshooting -o wide
kubectl run curl-check -n final-troubleshooting --rm -i --restart=Never --image=curlimages/curl:8.12.1 -- \
  curl -fsS http://trouble-app/
```

Evidence must show broken state, Events, root-cause explanation, corrected state and successful Service request.
