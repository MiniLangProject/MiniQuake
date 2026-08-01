# MiniQuake BP-040 – GLQuake world surfaces and texture chains

## Scope

BP-040 ports the remaining observable world-surface selection and chain rules
from `gl_rsurf.c` and the world-facing parts of `gl_rmain.c` into the common
MiniLang renderer.

## Changes

- Adds the original `BACKFACE_EPSILON` value of `0.01` for world and brush
  surface facing decisions.
- Restores per-texture head-insertion chains rather than treating all world
  surfaces as one undifferentiated draw list.
- Keeps sky and turbulent-water surfaces on their dedicated chains.
- Defers translucent sorted water to the post-entity pass while retaining the
  original immediate path for opaque or unsorted water.
- Applies brush-model facing rules in model-local coordinates.
- Keeps texture-chain allocation, reset and invalid-index handling explicit and
  testable.

## Evidence

- C oracle: `tools/oracle/world_surface_render_oracle.c`
- Golden report: `audit/world_surface_render_golden.json`
- MiniLang runtime suite: `tests/world_surface_render_tests.ml` (**20 fixtures**)
- Audit: `docs/BP-040_WORLD_SURFACE_AUDIT.md`
