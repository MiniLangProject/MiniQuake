# BP-020–BP-024R1 unter Windows testen

Das vollständige ZIP in einen neuen, leeren Ordner entpacken. Nicht über den
vorherigen BP-020–BP-024-Baum kopieren.

```powershell
.\TEST_BP-020-024R1.ps1 `
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

## Entscheidende Gates

```text
MiniQuake core tests passed: 16
MiniQuake BP-020 QuakeC progs.dat tests passed: 18
MiniQuake BP-021 QuakeC VM tests passed: 16
MiniQuake BP-022 QuakeC edict tests passed: 22
MiniQuake BP-023 QuakeC builtin tests passed: 22
MiniQuake BP-024 QuakeC closure tests passed: 20
MiniQuake BP-024 stock QuakeC test: PASS
```

Danach müssen installierte Spielvalidierung, 300 Headless-Frames, beide
128-Frame-Traces, der Bytevergleich und UDP-Loopback grün sein. Das erwartete
Ende lautet:

```text
MiniQuake BP-020-024R1 acceptance test: PASS
```

Nach jedem Lauf, auch nach einem Fehler:

```powershell
.\COLLECT_RESULTS.ps1
```

R1 sichert zusätzlich diese Logs:

```text
build\bp020-024r1-quakec-stock-tests.log
build\bp020-024r1-game-validation.log
build\bp020-024r1-runtime-validation.log
```
