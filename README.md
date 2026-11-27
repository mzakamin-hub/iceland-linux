# iceland-linux

The Linux kernel for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"). The kernel is kept as a patch
queue on an upstream tag, Linux `v7.4-rc4`, so every commit keeps its original author. postmarketOS kernel packages
and other tablet ports work the same way.

This repository is one part of the project. The hub,
[iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline), describes the system the tablet runs (Arch
Linux ARM with KDE Plasma), the boot chain and the install. Its
[CREDITS.md](https://github.com/mzakamin-hub/iceland-mainline/blob/main/CREDITS.md) lists everyone whose work the
kernel uses.

## Current kernel

- **Branch:** [`iceland-7.4-rc4`](https://github.com/mzakamin-hub/iceland-linux/tree/iceland-7.4-rc4), tag `q92d`.
  Build from this branch or the tag.
- **Queue:** q92d, kernel release `7.4.0-rc4-iceland-00827-g08a7adc3c104`, on Linux `v7.4-rc4`. It is packaged for
  Arch Linux ARM as `linux-iceland-q92d`. The released queues have their own tags (`q91c` to `q91k`, `q91n`, `q92d`).
- **New since q91n:**
  - Base: the queue moved from `v7.4-rc1` to `v7.4-rc4`. 79 patches were merged upstream, replaced by their
    upstream version, or cancelled out by their revert. See [docs/Q92D-QUEUE.md](docs/Q92D-QUEUE.md).
  - GPU: the msm VM_BIND lifetime fixes, drm_gpuvm two-pass locking, and drm_sched / dma-fence ordering fixes.
    Queued submits fail cleanly when the GPU does not recover. Rob Clark's A8xx IFPC / CP_PROTECT_PIPE reglist
    patches are in.
  - Display: the DP controller stays resumed while DP is in use. A monitor that is plugged in at boot is found
    (aux-hpd). The DPU timeouts allow for a stretched idle frame. The DSI1 nodes come after the DSI0 PHY.
  - Sleep: a suspend through the `/sys/power/wakeup_count` handshake (KDE's powerdevil) no longer aborts while a
    sensor streams (smp2p_sleepstate).
  - Audio: q6apm playback across PCM resets. The LPASS clocks and q6prm survive a DSP restart. TDM channels come
    from the DT mask. LPASS LPI / SoundWire runtime suspend in system sleep, now in the upstream form.
  - Bluetooth and Wi-Fi: L2CAP security checks. ath12k fixes for recovery, teardown, 6 GHz TX power, an unverified
    hardware link id and scan priority.
  - Platform and media: Qualcomm smp2p / apr / pdr / glink bounds fixes, GICv3 ITS and SCMI fixes, UFS
    system-suspend helpers, the qcom_battmgr pmic_glink use-after-free on unbind, the Type-C orientation switch
    init. Iris and v4l2 fixes: seeks, picture-less buffers, the AV1 / VP9 buffer floor.
  - Charging: dappermint's SuperVOOC driver
    ([dappermint/iceland-supervooc](https://github.com/dappermint/iceland-supervooc)), imported unchanged with his
    authorship (series `0042-q91o-plus`). Our commits on top of it keep it off:
    - the module never loads by itself;
    - a session ends at 85 % and needs the battery authentication;
    - the 7.3 A ceiling is asserted at build time.
    His thermal guards are unchanged. The charge pump buses stay disabled in the default device tree.
  - **Optional, off by default:** module parameters for fastrpc lifetime fixes, ath12k WoW-resume recovery, the
    SoundWire restart over suspend, pmic_glink / dwc3 sleep deferral, a wedged GPU on a failed recovery, PCIe
    shutdown L2 / PARF halt / suspend link-off, the io-pgtable contiguous hint, the MDSS ACTLR, the GMU slumber
    fixes and a stock-like USB-PD 9 V request. The earlier `msm.*` and q90u tunables are also off by default.
  - **Optional device trees:** `headset` (the USB-C analog headset path of the codec) and `pumpbus` (dappermint's
    patch that enables the two charge pump buses). Both are in the package under `dtb/qcom/variants/` and in the
    release, and neither is installed by default. Their sources are `optional/headset/` and `optional/pumpbus/`.
- **Coming next:** q92e. It replaces our USB-PD charging changes with dappermint's SuperVOOC charging, with the
  charge pumps enabled. It is not tested yet and not released.
- **Older branches:** `iceland-7.4-rc1` holds the queues q91c to q91n (with their Fedora RPM packaging), and
  `iceland-7.3-rc7-next` and older hold the 7.3 queues. `main` holds the queue of the first install image.

## Download

The newest release is q92d: the [`q92d` release](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q92d)
has:

- `linux-iceland-q92d-7.4.0rc4.00827.g08a7adc3c104-1-aarch64.pkg.tar.zst`, the Arch Linux ARM package for the
  tablet, and its detached signature `.sig`;
- `iceland-project-key.asc`, the public key that made the signature;
- `kaanapali-oneplus-iceland-headset.dtb` and `kaanapali-oneplus-iceland-pumpbus.dtb`, the optional device trees
  (also in the package);
- `iceland-linux-q92d.tar.gz`, this repository at tag `q92d` (the queue, scripts, config and PKGBUILD);
- `SHA256SUMS`.

Check the files, then install the package with pacman:

```bash
sha256sum -c SHA256SUMS
gpg --import iceland-project-key.asc
gpg --verify linux-iceland-q92d-7.4.0rc4.00827.g08a7adc3c104-1-aarch64.pkg.tar.zst.sig
sudo pacman -U linux-iceland-q92d-7.4.0rc4.00827.g08a7adc3c104-1-aarch64.pkg.tar.zst
```

With `iceland-coexist` from the hub installed, the kernel gets its own boot entry and the default stays as it was.
See [packaging/arch/README.md](packaging/arch/README.md) and the hub's
[daily use](https://github.com/mzakamin-hub/iceland-mainline#3-daily-use-and-updates) section.

Earlier releases: [q91n](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91n),
[q91k](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q91k),
[q90z](https://github.com/mzakamin-hub/iceland-linux/releases/tag/q90z) and older. Those are Fedora RPMs.

## What is in the repository

The counts below are for `iceland-7.4-rc4`.

| Path | Content |
|---|---|
| `kernel.pin` | the upstream tag, commit and tree, the tree hash expected after each series, a note per queue |
| `patches/0001-infiniti/` | the patches from infiniti-mainline/linux (OnePlus 15, the same SoC), on `v7.4-rc4` |
| `patches/0002-iceland/` | the OnePlus Pad 4 series, numbered with gaps up to 0412 |
| `patches/0003-glitchfix/` to `patches/0040-q91n/` | one series per queue q90b to q91n, replayed on `v7.4-rc4` (file names kept, numbers with gaps) |
| `patches/0041-q91o/` to `patches/0048-q92d/` | the series of the queues q91o to q92d (upstream and list picks, peer picks, imported drivers and our fixes; one series per queue) |
| `optional/headset/`, `optional/pumpbus/` | the device tree changes of the optional DTBs (not applied by `scripts/prepare.sh`) |
| `configs/` | `distro-neutral.config`, then one fragment per queue up to `q92d.config` (merged in the order of `scripts/build.sh`), and `required.config` (options the build checks) |
| `scripts/prepare.sh` | clones the upstream tag, checks its commit, applies every series with `git am`, checks the tree hashes |
| `scripts/build.sh` | configures and builds the kernel; writes `out/dist/` with `BUILD_INFO` and `SHA256SUMS` |
| `packaging/arch/linux-iceland/` | the Arch Linux ARM package: `PKGBUILD`, `kbuild.sh`, the package config `config-q92d` |
| `docs/` | `Q92D-QUEUE.md` (the v7.4-rc4 rebase and the new series), the older queue notes, `PORT-LOG.md` and `PROVENANCE.md` |
| `.github/workflows/build.yml` | a manual GitHub Actions build of the kernel |

## Build

Packages needed on Ubuntu 24.04 (the list the GitHub workflow installs): `clang lld llvm flex bison bc libssl-dev
libelf-dev device-tree-compiler zstd cpio`. The build uses LLVM (`LLVM=1`), so a PC cross-builds the arm64 kernel
without a separate cross compiler. On Arch Linux the same tools are `clang lld llvm bc bison flex perl python pahole
cpio xz zstd`.

```bash
git clone --branch iceland-7.4-rc4 https://github.com/mzakamin-hub/iceland-linux
cd iceland-linux
scripts/prepare.sh ./src        # clones v7.4-rc4, checks the commit, applies every series, checks the tree hashes
scripts/build.sh ./src ./out    # Image, Image.gz, the DTB and the modules; writes out/dist/
```

- `scripts/build.sh` starts from `defconfig`. It merges `arch/arm64/configs/sm8850.config` (map220v's fragment;
  drift is reported but not fatal), then `configs/distro-neutral.config` and the queue fragments `q90b.config` to
  `q92d.config`. The queue fragments and `required.config` are then checked strictly. A failed strict check stops
  the build unless `ALLOW_CONFIG_DRIFT=1` is set. The result is the config of the released q92d package (the
  toolchain version lines aside).
- `out/dist/` holds:
  - `Image`, `Image.gz` and `kaanapali-oneplus-iceland.dtb`;
  - the config and `modules-<release>.tar.zst`;
  - `BUILD_INFO` (kernel release, source commit, queue commit, compiler) and `SHA256SUMS`.
- The commit hashes that `scripts/prepare.sh` makes depend on the committer, so the `-g<hash>` part of your kernel
  release can differ from the released package's. The tree hashes do not depend on the committer.
- **The Arch package:** `packaging/arch/linux-iceland/kbuild.sh ./src ./out <tarball>` runs the build above, checks
  the config, builds the optional DTBs and stages the package tree. `makepkg` in an Arch Linux ARM aarch64
  environment then packages it. You can also build natively on aarch64 with `ICELAND_KERNEL_MODE=native makepkg`.
  See [packaging/arch/README.md](packaging/arch/README.md).
- The GitHub workflow runs the same build when it is started by hand. It keeps `out/dist/` as an artifact for 14 days
  and does not build the package.

## Authorship and sign-off

- Every series keeps the authors of its patches. Picked patches say where they come from in the commit message.
- 0255-0265 in `0002-iceland` come from [joonhoekim/tb323fu-linux](https://github.com/joonhoekim/tb323fu-linux) and
  keep their author, Joonhoe Kim. Six of them (0256, 0257, 0258, 0260, 0264, 0265) carry no `Signed-off-by` of
  their author in the source queue, only ours.
- 0266-0290 keep their authors. Five of them carry no `Signed-off-by` of their author in the source: 0274, 0275 and
  0276 by Joonhoe Kim, and 0279 and 0284 by Yibo Wang (SuperTurtleDev's iceland-mainline-kernel work).
- Some peer picks of the v7.4 series also carry no `Signed-off-by` of their author in the source:
  - the armada-os picks (author `Armada`): 0033-q91f 0006-0008 and 0036-q91i 0001;
  - virtudude's tsens patch: 0036-q91i 0002;
  - Yibo Wang's ath12k scan patch: 0037-q91j 0005.
- The three commits of dappermint's `iceland-supervooc` (`0042-q91o-plus` 0001-0003, git identity "millia
  ampora") are imported unchanged from his repository and carry no `Signed-off-by`. His DT patch in
  `optional/pumpbus/` does.
- Our own patches that build on other people's work name them with `Suggested-by:`, `Co-developed-by:`,
  `Based-on:` or "re-implemented" credits.
- These patches are for this tablet only. They are not upstreamable as they are, and none is sent anywhere before
  its author signs it off. [docs/PROVENANCE.md](docs/PROVENANCE.md) records where five of the tb323fu patches came
  from.
- 0292 (iris colorimetry) is carried in the kernel but is not sent upstream (the owner's decision; the kernel would
  require an `Assisted-by` line for it).

Licence: GPL-2.0 (Linux `COPYING`). Every patch keeps its authorship and SPDX headers. Proprietary firmware is never
stored here; the generic firmware is in [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware).

## Related repositories

- [iceland-mainline](https://github.com/mzakamin-hub/iceland-mainline): the project hub. It has the boot chain, the
  install guide, the Arch packaging of the device packages (`iceland-coexist`, `iceland-device` and others), the
  [list of working features](https://github.com/mzakamin-hub/iceland-mainline/blob/main/docs/FEATURES.md) and the
  [credits](https://github.com/mzakamin-hub/iceland-mainline/blob/main/CREDITS.md).
- [iceland-u-boot](https://github.com/mzakamin-hub/iceland-u-boot): the U-Boot that starts this kernel.
- [iceland-firmware](https://github.com/mzakamin-hub/iceland-firmware): the generic firmware files.
- [dappermint/iceland-supervooc](https://github.com/dappermint/iceland-supervooc): the SuperVOOC driver's upstream.
- Upstream: [Linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git) (`v7.4-rc4`) and
  [infiniti-mainline/linux](https://github.com/infiniti-mainline/linux) (the first series).
