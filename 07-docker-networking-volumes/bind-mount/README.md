# Nginx Bind-Mount Exercise

The local `site/` directory is mounted read-only inside Nginx at `/usr/share/nginx/html`. The `:ro` prevents container-side writes, but the host can still edit its own source file. Nginx observes that change immediately because it reads the same mounted file; no container restart is needed.

```bash
./run.sh
curl -fsS http://localhost:8085/
./verify.sh
docker rm -f devops-hw-bind-mount
```

Override the host port if needed:

```bash
BIND_MOUNT_PORT=18085 ./run.sh
BIND_MOUNT_PORT=18085 ./verify.sh
```

`verify.sh` confirms the initial `Hello students`, edits the host file to a second message, curls the still-running container, and restores the original tracked file with a trap even if verification fails.
