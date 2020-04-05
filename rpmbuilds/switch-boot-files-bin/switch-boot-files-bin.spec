# Maintainer: Ezekiel Bethel <zek@9net.org>

Name:			switch-boot-files-bin
Version:		r32
Release:		1
BuildArch:		aarch64
Source0:		boot-files-r32.tar.gz
License:        GPLv3+
Summary:		Switch kernel and boot files

%description
	Switch kernel and boot files

%prep
%setup

%install
	mkdir -p %buildroot/boot/ %buildroot/mnt/hos_data/
	mkdir -p %buildroot/usr/lib/modules/
	cp -r l4t-arch bootloader %buildroot/boot/
	cp -r 4.9.140+ %buildroot/usr/lib/modules/

%files
/usr/*
/boot/*

%clean
rm -rf %{buildroot}