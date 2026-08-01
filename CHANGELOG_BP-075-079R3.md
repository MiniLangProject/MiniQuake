# MiniQuake BP-075–BP-079R3

## Fixed

- Updated the inherited BP-036 runtime fixture to match the source-correct C-runtime `atoi` behavior introduced by BP-076.
- `0x20` and `'A` now correctly produce zero in the downstream `V_cshift_f` regression test.
- Extended the shared BP-036 checker so downstream mode validates both the production parser and the inherited runtime expectations.
- Strict historical mode still requires the original BP-036 `Q_atoi` source and 32/65 fixture values.
- Added R3-specific live Windows runner, collector metadata, result analysis and delivery ledger.

## Unchanged

- No file under `src/` or `native/` changed.
- BP-036 remains 22 fixtures; BP-075–BP-079 remains 112 fixtures.
- `client_render_109_frozen_v1` remains `0x95e2b295`.
- `gameplay_presentation_109_frozen_v1` remains `0xad91624c`.
