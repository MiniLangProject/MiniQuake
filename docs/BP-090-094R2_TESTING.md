# MiniQuake BP-090–BP-094R2 – Windows acceptance

R2 fixes the verifier command-line mismatch that stopped R1 before the build.
Use a new, empty extraction directory. Output remains live and line-flushed.

## Required paths

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"
$OriginalSource = "C:\Path\to\OriginalQuakeSourceCode.zip"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"
Test-Path $OriginalSource
```

All three checks must be `True`.

## Optional verifier smoke tests

Both forms are supported; the build itself uses the first one:

```powershell
python .\tools\verify.py --root .
python .\tools\verify.py .
```

## Full acceptance run

```powershell
.\TEST_BP-090-094R2.ps1 `
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

Expected final line:

```text
MiniQuake BP-090-094R2 acceptance test: PASS
```

Then collect the textual evidence:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector creates `build\MiniQuake_BP-090-094R2_RESULTS_*.zip` and
excludes the original executable, Quake game data, TGA images, DLLs and
compiled binaries.
