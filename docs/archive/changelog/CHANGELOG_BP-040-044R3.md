# MiniQuake BP-040–BP-044R3

Test-integrity hotfix for the BP-040–BP-044 world-render block.

## Windows result addressed

R2 compiled all 43 targets and reported 84/84 script steps as `PASS`, but the
supplied Quake base directory did not exist, so installed-game and runtime
acceptance were not reached. A retrospective scan of the collected UTF-16 test
logs found five test programs that printed failures while returning process exit
code 0.

## Corrected fixtures

- BP-013 event fixtures now pass `count` before `color` to the MiniLang
  `writeParticle` API.
- BP-014R1 beam fixture now expects the first expired slot to be reused and
  verifies the replacement entity payload.
- BP-015 signon fixture stores the client baseline in its canonical seven-value
  array and keeps the server `EntityBaseline` struct separate.
- BP-018 demo fixture uses two leading spaces for the bound GLQuake bytewise
  result `-1758`; the C oracle and golden document were updated accordingly.
- BP-043 no-split fixture uses a 16..48 polygon wholly inside one 128-unit
  subdivision cell instead of a centered polygon crossing the zero planes.

Fixture counts remain unchanged.

## Hardened test result channel

- Add `tools/check_runtime_test_log.py` with a self-test and encoding-aware log
  reader.
- `build.ps1` captures test output and fails on `FAIL:` or `tests failed: N/M`
  markers even when the process exit code is zero.
- `TEST_BP-040-044R3.ps1` applies the same rule to every independent test group,
  records the first marker, and marks synthetic failures in its JSON summary.
- The component checkers and global verifier bind all five corrected fixtures.

## Compatibility impact

No production source below `src/` and no native source or binary below `native/`
changed. The following remain unchanged:

```text
protocol15_frozen_v1
quakec_109_frozen_v1
world_physics_109_frozen_v1
host_lifecycle_109_frozen_v1
client_render_109_frozen_v1
world_render_109_frozen_v1
world_render_fingerprint=0x846a74de
```
