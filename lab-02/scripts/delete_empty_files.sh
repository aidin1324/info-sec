#!/bin/bash
if [ "$#" -ne 1 ]; then
    printf 'Usage: %s <directory>\n' "$0" >&2
    exit 1
fi
if [ ! -d "$1" ]; then
    printf 'Not a directory: %s\n' "$1" >&2
    exit 1
fi
directory=$(cd -- "$1" && pwd -P) || exit 1
find "$directory" -type f -empty -delete -print
