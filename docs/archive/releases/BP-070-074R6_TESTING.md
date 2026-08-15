# BP-070–BP-074R6 Windows acceptance

Extract into a new empty directory. Output remains live and unbuffered.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-070-074R6.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The repaired BP-073 gate must pass fixture 6 (`BSP submodel`) and later fixture 24 (`registry bounds`), then report:

```text
MiniQuake BP-073 model asset tests passed: 24
MiniQuake BP-074 core assets/memory closure tests passed: 24
MiniQuake BP-070-074R6 acceptance test: PASS
```

Then run `./COLLECT_RESULTS.ps1`.
