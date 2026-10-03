#!/usr/bin/env python3
"""Small observable HTTP service used by the CI/CD assignments."""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
import time

STARTED_AT = time.time()


def response_for(path: str) -> tuple[int, str, bytes]:
    """Return status, content type and body for a request path."""
    if path == "/health":
        return 200, "application/json", json.dumps({"status": "healthy"}).encode()
    if path == "/ready":
        return 200, "application/json", json.dumps({"status": "ready"}).encode()
    if path == "/metrics":
        body = f"devops_app_up 1\ndevops_app_uptime_seconds {int(time.time() - STARTED_AT)}\n"
        return 200, "text/plain; version=0.0.4", body.encode()
    if path == "/":
        payload = {
            "message": os.getenv("APP_MESSAGE", "Hello from the DevOps CI/CD demo"),
            "version": os.getenv("APP_VERSION", "development"),
        }
        return 200, "application/json", json.dumps(payload, sort_keys=True).encode()
    return 404, "application/json", json.dumps({"error": "not found"}).encode()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:  # noqa: N802 - required by BaseHTTPRequestHandler
        status, content_type, body = response_for(self.path.split("?", 1)[0])
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt: str, *args: object) -> None:
        print(json.dumps({"client": self.client_address[0], "message": fmt % args}))


def main() -> None:
    port = int(os.getenv("PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(json.dumps({"event": "server_started", "port": port}), flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
