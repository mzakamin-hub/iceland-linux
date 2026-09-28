# iceland-linux

Mainline Linux for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"), kept as a patch queue on an
upstream tag — Linux 7.3-rc4 — (same approach as pmOS kernel packages and other tablet ports) so every commit keeps its original author.

| Path | Content |
|---|---|
| `kernel.pin` | upstream tag/commit + expected tree hashes |
| `patches/0001-infiniti/` | infiniti-mainline/linux master (OnePlus 15, same SoC; 138 commits) — reproduces it bit-for-bit |
| `patches/0002-iceland/` | OnePlus Pad 4: map220v/sm8850-mainline `iceland-7.2` ported to 7.3 (authors kept) + our fixes |
| `docs/PORT-LOG.md` | what happened to each of map220v's 40 commits, and the resulting test items |
| `configs/` | `distro-neutral.config` (merged), `required.config` (checked) |
| `scripts/build.sh` | defconfig + sm8850.config + distro-neutral.config, config check, Image/dtb/modules + BUILD_INFO |
| `scripts/prepare.sh` | clone upstream tag, `git am` all series, verify tree hashes |

```
scripts/prepare.sh ./src
scripts/build.sh ./src ./out     # needs clang/lld (LLVM=1), zstd
```

Licence: GPL-2.0 (Linux `COPYING`; every patch keeps its authorship and SPDX headers).
Proprietary firmware is never stored here.
