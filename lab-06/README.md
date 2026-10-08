# Lab 6: Linux permissions

The [assignment](https://docs.google.com/document/d/1sgkWFDTC5tEzzbnh5R0RYNuQmiOth6OMrH6gMbx9bO8/edit) asks for `ls -la`, numeric `chmod 754`, and discovery of how `chown` and `chgrp` affect access. This lab runs the commands in a disposable Linux container.

From the repository root:

```bash
docker build -t info-sec-course -f lab-env/Dockerfile lab-env
docker run --rm --network none --mount "type=bind,src=$PWD/lab-06/demo.sh,dst=/demo.sh,readonly" info-sec-course bash /demo.sh
```

Read the [recorded session](results/session.txt). It creates `file.txt`, shows `ls -la`, sets mode `754` and changes its owner and group. It then runs reads and writes as three real Linux users. The container disappears after the command; no account on your Mac is changed.

**Main mechanism:** `r=4`, `w=2`, `x=1`; each digit in `754` is a sum for owner, group and everyone else. `chown alice:team` sets the owner and group. With `640`, only Alice can write and the group can read. `chgrp visitors` moves that read access to a different group. `chown bob:team` makes Bob the writer. Root can bypass normal permission checks, so the examples use `su` to observe each user's actual access.

Directory `x` means traversal; file `x` means execution. They are different operations.
