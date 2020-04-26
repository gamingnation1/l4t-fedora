Name:				moonlight-qt
Version:			1
Release:			0
BuildArch:			aarch64
License:			GPL
URL:				"https://github.com/moonlight-stream/monlight-qt"
Summary:			Moonlight QT
BuildRequires:		git cmake gcc-c++ tegra-bsp jetson-ffmpeg tegra-ffmpeg qt5-qtbase qt5-qtbase-devel qt5-devel compat-ffmpeg28

%description
	Moonlight QT

%prep
	git clone https://github.com/moonlight-stream/monlight-qt

	cd moonlight-qt
	qmake-qt5 moonlight-qt.pro

%build
	cd moonlight-qt
	make -j$(nproc) release

%install
	cd moonlight-qt
	make install

%post
	/sbin/ldconfig

%files
/usr/*