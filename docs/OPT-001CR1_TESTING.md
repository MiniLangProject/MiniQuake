# MiniQuake OPT-001CR1 Windows test

OPT-001CR1 repairs the delivery-time MiniLang delimiter error found in the
first OPT-001C Windows run.  It reruns the complete allocation/performance and
OPT-001B correctness matrix.

## Prerequisites

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path .\TEST_OPT-001CR1.ps1
Test-Path .\tools\verify.py
```

All four checks must return `True`.

## Run

Start PowerShell as Administrator, then:

```powershell
Get-ChildItem -Recurse -File | Unblock-File

.\TEST_OPT-001CR1.ps1 `
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

The early preflight must include:

```text
MiniQuake MiniLang delimiter verification: PASS
MiniQuake OPT-001CR1 syntax verification: PASS
MiniQuake OPT-001CR1 verification: PASS
```

The previous error must not recur:

```text
Expected RBRACK, got RPAREN
```

At the end the harness reports one of the measured performance classifications
while preserving all correctness gates.  The desired overall result is:

```text
MiniQuake OPT-001CR1 acceptance test: PASS
```

## Collect

```powershell
.\COLLECT_RESULTS.ps1
```

The collector creates:

```text
build\MiniQuake_OPT-001CR1_RESULTS_YYYYMMDD-HHMMSS.zip
```
