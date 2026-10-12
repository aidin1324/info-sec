#!/bin/bash
set -eu
mkdir -p /tmp/lab7
printf 'New line at %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> /tmp/lab7/file.txt
