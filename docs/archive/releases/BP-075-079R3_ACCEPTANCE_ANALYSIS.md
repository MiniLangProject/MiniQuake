# BP-075–BP-079R3 acceptance analysis

Windows acceptance status: **PASS**

The uploaded result archive completed all 19 required gates.

| Evidence | Result |
|---|---|
| Full build and cumulative unit suite | PASS |
| Installed `id1` validation | PASS |
| Headless runtime | PASS |
| Retail core-asset evidence A/B | byte-identical |
| Retail audio evidence A/B | byte-identical |
| Compatibility traces | 2 × 128 frames, byte-identical |
| Framebuffer evidence | byte-identical, SSIM 1.0 |
| Protocol-3 UDP handshakes | 2 independent pairs PASS |
| Winsock UDP loopback | PASS |

Reference values:

```text
Result archive SHA-256:
f86256028a30ed0740e2c80cf120eccec0977a841f3babdc297e25ca7d01d167

Trace SHA-256:
2b420f8b9713f09bc1edc632af7e2b18820629f428209775c85a29a4d7d6b293

Render TGA SHA-256:
734e965e17c9a20af7c42184d3d8a3d7f2997e1321342976799ec7f4670af945

Protocol-3 client report SHA-256:
50534266c750fa20058c82ce48baca953b0107106dc24fd69c5854fc3364ba96
```

The accepted parent contracts include `gameplay_presentation_109_frozen_v1`
with fingerprint `0xad91624c`.
