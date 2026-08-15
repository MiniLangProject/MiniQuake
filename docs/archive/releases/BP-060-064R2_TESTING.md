# BP-060–BP-064R2 Windows acceptance

R2 combines the live-output runner with the BP-061 rule-enumeration correction.

## Run

Use a clean extracted directory and a Quake base directory containing `id1\pak0.pak`:

```powershell
$QuakeBase = "C:\path\to\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-060-064R2.ps1 `
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

Compiler and runtime output is streamed live and written to `build\bp060-064r2-*.log`.

## Repaired gate

The BP-061 group must continue through:

```text
[19/24] rule enumeration
[20/24] rule enumeration terminator
```

and end with:

```text
MiniQuake BP-061 network control tests passed: 24
```

The remaining new groups must report:

```text
MiniQuake BP-062 WinSock address tests passed: 24
MiniQuake BP-063 system/platform tests passed: 21
MiniQuake BP-064 network/platform closure tests passed: 24
```

The complete target is:

```text
MiniQuake BP-064 network platform evidence server: PASS
MiniQuake BP-064 network platform evidence: PASS
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-060-064R2 acceptance test: PASS
```

## Collect results

```powershell
.\COLLECT_RESULTS.ps1
```

The collector creates `build\MiniQuake_BP-060-064R2_RESULTS_*.zip` and excludes Quake data and compiled binaries.
