#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Build the kernel and stage the linux-iceland package tree.
#   packaging/arch/linux-iceland/kbuild.sh SRC_DIR OUT_DIR TARBALL
# SRC_DIR is a tree made by scripts/prepare.sh. The script runs scripts/build.sh (the configured build), checks the
# result against the package config (config-q92d), builds the optional device trees (optional/*/), stages
# usr/lib/modules/<release>/ and packs it into TARBALL (.tar.zst), the input of the PKGBUILD.
# Works on an x86-64 PC (cross build: ARCH=arm64 LLVM=1 with any recent clang / lld) and on aarch64.
# KBUILD_BUILD_USER / KBUILD_BUILD_HOST default to iceland / iceland-builder.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); top=$(cd "$here/../../.." && pwd)
src=$(realpath "${1:?SRC_DIR}"); out=$(realpath -m "${2:?OUT_DIR}"); tarball=$(realpath -m "${3:?TARBALL}")
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-iceland} KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-iceland-builder}
jobs=${JOBS:-$(nproc)}
mk() { make -C "$src" O="$out" ARCH=arm64 LLVM=1 -j"$jobs" "$@"; }

"$top/scripts/build.sh" "$src" "$out"

# the configured .config must equal the package config (toolchain version lines aside)
norm() { grep -E '^CONFIG_|^# CONFIG_.* is not set' "$1" |
	grep -vE '^(# )?CONFIG_(CC_VERSION_TEXT|CLANG_VERSION|LLD_VERSION|AS_VERSION|LD_VERSION|RUSTC|BINDGEN|PAHOLE|GCC_VERSION|CC_IS|LD_IS|AS_IS|CC_HAS|TOOLS_SUPPORT)' | sort; }
if ! diff <(norm "$here/config-q92d") <(norm "$out/.config") > "$out/config-vs-package.diff"; then
	echo "the configured kernel differs from config-q92d (see $out/config-vs-package.diff)"
	[ "${ALLOW_CONFIG_DRIFT:-0}" = 1 ] || exit 1
fi

kver=$(cat "$out/include/config/kernel.release")
stage=$out/pkgstage; m=$stage/usr/lib/modules/$kver
rm -rf "$stage"; mkdir -p "$m/dtb/qcom/variants"
# the modules uncompressed (as in the released package; pacman compresses the package), debug info stripped
mk INSTALL_MOD_PATH="$stage/usr" INSTALL_MOD_STRIP=1 CONFIG_MODULE_COMPRESS_ALL= modules_install > /dev/null
rm -f "$m/build" "$m/source"
cp "$out/arch/arm64/boot/Image" "$m/vmlinuz"
cp "$out/System.map" "$m/System.map"
cp "$out/.config" "$m/config"
cp "$out/arch/arm64/boot/dts/qcom/kaanapali-oneplus-iceland.dtb" "$m/dtb/qcom/"
# the optional device trees: each change applied, the DTB built, the change reverted
for d in "$top"/optional/*/; do
	v=$(basename "$d")
	git -C "$src" apply "$d"*.patch
	mk qcom/kaanapali-oneplus-iceland.dtb
	cp "$out/arch/arm64/boot/dts/qcom/kaanapali-oneplus-iceland.dtb" "$m/dtb/qcom/variants/kaanapali-oneplus-iceland-$v.dtb"
	git -C "$src" apply -R "$d"*.patch
done
mk qcom/kaanapali-oneplus-iceland.dtb
cmp -s "$out/arch/arm64/boot/dts/qcom/kaanapali-oneplus-iceland.dtb" "$m/dtb/qcom/kaanapali-oneplus-iceland.dtb"
{
	echo "kernel-release: $kver"
	echo "source-commit: $(git -C "$src" rev-parse HEAD)"
	echo "patch-queue-commit: $(git -C "$top" rev-parse HEAD 2>/dev/null || echo unknown)"
	echo "compiler: $(clang --version | head -n1)"
	echo "image-sha256: $(sha256sum < "$m/vmlinuz" | cut -c1-64)"
	echo "dtb-sha256: $(sha256sum < "$m/dtb/qcom/kaanapali-oneplus-iceland.dtb" | cut -c1-64)"
	echo "modules: $(find "$m" -name '*.ko' | wc -l)"
} > "$m/BUILD_INFO"
tar -C "$stage" --owner=0 --group=0 --numeric-owner --sort=name -cf - usr | zstd -19 -T0 -q -f -o "$tarball"
echo "staged $kver -> $tarball ($(sha256sum < "$tarball" | cut -c1-64))"
