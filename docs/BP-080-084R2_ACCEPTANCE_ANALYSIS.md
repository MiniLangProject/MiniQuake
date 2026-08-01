# BP-080–BP-084R2 acceptance analysis

Windows acceptance status: **PASS**.

The uploaded result archive completed every required gate and formally accepts
`black_port_source_109_frozen_v1`.

| Evidence | Result |
|---|---|
| Full build and cumulative unit suite | PASS |
| BP-080 cvar source surface | 20/20 PASS |
| BP-081 CD-audio source surface | 20/20 PASS |
| BP-082 function inventory | 20/20 PASS |
| BP-083 black-port corpus fixtures | 18/18 PASS |
| BP-084 source closure | 24/24 PASS |
| Source definitions classified | 1,094/1,094 |
| Installed `id1` validation | PASS |
| Headless runtime | PASS |
| Compatibility traces | 2 × 128 frames, byte-identical |
| Four-map corpus | 4 × 2 × 64 frames, pairwise byte-identical |
| Retail core-asset evidence | A/B byte-identical |
| Retail audio evidence | A/B byte-identical |
| Framebuffer evidence | byte-identical, SSIM 1.0 |
| Protocol-3 UDP handshakes | 2 independent pairs PASS |
| Winsock UDP loopback | PASS |

Reference values:

```text
Result archive SHA-256:
7d4969d9ed05877fbbcc7c071ea8d1d52f8d0892f3fa57a667df03d083503ef7

Compatibility trace SHA-256:
e91f4c9e32c8c9df39d7cb4ceaf83efaa78c51057516323da2ba6cc3412f0c7b

Source inventory SHA-256:
31f437bb54a84fa690ff96011c50f8ca3e7dfabde05b4f450e58049eae5d8837

Retail core-asset evidence:
06eac1012b97d36116a8f605cd428b09bf81f2881c474eda049c5e50183ec20e

Retail audio evidence:
896049a03f26b1db4ddc1550d35d1cacb5f7e0f0c900b0ee36393c8ab8bd0501

Render TGA:
734e965e17c9a20af7c42184d3d8a3d7f2997e1321342976799ec7f4670af945
```

Black-port corpus traces:

```text
start-064  5089aa78a03932134cd41704fa24624c3e4e892de253377c5bf57981d15f252a
e1m1-064   bf066d210480ec24ffa56c1a9347c6d161b4d7c483d717dc53882084d89ab797
e1m2-064   392e0522bf21bb8b61de0b6a2eebf1ec28fb21f4c26be7caa1b1f6cc82b1d389
e1m3-064   5e0fe8892c2b610b708e53255d9dbfb320962c33fdde7b1e33fae1977c05e5b7
```
