#!/usr/bin/env bash
# Execute only in the disposable course container as root.
set -euo pipefail
if [[ $(uname -s) != Linux || ! -f /.dockerenv || $(id -u) != 0 ]]; then
    echo 'Run this lab as root inside Docker.' >&2
    exit 1
fi

groupadd team
groupadd visitors
useradd -m -s /bin/sh alice
useradd -m -s /bin/sh bob
useradd -m -s /bin/sh guest
usermod -aG team bob
usermod -aG visitors guest
mkdir -m 755 /tmp/lab6
cd /tmp/lab6

printf '$ touch file.txt; ls -la file.txt\n'
touch file.txt
ls -la file.txt
printf 'original line\n' > file.txt

printf '\n$ chmod 754 file.txt; chown alice:team file.txt\n'
chmod 754 file.txt
chown alice:team file.txt
stat -c '%A %a %U %G %n' file.txt
printf '754 = owner rwx (7), group r-x (5), others r-- (4)\n'

printf '\n$ su - alice -c "echo owner-added >> file.txt"\n'
su - alice -c 'echo owner-added >> /tmp/lab6/file.txt'
printf '$ su - bob -c "cat file.txt"\n'
su - bob -c 'cat /tmp/lab6/file.txt'
printf '$ su - bob -c "echo group-added >> file.txt"\n'
if su - bob -c 'echo group-added >> /tmp/lab6/file.txt' 2>/dev/null; then
    echo 'Unexpected group write access' >&2
    exit 1
fi
printf 'Permission denied: group has r-x but no w.\n'

printf '\n$ chmod 640 file.txt\n'
chmod 640 file.txt
stat -c '%A %a %U %G %n' file.txt
printf '$ su - guest -c "cat file.txt"\n'
if su - guest -c 'cat /tmp/lab6/file.txt' 2>/dev/null; then
    echo 'Unexpected other-user read access' >&2
    exit 1
fi
printf 'Permission denied: others have no rights.\n'

printf '\n$ chgrp visitors file.txt\n'
chgrp visitors file.txt
stat -c '%A %a %U %G %n' file.txt
printf '$ su - guest -c "cat file.txt"\n'
su - guest -c 'cat /tmp/lab6/file.txt'
printf '$ su - bob -c "cat file.txt"\n'
if su - bob -c 'cat /tmp/lab6/file.txt' 2>/dev/null; then
    echo 'Unexpected read access after group change' >&2
    exit 1
fi
printf 'Permission denied: Bob is no longer in the file group.\n'

printf '\n$ chown bob:team file.txt\n'
chown bob:team file.txt
stat -c '%A %a %U %G %n' file.txt
printf '$ su - bob -c "echo new-owner-added >> file.txt"\n'
su - bob -c 'echo new-owner-added >> /tmp/lab6/file.txt'
cat file.txt
printf '\nOwner and group changes changed real file access inside Docker.\n'
