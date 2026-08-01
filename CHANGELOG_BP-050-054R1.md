# BP-050–BP-054R1 changelog

This delivery-only hotfix corrects the final BP-054 closure test adapter.

## Fixed

- `tests/render_special_closure_tests.ml` now passes a real
  `miniquake.types.CommandLine` value to `host.createCvars`.
- The fixture uses `miniquake.common.create([])` rather than a plain string.
- `tools/check_render_special_054.py` rejects the former invalid call during
  static verification.
- Added an R1 acceptance script, result collector identity, analysis,
  hotfix report, ledger, and reproducible patch metadata.

## Unchanged

- No production source under `src/` changed.
- No native source or DLL changed.
- All 104 BP-050–BP-054 fixtures remain present.
- `render_special_109_frozen_v1` and fingerprint `0x2a3d8081` are unchanged.
- All previously frozen Protocol 15, QuakeC, physics, lifecycle, client/render,
  world/render, and model/UI/render contracts are unchanged.
