# MiniQuake BP-042 – dynamic-light render ordering

## Scope

BP-042 ports the frame-order-sensitive parts of `gl_rlight.c`, `gl_rmain.c` and
brush-model light marking.

## Changes

- Introduces a common `R_BeginWorldFrame` boundary.
- Preserves the original order: push dynamic lights, animate lightstyles, then
  advance render frame counters.
- Filters expired dynamic lights at the Binary32 time boundary.
- Resets stale surface light bits before a new marking frame.
- Unions multiple light bits without losing earlier markers.
- Marks dynamic lights on movable brush models in model-local space.
- Keeps `gl_flashblend` and `r_dynamic` bypass behavior explicit.

## Evidence

- C oracle: `tools/oracle/dynamic_light_render_oracle.c`
- Golden report: `audit/dynamic_light_render_golden.json`
- MiniLang runtime suite: `tests/dynamic_light_render_tests.ml` (**20 fixtures**)
- Audit: `docs/BP-042_DYNAMIC_LIGHT_RENDER_AUDIT.md`
