#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Package a scripts/build.sh output as kernel-iceland (binary rpm, aarch64) + a source rpm that carries the
# corresponding source (the patch queue + kernel.pin + configs; the upstream tree is fetched by prepare.sh).
#   packaging/fedora/build-rpm.sh BUILD_OUT_DIR RPM_OUT_DIR [RELEASE]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); top=$(cd "$here/../.." && pwd)
out=$(realpath "$1"); dest=$(realpath -m "$2"); rel=${3:-1}
dist=$out/dist
# the version is the modules directory inside the build's modules tarball (not include/config/kernel.release,
# which changes if anything is rebuilt in that tree afterwards)
kver=$(zstd -dc "$dist"/modules-*.tar.zst | tar -t 2>/dev/null | sed -n 's|^lib/modules/\([^/]*\)/$|\1|p' | head -n1)
[ -n "$kver" ] || { echo "no lib/modules/<kver>/ in the modules tarball"; exit 1; }
# rpm Version can't contain '-': 7.3.0-rc4-iceland-00161-gabc -> 7.3.0~rc4.iceland.00161.gabc
pkgver=$(echo "$kver" | sed 's/-rc/~rc/; s/-/./g')
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
mkdir -p "$work"/{SOURCES,SPECS,BUILD,RPMS,SRPMS} "$work/bin"
zstd -dc "$dist"/modules-*.tar.zst | tar -C "$work/bin" -x
cp "$dist/Image" "$dist/kaanapali-oneplus-iceland.dtb" "$work/bin/"
cp "$out/System.map" "$work/bin/System.map"; cp "$out/.config" "$work/bin/config"
tar -C "$work/bin" -cf "$work/SOURCES/kernel-iceland-$kver-bin.tar" .
cp "$here/90-iceland-dtb.install" "$dist/BUILD_INFO" "$work/SOURCES/"
# corresponding source: the whole patch-queue repo at this commit
git -C "$top" archive --prefix=iceland-linux/ -o "$work/SOURCES/iceland-linux-src.tar.gz" HEAD
sed 's|^Source2:.*|&\nSource3:        iceland-linux-src.tar.gz|' "$here/kernel-iceland.spec" > "$work/SPECS/kernel-iceland.spec"
rpmbuild --define "_topdir $work" --define "kver $kver" --define "kpkgver $pkgver" --define "krel $rel" \
	--define "dist .fc44" --target aarch64 --nodeps -ba "$work/SPECS/kernel-iceland.spec"
mkdir -p "$dest"; cp "$work"/RPMS/*/*.rpm "$work"/SRPMS/*.rpm "$dest/"
ls -la "$dest"
