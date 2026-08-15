# BP-040 audit – world surfaces and texture chains

## Original reference

Primary source: `gl_rsurf.c`; supporting world-facing behavior from
`gl_rmain.c` and `gl_refrag.c`.

## Ported behavior

- World and brush backface tests use a `0.01` epsilon and account for the
  surface plane-side flag.
- Visible, non-culled surfaces are inserted at the head of their texture's
  chain, preserving GLQuake's chain construction semantics.
- Sky and water flags remain available to their dedicated passes.
- Sorted translucent water is deferred; opaque and unsorted water can remain
  in the immediate path.
- Resetting a frame clears every texture-chain head without modifying surface
  ownership.

## Safe implementation differences

MiniLang stores chain heads in arrays rather than writable C pointers. Invalid
texture indices and `void` surfaces are rejected safely instead of causing an
out-of-bounds pointer write. Valid map/render behavior is unchanged.

## Evidence

`world_surface_render_oracle.c`, the JSON golden file and 20 MiniLang fixtures
cover epsilon boundaries, side selection, chain insertion/reset, texture
separation, sky/water classification and water deferral.
