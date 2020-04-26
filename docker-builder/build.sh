#!/usr/bin/bash
APP_ROOT="$(dirname "$(dirname "$(readlink -fm "$0")")")"
docker image build -t fedoral4tbuild:1.0 "$APP_ROOT"/docker-builder
docker run --privileged --cap-add=SYS_ADMIN --rm -it -v "$APP_ROOT":/root/l4t-fedora fedoral4tbuild:1.0 /root/l4t-fedora/builder/create-rootfs.sh