#!/usr/bin/env bash

rm -r deps
mkdir deps

for package in main/*; do
  (
    source "$package/APKBUILD"
     mkdir "deps/$pkgname"
     # At least rust doesn't do 'makedepends=$makedepends_...'. and doubletouching shouldn't hurt..
     for dep in $checkdepends $depends $makedepends $makedepends_host $makedepends_build; do
       if [[ "$dep" =~ '!' ]]; then continue; fi
       # Cut away versions. Let's pretend versioning is fine :)
       dep="${dep%%>*}"
       dep="${dep%%<*}"
       dep="${dep%%=*}"
       dep="${dep%%:*}"
       touch deps/$pkgname/$dep
     done
     # We don't need to know the dependencies of subpackages - doh!
     # We just need to remove subpackage dependencies after a build
     # REQUIRED: to remove nested dependencies
     for sub in $subpackages; do
       sub="${sub%%:*}"
       ln -s $pkgname deps/$sub
     done
  ) &
done

wait

for d in $(ls deps); do
  [[ -f deps/$d/$d ]] && rm -v deps/$d/$d 
done

