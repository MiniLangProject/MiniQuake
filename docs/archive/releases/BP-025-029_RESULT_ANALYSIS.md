# BP-025–BP-029 Windows result analysis

Result archive: `MiniQuake_BP-025-029_RESULTS_20260726-010226.zip`  
SHA-256: `40282cedd6a11449b85272e50bec3fba98f75eea0e73bd9c0b63e40db7710549`

## Result boundary

The complete static preflight passed, including all Protocol 15, QuakeC and
world/physics source contracts. The cumulative Windows build then produced the
game, all inherited regression executables and `MiniQuakeWorldHullTests.exe`.
In total, 21 executable targets and both native DLLs were present when the
build stopped. No runtime test group had started yet.

The first compiler failure was:

```text
CompileError: import alias bsp refers to multiple packages:
miniquake.format.bsp and miniquake.world_bsp
  at tests/world_trace_parity_tests.ml:11:1
  import miniquake.world_bsp as bsp
```

## Cause

MiniLang merges the entry module and its transitive imports before native code
generation. An explicit alias therefore has to identify one package throughout
that compile closure.

`tests/world_trace_parity_tests.ml` used `bsp` for
`miniquake.world_bsp`. Its dependency closure also reaches the integrated
server and edict modules, which already use `bsp` for
`miniquake.format.bsp`. The per-file package verifier did not detect this
transitive import closure conflict, but the Windows compiler correctly did.

A complete closure scan found one additional conflict that the compiler would
have reached after the first repair:

```text
movement -> miniquake.player_move
movement -> miniquake.server_move
```

It originated in `tests/world_physics_closure_tests.ml`, where the direct
`miniquake.server_move` alias collided with the integrated server's alias for
`miniquake.player_move`.

## R1 repair

The delivery-only test aliases are now unique in their complete compile graphs:

```text
miniquake.world_bsp  as bspworld
miniquake.server_move as serverMovement
```

A new verifier pass recursively expands every executable MiniLang entrypoint
and rejects any alias that names more than one package in the resulting graph.
It checks both the main program and every test file containing `main`.

No file under `src/` or `native/` was changed. Runtime fixture counts,
Protocol 15, QuakeC, world/physics code and the fingerprint `0x2235d77c`
remain unchanged. The executable identity therefore remains `BP-029`; the
corrected delivery revision is `BP-025-029R1`.
