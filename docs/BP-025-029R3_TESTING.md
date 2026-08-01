# BP-025–BP-029R3 Windows-Abnahme

Das vollständige Paket in einen neuen, leeren Ordner entpacken und aus diesem
Ordner ausführen:

```powershell
.\TEST_BP-025-029R3.ps1 `
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

Die vier in R2 fehlgeschlagenen Gruppen müssen nun vollständig bestehen:

```text
MiniQuake BP-025 world trace tests passed: 10
MiniQuake BP-028 sv_user movement tests passed: 16
MiniQuake BP-029 server user tests passed: 18
MiniQuake BP-029 world/physics closure tests passed: 20
```

Zusätzlich müssen alle historischen Gates, die installierte Quake-
Datenvalidierung, 300 Headless-Frames, zwei byteidentische 128-Frame-Traces und
UDP-Loopback grün bleiben. Die Abschlusszeile lautet:

```text
MiniQuake BP-025-029R3 acceptance test: PASS
```

Nach dem Lauf unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```
