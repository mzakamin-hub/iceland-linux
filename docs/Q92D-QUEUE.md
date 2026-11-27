# Queue q92d on Linux v7.4-rc4

Kernel `7.4.0-rc4-iceland-00827-g08a7adc3c104`: 827 patches on `v7.4-rc4` (`b6a9fa34ce41`), in 48 series.
`scripts/prepare.sh` applies them in order and checks the tree hash after each series (`kernel.pin`).

## The rebase from v7.4-rc1 to v7.4-rc4

Series 0001-0040 are q91n's series, regenerated from the replay of its 743 patches on the new base. The series
names and file names are kept, and the numbers are kept with gaps. 664 patches are kept and 79 are gone. A patch
is gone because:

- it was merged upstream by v7.4-rc4;
- it was replaced by the upstream version (the UFS MCQ abort path, the f_ncm NTB flush retry, the elevator sysfs
  store);
- or it cancels out with its revert.

Some conflicts were resolved by hand: hci_qca WCN7860, the MDSS splash handover, the camss C-PHY patches and the UFS
reap of aborted CQEs. That last one is now on top of the upstream abort path. Eight picks have their original
author again:

- Dmitry Baryshkov: `0002-iceland` 0209-0212;
- Jun Nie: 0213;
- Victor Fuentes: 0227 and 0251;
- Griffin Kroah-Hartman: 0252.

| Series | Patches on v7.4-rc1 | On v7.4-rc4 |
|---|---|---|
| `0001-infiniti` | 110 | 110 |
| `0002-iceland` | 299 | 293 |
| `0003-glitchfix` | 4 | 4 |
| `0004-q90b` | 22 | 22 |
| `0005-q90c` | 2 | 2 |
| `0006-q90d` | 2 | 2 |
| `0007-q90e` | 1 | 1 |
| `0008-q90f` | 2 | 2 |
| `0009-q90g` | 2 | 2 |
| `0010-q90h` | 1 | 1 |
| `0011-q90i` | 1 | 1 |
| `0012-q90k` | 17 | 17 |
| `0013-q90l` | 1 | 1 |
| `0014-q90m` | 10 | 10 |
| `0015-q90n` | 12 | 8 |
| `0016-q90o` | 4 | 1 |
| `0017-q90p` | 4 | 4 |
| `0018-q90q` | 10 | 9 |
| `0019-q90r` | 13 | 9 |
| `0020-q90s` | 6 | 6 |
| `0021-q90t` | 11 | 7 |
| `0022-q90u` | 2 | 2 |
| `0023-q90v` | 1 | 1 |
| `0024-q90w2` | 5 | 5 |
| `0025-q90x` | 1 | 1 |
| `0026-q90y` | 6 | 6 |
| `0027-q90z` | 11 | 9 |
| `0028-q91` | 32 | 27 |
| `0029-q91b` | 24 | 21 |
| `0030-q91c` | 2 | 1 |
| `0031-q91d` | 27 | 18 |
| `0032-q91e` | 8 | 8 |
| `0033-q91f` | 9 | 9 |
| `0034-q91g` | 3 | 3 |
| `0035-q91h` | 1 | 1 |
| `0036-q91i` | 5 | 5 |
| `0037-q91j` | 30 | 18 |
| `0038-q91k` | 3 | 3 |
| `0039-q91m-pd` | 1 | 1 |
| `0040-q91n` | 38 | 13 |
| `0041-q91o` | new | 117 |
| `0042-q91o-plus` | new | 13 |
| `0043-q91o-plus2` | new | 21 |
| `0044-q91o-plus3` | new | 1 |
| `0045-q92a` | new | 5 |
| `0046-q92b` | new | 1 |
| `0047-q92c` | new | 1 |
| `0048-q92d` | new | 4 |

The removed files (paths on branch `iceland-7.4-rc1`):

- `0002-iceland/0064-usb-dwc3-qcom-request-the-CPU-wakeup-latency-only-wh.patch`
- `0002-iceland/0065-Revert-usb-dwc3-qcom-request-the-CPU-wakeup-latency-.patch`
- `0002-iceland/0162-usb-gadget-f_ncm-retry-the-NTB-flush-while-every-IN-.patch`
- `0002-iceland/0295-block-restart-instead-of-failing-a-sysfs-store-on-a-.patch`
- `0002-iceland/0316-wifi-ath12k-fix-decap-of-MSDUs-spanning-multiple-RX-.patch`
- `0002-iceland/0342-usb-typec-ucsi-Set-ucsi-connector-before-enabling-no.patch`
- `0015-q90n/0002-scsi-ufs-qcom-Reprogram-ESI-after-a-host-controller-.patch`
- `0015-q90n/0009-FROMLIST-hwmon-Add-Qualcomm-PMIC-BCL-driver.patch`
- `0015-q90n/0010-FROMLIST-arm64-dts-qcom-pmih0108-kaanapali-Enable-BC.patch`
- `0015-q90n/0011-hwmon-qcom-bcl-hwmon-probe-only-with-enable-1-defaul.patch`
- `0016-q90o/0001-Revert-hwmon-qcom-bcl-hwmon-probe-only-with-enable-1.patch`
- `0016-q90o/0002-Revert-FROMLIST-arm64-dts-qcom-pmih0108-kaanapali-En.patch`
- `0016-q90o/0003-Revert-FROMLIST-hwmon-Add-Qualcomm-PMIC-BCL-driver.patch`
- `0018-q90q/0011-FROMLIST-ASoC-qcom-q6apm-Guard-callbacks-until-probe.patch`
- `0019-q90r/0007-net-qrtr-announce-local-services-again-once-our-HELL.patch`
- `0019-q90r/0009-wifi-mac80211-reinstate-IEEE80211_TX_CTL_AMPDU-flag-.patch`
- `0019-q90r/0010-Revert-phy-qcom-qmp-combo-Leave-the-USB-PCS-alone-in.patch`
- `0019-q90r/0011-phy-qcom-qmp-combo-Leave-the-USB-PCS-alone-in-DP-onl.patch`
- `0021-q90t/0001-scsi-ufs-core-Restore-jiffies-conversion-of-device-m.patch`
- `0021-q90t/0002-scsi-ufs-core-Introduce-ufshcd_rpm_resume_and_get-he.patch`
- `0021-q90t/0003-scsi-ufs-sysfs-Propagate-runtime-PM-resume-errors.patch`
- `0021-q90t/0004-scsi-ufs-hwmon-debugfs-Propagate-runtime-PM-resume-e.patch`
- `0027-q90z/0006-Revert-net-qrtr-announce-local-services-again-once-o.patch`
- `0027-q90z/0007-net-qrtr-announce-local-services-again-once-our-HELL.patch`
- `0028-q91/0007-PM-EM-Rank-boost-and-non-boost-frequencies-separatel.patch`
- `0028-q91/0016-ASoC-codecs-lpass-rx-macro-fix-PM-ref-leak-in-swclk_.patch`
- `0028-q91/0018-Bluetooth-hci_sync-Update-the-CIS-host-feature-when-.patch`
- `0028-q91/0019-Bluetooth-hci_core-Fix-queuing-rx_work-while-workque.patch`
- `0028-q91/0022-ufs-mcq-fix-dev-cmd-abort-path-and-add-OCS-poll-afte.patch`
- `0029-q91b/0001-Bluetooth-L2CAP-Hold-incoming-data-until-encryption-.patch`
- `0029-q91b/0004-wifi-ath12k-don-t-advertise-EHT-MCS15-to-firmware-un.patch`
- `0029-q91b/0010-arm64-dts-qcom-kaanapali-oneplus-iceland-link-the-re.patch`
- `0030-q91c/0001-Revert-arm64-dts-qcom-kaanapali-oneplus-iceland-link.patch`
- `0031-q91d/0001-cpufreq-Hold-the-policy-write-lock-when-changing-boo.patch`
- `0031-q91d/0002-cpufreq-Preserve-global-boost-state-on-failed-update.patch`
- `0031-q91d/0003-cpufreq-Serialize-global-boost-updates.patch`
- `0031-q91d/0011-arm64-suspend-Save-and-restore-TPIDR2_EL0-across-CPU.patch`
- `0031-q91d/0015-scsi-ufs-bsg-Abort-ufs_bsg_request-when-runtime-resu.patch`
- `0031-q91d/0016-scsi-ufs-core-Keep-clock-gating-hold-on-failed-W-LUN.patch`
- `0031-q91d/0017-scsi-ufs-core-Change-the-error-check-sequence-for-au.patch`
- `0031-q91d/0020-wifi-ath12k-set-MSDU-payload-correctly.patch`
- `0031-q91d/0021-Revert-PM-EM-Rank-boost-and-non-boost-frequencies-se.patch`
- `0037-q91j/0002-power-sequencing-qcom-wcn-increase-WCN7850-power-up-.patch`
- `0037-q91j/0006-wifi-ath12k-Fix-failure-to-create-ath12k_dp_peer-on-.patch`
- `0037-q91j/0016-usb-typec-ucsi-retry-init-only-while-the-PPM-is-not-.patch`
- `0037-q91j/0018-iio-adc-qcom-spmi-adc5-gen3-Reuse-IIO-device-ID-for-.patch`
- `0037-q91j/0020-Bluetooth-hci_qca-fix-use-after-free-in-ibs-debugfs-.patch`
- `0037-q91j/0022-usb-dwc3-gadget-Reject-requests-to-a-disabled-endpoi.patch`
- `0037-q91j/0023-usb-dwc3-gadget-Track-a-timed-out-End-Transfer.patch`
- `0037-q91j/0024-usb-dwc3-gadget-Clear-delayed-stop-on-End-Transfer-c.patch`
- `0037-q91j/0025-usb-dwc3-gadget-Issue-no-op-Start-Transfer-only-for-.patch`
- `0037-q91j/0026-usb-dwc3-gadget-Wait-for-End-Transfer-completion-on-.patch`
- `0037-q91j/0027-usb-dwc3-gadget-Reset-endpoint-flags-on-controller-s.patch`
- `0037-q91j/0028-usb-dwc3-gadget-Recover-from-End-Transfer-timeout.patch`
- `0040-q91n/0001-wifi-cfg80211-fix-out-of-bounds-read-in-valid_rule.patch`
- `0040-q91n/0002-ipv6-raw-fix-use-after-free-in-rawv6_send_hdrinc.patch`
- `0040-q91n/0003-ipv6-fix-fib6-walker-UAF-on-NLM_F_REPLACE.patch`
- `0040-q91n/0004-mm-shmem-fix-truncate-loop-after-boundary-swapin-fai.patch`
- `0040-q91n/0005-mm-huge_memory-fix-list-corruption-when-deferred_spl.patch`
- `0040-q91n/0006-Bluetooth-validate-retained-LE-Create-CIS-command-le.patch`
- `0040-q91n/0007-Bluetooth-validate-retained-LE-Set-CIG-Parameters-co.patch`
- `0040-q91n/0008-mm-memcontrol-fix-NULL-pointer-deref-and-UAF-from-hi.patch`
- `0040-q91n/0009-net-restore-refcount-ordering-for-lockless-socket-ac.patch`
- `0040-q91n/0010-mm-khugepaged-fix-PMD-table-lock-leak-in-try_collaps.patch`
- `0040-q91n/0011-mm-gup-fix-out-of-bounds-write-for-nr_pages-0-in-GUP.patch`
- `0040-q91n/0012-mm-gup-check-for-overflow-when-converting-nr_pages-t.patch`
- `0040-q91n/0013-mm-vma-don-t-leak-the-charge-for-stack-growth.patch`
- `0040-q91n/0014-crypto-essiv-fix-use-after-free-in-AEAD-path.patch`
- `0040-q91n/0015-netfilter-nf_conntrack_sip-fix-OOB-read-in-ct_sip_pa.patch`
- `0040-q91n/0016-tcp-ipv6-free-ireq-ipv6_opt-after-an-RCU-grace-perio.patch`
- `0040-q91n/0017-smb-client-fix-OOB-write-when-compounding-SMB2_IOCTL.patch`
- `0040-q91n/0018-smb-client-validate-descriptor-headers-before-query-.patch`
- `0040-q91n/0019-btrfs-fix-bio-counter-and-bioc-leak-when-async-check.patch`
- `0040-q91n/0020-tcp-free-saved_syn-after-an-RCU-grace-period.patch`
- `0040-q91n/0021-wifi-mac80211-fix-use-after-free-when-MLO-link-setup.patch`
- `0040-q91n/0022-wifi-mac80211-fix-use-after-free-on-TTLM-disconnect.patch`
- `0040-q91n/0023-ipv4-fib_trie-prevent-speculative-out-of-bounds-chil.patch`
- `0040-q91n/0024-net-dst_metadata-fix-memcmp-overread-in-skb_metadata.patch`
- `0040-q91n/0025-tcp-fix-request_sock-use-after-free-during-Fast-Open.patch`

## The series after q91n

The new series are 0041 to 0048: `0041-q91o` (117), `0042-q91o-plus` (13), `0043-q91o-plus2` (21),
`0044-q91o-plus3` (1), `0045-q92a` (5), `0046-q92b` (1), `0047-q92c` (1) and `0048-q92d` (4). What each one
contains is in `kernel.pin` and in the commit that adds it.

`0042-q91o-plus` imports dappermint's `iceland-supervooc` driver unchanged, with his author identity and
dates, from [dappermint/iceland-supervooc](https://github.com/dappermint/iceland-supervooc) `614469fabe59`. It
goes into `drivers/power/supply/iceland-supervooc/`. Our commits on top of it:

- the module never loads by itself;
- the automatic session ends at 85 %;
- there is no CPU latency request during a session;
- every start is gated on the battery authentication;
- the 7.3 A ceiling is asserted at build time;
- a `CREDITS` file.

His thermal guards are unchanged. The charge pump buses stay disabled in the default device tree: his DT patch is
`optional/pumpbus/`.

## Config

`scripts/build.sh` adds `configs/q92d.config` (`CONFIG_ICELAND_SUPERVOOC=m`). On v7.4-rc4, two new upstream
symbols are on by default: `ARM64_ERRATUM_2738461` and `ARM64_WORKAROUND_BROKEN_AMU_CORECNT`. The result is the
released package's config, `packaging/arch/linux-iceland/config-q92d`, apart from the toolchain version lines.
