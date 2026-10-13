# Provenance of patches not written by us

Owner decision 13 Oct 2026: these five patches stay in the queue, with this note on where they came from.

They were written by **Joonhoe Kim <26rote@gmail.com>** for the Lenovo tablet port **tb323fu-linux**
(https://github.com/joonhoekim/tb323fu-linux) and adapted to the OnePlus Pad 4. Their tb323fu versions carry no
`Signed-off-by` of the author, so the commits in this queue carry only our own sign-off. The author has posted related
patches to LKML (for example https://lore.kernel.org/r/20261002130712.50612-1-26rote@gmail.com and
https://lore.kernel.org/r/20261002130656.50577-1-26rote@gmail.com); where an upstream version with the author's sign-off
exists, it replaces ours on the next rebase.

| q89d9 commit | Date | Subject |
|---|---|---|
| 97a06c06eb9f | 2026-09-26 | clk: qcom: gcc-kaanapali: keep the USB GDSCs in retention |
| 84db00f41fdc | 2026-09-27 | usb: dwc3: tell xHCI that it lost its state when the core is powered off |
| b0a54f629419 | 2026-09-26 | usb: dwc3: qcom: arm the eUSB2 line interrupts for wakeup |
| 7d2d246809f8 | 2026-09-26 | drm/msm/dp: retrain the link on a quick replug while streaming |
| 9093690257a0 | 2026-09-27 | drm/msm/dp: hold one runtime PM reference per plugged state |

The same five commits are in the rebased q89e (v7.3-rc7) series unchanged (same patch-id, author, date and message).
Not taken: tb323fu 0110 (idle refresh rate; no Signed-off-by, depends on 0065) - see the iceland-mainline tracker.

The idle refresh rate patches of q89f (0303-0305, drm/msm dsi / dpu) are our own work, written for this queue;
they are not tb323fu 0110 and do not depend on its 0065.
