# Lab 8: Vim editor

The [assignment](https://docs.google.com/document/d/1AGwXVhwxq1Lk8HskhSQlyl9ysUTg6sBT/edit) asks to install Vim, create a file, insert lines, delete a line, clear the file, save and quit, then explore more commands. The demonstration runs actual Vim commands in a disposable Linux container; snapshots show every stage.

From the repository root:

```bash
docker build -t info-sec-course -f lab-env/Dockerfile lab-env
docker run --rm --network none --mount "type=bind,src=$PWD/lab-08,dst=/opt/info-sec-lab8,readonly" info-sec-course bash /opt/info-sec-lab8/demo.sh
```

Read the [recorded session](results/session.txt). The script uses Vim in batch mode for repeatable output. To practice interactively instead, run `docker run --rm -it info-sec-course vim /tmp/file.txt` and type these commands yourself:

| Keys | What happens |
|---|---|
| `i` | Enter Insert mode; type text. |
| `Esc` | Return to Normal mode. |
| `gg`, `j`, `dd` | Go to top, down one line, delete that line. |
| `u` | Undo the last edit. |
| `:%s/text/line/g` | Replace every occurrence in the file. |
| `:%d` | Delete all lines. |
| `:w`, `:q`, `:wq` | Save, quit, or do both. |

**Main mechanism:** Vim is *modal*: the same key means different things in Insert and Normal mode. After inserting text, press `Esc` before `dd` or any `:` command. The assignment calls deletion “DD”, but the actual Vim command is lowercase `dd`.
