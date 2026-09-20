# Three Containers / Three Networks

This Compose lab deliberately segments three services:

```text
frontend -- frontend_net -- backend -- backend_net -- database
                                                     database_net (database only)
```

- `frontend` joins only `frontend_net`.
- `backend` joins `frontend_net` and `backend_net`, making it the application-tier boundary.
- `database` joins `backend_net` and a third isolated `database_net`.
- The frontend and database share no network, so Compose DNS does not publish `database` to the frontend.

Connections use service names (`backend`, `database`), never container IP addresses. The MySQL volume and all three networks have project-specific names. Credentials are intentionally obvious, non-sensitive **lab-only** values and must not be reused in production.

## Run

```bash
./start.sh
./verify.sh
./stop.sh
```

`start.sh` waits until Compose reports healthy/running services. `verify.sh` proves:

1. The frontend can fetch `http://backend/` by service DNS.
2. The backend can open database TCP port `3306` by service DNS.
3. MySQL reports healthy.
4. The frontend cannot directly resolve/reach `database:3306`.
5. Docker network inspection shows the expected memberships.

Override the default frontend host port `8090` with `FRONTEND_HOST_PORT=<port>`.
