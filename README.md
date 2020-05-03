# L4T-Fedora

Fedora Linux arm64 repository for L4T.

## Scripts options

```
Usage: create-rootfs.sh [options]
Options:
 -d, --docker   Build using Docker
 -s, --staging	Install built local packages
 -h, --help		Show this help text
```

## Building with Docker

```sh
git clone https://github.com/Azkali/l4t-fedora/
./l4t-fedora/docker-builder/build.sh
```

## Building without Docker

### Dependencies

On a Arch Linux host install `qemu-user-static` from `AUR` and :

```sh
pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive p7zip
```

### Building

- `git clone https://github.com/Azkali/l4t-fedora/`
- As root user run `./l4t-fedora/builder/create-rootfs.sh`
