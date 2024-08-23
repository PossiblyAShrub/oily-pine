#!/usr/bin/env sh

set -x

# Running on a dev machine:
#   1. Make sure the repo has been cloned
#   2. Run `./dev.sh start`

# Here is the process:
#   1. Spin up a docker container of a barebones alpine image
#   2. Make sure that container mounts *this repo* to /aports
#   3. Install doas and alpine-sdk packages
#   4. Setup a packager user
#   5. Add the packager user to abuild groups
#   6. Enable doas for packager user (and sync w/ doas -C)
#   7. Recursively set the /aports group to abuild
#   8. Give the abuild group write permissions over /aports
#   9. Generate abuild keys for the packager user
#  10. Build oils-for-unix and readline packages
#  11. Install our bootstrap stdenv (packages built without oils that let us build more packages)
#  12. Point apk repos to our local /aports
#  13. Install newly built osh with apk
#  14. Replace /bin/sh with osh and then start building!
#
#    Reference: https://wiki.alpinelinux.org/wiki/Include:Setup_your_system_and_account_for_building_packages
#               https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package
# Derived from: https://github.com/Melkor333/oily-pine/blob/master/build-stdenv.sh

start() {
  # ulimit prevents hanging on "entering fakeroot..."
  docker run -it --rm --mount "type=bind,source=./,target=/aports" --ulimit "nofile=1024:1048576" alpine /aports/dev.sh worker
}

installPkgs() {
  apk add alpine-sdk doas
}

createPkgr() {
  adduser -Du 1000 packager
  addgroup packager abuild
  echo "permit nopass packager" >> /etc/doas.conf
  doas -C /etc/doas.conf
}

setupPerms() {
  chgrp abuild /var/cache/distfiles
  chmod g+w /var/cache/distfiles

  chgrp abuild /aports
  chmod g+w /aports
}

generateKey() {
  su packager -c "abuild-keygen -na --install"
}

setupStdenv() {
  apk add build-base               # Required to build anything C/C++
  apk add pigz                     # Needed whenever we `abuild -r` something
  apk add zlib-dev bzip2-dev perl  # Should be enough for mksh
}

buildPkg() {
  if [[ -z "$1" ]]; then
    echo 'Usage: build-pkg PKGNAME' 2>&1
    return 1
  fi

  pkg=$1

  su packager -c "cd /aports/main/$pkg && abuild -r"
}

buildOils() {
  apk add readline
  buildPkg oils-for-unix
}

switch() {
  echo '/home/packager/packages/main/' > /etc/apk/repositories 
  apk cache clean --purge
}

installOils() {
  apk add oils-for-unix
  rm /bin/sh
  ln -s oils-for-unix /bin/sh
}

worker() {
  installPkgs
  createPkgr
  setupPerms
  generateKey
  buildOils
  setupStdenv
  switch
  installOils

  echo 'Run /aports/dev.sh buildMksh to build mksh!'
  exec sh
}

buildMksh() {
  buildPkg mksh
  apk add mksh
}

"$@"
