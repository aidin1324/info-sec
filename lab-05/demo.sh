#!/usr/bin/env bash
# Disposable Linux account demonstration. Never run account commands on the host.
set -euo pipefail

if [[ $(uname -s) != Linux || ! -f /.dockerenv || $(id -u) != 0 ]]; then
    echo 'Run this demonstration as root inside the disposable lab Docker container.' >&2
    exit 1
fi
for name in user1 labstudent laboutsider labreaders labteam; do
    if getent passwd "$name" >/dev/null || getent group "$name" >/dev/null; then
        echo "Refusing to change existing account/group: $name" >&2
        exit 1
    fi
done

run() {
    printf '\n$'
    printf ' %q' "$@"
    printf '\n'
    "$@"
}

printf 'Lab 5: users, groups and permissions (isolated Linux container)\n'
run useradd -m -s /bin/bash user1
printf '\n$ printf "user1:<temporary classroom password>" | chpasswd\n'
printf 'user1:LabOnly-2026!\n' | chpasswd
run getent passwd user1
run ls -ld /home/user1
[[ -d /home/user1 ]]
run su - user1 -c whoami
[[ $(su - user1 -c whoami) == user1 ]]
printf 'CHECK: switched identity = user1\n'

run chfn -f 'Demo Student' user1
run getent passwd user1
[[ $(getent passwd user1 | cut -d: -f5 | cut -d, -f1) == 'Demo Student' ]]
printf 'CHECK: full name updated\n'

# The su command has exited, so there is no live user1 session to kill.
run userdel -r user1
if getent passwd user1 >/dev/null; then
    echo 'user1 was not removed' >&2
    exit 1
fi
[[ ! -e /home/user1 ]]
printf 'CHECK: user1 and home removed\n'

run groupadd labreaders
run groupadd labteam
run useradd -m -s /bin/bash -G labreaders labstudent
run usermod -aG labteam labstudent
run getent group labteam
run id labstudent
run groups labstudent
memberships=" $(id -nG labstudent) "
[[ $memberships == *' labreaders '* && $memberships == *' labteam '* ]]
printf 'CHECK: both supplementary groups retained\n'
run su - labstudent -c 'id; groups'

# Group membership has a concrete consequence: access to a shared file.
run install -d -m 750 -o root -g labteam /tmp/lab5-shared
printf 'A file readable by labteam.\n' > /tmp/lab5-shared/note.txt
run chown root:labteam /tmp/lab5-shared/note.txt
run chmod 640 /tmp/lab5-shared/note.txt
run ls -ld /tmp/lab5-shared /tmp/lab5-shared/note.txt
run su - labstudent -c 'cat /tmp/lab5-shared/note.txt'
printf 'CHECK: labstudent read group file\n'
run useradd -m -s /bin/bash laboutsider
printf '\n$ su - laboutsider -c "cat /tmp/lab5-shared/note.txt"\n'
if su - laboutsider -c 'cat /tmp/lab5-shared/note.txt'; then
    echo 'Unexpected access by outsider' >&2
    exit 1
fi
printf 'CHECK: outsider denied group file\n'
printf '\nAll Linux account checks passed. Container removal discards the lab accounts.\n'
