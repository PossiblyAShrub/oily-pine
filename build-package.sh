#!/usr/bin/env osh

package="$1"
# We want to use it's pkgname and subpackages to track deps
source main/$package/APKBUILD

# TODO: instead of waiting, the cleanup task should also start all new pkg builds
while [ -z "$(ls -A "deps/$pkgname")" ]; do
  sleep 1
done

pushd main/$package
abuild -rq
popd

# TODO: check if it is the last file remaining and only then start to build the next package
find deps -name $pkgname -rm

for sub in $subpackages; do
  sub="${sub%%:*}"
  find deps -name $sub -rm
done
