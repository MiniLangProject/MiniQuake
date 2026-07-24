# Reference instrumentation patches

Patches in this directory may add deterministic trace hooks to the pinned
GLQuake reference build.  They must not change game, protocol, renderer, or
audio behavior, and they are applied only to a disposable generated worktree.

The historical `GLQUAKE.EXE` remains the unmodified black-box oracle.

`renderer_trace_fixture.patch` is applied only to a temporary detached
worktree by `python tools/renderer_differential.py`.  It compiles the original
`GL_Bind` and `Draw_TileClear` bodies from `gl_draw.c` against a diagnostic GL
sink, runs the matching MiniLang fixture, and compares the resulting JSONL
command streams with zero numeric tolerance.

The same command also applies `renderer_warp_trace_fixture.patch` and
`renderer_rlight_trace_fixture.patch`.  These replace only the header include
in the disposable worktree, then compile every Quake 1 target body in
`gl_warp.c` and `gl_rlight.c` against the minimal types and diagnostic sinks in
`reference/fixtures/renderer`.  The matching MiniLang fixtures are
`tests/renderer_warp_trace_fixture.ml` and
`tests/renderer_rlight_trace_fixture.ml`.

`audit/renderer_differential_manifest.json` maps each compiled original function to the
scene that executes it.  The runner rejects a manifest entry whose scene did
not occur.  Command order, operation names, integer state and GL enums compare
exactly; floating-point parameters compare with epsilon `1e-5`.  `R_InitSky`
compares full FNV-1a hashes of both generated 128x128 RGBA layers.  QUAKE2-only
definitions in `gl_warp.c` are explicitly excluded because the parity target
is the Quake 1 path of GLQuake 1.09.

All three patches are applied to a detached worktree at the pinned reference
commit.  The runner removes the worktree and verifies the real submodule both
before and after every run.
