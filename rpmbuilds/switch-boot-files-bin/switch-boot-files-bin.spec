# Maintainer: Ezekiel Bethel <zek@9net.org>
Name:			switch-boot-files-bin
Version:		R32
Release:		4.2
BuildArch:		noarch
Source0:		https://9net.org/l4t-arch/boot-files-r32.tar.gz
License:        GPLv3+
Summary:		Switch boot files
BuildRequires:	uboot-tools

%description
	Switch boot files

%prep
	mkdir -p %buildroot/boot/bootloader/ini %buildroot/boot/switchroot/fedora/
	mkdir -p %buildroot/usr/lib/initcpio/{hooks,install}

%install
	install l4t-fedora.ini %buildroot/boot/bootloader/ini/switchroot-fedora.ini
	install mkscr boot.scr.txt coreboot.rom %buildroot/boot/switchroot/fedora/
	mkimage -A arm -T script -O linux -d boot.scr.txt %buildroot/boot/switchroot/fedora/boot.scr

	install resize-hook %buildroot/usr/lib/initcpio/hooks/resize-rootfs
	install resize-build-hook %buildroot/usr/lib/initcpio/install/resize-rootfs
	
	mkdir -p %buildroot/boot/l4t-fedora/
	cp -r bootloader %buildroot/boot/
	cp -r l4t-fedora/{boot.scr,coreboot.rom} %buildroot/boot/l4t-fedora

%files
/usr/*
/boot/*

%clean
rm -rf %{buildroot}