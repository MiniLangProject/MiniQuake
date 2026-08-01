# BP-040–BP-044R2 Windows result analysis

Result archive:

```text
MiniQuake_BP-040-044R2_RESULTS_20260727-105653.zip
SHA-256: 2678896b8071fe20d5f7a97fa86eb5cb5ad395a536be62ae464c697fc2f6d831
```

## What completed

The R2 compiler fixes were successful. The package passed all 41 static checks,
compiled `MiniQuake.exe` and all 42 test executables, and the acceptance summary
recorded 84/84 script steps as `PASS`.

The requested installed-game stages did not start because the supplied path did
not exist on that machine:

```text
C:\Program Files (x86)\Steam\steamapps\common\Quake
```

The summary therefore ended with:

```text
Quake base directory does not exist
```

No real-game validation, headless runtime, compatibility trace or UDP stage can
be accepted from this result.

## Suppressed runtime-test failures

A retrospective scan of the collected per-test logs found five independent
fixture failures that the R2 PowerShell harness had classified as `PASS` because
the corresponding MiniLang executables returned process exit code 0:

| Group | Runtime output | Classification |
|---|---|---|
| BP-013 events | particle count/color bytes reversed in two direct writer fixtures | fixture adapter error |
| BP-014R1 runtime events | expired first beam slot expected as slot 1 instead of reusable slot 0 | fixture expectation error |
| BP-015 signon | `ClientEntityState.baseline` populated with a struct instead of its canonical seven-element array | fixture adapter error |
| BP-018 demo | one leading space used while the expected GLQuake arithmetic value requires two | fixture input error |
| BP-043 sky/water | centered small polygon crosses both zero subdivision planes and therefore produces four polygons | fixture geometry error |

The relevant logs contained both a `FAIL:` line and a later failed aggregate
summary, followed by an unconditional success line. This is possible because a
number of historical MiniLang tests call a standalone top-level `error(...)`
without returning it from `main`; reaching the end of the program then yields
process exit code 0.

## R3 response

R3 corrects the five fixtures without changing production or native code. It
also makes runtime test output part of the acceptance contract:

```text
FAIL: ...
MiniQuake ... tests failed: N/M
BP-... tests failed: N/M
```

Any such marker now forces a failing result even if the executable reports exit
code 0. The same guard exists in both `build.ps1` and
`TEST_BP-040-044R3.ps1`, and is independently modeled by
`tools/check_runtime_test_log.py`.

The world-render contract and fingerprint remain unchanged:

```text
world_render_109_frozen_v1
0x846a74de
```
