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
- **Queue:** q90u (tag `q90u`), kernel release `7.3.0-next-20261020-iceland-00548-g18ffc096fcee`, packaged as
  `kernel-iceland`. The branch name is kept from the v7.3-rc7 queues; since q90b the queue applies onto linux-next
  `next-20261020` and moves to 7.4-rc1 once it is out.
- **New since q90i:**
  - q90j: the debugfs files, log lines and test switches that only served the display-flicker investigation are gone.
  - q90k / q90l: the A840 hardware workaround values, battery current limiter and CLX request of Qualcomm's KGSL
    driver as switches (default off), PSCI SYSTEM_RESET2 vendor resets as reboot modes, ath12k station power save and
    a quieter RX channel fallback, CCI reset on runtime resume, an optional single flush of the shared dual-DSI video
    CTL, and iris EOS only for the drain's last buffer (a seek no longer ends an FFmpeg stream).
  - q90m: the Gunyah hypervisor's VM manager in the tree (built as modules; used by the protected virtual machines of
    [iceland-gvm](https://github.com/mzakamin-hub/iceland-gvm) and [iceland-vms](https://github.com/mzakamin-hub/iceland-vms))
    and the C binder driver back as an option (binderfs, for Android containers).
  - q90n / q90o: named anonymous mappings, the soft and buddy hard-lockup detectors, the Gunyah vCPU timer as a module,
    the resource manager's PM notifier removed on unload (suspend after a VM no longer oopses).
  - q90n also brings iris capture buffer pools and VSP clock fixes, the LPASS macro clocks under runtime PM, the
    qmp-combo DP-only mode and UFS ESI after a host controller reset.
  - q90p: the board's kernel command line as built-in defaults for the OnePlus Pad 4 only (display and panel
    switches; GPU preemption and CLX only with the vendor GPU firmware pair), teo as the default cpuidle governor,
    suspend-to-idle by default, RCU callbacks offloaded with lazy RCU. A value given on the command line still wins.
  - q90q / q90r: upstream fixes for qmp-combo / qmp-usb system sleep, remoteproc, the geni UART, dwc3-qcom, ucsi_glink,
    arm-smmu-qcom, fastrpc, q6apm and qcom-cpucp; drm/msm's October fixes (GMU shutdown idle check, stale boot
    bandwidth vote, devfreq idle time, scheduler priority inversion, preemption records reset across suspend), qrtr
    service re-announce, mac80211 MLO multicast duplicate detection, the qmp-combo DP-only mode v2 and UFS link
    recovery.
  - q90s4 / q90t / q90u: ucsi_glink quiet across system sleep; the Gunyah VM manager never hands memory that may still
    belong to a guest back to the page allocator (fewer failed VM page assigns after a VM stop); UFS device-management
    timeouts in jiffies again and runtime-resume errors reported; the inline crypto engine enabled before crypto use,
    with runtime PM support; vhost-net as a module (for virtio-net in VMs); writeback throttling and the LZ4 zram
    backend available; ath12k no longer re-creates its debugfs files on a firmware restart; a quieter Gunyah log probe.
  - **Optional tunables, all off by default** (the kernel behaves as without them until one is set):
    `ath12k.cold_boot_cal` (Wi-Fi cold-boot calibration), `qcom_iris.decode_order_output` (decode-order output for
    VA-API style clients), `scmi_qcom_memlat_devfreq.stock_gating` (the vendor's memory-latency ceilings),
    `panel_novatek_nt36536.cabc_mode` (panel CABC 0-3), `ath12k.pcie_ltr_off` (Wi-Fi PCIe LTR off),
    `spi_geni_qcom.gpi_cpu_latency_us` (CPU latency limit during GPI DMA SPI transfers), the inline crypto engine's
    `power/control` (`auto` = runtime PM), `/sys/block/<dev>/queue/wbt_lat_usec` (writeback throttling) and
    `gunyah_qcom.debug_assign` (debug logging).
- **`main`** holds the older queue q89g, the kernel of the first install image. Later queues are only on
  `iceland-7.3-rc7-next`.

## Download

The newest release download is q90u: the [`q90u` release](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90u)
has:

- `kernel-iceland-7.3.0.next.20261020.iceland.00548.g18ffc096fcee-1.fc44.aarch64.rpm`, the Fedora 44 package for the
  tablet;
- the source RPM, which carries this repository's queue, and `SHA256SUMS`.

Check the files with `sha256sum -c SHA256SUMS`. On the tablet's Fedora 44 system, install the package with dnf:

```bash
sudo dnf install ./kernel-iceland-7.3.0.next.20261020.iceland.00548.g18ffc096fcee-1.fc44.aarch64.rpm
```

Earlier releases: [q90r](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90r),
[q90i](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90i),
[q89w](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89w),
[q89m](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89m),
[q89l](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89l) and
[q89k](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89k).

## What is in the repository

The counts below are for `iceland-7.3-rc7-next`.

| Path | Content |
|---|---|
| `kernel.pin` | the upstream tag and commit, the tree hash expected after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | 110 patches from infiniti-mainline/linux (OnePlus 15, the same SoC), rebased onto `next-20261020` |
| `patches/0002-iceland/` | 304 patches: the OnePlus Pad 4 series, numbered with gaps up to 0412 |
| `patches/0003-glitchfix/` to `patches/0022-q90u/` | 134 patches: the display-timing switches of q89z, then one series per queue q90b to q90u (upstream picks and our fixes; there is no q90j series: q90j only removed patches) |
| `configs/` | `distro-neutral.config`, `q90b.config`, `q90i.config`, `q90i-shipped.config`, `q90m.config` to `q90r.config`, `q90s.config` and `q90t.config` (merged into the build, in that order) and `required.config` (options the build checks) |
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
  but not fatal), `configs/distro-neutral.config`, `q90b.config`, `q90i.config`, `q90i-shipped.config` and
  `q90m.config` to `q90r.config`, `q90s.config` and `q90t.config`, then checks `q90i.config`, `q90i-shipped.config`,
  `q90m.config`, `q90p.config`, `q90s.config`, `q90t.config` and `required.config` strictly. The result is the same
  `.config` as the kernel-iceland q90u package's.
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
