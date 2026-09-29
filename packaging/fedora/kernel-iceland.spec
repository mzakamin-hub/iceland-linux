# SPDX-License-Identifier: GPL-2.0-only
#
# kernel-iceland: our OnePlus Pad 4 kernel (Linux + the iceland patch queue), packaged for Fedora 44 aarch64.
# Repackages a build made by scripts/build.sh (built from source by this repo; the source rpm carries the full
# source tarball + patch queue, see build-rpm.sh). Named kernel-iceland so it never clashes with Fedora's `kernel`
# (which the iceland-device package excludes). Installed side by side like Fedora kernels (installonlypkg).

%global kver %{?kver}%{!?kver:0.0.0-iceland}
%global debug_package %{nil}
%global __strip /bin/true
%global __os_install_post %{nil}
%global _build_id_links none

Name:           kernel-iceland
Version:        %{kpkgver}
Release:        %{krel}%{?dist}
Summary:        Linux kernel for the OnePlus Pad 4 (iceland, SM8850P)
License:        GPL-2.0-only
URL:            https://github.com/mzakamin-hub/iceland-linux
ExclusiveArch:  aarch64
Source0:        kernel-iceland-%{kver}-bin.tar
Source1:        90-iceland-dtb.install
Source2:        BUILD_INFO

Provides:       installonlypkg(kernel)
Requires(posttrans): systemd-udev dracut
Requires:       kmod
Recommends:     iceland-device

%description
Mainline Linux (%{kver}) with the OnePlus Pad 4 patch queue: kernel image, device tree
(qcom/kaanapali-oneplus-iceland.dtb), modules and config. kernel-install builds the initramfs and the boot entry,
and copies the device tree to the EFI system partition, where U-Boot loads it.
Source commits: see /usr/lib/modules/%{kver}/BUILD_INFO.

%prep
%setup -q -c -T
tar -xf %{SOURCE0}

%build
# prebuilt by scripts/build.sh (see BUILD_INFO)

%install
m=%{buildroot}/usr/lib/modules/%{kver}
mkdir -p $m/dtb/qcom %{buildroot}/usr/lib/kernel/install.d
cp -a lib/modules/%{kver}/. $m/
rm -f $m/build $m/source
install -m 0644 Image $m/vmlinuz
install -m 0644 System.map $m/System.map
install -m 0644 config $m/config
install -m 0644 kaanapali-oneplus-iceland.dtb $m/dtb/qcom/kaanapali-oneplus-iceland.dtb
install -m 0644 %{SOURCE2} $m/BUILD_INFO
install -m 0755 %{SOURCE1} %{buildroot}/usr/lib/kernel/install.d/90-iceland-dtb.install

%posttrans
/usr/bin/kernel-install add %{kver} /usr/lib/modules/%{kver}/vmlinuz || exit $?

%preun
/usr/bin/kernel-install remove %{kver} || :

%files
%dir /usr/lib/modules/%{kver}
/usr/lib/modules/%{kver}/*
/usr/lib/kernel/install.d/90-iceland-dtb.install

%changelog
* Tue Sep 29 2026 mzak <mzak.amin@gmail.com> - %{kpkgver}-%{krel}
- Built from the iceland-linux patch queue (see BUILD_INFO)
