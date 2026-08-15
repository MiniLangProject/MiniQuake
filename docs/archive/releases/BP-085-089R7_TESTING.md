# BP-085–BP-089R7 Windows acceptance

Extract the ZIP into a new, empty directory. Output is streamed live.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

Test-Path "$QuakeBase\id1\pak0.pak"
Test-Path "$CompilerRoot\mlc_win64.py"

.\TEST_BP-085-089R7.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -BlackPortCorpusFrames 64 `
  -SoakFrames 5000 `
  -ListenSoakFrames 5000 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Critical R7 gates:

```text
MiniQuake BP-001R3 diagnostics tests passed: 10
compatibility trace A: PASS
compatibility trace B: PASS
byte-identical trace comparison: PASS
black-port corpus e1m2-064 trace A: PASS
black-port corpus e1m2-064 trace B: PASS
black-port corpus e1m2-064 comparison: PASS
MiniQuake BP-085-089R7 acceptance test: PASS
```

The diagnostics stress is internal to the ten-test suite and binds 227 stable
Edicts, 80 synchronization passes, object identity and non-shrinking
`numEdicts`. After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
