# OPT-001CR3R6 – Windows-Test

```powershell
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLangCompilerPy"

.\TEST_OPT-001CR3R6.ps1 `
  -Compiler "$CompilerRoot\mlc_win64.py" `
  -StdLib $CompilerRoot `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -MatrixFrames 64 `
  -WarmupFrames 300 `
  -BenchmarkFrames 3000 `
  -HandleWarmupFrames 1200 `
  -HandleWindowFrames 5000 `
  -HandleWindows 3 `
  -HandleConfirmationWindows 2 `
  -E1M2VisibleFrames 1000 `
  -E1M2HeadlessFrames 10000 `
  -TransitionFrames 64 `
  -ContinueIndependentTests
```

Nach dem Build startet `build\MiniQuake.exe --play "$QuakeBase" start` ohne Videooption standardmäßig im Fenster. Ein normaler Engine-Start mit `-fullscreen` erzwingt weiterhin Fullscreen.
