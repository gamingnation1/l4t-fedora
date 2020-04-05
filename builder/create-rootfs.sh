#!/bin/bash

root_dir="$(dirname "$(dirname "$(readlink -fm "$0")")")"

cleanup() {
	umount -R ${root_dir}/tmp/mnt/*
	umount -R ${root_dir}/tmp/*
	kpartx -dv ${root_dir}/l4t-fedora.img
	
	vgchange -an fedora
	kpartx -dv ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw

	rm -rf ${root_dir}/tmp/
}

prepare() {
	mkdir -p ${root_dir}/tarballs/
	mkdir -p ${root_dir}/tmp/mnt/boot/
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
	cp -r ${root_dir}/rpmbuilds/*.rpm ${root_dir}/tmp/fedora-rootfs/pkgs/

	kpartx -av ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw
	sleep 1
	vgchange -ay fedora
	sleep 1
	mount -o loop /dev/mapper/fedora-root ${root_dir}/tmp/fedora_iso_root/

	cp -prd ${root_dir}/tmp/fedora_iso_root/* ${root_dir}/tmp/fedora-rootfs/

	umount -R ${root_dir}/tmp/fedora_iso_root/
	vgchange -an fedora
	kpartx -dv ${root_dir}/tarballs/Fedora-Server-31-1.9.aarch64.raw

	echo -e "/dev/mmcblk0p1	/mnt/hos_data	vfat	rw,relatime	0	2\n/boot /mnt/hos_data/l4t-arch/	none	bind	0	0\n" > ${root_dir}/tmp/fedora-rootfs/etc/fstab

	cp /usr/bin/qemu-aarch64-static ${root_dir}/tmp/fedora-rootfs/usr/bin/
	cp /etc/resolv.conf ${root_dir}/tmp/fedora-rootfs/etc/
	
	mount --bind ${root_dir}/tmp/fedora-rootfs ${root_dir}/tmp/fedora-rootfs/
	mount --bind ${root_dir}/tmp/fedora-bootfs ${root_dir}/tmp/fedora-rootfs/boot/
	arch-chroot ${root_dir}/tmp/fedora-rootfs/ ./build-stage2.sh
	umount -R ${root_dir}/tmp/fedora-rootfs/boot/
	umount -R ${root_dir}/tmp/fedora-rootfs/
	
	rm -rf ${root_dir}/tmp/fedora-rootfs/{rpmbuilds,build-stage2.sh}
	rm -rf ${root_dir}/tmp/fedora-rootfs/usr/bin/qemu-aarch64-static
}

buildiso() {
	size=$(du -hs ${root_dir}/tmp/fedora-rootfs/ | head -n1 | awk '{print int($1+2);}')$(du -hs ${root_dir}/tmp/fedora-rootfs/ | head -n1 | awk '{print $1;}' | grep -o '[[:alpha:]]')

	dd if=/dev/zero of=${root_dir}/l4t-fedora.img bs=1 count=0 seek=$size
	
	parted ${root_dir}/l4t-fedora.img --script -- mklabel msdos
	parted -a optimal ${root_dir}/l4t-fedora.img mkpart primary 0% 476MB
	parted -a optimal ${root_dir}/l4t-fedora.img mkpart primary 477MB 100%

	loop_dev=$(kpartx -av ${root_dir}/l4t-fedora.img | grep -oh "\w*loop\w*")
	loop1=`echo "${loop_dev}" | head -1`
	loop2=`echo "${loop_dev}" | tail -1`

	mkfs.fat -F 32 /dev/mapper/${loop1}
	mkfs.ext4 /dev/mapper/${loop2}

	mount -o loop /dev/mapper/${loop1} ${root_dir}/tmp/mnt/boot/
	mount -o loop /dev/mapper/${loop2} ${root_dir}/tmp/mnt/root/
	
	cp -r ${root_dir}/tmp/fedora-bootfs/* ${root_dir}/tmp/mnt/boot/
	cp -prd ${root_dir}/tmp/fedora-rootfs/* ${root_dir}/tmp/mnt/root/
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
