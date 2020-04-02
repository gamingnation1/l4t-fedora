#!/bin/bash

cleanup() {
	umount -R tmp/mnt/boot/
	umount -R tmp/mnt/root/
	kpartx -dv l4t-fedora.img
	
	umount -R tmp/fedora-rootfs/
	umount -R tmp/fedora_iso_root/
	vgchange -an fedora
	kpartx -dv tarballs/Fedora-Server-31-1.9.aarch64.raw

	rm -rf tmp/
}

prepare() {
	mkdir -p tarballs/
	mkdir -p tmp/
	mkdir -p tmp/fedora-bootfs/
	mkdir -p tmp/fedora-rootfs/
	mkdir -p tmp/fedora_iso_root/

	if [[ ! -e tarballs/Fedora-Server-31-1.9.aarch64.raw ]]; then
		wget -O tarballs/Fedora-Server-31-1.9.aarch64.raw.xz https://download.fedoraproject.org/pub/fedora/linux/releases/31/Server/aarch64/images/Fedora-Server-31-1.9.aarch64.raw.xz
		unxz tarballs/Fedora-Server-31-1.9.aarch64.raw.xz
	fi

	if [[ ! -e tmp/fedora-rootfs/reboot_payload.bin ]]; then
		wget https://github.com/CTCaer/hekate/releases/download/v5.1.3/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip -P tmp/
		unzip tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip hekate_ctcaer_5.1.3.bin
		mv hekate_ctcaer_5.1.3.bin tmp/fedora-rootfs/reboot_payload.bin
		rm tmp/hekate_ctcaer_5.1.3_Nyx_0.8.6.zip
	fi
}

## TODO: Up to date kernel should be online
setup_bootfs() {
	cp -r kernel/bootfs/* tmp/fedora-bootfs/
	cp -prd kernel/rootfs/lib/{firmware,modules} tmp/fedora-rootfs/usr/lib64/
}

setup_rootfs() {
	cp build-stage2.sh tmp/fedora-rootfs/
	cp -r rpmbuilds/ tmp/fedora-rootfs/
	
	kpartx -av tarballs/Fedora-Server-31-1.9.aarch64.raw
	sleep 1
	vgchange -ay fedora
	sleep 1
	mount -o loop /dev/mapper/fedora-root tmp/fedora_iso_root/

	cp -prd tmp/fedora_iso_root/* tmp/fedora-rootfs/

	umount -R tmp/fedora_iso_root/
	vgchange -an fedora
	kpartx -dv tarballs/Fedora-Server-31-1.9.aarch64.raw

	echo -e "/dev/mmcblk0p1	/mnt/hos_data	vfat	rw,relatime	0	2\n/boot /mnt/hos_data/l4t-fedora/	none	bind	0	0" >> tmp/fedora-rootfs/etc/fstab

	cp /usr/bin/qemu-aarch64-static tmp/fedora-rootfs/usr/bin/
	cp /etc/resolv.conf tmp/fedora-rootfs/etc/
	
	mount --bind tmp/fedora-rootfs tmp/fedora-rootfs
	arch-chroot tmp/fedora-rootfs/ ./build-stage2.sh
	sleep 5
	umount -R tmp/fedora-rootfs/
}

buildiso() {
	mkdir -p tmp/mnt/boot/
	mkdir -p tmp/mnt/root/

	size=$(du -hs tmp/fedora-rootfs/ | head -n1 | awk '{print int($1+1);}')$(du -hs tmp/fedora-rootfs/ | head -n1 | awk '{print $1;}' | grep -o '[[:alpha:]]')

	dd if=/dev/zero of=l4t-fedora.img bs=1 count=0 seek=$size
	
	parted l4t-fedora.img --script -- mklabel msdos
	parted -a optimal l4t-fedora.img mkpart primary 0% 476MB
	parted -a optimal l4t-fedora.img mkpart primary 477MB 100%

	loop_dev=$(kpartx -av l4t-fedora.img | grep -oh "\w*loop\w*")
	loop1=`echo "${loop_dev}" | head -1`
	loop2=`echo "${loop_dev}" | tail -1`

	mkfs.fat -F 32 /dev/mapper/${loop1}
	mkfs.ext4 /dev/mapper/${loop2}

	mount -o loop /dev/mapper/${loop1} tmp/mnt/boot/
	mount -o loop /dev/mapper/${loop2} tmp/mnt/root/
	
	cp -r tmp/fedora-bootfs/* tmp/mnt/boot/
	cp -prd tmp/fedora-rootfs/* tmp/mnt/root/
}

if [[ `whoami` != root ]]; then
	echo hey! run this as root.
	exit
fi

cleanup
prepare
setup_rootfs
setup_bootfs
buildiso
cleanup

echo "Done!\n"
