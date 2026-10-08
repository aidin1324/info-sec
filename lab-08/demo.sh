#!/usr/bin/env bash
set -euo pipefail
if [[ $(uname -s) != Linux || ! -f /.dockerenv ]]; then
    echo 'Run this lab inside Docker.' >&2
    exit 1
fi
mkdir -p /tmp/lab8
printf '$ vim -Nu NONE -n -i NONE -es -S commands.vim file.txt\n'
vim -Nu NONE -n -i NONE -es -S /opt/info-sec-lab8/commands.vim /tmp/lab8/file.txt

printf '\ni → insert three lines; Esc, :w → save:\n'
cat /tmp/lab8/01-insert.txt
printf '\ngg j dd → delete the second line:\n'
cat /tmp/lab8/02-delete-line.txt
printf '\nu → undo deletion:\n'
cat /tmp/lab8/03-undo.txt
printf '\n:%%s/text/line/g → replace text in every line:\n'
cat /tmp/lab8/04-replace.txt
printf '\n:%%d → delete all lines; wc -c:\n'
wc -c < /tmp/lab8/05-clear.txt
printf '\ni → insert final text; Esc, :wq → save and quit:\n'
cat /tmp/lab8/file.txt
