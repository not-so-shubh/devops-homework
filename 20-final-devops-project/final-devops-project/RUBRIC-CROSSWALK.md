# Instructor Grading Rubric Crosswalk

This crosswalk maps the instructor repository's Session 21 `GRADING.md` to this original Release Tracker implementation. It is a verification aid, not a substitute for genuine runtime evidence.

| Module | Points | Evidence in this project |
|---|---:|---|
| M1 Application | 10 | FastAPI `/health`; six release API routes including GET/POST/PUT/DELETE; PostgreSQL model and Alembic migration; React frontend that calls the API; responsive CSS |
| M2 Testing | 10 | `backend/tests/` contains eight pytest cases across health, readiness, metrics and CRUD endpoints; SQLite dependency override; `pytest.ini` and `conftest.py` |
| M3 Git | 5 | Public GitHub repository, meaningful commits, and root `.gitignore` excluding `.env`, `__pycache__`, `node_modules` and `.venv` |
| M4 Docker | 10 | Separate backend Dockerfile; frontend Node-to-Nginx multi-stage Dockerfile; both use non-root UIDs; Compose starts frontend, backend and PostgreSQL |
| M5 CI/CD | 15 | `.github/workflows/final-project.yml` runs pytest and frontend build, builds and pushes both images to GHCR, and applies commit-SHA tags |
| M6 DevSecOps | 5 | Independent Trivy HIGH/CRITICAL gates for both images plus uploaded SARIF; README documents the fail condition; Bandit, pip-audit and Gitleaks add defense in depth |
| M7 Terraform | 15 | Formatted/validated HCL for VPC, two public subnets, EKS and managed nodes; safe `terraform.tfvars.example`; `terraform/README.md` documents init/plan/apply/output/destroy |
| M8 Kubernetes + Helm | 15 | Namespace, raw manifests and Helm chart; two frontend and two backend replicas; ClusterIP services; `/api` and `/` ingress rules; probes, HPA and chart test |
| M9 Observability | 10 | `/metrics`, ServiceMonitor/Prometheus discovery, kube-prometheus-stack values, alerts and a provisioned three-panel Grafana dashboard; hosted smoke testing verifies a live scrape, non-zero query, accessible Grafana and screenshot artifact |
| M10 Documentation/demo | 5 | This README explains architecture and every run path; CI deploys each gated SHA into Kind and verifies all workloads after the images are published |

## Originality

The instructor's sample project is a task board. This submission deliberately uses a different domain, schema, interface and API: release/change tracking for platform teams. No generated output or screenshots were copied from the instructor repository.
