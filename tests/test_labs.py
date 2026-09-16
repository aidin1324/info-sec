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


class Lab2Tests(unittest.TestCase):
    def run_script(self, name, *args, env=None):
        path = ROOT / "lab-02/scripts" / name
        self.assertTrue(path.is_file(), f"Missing command: {name}")
        return subprocess.run(["/bin/bash", str(path), *map(str, args)],
                              text=True, capture_output=True, env=env, timeout=5)

    def test_word_count_counts_occurrences_not_lines_or_substrings(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "words with spaces.txt"
            path.write_text("apple apple pineapple Apple\napple, apple!\n")
            result = self.run_script("count_word.sh", path, "apple")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertRegex(result.stdout, r"appears\s+4\s+time")
            result = self.run_script("count_word.sh", path, "pear")
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertRegex(result.stdout, r"appears\s+0\s+time")

    def test_word_count_rejects_missing_inputs(self):
        self.assertNotEqual(self.run_script("count_word.sh").returncode, 0)
        self.assertNotEqual(self.run_script("count_word.sh", "/missing-file", "word").returncode, 0)

    def test_workday_boundaries_use_minutes_and_decimal_hours(self):
        # Only the clock is substituted; the script and its arithmetic are real.
        with tempfile.TemporaryDirectory() as directory:
            date = Path(directory) / "date"
            date.write_text('#!/bin/sh\n[ "$1" = "+%H:%M" ] || exit 2\nprintf "%s\\n" "$LAB_TEST_TIME"\n')
            date.chmod(0o755)
            cases = [("08:05", "9 hours and 55 minutes"),
                     ("13:30", "4 hours and 30 minutes"),
                     ("17:59", "0 hours and 1 minutes"),
                     ("18:00", "ended"), ("19:10", "ended")]
            for clock, expected in cases:
                with self.subTest(clock=clock):
                    env = dict(os.environ, PATH=directory + os.pathsep + os.environ["PATH"],
                               LAB_TEST_TIME=clock)
                    result = self.run_script("current_time.sh", env=env)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn(expected, result.stdout)

    def test_cleanup_only_deletes_empty_regular_files_and_prints_names(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "test files"
            nested = target / "nested"
            nested.mkdir(parents=True)
            empty = target / "empty file.txt"
            hidden = nested / ".empty"
            empty.touch()
            hidden.touch()
            full = target / "keep.txt"
            full.write_text("keep this\n")
            outside = root / "outside.txt"
            outside.touch()
            link = target / "link"
            link.symlink_to(outside)
            result = self.run_script("delete_empty_files.sh", target)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(empty.exists())
            self.assertFalse(hidden.exists())
            self.assertEqual(full.read_text(), "keep this\n")
            self.assertTrue(nested.is_dir())
            self.assertTrue(outside.exists())
            self.assertTrue(link.is_symlink())
            self.assertIn(str(empty), result.stdout)
            self.assertIn(str(hidden), result.stdout)

    def test_cleanup_rejects_missing_or_invalid_directory(self):
        self.assertNotEqual(self.run_script("delete_empty_files.sh").returncode, 0)
        self.assertNotEqual(self.run_script("delete_empty_files.sh", "/missing-dir").returncode, 0)


class Lab3Tests(unittest.TestCase):
    def command(self):
        path = ROOT / "lab-03/toy_shell.py"
        self.assertTrue(path.is_file(), "Toy shell implementation is missing")
        return [sys.executable, "-u", str(path)]

    def run_shell(self, text, cwd):
        return subprocess.run(self.command(), input=text, cwd=cwd,
                              text=True, capture_output=True, timeout=5)

    def test_future_date_lists_file_and_folder_with_ctime_labels(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "notes.txt").write_text("notes\n")
            (root / "folder").mkdir()
            result = self.run_shell("2099-01-01\nexit\n", directory)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("notes.txt (File, ctime:", result.stdout)
            self.assertIn("folder (Folder, ctime:", result.stdout)

    def test_past_date_does_not_list_new_entries(self):
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / "new.txt").touch()
            result = self.run_shell("2000-01-01\nexit\n", directory)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertNotIn("new.txt", result.stdout)

    def test_invalid_calendar_and_non_iso_dates_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            for value in ["2026-02-30", "2026-9-1", "hello"]:
                with self.subTest(value=value):
                    result = self.run_shell(value + "\nexit\n", directory)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn("Invalid date", result.stdout)

    def test_eof_and_exit_end_the_session(self):
        with tempfile.TemporaryDirectory() as directory:
            for value in ["", "EXIT\n"]:
                result = self.run_shell(value, directory)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertNotIn("Traceback", result.stderr)

    def test_ctrl_c_leaves_shell_available_for_exit(self):
        with tempfile.TemporaryDirectory() as directory:
            process = subprocess.Popen(self.command(), cwd=directory,
                                       stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE, text=True)
            try:
                self.assertIn("Toy shell", process.stdout.readline())
                time.sleep(0.05)
                process.send_signal(signal.SIGINT)
                time.sleep(0.05)
                output, error = process.communicate("exit\n", timeout=5)
                self.assertEqual(process.returncode, 0, error)
                self.assertIn("Use 'exit'", output)
                self.assertNotIn("Traceback", error)
            finally:
                if process.poll() is None:
                    process.kill()
                    process.wait()


if __name__ == "__main__":
    unittest.main(verbosity=2)
