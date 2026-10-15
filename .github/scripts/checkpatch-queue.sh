#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-only
#
# checkpatch.pl over queue patches, as GitHub annotations (used by .github/workflows/kernel-checks.yml).
#   .github/scripts/checkpatch-queue.sh CHECKPATCH_DIR PATCH...
# CHECKPATCH_DIR holds checkpatch.pl, spelling.txt and const_structs.checkpatch of the pinned upstream commit.
# Our patches (author mzak.amin@gmail.com) are checked with --strict, upstream-authored ones with the default checks.
# WARNING / CHECK lines become warning annotations; the run fails only on an ERROR in one of our patches
# (an ERROR in an upstream-authored patch is reported as a warning: the queue carries those patches unchanged).
set -u
dir=$1; shift
own_err=0; up_err=0; nw=0; n=0
for p in "$@"; do
	[ -f "$p" ] || continue
	n=$((n + 1))
	if grep -m1 '^From: ' "$p" | grep -q -F '<mzak.amin@gmail.com>'; then own=1; mode=--strict; else own=0; mode=; fi
	# on stdin: checkpatch treats a file name that git tracks as a source file, not as a patch
	out=$(perl "$dir/checkpatch.pl" --no-tree $mode --emacs --terse --no-summary --color=never - < "$p" 2>&1)
	while IFS= read -r line; do
		# "<patch>:<line>: ERROR|WARNING|CHECK: <TYPE>: <text>"
		case "$line" in
		*": ERROR: "*) kind=ERROR ;;
		*": WARNING: "*) kind=WARNING ;;
		*": CHECK: "*) kind=CHECK ;;
		*) continue ;;
		esac
		ln=$(printf '%s' "$line" | sed -n 's/^[^:]*:\([0-9][0-9]*\): .*/\1/p')
		msg=${line#*": $kind: "}
		if [ "$kind" = ERROR ] && [ "$own" = 1 ]; then
			own_err=$((own_err + 1)); echo "::error file=$p,line=${ln:-1},title=checkpatch --strict ERROR::$msg"
		else
			[ "$kind" = ERROR ] && up_err=$((up_err + 1))
			nw=$((nw + 1)); echo "::warning file=$p,line=${ln:-1},title=checkpatch $kind$([ "$own" = 1 ] && echo ' (--strict)' || echo ' (upstream author)')::$msg"
		fi
	done <<< "$out"
done
echo "checkpatch: $n patch(es), $own_err error(s) in our patches, $up_err error(s) in upstream-authored patches (reported only), $nw warning annotation(s)"
[ "$own_err" = 0 ]
