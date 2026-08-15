# BP-060–BP-064R3 Windows acceptance

Use a freshly extracted directory and a Quake base directory containing
`id1\pak0.pak`. Output is streamed live and flushed to logs line by line.

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-060-064R3.ps1 `
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

The inherited diagnostics group must still report:

```text
MiniQuake BP-001R3 diagnostics tests passed: 10
```

The repaired trace gate must complete twice:

```text
compatibility trace A: PASS
compatibility trace B: PASS
byte-identical trace comparison: PASS
```

All five network/platform groups must remain green:

```text
MiniQuake BP-060 network main tests passed: 20
MiniQuake BP-061 network control tests passed: 24
MiniQuake BP-062 WinSock address tests passed: 24
MiniQuake BP-063 system/platform tests passed: 21
MiniQuake BP-064 network/platform closure tests passed: 24
```

The final line is:

```text
MiniQuake BP-060-064R3 acceptance test: PASS
```

Collect results with:

```powershell
.\COLLECT_RESULTS.ps1
```
