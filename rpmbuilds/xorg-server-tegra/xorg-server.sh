#!/usr/bin/bash
git clone -b f28 https://src.fedoraproject.org/rpms/xorg-x11-server.git
cd xorg-x11-server
cp * $HOME/rpmbuild/SOURCES
dnf builddep xorg-x11-server.spec
rpmbuild --undefine=_disable_source_fetch -ba xorg-x11-server.spec
