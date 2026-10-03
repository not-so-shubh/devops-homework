# Session 13 - Kubernetes Storage, HPA and Probes

**Student:** Shubh Jaiswal
**Enrollment:** 24BCS10601

This lab demonstrates ephemeral and persistent storage, health probes, resource requests, metrics-based autoscaling, and a small production-style application. All resources use the `session13` namespace so the exercise is isolated and removable.

## 1. Kubernetes volumes

The detailed comparison and practical examples are in [`01-kubernetes-volumes/README.md`](01-kubernetes-volumes/README.md).

```bash
kubectl create namespace session13
kubectl apply -f 01-kubernetes-volumes/emptydir.yaml
kubectl apply -f 01-kubernetes-volumes/hostpath.yaml
kubectl apply -f 01-kubernetes-volumes/pv-pvc.yaml
kubectl apply -f 01-kubernetes-volumes/storageclass-pvc.yaml
kubectl get pod,pv,pvc -n session13 -o wide
kubectl describe pvc -n session13
```

## 2. HPA hands-on

Enable metrics, deploy the workload and generate load:

```bash
minikube addons enable metrics-server
kubectl apply -f 02-hpa/
kubectl wait --for=condition=available deployment/hpa-web -n session13 --timeout=180s
kubectl get hpa -n session13
kubectl get pods -n session13
kubectl top pods -n session13
kubectl describe hpa hpa-web -n session13
kubectl logs -n session13 job/load-generator --follow
kubectl get hpa,pods -n session13 -w
```

The Deployment requests `20m` CPU and the HPA targets 50% utilization. The load generator repeatedly requests the Service, causing the HPA to increase replicas. The Deployment also includes startup, readiness and liveness probes so traffic reaches only healthy Pods and failed processes are restarted.

## 3. Mini-project

The mini-project combines a ConfigMap, Secret, persistent volume claim, Deployment, Service, Ingress, HPA and PodDisruptionBudget:

```bash
kubectl apply -f 03-mini-project/
kubectl wait --for=condition=available deployment/session13-project -n session13 --timeout=180s
kubectl get all,pvc,configmap,secret,ingress,pdb -n session13
kubectl port-forward -n session13 service/session13-project 8093:80
curl http://127.0.0.1:8093/
```

The Secret contains lab-only values. Production credentials should come from an external secret manager and must not be committed.

## Cleanup

```bash
kubectl delete namespace session13
kubectl delete pv session13-manual-pv --ignore-not-found
```

## Evidence

Genuine command transcripts belong in `evidence/`; the exact capture checklist is in [`evidence/README.md`](evidence/README.md).
