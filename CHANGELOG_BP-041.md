# MiniQuake BP-041 – lightmap formats and atlas ownership

## Scope

BP-041 completes the lightmap-memory and atlas-ownership rules carried by
`gl_rsurf.c` and `gl_rmisc.c`.

## Changes

- Supports both the historical one-byte luminance lightmap path and the
  four-byte RGBA path used by later GLQuake configurations.
- Computes exact row-stride and destination-size requirements before writing.
- Preserves fullbright and missing-lightdata behavior.
- Retains cached lightstyle and dynamic-light invalidation semantics.
- Collects shared atlas texture IDs once and deletes every OpenGL lightmap page
  exactly once during renderer destruction.
- Prevents duplicate deletion when multiple surfaces share an atlas page.

## Evidence

- C oracle: `tools/oracle/lightmap_atlas_render_oracle.c`
- Golden report: `audit/lightmap_atlas_render_golden.json`
- MiniLang runtime suite: `tests/lightmap_atlas_tests.ml` (**22 fixtures**)
- Audit: `docs/BP-041_LIGHTMAP_ATLAS_AUDIT.md`
