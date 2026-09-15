#!/bin/bash
set -euo pipefail

lab_dir=$(cd -- "$(dirname -- "$0")" && pwd)
results=${1:-"$lab_dir/results"}
if [ -e "$results" ]; then
    printf 'Output path already exists: %s\nChoose a new output directory.\n' "$results" >&2
    exit 1
fi
mkdir -p "$results"
results=$(cd -- "$results" && pwd)
workspace=$(mktemp -d "${TMPDIR:-/tmp}/info-sec-lab1.XXXXXX")
printf 'Working directory: %s\n' "$workspace"
cd -- "$workspace"

run() {
    printf '$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
}

{
    run mkdir my_dir
    run cd my_dir
    run touch my_file.txt
    run chmod 777 my_file.txt
    run ls -l my_file.txt
    run cat my_file.txt
    run cd ..
    run mkdir another_dir
    run cp my_dir/my_file.txt another_dir/
    run rm my_dir/my_file.txt
    run ls another_dir
    run mkdir source destination
    run bash -c 'printf "first file\n" > source/notes.txt; printf "second file\n" > source/second.txt; printf "hidden file\n" > source/.hidden.txt'
    run ls -A source
    shopt -s dotglob nullglob
    run mv source/* destination/
    run ls -A source
    run ls -A destination
    python3 - "$results/file-state.json" <<'PY'
import json
import os
import sys
with open(sys.argv[1], 'w') as output:
    json.dump({name: sorted(os.listdir(name)) for name in ['source', 'destination']}, output, indent=2)
PY
    mkdir "$results/files"
    cp -R destination "$results/files/"
} > "$results/files.txt" 2>&1

{
    run curl --help
    run curl --fail --silent --show-error https://jsonplaceholder.typicode.com/posts -o "$results/posts.json"
    printf '$ python3: show number of posts and first object\n'
    python3 - "$results/posts.json" <<'PY'
import json
import sys
with open(sys.argv[1]) as response:
    posts = json.load(response)
print(f'Posts received: {len(posts)}')
print(json.dumps(posts[0], indent=2))
PY
    run curl --fail --silent --show-error -I https://jsonplaceholder.typicode.com/posts -o "$results/head.txt"
    run head -n 8 "$results/head.txt"
    run curl --fail --silent --show-error -X POST -H 'Content-Type: application/json' -d '{"title":"foo","body":"bar","userId":1}' https://jsonplaceholder.typicode.com/posts -o "$results/post.json"
    run cat "$results/post.json"
} > "$results/http.txt" 2>&1

{
    run tar --help
    run tar -czvf "$results/archive.tar.gz" destination
    run tar -tzf "$results/archive.tar.gz"
    run mkdir "$results/extracted"
    run tar -xzvf "$results/archive.tar.gz" -C "$results/extracted"
    run diff -r destination "$results/extracted/destination"
    printf 'Extracted files match the originals.\n'
} > "$results/archive.txt" 2>&1

cat "$results/files.txt" "$results/http.txt" "$results/archive.txt"
printf '\nResults: %s\n' "$results"
