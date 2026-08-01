# BP-020–BP-024R3 Windows acceptance

Extract the complete package into a new empty directory. Do not overlay it on
R2 or an older package.

```powershell
.\TEST_BP-020-024R3.ps1 `
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

The repaired gate is:

```text
[16/22] ED_Write
MiniQuake BP-022 QuakeC edict tests passed: 22
```

All other R2 gates must remain green, including:

```text
MiniQuake BP-024 stock QuakeC test: PASS
Validation result: PASS
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-020-024R3 acceptance test: PASS
```

After the run, regardless of the result:

```powershell
.\COLLECT_RESULTS.ps1
```

The output archive will be named approximately:

```text
build\MiniQuake_BP-020-024R3_RESULTS_YYYYMMDD-HHMMSS.zip
```
