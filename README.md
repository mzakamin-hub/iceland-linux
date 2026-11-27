# iceland-linux

The Linux kernel for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch queue
on an upstream tag, Linux `v7.4-rc4` on the current branch, so every commit keeps its original author. This is the same approach as the
postmarketOS kernel packages and other tablet ports.

This repository is one part of the project. The boot chain and the install are described in the hub,
[iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline#boot-chain), and the install steps are in its
[manual install](https://github.com/mzakamin-hub/iceland-mainline#manual-install) section.

## Current kernel

- **Branch:** [`iceland-7.4-rc4`](https://github.com/mzakamin-hub/iceland-linux/tree/iceland-7.4-rc4) (tag `q92d`).
  Build from that branch; its README describes the queue, the build and the Arch Linux ARM package.
- **Queue:** q92d, kernel release `7.4.0-rc4-iceland-00827-g08a7adc3c104`, on Linux `v7.4-rc4`, packaged for Arch
  Linux ARM as `linux-iceland-q92d`.
- **`main`** holds the older queue q89g, the kernel of the first install image. Later queues are on the
  `iceland-*` branches: `iceland-7.4-rc4` (q92d), `iceland-7.4-rc1` (q91c to q91n), `iceland-7.3-rc7-next` (q89h to
  q90z).

## Download

The newest release is q92d: the [`q92d` release](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q92d) has
the Arch Linux ARM package `linux-iceland-q92d-7.4.0rc4.00827.g08a7adc3c104-1-aarch64.pkg.tar.zst`, its signature,
the optional device trees, the repository at tag `q92d` and `SHA256SUMS`. Install it with
`sudo pacman -U linux-iceland-q92d-7.4.0rc4.00827.g08a7adc3c104-1-aarch64.pkg.tar.zst` (see the
[branch README](https://github.com/mzakamin-hub/iceland-linux/tree/iceland-7.4-rc4#download)).

Earlier releases (Fedora RPMs): [q91n](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91n),
[q91k](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91k),
[q90z](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90z),
[q90x](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90x) and older.

The sections below describe the files on `main` (the q89g queue).

## What is in the repository

The counts below are for the q89g queue on `main`.

| Path | Content |
|---|---|
| `kernel.pin` | the upstream tag and commit, the tree hash expected after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | 132 patches from infiniti-mainline/linux (OnePlus 15, the same SoC), rebased onto v7.3-rc7 |
| `patches/0002-iceland/` | 385 patches: the OnePlus Pad 4 series, numbered with gaps up to 0402 |
| `configs/` | `distro-neutral.config` (merged into the build) and `required.config` (options the build checks) |
| `scripts/prepare.sh` | clones the upstream tag, checks its commit, applies both series with `git am`, checks the tree hashes |
| `scripts/build.sh` | configures and builds the kernel; writes `out/dist/` with `BUILD_INFO` and `SHA256SUMS` |
| `packaging/fedora/` | `kernel-iceland.spec`, `build-rpm.sh` and the kernel-install plugin for the Fedora 44 package |
| `packaging/repo/make-repo.sh` | builds a dnf repository from the `kernel-iceland` and `iceland-device` RPMs |
| `docs/` | one note per queue, `PORT-LOG.md` (each commit of the original port) and `PROVENANCE.md` |
| `.github/workflows/build.yml` | a manual GitHub Actions build of the kernel |

## Build

Packages needed on Ubuntu 24.04 (the list the GitHub workflow installs): `clang lld llvm flex bison bc libssl-dev
libelf-dev device-tree-compiler zstd cpio`. The build uses LLVM (`LLVM=1`).

```bash
git clone --branch iceland-7.3-rc7-next https://github.com/mzakamin-hub/iceland-linux
cd iceland-linux
scripts/prepare.sh ./src        # clones v7.3-rc7, checks the commit, applies both series, checks the tree hashes
scripts/build.sh ./src ./out    # Image, Image.gz, the DTB and the modules; writes out/dist/
```

- `scripts/build.sh` runs `defconfig`, merges `arch/arm64/configs/sm8850.config` (map220v's fragment; drift is reported
  but not fatal) and `configs/distro-neutral.config`, then checks `distro-neutral.config` and `required.config` strictly.
  A failed strict check stops the build unless `ALLOW_CONFIG_DRIFT=1` is set.
- `out/dist/` holds `Image`, `Image.gz`, `kaanapali-oneplus-iceland.dtb`, the config, `modules-<release>.tar.zst`,
  `BUILD_INFO` (kernel release, source commit, queue commit, compiler) and `SHA256SUMS`.
- The Fedora package: `packaging/fedora/build-rpm.sh BUILD_OUT RPM_OUT [RELEASE]` builds `kernel-iceland` for aarch64,
  with a source RPM that carries this repository. Check out the branch or tag you built before you package it: the
  source RPM carries the queue at its head. See [packaging/fedora/README.md](packaging/fedora/README.md).
- The GitHub workflow runs the same build when it is started by hand. It keeps `out/dist/` as an artifact for 14 days
  and does not build the RPM.

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

## Related repositories

- [iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline): the project, the boot chain, the install guide,
  the device package and the [list of working features](https://github.com/mzakamin-hub/iceland-mainline/blob/main/docs/FEATURES.md).
- [iceland-u-boot](https://github.com/mzakamin-hub/iceland-u-boot): the U-Boot that starts this kernel.
- [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware): the generic firmware files.
- Upstream: [torvalds/linux](https://github.com/torvalds/linux) (v7.3-rc7) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
