#!/usr/bin/bash
uname -a

mv /reboot_payload.bin /lib/firmware/

dnf -y update && dnf -y groupinstall 'Basic Desktop' 'Xfce Desktop' && dnf -y install `cat base-pkgs`
dnf -y remove xorg-x11-server-common linux-firmware iscsi-initiator-utils-iscsiuio iscsi-initiator-utils clevis-luks atmel-firmware kernel*
for pkg in `find /pkgs/*.rpm -type f`; do
	rpm -ivvh --force $pkg
done
dnf -y clean all && rm -r /pkgs
# TODO: Make kernel rpm
echo '\nexclude=linux-firmware kernel* xorg-x11-server-* xorg-x11-drv-ati xorg-x11-drv-armsoc xorg-x11-drv-nouveau xorg-x11-drv-ati xorg-x11-drv-qxl xorg-x11-drv-fbdev' >> /etc/dnf/dnf.conf

# rm -f /etc/systemd/system/display-manager.service
systemctl enable r2p bluetooth lightdm NetworkManager
# systemctl set-default graphical.target
sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

/usr/bin/useradd -m fedora
/usr/bin/usermod -aG video,audio fedora
echo "fedora:fedora" | /usr/bin/chpasswd && echo "root:root" | /usr/bin/chpasswd

/usr/sbin/ldconfig