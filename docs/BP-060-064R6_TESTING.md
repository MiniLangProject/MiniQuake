# BP-060–BP-064R6 Windows acceptance

R6 fixes the false failure produced when Windows PowerShell 5.1 returned a blank
`Start-Process.ExitCode` for an already completed Protocol-3 evidence server.
Foreground compiler and test output remains live and is flushed per line.

## Run

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-060-064R6.ps1 `
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

The two UDP Protocol-3 pairs must each show server and client PASS. R6 also
writes:

```text
build\bp060-064r6-network-pair-a.json
build\bp060-064r6-network-pair-b.json
```

Each report must contain exit code `0` for both processes and both PASS markers.
The complete run must end with:

```text
MiniQuake BP-060-064R6 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
