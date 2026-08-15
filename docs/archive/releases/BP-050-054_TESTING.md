# BP-050-BP-054 Windows acceptance

Extract the complete ZIP into a new empty directory. Set `QuakeBase` to the directory containing `id1\pak0.pak`.

```powershell
$QuakeBase = "C:\Path\To\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"

.\TEST_BP-050-054.ps1 `
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

An optional Original GLQuake corpus can be supplied with:

```powershell
-OriginalRenderReference C:\Path\To\OriginalGLQuakeCaptures
```

That directory must contain `start-064.tga`, `start-128.tga`, and `e1m1-128.tga`. Without it, exact MiniQuake A/B corpus determinism is still mandatory and the Original comparison is explicitly marked SKIPPED.

Expected new test markers:

```text
MiniQuake BP-050 mirror special-render tests passed: 22
MiniQuake BP-051 render-clear special tests passed: 20
MiniQuake BP-052 envmap/timerefresh tests passed: 20
MiniQuake BP-053 render-evidence corpus tests passed: 18
MiniQuake BP-054 render-special closure tests passed: 24
MiniQuake BP-050-054 acceptance test: PASS
```

After the run:

```powershell
.\COLLECT_RESULTS.ps1
```
