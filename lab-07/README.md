# Lab 7: cron in Linux

[Assignment](https://docs.google.com/document/d/1OD9E6xuYSyS19sxaFH7acV74E6gjFsbCQDZY8_FxBMs/edit).

## Run

From the repository root, with Docker running:

```bash
docker build -t info-sec-course -f lab-env/Dockerfile lab-env
docker run --rm --network none --mount "type=bind,src=$PWD/lab-07,dst=/opt/info-sec-lab7,readonly" info-sec-course bash /opt/info-sec-lab7/demo.sh
```

Allow up to 130 seconds. The container runs both jobs on two consecutive minute ticks, prints their output, then removes its crontab. No host schedule is changed.

## Results

- `write_line.sh` reproduces the Bash example: appends a UTC timestamp to `/tmp/lab7/file.txt`.
- `job.py` completes the Python task: appends a UTC timestamp and free disk space in MiB to `/tmp/lab7/reports.txt`. Email is only an example in the assignment, not a requirement.
- [Recorded execution](results/session.txt) shows two scheduled runs of each job. Neither script is run manually by the demonstration. there is no `@reboot` shortcut.

`* * * * *` means every minute: minute, hour, day of month, month, weekday. `crontab -e` edits the schedule. `crontab FILE` installs a prepared schedule. `-l` lists it. `-r` removes it. The `cron` daemon executes the commands. Absolute paths and an explicit `PATH` avoid dependence on an interactive shell's environment.
