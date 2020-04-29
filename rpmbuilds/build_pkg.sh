#!/usr/bin/bash
[[ ! -d $1 ]] && echo "No target directory specified .. Exiting now" && exit 1
pkg=$1/*.spec

dnf builddep $pkg
rpmbuild --undefine=_disable_source_fetch -ba $pkg
