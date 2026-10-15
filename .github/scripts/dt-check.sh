#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Device-tree checks of the iceland tree made by scripts/prepare.sh (used by .github/workflows/kernel-checks.yml).
#   .github/scripts/dt-check.sh SRC_DIR OUT_DIR
# 1. dt_binding_check of every binding the queue adds or changes (DT_SCHEMA_FILES = the queue's yaml files)
# 2. dtbs_check of the iceland DT (qcom/kaanapali-oneplus-iceland.dtb with CHECK_DTBS=y)
# The warnings (paths made relative) are compared with .github/dtbs-check-baseline.txt: a warning that is not in the
# baseline fails the run, a baseline line that no longer appears is reported (refresh the baseline in that commit).
# Without a baseline file every warning is reported and the run passes (first run: copy dt-warnings.txt from the
# run's artifact into the baseline).
set -uo pipefail
top=$(cd "$(dirname "$0")/../.." && pwd)
src=$(realpath "$1"); out=$(realpath -m "$2"); mkdir -p "$out"
. "$top/kernel.pin"
mk() { make -C "$src" O="$out" ARCH=arm64 -j"$(nproc)" "$@"; }
mk -s defconfig >/dev/null || exit 1

bind=$(git -C "$src" diff --name-only --diff-filter=AM "$UPSTREAM_COMMIT" HEAD -- 'Documentation/devicetree/bindings/*.yaml' |
	sed 's,^Documentation/devicetree/bindings/,,' | paste -s -d:)
echo "bindings added / changed by the queue: $(echo "$bind" | tr ':' '\n' | grep -c . || true)"
: > "$out/dt-raw.log"
if [ -n "$bind" ]; then
	mk dt_binding_check DT_SCHEMA_FILES="$bind" >> "$out/dt-raw.log" 2>&1 || echo "::error title=dt_binding_check::make dt_binding_check failed (see the log)"
fi
mk CHECK_DTBS=y qcom/kaanapali-oneplus-iceland.dtb >> "$out/dt-raw.log" 2>&1 || { cat "$out/dt-raw.log"; echo "::error title=dtbs_check::the iceland DT does not build"; exit 1; }

# warnings: every log line except make's progress lines (dtc, dt-validate, dt-doc-validate output); paths relative
grep -v -E '^(  [A-Z0-9_-]+ |make(\[[0-9]+\])?: |#|\*|[[:space:]]*$)' "$out/dt-raw.log" | grep -v 'jobserver' |
	sed -e "s#$out/##g" -e "s#$src/##g" | sed -E 's/[[:space:]]+$//' | LC_ALL=C sort -u > "$out/dt-warnings.txt"
n=$(wc -l < "$out/dt-warnings.txt")
base=$top/.github/dtbs-check-baseline.txt
if [ ! -f "$base" ]; then
	echo "no baseline yet: $n warning line(s), reported only"
	sed 's/^/::warning title=dt-check (no baseline)::/' "$out/dt-warnings.txt" | head -n 50
	exit 0
fi
grep -v '^#' "$base" | LC_ALL=C sort -u > "$out/baseline.txt"
new=$(LC_ALL=C comm -23 "$out/dt-warnings.txt" "$out/baseline.txt")
gone=$(LC_ALL=C comm -13 "$out/dt-warnings.txt" "$out/baseline.txt")
[ -n "$gone" ] && echo "$gone" | sed 's/^/::notice title=dt-check warning gone (refresh the baseline)::/'
echo "dt-check: $n warning line(s), $(echo -n "$new" | grep -c . || true) new, $(echo -n "$gone" | grep -c . || true) gone"
if [ -n "$new" ]; then
	echo "$new" | sed 's/^/::error title=dt-check new warning::/'
	exit 1
fi
