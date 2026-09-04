# Final Repository Audit

Status in this table reflects verification performed in the current environment. `PASS` means the implementation or command was actually checked. `BLOCKED` means implementation exists but its required runtime was unavailable. `MANUAL ACTION REQUIRED` identifies evidence or platform actions that cannot be responsibly fabricated.

| Section | Requirement | Implementation | Verification | Status |
|---|---|---|---|---|
| Linux | Explain symbolic links, inode behavior, cross-filesystem/directory support, dangling links, and commands | `linux-fundamentals/README.md` | Documentation review; link demo | PASS |
| Linux | Explain hard links, same inode, filesystem/directory limits, and unlink survival | `linux-fundamentals/README.md` | Documentation review; link demo | PASS |
| Linux | Safe create/read/delete link practice using `ls -li`, `stat`, `readlink`, `unlink`, and `rm` | `link-practice.sh` | Syntax check and live temporary-directory run | PASS |
| Linux | Interview-ready link comparison | `linux-fundamentals/README.md` | Documentation review | PASS |
| Linux | Accurate `adduser` versus `useradd` notes and Ubuntu practice commands | `user-practice.md` | Documentation review; no host users modified | PASS |
| Linux | `journalctl` boot, follow, priority, time, unit, and diagnostic commands | `journalctl-practice.md` | Documentation review; systemd runtime is host-dependent | PASS |
| Linux | Categorized command cheat sheet with purpose, syntax, and explanation | `linux-command-cheatsheet.md` | Documentation review | PASS |
| Shell | Date, host, user, disk, processes, variables, `read -p`, `mkdir`, `touch`, and `>` | `system-info.sh` | Syntax check and piped-input run | PASS |
| Shell | Script explanation and expected format | `shell-scripting/README.md` | Documentation review | PASS |
| Networking | Inspect/reference instructor `devops-hero` URL | Root/network READMEs record that no URL existed in supplied project | Repository-wide URL search | PASS |
| Networking | Command guide for host/interface/address/route/neighbors/DNS/ports/tools/config files | `networking-commands.md` | Documentation review | PASS |
| Networking | Define core networking concepts | `networking/README.md` | Documentation review | PASS |
| Networking | Optional-tool-aware information collection | `collect-network-info.sh` | Syntax check and local run | PASS |
| Git | Explain `commit -m` versus `commit -a -m`, including untracked-file limitation | `commit-a-vs-commit-m.md` | Documentation review and live demo | PASS |
| Git | Disposable `commit -a` demonstration | `git-practice-demo.sh` | Temporary repository run | PASS |
| Git | Three main commits, feature branch, two feature commits, selected cherry-pick, log, content/status proof | `git-practice-demo.sh` | Temporary repository run | PASS |
| Git | Explain hashes, syntax, conflicts, continue, and abort | `cherry-pick.md` | Documentation review | PASS |
| Docker Fundamentals | Node/Express page and Dockerfile with exact message | `nodejs-app/` | Image built, container ran, curl assertion passed | PASS |
| Docker Fundamentals | Python/Flask page binding `0.0.0.0` with exact message | `python-app/` | Image built, container ran, curl assertion passed | PASS |
| Docker Fundamentals | Java HTTP server and build/runtime image with exact message | `java-app/` | Image built, container ran, curl assertion passed | PASS |
| Docker Fundamentals | Official Apache `httpd` image and exact message | `Apache-app/` | Image built, container ran, curl assertion passed | PASS |
| Docker Fundamentals | React/Vite multi-stage production image and exact message | `React-app/` | Production build and image succeeded; container curl passed | PASS |
| Docker Fundamentals | Official Nginx image and exact message | `nginx-app/` | Image built, container ran, curl assertion passed | PASS |
| Docker Fundamentals | Compose all six apps on unique configurable ports | `docker-compose.yml` | `docker compose config`, build/start, six curls, and `ps` | PASS |
| Multi-stage | Inspect/reference instructor repository URL | README records that no URL existed in supplied project | Repository-wide URL search | PASS |
| Multi-stage | Genuine multi-stage app, port 8080, exact required message | `multistage-app/` | Image built, ran on host port 8080, curl and `docker ps` captured | PASS |
| Multi-stage | Submission name/enrollment, commands, curl and `docker ps` evidence/checklist | `submission.md` | Documentation review | PASS |
| Multi-stage | Reference Node, Python, and Java deployments | `docker-multistage/README.md` | All three referenced images built and returned expected text | PASS |
| Docker Network | Frontend/backend/MySQL across three networks with backend on two | `container-networking/docker-compose.yml` | Compose start and three network inspections | PASS |
| Docker Network | DNS-based frontend-to-backend, backend-to-database, and isolation verification | `container-networking/verify.sh` | Both allowed paths and denied frontend/database path verified | PASS |
| Docker Network | MySQL health check and documented demo-only credentials | `container-networking/docker-compose.yml` and README | Static review | PASS |
| Docker Network | Apache on host network plus Linux/Desktop differences and port warning | `host-network/README.md` and guarded verifier | Port was free and `host` mode confirmed, but Docker Desktop did not expose port 80; enable feature or use Linux | MANUAL ACTION REQUIRED |
| Docker Volume | Read-only Nginx bind mount, before/after change without restart, and restore | `bind-mount/` | Initial/updated curls passed without restart; tracked source restored | PASS |
| Docker Network | Overlay, Swarm, VXLAN, discovery, ingress/user-defined, prerequisites, encryption, and commands | `overlay-network.md` | Documentation review; Swarm state intentionally unchanged | PASS |
| Evidence | Real command outputs only | `evidence/command-outputs/` | Files generated from live commands | PASS |
| Evidence | Exact 18-item screenshot checklist | `evidence/screenshots/README.md` | No screenshots fabricated | MANUAL ACTION REQUIRED |
| Global | Required-tree, Bash, demos, Docker, curl assertions, cleanup, and summary verifier | `scripts/verify-all.sh` | Live run: 12 PASS, 0 FAIL, 0 BLOCKED/SKIP | PASS |
| Global | Scoped cleanup only; no global prune | `scripts/cleanup.sh` | Syntax/static review | PASS |
| Quality | Ignore dependencies, builds, environments, data, IDE files, secrets | `.gitignore` and `.dockerignore` files | Repository audit | PASS |
| Quality | No nested tracked `.git`, fake outputs, secrets, or unnecessary artifacts | Repository audit | `find`, `git diff --check`, and secret-pattern review | PASS |

## Manual gates before submission

1. Confirm that the name and enrollment inferred from Git configuration are the intended submission identity.
2. Capture genuine screenshots using `evidence/screenshots/README.md`.
3. Enable Docker Desktop host networking or run `docker-network/host-network/verify.sh` on native Linux, then capture its successful port-80 proof.
