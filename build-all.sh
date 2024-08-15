#!/usr/bin/env sh
# Run this inside of:
# podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/build-all.sh

set -x

cp -R /aports/build/abuild /root/.abuild
cp -R /aports/build/abuild/-66b5b4e2.rsa.pub /etc/apk/keys
cp -R /aports/build/abuild/-66b5b4e5.rsa.pub /etc/apk/keys
mkdir -p /aports/repo

cd /aports
# Setup repo
echo '/aports/repo/main' > /etc/apk/repositories
echo '/aports/repo/community' >> /etc/apk/repositories
#echo '/aports/repo/testing' >> /etc/apk/repositories
apk cache clean --purge

# TODO: this should 'update' busybox-bin to use the overwritten oils-for-unix one
apk update
apk upgrade

