"""Check the local training form against real HTTP requests and file writes."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
DEMO = {"holder": "DEMO STUDENT", "card": "0000 0000 0000 0000",
        "expiry": "12/99", "cvv": "000"}


class Lab4Tests(unittest.TestCase):
    def setUp(self):
        path = ROOT / "lab-04/app.py"
        self.assertTrue(path.is_file(), "Lab 4 server is missing")
        spec = importlib.util.spec_from_file_location("lab04", path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.create_app = module.create_app
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.record = Path(self.directory.name) / "nested/submissions.jsonl"
        self.app = module.create_app(self.record)
        self.app.config["TESTING"] = True
        self.client = self.app.test_client()

    def test_two_submissions_append_and_survive_a_new_app(self):
        for _ in range(2):
            response = self.client.post("/submit", json=DEMO)
            self.assertEqual(response.status_code, 201)
            self.assertEqual(response.json, {"saved": True, "demo_only": True})
        rows = [json.loads(line) for line in self.record.read_text().splitlines()]
        self.assertEqual(rows, [DEMO, DEMO])
        # A new browser/server instance does not erase persistent file state.
        self.assertEqual(self.create_app(self.record).test_client().get("/").status_code, 200)
        self.assertEqual(len(self.record.read_text().splitlines()), 2)

    def test_non_demo_fields_are_rejected_without_writing(self):
        for field in DEMO:
            payload = dict(DEMO, **{field: "unapproved value"})
            with self.subTest(field=field):
                self.assertEqual(self.client.post("/submit", json=payload).status_code, 400)
                self.assertFalse(self.record.exists())

    def test_missing_extra_and_non_object_data_are_rejected(self):
        for payload in [{}, {**DEMO, "email": "person@example.test"}, [], None, "text"]:
            with self.subTest(payload=payload):
                response = self.client.post("/submit", data=json.dumps(payload),
                                            content_type="application/json")
                self.assertEqual(response.status_code, 400)
                self.assertFalse(self.record.exists())

    def test_malformed_json_and_wrong_content_type_are_rejected(self):
        for body, content_type in [("{", "application/json"), ("hello", "text/plain")]:
            response = self.client.post("/submit", data=body, content_type=content_type)
            self.assertEqual(response.status_code, 400)
            self.assertFalse(self.record.exists())

    def test_large_request_is_rejected_without_writing(self):
        response = self.client.post("/submit", data="x" * 5000,
                                    content_type="application/json")
        self.assertEqual(response.status_code, 413)
        self.assertFalse(self.record.exists())

    def test_get_submit_does_not_write(self):
        self.assertEqual(self.client.get("/submit").status_code, 405)
        self.assertFalse(self.record.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
