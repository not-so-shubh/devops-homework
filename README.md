# DevOps Homework

## Student Information

- **Name:** Shubh Jaiswal
- **Enrollment Number:** 24BCS10601

## Overview

This repository contains the cumulative DevOps homework submission. Sections 1–7 cover Linux, shell scripting, networking, Git, Docker, images, networking, and volumes. Sections 8–11 extend the same repository with Kubernetes fundamentals, workload controllers, Services/networking, ConfigMaps, Secrets, and Ingress.

The repository is intentionally organized as one numbered sequence so every lecture can be reviewed from a single submission URL. Runtime evidence is kept separate from source files: existing Docker evidence is preserved under `evidence/`, while Kubernetes screenshots must be captured from the real Minikube cluster and saved in the relevant section's `screenshots/` directory.

## Repository Structure

```text
.
├── 01-linux-fundamentals/
├── 02-shell-scripting/
├── 03-networking-fundamentals/
├── 04-git-github/
├── 05-docker-fundamentals/
├── 06-dockerfiles-images/
├── 07-docker-networking-volumes/
├── 08-kubernetes-fundamentals/
├── 09-kubernetes-pods-replicasets-deployments/
├── 10-kubernetes-networking-services/
├── 11-kubernetes-ingress-configmaps-secrets/
├── evidence/
├── scripts/
├── AUDIT.md
└── README.md
```

## Sections

| # | Section | Main topics |
|---:|---|---|
| 1 | [Linux Fundamentals](01-linux-fundamentals/) | Links, users, `journalctl`, Linux command practice |
| 2 | [Shell Scripting](02-shell-scripting/) | Variables, input, files, redirection, process reporting |
| 3 | [Networking Fundamentals](03-networking-fundamentals/) | Interfaces, routes, DNS, sockets, troubleshooting commands |
| 4 | [Git & GitHub](04-git-github/) | `commit -a`, branches, cherry-pick workflow |
| 5 | [Docker Fundamentals](05-docker-fundamentals/) | Node, Python, Java, Apache, React, and Nginx containers |
| 6 | [Dockerfiles & Images](06-dockerfiles-images/) | Multi-stage image builds and deployment verification |
| 7 | [Docker Networking & Volumes](07-docker-networking-volumes/) | Bridge/host/overlay networking and bind mounts |
| 8 | [Kubernetes Fundamentals](08-kubernetes-fundamentals/) | Minikube lifecycle and Kubernetes architecture |
| 9 | [Pods, ReplicaSets & Deployments](09-kubernetes-pods-replicasets-deployments/) | Pod lifecycle, probes, controllers, rollout strategies, troubleshooting |
| 10 | [Kubernetes Networking & Services](10-kubernetes-networking-services/) | ClusterIP, NodePort, LoadBalancer, ExternalName, headless Services, DNS |
| 11 | [Ingress, ConfigMaps & Secrets](11-kubernetes-ingress-configmaps-secrets/) | Configuration, Secrets, Ingress routing, TLS, full-stack demo |

## Verification

Run the repository-level static/syntax verifier from the repository root:

```bash
chmod +x scripts/verify-all.sh scripts/cleanup.sh
./scripts/verify-all.sh
```

The verifier checks the required 1–11 structure, Bash syntax, the safe Linux/Git demonstrations, Docker Compose configuration when Docker is available, and Kubernetes YAML syntax when a local YAML parser is available. It does **not** pretend that Minikube labs ran when they did not.

For Kubernetes runtime verification, start Minikube and follow the commands in Sections 8–11. Capture the required screenshots only from your own terminal/cluster.

## Evidence Policy

- Existing command output under `evidence/command-outputs/` is historical runtime evidence from the earlier Sections 1–7 verification.
- Never paste sample output into the repository and present it as captured runtime evidence.
- Kubernetes screenshot placeholders/checklists are provided, but screenshots must be generated on the real machine.
- Credentials used in Kubernetes manifests are deliberately lab-only placeholders and must never be replaced with real credentials.

## Platform Notes

The repository is usable on macOS with Docker Desktop and Minikube. A few host-networking behaviors differ from native Linux. In particular, Minikube's Docker driver on macOS may require `minikube service ... --url`, `minikube tunnel`, or Ingress-specific routing instead of assuming that a NodePort is reachable directly through the Minikube container IP.

## Submission Checklist

- [x] Sections 1–7 retained and normalized into numbered folders.
- [x] Root documentation and verifier updated for the 1–11 structure.
- [x] Kubernetes manifests and task documentation prepared for Sections 8–11.
- [ ] Run Sections 8–11 on the local Minikube cluster.
- [ ] Capture every required Kubernetes screenshot from genuine command output.
- [ ] Re-run `./scripts/verify-all.sh` after all screenshots are added.
- [ ] Confirm the student name and enrollment number before final submission.
