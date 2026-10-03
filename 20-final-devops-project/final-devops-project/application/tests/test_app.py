import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from app import route  # noqa: E402


class FinalAppTests(unittest.TestCase):
    def test_home_contract(self):
        status, content_type, body = route("/")
        self.assertEqual(status, 200)
        self.assertEqual(content_type, "application/json")
        self.assertEqual(json.loads(body)["message"], "Final DevOps Project")

    def test_health_and_readiness(self):
        self.assertEqual(route("/health")[0], 200)
        self.assertEqual(route("/ready")[0], 200)

    def test_prometheus_metrics(self):
        status, content_type, body = route("/metrics")
        self.assertEqual(status, 200)
        self.assertIn("version=0.0.4", content_type)
        self.assertIn(b"final_app_requests_total", body)

    def test_not_found(self):
        self.assertEqual(route("/missing")[0], 404)


if __name__ == "__main__":
    unittest.main()
