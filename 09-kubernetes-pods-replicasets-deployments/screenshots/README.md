# Lecture 10 Screenshot Checklist

Capture these from the real Minikube run:

1. `01-cluster-health.png` — `kubectl cluster-info` plus `kubectl get nodes -o wide` with Ready node(s).
2. `02-nginx-pod-operations.png` — `nginx-pod` Running in `-o wide`, followed by container logs.
3. `03-imagepullbackoff-error.png` — `ErrImagePull`/`ImagePullBackOff` plus failed-pull events.
4. `04-pod-lifecycle-stages.png` — watch history showing `ContainerCreating` → `Running` → `Completed` for `hello-pod`.
5. `05-lifecycle-probes-crashloop.png` — Pending/FailedScheduling, CrashLoopBackOff and a liveness restart count.
6. `05-lifecycle-init-multicontainer.png` — init-container evidence plus `lifecycle-multi-container` at `2/2` and sidecar logs.
7. `06-controllers-rs-statefulset.png` — ReplicaSet replacement and StatefulSet ordinal names/PVCs.
8. `07-daemonset-verification.png` — DaemonSet desired/current count and one agent Pod per eligible node.
9. `08-rolling-update-and-rollback.png` — rollout to v2, rollout history and `rollout undo`.
10. `09-troubleshooting-drills.png` — stalled invalid-image rollout and selector-mismatch validation error.
11. `11-blue-green-cutover.png` — Blue response, selector switch to Green and Green response.
12. `12-canary-traffic-split.png` — 9 stable/1 canary Pods plus curl responses containing both versions.
13. `13-recreate-downtime-outage.png` — v1 responses, a visible outage window and v2 recovery.

Do not substitute source-code screenshots or another student's output for runtime evidence.
