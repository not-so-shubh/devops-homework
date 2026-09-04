# React App

Vite builds a production React bundle in the first stage; official Nginx serves only the resulting static files in the runtime stage.

```bash
docker build -t devops-homework-react .
docker run --rm -p 8083:80 devops-homework-react
curl -fsS http://localhost:8083/
```

Expected text: `Hello World from React`.
