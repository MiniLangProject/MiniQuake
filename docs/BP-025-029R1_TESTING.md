# BP-025–BP-029R1 Windows acceptance

Extract the complete ZIP into a new, empty directory. Do not overlay the failed
BP-025–BP-029 directory.

```powershell
.\TEST_BP-025-029R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The preflight must include:

```text
[PASS] minilang_transitive_import_aliases
```

The first new compile boundary is:

```text
MiniQuakeWorldTraceTests.exe
```

It must now compile, followed by all remaining world/physics executables:

```text
MiniQuakeWorldLinkTests.exe
MiniQuakeServerMoveTests.exe
MiniQuakeServerPhysicsTests.exe
MiniQuakeSvUserMovementTests.exe
MiniQuakeServerUserTests.exe
MiniQuakeWorldPhysicsClosureTests.exe
```

Expected new runtime results:

```text
MiniQuake BP-025 world hull tests passed: 14
MiniQuake BP-025 world trace tests passed: 10
MiniQuake BP-026 world link/collision tests passed: 15
MiniQuake BP-027 server movement tests passed: 14
MiniQuake BP-028 server physics tests passed: 18
MiniQuake BP-028 sv_user movement tests passed: 16
MiniQuake BP-029 server user tests passed: 18
MiniQuake BP-029 world/physics closure tests passed: 20
```

The complete acceptance ends with:

```text
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-025-029R1 acceptance test: PASS
```

After the run, regardless of success or failure:

```powershell
.\COLLECT_RESULTS.ps1
```

The result file is named approximately:

```text
build\MiniQuake_BP-025-029R1_RESULTS_YYYYMMDD-HHMMSS.zip
```
