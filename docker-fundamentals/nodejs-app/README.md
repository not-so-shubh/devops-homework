# Node.js App

Minimal Express service returning `Hello World from Node.js`. It listens on `0.0.0.0:3000` and runs as the image's unprivileged `node` user.

```bash
docker build -t devops-homework-nodejs .
docker run --rm -p 3000:3000 devops-homework-nodejs
curl -fsS http://localhost:3000/
```
