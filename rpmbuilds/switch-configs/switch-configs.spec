# Maintainer: Your Name <youremail@domain.com>
Name:		switch-configs
Version:	1
Release:	1
License:	GPL
BuildArch:	aarch64
Summary:	Switch specific config for Linux
# Source0:	git+https://gitlab.com/switchroot/switch-l4t-configs.git

%description
	Switch specific config for Linux

%install
	git clone https://gitlab.com/switchroot/switch-l4t-configs.git 
	mkdir -p %buildroot/etc/systemd/system %buildroot/etc/X11/xorg.conf.d %buildroot/usr/bin %buildroot/usr/lib64/udev/rules.d %buildroot/etc/dconf/db/local.d %buildroot/etc/dconf/profile %buildroot/usr/share/alsa/ucm/tegra-snd-t210ref-mobile-rt565x/ %buildroot/usr/lib64/systemd/system

	cd switch-l4t-configs

	cp switch-dock-handler/92-dp-switch.rules %buildroot/usr/lib64/udev/rules.d/
	cp switch-dock-handler/dock-hotplug %buildroot/usr/bin/
	sed 's/sudo -u/sudo -s -u/g' -i %buildroot/usr/bin/dock-hotplug

	cp switch-dconf-customizations/99-switch %buildroot/etc/dconf/db/local.d/
	cp switch-dconf-customizations/user %buildroot/etc/dconf/profile/
	cp switch-alsa-ucm/* %buildroot/usr/share/alsa/ucm/tegra-snd-t210ref-mobile-rt565x/
	cp switch-bluetooth-service/switch-bluetooth.service %buildroot/usr/lib64/systemd/system/
	cp switch-touch-rules/* %buildroot/usr/lib64/udev/rules.d/

%clean

%files
/usr/*
/etc/*