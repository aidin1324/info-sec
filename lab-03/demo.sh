#!/bin/bash
set -euo pipefail
lab_dir=$(cd -- "$(dirname -- "$0")" && pwd)
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
mkdir "$workspace/bin" "$workspace/sample" "$workspace/sample/folder"
touch "$workspace/sample/notes.txt"
ln -s "$lab_dir/toy_shell.py" "$workspace/bin/toy_shell"
export PATH="$workspace/bin:$PATH"
cd "$workspace/sample"
printf '$ pwd\n'; pwd
printf '$ command -v toy_shell\n'; command -v toy_shell
printf '$ printf "2000-01-01\\n2099-01-01\\n2026-02-30\\n2026-9-1\\nexit\\n" | toy_shell\n'
printf '2000-01-01\n2099-01-01\n2026-02-30\n2026-9-1\nexit\n' | toy_shell
printf 'CHECK: file/folder filtering, invalid dates and exit demonstrated.\n'
