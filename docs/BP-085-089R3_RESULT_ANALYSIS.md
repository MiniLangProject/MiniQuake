# MiniQuake BP-085–BP-089R3 result analysis

## Observed Windows result

The BP-085–BP-089R2 delivery stopped during the inherited BP-022 QuakeC
edict preflight, before the MiniLang build started.

```text
MiniQuake BP-022 QuakeC edict verification: FAIL
ERROR: missing edict marker: negative = (rawWord & 0x80000000) != 0
```

Result archive SHA-256:

```text
f39e82b46494d815fe4fbafc361ddd4cf6d8d305222f9c9b29b64b0ccf4958f6
```

## Root cause

BP-085–BP-089R2 intentionally replaced the historical integer-scaled
six-decimal formatter with the MSVCRT-compatible caller-owned text-bridge
path:

```text
mqt_f32_to_fixed6
sprintf("%.6f", (double)binary32_value)
```

The inherited BP-022 checker still required an implementation detail from the
older raw-word formatter:

```ml
negative = (rawWord & 0x80000000) != 0
```

That marker disappeared because the native formatter now owns sign handling,
negative zero, rounding and large-value formatting. The QuakeC runtime fixture,
golden rows and savegame evidence remain unchanged; only the historical source
marker became obsolete in a downstream package.

## R3 correction

`tools/check_quakec_edict.py` now has two explicit modes:

- historical mode retains the original BP-022 raw-word source contract;
- `--allow-downstream-package` validates the accepted native
  `MSVCRT %.6f` path and rejects the overflow-prone integer-scaled formatter.

`build.ps1` uses the downstream mode for BP-089. The package verifier confirms
that downstream mode passes while historical mode still rejects the current
source tree, so the old BP-022 audit has not been silently weakened.

No file under `src/` or `native/` is changed by R3.
