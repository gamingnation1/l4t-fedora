Name:				jetson-ffmpeg
Version:			R32
Release:			4.2
BuildArch:			noarch
License:			GPL
URL:				"https://github.com/jocover/${name}"
Source0:			CMakeLists.txt
Summary:			Jetson ffmpeg
BuildRequires:		git cmake gcc-c++ tegra-bsp mesa-libEGL-devel

%description
	Jetson ffmpeg

%prep
	git clone %url
	cd %name

	# https://github.com/jocover/jetson-ffmpeg/issues/34/
	cp %SOURCE0 .

	mkdir build

%build
	cd %name/build
	cmake -DCMAKE_INSTALL_PREFIX=/usr -DLIB_SUFFIX=64 ..
	make -j$(nproc)

%install
	cd %name/build
	make DESTDIR=%buildroot install

%post
	/sbin/ldconfig

%files
/usr/*

%clean
rm -rf %{buildroot}