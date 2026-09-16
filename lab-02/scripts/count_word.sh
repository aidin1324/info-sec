#!/bin/bash
if [ "$#" -ne 2 ] || [ -z "$2" ]; then
    printf 'Usage: %s <file> <word>\n' "$0" >&2
    exit 1
fi
file=$1
word=$2
if [ ! -f "$file" ] || [ ! -r "$file" ]; then
    printf 'Cannot read file: %s\n' "$file" >&2
    exit 1
fi

matches=$(LC_ALL=C grep -F -w -o -- "$word" "$file")
status=$?
if [ "$status" -gt 1 ]; then
    exit "$status"
fi
count=0
if [ -n "$matches" ]; then
    count=$(printf '%s\n' "$matches" | wc -l | tr -d '[:space:]')
fi
printf "The word '%s' appears %s time(s) in '%s'.\n" "$word" "$count" "$file"
