import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from app import response_for  # noqa: E402


class ApplicationTests(unittest.TestCase):
    def test_home(self):
        status, content_type, body = response_for("/")
        self.assertEqual(status, 200)
        self.assertEqual(content_type, "application/json")
        self.assertIn("message", json.loads(body))

    def test_health(self):
        status, _, body = response_for("/health")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(body), {"status": "healthy"})

    def test_metrics(self):
        status, content_type, body = response_for("/metrics")
        self.assertEqual(status, 200)
        self.assertIn("text/plain", content_type)
        self.assertIn(b"devops_app_up 1", body)

    def test_unknown_path(self):
        status, _, _ = response_for("/missing")
        self.assertEqual(status, 404)


if __name__ == "__main__":
    unittest.main()
