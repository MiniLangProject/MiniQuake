# MiniQuake BP-040–BP-044R2

Delivery-only compiler hotfix for the BP-040–BP-044 world-render block.

## Windows result addressed

The R1 game executable and 38 inherited test programs compiled successfully.
Compilation stopped at the BP-041 lightmap-atlas entry with:

```text
CompileError: Function standard expects 0 args, got 2
src/miniquake/filesystem.ml:70
```

The package-free test helper `standard()` shadowed the two-argument internal
`miniquake.filesystem.standard(baseDirectory, gameName)` within the merged
MiniLang import closure.

## Changes

- `tests/lightmap_atlas_tests.ml`
  - rename `standard()` to `standardFixture()`;
  - update all BP-041 fixture call sites.
- `tests/sky_water_render_tests.ml`
  - proactively rename the test helper `bits()` to `fixtureFloatBits()`;
  - avoid shadowing `miniquake.render.gl11.bits()` in future closure growth.
- `tools/verify.py`
  - add the `minilang_entry_function_shadow_arity` graph check;
  - bind the R1 result archive and exact compiler diagnostic;
  - require the two collision-free fixture helper names.
- Add `TEST_BP-040-044R2.ps1`, R2 collector identity, result analysis, testing
  guide, block ledger and logical hotfix patch.

## Compatibility impact

No production source or native bridge file changed. The following remain
identical to R1:

```text
protocol15_frozen_v1
quakec_109_frozen_v1
world_physics_109_frozen_v1
host_lifecycle_109_frozen_v1
client_render_109_frozen_v1
world_render_109_frozen_v1
world_render_fingerprint=0x846a74de
```

Runtime fixture counts remain BP-040=20, BP-041=22, BP-042=20, BP-043=22 and
BP-044=24.
