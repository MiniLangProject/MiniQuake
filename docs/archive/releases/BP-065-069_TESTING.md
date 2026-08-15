# BP-065–BP-069 Windows acceptance

Unpack the package into a new, empty directory. Build and test output is streamed
live while it is written to the build logs.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-065-069.ps1 `
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

New expected runtime markers:

```text
MiniQuake BP-065 key/focus tests passed: 20
MiniQuake BP-066 input device tests passed: 22
MiniQuake BP-067 console/screen tests passed: 22
MiniQuake BP-068 menu lifecycle tests passed: 24
MiniQuake BP-069 frontend closure tests passed: 24
```

All inherited real-game, trace, audio, framebuffer, Protocol-3 process-pair and
UDP gates remain mandatory. Expected final line:

```text
MiniQuake BP-065-069 acceptance test: PASS
```

Afterwards run:

```powershell
.\COLLECT_RESULTS.ps1
```
