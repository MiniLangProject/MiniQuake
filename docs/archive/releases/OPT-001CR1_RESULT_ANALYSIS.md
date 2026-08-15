# MiniQuake OPT-001CR1 result analysis

## Input

- Result archive: `MiniQuake_OPT-001C_RESULTS_20260807-180739.zip`
- SHA-256: `46030ff06931e660ba025453fd03f92488846dd42d5341bff353a5f82e844c81`
- Delivery under test: `OPT-001C`
- Parent: `OPT-001B`

## Result

The package verifier passed, but the first MiniLang target (`MiniQuake.exe`) did
not compile.  No map matrix, benchmark, handle plateau, trace comparison or
performance comparison ran.

```text
ParseError: Expected RBRACK, got RPAREN:)
  at src/miniquake/render/world.ml:1581:216
```

The delivered source contained a malformed nested trace-only expression ending
in the equivalent of:

```text
compatHashLightmapRows(page, rectangle[1], rectangle[3),
```

The `import ... requires imported file to declare package` messages that
followed were secondary diagnostics: because `world.ml` failed to parse, its
leading `package miniquake.render.world` declaration never became available to
import resolution.

The harness then reported the missing
`MiniQuakeOPT001BCorrectnessTests.exe`.  That is also a consequence of the
failed cumulative build, not an independent product defect.

## Classification

```text
delivery-time MiniLang delimiter error
```

This result does **not** measure the intended OPT-001C optimization.  The
performance classification and handle classification correctly remained
`UNKNOWN`.

## OPT-001CR1 repair

1. Both guarded lightmap-upload trace call sites now calculate their trace hash
   in a named local variable before constructing the trace argument list.
2. The malformed `rectangle[3)` form is explicitly forbidden by the R1 source
   contract.
3. A lexical delimiter checker scans every project `.ml` file before the long
   Windows build and validates parentheses and array brackets while ignoring
   strings and comments.
4. The package verifier invokes both the general delimiter checker and the R1
   source contract before compilation.
5. R1 has a unique test, log, summary and result-archive identity so it cannot
   be confused with the failed OPT-001C delivery.

The intended OPT-001C semantics remain unchanged: disabled trace paths must not
construct trace argument arrays, and all OPT-001B correctness gates remain
active.
