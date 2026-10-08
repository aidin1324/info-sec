# Lab 7: crontab in Linux

The [assignment](https://docs.google.com/document/d/1OD9E6xuYSyS19sxaFH7acV74E6gjFsbCQDZY8_FxBMs/edit) asks for a cron task that runs a Python script. This one appends a timestamp and current free disk space to a local report. It does not send email.

From the repository root:

```bash
docker build -t info-sec-course -f lab-env/Dockerfile lab-env
docker run --rm --network none --mount "type=bind,src=$PWD/lab-07,dst=/opt/info-sec-lab7,readonly" info-sec-course bash /opt/info-sec-lab7/demo.sh
```

The [recorded session](results/session.txt) shows the installed crontab, the report made by the cron daemon, and removal of the container's crontab. Nothing is scheduled on your Mac.

**Main mechanism:** `* * * * *` means every minute (minute, hour, day of month, month, day of week). The extra `@reboot` line runs the same Python script when the container's cron daemon starts, so the demonstration finishes quickly. `crontab -l` lists scheduled jobs; `crontab -r` removes them. A crontab is the schedule; the `cron` daemon is the process that actually launches the command. Absolute paths matter because cron runs with a small environment.

Reference: [Debian's crontab format](https://manpages.debian.org/bookworm/cron/crontab.5.en.html) and [crontab commands](https://manpages.debian.org/bookworm/cron/crontab.1.en.html).
