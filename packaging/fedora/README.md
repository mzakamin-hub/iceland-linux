# Fedora packaging (PLAN v4 Phase 4b)

- `kernel-iceland.spec`: repackages a `scripts/build.sh` output as `kernel-iceland` (aarch64), installable side by
  side with other versions (`installonlypkg(kernel)`). `%posttrans` runs `kernel-install add` (dracut initramfs + BLS
  entry). The source rpm carries this repo (patch queue + pin + configs) as the corresponding source.
- `90-iceland-dtb.install`: a kernel-install plugin that copies the newest kernel-iceland DT to
  `<ESP>/dtb/qcom/kaanapali-oneplus-iceland.dtb`, where U-Boot's EFI boot manager loads `fdtfile` and applies its
  fixups (ABL's memory map). It keeps the previous file in `<ESP>/dtb.prev/`. There's deliberately no GRUB
  `devicetree` line: GRUB would bypass U-Boot's memory fixups unless the EFI DT fixup protocol is proven.
- `build-rpm.sh BUILD_OUT RPM_OUT [RELEASE]`: builds the binary rpm and the source rpm (rpmbuild, `--target aarch64`).

The version maps `7.3.0-rc4-iceland-NNNNN-gHASH` to `7.3.0~rc4.iceland.NNNNN.gHASH` (rpm versions can't hold `-`).
It pairs with the `iceland-device` package in iceland-mainline (`packaging/iceland-device`), which excludes Fedora's
kernels and makes kernel-iceland the default.
