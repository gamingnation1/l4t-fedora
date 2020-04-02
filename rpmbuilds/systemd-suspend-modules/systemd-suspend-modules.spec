# Maintainer: Azkali Manad <a.ffcc7@gmail.com>
Name:		systemd-suspend-modules
Version:	1.0
Release:	2
BuildArch:	aarch64
URL:		https://aur.archlinux.org/packages/systemd-suspend-modules/
Summary:	Reload modules on suspend/hibernate with systemd
License:	GPL
Requires:	systemd
#backup=('etc/suspend-modules.conf')

%install
    # Install files
    install -Dm755 "${srcdir}/suspend-modules" "${pkgdir}/usr/lib/systemd/system-sleep/suspend-modules"
    mkdir ${pkgdir}/etc/
    touch ${pkgdir}/etc/suspend-modules.conf
