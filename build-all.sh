#!/usr/bin/env sh
# Run this inside of:
# podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/build-all.sh

set -ex

mkdir -p /aports/repo

cd /aports

./build-package.sh 1
#for file in $(ls deps); do
#        ./build-package.sh $file &
#done
# Setup repo
# TODO: this should 'update' busybox-bin to use the overwritten oils-for-unix one
# apk update
# apk upgrade

