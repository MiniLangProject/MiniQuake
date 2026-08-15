# BP-070–BP-074R1 Windows result analysis

The R1 package passed its static preflight and compiled the game plus all inherited test targets through the accepted frontend block. The build stopped at the first new BP-070 executable.

```text
CompileError: Undefined variable 'bio'
  at tests/common_asset_parity_tests.ml:49:14
    bp070Equal(bio.ShortSwap(0x1234), 0x3412, "ShortSwap")
```

## Failure boundary

- expected MiniLang targets: 76
- successfully compiled targets before the failure: 70
- failed target: `MiniQuakeCommonCoreTests.exe`
- BP-071 through BP-074 executables were not reached
- no installed-game, retail-asset, runtime, trace, render, audio or network evidence was executed

The result archive is:

```text
MiniQuake_BP-070-074R1_RESULTS_20260729-192646.zip
SHA-256: 02cb2d978b35076623432cf46a8c56e9907e1430875b07b6ee401eb43387a1c9
```

## Root cause

The fixture imported:

```ml
import miniquake.byteio as bio
```

but attempted to call these nonexistent, case-sensitive package members:

```text
bio.ShortSwap
bio.LongSwap
bio.ShortNoSwap
bio.LongNoSwap
bio.FloatNoSwap
```

`miniquake.byteio` exposes lower-case implementation helpers. The public C-style `common.c` entrypoints live in `miniquake.common` and are named exactly `ShortSwap`, `LongSwap`, `ShortNoSwap`, `LongNoSwap`, `FloatSwap` and `FloatNoSwap`.

## R2 correction

The BP-070 fixture now tests the intended public API through `common.*`.

A follow-up source audit also found that `LongNoSwap` and `FloatNoSwap` did not yet model their C parameter/return boundaries when called from dynamically typed MiniLang:

- `LongNoSwap(int)` must return a signed 32-bit value.
- `FloatNoSwap(float)` must round at the Binary32 call and return boundary.

R2 therefore uses the existing `quakeInt32` and `quakeFloat` helpers in those two entrypoints. This is a direct source-guided parity correction; it does not change the block fingerprint or fixture count.
