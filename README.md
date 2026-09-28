# iceland-linux

Mainline Linux for the OnePlus Pad 4 (`iceland`, Qualcomm SM8850P "kaanapali"), kept as a patch queue on an
upstream tag (same approach as pmOS kernel packages and other tablet ports) so every commit keeps its original author.

| Path | Content |
|---|---|
| `kernel.pin` | upstream tag/commit + expected tree hashes |
| `patches/0001-map220v/` | map220v/sm8850-mainline `iceland-7.2` (40 commits, 12 authors) — reproduces map220v's tree bit-for-bit |
| `patches/00NN-*/` | further series, applied in directory order |
| `scripts/prepare.sh` | clone upstream tag, `git am` all series, verify tree hashes |

```
scripts/prepare.sh ./src
```

Licence: GPL-2.0 (Linux `COPYING`; every patch keeps its authorship and SPDX headers).
Proprietary firmware is never stored here.
