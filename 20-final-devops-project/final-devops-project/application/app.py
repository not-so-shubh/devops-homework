#!/usr/bin/env python3
"""Final-project service with health, readiness and Prometheus metrics."""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
import time

START = time.time()
REQUESTS = 0


def route(path: str) -> tuple[int, str, bytes]:
    global REQUESTS
    REQUESTS += 1
    if path == "/health":
        return 200, "application/json", b'{"status":"healthy"}'
    if path == "/ready":
        return 200, "application/json", b'{"status":"ready"}'
    if path == "/metrics":
        metrics = (
            "# HELP final_app_up Whether the application is running.\n"
            "# TYPE final_app_up gauge\nfinal_app_up 1\n"
            "# HELP final_app_requests_total Requests handled by this process.\n"
            "# TYPE final_app_requests_total counter\n"
            f"final_app_requests_total {REQUESTS}\n"
            f"final_app_uptime_seconds {int(time.time() - START)}\n"
        )
        return 200, "text/plain; version=0.0.4", metrics.encode()
    if path == "/":
        body = json.dumps(
            {
                "message": os.getenv("APP_MESSAGE", "Final DevOps Project"),
                "environment": os.getenv("APP_ENV", "development"),
                "version": os.getenv("APP_VERSION", "local"),
            },
            sort_keys=True,
        ).encode()
        return 200, "application/json", body
    return 404, "application/json", b'{"error":"not found"}'


class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:  # noqa: N802
        status, content_type, body = route(self.path.split("?", 1)[0])
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt: str, *args: object) -> None:
        print(json.dumps({"remote": self.client_address[0], "message": fmt % args}), flush=True)


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", int(os.getenv("PORT", "8080"))), Handler).serve_forever()
