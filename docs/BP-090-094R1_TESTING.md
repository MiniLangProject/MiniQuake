# MiniQuake BP-090–BP-094R1 – Windows acceptance

R1 fixes the PowerShell parse failure that occurred before the acceptance test
could begin. Use a new, empty extraction directory.

## Required paths

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "C:\Path\to\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
```

All three checks must be `True`. The original archive can alternatively be
placed next to the extracted MiniQuake directory or supplied through
`MINIQUAKE_ORIGINAL_SOURCE`.

## Run

```powershell
.\TEST_BP-090-094R1.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -OriginalQuakeSourceArchive $OriginalSource `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -OriginalInteropFrames 10000 `
  -OriginalVisualFrame 256 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The output remains live and line-flushed. The expected final line is:

```text
MiniQuake BP-090-094R1 acceptance test: PASS
```

Then collect the textual evidence:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector creates `build\MiniQuake_BP-090-094R1_RESULTS_*.zip` and
excludes the original executable, Quake game data, TGA images, DLLs and compiled
binaries.
