# DevOps Homework

## Student Information

- **Name:** Shubh Jaiswal
- **Enrollment Number:** 24BCS10601

## Overview

This repository is a reproducible submission for the DevOps Homework assignment. It combines concept notes with safe practice scripts, six containerized web applications, a genuine multi-stage build, Docker networking and volume exercises, real command-output evidence, and an automated verifier.

Source assignment: [DevOps Homework (Google Docs)](https://docs.google.com/document/d/1cjXFYf2Thm8cBEN-0C48B-v02cj3jGLd47lcO18prHE/edit?tab=t.0)

The supplied project directory was empty and was not a Git repository. No instructor-provided `devops-hero` or multi-stage repository URL was present in the supplied files, so the networking and multi-stage exercises are complete local equivalents rather than invented external references.

## Repository Structure

```text
.
├── linux-fundamentals/    # Links, users, journalctl, command reference
├── shell-scripting/       # Interactive system-information script
├── networking/            # Networking notes and portable collector
├── git-github/            # Disposable commit/cherry-pick demonstration
├── docker-fundamentals/   # Six Hello World applications and Compose
├── docker-multistage/     # Genuine Go build/runtime multi-stage image
├── docker-network/        # Networks, host mode, bind mounts, overlay notes
├── evidence/              # Genuine command outputs and screenshot checklist
├── scripts/               # Full verification and scoped cleanup
└── AUDIT.md               # Requirement-by-requirement submission audit
```

## Prerequisites

- Ubuntu or another Linux distribution with Bash, Git, and `curl`
- Docker Engine and Docker Compose v2 for container exercises
- Common Linux networking tools (`ip`, `ss`, `ping`, `dig`) for full networking output

Docker Desktop on macOS can run the build, Compose, bridge-network, and bind-mount exercises. Linux-only commands such as `journalctl`, `ip`, and host networking behave differently or may be unavailable on macOS; those differences are called out in the relevant notes.

## Sections

| # | Objective | Folder | Completion |
|---:|---|---|---|
| 1 | Linux links, users, logs, and command fluency | [Linux Fundamentals](linux-fundamentals/) | Implemented; Linux-only commands documented |
| 2 | Bash variables, input, files, redirection, and process reporting | [Shell Scripting](shell-scripting/) | Implemented and locally runnable |
| 3 | Interfaces, addresses, routes, DNS, ports, and sockets | [Networking](networking/) | Implemented; output depends on host tools |
| 4 | `commit -a` and cherry-pick workflow | [Git/GitHub](git-github/) | Implemented in a disposable repository |
| 5 | Six containerized Hello World web applications | [Docker Fundamentals](docker-fundamentals/) | Implemented and runtime verified |
| 6 | Multi-stage image build and deployment | [Docker Multi-Stage](docker-multistage/) | Implemented and runtime verified on port 8080 |
| 7 | Docker networks, host mode, bind mounts, and overlay | [Docker Networking](docker-network/) | Bridge/bind labs passed; Desktop host mode needs enablement |

## Quick Start

```bash
chmod +x scripts/verify-all.sh scripts/cleanup.sh
./scripts/verify-all.sh
```

Run all six basic web applications with their default host ports:

```bash
cd docker-fundamentals
docker compose up --build -d
docker compose ps
```

The default endpoints are Node `3000`, Python `5000`, Java `8081`, Apache `8082`, React `8083`, and Nginx `8084` on `localhost`. Each host port can be overridden with the environment variables documented in [Docker Fundamentals](docker-fundamentals/README.md).

## Verification

`scripts/verify-all.sh` checks required files, validates every Bash script, runs the Linux, shell, and Git demonstrations, and—when a working Docker daemon is available—builds, starts, curls, and cleans up the Docker exercises. Its summary distinguishes `PASS`, `FAIL`, and `BLOCKED/SKIP`; Docker is never reported as passing if its daemon cannot be reached.

Generated command evidence is indexed in [evidence/README.md](evidence/README.md). The detailed compliance result is in [AUDIT.md](AUDIT.md).

## Docker Cleanup

Stop only resources created by this project:

```bash
./scripts/cleanup.sh
```

The script deliberately does not run global prune commands and does not remove unrelated containers, networks, volumes, or images.

## Evidence

Real textual outputs produced in this environment are stored in [evidence/command-outputs](evidence/command-outputs/). Machine-specific values naturally differ. Do not treat example command blocks in documentation as captured evidence.

## Screenshot Checklist

Screenshots must show real running commands and applications. Follow the exact capture instructions in [evidence/screenshots/README.md](evidence/screenshots/README.md); no synthetic screenshots are included.

## Key Concepts Learned

- Names, inodes, and the failure behavior of symbolic versus hard links
- Safe Bash input handling, quoting, file creation, and output redirection
- How interfaces, routes, DNS, ports, sockets, and ARP/neighbor tables fit together
- The precise staging behavior of `git commit -a` and selective history transfer with cherry-pick
- Small, non-root-friendly application images and production static serving
- Build-stage separation, container DNS, network segmentation, and persistent host-mounted content

## Interview Questions / Revision Notes

1. Why can a hard link survive removal of another filename while a symbolic link becomes dangling?
2. Why does `git commit -a` ignore a brand-new file?
3. Why should application containers bind to `0.0.0.0` rather than only `127.0.0.1`?
4. How does a multi-stage Dockerfile reduce runtime image contents and attack surface?
5. Why can the frontend resolve `backend` but not `database` in the segmented Compose topology?
6. When is an overlay network required instead of a bridge network?

## Submission Checklist

- [x] All seven assignment sections implemented
- [x] Safe practice and verification scripts included
- [x] Exact Hello World strings implemented
- [x] No secrets, dependency directories, container data, or nested Git repositories included
- [x] Requirement audit included
- [ ] Confirm that the name/enrollment detected from local Git configuration are the intended submission identity
- [ ] Capture the required screenshots using the checklist
- [ ] Review environment-specific `BLOCKED` items in `AUDIT.md` and evidence
