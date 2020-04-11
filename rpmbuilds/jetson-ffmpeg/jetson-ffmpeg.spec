Name:				jetson-ffmpeg
Version:			R32
Release:			3.1
BuildArch:			aarch64
License:			GPL
URL:				"https://github.com/jocover/jetson-ffmpeg"
Summary:			Jetson ffmpeg

%description
	Jetson ffmpeg

%prep
	git clone https://github.com/jocover/jetson-ffmpeg.git

	cd jetson-ffmpeg
	mkdir build

%build
	cd jetson-ffmpeg/build
	cmake ..
	make -j$(nproc)

%install
	cd jetson-ffmpeg/build
	install -m644 libnvmpi.so.1.0.0 %buildroot/usr/lib/libnvmpi.so.1.0.0
	install -m644 libnvmpi.so %buildroot/usr/lib/libnvmpi.so
	install -m644 ../nvmpi.h %buildroot/usr/include/nvmpi.h
	install -m644 nvmpi.pc %buildroot/usr/share/pkgconfig/nvmpi.pc

%post
	/sbin/ldconfig

%files
/usr/*