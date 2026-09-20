# Apache with Host Networking

The official Apache HTTP Server image is `httpd`. On a native Linux host, `--network host` places the container in the host's network namespace, so Apache's port 80 is directly the host's port 80 and no `-p` mapping is used.

## Check for conflicts first

```bash
sudo ss -ltnp '( sport = :80 )'
```

If a process is already listening, do not stop it blindly. Choose a different exercise or explicitly coordinate the port owner. Apache's image listens on port 80, so this exact host-mode task cannot coexist with another host listener there.

## Linux commands

```bash
docker pull httpd:2.4-alpine
docker run --rm --name apache-host --network host httpd:2.4-alpine
```

From another terminal:

```bash
curl -fsS http://localhost/
```

Stop the foreground container with Ctrl+C. If it was started with `-d`, remove only this named container with `docker rm -f apache-host`.

## Docker Desktop note

Docker Desktop runs containers inside a Linux VM. Host-network support on macOS/Windows depends on the Docker Desktop version and settings and is not historically identical to native Linux. Recent versions may require **Settings → Resources → Network → Enable host networking**. If that option is unavailable or disabled, perform this assignment step on a Linux VM. Do not add `-p 80:80` and call it the same test; that verifies port publishing, not host mode.

The global verifier does not automatically occupy host port 80.

For a guarded check that refuses to start when port 80 is occupied and cleans up its own container, run:

```bash
./verify.sh
```
