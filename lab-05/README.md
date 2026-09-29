# Lab 5: Linux users and groups

I reproduced the [assignment](https://docs.google.com/document/d/1O6ATnyv85L9-AX1B96-pKn9cjAABx2Sm0AQtB2NtfKU/edit) in a disposable Debian Linux container. The final task is implemented: a new user is added to a newly created group. Actual file access demonstrates the effect of membership.

## Run

From the repository root, with Docker running:

```bash
docker build -t info-sec-lab5 lab-05
docker run --rm --network none info-sec-lab5
```

The image uses `python:3.13.7-bookworm` for its Debian account-management tools. No host account files are mounted. `--rm` removes the container after execution; the lab accounts disappear with it. The script refuses to run outside a root Linux Docker container or if any lab account/group already exists.

## Commands and observed behavior

| Command | Effect |
|---|---|
| `useradd -m -s /bin/bash user1` | Creates the account and `/home/user1`. |
| `chpasswd` | Sets a temporary classroom password inside the container. |
| `getent passwd user1` | Shows the user database entry. |
| `su - user1 -c whoami` | Starts a login environment as `user1`; prints `user1`. |
| `chfn -f 'Demo Student' user1` | Updates the full-name part of the GECOS field. |
| `userdel -r user1` | Removes the account and its home directory. |
| `groupadd labteam` | Creates a new group. |
| `usermod -aG labteam labstudent` | Adds the new user to `labteam`, retaining `labreaders`. |
| `id labstudent` / `groups labstudent` | Confirms UID, primary group and supplementary groups. |

`useradd`/`userdel` are the lower-level equivalents of the assignment's interactive `adduser`/`deluser`. Commands run as root inside the container, so `sudo` is unnecessary and `su` does not prompt root for a password. This checks identity switching, not password authentication. Each `su - ... -c ...` exits before deletion, so no process-killing command is needed.

## Main mechanics / главное для защиты

- **UID** identifies a user; **GID** identifies a group. A user has one primary group and can have supplementary groups.
- `/etc/passwd` stores account metadata. Its `x` password field refers to password information stored separately in `/etc/shadow`; hashes are not printed. `/etc/group` stores group metadata and explicit memberships.
- **`-aG` = append to supplementary groups.** Without `-a`, `usermod -G` replaces the existing list. The demonstration checks that both `labreaders` and `labteam` remain.
- Existing processes keep their group credentials. A fresh `su - labstudent` session gets the updated membership.
- The shared directory has mode `750`: its group may list/traverse it. The file has mode `640`: its group may read it. `labstudent` reads the file; `laboutsider` receives `Permission denied`.

Full execution: [users and groups log](results/session.txt). `tests/test_lab05.py` repeats the operations in a new container and checks the assertions. No users or groups are created on macOS.

Command references: [usermod](https://man7.org/linux/man-pages/man8/usermod.8.html), [userdel](https://man7.org/linux/man-pages/man8/userdel.8.html), [chfn](https://man7.org/linux/man-pages/man1/chfn.1.html).
