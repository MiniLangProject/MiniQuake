# BP-060–BP-064R5 Windows acceptance

R5 fixes the render-comparator command-line mismatch found after R4 had already
completed all compiled tests, game validation, headless runtime, audio evidence,
double traces and both visible framebuffer captures. Foreground output remains
live and is flushed to the corresponding log file per line.

## Run

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-060-064R5.ps1 `
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

The corrected gate must report:

```text
byte-identical render evidence: PASS
```

It is followed by the two independent Protocol-3/UDP server-client handshakes
and the Winsock UDP loopback smoke. The complete run must end with:

```text
MiniQuake BP-060-064R5 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
