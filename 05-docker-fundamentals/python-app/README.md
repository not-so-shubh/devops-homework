# Python App

Flask application served without debug mode by Gunicorn, bound to `0.0.0.0:5000`, and run as an unprivileged user.

```bash
docker build -t devops-homework-python .
docker run --rm -p 5000:5000 devops-homework-python
curl -fsS http://localhost:5000/
```

Expected text: `Hello World from Python`.
