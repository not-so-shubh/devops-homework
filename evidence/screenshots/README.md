# Genuine Screenshot Checklist

Do not screenshot source code and label it runtime proof. Each capture below must show the real command/page/state described. Keep tokens, unrelated terminal history, personal paths, and private network details out of frame where practical.

## 01 — Linux links

- File: `01-linux-links.png`
- Run: `./linux-fundamentals/link-practice.sh`
- Visible state: the `ls -li` rows, hard link sharing the original inode, and `EXPECTED` dangling-symbolic-link result.
- Success: final `PASS` is visible.

## 02 — Shell script

- File: `02-shell-script.png`
- Run: `printf 'screenshot-output\n' | ./shell-scripting/system-info.sh`
- Visible state: date, hostname, current user, disk section, process summary, and saved report path.
- Success: final system-information `PASS` is visible. Remove `shell-scripting/screenshot-output/` after capture.

## 03 — Networking

- File: `03-networking.png`
- Run on Linux: `./networking/collect-network-info.sh`
- Visible state: interface/address, route, and listening-socket sections.
- Success: output comes from the current machine and ends with `PASS`; review sensitive values before submission.

## 04 — `commit -a`

- File: `04-git-commit-a.png`
- Run: `./git-github/git-practice-demo.sh`
- Visible state: status before and after `git commit -a -m`.
- Success: `tracked.txt` is committed while `?? untracked.txt` remains.

## 05 — Cherry-pick

- File: `05-git-cherry-pick.png`
- Run: `./git-github/git-practice-demo.sh`
- Visible state: generated selected commit hash, cherry-pick result, and decorated graph.
- Success: `selected cherry-pick content` and final `PASS` are visible.

## 06 — Node.js browser

- File: `06-nodejs-browser.png`
- Start: `cd docker-fundamentals && docker compose up --build -d nodejs`
- Open: `http://localhost:3000/`
- Success: page visibly says `Hello World from Node.js`.

## 07 — Python browser

- File: `07-python-browser.png`
- Start: `cd docker-fundamentals && docker compose up --build -d python`
- Open: `http://localhost:5000/`
- Success: page visibly says `Hello World from Python`.

## 08 — Java browser

- File: `08-java-browser.png`
- Start: `cd docker-fundamentals && docker compose up --build -d java`
- Open: `http://localhost:8081/`
- Success: page visibly says `Hello World from Java`.

## 09 — Apache browser

- File: `09-apache-browser.png`
- Start: `cd docker-fundamentals && docker compose up --build -d apache`
- Open: `http://localhost:8082/`
- Success: page visibly says `Hello World from Apache`.

## 10 — React browser

- File: `10-react-browser.png`
- Start: `cd docker-fundamentals && docker compose up --build -d react`
- Open: `http://localhost:8083/`
- Success: rendered React card says `Hello World from React`; browser console has no load error.

## 11 — Nginx browser

- File: `11-nginx-browser.png`
- Start: `cd docker-fundamentals && docker compose up --build -d nginx`
- Open: `http://localhost:8084/`
- Success: page visibly says `Hello World from Nginx`.

After screenshots 06–11, run `cd docker-fundamentals && docker compose down`.

## 12 — Multi-stage browser

- File: `12-multistage-browser.png`
- Run: `docker build -t devops-multistage-app docker-multistage/multistage-app && docker run -d --name devops-multistage -p 8080:8080 devops-multistage-app`
- Open: `http://localhost:8080/`
- Success: page visibly says `Hello World from Docker multi-stage build`.

## 13 — Multi-stage `docker ps`

- File: `13-multistage-docker-ps.png`
- Run: `docker ps --filter name=devops-multistage --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'`
- Visible state: terminal row for `devops-multistage`.
- Success: status is Up and port mapping includes host `8080` to container `8080`.

Then run `docker rm -f devops-multistage`.

## 14 — Docker networks

- File: `14-docker-networks.png`
- Run: `./docker-network/container-networking/start.sh` followed by `docker network ls --filter name=devops_hw_`.
- Visible state: `devops_hw_frontend_net`, `devops_hw_backend_net`, and `devops_hw_database_net`.
- Success: all three are bridge networks.

## 15 — Network connectivity

- File: `15-network-connectivity.png`
- Run: `./docker-network/container-networking/verify.sh`
- Visible state: frontend-to-backend output, backend-to-database TCP success, database health, and isolation result.
- Success: final connectivity/isolation `PASS` is visible. Then run `./docker-network/container-networking/stop.sh`.

## 16 — Host networking

- File: `16-host-network.png`
- On native Linux, first run: `sudo ss -ltnp '( sport = :80 )'` and confirm port 80 is free.
- Start: `docker run -d --rm --name apache-host --network host httpd:2.4-alpine`
- Verify: `curl -fsS http://localhost/`
- Visible state: curl's real “It works!” Apache response and `docker inspect apache-host --format '{{.HostConfig.NetworkMode}}'` returning `host`.
- Success: direct port 80 response and confirmed host network mode. Remove with `docker rm -f apache-host`.

## 17 — Bind mount before

- File: `17-bind-mount-before.png`
- Start: `./docker-network/bind-mount/run.sh`
- Run: `curl -fsS http://localhost:8085/`
- Success: response visibly contains `Hello students`.

## 18 — Bind mount after

- File: `18-bind-mount-after.png`
- While the same container remains running, execute `./docker-network/bind-mount/verify.sh`.
- Visible state: before and after responses plus the statement that the container was not restarted.
- Success: updated response says `updated through the host bind mount` and final `PASS` is visible. The script restores the source file; remove the container with `docker rm -f devops-hw-bind-mount`.
