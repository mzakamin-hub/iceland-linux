# iceland-linux

The Linux kernel for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch queue
on an upstream tag, linux-next `next-20261020` (Linux 7.3 plus the trees queued for 7.4), so every commit keeps its
original author. This is the same approach as the
postmarketOS kernel packages and other tablet ports.

This repository is one part of the project. The boot chain and the install are described in the hub,
[iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline#boot-chain), and the install steps are in its
[manual install](https://github.com/mzakamin-hub/iceland-mainline#manual-install) section.

## Current kernel

- **Branch:** [`iceland-7.3-rc7-next`](https://github.com/mzakamin-hub/iceland-linux/tree/iceland-7.3-rc7-next). Build from this branch.
- **Queue:** q90o, kernel release `7.3.0-next-20261020-iceland-00501-g93375214c848`, packaged as
  `kernel-iceland`. The branch name is kept from the v7.3-rc7 queues; since q90b the queue applies onto linux-next
  `next-20261020` and moves to 7.4-rc1 once it is out.
- **New since q89w:** the queue on the 7.4 base (107 patches dropped as upstream there), Qualcomm's split CPU cluster
  power domains, the rpmhpd fix that lets the GPU's CLX start, the display clock controller's own MX vote, dwc3-qcom
  keeping its interconnect votes across runtime suspend on Kaanapali (fixes display flicker while the USB-C
  controller is suspended), the A8xx crash-state capture made opt-in (GPU recovery no longer hangs), the Kaanapali CP
  protect table on the A840, no submit replay on a GPU that was not reset, battery power reported at the nominal
  voltage (correct time-to-empty), the memlat devfreq read-back poll off by default, and a config round (VA_BITS 48,
  HZ 250, PREEMPT_DYNAMIC, CoreSight / STM off). q90j is q90i without the debugfs files, log lines and test
  switches that only served the display-flicker investigation.
- **`main`** holds the older queue q89g, the kernel of the first install image. Later queues are only on
  `iceland-7.3-rc7-next`.

## Download

q90o has no release download yet: build it from the branch (below). The newest packaged release is q89w:
the [`q89w` release](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89w) has:

- `kernel-iceland-7.3.0.rc7.iceland.00519.gec0a0e306dd9-1.fc44.aarch64.rpm`, the Fedora 44 package for the tablet;
- the source RPM, which carries this repository's queue at its head, and the build's config;
- `SHA256SUMS`.

Check the files with `sha256sum -c SHA256SUMS`. On the tablet's Fedora 44 system, install the package with dnf:

```bash
sudo dnf install ./kernel-iceland-7.3.0.rc7.iceland.00519.gec0a0e306dd9-1.fc44.aarch64.rpm
```

Earlier releases: [q89m](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89m),
[q89l](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89l) and
[q89k](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89k).

## What is in the repository

The counts below are for `iceland-7.3-rc7-next`.

| Path | Content |
|---|---|
| `kernel.pin` | the upstream tag and commit, the tree hash expected after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | 110 patches from infiniti-mainline/linux (OnePlus 15, the same SoC), rebased onto `next-20261020` |
| `patches/0002-iceland/` | 304 patches: the OnePlus Pad 4 series, numbered with gaps up to 0412 |
| `patches/0003-glitchfix/` to `patches/0016-q90o/` | 60 patches: the display-timing switches of q89z, then one series per queue q90b to q90k (upstream picks and our fixes) |
| `configs/` | `distro-neutral.config`, `q90b.config`, `q90i.config` and `q90i-shipped.config` (merged into the build, in that order) and `required.config` (options the build checks) |
| `scripts/prepare.sh` | clones the upstream tag, checks its commit, applies every series with `git am`, checks the tree hashes |
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
scripts/prepare.sh ./src        # clones next-20261020, checks the commit, applies every series, checks the tree hashes
scripts/build.sh ./src ./out    # Image, Image.gz, the DTB and the modules; writes out/dist/
```

- `scripts/build.sh` runs `defconfig`, merges `arch/arm64/configs/sm8850.config` (map220v's fragment; drift is reported
  but not fatal), `configs/distro-neutral.config`, `q90b.config`, `q90i.config` and `q90i-shipped.config`, then checks
  `distro-neutral.config`, `q90i.config`, `q90i-shipped.config` and `required.config` strictly. The result is the same
  `.config` as the kernel-iceland q90i, q90j and q90k packages'.
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
- Upstream: [linux-next](https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git) (`next-20261020`) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
