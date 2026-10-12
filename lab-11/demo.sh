#!/bin/bash
set -euo pipefail
[[ -f /.dockerenv && $(id -u) == 0 ]] || { echo 'Run in disposable Docker.'; exit 1; }
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@"; }
mkdir -p /tmp/lab11
cd /tmp/lab11
run git clone --depth 1 --quiet https://github.com/ytdl-org/youtube-dl.git
cd youtube-dl
run git fetch --depth 1 --quiet origin 956b8c585591b401a543e409accb163eeaaa1193
run git checkout --quiet 956b8c585591b401a543e409accb163eeaaa1193
run git rev-parse HEAD
run /usr/bin/python3 setup.py install
run youtube-dl --version
cd /tmp/lab11
run git clone --depth 1 --quiet https://github.com/dylanaraps/neofetch.git
cd neofetch
run git fetch --depth 1 --quiet origin ccd5d9f52609bbdcd5d8fa78c4fdb0f12954125f
run git checkout --quiet ccd5d9f52609bbdcd5d8fa78c4fdb0f12954125f
run git rev-parse HEAD
run make install
run neofetch --stdout
cd /tmp/lab11
run curl -fL https://ftp.gnu.org/gnu/hello/hello-2.12.2.tar.gz -o hello.tar.gz
printf '%s\n' '5a9a996dc292cc24dcf411cee87e92f6aae5b8d13bd9c6819b4c7a9dce0818ab  hello.tar.gz' | sha256sum -c -
run tar -xzf hello.tar.gz
cd hello-2.12.2
run ./configure --prefix=/opt/hello
run make -j2
run make install
run /opt/hello/bin/hello --version
run /opt/hello/bin/hello
printf '\nInstalled commands:\n'
run command -v youtube-dl neofetch
run youtube-dl --version
run /opt/hello/bin/hello --version
run /opt/hello/bin/hello
printf '\nCHECK: youtube-dl, neofetch and GNU Hello installed from source.\n'
