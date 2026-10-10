# Kernel q89b - the queue on v7.3-rc6 (10 Oct 2026)

Branch `iceland-7.3-rc6-q89b`, tag `q89b`. Built and tested as 7.3.0-rc6-iceland-00377-g8e90101870e4.
Status: CANDIDATE (the image built on it is held until a clean fresh-boot rehearsal, the cable-out idle test and the
owner's checks). `main` keeps the v7.3-rc4 queue (0190, kernel q87).

q89b = the q89 trial build below **minus 0202-0205, 0244, 0245, 0253, 0254**:

| Removed | Why (rehearsal r2t on q89) |
|---|---|
| 0202-0205 audioreach / q6apm RFC (patchwork 1181907) | every capture read-done rejected ("RD BUFF Invalid payload size 56"): the kernel's `data_cmd_rsp_rd_sh_mem_ep_data_buffer_done_v2` has the V1 layout (60 bytes), the ADSP sends SPF V2 (56 bytes); 15 / 15 mic opens empty |
| 0244-0245 a6xx CLX (msm-next 967e62fbeecc, 08d5049d9e84) | GPU does not start (HFI GX_BW_PERF_VOTE timeout, OOB GPU_SET timeout, gpu hw init -110) |
| 0253 dw9719 DW9800K update (linuxtv 30346 2/3) | "unknown device id 0xfe" (expects 0xEB): no lens, no camera |
| 0254 wcd939x per-channel switches (patchwork 1180866) | suspected of SoundWire clsh / parity errors; r2u showed they remain without it (open item, not this patch) |

Numbers: 0001-0190 keep their original numbers (gaps: infiniti 0004 / 0005 / 0030 and iceland 0077 / 0155 / 0161
dropped), 0191-0199 = the q88 items, 0200 unused (in rc6), 0201-0252 = the upstream additions kept.

The q89 working notes follow (QUEUE-ADD.md of the up3 workflow, unchanged).

---

# wf/up3 - queue q89: rebase onto v7.3-rc6 + upstream scan additions (10 Oct 2026)

Base: **v7.3-rc6** (a90ee4305c4a, tag object 4eeccbed21e5). No v7.3-rc7 / v7.3 tag existed (torvalds master
fc1c25014ff8, 10 Oct 00:01); rc7 is due 11 Oct.
Tree: `wf/up3/linux` (clone of build/src with alternates; build/src untouched). Branches:
`up3-0190` = rc6 + queue 0001-0190 rebased (322 commits), `up3` = + 0191-0199, `up3-q` = + 0201-0254 replayed from
`queue.list` (the built q89 commit b21593befe0b), `up3-add` = the trial branch (same tree 616cc0e34b3e),
`up3-opt` = up3-q + 9e47ad9c5 (optional, not built).
Files: `queue.list` (0191-0199 = wf/q88k/cand unchanged, 0201-0254 = wf/up3/cand), `up3.msg`, `cand/`,
`queue-add.tsv`, `export/rebased-0001-0190/` (format-patch of the rebased 322), `pid/rebase.log` (per-commit result).

## Rebase 0001-0190 (+ q88k 0191-0200)

| Result | Count | Items |
|---|---|---|
| cherry-picked unchanged (patch-id identical) | 322 | all others |
| dropped, patch-id in rc4..rc6 | 5 | infiniti 0004 = 2de1066dc859 (serial: qcom-geni: keep registered console runtime active); infiniti 0005 = 34b8b2d78b62 (q6v5_pas: Don't enable handover IRQ on attach); infiniti 0030 = b52d695d0620 (ufs: core: Keep internal commands dispatchable during error handling); iceland 0155 = 9db31edf92dd (qcom_q6v5_pas: Fix error masking in qcom_pas_stop()); iceland 0161 = cb97bf3d4f91 (i2c: qcom-geni: Fix hardcoded clock index in SE_GENI_CLK_SEL) |
| dropped, superseded (the one conflict) | 1 | iceland 0077 "thermal: gov_step_wise: drop the request of a trip that needs no mitigation" = upstream ec0d89150a93 "Fix stale mitigation vote with non-zero lower bounds" (same code: return THERMAL_NO_TARGET, cur_state test removed; only our header comment differed) |
| q88k 0191-0199 | 9 | apply unchanged |
| q88k 0200 (3872cc6b9294 arm64 topology freq overflow) | dropped | in v7.3-rc6 itself; number 0200 left unused |

## Added 0201-0254 (54)

Apply: am3 = `git am -3` clean; fix = rebased by hand (wf/up3/scripts/fixes/*.py, note in the message).

| # | Patch | Source | Apply | Risk / what to watch |
|---|---|---|---|---|
| 0201 | ASoC: qcom: q6apm: clear g_apm on driver removal | sound for-next be2172758f2b | am3 | low; prerequisite context of 0204 |
| 0202 | ASoC: qcom: audioreach: exclude headers and padding from PCM format sizes (RFC 1/4) | patchwork 1181907 (Zhang Jiaxi, 8 Oct) | am3 | **medium-high**: RFC, changes the PCM media-format payload lengths sent to the ADSP; F55 lead. Watch playback + capture start, APM errors |
| 0203 | ASoC: qcom: q6apm: abort prepare when stopping the graph fails (RFC 2/4) | patchwork 1181907 | am3 | medium: prepare now fails instead of continuing; watch pipewire retries |
| 0204 | ASoC: qcom: q6apm: synchronize readiness query and provider lifetime (RFC 3/4) | patchwork 1181907 | am3 | medium: q6apm_is_adsp_ready() now needs state == 1 + a mutex; watch sound card probe at boot (could defer longer) |
| 0205 | ASoC: qcom: q6apm: recover PCM from failed data receipts (RFC 4/4) | patchwork 1181907 | am3 | medium: validates DSP tokens/addresses, stops the stream on failed receipts; F55 mic fresh-open test |
| 0206 | drm/msm/dpu: disable the slave encoder before the master | msm-next 32d04280ddeb | am3 | low-medium: dual-DSI disable order (suspend / blank / modeset) |
| 0207 | drm/msm/dpu: compute the CRTC bandwidth from the state being checked | msm-next 480ba24aa340 | am3 | low |
| 0208 | drm/msm/dsi: Fix VM leak in dsi_tx_buf_alloc_6g() | msm-next ab91ba61871a | am3 | low |
| 0209 | drm/msm/dpu: don't flush a legacy CTL after its interface has stopped (quad-pipe 1/5) | patchwork 1178674 | fix | low on DPU 13: merged with our CTL_START-only-for-writeback change; behaviour on kaanapali unchanged |
| 0210 | drm/msm/dpu: don't count the cloned writeback as an interface (2/5) | patchwork 1178674 | am3 | low-medium |
| 0211 | drm/msm/dpu: assign the mixers to the CTLs per interface (3/5) | patchwork 1178674 | am3 | medium (open series; DPU >= 5 uses one CTL) |
| 0212 | drm/msm/dpu: enable 3D merge when there are more mixers than interfaces (4/5) | patchwork 1178674 | am3 | **high**: topology change for the 3392x2400 dual-DSI DSC panel |
| 0213 | drm/msm/dpu: enable quad-pipe for DSC and dual-DSI case (5/5, Jun Nie v21 rebased) | patchwork 1178674 | am3 | **high**: 4 mixers / 4 pipes for our panel at 120/144 Hz; watch first frame, mode switch 60/120/144, underruns, `dpu` errors, suspend/resume of the display |
| 0214 | drm/panel: fix novatek-nt36536 dependencies | drm-misc-next f11277810402 | am3 | none (Kconfig select/depends; config unchanged) |
| 0215 | Bluetooth: Move H:4 reassembly into the Bluetooth core | bluetooth-next 11199d15cd9a | am3 | medium: hci_uart H:4 receive path code move (hci_qca uses it); BT pairing / audio test |
| 0216 | Bluetooth: hci_serdev: Fix use-after-free in hci_uart_unregister_device() | bluetooth-next 140202e22dee | am3 | low |
| 0217 | wifi: ath12k: clear dangling channel pointers on error paths | ath-next 507478f6f938 | am3 | low |
| 0218 | wifi: ath12k: fix DMA unwind for ext MSDU descriptor retry | ath-next 4de5a8a0eddd | am3 | low |
| 0219 | wifi: ath12k: fix stale skb pointers after aligned TX payload shift | ath-next 6c40719489c8 | am3 | low-medium (TX path) |
| 0220 | wifi: ath12k: fix truncated TX buffer DMA address in MSDU ext descriptor | ath-next 979ecb88ed35 | am3 | low-medium (TX path) |
| 0221 | wifi: ath12k: Free allocated CE IRQs on request_irq() failure | ath-next 12ca935af2e6 | am3 | low |
| 0222 | wifi: ath12k: Free allocated external IRQs on request_irq() failure | ath-next 9a78703ec4a8 | am3 | low |
| 0223 | wifi: ath12k: use per-device max QMI chunk size | ath-next 4e286c780d75 | am3 | medium: firmware memory segment layout at QMI; watch "qmi" errors / firmware boot |
| 0224 | wifi: ath12k: clear chunk paddr and size in ath12k_qmi_free_target_mem_chunk() | ath-next a1af8645cf2d | am3 | low |
| 0225 | wifi: ath12k: align QMI target memory to 64 KB | ath-next f7f05c443361 | am3 | medium (same as 0223) |
| 0226 | wifi: ath12k: read wiphy regd under RCU (wireless-next v3 18/19) | patchwork 14869758 (accepted) | am3 | low (taken alone; RCU read works with or without the cfg80211 part of the series) |
| 0227 | wifi: ath12k: Don't count a vdev restart as a start | infiniti fd4ee6f55976 | am3 | low-medium (channel switch / CSA) |
| 0228 | clk: qcom: gcc-kaanapali: Tie the CX power domain to controller | qcom clk-for-7.4 18c75784e4a9 | am3 | **medium**: GCC becomes a runtime-PM device in CX (use_rpm); GDSCs become CX subdomains. Watch boot (GCC probe), deep sleep / cxsd counters |
| 0229 | arm64: dts: qcom: kaanapali: Add GCC CX power domain | qcom arm64-for-7.4 9339897ad7ed | am3 | medium (pairs with 0228; the only DT change vs q88) |
| 0230 | clk: qcom: gcc-kaanapali: Enable FORCE_MEM_CORE_ON for UFS AXI PHY clock | patchwork 1180949 (reviewed) | fix | low (context only) |
| 0231 | thermal/drivers/qcom-spmi-temp-alarm: Fix temp_map indexing | patchwork 1175274 (in linux-pm next) | am3 | low-medium: the PMIC alarm thresholds can change (correct index); check the 7 temp-alarm zones' trip values, no limit is raised above stock by our DT |
| 0232 | soc: qcom: pmic_pdcharger_ulog: prevent work requeue during remove | qcom drivers-for-7.4 2354a6131c7d | am3 | low (no charging behaviour change) |
| 0233 | usb: typec: ucsi: retry init when the PPM answers early commands incorrectly | usb-next 254261381538 | am3 | low |
| 0234 | usb: typec: ucsi: allow retries of ucsi_resume_work | usb-next a2463e239443 | am3 | low |
| 0235 | PCI: qcom: Block accesses to downstream devices on link down | pci next 86624b718f94 | am3 | low-medium (Wi-Fi PCIe link-down handling) |
| 0236 | PCI: qcom: Skip system suspend/resume for firmware-managed PCIe | pci next 89d17a633108 | am3 | low (firmware-managed only; not our controller) |
| 0237 | cpuidle: menu: Do not return a disabled idle state | linux-pm d594187cafd5 | am3 | low |
| 0238 | cpuidle: teo: Do not return a disabled idle state | linux-pm 60d5fca628f9 | am3 | none (TEO not built; W=1 compile-checked) |
| 0239 | spi: qcom-geni: Add shutdown callback to quiesce hardware on reboot | spi for-next 3958b39fa5b7 | am3 | low (touch SPI at poweroff/reboot) |
| 0240 | dmaengine: qcom: gpi: Fix resource leaks as part of channel clean up | dmaengine next dd27c3f4d610 | am3 | low |
| 0241 | dmaengine: qcom: bam_dma: free interrupt before the clock in error path | dmaengine next 82eed160cfa7 | fix | low (kept IRQF_TRIGGER_HIGH; devm_request_irq -> request_irq) |
| 0242 | serial: qcom-geni: Fix port_ida handling for console and probe errors | linux-next 37d7703dbd6a | am3 | low-medium (console/UART line numbering; check ttyMSM names for BT + pogo UARTs) |
| 0243 | serial: qcom-geni: Avoid double-free of PM domain list | linux-next 4a86249c87ec | am3 | low |
| 0244 | drm/msm/a6xx: Add HFI support for CLX feature | msm-next 967e62fbeecc | am3 | medium (GMU HFI) |
| 0245 | drm/msm/a6xx: Enable CLX feature on A840 | msm-next 08d5049d9e84 | am3 | **medium**: GMU must accept the CLX tables; watch GPU init / "hfi" errors, GPU load test |
| 0246 | media: iris: reset AHB bridge before enabling HW mode | media next cc330f558996 | am3 | low-medium (video codec power-on) |
| 0247 | media: iris: Fix power-off ordering to disable power domain after clocks | media next 9cfae7726a9a | am3 | low-medium |
| 0248 | media: iris: take core lock when scanning the instance list | media next 428e6f95e685 | am3 | low |
| 0249 | media: iris: reject open() when the session limit is reached | media next 397ebadcbc21 | am3 | low |
| 0250 | media: iris: reference count video instances | media next af5f7df6c8b3 | am3 | low-medium |
| 0251 | net: qrtr: Send HELLO early when a packet waits for it | infiniti 839c154d7e75 | am3 | medium: QRTR to ADSP/CDSP (sensor hub, hexagonrpcd, pd-mapper); watch sensors / audio PD up |
| 0252 | dt-bindings: media: i2c: dw9800: Redocument DW9800K (v2 1/3) | patchwork.linuxtv 30346 (open) | am3 | none (binding text; dt-schema not run) |
| 0253 | media: i2c: dw9719: Update DW9800K driver (v2 2/3) | patchwork.linuxtv 30346 (open) | am3 | **medium**: DW9800K now detected by chip ID 0xEB, SAC mode 1 -> 3, new divider/SAC time registers; focus motor behaviour changes (rear camera focus test) |
| 0254 | ASoC: codecs: wcd939x: read the SoundWire port switches per channel | patchwork 1180866 (open) | am3 | medium: ADC/DMIC/HPH switch semantics per channel; UCM / alsactl restore state of mic switches |

## Not added

| Item | Reason |
|---|---|
| fastrpc 9e47ad9c5 "Allocate entire reserved memory for Audio PD in probe" | = 9981fbe599e8 (same patch-id); owner: NOT 9981fbe599e8. Prepared as an option only: `raw/opt-fastrpc-9e47ad9c5.patch`, applies clean on up3-q (branch up3-opt), fastrpc.o W=1 clean, not built into q89 |
| kaanapali.dtsi "Add memory-region for audio PD" (patchwork 1171074) | reconciled, not taken: it adds `adsp_rpc_remote_heap_mem` (reusable, 8 MiB) in the SoC dtsi - the same label our board DT already defines (26752e27e + 0194: no-map, 12 MiB, + memory-region/vmids on the ADSP fastrpc node); the reusable variant is the unsafe one with 9e47ad9c5 |
| already in v7.3-rc6 / base | DSI byte-clock rounding 202828068fcf; GMU FW init timeout ba970587a; hci_qca no write after close 4e93c65f8; UFS link startup mode a3756f53b + sequential read b2ededcb2; typec_switch_match dea99705b + duplicated mux d50b6442b; psci probe deferral 0606f2114; i2c-geni DMA release 268aacb2e; qrtr HELLO on register 544d85de4 (+ 6a5719cc3); console RX after deep idle 63ef71d14; ucsi glink UAF 63b269ec5; ucsi fwnode by reg 6c51f09c6 |
| already carried by our queue | eUSB2 repeater SMB power leakage fix (iceland, same subject); pmic_glink early rpmsg (our 0028) and worker-during-suspend (our 0152); sysmon skip state query (infiniti master's new version = same code as ours); ADC5 Gen4 PMK8850 1-5/7 (infiniti 0001-0138; 6-7/7 are MTP/QRD boards) |
| superseded | dpu "round up the compressed INTF width" 6b93e8b453 (our "Fix Compressed width calculation" 678ddbc95605 already uses a ceil); gcc-kaanapali runtime PM (infiniti afdaf8cb4dee: 18c75784e4 sets use_rpm); infiniti's own "Add the CX power domain to GCC" (upstream 9339897ad7 taken) |
| N/A | NT36536 double-remove 4085da1e6a (our driver version has no drm_panel_remove() on that path); PCIe WAKE# polarity ab288a0e4f (MTP dts only; our board already ACTIVE_LOW); dwc3 revert bb4f62bfa (the reverted commit is not in our tree) |
| infiniti 21 new commits, skipped | modem / IPA x8, NFC x2, IR LED (ir-spi), eSIM, OnePlus 15 DT x2 (hall/IR, drop cluster idle), imx709 (OP15 sensor) |
| skipped by order | LLCC / DDR / DDR_QOS DVFS RFC (memory DVFS = power; not trivially safe); BCL hwmon v4 (overlaps our 0075, not a clean replacement); TFA2 RFC (our TFA9865 driver works) |
| open, not in the order's list (left for a later round) | msm-next DP fixes (we carry infiniti's DP); Joonhoe Kim "stop all video interfaces before cleaning up a split encoder"; Mahadevan P mode-width / mixer clock limits; rpmh regulator debounce; arm_smccc_trng as SMCCC device; kaanapali I2C strong pull-up (pinctrl); adc5-gen3 __counted_by_ptr annotation; geni-se firmware-load fixes (FW loading not used here); QCE v-next (we carry the previous version) |
| MISSING (not obtainable) | none: every listed patch was found in a fetched tree, on patchwork (kernel.org / linuxtv REST, series mbox) or on GitHub |
