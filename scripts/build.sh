#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Configure and build the iceland kernel from a tree made by prepare.sh.
#   scripts/build.sh [SRC_DIR] [OUT_DIR]      (defaults: ./src ./out)
# Output: OUT_DIR/dist/{Image,Image.gz,kaanapali-oneplus-iceland.dtb,config,modules.tar.zst,BUILD_INFO,SHA256SUMS}
set -euo pipefail
top=$(cd "$(dirname "$0")/.." && pwd)
src=$(realpath "${1:-$top/src}")
out=$(realpath -m "${2:-$top/out}")
jobs=${JOBS:-$(nproc)}
mk() { make -C "$src" O="$out" ARCH=arm64 LLVM=1 -j"$jobs" "$@"; }

mkdir -p "$out"
mk defconfig
# The fragments in order: map220v's SoC fragment, ours, then the queue's release fragments (q90b: the 7.4-base
# config pass; q90i: the config round; q90i-shipped: the rest of the shipped q90i config).
frags=("$top/configs/distro-neutral.config" "$top/configs/q90b.config" "$top/configs/q90i.config"
	"$top/configs/q90i-shipped.config")
"$src/scripts/kconfig/merge_config.sh" -m -O "$out" "$out/.config" 	"$src/arch/arm64/configs/sm8850.config" "${frags[@]}" >/dev/null
mk olddefconfig

# Our fragment + the must-have list are checked strictly (a silent drop = unmet dependency);
# drift in map220v's sm8850.config is only reported.
check() { # check <fragment> <strict:0|1>
	local bad=0 line sym val
	while IFS= read -r line; do
		case "$line" in CONFIG_*=*) ;; *) continue ;; esac
		sym=${line%%=*}; val=${line#*=}
		if [ "$val" = n ]; then
			grep -q "^$sym=" "$out/.config" && { echo "config: $sym should be off"; bad=1; }
		else
			grep -qx "$line" "$out/.config" || { echo "config: wanted $line, got: $(grep "^$sym=\|# $sym is" "$out/.config" || echo missing)"; bad=1; }
		fi
	done < "$1"
	[ "$bad" = 0 ] && return 0
	[ "$2" = 1 ] && return 1
	echo "  (warnings above are drift in $(basename "$1"), not fatal)"
}
check "$src/arch/arm64/configs/sm8850.config" 0 > "$out/config-drift.txt" || true
check "$top/configs/q90i.config" 1 && check "$top/configs/q90i-shipped.config" 1 &&
	check "$top/configs/required.config" 1 || {
	echo "config check failed (fix fragment dependencies)"; [ "${ALLOW_CONFIG_DRIFT:-0}" = 1 ] || exit 1; }

mk Image Image.gz dtbs modules
dist=$out/dist
rm -rf "$dist" "$out/modinst"; mkdir -p "$dist"
mk INSTALL_MOD_PATH="$out/modinst" INSTALL_MOD_STRIP=1 modules_install >/dev/null
kver=$(cat "$out/include/config/kernel.release")
tar -C "$out/modinst" -c lib | zstd -q -19 -T0 -o "$dist/modules-$kver.tar.zst"
cp "$out/arch/arm64/boot/Image" "$out/arch/arm64/boot/Image.gz" "$dist/"
cp "$out/arch/arm64/boot/dts/qcom/kaanapali-oneplus-iceland.dtb" "$dist/"
cp "$out/.config" "$dist/config-$kver"
{
	echo "kernel-release: $kver"
	echo "source-commit: $(git -C "$src" rev-parse HEAD)"
	echo "patch-queue-commit: $(git -C "$top" rev-parse HEAD 2>/dev/null || echo unknown)"
	echo "compiler: $(clang --version | head -n1)"
	echo "date: $(date -u +%FT%TZ)"
} > "$dist/BUILD_INFO"
(cd "$dist" && sha256sum -- * > SHA256SUMS)
echo "built $kver -> $dist"
