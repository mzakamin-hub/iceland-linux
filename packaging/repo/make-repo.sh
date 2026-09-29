#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Build (or refresh) a dnf repository of our packages: kernel-iceland + iceland-device.
#   packaging/repo/make-repo.sh REPO_DIR RPM...
# Copies the rpms into REPO_DIR/aarch64 (binary) and REPO_DIR/SRPMS (sources), keeps the newest KEEP (default 3)
# kernel-iceland versions, and regenerates the metadata with createrepo_c. REPO_DIR is then either copied to the
# tablet (/var/lib/iceland/repo, see iceland-repo-sync) or served over the PC's USB network.
# Nothing is published anywhere: a public repo (COPR / GitHub Pages) needs the user's OK first.
set -euo pipefail
repo=$(realpath -m "$1"); shift
keep=${KEEP:-3}
mkdir -p "$repo/aarch64" "$repo/SRPMS"
for r in "$@"; do
	case "$r" in
	*.src.rpm) cp -f "$r" "$repo/SRPMS/" ;;
	*.rpm) cp -f "$r" "$repo/aarch64/" ;;
	esac
done
# keep the newest $keep kernel-iceland builds (installonly: dnf keeps 3 installed too)
for d in aarch64 SRPMS; do
	mapfile -t k < <(ls -1 "$repo/$d"/kernel-iceland-*.rpm 2>/dev/null | sort -V)
	n=${#k[@]}
	if [ "$n" -gt "$keep" ]; then
		for ((i = 0; i < n - keep; i++)); do rm -f "${k[$i]}"; done
	fi
done
createrepo_c -q --update "$repo/aarch64"
createrepo_c -q --update "$repo/SRPMS"
(cd "$repo" && find . -name '*.rpm' -printf '%P\n' | sort | xargs sha256sum > SHA256SUMS)
echo "repo: $repo"; cat "$repo/SHA256SUMS"
