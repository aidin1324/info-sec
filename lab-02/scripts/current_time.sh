#!/bin/bash
current_time=$(date +%H:%M) || exit 1
hour=${current_time%:*}
minute=${current_time#*:}
remaining=$((18 * 60 - (10#$hour * 60 + 10#$minute)))

printf 'Current time: %s. ' "$current_time"
if [ "$remaining" -le 0 ]; then
    printf 'The work day has ended.\n'
else
    printf 'Work day ends after %d hours and %d minutes.\n' \
        "$((remaining / 60))" "$((remaining % 60))"
fi
