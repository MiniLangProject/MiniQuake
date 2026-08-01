# MiniQuake BP-043 – Binary32 sky, water and subdivision math

## Scope

BP-043 tightens the `gl_warp.c` port at the same storage and arithmetic
boundaries that are observable in GLQuake 1.09.

## Changes

- Rounds water-warp inputs, sine offsets and resulting texture coordinates to
  IEEE-754 Binary32 at the original C `float` boundaries.
- Applies the same treatment to sky vectors, wrapped speed scales and the two
  sky-layer speeds.
- Keeps sky-axis and zero-direction edge cases stable.
- Uses Binary32 values through recursive polygon subdivision.
- Preserves the 128-unit default subdivision size and vertex-limit guards.
- Retains original sky-palette averaging and transparent-layer construction.

## Evidence

- C oracle: `tools/oracle/sky_water_render_oracle.c`
- Golden report: `audit/sky_water_render_golden.json`
- MiniLang runtime suite: `tests/sky_water_render_tests.ml` (**22 fixtures**)
- Audit: `docs/BP-043_SKY_WATER_RENDER_AUDIT.md`
