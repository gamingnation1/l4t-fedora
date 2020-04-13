FROM archlinux:latest
RUN pacman -Syu base base-devel dhcpcd iproute2 git unzip qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive lvm2 multipath-tools --noconfirm
RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
RUN yay -S qemu-user-static-bin --noconfirm
USER root
COPY . /root
RUN bash /root/l4t-fedora/builder/create-rootfs.sh