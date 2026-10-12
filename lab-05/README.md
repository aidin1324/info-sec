# Lab 5: Linux users and groups

Sources: [Lab 5](https://docs.google.com/document/d/1O6ATnyv85L9-AX1B96-pKn9cjAABx2Sm0AQtB2NtfKU/edit) and [Labs 4–6](https://docs.google.com/document/d/1iLU-oof3YflO--nj00r0LgKvT8UiGYt2/edit).

## Run

From the repository root, with Docker running:

```bash
docker build -t info-sec-lab5 lab-05
docker run --rm --network none info-sec-lab5
```

Accounts exist only inside this disposable Linux container. Setup runs as root. access checks run as ordinary users.

## Results

| Commands | Observed result |
|---|---|
| `useradd -m`, `chpasswd` | Account, home directory and temporary password created. |
| `getent passwd`, `su - user1 -c whoami` | Account entry exists. switched identity prints `user1`. |
| `chfn` | Full name updated in the account entry. |
| `pkill -KILL -u user1` | Temporary login session terminated. |
| `userdel -r` | Account and home directory removed. |
| `groupadd`, `usermod -aG`, `id`, `groups` | New membership added while the earlier group is retained. |
| `chown`, `chgrp`, `chmod` | Shared directory `750`, file `640`: `labstudent` reads. `laboutsider` is denied. |

[Recorded execution](results/session.txt).

## Required explanation

- `/etc/passwd`: `name:x:UID:GID:personal-info:home:shell`. UID identifies a user. GID identifies their primary group. `x` refers to password data in `/etc/shadow`. `/etc/group` records groups and explicit memberships.
- `usermod -aG` appends supplementary groups. Without `-a`, `-G` replaces the list. Start a new login session to acquire updated memberships.
- Group access enables collaboration. denying others isolates the file. Parent-directory traversal is also required.

`useradd`/`userdel` are equivalents of the assignment's interactive `adduser`/`deluser`. `getent passwd user1` shows just the relevant account. Root's `su` checks identity switching, not password authentication.
