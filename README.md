# iceland-linux

Mainline Linux for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch queue
on an upstream tag, Linux v7.3-rc7, so every commit keeps its original author. This is the same approach as the
postmarketOS kernel packages and other tablet ports.

Current state (19 Oct 2026): queue **q89w** on the branch `iceland-7.3-rc7-next` (this branch). The kernel release is
`7.3.0-rc7-iceland-00519-gec0a0e306dd9`: Linux v7.3-rc7 plus the queue's 517 patches (132 in `0001-infiniti`, 385 in
`0002-iceland`). It is the current kernel of the Fedora 44 system installed on the tablet, packaged as
`kernel-iceland` and installed with dnf.

The queue commits of q89q to q89w were made while each kernel was a trial build: their subjects say "(TRIAL)" and their
messages "Not for release before the tablet checks". Each of these kernels then passed its checks on the tablet, and
q89w is the current kernel. 0347 (`msm.dpu_dsc_once`) stays off by default.

Wi-Fi PCIe: queue patch 0349 (q89r) limits the Wi-Fi card's PCIe link to Gen2 (5 GT/s). The installed tablet runs the
link at Gen3 (8 GT/s, the card's own speed) through a device-tree override on its default boot entry; 0349 is dropped
from the queue in the next round.

## Download

The current queue q89w has the release [`q89w`](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89w)
(queue commit `c8c8087`): the Fedora 44 package
`kernel-iceland-7.3.0.rc7.iceland.00519.gec0a0e306dd9-1.fc44.aarch64.rpm` (sha256 `b903dfc095cde978...`), its
source RPM and the build's config, with `SHA256SUMS`. Earlier releases:
[`q89m`](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89m),
[`q89l`](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89l),
[`q89k`](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q89k).

## What is in the repository

| Path | Content |
|---|---|
| `kernel.pin` | upstream tag and commit, the expected tree hash after each series, the kernel release of each queue |
| `patches/0001-infiniti/` | 132 patches: infiniti-mainline/linux master (OnePlus 15, same SoC), rebased onto v7.3-rc7 |
| `patches/0002-iceland/` | 385 patches: the OnePlus Pad 4 series, numbered with gaps up to 0402 (see below) |
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
that passed the RAM-boot rehearsals. Since the install (13 Oct 2026) new queues reach the tablet as `kernel-iceland`
updates through dnf: each boots once as a trial and becomes the default after a confirmed boot.

| Queue | Kernel release | Base | Change | Branch / tag | Golden |
|---|---|---|---|---|---|
| q89b | `7.3.0-rc6-iceland-00377-g8e90101870e4` | v7.3-rc6 | first rc6 rebase of the queue ([notes](docs/Q89B-QUEUE.md)) | `iceland-7.3-rc6-q89b`, tag `q89b` (and tag `q89b-1`) | B130 |
| q89c-tb | `7.3.0-rc6-iceland-00388-g9093690257a0` | v7.3-rc6 | + 0255-0265, eleven patches from tb323fu-linux; a test candidate ([notes](docs/Q89C-TB-QUEUE.md)) | `iceland-7.3-rc6-q89c-tb`, tag `q89c-tb` | none |
| q89d8 | `7.3.0-rc6-iceland-00413-gfaa8eeee8c82` | v7.3-rc6 | + 0266-0290, in four stages ([notes](docs/Q89D8-QUEUE.md)) | `iceland-7.3-rc6-q89d8`, tag `q89d8` | B143 |
| q89d9 | `7.3.0-rc6-iceland-00414-g9e7350a6ab86` | v7.3-rc6 | + 0291, the Bluetooth hci_qca baud-rate burst ([notes](docs/Q89D9-QUEUE.md)) | `iceland-7.3-rc6-q89d9`, tag `q89d9` | B145 |
| q89e | `7.3.0-rc7-iceland-00412-g4917dfb48aab` | v7.3-rc7 | q89d9 rebased onto rc7 (three patches merged upstream were dropped) + 0292 | `iceland-7.3-rc7-q89e`, tag `q89e` | B147 |
| q89f | `7.3.0-rc7-iceland-00425-g8165b4e0b2d8` | v7.3-rc7 | + 0293-0305: brightness limit, focus lens, wake, idle refresh rate ([notes](docs/Q89F-QUEUE.md)) | `iceland-7.3-rc7-q89f`, tag `q89f` | none |
| q89g | `7.3.0-rc7-iceland-00426-g520e85da9244` | v7.3-rc7 | + 0306: the focus lens holds its position ([notes](docs/Q89G-QUEUE.md)) | `iceland-7.3-rc7-q89g`, tag `q89g`, `main` | B149 |
| q89h | `7.3.0-rc7-iceland-00428-g8b6c6be9969d` | v7.3-rc7 | + 0307-0308: the SC8547D charge pumps described (disabled), battery manager PD settings | `iceland-7.3-rc7-next` | none (dnf update) |
| q89i | `7.3.0-rc7-iceland-00430-ge15255f5a056` | v7.3-rc7 | + 0310-0311 (A8xx GMU keep-alive register, GPU preemption off by default) and the config commits 0309 / 0312 (binderfs-only binder devices, TEO and lazy RCU built) | `iceland-7.3-rc7-next` | none (dnf update) |
| q89j | `7.3.0-rc7-iceland-00431-g47151df8a814` | v7.3-rc7 | + 0313: the pogo keyboard backlight registered at probe | `iceland-7.3-rc7-next` | none (dnf update) |
| q89k | `7.3.0-rc7-iceland-00436-gf1673c99e731` | v7.3-rc7 | + 0314-0318, upstream fixes: DPU pending-frame count and frame-done timer, ath12k multi-buffer MSDU decap, pmic_glink altmode ack, GPU RSC awake for poweroff | `iceland-7.3-rc7-next` | none (dnf update) |
| q89l | `7.3.0-rc7-iceland-00438-gc7bc30386efe` | v7.3-rc7 | + 0319-0320: the battery's design energy in the device tree and the battery energy reported at its nominal voltage (UPower's full energy 53.80 Wh, was 62.23 Wh = charge x 4.5 V); built with a neutral build host name | `iceland-7.3-rc7-next` | none (dnf update) |
| q89m | `7.3.0-rc7-iceland-00453-ga028210c2e52` | v7.3-rc7 | + 0321-0335: display fixes after a blank / unblank (DPU pending flush, CRTC clock, vblank_off race), the MDSS interrupt CPU resume latency cap, upstream stable fixes (q6apm, ath12k, UCSI, qcom_battmgr, a6xx) | `iceland-7.3-rc7-next`, tag `q89m` | none (dnf update) |
| q89n | `7.3.0-rc7-iceland-00455-g5baf75b61533` | v7.3-rc7 | + 0336-0337: the vsync interrupt of an idle video-mode encoder kept (a switch); the RTC gives no time while its offset is unset | `iceland-7.3-rc7-next` | none (dnf update) |
| q89o | `7.3.0-rc7-iceland-00456-g7cb44cc55f8d` | v7.3-rc7 | + 0338: with GPU preemption, the GPU waits for the GMU to leave IFPC | `iceland-7.3-rc7-next` | none (dnf update) |
| q89p | `7.3.0-rc7-iceland-00464-g16351b002939` | v7.3-rc7 | + 0339-0346: q6apm unmap fixes, the UCSI connector race, drm_exec prelocked objects, msm VM_BIND submit check, the DPU pending-flush clear as a switch, no placeholder Bluetooth address in the device tree | `iceland-7.3-rc7-next` | none (dnf update) |
| q89q | `7.3.0-rc7-iceland-00465-g12077ab9264e` | v7.3-rc7 | + 0347: the DSC blocks programmed once per enable (`msm.dpu_dsc_once`, off by default) | `iceland-7.3-rc7-next` | none (dnf update) |
| q89r | `7.3.0-rc7-iceland-00467-g66b3328b54d9` | v7.3-rc7 | + 0348-0349: fastrpc user waits freezable; the Wi-Fi PCIe link limited to Gen2 (see above) | `iceland-7.3-rc7-next` | none (dnf update) |
| q89s | `7.3.0-rc7-iceland-00480-g390139cb1641` | v7.3-rc7 | + 0350-0362: ath12k RX ring size, the SMP2P sleep-state notifier for the DSPs, 0255 / 0262 replaced by their posted versions, UFS / cmd-db / wcd-common / iris fixes, the USB / DP PHY as a mode switch | `iceland-7.3-rc7-next` | none (dnf update) |
| q89t | `7.3.0-rc7-iceland-00481-gf27a488fdec9` | v7.3-rc7 | + 0363: a video-mode DSI slave torn down only after both timing engines stop (no underrun at screen off) | `iceland-7.3-rc7-next` | none (dnf update) |
| q89u | `7.3.0-rc7-iceland-00487-gd9580aa77bd5` | v7.3-rc7 | + 0365-0370: iris, power-supply and ath12k upstream fixes | `iceland-7.3-rc7-next` | none (dnf update) |
| q89v | `7.3.0-rc7-iceland-00511-g85d399a435db` | v7.3-rc7 | + 0371-0394: a 120 <-> 60 Hz change made in place without a modeset (`msm.dpu_vfp_inplace`), DSI PHY / PLL and SMMU fault-dump fixes, fastrpc / pas / ath12k / iris / dw9719 fixes, PCIe T_POWER_ON, CPU bandwidth monitors voting for LLCC; config: everyday USB / HID / network / file-system options, IOMMU in lazy mode | `iceland-7.3-rc7-next` | none (dnf update) |
| **q89w** | `7.3.0-rc7-iceland-00519-gec0a0e306dd9` | v7.3-rc7 | + 0395-0402: DisplayPort over USB-C sized to the lanes of the Type-C pin assignment, with a link-training fallback and `msm.dp_max_lanes` (not yet tested with a monitor); the in-place vertical total written in a front-porch window; config: modules for USB-C devices (card readers, serial adapters, LTE modems, USB Wi-Fi) | `iceland-7.3-rc7-next`, tag `q89w` | none (dnf update) |

The earlier queues on Linux 7.3-rc4 (q84 to q87) are not kept on a branch. Their story is in `docs/PORT-LOG.md`.

The idle refresh rate code (0303-0305) is compiled in from q89f on but off by default (`msm.dpu_idle_refresh_ms=0`).

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

- Fedora 44 GNOME runs on the tablet since 13 Oct 2026. Kernel q89w (`7.3.0-rc7-iceland-00519`) is its current kernel
  (19 Oct 2026), installed with dnf.
- What works, feature by feature:
  [iceland-mainline/docs/FEATURES.md](https://github.com/mzakamin-hub/iceland-mainline/blob/main/docs/FEATURES.md).

## Related repositories

- [iceland-u-boot](https://github.com/mzakamin-hub/iceland-u-boot): the U-Boot that starts the kernel.
- [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware): the generic firmware files.
- [iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline): the project, the install guide, the device
  package and the list of working features.
- Upstream: [torvalds/linux](https://github.com/torvalds/linux) (v7.3-rc7) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
