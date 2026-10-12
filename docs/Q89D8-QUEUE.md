# Kernel q89d8 - q89c-tb + 0266-0290 (12 Oct 2026)

Branch `iceland-7.3-rc6-q89d8`, tag `q89d8`. Built and tested as 7.3.0-rc6-iceland-00413-gfaa8eeee8c82 (config,
DTB and module set = q89d5; 0 build warnings). Status: **the kernel of the install candidate** (golden B143 =
q89d8 + iceland-device 0.28-2 + Fedora 44 stable, minimal holds). The final golden adds only the sound package
(iceland-device 0.28-3, pending); the kernel is not expected to change. Nothing is installed: the install image is
held until the owner runs the writes.

The branch carries the intermediate kernels as separate commits, in the order they were built and tested on the
tablet (`kernel.pin` names the tree after each stage; `scripts/prepare.sh` checks the last one):

| Stage | Patches | Kernel release | Tree after 0002 |
|---|---|---|---|
| q89d2 | 0266-0285 | 7.3.0-rc6-iceland-00408-gf15df25b7b16 | f0bdbecc04ed |
| q89d3 | 0286 | 7.3.0-rc6-iceland-00409-g9f9b14376d1a | fe91ba2d9aff |
| q89d5 | 0287-0288 | 7.3.0-rc6-iceland-00411-ge69f6f280d70 | f0749c7f6478 |
| q89d8 | 0289-0290 | 7.3.0-rc6-iceland-00413-gfaa8eeee8c82 | d5caed260f61 |

Not on this branch (test-only kernels): q89d4's DPU colour read-back / Night Light test switch (kit only, Night
Light dropped by the owner), and q89d6t / q89d7t (N1 SoundWire IRQ-before-clock-gating: FAIL, dropped; N2 hci_qca
IBS reset: never exercised, dropped). The amplifier change of q89d7t is carried here as 0290 (re-picked onto q89d5).

## The patches

| # | Subject | Author | Source / note |
|---|---|---|---|
| 0266 | firmware: arm_scmi: Add SCMI QCOM Generic Extension Protocol documentation | Pragnesh Papaniya |  |
| 0267 | dt-bindings: firmware: arm,scmi: Add Qualcomm Generic Extension Protocol | Pragnesh Papaniya |  |
| 0268 | firmware: arm_scmi: vendors: Add QCOM SCMI Generic Extensions | Sibi Sankar |  |
| 0269 | PM / devfreq: Add new target_freq attribute flag for governors | Sibi Sankar |  |
| 0270 | PM / devfreq: Add new track_remote flag for governors | Sibi Sankar |  |
| 0271 | PM / devfreq: Add a governor for tracking remote device frequencies | Sibi Sankar |  |
| 0272 | PM / devfreq: Introduce the QCOM SCMI Memlat devfreq driver | Sibi Sankar |  |
| 0273 | arm64: dts: qcom: kaanapali: Enable LLCC/DDR/DDR_QOS DVFS | Jia Yang |  |
| 0274 | clk: qcom: gcc-kaanapali: keep the USB GDSCs in retention | Joonhoe Kim | **no author Signed-off-by** |
| 0275 | usb: dwc3: tell xHCI that it lost its state when the core is powered off | Joonhoe Kim | **no author Signed-off-by** |
| 0276 | usb: dwc3: qcom: arm the eUSB2 line interrupts for wakeup | Joonhoe Kim | tb323fu-linux 0062; **no author Signed-off-by** |
| 0277 | cpuidle: psci-domain: add allow_cluster_off to refuse cluster idle states | Joonhoe Kim |  |
| 0278 | cpuidle: psci-domain: add allow_system_off to keep the system domain state for s2idle | mzak | https://github.com/joonhoekim/tb323fu-linux |
| 0279 | firmware: arm_scmi: quirk: skip P2A CHANNEL_FREE ack for Qualcomm CPUCP | Yibo Wang | **no author Signed-off-by** |
| 0280 | Input: oneplus-pogo-keyboard: tell the dock the host is awake on attach | mzak | https://github.com/SuperTurtleDev/iceland-mainline-kernel |
| 0281 | rtc: pm8xxx: use s64 offset for full Unix timestamp range | Yibo Wang | SuperTurtleDev iceland-mainline-kernel 1d9b86fe5c8d |
| 0282 | arm64: dts: qcom: kaanapali-oneplus-iceland: keep the RTC offset in SDAM2 | mzak | https://github.com/SuperTurtleDev/iceland-mainline-kernel |
| 0283 | firmware: arm_scmi: put the P2A CHANNEL_FREE quirk code in a QUIRK_ macro | mzak |  |
| 0284 | power: supply: qcom_battmgr: compute power_now on kaanapali | Yibo Wang | https://github.com/SuperTurtleDev/iceland-mainline-kernel; **no author Signed-off-by** |
| 0285 | drm/msm/dpu: do a full modeset when colour management changes the DSPP need | mzak | https://github.com/joonhoekim/tb323fu-linux |
| 0286 | power: supply: qcom_battmgr: OPLUS: list power_now | mzak |  |
| 0287 | usb: dwc3: qcom: drop the CPU latency request while no USB role is set | mzak |  |
| 0288 | usb: dwc3: qcom: drop the CPU latency request while no VBUS is present | mzak |  |
| 0289 | wifi: ath12k: set the regdomain before registering the wiphy | François Roux | https://lore.kernel.org/all/20261006161744.3804-1-franzelfranzel@gmail.com/ |
| 0290 | ASoC: codecs: tfa9865: OnePlus Pad 4: middle amplifiers' gain and boost from stock | mzak | re-picked from q89d7t 5a30d72164 |

## Authorship and sign-off

Every patch keeps its author. **0274, 0275, 0276 (Joonhoe Kim, tb323fu-linux) and 0279, 0284 (Yibo Wang,
SuperTurtleDev iceland-mainline-kernel) have no Signed-off-by of their author** in the source, only ours,
added when they were picked: for testing on this tablet only, not to be sent anywhere before their authors sign
them off. 0278, 0282 and 0285 are ours, based on work by those authors (noted in each message).

## Test status (RAM-boot rehearsals of the installed image; nothing written to the tablet)

- q89d2: kit 133, B run 134 (golden B134) + rehearsals r2z / r136: F54 40/40, Bluetooth, qrtr, UFS scaling PASS;
  the clock from RTC + SDAM2 offset across reboots (r136 K6) PASS; most kit-133 FAILs were test bugs; power_now
  missing (fixed by 0286).
- q89d3: kit 135: B2 wakes 9/9, C3 power_now = V x I, K1 memlat follows load, K4 SCMI quirk, C4, C6 PASS.
- q89d5: kits 136 / 137 (dwc3 latency request dropped with the cable out: unplug-qos / plug-qos PASS), B runs
  138 / 139 / 140, rehearsals r137, r138b, r138c.
- q89d8: B run 142 + r139a (N3 PASS; the Bluetooth adapter race found there is userspace, fixed in
  iceland-device 0.28-2), golden B143 + r139b, and **r139c: the first clean final rehearsal (36 rows, 0 FAIL,
  2 CHECK - test-tool SELinux denials and microphone clipping with the tablet upright - 28 PASS, 6 INFO)**.
  The amplifier rows confirm the middle amplifiers at stock (AK: every field at or below stock).
- Open, not kernel: the speaker loudness item (package 0.28-3, measurement deferred by the owner).
