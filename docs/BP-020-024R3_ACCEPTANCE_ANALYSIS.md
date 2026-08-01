# BP-020–BP-024R3 Windows acceptance

## Result

The uploaded Windows result archive `MiniQuake_BP-020-024R3_RESULTS_20260725-233340.zip`
completed the cumulative QuakeC block without a failing gate.

| Gate | Result |
|---|---:|
| Static package and ABI verification | PASS |
| Single cumulative Windows build | PASS |
| Base core and milestone suites | PASS |
| Protocol 15 BP-010R1 through BP-019 | PASS |
| BP-020 progs.dat fixtures | 18/18 PASS |
| BP-021 VM fixtures | 16/16 PASS |
| BP-022 edict/save-text fixtures | 22/22 PASS |
| BP-023 builtin fixtures | 22/22 PASS |
| BP-024 closure fixtures | 20/20 PASS |
| Stock id1/progs.dat gate | PASS |
| Installed Quake data validation | PASS |
| Headless runtime | 300 frames PASS |
| Deterministic traces | 128/128 frames in two independent processes |
| Trace comparison | byte-identical PASS |
| UDP loopback | PASS |

## Accepted deterministic reference

```text
Trace SHA-256: 28fb377c9d694ed7ac14dac1d7110fa6fcb6cdcd2ffdf8a3c7cdbad3ffefe5cd
Rolling hash:  58a7d245
```

The uploaded result archive has this SHA-256 digest:

```text
d9fa5aa62854a8c9b5175c2d8aa789e49516c530ded3294b5f7a5515467e820f
```

## Consequence

`quakec_109_frozen_v1` is accepted as the parent contract for BP-025–BP-029.
The R3 exact-size Quake-byte serializer is confirmed under the native Windows
MiniLang runtime, with real `id1/progs.dat`, full startup and deterministic
runtime traces.
