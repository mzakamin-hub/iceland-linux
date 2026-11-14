# iceland-linux

The Linux kernel for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch queue
on an upstream tag, Linux `v7.4-rc1`, so every commit keeps its original author. This is the same approach as the
postmarketOS kernel packages and other tablet ports.

This repository is one part of the project. The boot chain and the install are described in the hub,
[iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline#boot-chain), and the install steps are in its
[manual install](https://github.com/mzakamin-hub/iceland-mainline#manual-install) section.

## Current kernel

- **Branch:** [`iceland-7.4-rc1`](https://github.com/mzakamin-hub/iceland-linux/tree/iceland-7.4-rc1) (tag `q91n`). Build
  from this branch.
- **Queue:** q91n, kernel release `7.4.0-rc1-iceland-00743-g06b3ff1eede5`, packaged as `kernel-iceland`, on Linux
  `v7.4-rc1`. The released queues since q91c have their own tags (`q91c` to `q91k`, `q91n`).
- **New in q91n** (since q91k):
  - Security: 25 fixes from mainline: mac80211 use-after-free on an MLO link rollback and on TTLM disconnect,
    cfg80211 regulatory rule out-of-bounds read, TCP Fast Open and ipv6 raw socket use-after-free, TCP / ipv6 RCU
    frees, GUP-fast bounds, memcg / THP / khugepaged / shmem / vma fixes, essiv, btrfs, netfilter SIP, Bluetooth
    CIS / CIG length checks and smb client bounds.
  - Qualcomm: remoteproc firmware address bounds, the mdt_loader segment name and smem partition range checks;
    msm keeps the objects of queued VM_BIND unmaps busy.
  - Wi-Fi: ath12k fixes for a firmware crash around resume (CE interrupts toggled once, no wait in resume for a
    reset that cannot finish there, the thermal devices unregistered once).
  - Also included, not yet verified with a USB-PD charger: the battery manager keeps a 9 V PD contract at stock's
    cool-down level 4 instead of returning to 5 V (series `0039-q91m-pd`).
- **New in q91d to q91k** (since q91c):
  - GPU: GPU recovery frees the crash state asynchronously (no recovery deadlock), the GMU-to-host interrupts are
    masked before the GMU boots, A8xx 1/2-bit alpha filtering precision, msm VM_BIND and metadata lock fixes.
  - Display: KWin Night Light works: the Kaanapali DSPP no longer exposes the GC (gamma LUT) block, which this
    hardware loads only through LUTDMA, so compositors use the colour transform matrix.
  - Sleep: the cover closes into sleep about a second after the close (the SMP2P sleep-state driver reports wakeup
    events only while suspending); SoundWire and the LPASS LPI pins are runtime-suspended in system sleep; tsens
    masks its low-threshold interrupts and bwmon drops its vote across suspend; UFS holds clock gating in system PM.
  - Bluetooth and Wi-Fi: 100 ms WCN7850 / WCN7860 power-up delay (no lost QCA version read on a Bluetooth-first
    cold start), hci_qca in-band sleep reset and debugfs fix, MGMT power-on / power-off serialised, ath12k scan
    unwind, MLO reconnect, PPE thresholds, SRNG and MSDU fixes, the WCN7860 QMI chunk size limit.
  - USB-C: UCSI and the dwc3 mux leave DisplayPort alt mode to the altmode driver, DP PHY state tracked with the
    link, pmic_glink_altmode fixes, UCSI init retries only while the PPM is not ready, the dwc3 gadget End Transfer
    series, and the USB connector temperature (`qcom-battmgr-usb` reports `TEMP`).
  - Thermal: stock's shell temperature policy as a kernel thermal zone, 95 C CPU and QMX backstops, and the stock
    Horae shell estimate as the read-only zone `horae-shell` are now in the default device tree; tsens and
    adc5-gen3 fixes.
  - Robustness: cpufreq boost locking, rpmh and pmic_glink use-after-free fixes, TPIDR2 kept across CPU suspend, UFS
    runtime-resume / hibern8 error paths, iris fixes, multi-owner I2C in GPI mode, CSD lock wait
    reporting.
  - **Optional, off by default:** the earlier `msm.*` and q90u tunables.
  - **Optional device tree:** `headset` (the USB-C analog headset path of the codec), shipped in the package under
    `dtb/qcom/variants/` and as a release file, never installed by default. Its device tree change is
    `optional/headset/`.
- **`main`** holds the older queue q89g, the kernel of the first install image.

## Download

The newest release is q91n: the [`q91n` release](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91n) has:

- `kernel-iceland-7.4.0.rc1.iceland.00743.g06b3ff1eede5-1.fc44.aarch64.rpm`, the package for the tablet (built for Fedora 44,
  installs on Fedora 45; package version `7.4.0~rc1.iceland.00743.g06b3ff1eede5`, the file name has `.` for `~`);
- the optional `headset` device tree, the source RPM, which carries this repository's queue, and `SHA256SUMS`.

Check the files with `sha256sum -c SHA256SUMS`. On the tablet, install the package with dnf:

```bash
sudo dnf install ./kernel-iceland-7.4.0.rc1.iceland.00743.g06b3ff1eede5-1.fc44.aarch64.rpm
```

Earlier releases: [q91k](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91k),
[q90z](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90z),
[q90u](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90u),
[q90r](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90r),
[q90i](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90i) and older.

## What is in the repository

The counts below are for `iceland-7.4-rc1`.

| Path | Content |
|---|---|
| `kernel.pin` | the upstream tag and commit, the tree hash expected after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | the patches from infiniti-mainline/linux (OnePlus 15, the same SoC), rebased onto `v7.4-rc1` |
| `patches/0002-iceland/` | the OnePlus Pad 4 series, numbered with gaps up to 0412 |
| `patches/0003-glitchfix/` to `patches/0027-q90z/` | 158 patches: the display-timing switches of q89z, then one series per queue q90b to q90z (upstream picks and our fixes; there is no q90j series: q90j only removed patches) |
| `patches/0028-q91/` to `patches/0040-q91n/` | the series of the v7.4-rc1 queues q91 to q91n (upstream and list picks, peer picks and our fixes; one series per queue) |
| `optional/headset/` | the device tree change of the optional `headset` DTB (not applied by `scripts/prepare.sh`) |
| `configs/` | `distro-neutral.config`, then one fragment per queue up to `q91e.config` (merged into the build in the order of `scripts/build.sh`) and `required.config` (options the build checks) |
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
git clone --branch iceland-7.4-rc1 https://github.com/mzakamin-hub/iceland-linux
cd iceland-linux
scripts/prepare.sh ./src        # clones v7.4-rc1, checks the commit, applies every series, checks the tree hashes
scripts/build.sh ./src ./out    # Image, Image.gz, the DTB and the modules; writes out/dist/
```

- `scripts/build.sh` runs `defconfig`, merges `arch/arm64/configs/sm8850.config` (map220v's fragment; drift is reported
  but not fatal), `configs/distro-neutral.config`, `q90b.config`, `q90i.config`, `q90i-shipped.config` and
  `q90m.config` to `q90r.config`, `q90s.config`, `q90t.config`, `q90y.config`, `q90z.config` and `q91c.config` to `q91e.config`, then checks `q90i.config`, `q90i-shipped.config`,
  `q90m.config`, `q90p.config`, `q90s.config`, `q90t.config`, `q90y.config`, `q90z.config`, `q91c.config` to `q91e.config` and `required.config` strictly. The result is the
  same `.config` as the kernel-iceland q91n package's.
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

- The v7.4-rc1 series keep their authors. Some peer picks carry no `Signed-off-by` of their author in the source:
  the armada-os picks (author `Armada`, 0033-q91f 0006-0008, 0036-q91i 0001), virtudude's tsens patch (0036-q91i
  0002) and Yibo Wang's ath12k scan patch (0037-q91j 0005). Our own patches that build on other people's work name
  them with `Suggested-by:`, `Co-developed-by:` or `Based-on:` lines.

Licence: GPL-2.0 (Linux `COPYING`). Every patch keeps its authorship and SPDX headers. Proprietary firmware is never
stored here; the generic firmware is in [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware).

## Related repositories

- [iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline): the project, the boot chain, the install guide,
  the device package and the [list of working features](https://github.com/mzakamin-hub/iceland-mainline/blob/main/docs/FEATURES.md).
- [iceland-u-boot](https://github.com/mzakamin-hub/iceland-u-boot): the U-Boot that starts this kernel.
- [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware): the generic firmware files.
- Upstream: [Linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git) (`v7.4-rc1`) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
