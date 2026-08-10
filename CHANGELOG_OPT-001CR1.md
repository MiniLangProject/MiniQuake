# MiniQuake OPT-001CR1

Parent delivery: `OPT-001C`

## Fixed

- Repaired the malformed guarded lightmap-upload trace expression that caused
  `world.ml` to fail with `Expected RBRACK, got RPAREN` before `MiniQuake.exe`
  could compile.
- Moved each trace-only lightmap-row hash into a named local before building the
  trace argument array.
- Added a lexical MiniLang delimiter checker for all project `.ml` files.
- Added an OPT-001CR1 source contract that rejects the exact malformed
  `rectangle[3)` regression.
- Added unique R1 test, log, summary and result-archive names.

## Unchanged

- The OPT-001C allocation optimization contract and fingerprint.
- The OPT-001B correctness fixes and all e1m2/transition/handle gates.
- Native bridges and Quake game-data policy.
- Performance targets and accepted OPT-001B baseline.
