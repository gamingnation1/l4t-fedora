#!/usr/bin/bash
uname -a

dnf -y update
dnf -y groupinstall 'Basic Desktop' 'LXDE Desktop'
dnf -y remove xorg-x11-server-common lxdm linux-firmware iscsi-initiator-utils-iscsiuio iscsi-initiator-utils clevis-luks atmel-firmware
dnf -y install `cat base-pkgs`
# dnf -y install tegra-bsp switch-boot-files-bin switch-configs systemd-suspend-modules

for pkg in `find /pkgs/*.rpm -type f`; do
	rpm -ivvh --force $pkg
done

dnf -y clean all

echo 'exclude=linux-firmware xorg-x11-server-* xorg-x11-drv-ati xorg-x11-drv-armsoc xorg-x11-drv-nouveau xorg-x11-drv-ati xorg-x11-drv-qxl xorg-x11-drv-fbdev' >> /etc/dnf/dnf.conf 
echo 'l4t-fedora.local' > /etc/hostname
echo '127.0.0.1   l4t-fedora.local l4t-fedora' >> /etc/hosts

echo "[Unit]
Description=Setup r2p

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo 1 > /sys/devices/r2p/default_payload_ready' 
RemainAfterExit=true

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/r2p.service

echo 'Section "Monitor"
   Identifier "DFP-0"
   Option "Rotate" "left"
EndSection' > /etc/X11/xorg.conf.d/10-monitor.conf

rm -f /etc/systemd/system/display-manager.service
systemctl enable r2p
systemctl enable bluetooth
systemctl enable lightdm
systemctl enable NetworkManager
systemctl set-default graphical.target

sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

mv /reboot_payload.bin /lib/firmware/

PATH=$PATH:/usr/bin:/usr/sbin

useradd -m fedora
echo "fedora:fedora" | chpasswd
echo "root:root" | chpasswd
gpasswd -a fedora audio
gpasswd -a fedora video

ldconfig