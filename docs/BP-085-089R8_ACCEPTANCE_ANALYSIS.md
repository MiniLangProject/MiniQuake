# MiniQuake BP-085–BP-089R8 – Windows acceptance analysis

## Result

The Windows acceptance run completed successfully. The summary reports `status=PASS` and all required gates passed.

## Confirmed gates

- Complete cumulative build and unit/regression suite: PASS
- Installed Quake data validation for `id1`: PASS
- Runtime validation for `id1`: PASS
- Mission packs `rogue` and `hipnotic`: validation and runtime PASS
- Retail core-asset evidence: two independent runs byte-identical
- Retail audio evidence: two independent runs byte-identical
- Retail demos `demo1.dem`, `demo2.dem`, `demo3.dem`: parsed and replayed successfully
- Quake-v5 savegame roundtrip: first pass exact and semantic; stable pass exact and semantic
- Main compatibility traces: two independent 128-frame runs byte-identical
- Black-port corpus: `start`, `e1m1`, `e1m2`, `e1m3`, each two independent 64-frame runs byte-identical
- Host soak: 5,000 frames PASS
- Listen-server resource soak: 5,000 frames PASS
- Visible render evidence: two independent 640×480 captures byte-identical, SSIM 1.0
- Two independent Protocol-3 UDP control handshakes: PASS
- Winsock UDP loopback smoke: PASS

## Key reference values

- Result archive SHA-256: `f15f674ade75d82ef2221390f2d1180292b263e3d0dd8c9d1afc1d56a5c7dab6`
- Main compatibility trace SHA-256: `b6e1d92f614cae73e43782dcb94a0233769a6e5dc70dad9f7c1da636d391219c`
- Main rolling hash: `d905b042`
- Retail core-asset evidence SHA-256: `06eac1012b97d36116a8f605cd428b09bf81f2881c474eda049c5e50183ec20e`
- Retail audio evidence SHA-256: `896049a03f26b1db4ddc1550d35d1cacb5f7e0f0c900b0ee36393c8ab8bd0501`
- Retail demo/save evidence SHA-256: `982084a99e7dd6e889ef0fdbdd5f084b263fc2884946c100b0c67b4639f45e60`
- Visible render TGA SHA-256: `734e965e17c9a20af7c42184d3d8a3d7f2997e1321342976799ec7f4670af945`
- Protocol-3 normalized client report SHA-256: `50534266c750fa20058c82ce48baca953b0107106dc24fd69c5854fc3364ba96`

## Stability measurements

### Host soak

- Frames: 5,000
- Live heap blocks: 114,251 → 114,276
- Heap high-water bytes: unchanged at 118,608,232
- Result: PASS

### Listen-server soak

- Frames: 5,000
- Heap live blocks: 113,918 → 113,927
- Heap live bytes: 115,647,896 → 115,648,672
- Server edicts: 67 → 67
- Client entity slots: 66 → 67, within calculated high-water limit 67
- Active clients: 1 → 1
- Active QSockets: 2 → 2
- UDP endpoints: 1 → 1
- Process handles: 279 → 279
- All stability gates: true
- Result: PASS

## Contract status

The following cumulative candidate is now Windows-confirmed:

- `compat_109_release_candidate_v1`
- Fingerprint `0x29b72a98`

The only explicitly open external gates after this acceptance are:

1. direct interoperability with the original GLQuake executable in both client/server directions;
2. image comparison against an independently executed original GLQuake reference capture with SSIM at least 0.95.
