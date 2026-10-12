#!/bin/bash
set -euo pipefail
[[ -f /.dockerenv ]] || { echo 'Run in isolated Docker.'; exit 1; }
lab_dir=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p /tmp/lab13
export DISPLAY=:99
Xvfb :99 -screen 0 800x600x24 >/tmp/lab13/xserver.txt 2>&1 &
xserver_pid=$!
python3 -m uvicorn api:app --app-dir "$lab_dir" --host 127.0.0.1 --port 8130 >/tmp/lab13/api.txt 2>&1 &
api_pid=$!
trap 'kill "$xserver_pid" "$api_pid" ${window_pid:-} ${logger_pid:-} 2>/dev/null || true' EXIT
for attempt in {1..50}; do
    if curl -fsS http://127.0.0.1:8130/openapi.json >/dev/null 2>&1 && xdotool getdisplaygeometry >/dev/null 2>&1; then break; fi
    sleep 0.1
done
xterm -title LAB13-INPUT -e /bin/cat >/tmp/lab13/input.txt 2>&1 &
window_pid=$!
window_id=$(timeout 5 xdotool search --sync --name LAB13-INPUT | head -n 1)
xdotool windowfocus "$window_id"
printf '$ DISPLAY=:99 python3 main.py\n'
python3 "$lab_dir/main.py" >/tmp/lab13/listener.txt 2>&1 &
logger_pid=$!
for attempt in {1..50}; do
    if grep -q 'ACTIVE:' /tmp/lab13/listener.txt; then break; fi
    sleep 0.1
done
printf '$ xdotool type --delay 80 "testing my lab"; xdotool key Return\n'
xdotool type --delay 80 'testing my lab'
xdotool key Return
if [[ ${1:-} == --escape ]]; then
    printf '$ xdotool key Escape\n'
    xdotool key Escape
fi
wait "$logger_pid"
cat /tmp/lab13/listener.txt
printf '\n$ cat /tmp/lab13/log.txt\n'
cat /tmp/lab13/log.txt
printf '$ cat /tmp/lab13/server-log.txt\n'
cat /tmp/lab13/server-log.txt
printf '$ cmp /tmp/lab13/log.txt /tmp/lab13/server-log.txt\n'
cmp /tmp/lab13/log.txt /tmp/lab13/server-log.txt
printf 'testing\nmy\nlab\n' | cmp - /tmp/lab13/log.txt
printf 'CHECK: actual X11 key events recorded, delivered to local API, listener stopped.\n'
