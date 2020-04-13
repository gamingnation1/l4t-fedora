# Maintainer: Your Name <youremail@domain.com>
Name:		tegra-bsp
Version:	r32
Release:	3.1
License:	GPL
BuildArch:	aarch64
Summary:	Nvidia drivers for Tegra210
URL:		https://developer.nvidia.com/embedded/dlc/r32-3-1_Release_v1.0/t210ref_release_aarch64/Tegra210_Linux_R32.3.1_aarch64.tbz2

%define NVdir   %{name}-%{version}

%description
	Nvidia drivers for Tegra210

%prep
	rm -rf %{NVdir}
	wget %{url} -P %{NVdir}
	cd %{NVdir}
	tar xvf Tegra210_Linux_R32.3.1_aarch64.tbz2
	rm Tegra210_Linux_R32.3.1_aarch64.tbz2

%build
	cd %{NVdir}
	tar xvf Linux_for_Tegra/nv_tegra/nvidia_drivers.tbz2
	tar xvf Linux_for_Tegra/nv_tegra/config.tbz2

%install
	# Hold on. We don't want ALL of /etc.
	mkdir -p %buildroot/etc/
	mkdir -p %buildroot/etc/systemd/system

	sed -e 's_/usr/lib/aarch64-linux-gnu_/usr/lib64/aarch64-linux-gnu/_' -i %{NVdir}/etc/nv_tegra_release
	sed -e 's_/usr/lib/_/usr/lib64/_' -i %{NVdir}/etc/nv_tegra_release
	cp %{NVdir}/etc/nv_tegra_release %buildroot/etc/nv_tegra_release
	cp -r %{NVdir}/etc/ld.so.conf.d %buildroot/etc/ld.so.conf.d
	echo "/usr/lib64/aarch64-linux-gnu/tegra" > %buildroot/etc/ld.so.conf.d/nvidia-tegra.conf
	echo "/usr/lib64/aarch64-linux-gnu/tegra-egl" > %buildroot/etc/ld.so.conf.d/ld.so.conf

	cp %{NVdir}/etc/systemd/nv* %buildroot/etc/systemd/
	cp -d %{NVdir}/etc/systemd/system/nv*service %buildroot/etc/systemd/system/
	cp %{NVdir}/etc/asound.conf.* %buildroot/etc/
	
	# Get the udev rules & xorg config.
	cp -r %{NVdir}/etc/udev/ %buildroot/etc/udev
	mkdir %buildroot/etc/X11
	cp -r %{NVdir}/etc/X11/xorg.conf %buildroot/etc/X11/

	mkdir -p %buildroot/usr/lib64/firmware/ %buildroot/usr/lib64/systemd/
	
	# Copy usr/lib/aarch64-linux-gnu -> usr/lib64/aarch64-linux-gnu.
	cp -r %{NVdir}/usr/lib/aarch64-linux-gnu/ %buildroot/usr/lib64/
	
	# Same for lib/firmware, lib/systemd.
	cp -r %{NVdir}/lib/firmware/* %buildroot/usr/lib64/firmware/
	cp -r %{NVdir}/lib/systemd/* %buildroot/usr/lib64/systemd/

	# Pass through these 2 in usr/lib64.
	cp -r %{NVdir}/usr/lib/xorg %buildroot/usr/lib64/
	cp -r %{NVdir}/usr/lib/nvidia %buildroot/usr/lib64/
	
	# These are OK as well...
	cp -r %{NVdir}/usr/share %buildroot/usr/share/
	cp -r %{NVdir}/usr/bin %buildroot/usr/bin/
	# move sbin -> bin
	cp -r %{NVdir}/usr/sbin/* %buildroot/usr/sbin/
	# pass through
	cp -r %{NVdir}/var/ %buildroot/var/
	cp -r %{NVdir}/opt/ %buildroot/opt/ 

	[[ ! -e %buildroot/usr/lib64/firmware/gm20b ]] && mkdir %buildroot/usr/lib64/firmware/gm20b
	pushd %buildroot/usr/lib64/firmware/gm20b > /dev/null 2>&1
                ln -sf "../tegra21x/acr_ucode.bin" "acr_ucode.bin"
                ln -sf "../tegra21x/gpmu_ucode.bin" "gpmu_ucode.bin"
                ln -sf "../tegra21x/gpmu_ucode_desc.bin" \
                                "gpmu_ucode_desc.bin"
                ln -sf "../tegra21x/gpmu_ucode_image.bin" \
                                "gpmu_ucode_image.bin"
                ln -sf "../tegra21x/gpu2cde.bin" \
                                "gpu2cde.bin"
                ln -sf "../tegra21x/NETB_img.bin" "NETB_img.bin"
                ln -sf "../tegra21x/fecs_sig.bin" "fecs_sig.bin"
                ln -sf "../tegra21x/pmu_sig.bin" "pmu_sig.bin"
                ln -sf "../tegra21x/pmu_bl.bin" "pmu_bl.bin"
                ln -sf "../tegra21x/fecs.bin" "fecs.bin"
                ln -sf "../tegra21x/gpccs.bin" "gpccs.bin"
                popd > /dev/null

				
	# Add a symlink for the Vulkan ICD.
	mkdir -p %buildroot/etc/vulkan/icd.d
	ln -s /usr/lib64/aarch64-linux-gnu/tegra/nvidia_icd.json %buildroot/etc/vulkan/icd.d/nvidia_icd.json
	
	# And another one for EGL.
	mkdir -p %buildroot/usr/share/glvnd/egl_vendor.d
	ln -s /usr/lib64/aarch64-linux-gnu/tegra-egl/nvidia.json %buildroot/usr/share/glvnd/egl_vendor.d/
	
	# Refresh old symlinks from /usr/lib/* to /usr/lib64/*
	ln -sfn /usr/lib64/aarch64-linux-gnu/tegra/libcuda.so %buildroot/usr/lib64/aarch64-linux-gnu/libcuda.so
	ln -sfn /usr/lib64/aarch64-linux-gnu/tegra/libcuda.so.1.1 %buildroot/usr/lib64/aarch64-linux-gnu/tegra/libcuda.so
	ln -sfn /usr/lib64/aarch64-linux-gnu/tegra/libnvbuf_utils.so.1.0.0 %buildroot/usr/lib64/aarch64-linux-gnu/tegra/libnvbuf_utils.so
	ln -sfn /usr/lib64/aarch64-linux-gnu/tegra/libnvbufsurface.so.1.0.0 %buildroot/usr/lib64/aarch64-linux-gnu/tegra/libnvbufsurface.so
	ln -sfn /usr/lib64/aarch64-linux-gnu/tegra/libnvbufsurftransform.so.1.0.0 %buildroot/usr/lib64/aarch64-linux-gnu/tegra/libnvbufsurftransform.so
	ln -sfn /usr/lib64/aarch64-linux-gnu/tegra/libnvid_mapper.so.1.0.0 %buildroot/usr/lib64/aarch64-linux-gnu/tegra/libnvid_mapper.so

%post
	/sbin/ldconfig

%files
/usr/*
/etc/*
/opt/*
/var/*
