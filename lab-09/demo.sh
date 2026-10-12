#!/bin/bash
set -euo pipefail
[[ -f /.dockerenv && $(id -u) == 0 ]] || { echo 'Run as root in the disposable Linux container.'; exit 1; }
run() { printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@"; }
export DEBIAN_FRONTEND=noninteractive
run apt-get update
run apt-cache search '^nginx$'
run apt-cache depends nginx
run apt-get install -y nginx
run nginx -v
run dpkg-query -W -f='${Package} ${Version} ${Status}\n' nginx
run apt-get upgrade -y
run apt-get remove -y nginx
if dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -q 'install ok installed'; then
    echo 'nginx is still installed'; exit 1
fi
run dpkg-query -W -f='${Package} ${Status}\n' nginx
run apt-get purge -y nginx nginx-common
printf '\nCHECK: install, upgrade, removal and config purge completed.\n'
