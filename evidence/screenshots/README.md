# Screenshot Checklist

Existing Sections 1–7 retain the original screenshot filenames. Commands below use the repaired numbered paths.

## Sections 1–4

- `01-linux-links.png` — run `./01-linux-fundamentals/link-practice.sh` and show inode/link behavior plus the final PASS.
- `02-shell-script.png` — run `printf 'screenshot-output\n' | ./02-shell-scripting/system-info.sh` and show the system-information output.
- `03-networking.png` — run `./03-networking-fundamentals/collect-network-info.sh` and show interface/route/socket output.
- `04-git-commit-a.png` and `05-git-cherry-pick.png` — run `./04-git-github/git-practice-demo.sh` and capture the two required Git states.

## Section 5 — Docker Fundamentals

Start services from `05-docker-fundamentals/` and capture:

- `06-nodejs-browser.png` — `http://localhost:3000/`
- `07-python-browser.png` — `http://localhost:5000/`
- `08-java-browser.png` — `http://localhost:8081/`
- `09-apache-browser.png` — `http://localhost:8082/`
- `10-react-browser.png` — `http://localhost:8083/`
- `11-nginx-browser.png` — `http://localhost:8084/`

## Section 6 — Dockerfiles & Images

- `12-multistage-browser.png` — build from `06-dockerfiles-images/multistage-app/`, run on host port 8080, and capture the rendered response.
- `13-multistage-docker-ps.png` — capture the running `devops-multistage` row and its port mapping.

## Section 7 — Docker Networking & Volumes

- `14-docker-networks.png` — show the three `devops_hw_*` bridge networks.
- `15-network-connectivity.png` — run `./07-docker-networking-volumes/container-networking/verify.sh` and show allowed/denied connectivity.
- `16-host-network.png` — native-Linux host-network proof if your platform supports the assignment behavior.
- `17-bind-mount-before.png` and `18-bind-mount-after.png` — capture the same bind-mounted container before/after the host edit.

## Sections 8–11 — Kubernetes

Each Kubernetes section contains its own exact task-by-task screenshot filenames and commands in its README. Save those images in that section's `screenshots/` directory. Do not substitute source-code screenshots for runtime proof.
