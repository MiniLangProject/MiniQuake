# BP-040–BP-044R3 Windows acceptance

Extract the complete source archive into a new, empty directory. Do not overlay
R3 on an older MiniQuake tree.

Use a Quake base directory that actually exists on the test machine and contains
`id1/pak0.pak` and, for the registered game, `id1/pak1.pak`.

```powershell
Test-Path "C:\Actual\Path\To\Quake\id1\pak0.pak"
```

The command must print `True` before running full acceptance.

```powershell
.\TEST_BP-040-044R3.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Actual\Path\To\Quake" `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

## Early gates

The preflight must include:

```text
[PASS] minilang_entry_function_shadow_arity
[PASS] bp040044r1_renderer_member_write_contract
[PASS] bp040044r2_entry_symbol_shadow_contract
[PASS] bp040044r3_runtime_test_integrity_contract
MiniQuake runtime-test log checker self-test: PASS
```

The cumulative build must create all 43 executables.

## Corrected historical fixtures

These inherited groups must now be genuinely green, not merely return exit code
0:

```text
MiniQuake BP-013 Protocol 15 event tests passed: 22
MiniQuake BP-014R1 Protocol 15 runtime-event tests passed: 28
MiniQuake BP-015 Protocol 15 signon tests passed: 12
MiniQuake BP-018 Protocol 15 demo tests passed: 19
MiniQuake BP-043 sky/water render tests passed: 22
```

A line beginning with `FAIL:` or a summary containing `tests failed: N/M` is now
reported as a failed independent test group even if the executable returns 0.

The five world-render groups must end with:

```text
MiniQuake BP-040 world surface tests passed: 20
MiniQuake BP-041 lightmap atlas tests passed: 22
MiniQuake BP-042 dynamic-light render tests passed: 20
MiniQuake BP-043 sky/water render tests passed: 22
MiniQuake BP-044 world-render closure tests passed: 24
```

Full acceptance also requires installed-game validation, 300 headless frames,
two independent byte-identical 128-frame traces, a direct snapshot and Winsock
UDP loopback.

Expected final line:

```text
MiniQuake BP-040-044R3 acceptance test: PASS
```

After either success or failure:

```powershell
.\COLLECT_RESULTS.ps1
```

Expected result name:

```text
build\MiniQuake_BP-040-044R3_RESULTS_YYYYMMDD-HHMMSS.zip
```
