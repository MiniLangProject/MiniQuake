# BP-060–BP-064R4 Windows acceptance

R4 fixes package-qualified concrete type-name handling in deterministic
diagnostics and carries forward the R3 GC-rooting correction.  Foreground output
is streamed live and flushed to log files.

## Run

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-060-064R4.ps1 `
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

The first repaired gate must report:

```text
MiniQuake BP-001R3 diagnostics tests passed: 10
```

The decisive R3 revalidation is:

```text
compatibility trace A: PASS
compatibility trace B: PASS
byte-identical trace comparison: PASS
```

The complete run must end with:

```text
MiniQuake BP-060-064R4 acceptance test: PASS
```

Collect the result with:

```powershell
.\COLLECT_RESULTS.ps1
```
