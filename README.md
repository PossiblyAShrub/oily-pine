# Oily-pine

Alpine mixed with oils-for-unix.
Overwrite /bin/sh with oils.

run the following commands to get a build of all packages with oils as /bin/sh:

```
# Create oils-for-unix package from local repo
podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/build-all.sh
# Script to overwrite /bin/sh with a link to oils-for-unix and build all packages
podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/dirty-build.sh
```

TODOS:
- [ ] create & use a `build` user, tests fail as root

# Workflow

- Create Base Container with patched /bin/sh (`./build-container.sh` which uses `./build-stdenv.sh`) directly from this repo
- Run the container with its cmd `./build-all.sh`
  - It should check if /aports/ is a git folder. if not -> git clone oily-pine (`OILY_PINE_REPO`)
```bash
podman run --rm --userns=keep-id --mount "type=bind,source=./,target=/aports,rw" oily-pine-build /aports/build-all.s
```
