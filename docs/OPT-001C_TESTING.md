# OPT-001C Windows test

Run from an elevated PowerShell in the flat project root:

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

.\TEST_OPT-001C.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -MatrixFrames 64 `
  -WarmupFrames 300 `
  -BenchmarkFrames 3000 `
  -HandleWarmupFrames 1200 `
  -HandleWindowFrames 5000 `
  -HandleWindows 3 `
  -E1M2VisibleFrames 1000 `
  -E1M2HeadlessFrames 10000 `
  -TransitionFrames 64 `
  -ContinueIndependentTests
```

Expected early gates:

```text
MiniQuake OPT-001C verification: PASS
MiniQuake OPT-001C allocation verification: PASS
MiniQuake OPT-001C allocation tests passed: 14
```

Performance classification is one of:

```text
TARGET_MET
IMPROVED_BELOW_TARGET
NO_REGRESSION_BELOW_TARGET
REGRESSION
```

Only `REGRESSION` fails the performance gate. The target remains at least 35% lower render median or 1.5x throughput together with at least 30% lower render P99.

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
