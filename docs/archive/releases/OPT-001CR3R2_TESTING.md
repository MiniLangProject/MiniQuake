# MiniQuake OPT-001CR3R2 – Windows-Test

```powershell
.\TEST_OPT-001CR3R2.ps1 `
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

Erwarteter früher Ablauf:

```text
[PASS] OPT-001CR3R2 package verification
[MiniQuake/OPT-001CR3R2] starting OPT-001CR3R2 game and contract build
output_mode=python_subprocess_live_scalar_exit
... live Compilerzeilen ...
```

Nach dem Lauf `./COLLECT_RESULTS.ps1` ausführen.
## Binary-safe Live-Runner-Hotfix (2026-08-09)

Der zweite CR3R2-Versuch erreichte den Paket-PASS, der Python-Live-Runner brach jedoch beim Start des Build-Kindprozesses mit einer nicht vollständig erhaltenen Traceback-Ausgabe ab. Der Runner leitet Kindprozessdaten nun binär ohne Codepage-Roundtrip weiter, fängt Streamingfehler vollständig ab und schreibt Diagnose sowie Exitcode in `*.status.json`. PowerShell konsumiert den nativen Stream über `Out-Host` bei vorübergehend nicht-terminierender Native-Fehlerbehandlung; der Funktionsrückgabewert bleibt ein einzelner Integer.

