# Repository Audit

This audit separates **implementation** from **runtime evidence**. A file existing in Git is not proof that a Kubernetes command was executed. Existing Sections 1–7 had real verification evidence before this structural refactor; Sections 8–11 are prepared as runnable labs and still require genuine Minikube execution/screenshots on the student's machine.

| Section | Implementation state | Runtime evidence state |
|---|---|---|
| 01 — Linux Fundamentals | Complete | Existing evidence retained; rerun after refactor recommended |
| 02 — Shell Scripting | Complete | Existing evidence retained; rerun after refactor recommended |
| 03 — Networking Fundamentals | Complete | Existing evidence retained; host-dependent values vary |
| 04 — Git & GitHub | Complete | Existing disposable-repo evidence retained |
| 05 — Docker Fundamentals | Complete | Existing build/curl/browser evidence retained |
| 06 — Dockerfiles & Images | Complete | Existing multi-stage evidence retained |
| 07 — Docker Networking & Volumes | Complete | Bridge/bind-mount evidence retained; host networking remains platform-dependent |
| 08 — Kubernetes Fundamentals | Manifests/docs/checklist complete | **Manual runtime evidence required** |
| 09 — Pods, ReplicaSets & Deployments | Manifests/docs/checklist complete | **Manual runtime evidence required** |
| 10 — Kubernetes Networking & Services | Manifests/docs/checklist complete | **Manual runtime evidence required** |
| 11 — Ingress, ConfigMaps & Secrets | Manifests/scripts/docs/checklist complete | **Manual runtime evidence required** |

## Quality controls

- Numbered top-level folders now match the cumulative course sequence.
- No real credentials are stored in the repository; Kubernetes credentials are explicit lab placeholders.
- TLS private keys/certificates, `.env` files, build artifacts, dependency folders, and local kubeconfig files are ignored.
- The root verifier never reports Kubernetes runtime success merely because YAML files exist.
- Intentionally broken manifests used for troubleshooting are clearly identified and excluded from semantic validation expectations.
- Cleanup scripts are scoped to homework resources; no global Docker/Kubernetes prune is used.

## Manual gates before final submission

1. Run `./scripts/verify-all.sh` after pulling the repaired structure.
2. Start Minikube and execute every task in Sections 8–11 in order.
3. Save genuine screenshots in each section's `screenshots/` folder using the filenames listed in its README.
4. Do not reuse another student's screenshots, terminal output, IP addresses, pod names, timestamps, or cluster versions.
5. Review screenshots for accidental secrets or unrelated terminal history.
6. Confirm the student identity shown in the root README.
