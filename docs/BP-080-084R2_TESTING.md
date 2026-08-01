# BP-080–BP-084R2 Windows acceptance

Extract the complete package into a new, empty directory. Do not overlay an
older MiniQuake tree.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The path check must return `True`. Then run:

```powershell
.\TEST_BP-080-084R2.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The new early preflight gates must report:

```text
[PASS] minilang_main_entry_scope
[PASS] minilang_entry_helper_namespace
[PASS] minilang_entry_function_shadow_arity
```

All five new executables must compile:

```text
MiniQuakeCvarSourceSurfaceTests.exe
MiniQuakeCdAudioSourceSurfaceTests.exe
MiniQuakeSourceFunctionInventoryTests.exe
MiniQuakeBlackPortCorpusTests.exe
MiniQuakeBlackPortSourceClosureTests.exe
```

Expected runtime markers:

```text
MiniQuake BP-080 cvar source-surface tests passed: 20
MiniQuake BP-081 CD audio source-surface tests passed: 20
MiniQuake BP-082 source function inventory tests passed: 20
MiniQuake BP-083 black-port corpus tests passed: 18
MiniQuake BP-084 source black-port closure tests passed: 24
```

The four corpus pairs (`start`, `e1m1`, `e1m2`, `e1m3`) must each produce
byte-identical 64-frame traces. The final marker is:

```text
MiniQuake BP-080-084R2 acceptance test: PASS
```

Collect the result, even after a failure:

```powershell
.\COLLECT_RESULTS.ps1
```

The archive is written as:

```text
build\MiniQuake_BP-080-084R2_RESULTS_*.zip
```
