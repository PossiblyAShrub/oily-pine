#!/usr/bin/env sh
# Run this inside of:
# podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/dirty-build.sh

set -xe

APORTSDIR=/aports

cp -R /aports/build/abuild /root/.abuild
cp -R /aports/build/abuild/-66b5b4e2.rsa.pub /etc/apk/keys
cp -R /aports/build/abuild/-66b5b4e5.rsa.pub /etc/apk/keys
mkdir -p /aports/repo

cd /aports

apk add abuild

cd main/oils-for-unix
abuild -Fr

apk add /aports/repo/main/x86_64/oils-for-unix-0.22.0-r0.apk
rm /bin/sh
ln -s oils-for-unix /bin/sh
# TODO: all the required packages to have a running system
# Not sure what is really required
#
/bin/sh --version

cd /aports
#ls
for file in main/*; do
  cd /aports/$file
  abuild -Fr
done
