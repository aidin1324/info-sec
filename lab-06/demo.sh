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
ls -la file.txt
stat -c '%A %a %U %G %n' file.txt
printf '754 = owner rwx (7), group r-x (5), others r-- (4)\n'

printf '\n$ su - alice -c "echo owner-added >> file.txt"\n'
su - alice -c 'echo owner-added >> /tmp/lab6/file.txt'
printf '$ su - bob -c "cat file.txt"\n'
su - bob -c 'cat /tmp/lab6/file.txt'
printf '$ su - bob -c "echo group-added >> file.txt"\n'
if su - bob -c 'echo group-added >> /tmp/lab6/file.txt'; then
    echo 'Unexpected group write access' >&2
    exit 1
fi
printf 'Permission denied: group has r-x but no w.\n'

printf '\n$ chmod 640 file.txt\n'
chmod 640 file.txt
stat -c '%A %a %U %G %n' file.txt
printf '$ su - guest -c "cat file.txt"\n'
if su - guest -c 'cat /tmp/lab6/file.txt'; then
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
if su - bob -c 'cat /tmp/lab6/file.txt'; then
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

printf '\n$ install -d -m 700 -o alice -g alice private\n'
install -d -m 700 -o alice -g alice private
printf '$ install -d -m 750 -o alice -g team shared\n'
install -d -m 750 -o alice -g team shared
printf 'Private classroom note.\n' > private/secret.txt
printf 'Shared classroom note.\n' > shared/note.txt
chown alice:alice private/secret.txt
chmod 600 private/secret.txt
chown alice:team shared/note.txt
chmod 640 shared/note.txt
printf '$ ls -ld private shared private/secret.txt shared/note.txt\n'
ls -ld private shared private/secret.txt shared/note.txt

printf '\n$ su - bob -c "cat /tmp/lab6/private/secret.txt"\n'
if su - bob -c 'cat /tmp/lab6/private/secret.txt'; then
    echo 'Unexpected access to private directory' >&2
    exit 1
fi
printf '$ su - bob -c "cat /tmp/lab6/shared/note.txt"\n'
su - bob -c 'cat /tmp/lab6/shared/note.txt'

printf '\n$ chmod 740 shared\n'
chmod 740 shared
printf '$ su - bob -c "cat /tmp/lab6/shared/note.txt"\n'
if su - bob -c 'cat /tmp/lab6/shared/note.txt'; then
    echo 'Unexpected access without directory traversal permission' >&2
    exit 1
fi
printf 'The file is group-readable, but its directory also needs x.\n'
printf '$ chmod 750 shared\n'
chmod 750 shared
su - bob -c 'cat /tmp/lab6/shared/note.txt'

printf '\nUnsafe permissions on disposable data:\n'
printf 'Original note.\n' > exposed.txt
chown alice:team exposed.txt
printf '$ chmod 666 exposed.txt\n'
chmod 666 exposed.txt
printf '$ su - guest -c "echo outsider-changed >> /tmp/lab6/exposed.txt"\n'
su - guest -c 'echo outsider-changed >> /tmp/lab6/exposed.txt'
cat exposed.txt
printf '$ chmod 640 exposed.txt\n'
chmod 640 exposed.txt
printf '$ su - guest -c "echo another-change >> /tmp/lab6/exposed.txt"\n'
if su - guest -c 'echo another-change >> /tmp/lab6/exposed.txt'; then
    echo 'Unexpected outsider write after restricting permissions' >&2
    exit 1
fi
printf '$ ls -la exposed.txt\n'
ls -la exposed.txt
printf 'Least privilege: owner writes, team reads, outsiders have no access.\n'
printf '\nOwner and group changes changed real file access inside Docker.\n'
