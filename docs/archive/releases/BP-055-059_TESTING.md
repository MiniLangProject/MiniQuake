# BP-055–BP-059 Windows acceptance

Extract the archive into a new empty directory. Set the directory that contains `id1\pak0.pak` as `-QuakeBase`.

```powershell
$QuakeBase = "C:\Path\To\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-055-059.ps1 `
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

Expected new success markers:

```text
MiniQuake BP-055 audio memory tests passed: 20
MiniQuake BP-056 audio DMA tests passed: 22
MiniQuake BP-057 audio mixer tests passed: 22
MiniQuake BP-058 audio Win32 tests passed: 20
MiniQuake BP-059 audio closure tests passed: 24
MiniQuake BP-059 retail audio evidence: PASS
MiniQuake BP-055-059 acceptance test: PASS
```

The acceptance script also requires two byte-identical retail-audio evidence logs, installed-game validation, 300 headless frames, two byte-identical 128-frame traces, inherited render evidence and UDP loopback. After the run, execute `.\COLLECT_RESULTS.ps1`. Quake data and binaries are excluded from the result archive.
