# MiniQuake BP-075–BP-079R2

## Fixed

- The inherited BP-036 view-state checker now distinguishes its historical `common.atoi` source marker from the source-correct downstream `common.cAtoi` implementation introduced by BP-076.
- The strict historical BP-036 mode remains unchanged and intentionally rejects the current downstream source tree.
- `build.ps1` invokes BP-036 with `--allow-downstream-package`; all other BP-035..BP-039 checkers remain in strict mode.
- Added revision-specific Windows runner, collector metadata, result analysis and block ledger.

## Unchanged

- No file under `src/` or `native/` changed from BP-075–BP-079R1.
- All 112 BP-075..BP-079 runtime fixtures are unchanged.
- `client_render_109_frozen_v1` remains `0x95e2b295`.
- `gameplay_presentation_109_frozen_v1` remains `0xad91624c`.
