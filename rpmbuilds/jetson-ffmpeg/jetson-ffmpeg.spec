Name:				jetson-ffmpeg
Version:			R32
Release:			3.1
BuildArch:			aarch64
License:			GPL
URL:				"https://github.com/jocover/jetson-ffmpeg"
Summary:			Jetson ffmpeg
BuildRequires:		git cmake gcc-c++ tegra-bsp

%description
	Jetson ffmpeg

%prep
	git clone https://github.com/jocover/jetson-ffmpeg.git

	cd jetson-ffmpeg

	# https://github.com/jocover/jetson-ffmpeg/issues/34/
	rm CMakeLists.txt
	wget https://gist.githubusercontent.com/jocover/7a60c1006e546ed821d4e609d80df765/raw/b5846cd5638832c75d9f7a682ec371c50d5c0192/CMakeLists.txt

	sed -i 's/\/usr\/src\/jetson_multimedia_api\/samples\/common\/classes\//common\//g' CMakeLists.txt
	sed -i 's/\/usr\/src\/jetson_multimedia_api\///g' CMakeLists.txt
	sed -i 's/\/usr\/lib\//\/usr\/lib64\//g' CMakeLists.txt
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