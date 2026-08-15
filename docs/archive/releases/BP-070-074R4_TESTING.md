# BP-070–BP-074R4 collection and Windows test

## Recover an already completed R3 run without rebuilding

The generated BP-071/BP-072 scratch directories contain no diagnostics needed
for the result archive. In the existing R3 tree they can be removed and the old
collector rerun:

```powershell
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue `
  .\build\bp071_fs, `
  .\build\bp071-filesystem, `
  .\build\bp072-wad

.\COLLECT_RESULTS.ps1
```

Alternatively replace the collector with the R4 version and rerun only result
collection. A full engine retest is not required for this collector-only fix.

## Full R4 acceptance

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"

.\TEST_BP-070-074R4.ps1 `
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

Then:

```powershell
.\COLLECT_RESULTS.ps1
```

The collector must finish even when synthetic test workspaces remain under
`build`. `collection.json` records them in `skipped_build_artifacts`, and no
Quake data or compiled binary is included.
