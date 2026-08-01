# BP-085–BP-089R3 Windows result analysis

Result archive:

```text
MiniQuake_BP-085-089R3_RESULTS_20260731-231328.zip
SHA-256: 9713654070c733ff44f56fe98bee6e860e2717e162d2b706daed102316598703
```

## First failure

The current BP-089 package verifier and the inherited BP-022 downstream audit
both passed. The run stopped before MiniLang compilation at the inherited
BP-031 command/cvar source checker:

```text
MiniQuake BP-031 command/cvar verification: FAIL
ERROR: missing cvar marker: negative = (raw & 0x80000000) != 0
```

## Cause

BP-085–BP-089R2 moved six-decimal Binary32 formatting from the historical
MiniLang i32-scaled implementation to the caller-owned native text bridge:

```text
native.fixedSixText
mqt_f32_to_fixed6
MSVCRT sprintf("%.6f")
```

The inherited BP-031 checker still required the implementation detail of the
old formatter. That marker is correctly absent from the accepted current cvar
path. Runtime fixtures, golden values, cvar semantics and the release matrix
were not reached by this Windows run.

## R4 correction

The BP-031 checker now has two explicit modes:

- strict historical mode requires the original raw-word/i32-scaled source;
- downstream mode requires the accepted native MSVCRT formatter, its export,
  caller-owned buffer boundary and the absence of the overflow-prone code.

`build.ps1` selects downstream mode for BP-089. The package verifier executes
both modes and requires current strict-mode rejection plus downstream-mode
success.

No file below `src/` or `native/` is changed by R4.
