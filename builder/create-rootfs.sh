#!/bin/bash

staging=no
options=$(getopt -o hs --long staging --long help -- "$@")

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo " -s, --staging	Install built local packages"
    echo " -h, --help		Show this help text"
}

[ $? -eq 0 ] || {
	usage
	exit 1
}

eval set -- "$options"
while true; do
    case "$1" in
    -s)
        staging=yes
        ;;
    --staging)
        staging=yes
        ;;
    -h|--help)
	usage
	exit 0
	;;
    --)
        shift
        break
        ;;
    esac
    shift
done

root_dir="$(dirname "$(dirname "$(readlink -fm "$0")")")"

cleanup(){
	umount -R ${root_dir}/tmp/mnt/*
	umount -R ${root_dir}/tmp/*
	rm -rf ${root_dir}/tmp/
}

prepare() {
	mkdir -p ${root_dir}/tarballs/
	mkdir -p ${root_dir}/tmp/mnt/root/
	mkdir -p ${root_dir}/tmp/fedora-bootfs/
	mkdir -p ${root_dir}/tmp/fedora-rootfs/pkgs/
	mkdir -p ${root_dir}/tmp/fedora_iso_root/

	if [[ ! -e ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw ]]; then
		wget https://download.fedoraproject.org/pub/fedora/linux/releases/31/Server/aarch64/images/Fedora-Server-31-1.9.aarch64.raw.xz -P ${root_dir}/tarballs/
		unxz ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw.xz
	fi

	if [[ ! -e ${root_dir}/tmp/fedora-rootfs/reboot_payload.bin ]]; then
		wget https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip -P ${root_dir}/tmp/
		unzip ${root_dir}/tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin ${root_dir}/tmp/fedora-rootfs/reboot_payload.bin
		rm ${root_dir}/tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi
}

setup_base() {
	cp ${root_dir}/builder/build-stage2.sh ${root_dir}/tmp/fedora-rootfs/
	
	if [[ $staging == "yes" ]]; then
		cp -r ${root_dir}/rpmbuilds/*/*.rpm ${root_dir}/tmp/fedora-rootfs/pkgs/
	fi

	losetup ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw
	vgchange -ay fedora
	mount -o loop /dev/mapper/fedora-root ${root_dir}/tmp/fedora_iso_root/

	cp -prd ${root_dir}/tmp/fedora_iso_root/* ${root_dir}/tmp/fedora-rootfs/

	umount -R ${root_dir}/tmp/fedora_iso_root/
	vgchange -an fedora
	losetup -d ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw

	echo -e "/dev/mmcblk0p1	/boot	vfat	rw,relatime	0	2\n" > ${root_dir}/tmp/fedora-rootfs/etc/fstab

	cp /usr/bin/qemu-aarch64-static ${root_dir}/tmp/fedora-rootfs/usr/bin/
	cp /etc/resolv.conf ${root_dir}/tmp/fedora-rootfs/etc/
	
	mount --bind ${root_dir}/tmp/fedora-rootfs ${root_dir}/tmp/fedora-rootfs/
	mount --bind ${root_dir}/tmp/fedora-bootfs ${root_dir}/tmp/fedora-rootfs/boot/
	arch-chroot ${root_dir}/tmp/fedora-rootfs/ ./build-stage2.sh
	umount -R ${root_dir}/tmp/fedora-rootfs/boot/
	umount -R ${root_dir}/tmp/fedora-rootfs/
	
	rm ${root_dir}/tmp/fedora-rootfs/etc/pacman.d/gnupg/S.gpg-agent*
	rm -rf ${root_dir}/tmp/fedora-rootfs/{rpmbuilds,build-stage2.sh,rpms}
	rm ${root_dir}/tmp/fedora-rootfs/usr/bin/qemu-aarch64-static
}

buildiso() {
	size=$(du -hs ${root_dir}/tmp/fedora-rootfs/ | head -n1 | awk '{print int($1+2);}')$(du -hs ${root_dir}/tmp/fedora-rootfs/ | head -n1 | awk '{print $1;}' | grep -o '[[:alpha:]]')

	rm ${root_dir}/l4t-fedora.img
	dd if=/dev/zero of=${root_dir}/l4t-fedora.img bs=1 count=0 seek=$size
	
	loop=`losetup --find`
	losetup $loop ${root_dir}/l4t-fedora.img

	mkfs.ext4 $loop
	mount $loop ${root_dir}/tmp/mnt/rootfs/

	cp -pdr ${root_dir}/tmp/fedora-rootfs/* ${root_dir}/tmp/mnt/rootfs/
	umount $loop
	losetup -d $loop

	pushd ${root_dir}/tmp/fedora-bootfs
	zip -r ${root_dir}/l4t-boot.zip *
	popd
}

if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
prepare
setup_base
buildiso
cleanup

echo "Done!\n"
