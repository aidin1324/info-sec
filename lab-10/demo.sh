#!/bin/bash
set -euo pipefail
[[ -f /.dockerenv && $(id -u) == 0 ]] || { echo 'Run as root in Docker.'; exit 1; }
lab_dir=$(cd -- "$(dirname -- "$0")" && pwd)
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@"; }
run install -m 644 "$lab_dir/my_site" /etc/nginx/sites-available/my_site
run install -m 644 "$lab_dir/my_site.html" /var/www/html/my_site.html
run ln -s /etc/nginx/sites-available/my_site /etc/nginx/sites-enabled/my_site
run nginx -t
python3 "$lab_dir/api.py" &
api_pid=$!
trap 'nginx -s quit 2>/dev/null || true; kill "$api_pid" 2>/dev/null || true' EXIT
for attempt in {1..50}; do
    if curl -fsS http://127.0.0.1:9000/health >/dev/null 2>&1; then break; fi
    sleep 0.1
done
run nginx
run nginx -s reload
run curl -fsS http://127.0.0.1:8000/
run curl -fsS http://127.0.0.1:8000/api/health
curl -fsS http://127.0.0.1:8000/ | grep -q 'My site on 8000'
curl -fsS http://127.0.0.1:8000/api/health | python3 -c 'import json, sys; assert json.load(sys.stdin) == {"ok": True, "service": "lab10-api"}'
printf '\n$ curl -s -o /dev/null -w "%%{http_code}" http://127.0.0.1:8000/missing\n'
status=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8000/missing)
printf '%s\n' "$status"
[[ $status == 404 ]]
printf 'CHECK: static page 200; proxied API 200; missing file 404.\n'
if [[ ${1:-} == --serve ]]; then
    printf 'Browser demo remains active until this container stops.\n'
    wait "$api_pid"
fi
