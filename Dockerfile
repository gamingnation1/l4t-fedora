FROM archlinux:latest
RUN pacman -Syu base base-devel dhcpcd iproute2 git wget unzip qemu qemu-arch-extra arch-install-scripts parted dosfstools wget libarchive lvm2 multipath-tools --noconfirm
RUN git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
RUN yay -S qemu-user-static-bin --noconfirm
USER root
COPY . /root
RUN cd /root/l4t-fedora/ && ./create-rootfs.sh 