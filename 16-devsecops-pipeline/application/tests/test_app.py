import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from app import payload  # noqa: E402


class DevSecOpsAppTests(unittest.TestCase):
    def test_root(self):
        status, body = payload("/")
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(body)["message"], "DevSecOps pipeline demo")

    def test_health(self):
        status, body = payload("/health")
        self.assertEqual((status, json.loads(body)), (200, {"status": "ok"}))

    def test_missing(self):
        self.assertEqual(payload("/missing")[0], 404)


if __name__ == "__main__":
    unittest.main()
