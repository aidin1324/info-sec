#!/usr/bin/env python3
"""Behavior checks for the lab results and small command-line tools."""

import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]


class Lab1Tests(unittest.TestCase):
    def test_every_file_was_moved_including_hidden_files(self):
        state_path = ROOT / "lab-01/results/file-state.json"
        destination = ROOT / "lab-01/results/files/destination"
        self.assertTrue(state_path.is_file(), "Run the Lab 1 demonstration first")
        self.assertEqual(json.loads(state_path.read_text())["source"], [])
        self.assertEqual({p.name for p in destination.iterdir()},
                         {"notes.txt", "second.txt", ".hidden.txt"})

    def test_archive_extraction_preserves_file_contents(self):
        base = ROOT / "lab-01/results"
        self.assertTrue((base / "archive.tar.gz").is_file(), "Archive is missing")
        for name, expected in [("notes.txt", "first file\n"),
                               ("second.txt", "second file\n"),
                               (".hidden.txt", "hidden file\n")]:
            self.assertEqual((base / "extracted/destination" / name).read_text(), expected)

    def test_get_returns_posts_and_head_succeeds(self):
        base = ROOT / "lab-01/results"
        self.assertTrue((base / "posts.json").is_file(), "GET response is missing")
        posts = json.loads((base / "posts.json").read_text())
        self.assertEqual(len(posts), 100)
        self.assertEqual(posts[0]["id"], 1)
        headers = (base / "head.txt").read_text()
        self.assertRegex(headers, r"HTTP/\S+ 200")

    def test_post_returns_the_submitted_payload(self):
        path = ROOT / "lab-01/results/post.json"
        self.assertTrue(path.is_file(), "POST response is missing")
        self.assertEqual(json.loads(path.read_text()),
                         {"title": "foo", "body": "bar", "userId": 1, "id": 101})


if __name__ == "__main__":
    unittest.main(verbosity=2)
