# L4T-Fedora

## Docker

```sh
docker image build -t fedoral4tbuild:1.0 .
docker run --privileged --cap-add=SYS_ADMIN --rm -i -t --name fedoral4tbuild fedoral4tbuild:1.0
```

## Prepare

A SD Card with a minimum of 8Go.

### Dependencies

On Arch host install `qemu-user-static` from `AUR` and :

```sh
sudo pacman -S qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive lvm2 multipath-tools
```

## Build

On your host :

- Switch to root user ( e.g.: `sudo su` )
- Go to l4t-fedora/
- Run `./create-rootfs.sh`
- Burn the resulting image from `l4t-fedora/l4t-fedora.img` to your SD Card
