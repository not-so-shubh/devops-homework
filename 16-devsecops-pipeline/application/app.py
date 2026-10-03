#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os


def payload(path: str) -> tuple[int, bytes]:
    if path in ("/health", "/ready"):
        return 200, json.dumps({"status": "ok"}).encode()
    if path == "/":
        return 200, json.dumps({"message": "DevSecOps pipeline demo", "version": os.getenv("APP_VERSION", "dev")}).encode()
    return 404, json.dumps({"error": "not found"}).encode()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:  # noqa: N802
        status, body = payload(self.path.split("?", 1)[0])
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt: str, *args: object) -> None:
        print(json.dumps({"message": fmt % args}))


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", int(os.getenv("PORT", "8080"))), Handler).serve_forever()
