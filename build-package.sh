#!/usr/bin/env osh

# lets start by building *all that's possible!
#set -e

if [[ -n "$1" ]]; then
  recursive=$1
fi
package="$2"
if [[ -n "$package" ]]; then
  # We want to use it's pkgname and subpackages to track deps
  source main/$package/APKBUILD
  
  # TODO: instead of waiting, the cleanup task should also start all new pkg builds
#  while [ -z "$(ls -A "deps/$pkgname")" ]; do
#    sleep 1
#  done
  
  cd main/$package
  echo "build $package. logs: /aports/${recursive}_build.log" | tee "/aports/${recursive}_build.log" 
  abuild -rq -P /aports/repo &> /aports/${recursive}_build.log
  rc=$?
  cd -
  
  if [[ "$rc" = 0 ]]; then
    find deps -name $pkgname -delete
    
    for sub in $subpackages; do
      sub="${sub%%:*}"
      find deps -name $sub -delete
    done
  else
    mkdir -p /aports/logs
    mv /aports/${recursive}_build.log /aports/logs/$package.log
  fi
fi

if [[ -n "$recursive" ]]; then
  f=$(mktemp -u)
  for pkg in $(find deps/ -empty -type d); do
    mv "$pkg" $f || true
    if ! [[ -d "$f" ]]; then
      continue
    fi
    rmdir "$f"
    ./build-package.sh "$recursive" "$(basename $pkg)"
    exit
  done
fi

