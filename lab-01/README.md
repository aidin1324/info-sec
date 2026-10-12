# Lab 1: UNIX commands

[Assignment](https://docs.google.com/document/d/1mglrCwzt-hevxKgBr-5jgQ3S4Fml2BQB/edit).

## Run

From the repository root. Use a new output directory each time:

```bash
bash lab-01/commands.sh /tmp/info-sec-lab1-results
```

## Results

| Task | Result |
|---|---|
| Basic commands | Created a directory/file, set `777`, read, copied, deleted and listed files. |
| Move all files | Three files, including a hidden file, moved. The source directory became empty. |
| `curl` | GET saved 100 posts. HEAD returned 200. POST returned the submitted fields and `id: 101`. |
| `tar` | Created, listed and extracted `tar.gz`. `diff -r` found no differences. |

`cp` keeps the original. `mv` moves it. `777` grants everyone read/write/execute and is used only on an empty disposable file. JSONPlaceholder [simulates POST without storing it](https://jsonplaceholder.typicode.com/guide/).

[File log](results/files.txt) · [HTTP log](results/http.txt) · [archive log](results/archive.txt) · [GET JSON](results/posts.json) · [POST JSON](results/post.json).

[Complete execution on 12 October 2026](results/session.txt).

## Screenshot

Unedited capture from Chrome on the laptop. The page displays the actual execution log on GitHub.

![Actual execution log in Chrome](screenshots/execution-log.jpg)
