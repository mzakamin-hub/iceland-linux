# iceland-linux

The Linux kernel for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch queue
on an upstream tag, Linux `v7.4-rc1`, so every commit keeps its original author. This is the same approach as the
postmarketOS kernel packages and other tablet ports.

This repository is one part of the project. The boot chain and the install are described in the hub,
[iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline#boot-chain), and the install steps are in its
[manual install](https://github.com/mzakamin-hub/iceland-mainline#manual-install) section.

## Current kernel

- **Branch:** [`release/q91c`](https://github.com/mzakamin-hub/iceland-linux/tree/release/q91c) (tag `q91c`). Build from
  this branch.
- **Queue:** q91c, kernel release `7.4.0-rc1-iceland-00618-g0ec14bab11a0`, packaged as `kernel-iceland`, on Linux `v7.4-rc1`.
- **New in q91c** (since q90z):
  - The queue applies onto Linux v7.4-rc1. Twelve patches that were merged upstream by rc1 are gone (numbers kept with
    gaps), among them three q6apm unmap fixes and seven UFS fixes; one UFS abort fix is replaced by its upstream form.
  - GPU: preemption-aware hang detection, the A8xx GMEM base fix and a bounded wait in GPU recovery.
  - CPU: the frequency-invariance reference follows the boost frequencies, schedutil returns below the boost steps when
    boost is switched off, and the energy model ranks boost and non-boost steps separately.
  - Cameras: CAMSS fixes (active buffer pointers cleared after a flush, CSID power-on unwind, DMA-contiguous buffer
    check) and the CSIPHY held in reset between streams.
  - Video (iris): deblocking controls, timestamps kept on error buffers, buffer recycling for non-display pictures,
    fewer redundant decoder parameter writes, the encoder reference buffer size, the video format kept across GOP
    restarts.
  - Display: 50 and 48 Hz panel modes; DPU cleanup fixes on mode changes.
  - Sound: the RX codec DMA runs at 24 bit (headphones), 32-bit capture, the WCD939x headphone volume on its real gain
    register (1.5 dB steps, +6 to -30 dB).
  - Robustness: fastrpc use-after-free, UFS MCQ abort and full re-init after a fatal link loss, LPASS RX macro PM
    reference leak, SoundWire clock stop, Bluetooth (CIS host feature, RX work drain, L2CAP waits for the key size),
    ath12k EHT fixes, the GENI SE resource handling, the battery manager matching replies to their requests, the
    dma-buf system heap allocation orders, USB UTMI clock selection restored after resume.
  - Config: CMA dma-buf heap, VM sockets (vsock / vhost-vsock), idle-injection cooling, the Gunyah watchdog; QCOM_LMH
    is no longer built (Kaanapali's CPU limits come through SCMI).
  - **Optional, off by default:** `msm.a8xx_ab_vote=1` (average-bandwidth DDR votes with each GPU level) and
    `msm.gmu_hfi_irq_fix=1` (the GMU interrupt handled as the vendor driver does), plus the earlier tunables of q90u.
  - **Optional device trees** (shipped in the package under `dtb/qcom/variants/` and as release files, never installed
    by default): `headset` (the USB-C analog headset path of the codec), `int2dt` (the display's INT2 power domain
    under display runtime PM) and `thermaldt` (the skin temperature policy as a kernel thermal zone plus a 95 C CPU
    backstop).
- **`main`** holds the older queue q89g, the kernel of the first install image.

## Download

The newest release is q91c: the [`q91c` release](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91c) has:

- `kernel-iceland-7.4.0~rc1.iceland.00618.g0ec14bab11a0-2.fc44.aarch64.rpm`, the Fedora 44 package for the tablet;
- the three optional device trees, the source RPM, which carries this repository's queue, and `SHA256SUMS`.

Check the files with `sha256sum -c SHA256SUMS`. On the tablet's Fedora 44 system, install the package with dnf:

```bash
sudo dnf install ./kernel-iceland-7.4.0~rc1.iceland.00618.g0ec14bab11a0-2.fc44.aarch64.rpm
```

Earlier releases: [q90z](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90z),
[q90u](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90u),
[q90r](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90r),
[q90i](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90i) and older.

## What is in the repository

The counts below are for `release/q91c`.

| Path | Content |
|---|---|
| `kernel.pin` | the upstream tag and commit, the tree hash expected after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | the patches from infiniti-mainline/linux (OnePlus 15, the same SoC), rebased onto `v7.4-rc1` |
| `patches/0002-iceland/` | the OnePlus Pad 4 series, numbered with gaps up to 0412 |
| `patches/0003-glitchfix/` to `patches/0027-q90z/` | 158 patches: the display-timing switches of q89z, then one series per queue q90b to q90z (upstream picks and our fixes; there is no q90j series: q90j only removed patches) |
| `configs/` | `distro-neutral.config`, then one fragment per queue up to `q91c.config` (merged into the build in the order of `scripts/build.sh`) and `required.config` (options the build checks) |
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
git clone --branch release/q91c https://github.com/mzakamin-hub/iceland-linux
cd iceland-linux
scripts/prepare.sh ./src        # clones v7.4-rc1, checks the commit, applies every series, checks the tree hashes
scripts/build.sh ./src ./out    # Image, Image.gz, the DTB and the modules; writes out/dist/
```

- `scripts/build.sh` runs `defconfig`, merges `arch/arm64/configs/sm8850.config` (map220v's fragment; drift is reported
  but not fatal), `configs/distro-neutral.config`, `q90b.config`, `q90i.config`, `q90i-shipped.config` and
  `q90m.config` to `q90r.config`, `q90s.config`, `q90t.config`, `q90y.config` and `q90z.config`, then checks `q90i.config`, `q90i-shipped.config`,
  `q90m.config`, `q90p.config`, `q90s.config`, `q90t.config`, `q90y.config`, `q90z.config` and `required.config` strictly. The result is the same
  `.config` as the kernel-iceland q90z package's.
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
- Upstream: [Linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git) (`v7.4-rc1`) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
