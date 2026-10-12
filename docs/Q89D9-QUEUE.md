# Kernel q89d9 - q89d8 + 0291 (12 Oct 2026)

Branch `iceland-7.3-rc6-q89d9`, tag `q89d9`. Built and tested as 7.3.0-rc6-iceland-00414-g9e7350a6ab86 (config, DTB
and module set = q89d8; 0 build warnings). Status: **the kernel of the final install image** (golden B145 = q89d9 +
iceland-device 0.28-3 + iceland-firmware 11.A.38-2 + Fedora 44 stable, minimal holds). Nothing is installed: the
install image is held until the owner runs the writes.

| Stage | Patches | Kernel release | Tree after 0002 |
|---|---|---|---|
| q89d8 | 0266-0290 | 7.3.0-rc6-iceland-00413-gfaa8eeee8c82 | d5caed260f61 |
| q89d9 | 0291 | 7.3.0-rc6-iceland-00414-g9e7350a6ab86 | b6e37a4f5805 |

## The patch

| # | Subject | Author | Note |
|---|---|---|---|
| 0291 | Bluetooth: hci_qca: Discard the RX burst of the WCN7860 baudrate change | mzak | ours; Signed-off-by present |

Every WCN7860 setup logged "Frame reassembly failed (-84)" right after the speed change (the controller's held-back
bytes when RTS comes back). 0291 drops what qca_recv() gets during the WCN7860 speed change (+ 20 ms); other SoCs are
not affected. The setup itself always completed: the change removes an error-level line on every power-on.

## Test status (RAM-boot rehearsals of the installed image; nothing written to the tablet)

- r146 / r146b (12 Oct): q89d9 installed through its kernel-iceland rpm in the overlay (the kernel-update path: new
  boot entry + initramfs with the iceland dracut module), boot 2 on q89d9: BT84 PASS (5 setups incl. 3 power cycles,
  0 lines with -84, adapter powered, scan finds devices), 17/17 PASS.
- Golden B145 (B run 33/0) and the final rehearsal r141 / r141u / r141ub on it: NO-REGRESSION vs r139c / r140 over
  36 rows; BT84 and BTd PASS; rollback boot 7/7 PASS.
