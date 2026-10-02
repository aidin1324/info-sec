#!/usr/bin/env python3
"""Append a small, local disk-space report when cron runs this job."""

from datetime import datetime, timezone
from pathlib import Path
import shutil

REPORT = Path("/tmp/lab7/reports.txt")
REPORT.parent.mkdir(parents=True, exist_ok=True)
free_mib = shutil.disk_usage("/").free // (1024 * 1024)
with REPORT.open("a", encoding="utf-8") as output:
    output.write(f"{datetime.now(timezone.utc).isoformat()} free_space_mib={free_mib}\n")
