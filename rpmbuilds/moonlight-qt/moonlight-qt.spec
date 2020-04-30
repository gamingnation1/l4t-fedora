Name:				moonlight
Version:			1
Release:			0
BuildArch:			aarch64
License:			GPL
URL:				"https://github.com/moonlight-stream/moonlight-qt"
Summary:			Moonlight-QT
BuildRequires:		git cmake gcc-c++ tegra-bsp jetson-ffmpeg tegra-ffmpeg qt5-qtbase qt5-qtbase-devel qt5-devel compat-ffmpeg28 alsa-lib-devel openssl-devel

%description
	Moonlight QT

%prep
	git clone %url
	cd moonlight-qt
	git submodule update --init --recursive
	qmake-qt5 moonlight-qt.pro

%build
	cd moonlight-qt
	make -j$(nproc) release

%install
	cd moonlight-qt
	make DESTDIR=%buildroot install

%post
	/sbin/ldconfig

%files
/usr/*