# Maintainer: Your Name <youremail@domain.com>
Name:			switch-configs
Version:		1
Release:		4
License:		GPL
BuildArch:		noarch
Summary:		Switch specific config for Linux
Source0:		https://gitlab.com/switchroot/switch-l4t-configs
Source1:		asound.state
Source2:		10-monitor.conf
Source3:		r2p.service
Source4:		brcmfmac4356-pcie.txt
BuildRequires:	git

%description
	Switch specific config for Linux

%install
	git clone %SOURCE0
	mkdir -p %buildroot/etc/systemd/system %buildroot/etc/X11/xorg.conf.d %buildroot/usr/bin %buildroot/usr/lib/udev/rules.d %buildroot/etc/dconf/db/local.d %buildroot/etc/dconf/profile %buildroot/usr/share/alsa/ucm/tegra-snd-t210ref-mobile-rt565x/ %buildroot/usr/lib/systemd/system
	install asound.state %buildroot/var/lib/alsa/
	install r2p.service %buildroot/etc/systemd/system/
	install 10-monitor.conf %buildroot/etc/X11/xorg.conf.d/
	install brcmfmac4356-pcie.txt %buildroot/usr/lib/firmware/brcm/

	cd switch-l4t-configs

	install switch-dock-handler/92-dp-switch.rules %buildroot/usr/lib/udev/rules.d/
	install switch-dock-handler/dock-hotplug %buildroot/usr/bin/
	sed 's/sudo -u/sudo -s -u/g' -i %buildroot/usr/bin/dock-hotplug

	install switch-dconf-customizations/99-switch %buildroot/etc/dconf/db/local.d/
	install switch-dconf-customizations/user %buildroot/etc/dconf/profile/
	install switch-alsa-ucm/* %buildroot/usr/share/alsa/ucm/tegra-snd-t210ref-mobile-rt565x/
	install switch-bluetooth-service/switch-bluetooth.service %buildroot/usr/lib/systemd/system/

	install switch-touch-rules/* %buildroot/usr/lib/udev/rules.d/	


%clean
rm -rf %{buildroot}

%files
/usr/*
/etc/*