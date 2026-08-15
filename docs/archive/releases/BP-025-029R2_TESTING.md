# BP-025–BP-029R2 Windows acceptance

Extract the complete ZIP into a new, empty directory. Do not overlay the R1
folder.

```powershell
.\TEST_BP-025-029R2.ps1 `
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
[PASS] bp025029r2_world_hull_member_contract
```

The repaired compile boundary is the final block executable:

```text
MiniQuakeWorldPhysicsClosureTests.exe
```

It must compile after the other 27 targets. The new world/physics runtime groups
must then report:

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
MiniQuake BP-025-029R2 acceptance test: PASS
```

After the run, regardless of success or failure:

```powershell
.\COLLECT_RESULTS.ps1
```

The result file is named approximately:

```text
build\MiniQuake_BP-025-029R2_RESULTS_YYYYMMDD-HHMMSS.zip
```
