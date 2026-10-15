# iceland-linux

Mainline Linux for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch queue
on an upstream tag, Linux v7.3-rc7, so every commit keeps its original author. This is the same approach as the
postmarketOS kernel packages and other tablet ports.

**The current branch is [`iceland-7.3-rc7-next`](https://github.com/mzakamin-hub/iceland-linux/tree/iceland-7.3-rc7-next)**
(16 Oct 2026): queue q89l, kernel release `7.3.0-rc7-iceland-00438-gc7bc30386efe`, the default kernel of the Fedora 44
system installed on the tablet. Build from that branch.

`main` holds queue q89g (`7.3.0-rc7-iceland-00426-g520e85da9244`, branch `iceland-7.3-rc7-q89g`, tag `q89g`), the kernel
of the first Fedora 44 install image (13 Oct 2026). The tables below describe q89g; q89h to q89l are listed in the README of
`iceland-7.3-rc7-next`.

## Download

The current queue q89l has no release yet. The latest release is [`q89k`](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89k) (queue commit `90869cf`, the queue before q89l): the Fedora 44 package
`kernel-iceland-7.3.0.rc7.iceland.00436.gf1673c99e731-1.fc44.aarch64.rpm` (sha256 `ca9bc275ba4b9f99...`), its
source RPM and the build's config, with `SHA256SUMS`.

## What is in the repository

| Path | Content |
|---|---|
| `kernel.pin` | upstream tag and commit, the expected tree hash after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | 132 patches: infiniti-mainline/linux master (OnePlus 15, same SoC), rebased onto v7.3-rc7 |
| `patches/0002-iceland/` | 294 patches: the OnePlus Pad 4 series, numbered with gaps up to 0306 (see below) |
| `configs/` | `distro-neutral.config` (merged into the build) and `required.config` (options the build checks) |
| `scripts/prepare.sh` | clones the upstream tag, checks its commit, applies both series with `git am`, checks the tree hashes |
| `scripts/build.sh` | configures and builds the kernel; writes `dist/` with `BUILD_INFO` and `SHA256SUMS` |
| `packaging/fedora/` | `kernel-iceland.spec`, `build-rpm.sh` and the kernel-install plugin for the Fedora 44 package |
| `packaging/repo/make-repo.sh` | builds a dnf repository from the kernel-iceland and iceland-device RPMs |
| `docs/` | one note per queue (`Q89B`, `Q89C-TB`, `Q89D8`, `Q89D9`, `Q89F`, `Q89G`), `PORT-LOG.md` and `PROVENANCE.md` |
| `.github/workflows/build.yml` | manual GitHub Actions build of the kernel (see below) |

The 0002 series is map220v's `iceland-7.2` work for the Pad 4, ported to 7.3 with the authors kept, plus our fixes,
upstream picks, the tb323fu-linux patches and our later queue items. `docs/PORT-LOG.md` accounts for each commit of
the original port, and the kernel history after it.

## Queues and branches

Each queue is a rebase or an addition on the one before it. The golden is the rehearsal image built from that queue
that passed the RAM-boot rehearsals.

| Queue | Kernel release | Base | Change | Branch / tag | Golden |
|---|---|---|---|---|---|
| q89b | `7.3.0-rc6-iceland-00377-g8e90101870e4` | v7.3-rc6 | first rc6 rebase of the queue ([notes](docs/Q89B-QUEUE.md)) | `iceland-7.3-rc6-q89b`, tag `q89b` (and tag `q89b-1`) | B130 |
| q89c-tb | `7.3.0-rc6-iceland-00388-g9093690257a0` | v7.3-rc6 | + 0255-0265, eleven patches from tb323fu-linux; a test candidate ([notes](docs/Q89C-TB-QUEUE.md)) | `iceland-7.3-rc6-q89c-tb`, tag `q89c-tb` | none |
| q89d8 | `7.3.0-rc6-iceland-00413-gfaa8eeee8c82` | v7.3-rc6 | + 0266-0290, in four stages ([notes](docs/Q89D8-QUEUE.md)) | `iceland-7.3-rc6-q89d8`, tag `q89d8` | B143 |
| q89d9 | `7.3.0-rc6-iceland-00414-g9e7350a6ab86` | v7.3-rc6 | + 0291, the Bluetooth hci_qca baud-rate burst ([notes](docs/Q89D9-QUEUE.md)) | `iceland-7.3-rc6-q89d9`, tag `q89d9` | B145 |
| q89e | `7.3.0-rc7-iceland-00412-g4917dfb48aab` | v7.3-rc7 | q89d9 rebased onto rc7 (three patches merged upstream were dropped) + 0292 | `iceland-7.3-rc7-q89e`, tag `q89e` | B147 |
| q89f | `7.3.0-rc7-iceland-00425-g8165b4e0b2d8` | v7.3-rc7 | + 0293-0305: brightness limit, focus lens, wake, idle refresh rate ([notes](docs/Q89F-QUEUE.md)) | `iceland-7.3-rc7-q89f`, tag `q89f` | none |
| q89g | `7.3.0-rc7-iceland-00426-g520e85da9244` | v7.3-rc7 | + 0306: the focus lens holds its position ([notes](docs/Q89G-QUEUE.md)) | `iceland-7.3-rc7-q89g`, tag `q89g`, `main` | B149 |

The earlier queues on Linux 7.3-rc4 (q84 to q87) are not kept on a branch. Their story is in `docs/PORT-LOG.md`.

The idle refresh rate (0303-0305) is compiled into q89f and q89g but off by default (`msm.dpu_idle_refresh_ms=0`).

## Authorship and sign-off

- 0255-0265 come from [joonhoekim/tb323fu-linux](https://github.com/joonhoekim/tb323fu-linux) and keep their author,
  Joonhoe Kim. Six of them (0256, 0257, 0258, 0260, 0264, 0265) carry no `Signed-off-by` of their author in the source
  queue, only ours.
- 0266-0290 keep their authors. Five of them (0274, 0275, 0276 by Joonhoe Kim; 0279, 0284 by Yibo Wang, SuperTurtleDev's
  iceland-mainline-kernel work) carry no `Signed-off-by` of their author in the source.
- These patches are for this tablet only. They are not upstreamable as they are and are not sent anywhere before their
  authors sign them off. The sign-off status of each is in its queue note.
- [docs/PROVENANCE.md](docs/PROVENANCE.md) records where five of the tb323fu patches came from, and where a signed
  upstream version exists it replaces ours on the next rebase.
- 0292 (iris colorimetry) is carried in the kernel but is not sent upstream (owner's decision; the kernel requires an
  `Assisted-by` line for it).

Licence: GPL-2.0 (Linux `COPYING`). Every patch keeps its authorship and SPDX headers. Proprietary firmware is never
stored here; the generic firmware is in [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware).

## Build

Packages needed on Ubuntu 24.04 (the same list the GitHub workflow installs): `clang lld llvm flex bison bc libssl-dev
libelf-dev device-tree-compiler zstd cpio`. The build uses LLVM (`LLVM=1`).

```
scripts/prepare.sh ./src        # clones v7.3-rc7, checks the commit, applies both series, checks the tree hashes
scripts/build.sh ./src ./out    # Image, Image.gz, the DTB and the modules; writes out/dist/
```

`scripts/build.sh` runs `defconfig`, merges `arch/arm64/configs/sm8850.config` (map220v's fragment; drift is reported
but not fatal) and `configs/distro-neutral.config`, then checks `distro-neutral.config` and `required.config` strictly.
A failed strict check stops the build unless `ALLOW_CONFIG_DRIFT=1` is set. `out/dist/` holds `Image`, `Image.gz`,
`kaanapali-oneplus-iceland.dtb`, the config, `modules-<release>.tar.zst`, `BUILD_INFO` (kernel release, source commit,
queue commit, compiler) and `SHA256SUMS`.

The Fedora package is made from that output (see [packaging/fedora/README.md](packaging/fedora/README.md)):
`packaging/fedora/build-rpm.sh BUILD_OUT RPM_OUT [RELEASE]` builds `kernel-iceland` for aarch64 and a source RPM that
carries this repository. `packaging/repo/make-repo.sh` turns the RPMs into a dnf repository. Nothing is published
anywhere by these scripts.

### GitHub Actions

`.github/workflows/build.yml` (workflow `kernel`) is started by hand from the Actions tab. It runs on an
`ubuntu-24.04-arm` runner: it prepares the source, builds it and uploads `out/dist/` as the artifact
`iceland-kernel-<commit>`, kept for 14 days. The workflow does not build the RPM.

## Status on the installed tablet

- The first Fedora 44 install image carries this queue (q89g). Installed systems update to q89l from
  `iceland-7.3-rc7-next` with dnf; it is the default kernel since 16 Oct 2026.
- What works, feature by feature:
  [iceland-mainline/docs/FEATURES.md](https://github.com/mzakamin-hub/iceland-mainline/blob/main/docs/FEATURES.md).

## Related repositories

- [iceland-u-boot](https://github.com/mzakamin-hub/iceland-u-boot): the U-Boot that starts the kernel.
- [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware): the generic firmware files.
- [iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline): the project, the install guide, the device
  package and the list of working features.
- Upstream: [torvalds/linux](https://github.com/torvalds/linux) (v7.3-rc7) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
