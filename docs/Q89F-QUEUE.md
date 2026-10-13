# Kernel q89f queue (0002-iceland 0293-0305)

q89f = q89e (7.3.0-rc7-iceland-00412-g4917dfb48aab) + the patches below, 7.3.0-rc7-iceland-00425-g8165b4e0b2d8.
Each one has a switch id in the build workflow's patch list (on / off); the idle refresh rate (RR3) is
compiled in but OFF by default (msm.dpu_idle_refresh_ms=0).

| Patch | Switch | Commit | File |
|---|---|---|---|
| 0293 | KBL | e2a2bc97b749 | 0293-backlight-ktz8869_iceland-add-a-thermal-brightness-l.patch |
| 0294 | KBF | bf114d88e2e2 | 0294-backlight-ktz8869_iceland-do-not-crash-when-the-seco.patch |
| 0295 | K3 | 1e9ba7b6a9b9 | 0295-block-restart-instead-of-failing-a-sysfs-store-on-a-.patch |
| 0296 | K7a | 3941dc32c441 | 0296-media-i2c-dw9719-reach-the-focus-position-on-resume.patch |
| 0297 | K7b | 237fd568d354 | 0297-dt-bindings-media-i2c-dongwoon-dw9800k-add-a-default.patch |
| 0298 | K7c | 9f9737616d84 | 0298-media-i2c-dw9719-hold-a-default-lens-position-while-.patch |
| 0299 | K7d | 90e1cf8579b5 | 0299-media-i2c-sc1320cs-power-the-lens-focus-actuator-whi.patch |
| 0300 | K7e | b49cca5cf8db | 0300-arm64-dts-qcom-kaanapali-oneplus-iceland-rear-lens-a.patch |
| 0301 | K6 | e83a1305c9e4 | 0301-arm64-dts-qcom-kaanapali-oneplus-iceland-Neither-USB.patch |
| 0302 | KD5y | 2a4423da58d7 | 0302-dt-bindings-net-wireless-qcom-ath12k-let-the-qcom-no.patch |
| 0303 | RR1 | e6e89f3e293c | 0303-drm-msm-dsi-change-the-vertical-total-of-a-running-v.patch |
| 0304 | RR2 | 988f0b5c1814 | 0304-drm-msm-dpu-change-the-vsync-period-of-a-running-vid.patch |
| 0305 | RR3 | 8165b4e0b2d8 | 0305-drm-msm-dpu-lower-the-refresh-rate-of-an-idle-video-.patch |
