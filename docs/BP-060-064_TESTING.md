# BP-060–BP-064 Windows acceptance

Extract the package into a new empty directory. Set the actual Quake base
folder—the directory containing `id1\pak0.pak`—and run:

```powershell
$QuakeBase = "C:\Path\To\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-060-064.ps1 `
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

New required runtime markers:

```text
MiniQuake BP-060 network main tests passed: 20
MiniQuake BP-061 network control tests passed: 24
MiniQuake BP-062 WinSock address tests passed: 24
MiniQuake BP-063 system/platform tests passed: 21
MiniQuake BP-064 network/platform closure tests passed: 24
two independent UDP control handshakes ... PASS
MiniQuake BP-060-064 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
