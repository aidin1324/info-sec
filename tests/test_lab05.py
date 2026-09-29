"""Run Linux account operations in a disposable container, never on the host."""

from pathlib import Path
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("docker"), "Lab 5 needs Docker")
class Lab5Tests(unittest.TestCase):
    def test_account_lifecycle_groups_and_real_file_access(self):
        script = ROOT / "lab-05/demo.sh"
        self.assertTrue(script.is_file(), "Lab 5 demonstration is missing")
        result = subprocess.run([
            "docker", "run", "--rm", "--network", "none",
            "--mount", f"type=bind,src={script},dst=/demo.sh,readonly",
            "python:3.13.7-bookworm", "bash", "/demo.sh"
        ], capture_output=True, text=True, timeout=60)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for expected in ["CHECK: switched identity = user1",
                         "CHECK: full name updated", "CHECK: user1 and home removed",
                         "CHECK: both supplementary groups retained",
                         "CHECK: labstudent read group file",
                         "CHECK: outsider denied group file"]:
            self.assertIn(expected, result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
