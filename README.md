# iceland-linux

Mainline Linux for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"), kept as a patch queue on an
upstream tag — Linux 7.3-rc6 (branch iceland-7.3-rc6-q89b, kernel q89b; main keeps the 7.3-rc4 queue) — (same approach as pmOS kernel packages and other tablet ports) so every commit keeps its original author.

| Path | Content |
|---|---|
| `kernel.pin` | upstream tag/commit + expected tree hashes |
| `patches/0001-infiniti/` | infiniti-mainline/linux master (OnePlus 15, same SoC; 135 of its 138 commits, 3 are upstream in rc6) |
| `patches/0002-iceland/` | OnePlus Pad 4: map220v/sm8850-mainline `iceland-7.2` ported to 7.3 (authors kept) + our fixes + upstream picks (0191-0252, numbers with gaps) |
| `docs/Q89B-QUEUE.md` | the rc6 rebase: what was dropped, what was added (with sources), what was taken out after testing |
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
