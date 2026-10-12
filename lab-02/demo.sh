#!/bin/bash
set -euo pipefail
lab_dir=$(cd -- "$(dirname -- "$0")" && pwd)
export PATH="$lab_dir/scripts:$PATH"
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
cd "$workspace"
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@"; }
run pwd
run command -v system_info
run system_info
run greet.sh
run current_time.sh
run count_word.sh "$lab_dir/samples/words with spaces.txt" apple
run count_word.sh "$lab_dir/samples/words with spaces.txt" pear
printf 'apple pineapple apple\n' > boundary-words.txt
run count_word.sh boundary-words.txt apple
[[ $(count_word.sh boundary-words.txt apple) == *'appears 2 time(s)'* ]]
mkdir -p sample/nested
touch sample/empty.txt sample/nested/.empty
printf 'keep this\n' > sample/keep.txt
run find sample -type f
run delete_empty_files.sh sample
run find sample -type f
run cat sample/keep.txt
printf '\nCHECK: all five custom commands ran from another directory.\n'
