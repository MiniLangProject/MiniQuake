# MiniQuake OPT-001CR3R4 – Windows-Test

```powershell
.\TEST_OPT-001CR3R4.ps1 `
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

Vor dem Build müssen die Paketchecks `current_entry_helper_namespace` und `minilang_entry_function_shadow_arity` PASS melden. Anschließend muss `MiniQuakeOPT001CR3HotpathTests.exe` kompilieren.
