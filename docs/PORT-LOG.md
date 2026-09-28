# Port log — map220v iceland-7.2 (Linux 7.2) → infiniti-mainline master (Linux 7.3-rc4)

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
