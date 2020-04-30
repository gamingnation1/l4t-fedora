Name:				moonlight-qt
Version:			1
Release:			0
BuildArch:			noarch
License:			GPL
URL:				"https://github.com/moonlight-stream/%{name}"
Summary:			Moonlight-QT
BuildRequires:		git cmake gcc-c++ ffmpeg ffmpeg-libs qt5-qtbase qt5-qtbase-devel qt5-devel compat-ffmpeg28 alsa-lib-devel openssl-devel

%description
	Moonlight QT

%prep
	git clone %url
	cd %name
	git submodule update --init --recursive
	qmake-qt5 moonlight-qt.pro

%build
	cd %name
	make -j$(nproc) release

%install
	cd %name
	make DESTDIR=%buildroot install

%post
	/sbin/ldconfig

%files
/usr/*

%clean
rm -rf %{buildroot}