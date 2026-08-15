# BP-025–BP-029R1 Windows result analysis

Result archive:

```text
MiniQuake_BP-025-029R1_RESULTS_20260726-015350.zip
SHA-256: 08f1dfb4ee1cd0e703b94177f02334a1a0a3f68cf152e6e8412b0b6ea02dd9af
```

## Result boundary

The complete static preflight passed, including the transitive import-alias
closure scan added in R1. The Windows compiler then produced 27 of the 28
requested executables. The final target failed:

```text
MiniQuakeWorldPhysicsClosureTests.exe
```

The compiler diagnostic was:

```text
CompileError: Undefined variable 'hull'
  at tests/world_physics_closure_tests.ml:70:76
    ... equal(hull.pointContents(box, ...), ...)
              ^
```

No runtime, installed-game, deterministic-trace or UDP gate was reached because
the cumulative build is intentionally atomic.

## Root cause

The import alias itself was valid:

```ml
import miniquake.world_hull as hull
```

The immediately preceding call to `hull.createBoxHull(...)` compiled. The
failure was the requested package member. `miniquake.world_hull` exports:

```text
truePointContents
pointContentsFromNode
```

It does not export a function named `pointContents`. Once qualified package
member resolution failed, the MiniLang compiler reported the head identifier as
an undefined value named `hull`.

The closure fixture was intended to validate the six-node box-hull traversal.
The correct call is therefore:

```ml
hull.pointContentsFromNode(box, 0, point)
```

This is a test-only error. The production world, collision and physics source
was not implicated by the result.

## BP-025–BP-029R2 correction

R2:

- replaces the nonexistent `hull.pointContents(...)` call with
  `hull.pointContentsFromNode(box, 0, ...)`;
- keeps the existing 20-fixture closure contract and its expected values;
- adds an explicit verifier gate for the exported box-hull API used by the
  closure fixture;
- records R2-specific logs, result metadata and the exact R1 compiler evidence;
- changes no file under `src/` or `native/`.

The engine package remains `BP-029`; only the delivery revision advances to
`BP-025-029R2`.
