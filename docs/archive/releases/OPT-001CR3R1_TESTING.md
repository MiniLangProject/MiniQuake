# MiniQuake OPT-001CR3R1 – Windows-Test

Das ZIP flach in einen leeren MiniQuake-Ordner entpacken. Danach PowerShell als Administrator öffnen.

```powershell
Get-ChildItem -Recurse -File | Unblock-File
$QuakeBase = "C:\Users\nilsk\Dropbox\Quake"
$CompilerRoot = "C:\Users\nilsk\Desktop\MiniLang\MiniLangCompilerPy"

.\TEST_OPT-001CR3R1.ps1 `
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

Der Build muss sofort fortlaufende Zeilen unter `output_mode=python_subprocess_live` anzeigen. Bei einem Buildfehler werden abhängige Tests nicht gestartet; stattdessen erscheinen `SKIPPED` und die letzten Logzeilen.

Nach dem Lauf:

```powershell
.\COLLECT_RESULTS.ps1
```
