#!/usr/bin/env sh
# Run this inside of:
# podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/build-all.sh

APORTSDIR=/aports

cp -R /aports/build/abuild /root/.abuild
cp -R /aports/build/abuild/-66b5b4e2.rsa.pub /etc/apk/keys
cp -R /aports/build/abuild/-66b5b4e5.rsa.pub /etc/apk/keys
mkdir -p /aports/repo

cd /aports

apk add abuild-rootbld

cd main/oils-for-unix
abuild -Fr

# TODO: all the required packages to have a running system
# Not sure what is really required
#files="
#  musl
#  ncurses
#  readline
#"
#
#for file in $files; do
#  cd /aports/main/$file
#  abuild -Fr
#done
