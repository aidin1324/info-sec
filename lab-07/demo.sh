#!/usr/bin/env bash
# Cron and its crontab exist only in this disposable container.
set -euo pipefail
if [[ $(uname -s) != Linux || ! -f /.dockerenv || $(id -u) != 0 ]]; then
    echo 'Run this lab as root inside Docker.' >&2
    exit 1
fi

mkdir -p /tmp/lab7
touch /tmp/lab7/file.txt /tmp/lab7/reports.txt
printf '$ crontab /opt/info-sec-lab7/crontab.txt\n'
crontab /opt/info-sec-lab7/crontab.txt
printf '$ crontab -l\n'
crontab -l
printf '\n$ cron -f\n'
cron -f &
cron_pid=$!
trap 'kill "$cron_pid" 2>/dev/null || true' EXIT

# Observe two actual minute ticks; neither job is called directly.
printf 'Waiting for two scheduled runs of BOTH jobs (up to 130 seconds).\n'
for attempt in {1..130}; do
    if [[ $(wc -l < /tmp/lab7/file.txt) -ge 2 && $(wc -l < /tmp/lab7/reports.txt) -ge 2 ]]; then
        break
    fi
    sleep 1
done
if [[ $(wc -l < /tmp/lab7/file.txt) -lt 2 || $(wc -l < /tmp/lab7/reports.txt) -lt 2 ]]; then
    echo 'Cron did not run both jobs twice.' >&2
    exit 1
fi
printf '$ cat /tmp/lab7/file.txt\n'
cat /tmp/lab7/file.txt
printf '$ cat /tmp/lab7/reports.txt\n'
cat /tmp/lab7/reports.txt
printf 'CHECK: both jobs ran on two minute ticks.\n'
printf '\n$ crontab -r\n'
crontab -r
printf '$ crontab -l\n'
if crontab -l 2>&1; then
    echo 'The crontab still exists unexpectedly.' >&2
    exit 1
fi
printf 'The demonstration crontab was removed inside the container.\n'
