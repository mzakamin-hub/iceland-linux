# Kernel q89c-tb - q89b + 11 patches from tb323fu-linux (10 Oct 2026)

Branch `iceland-7.3-rc6-q89c-tb`, tag `q89c-tb`. Built and tested as 7.3.0-rc6-iceland-00388-g9093690257a0
(config and DTB identical to q89b). Status: **TEST CANDIDATE, NOT the shipping kernel** - q89b (branch
`iceland-7.3-rc6-q89b`, tags `q89b` / `q89b-1`) stays the kernel of the install image. `main` is unchanged.

Source: [joonhoekim/tb323fu-linux](https://github.com/joonhoekim/tb323fu-linux) (Lenovo Legion Tab Gen 5 /
TB323FU, the same SM8850 SoC, commit 0c7c0c477d4f, 9 Oct 2026), its "Add" list as chosen by the owner. The
patches keep their author (Joonhoe Kim) and date; "tb" = the number in that queue.

| Here | tb | Patch | Note |
|---|---|---|---|
| 0255 | 0129 | scsi: ufs: core: Fix a deadlock between clock scaling and device commands | lore link in the patch (Manivannan Sadhasivam's series) |
| 0256 | 0046 | clk: qcom: gdsc: keep the clock controller active while a GDSC is on | author's Signed-off-by missing |
| 0257 | 0103 | clk: qcom: gdsc: drop the controller reference only if it was taken | author's Signed-off-by missing |
| 0258 | 0061 | usb: typec: ucsi: run connector change handling on the freezable workqueue | author's Signed-off-by missing |
| 0259 | 0113 | wifi: ath12k: keep the RX refill ring from running dry | compile-tested upstream |
| 0260 | 0058 | wifi: ath12k: don't wake the device over MHI from the panic notifier | author's Signed-off-by missing; not exercised (panic test off) |
| 0261 | 0130 | Bluetooth: qca: check the device address on every setup | |
| 0262 | 0114 | net: qrtr: ns: retry announcements the new node is not ready for yet | |
| 0263 | 0116 | media: qcom: camss: hold the bandwidth vote while TITAN_TOP is powered | |
| 0264 | 0057 | drm/msm/dp: retrain the link on a quick replug while streaming | author's Signed-off-by missing; not exercised (USB-C carried the test root) |
| 0265 | 0098 | drm/msm/dp: hold one runtime PM reference per plugged state | PORTED: only the msm_dp_bridge_detect half (our plug handler already returns early; `[mzak: ...]` note); author's Signed-off-by missing |

Not taken: tb 0036 (f_ncm timer; our 3351b94e2e already re-arms it, does not apply), tb 0128 (= our 0230).

**Authorship / sign-off:** six patches (0256, 0257, 0258, 0260, 0264, 0265) carry no Signed-off-by of their
author in the source queue, only ours (added when they were picked). They are kept here with the author's name as
published, for testing on this tablet only; they are not upstreamable as they are and must not be sent anywhere
before the author signs them off.

Tests (10 Oct 2026, kernel q89c-tb + iceland-device 0.26):

- Rehearsal r2x (installed image booted from the PC over NBD): btaddr same address x3 (0261), qrtr (0262), dp-rpm
  suspended with nothing plugged (0265), wifi-refill counters (0259), dmaheap, gpu-opp PASS; then ABORTED by a
  tablet reset when the test suspended the tablet with its root on NBD (bootloader log "Reset by PSHOLD"): the
  house rule "no suspend in a rehearsal session" (same signature as R2-final), not the kernel - none of these
  patches touches audio or the NBD path; config / DTB / cmdline = q89b.
- RAM kit 132 (root in RAM): pm_test freezer / devices / platform / full PASS, 9 suspends 9 success 0 fail,
  gdsc 0256 / 0257 PASS, ucsi 0258 PASS (charger unplug / plug windows PASS), wake rules PASS. ufs 0255 CHECK (no
  error or hung task under 2.28 M random reads + 3 suspends, but no clock-scaling transition happened, so the
  deadlock path was not exercised). Hardware sleep counter +0 in both measured suspends.
- FAIL, under investigation: sensors - iio-sensor-proxy stuck "activating", no accelerometer after resume (kit
  132); not yet known whether kernel or the 0.26 sensor sleep hook.
- Rehearsal r2y was stopped by the owner before results.
