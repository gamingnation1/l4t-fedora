#!/usr/bin/bash
uname -a

dnf -y groupinstall 'Basic Desktop' 'LXDE Desktop'

mkdir xorg/

wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-server/1.19.6/10.fc28/aarch64/xorg-x11-server-Xorg-1.19.6-10.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-nouveau/1.0.15/4.fc28/aarch64/xorg-x11-drv-nouveau-1.0.15-4.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-qxl/0.1.5/6.fc28/aarch64/xorg-x11-drv-qxl-0.1.5-6.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-fbdev/0.4.3/29.fc28/aarch64/xorg-x11-drv-fbdev-0.4.3-29.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-armsoc/1.4.0/7.20160929.fc28/aarch64/xorg-x11-drv-armsoc-1.4.0-7.20160929.fc28.aarch64.rpm -P xorg/
wget https://kojipkgs.fedoraproject.org/packages/xorg-x11-drv-ati/18.1.0/1.fc28/aarch64/xorg-x11-drv-ati-18.1.0-1.fc28.aarch64.rpm -P xorg/

dnf -y downgrade xorg/*.rpm

dnf -y install gcc git rpm-build rpm-devel rpmlint python patch rpmdevtools
rpmdev-setuptree
rpmbuild -ba /rpmbuilds/nvidia-drivers-package/tegra-bsp.spec
rpmbuild -ba /rpmbuilds/switch-configs/switch-configs.spec
rpm -ivvh --force /root/rpmbuild/RPMS/aarch64/switch-configs-1-1.aarch64.rpm
rpm -ivvh --force /root/rpmbuild/RPMS/aarch64/tegra-bsp-r32-3.1.aarch64.rpm
dnf -y remove gcc git rpm-build rpm-devel rpmlint python patch rpmdevtools
rm -rf /root/rpmbuilds

dnf -y clean all

echo l4t-fedora.local > /etc/hostname
echo '127.0.0.1   l4t-fedora.local l4t-fedora' >> /etc/hosts

echo "[Unit]
Description=Setup r2p

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo 1 > /sys/devices/r2p/default_payload' 
RemainAfterExit=true

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/r2p.service

echo 'Section "Monitor"
   Identifier "DFP-0"
   Option "Rotate" "left"
EndSection' > /etc/X11/xorg.conf.d/10-monitor.conf

echo 'sessreg -a -l $DISPLAY -x /etc/X11/xdm/Xservers $USER &' >> \
  /etc/lxdm/PostLogin
echo 'sessreg -d -l $DISPLAY -x /etc/X11/xdm/Xservers $USER &' >> \
  /etc/lxdm/PostLogout

rm -f /etc/systemd/system/display-manager.service
systemctl enable r2p
systemctl enable bluetooth
systemctl enable lxdm
systemctl set-default graphical.target
# sed -i 's/#keyboard=/keyboard=onboard/' /etc/lightdm/lightdm-gtk-greeter.conf
mv /reboot_payload.bin /lib/firmware/
