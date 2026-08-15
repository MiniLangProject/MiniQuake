# MiniQuake OPT-001CR2

Parent: `OPT-001CR1`

## Changes

- Fixes the revision-prefix mismatch in both optimization analyzers.  The
  aggregate analyzer and the OPT-001C performance comparator now accept an
  explicit `--prefix` instead of assuming `opt001a-*` or `opt001c-*` names.
- Runs one additional handle confirmation window by default.  A late, one-time
  process-handle initialization can therefore be distinguished from continued
  growth without weakening the leak criteria.
- Preserves the accepted OPT-001C engine and renderer sources byte-for-byte.
- Records requested, confirmation and effective handle-window counts in the
  test summary.

## R1 evidence

All build, correctness, map, render, trace and long-run gates passed in the
OPT-001CR1 Windows run.  Its final failure was produced only by the two
hard-coded analyzer prefixes.  Reconstructing the comparison from the emitted
JSON reports shows that the OPT-001C performance target was met.

## Delivery hotfix 2026-08-08: live nested-build output

The OPT-001CR2 runner now starts `build.ps1` in an attached child PowerShell. The child owns the `Tee-Object` pipeline, so Windows PowerShell 5.1 shows every build/compiler line immediately while still writing `build\opt001cr2-build.log`. Engine and native code are unchanged.
