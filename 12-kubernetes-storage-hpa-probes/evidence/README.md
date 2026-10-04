# Session 13 Evidence Checklist

Capture genuine command output for:

1. `kubectl get pod,pv,pvc -n session13 -o wide` and reads from each volume.
2. `kubectl get hpa,pods -n session13` before load.
3. `kubectl top pods -n session13` and `kubectl describe hpa` during load.
4. Increased replica count during the load-generator run.
5. Mini-project resources and a successful HTTP response.

The checked-in evidence was produced by the local Minikube run; no sample output is represented as a real execution.

- [Volumes, persistence, probes and mini-project](01-volumes-and-project.png)
- [HPA load and replica scaling](02-hpa-scaling.png)
