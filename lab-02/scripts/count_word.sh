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

# BSD grep -w -o can stop at a rejected substring and miss later words.
count=$(COUNT_WORD="$word" LC_ALL=C awk '
    BEGIN { word = ENVIRON["COUNT_WORD"]; size = length(word) }
    {
        offset = 0
        remaining = $0
        while ((position = index(remaining, word)) > 0) {
            position += offset
            before = position > 1 ? substr($0, position - 1, 1) : ""
            after = substr($0, position + size, 1)
            if (before !~ /[[:alnum:]_]/ && after !~ /[[:alnum:]_]/) total++
            offset = position + size - 1
            remaining = substr($0, offset + 1)
        }
    }
    END { print total + 0 }
' "$file") || exit "$?"
printf "The word '%s' appears %s time(s) in '%s'.\n" "$word" "$count" "$file"
