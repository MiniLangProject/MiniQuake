# MiniQuake BP-044 – central GLQuake world-render contract

## Scope

BP-044 closes the block by binding the central `gl_rmain.c` render ordering,
viewport setup, culling state and the previously completed world/light/warp
components into one contract.

## Changes

- Restores GLQuake's near/far clip values of `4` and `4096`.
- Implements the original viewport edge/fractional-scale fudge.
- Uses front-face culling and exposes the classic `gl_cull` compatibility Cvar.
- Makes the authoritative frame order explicit:
  `world → entities → dlights → particles → viewmodel → water → polyblend`.
- Moves deferred water to the correct post-viewmodel pass.
- Keeps dynamic-light rendering immediately after the world pass.
- Adds the candidate contract `world_render_109_frozen_v1` with fingerprint
  `0x846a74de`.

## Evidence

- C oracle: `tools/oracle/world_render_closure_oracle.c`
- Golden report: `audit/world_render_closure_golden.json`
- MiniLang runtime suite: `tests/world_render_closure_tests.ml` (**24 fixtures**)
- Audit: `docs/BP-044_WORLD_RENDER_CLOSURE_AUDIT.md`
