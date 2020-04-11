Name:			tegra-ffmpeg
Version:		R32
Release:		3.1
BuildArch:		aarch64
License:		GPL
URL:			https://://source.ffmpeg.org/ffmpeg.git
BuildRequires:	jetson-ffmpeg
Summary:		FFMPEG for Tegra jetson

%description
	FFMPEG for Tegra jetson

%prep
	git clone git://source.ffmpeg.org/ffmpeg.git -b release/4.2 --depth=1
	cd ffmpeg/
	wget https://github.com/jocover/jetson-ffmpeg/raw/master/ffmpeg_nvmpi.patch
	git apply ffmpeg_nvmpi.patch
	./configure --enable-nvmpi --prefix=/usr

%build
	cd ffmpeg/
	make -j$(nproc)

%install
	cd ffmpeg/
	make DEST=%buildroot install

%post
	/sbin/ldconfig

%files
/usr/*