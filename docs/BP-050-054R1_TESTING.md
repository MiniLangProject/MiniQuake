# BP-050–BP-054R1 Windows acceptance

Extract the complete archive into a new, empty directory.  Set the actual Quake
base directory: it is the directory that contains `id1\pak0.pak`.

```powershell
$QuakeBase = "C:\Path\To\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"
```

The second command must return `True`.

Run:

```powershell
.\TEST_BP-050-054R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

The corrected gate is:

```text
[21/24] special cvar defaults
MiniQuake BP-054 render-special closure tests passed: 24
```

All previously green runtime gates must remain green, including the two exact
128-frame traces, the exact single evidence pair, the three exact corpus pairs,
and UDP loopback.

Expected final line:

```text
MiniQuake BP-050-054R1 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector writes `build\MiniQuake_BP-050-054R1_RESULTS_*.zip` and excludes
Quake game data and compiled binaries.
