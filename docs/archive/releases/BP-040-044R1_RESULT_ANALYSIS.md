# BP-040–BP-044R1 Windows result analysis

## Result archive

- Archive: `MiniQuake_BP-040-044R1_RESULTS_20260727-080437.zip`
- SHA-256: `73ea957dacb8f106ccbc3c7b176b8167a882d95109ff98f3604703be7fe53754`
- Delivery under test: `BP-040-044R1`
- Engine package: `BP-044`

## Failure boundary

The static verifier completed successfully with all 39 R1 checks. The game
executable and 38 inherited test executables compiled successfully. The first
failure occurred while compiling the new BP-041 lightmap-atlas test entry:

```text
CompileError: Function standard expects 0 args, got 2
  at src/miniquake/filesystem.ml:70:10
    return standard(baseDirectory, gameName)
           ^
```

Build inventory at the stop point:

- 39 of 43 expected `.exe` targets existed.
- `MiniQuake.exe` compiled successfully.
- `MiniQuakeWorldSurfaceRenderTests.exe` compiled successfully.
- `MiniQuakeLightmapAtlasTests.exe` was the first missing target.
- BP-042, BP-043 and BP-044 test targets were not attempted after that failure.
- No runtime, installed-game, headless, trace or UDP test was reached.

## Root cause

`tests/lightmap_atlas_tests.ml` declared a package-free helper:

```ml
function standard()
  ...
end function
```

The transitive import closure also contains `miniquake.filesystem`, which owns:

```ml
function standard(baseDirectory, gameName)
  ...
end function

function initialize(baseDirectory, gameName)
  return standard(baseDirectory, gameName)
end function
```

The MiniLang compiler merges the complete import closure of an entry program.
A package-free entry function can therefore shadow an unqualified package-local
helper call during resolution. In the lightmap test program, the zero-argument
test helper shadowed `miniquake.filesystem.standard`, so the call from
`filesystem.initialize` was resolved against the wrong arity.

This is a test-entry symbol-resolution collision, not a filesystem, lightmap or
renderer semantic failure.

## R2 correction

- Rename the BP-041 helper to `standardFixture` and update all callers.
- Proactively rename the BP-043 test helper `bits` to `fixtureFloatBits`, so it
  cannot shadow the identically named internal helper in `render/gl11.ml`.
- Add a verifier pass over every MiniLang entry import closure. It rejects a
  package-free entry function when it shadows an internally called imported
  function with a different arity.
- Bind the exact R1 failure diagnostic and result archive hash in the delivery
  ledger and hotfix contract.

No file under `src/` or `native/` is changed by R2. All 108 world-render runtime
fixtures and the candidate contract remain unchanged:

```text
world_render_109_frozen_v1
fingerprint=0x846a74de
```
