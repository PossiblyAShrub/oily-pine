#!/usr/bin/env bash

set -e

cont=$(buildah from alpine)

buildah run --mount "rw,type=bind,source=$(pwd),target=/aports" $cont /aports/build-stdenv.sh
#buildah copy $cont ./build-all.sh /bin/build-all.sh
buildah config -u packager $cont
buildah config --workingdir /aports \
  --volume /aports \
  --label - \
  --env APORTSDIR=/aports \
  --cmd /aports/build-all.sh \
  $cont
buildah commit $cont oily-pine-build

# create user

