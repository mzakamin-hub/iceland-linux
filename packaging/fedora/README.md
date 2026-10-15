# Fedora packaging

Packages the kernel that `scripts/build.sh` builds as `kernel-iceland` for Fedora 44 (aarch64). The package installs
next to Fedora's own kernels, which the device package keeps off the tablet.

## Files

- `kernel-iceland.spec`: installs the build output under `/usr/lib/modules/<release>/` (the image as `vmlinuz`, the
  modules, `System.map`, the config, the DTB as `dtb/qcom/kaanapali-oneplus-iceland.dtb`, `BUILD_INFO`). The package
  provides `installonlypkg(kernel)`, so several versions can be kept. `%posttrans` runs `kernel-install add`, which
  builds the initramfs (dracut) and the boot entry. The source RPM carries the whole queue repository at the build
  commit, so the source is available with the binary.
- `90-iceland-dtb.install`: a kernel-install plugin that copies the newest kernel-iceland DTB to
  `<ESP>/dtb/qcom/kaanapali-oneplus-iceland.dtb`. U-Boot's EFI boot manager loads that file and applies its fixups
  (ABL's memory map). The previous file is kept in `<ESP>/dtb.prev/`. The boot entry has no GRUB `devicetree` line,
  because GRUB would skip U-Boot's memory fixups.
- `build-rpm.sh BUILD_OUT RPM_OUT [RELEASE]`: builds the binary RPM and the source RPM with `rpmbuild --target aarch64`
  (dist tag `.fc44`). `RELEASE` defaults to 1.

## Version mapping

RPM versions cannot contain `-`, so `build-rpm.sh` maps the kernel release by replacing `-rc` with `~rc` and every
other `-` with `.`:

    7.3.0-rc7-iceland-00426-g520e85da9244  ->  7.3.0~rc7.iceland.00426.g520e85da9244

The `~` makes the release sort before the final 7.3.0. For the q89g build the package is
`kernel-iceland-7.3.0~rc7.iceland.00426.g520e85da9244-1.fc44`.

## Procedure

```
scripts/prepare.sh ./src && scripts/build.sh ./src ./out    # see the repository README
packaging/fedora/build-rpm.sh ./out ./rpms                   # binary and source RPM
packaging/repo/make-repo.sh ./repo ./rpms/*.rpm              # dnf repository, SHA256SUMS
```

`make-repo.sh` keeps the newest three kernel-iceland builds (`KEEP` overrides this), regenerates the metadata with
`createrepo_c`, and writes `SHA256SUMS`. Nothing is published: the repository is copied to the tablet's local
repository (synced by `iceland-repo-sync`, from the device package) or served over the PC's USB network.

## On the tablet

The device package ([iceland-mainline/packaging/iceland-device](https://github.com/mzakamin-hub/iceland-mainline/tree/main/packaging/iceland-device))
excludes Fedora's kernels and makes kernel-iceland the default boot entry. The kernel comes from this project's dnf
repository, not from Fedora.
