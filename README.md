# L4T-Fedora

## Docker

```sh
./docker-builder/build.sh
```

## Prepare

A SD Card with a minimum of 8Go.

### Dependencies

On Arch host install `qemu-user-static` from `AUR` and :

```sh
sudo pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive lvm2 multipath-tools p7zip
```

## Build

On your host :

- Clone this repository
- Log as root user ( `sudo su` )
- Run `./l4t-fedora/builder/create-rootfs.sh`