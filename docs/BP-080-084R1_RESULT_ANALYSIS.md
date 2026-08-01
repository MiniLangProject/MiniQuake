# BP-080–BP-084 result analysis

## Observed Windows result

The BP-080–BP-084 package passed all static source-contract checks and compiled
MiniQuake plus all inherited test targets through BP-079.  The first new target,
`MiniQuakeCvarSourceSurfaceTests.exe`, failed during MiniLang compilation:

```text
CompileError: main(args) must be declared at top-level
at tests/cvar_source_surface_tests.ml:27
```

The same structural defect was present in all five new block entry files.  Each
file declared a `package` and also defined `main(args)`.  MiniLang requires a
program entrypoint to live in the global top-level scope; package modules may be
imported, but they cannot own the program entrypoint.

## R1 correction

The package declarations were removed from:

- `tests/cvar_source_surface_tests.ml`
- `tests/cd_audio_source_surface_tests.ml`
- `tests/source_function_inventory_tests.ml`
- `tests/black_port_corpus_tests.ml`
- `tests/black_port_source_closure_tests.ml`

No production or native code changed.  A new verifier gate scans every MiniLang
entry file and rejects `main(args)` whenever the same source declares a
`package`.

## Classification

- Failure class: build/test-entrypoint blocker
- Production semantics reached: no
- New BP-080..084 runtime fixtures reached: no
- Parent engine baseline affected: no
- Result archive SHA-256: `b5ff4b1defbfffacf14e6d9e0b84102093b21f367f5065d1bcc873310cb7b51a`
