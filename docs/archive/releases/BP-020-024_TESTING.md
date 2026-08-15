# BP-020–BP-024 – Windows-Abnahme

Das vollständige ZIP immer in einen neuen, leeren Ordner entpacken.

```powershell
.\TEST_BP-020-024.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Der Test baut den kumulativen Endstand einmal und führt danach alle voneinander
unabhängigen Testprogramme weiter aus. Das benutzereigene `id1/progs.dat` wird
nur gelesen und niemals in das Ergebnisarchiv übernommen.

Erwartete neue Erfolgsausgaben:

```text
MiniQuake BP-020 QuakeC progs.dat tests passed: 18
MiniQuake BP-021 QuakeC VM tests passed: 16
MiniQuake BP-022 QuakeC edict tests passed: 22
MiniQuake BP-023 QuakeC builtin tests passed: 22
MiniQuake BP-024 QuakeC closure tests passed: 20
MiniQuake BP-024 stock QuakeC test: PASS
MiniQuake BP-020-024 acceptance test: PASS
```

Nach jedem Lauf, auch nach einem Fehler:

```powershell
.\COLLECT_RESULTS.ps1
```
