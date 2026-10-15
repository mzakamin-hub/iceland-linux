# Port log — map220v iceland-7.2 (Linux 7.2) → infiniti-mainline master (Linux 7.3-rc4)

Current base (14 Oct 2026): Linux v7.3-rc7, queue q89g. The port table below is the rc4 port; the kernel history
after it, to 14 Oct 2026, is at the end.

Base changed from "Linux 7.2 + map220v" to "Linux 7.3-rc4 + infiniti-mainline (OnePlus 15, same SoC) + ported
Pad 4 commits": infiniti already carries most SoC work (GPU, WCN7860 Wi-Fi/BT, QFPROM, SOCCP, iris, CAMSS,
DP, ADC5 Gen4, crypto, remoteproc fixes), so porting map220v's device commits forward is far smaller than
backporting ~100 SoC commits to 7.2. Every map220v commit is accounted for below (index = position in
map220v's series).

| # | Result | map220v commit / note |
|---|---|---|
| 1 | SKIP | late attach (superseded by upstream 7.3 implementation) |
| 2 | SKIP | SoCCP PAS entry (already upstream) |
| 3 | SKIP | arm64: dts: qcom: kaanapali: add the GPU SMMU node |
| 4 | SKIP | arm64: dts: qcom: kaanapali: Add qfprom node |
| 5 | SKIP | arm64: dts: qcom: Add GPU support for Kaanapali |
| 6 | SKIP | arm64: dts: qcom: kaanapali: Add GPU cooling |
| 7 | EMPTY | SM8850: Fix gpuss thermal polling delay (already upstream) |
| 8 | SKIP | SM8850: Add SOCCP nodes (already in infiniti/7.3 as soccp_smp2p_*; map220v's extra SOCCP->EBI1 interconnect vote not carried — revisit if SOCCP attach needs it) |
| 9 | PORT | SM8850: Add DSI1 nodes (conflict with infiniti DP controller node; DSI1+PHY inserted after mdss_dp0) |
| 10 | SKIP | wifi: ath12k: add initial hardware definition for WCN7860 |
| 11 | SKIP | wifi: ath12k: send QDSS config when CNSS_QDSS_CFG_MISS_V01 is disabled |
| 12 | SKIP | wifi: ath12k: disable CNSS_QDSS_CFG_MISS_V01 for the WCN7860 |
| 13 | SKIP | PCI/pwrctrl: pwrseq: add support for WCN7860 |
| 14 | SKIP | power: sequencing: qcom-wcn: add support for WCN7860 |
| 15 | SKIP | Bluetooth: qca: add WCN7860 support |
| 16 | PORT | SM8850: Add device tree for OnePlus Pad 4 (Makefile: kept infiniti + iceland entries) |
| 17 | OK | SM8850: Add sm8850.config fragment |
| 18 | DROP | drm/msm/dsi: change sync mode to DSI0 (upstream NT36536 driver + msm sync on DSI1, as on Lenovo Y700; test item, fallback = restore this commit) |
| 19 | SKIP | drm/msm/dsi: support DSC slice_per_pkt > 1 (upstream 7.3 has MIPI_DSI_MODE_DSC_ALL_SLICES_IN_PKT; panel driver adapted in its own port) |
| 20 | PORT | backlight: Add KTZ8869 driver (Kconfig next to new upstream SY7758 entry) |
| 21 | OK | ICELAND: Add KTZ8869 nodes |
| 22 | SKIP | drm/msm/dpu: DMA SSPP rect offsets (already upstream, whitespace-only difference) |
| 23 | OK | drm/msm/dpu: Fix Compressed width calculation |
| 24 | SKIP | drm/panel: NT36536 driver (upstream 7.3 has panel-novatek-nt36536.c by Pengyu Luo; Pad 4 panel added to it as a new desc in our commit) |
| 24b | NEW | drm/panel: nt36536: Add the OnePlus Pad 4 panel (port of map220v's panel data into upstream driver) |
| 25 | OK | ICELAND: Add panel node |
| 26 | PORT | Input: Add NT36536 touch driver (Makefile next to upstream synaptics_tcm_spi) |
| 27 | OK | ICELAND: Add touchscreen node |
| 28 | OK | SM8850: Fix GMU address |
| 29 | OK | SM8850: Add cache info |
| 30 | PORT | qcom_battmgr: use infiniti's Oplus charger support + oneplus,iceland-pmic-glink (replaces map220v variant) |
| 31 | PORT | ASoC: TFA9865 driver (Kconfig/Makefile next to infiniti TFA9866) |
| 32 | OK | ICELAND: Add sound nodes |
| 33 | EMPTY | SM8850: Update GPU OPP table (already upstream) |
| 34 | EMPTY | arm64: dts: qcom: kaanapali: Add missing properties to usb controller (already upstream) |
| 35 | OK | ICELAND: Remove usb-role-switch |
| 36 | OK | ICELAND: Reserve llcc_lpi_mem to fix Gunyah crash |
| 37 | OK | ICELAND: Reserve adsp_mhi_mem and global_sync_mem Both have XN=2(EL1&EL0 NOEXEC) in VTTBR |
| 38 | EMPTY | drm/msm/dpu: Drop sneaky dev_pm_opp_set_rate(0) (already upstream) |
| 39 | SKIP | drm/msm/dp: Drop dev_pm_opp_set_rate(0) (no such call left upstream) |
| 40 | EMPTY | drm/msm/dsi: Drop dev_pm_opp_set_rate(0) (already upstream) |

Legend: OK = applied unchanged · PORT = applied with conflict resolution (author kept) · SKIP = already in
upstream/infiniti or superseded · EMPTY = identical change already present · DROP = intentionally left out ·
NEW = our own commit replacing a map220v commit (map220v credited in the message).

## Follow-up commits (ours)
- `arm64: dts: qcom: kaanapali-oneplus-iceland: Match the upstream NT36536 panel driver` — `csot,xn251`, vsp/vsn.
- `arm64: dts: qcom: kaanapali-oneplus-iceland: Drop the modem remoteproc` — SM8850P has no modem.

## Test items on the tablet (from this port)
1. Panel uses upstream msm dual-DSI sync on DSI1 (commit 18 dropped). If the panel stays dark with the rest
   working, restore map220v's "change sync mode to sync on DSI0" and send commands on dsi[0].
2. Panel PPS is sent before sleep out (map220v order) via `init_sends_pps`.
3. SOCCP: map220v's extra SOCCP→EBI1 interconnect vote is not carried (infiniti's SOCCP node is used).
4. Battery: infiniti's Oplus charger support replaces map220v's simpler variant.

## The speaker chain (0038-0050)
Stock drives the six TFA9865 over **TDM-LPAIF-RX-PRIMARY** (8 slots x 32 bit, 48 kHz), not Primary MI2S. The
working chain, link by link:
1. **DT link on PRIMARY_TDM_RX_0** with the slot layout (0038).
2. **Classic TDM endpoint in audioreach** (0041): the stock ADSP has no Audio Interface (QAIF) module.
3. **The TDM bit clock:** in q6prm (0042), voted from the DT (0043).
4. **The TDM back ends at 32 bit, one channel per slot** (0044); default 6/8-channel maps (0045).
5. **A device-subgraph MFC** in the Pad 4 topology (iceland-mainline `audio/topology`), so the 2-ch/16-bit stream
   is converted to the 8-ch/32-bit endpoint format. Without it the stream ran 8x too fast.
6. **Stock TDM tables for each amplifier** (0046): reg 0x20 = 0x6f91; the speaker/sense slots 0-5 in regs
   0x21/0x22, from the stock container. The old tables were for a 2-slot I2S frame.
7. **MANSCONF after every power-up** (0047). The amplifier's manager waits in "wait for source settings" until
   MANSCONF ("I2C configured") is set, and it clears MANSCONF itself while the TDM setup doesn't match the frame.
8. **A TDM channel map** (0048) and the **Pad 4 card** spreading stereo as FL FR FL FR FL FR FL FR (0049): left =
   slots 0/2/4 (i2c0 0x34/0x36/0x37), right = slots 1/3/5 (i2c22). The DT compatible `oneplus,iceland-sndcard`
   (0050).
Proof:
- iceland-mainline sessions 26r-26u (items S16-S19; the test records are not in this repository).
- area-audio-1 (2026-09-29): all six amplifiers engage on stereo, each side exactly its three, and the user heard
  GNOME's Sound test.
0051: the audioreach volume control stays within the topology maximum (area-audio-2: writes above 2056 rejected with EINVAL).
0052: the WCD939x analog TX gain scale, 1.5 dB per step without a mute (measured in area-audio-2, reported in area-audio-4).

## Kernel history after the port (to 14 Oct 2026)

Condensed from the project log. Golden = the rehearsal image of that queue (see the README table).

- **28-30 Sep (queue on rc4):** suspend fixed (PCIe WAKE# polarity, 0040); 144 Hz black screen (0058); pink UBWC
  glitch (0060); thermal trips and cooling maps at stock (0022-0023); a freeze under fast USB traffic (0063); hardware
  video decode checked bit-exact. The green picture was traced to a debug option and fixed in the config.
- **1-2 Oct:** NPU, microphone, Wi-Fi 5 GHz (0066-0068); the first camera frames from both sensors; battery estimate
  (0071-0072); libcamera on both cameras (0073); charging as stock (0078-0080); camera focus motor (0087-0089); pogo
  keyboard and pen charger (0090-0097).
- **3-9 Oct (q84 to q87, rc4 base):** the first consolidated build and its goldens (B112, B118). The fresh-boot
  rehearsal of q87 (golden B123) showed a microphone stall in 3 of 10 fresh opens (F55), so that image was held. Queue 0190 was added
  with the F55 work in q87 (commit a8739a6).
- **10 Oct: rc6 rebase (q89 -> q89b).** The F55 replay passes on q89b; golden B130 confirmed it. The tb323fu-linux
  patches were added as q89c-tb (0255-0265). An upstream scan by hardware block ran the same day.
- **11-12 Oct: q89d8 and q89d9.** The SuperTurtleDev and tb323fu items were added (0266-0290, q89d8, golden B143,
  first clean final rehearsal). 0291 (q89d9, golden B145) discards the RX burst of the WCN7860 baud-rate change, which
  caused the Bluetooth "-84" line. Then the rc7 rebase started (q89e).
- **13 Oct: rc7 and the final queue.** q89e (rc7, 0292 iris colorimetry) with the microphone chain is golden B147
  (06:02). q89f (0293-0305) adds the brightness limit at thermal level, the focus lens fixes (K7), the wake fix (K6)
  and the idle refresh rate, compiled in and off. q89g (0306) makes the focus lens hold its position. Its golden,
  B149, was committed at 15:45 after the final rehearsal and is the image the owner installed that evening.
- **14 Oct:** q89g is on `main`. The DisplayPort-over-USB-C investigation found no picture. The DT allows up to HBR3 on
  two lanes; whether the monitor's power draw causes a supply cut-off is unverified. The power diagnostic of the installed system is recorded in
  the iceland-mainline project notes.

Test items left open by the port (from the rc4 table above, unchanged): the speaker level check on the installed
system; the Android comparison is inconclusive and the owner's listening check decides.
