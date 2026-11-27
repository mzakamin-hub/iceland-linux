# Arch Linux ARM packaging

`linux-iceland/` packages the kernel of this repository for Arch Linux ARM (aarch64). The package name carries the
queue, for example `linux-iceland-q92d`. Each kernel's files are all below `/usr/lib/modules/<release>/`, so kernels
install side by side.

The boot entry and the initramfs come from `iceland-coexist`
([iceland-mainline, packaging/arch/iceland-coexist](https://github.com/mzakamin-hub/iceland-mainline/tree/main/packaging/arch)).
Its pacman hook runs `kernel-install add` for a new `linux-iceland-*` package and writes a new boot entry. It never
changes the default entry.

## Files

- `linux-iceland/PKGBUILD`: the package recipe, with two modes:
  - `cross` (the default): packages a tree that `kbuild.sh` made on a PC. The released package was built this way.
  - `native`: `makepkg` on an aarch64 Arch system fetches the tag, then runs `scripts/prepare.sh` and `kbuild.sh`
    itself.
- `linux-iceland/kbuild.sh SRC OUT TARBALL`: runs `scripts/build.sh` and checks that the resulting `.config` equals
  `config-q92d` (the toolchain version lines are ignored). It then builds the optional device trees from
  `optional/*/`, stages `usr/lib/modules/<release>/` and packs the result into `TARBALL`.
- `linux-iceland/config-q92d`: the config of the released q92d package.
- `linux-iceland/linux-iceland.install`: runs `depmod` after the install.

## Cross build on a PC (as for the release)

```bash
git clone --branch q92d https://github.com/mzakamin-hub/iceland-linux && cd iceland-linux
scripts/prepare.sh ./src
packaging/arch/linux-iceland/kbuild.sh ./src ./out packaging/arch/linux-iceland/kbuild-q92d.tar.zst
# then, in an Arch Linux ARM aarch64 environment (a container is enough), as a normal user:
cd packaging/arch/linux-iceland && makepkg --sign      # or without --sign
```

The PC needs `clang lld llvm flex bison bc libssl-dev libelf-dev device-tree-compiler zstd cpio git`. Ubuntu 24.04
package names are used here; the build uses `LLVM=1`.

For the Arch environment on an x86 PC, the hub's guide shows a rootless podman container with qemu-user:
[iceland-mainline, Build from source](https://github.com/mzakamin-hub/iceland-mainline#2-build-from-source).

## Native build on the tablet or another aarch64 Arch system

```bash
cd packaging/arch/linux-iceland && ICELAND_KERNEL_MODE=native makepkg -s
```

## Install

```bash
sudo pacman -U linux-iceland-q92d-7.4.0rc4.00827.g08a7adc3c104-1-aarch64.pkg.tar.zst
```

With `iceland-coexist` installed, the new kernel gets its own boot entry next to the running one.

- To boot it once: `sudo iceland-oneshot arm <name> --entry <entry id>`.
- To make it the default: `sudo grub-editenv /boot/grub2/grubenv set saved_entry=<entry id>`.

The hub's [daily use](https://github.com/mzakamin-hub/iceland-mainline#3-daily-use-and-updates) section has the
details.
