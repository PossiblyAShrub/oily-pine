#!/usr/bin/env bash

set -e

cont=$(buildah from alpine)

buildah run --mount "type=bind,source=$(pwd),target=/aports" $cont /aports/build-stdenv.sh
buildah copy $cont ./build-all.sh /bin/build-all.sh
buildah config -u packager $cont
buildah config --workingdir /aports \
  --volume /aports \
  --unsetlabel alpine \
  --label oily-pine \
  --env APORTSDIR=/aports \
  --cmd /bin/build-all.sh \
  $cont
buildah commit $cont oily-ci-builder

# create user

