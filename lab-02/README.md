# Lab 2: custom UNIX commands

[Assignment](https://docs.google.com/document/d/10NiPchRJCOz84ndxy1rQ3dR7A5FAjIS1-Evz1qzJURA/edit).

## Run

From the repository root:

```bash
export PATH="$PWD/lab-02/scripts:$PATH"
system_info
greet.sh
current_time.sh
count_word.sh "lab-02/samples/words with spaces.txt" apple
```

`PATH` applies to the current terminal. the commands also work from another directory. Scripts are executable. The assignment's `/usr/local/bin/system_info` installation was also [checked inside Linux Docker](results/linux-path.txt).

For cleanup, create disposable files:

```bash
sample_dir=$(mktemp -d)
mkdir "$sample_dir/nested"
touch "$sample_dir/empty.txt" "$sample_dir/nested/.empty"
printf 'keep this\n' > "$sample_dir/keep.txt"
delete_empty_files.sh "$sample_dir"
find "$sample_dir" -type f
```

## Results

| Command | Result |
|---|---|
| `system_info` | Hostname, username and disk usage. available through `PATH`. |
| `greet.sh` | Greeting uses the current username from `whoami`. |
| `current_time.sh` | Counts down to 18:00. at 18:00 or later reports that work ended. |
| `count_word.sh` | `apple`: 4. `pear`: 0. Matches whole words with matching case. |
| `delete_empty_files.sh` | Prints and removes nested empty files. preserves nonempty files and does not follow symlinks within that directory. |

[Command log](results/commands.txt) · [word counts](results/words.txt) · [cleanup](results/cleanup.txt).

[Complete execution on 12 October 2026](results/session.txt).

Run the full demonstration with `bash lab-02/demo.sh`.
