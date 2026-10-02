#!/usr/bin/env bash
# Cron and its crontab exist only in this disposable container.
set -euo pipefail
if [[ $(uname -s) != Linux || ! -f /.dockerenv || $(id -u) != 0 ]]; then
    echo 'Run this lab as root inside Docker.' >&2
    exit 1
fi

printf '$ crontab /opt/info-sec-lab7/crontab.txt\n'
crontab /opt/info-sec-lab7/crontab.txt
printf '$ crontab -l\n'
crontab -l
printf '\n$ cron -f\n'
cron -f &
cron_pid=$!
trap 'kill "$cron_pid" 2>/dev/null || true' EXIT

# @reboot executes when this container's daemon starts; the minute entry
# stays installed too, as requested in the exercise.
for attempt in {1..65}; do
    if [[ -s /tmp/lab7/reports.txt ]]; then
        break
    fi
    sleep 1
done
if [[ ! -s /tmp/lab7/reports.txt ]]; then
    echo 'Cron did not run the Python job.' >&2
    exit 1
fi
printf '$ cat /tmp/lab7/reports.txt\n'
cat /tmp/lab7/reports.txt
printf '\n$ crontab -r\n'
crontab -r
printf '$ crontab -l\n'
if crontab -l 2>&1; then
    echo 'The crontab still exists unexpectedly.' >&2
    exit 1
fi
printf 'The demonstration crontab was removed inside the container.\n'
