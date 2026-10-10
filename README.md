# iceland-linux

Mainline Linux for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"), kept as a patch queue on an
upstream tag — Linux 7.3-rc6 (branch iceland-7.3-rc6-q89c-tb, kernel q89c-tb = q89b + 11 tb323fu-linux patches, a TEST candidate; the shipping kernel stays q89b on branch iceland-7.3-rc6-q89b; main keeps the 7.3-rc4 queue) — (same approach as pmOS kernel packages and other tablet ports) so every commit keeps its original author.

| Path | Content |
|---|---|
| `kernel.pin` | upstream tag/commit + expected tree hashes |
| `patches/0001-infiniti/` | infiniti-mainline/linux master (OnePlus 15, same SoC; 135 of its 138 commits, 3 are upstream in rc6) |
| `patches/0002-iceland/` | OnePlus Pad 4: map220v/sm8850-mainline `iceland-7.2` ported to 7.3 (authors kept) + our fixes + upstream picks (0191-0252, numbers with gaps) + 0255-0265 from tb323fu-linux (q89c-tb) |
| `docs/Q89C-TB-QUEUE.md` | q89c-tb: the 11 tb323fu-linux patches (0255-0265), their sources, sign-off status and test results |
| `docs/Q89B-QUEUE.md` | the rc6 rebase: what was dropped, what was added (with sources), what was taken out after testing |
| `docs/PORT-LOG.md` | what happened to each of map220v's 40 commits, and the resulting test items |
| `configs/` | `distro-neutral.config` (merged), `required.config` (checked) |
| `scripts/build.sh` | defconfig + sm8850.config + distro-neutral.config, config check, Image/dtb/modules + BUILD_INFO |
| `scripts/prepare.sh` | clone upstream tag, `git am` all series, verify tree hashes |

## q89c-tb: authorship and sign-off

0255-0265 come from [joonhoekim/tb323fu-linux](https://github.com/joonhoekim/tb323fu-linux) (Lenovo Legion Tab Gen 5, same SoC) and keep their author, Joonhoe Kim. **Six of them - 0256, 0257, 0258, 0260, 0264, 0265 - carry no Signed-off-by of their author** in the source queue, only ours, added when they were picked (0265 is also ported by us, see its `[mzak: ...]` note). They are here for testing on this tablet only, are not upstreamable as they are, and are not to be sent anywhere before the author signs them off. q89c-tb is a test candidate (tag `q89c-tb`, status in docs/Q89C-TB-QUEUE.md); the shipping kernel is q89b.

```
scripts/prepare.sh ./src
scripts/build.sh ./src ./out     # needs clang/lld (LLVM=1), zstd
```

Licence: GPL-2.0 (Linux `COPYING`; every patch keeps its authorship and SPDX headers).
Proprietary firmware is never stored here.
