#!/usr/bin/bash
uname -a

dnf -y update
dnf -y groupinstall 'Basic Desktop' 'LXDE Desktop'
dnf -y install lightdm onboard
# dnf -y install xorg-server-tegra tegra-bsp switch-boot-files-bin switch-configs systemd-suspend-modules
dnf -y remove xorg-x11-server-common lxdm

mkdir xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-nouveau/1.0.15/4.fc28/aarch64/xorg-x11-drv-nouveau-1.0.15-4.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-qxl/0.1.5/6.fc28/aarch64/xorg-x11-drv-qxl-0.1.5-6.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-fbdev/0.4.3/29.fc28/aarch64/xorg-x11-drv-fbdev-0.4.3-29.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-armsoc/1.4.0/7.20160929.fc28/aarch64/xorg-x11-drv-armsoc-1.4.0-7.20160929.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-ati/18.1.0/1.fc28/aarch64/xorg-x11-drv-ati-18.1.0-1.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-common-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-devel-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-Xdmx-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-Xephyr-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-Xnest-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-Xorg-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-Xvfb-1.19.6-7.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/xorg-x11-server/1.19.6/7.fc28/aarch64/xorg-x11-server-Xwayland-1.19.6-7.fc28.aarch64.rpm -P xorg/

dnf -y install xorg/*.rpm
rm -r xorg

for pkg in `find /pkgs/*.rpm -type f`; do
	rpm -ivvh --force $pkg
done

dnf -y clean all

echo 'l4t-fedora.local' > /etc/hostname
echo '127.0.0.1   l4t-fedora.local l4t-fedora' >> /etc/hosts
#sed -i 's/# autologin.*/autologin=fedora/' /etc/lxdm/lxdm.conf

#echo 'sessreg -a -l $DISPLAY -x /etc/X11/xdm/Xservers $USER &' >> \
#  /etc/lxdm/PostLogin
#echo 'sessreg -d -l $DISPLAY -x /etc/X11/xdm/Xservers $USER &' >> \
#  /etc/lxdm/PostLogout

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
systemctl set-default graphical.target

sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf

mv /reboot_payload.bin /lib/firmware/

PATH=$PATH:/usr/bin:/usr/sbin

useradd -m fedora
echo "fedora:fedora" | chpasswd
echo "root:root" | chpasswd

ldconfig