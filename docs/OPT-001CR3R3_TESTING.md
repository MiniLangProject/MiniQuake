# MiniQuake OPT-001CR3R3 – Windows-Test

```powershell
.\TEST_OPT-001CR3R3.ps1 `
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
  -HandleConfirmationWindows 1 `
  -E1M2VisibleFrames 1000 `
  -E1M2HeadlessFrames 10000 `
  -TransitionFrames 64 `
  -ContinueIndependentTests
```

Nach der Paketprüfung muss der Buildaufruf sichtbar echte benannte Argumente enthalten:

```text
arguments=-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ...\build.ps1 -Compiler ... -StdLib ... -Configuration Release -NoRunTests -SkipPreflight
output_mode=python_binary_passthrough_named_build_binding
```
