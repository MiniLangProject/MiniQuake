# BP-012 – Windows-Testanleitung

## Voraussetzung

- Windows x64
- Python und der MiniLang-Win64-Compiler
- eine legale Quake-Installation für die Echtdatenprüfung

Das vollständige BP-012-ZIP muss in einen **neuen, leeren Ordner** entpackt
werden. Nicht über BP-011 oder einen älteren Paketbaum kopieren.

## Vollständige Abnahme

```powershell
.\TEST_BP-012.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Erwartete neue Ausgaben

```text
MiniQuake BP-012 Protocol 15 server-data verification: PASS
MiniQuake BP-012 Protocol 15 server-data tests passed: 16
```

Alle Elternregressionen müssen ebenfalls grün bleiben:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
MiniQuake BP-011 Protocol 15 command tests passed: 14
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-012 acceptance test: PASS
```

## Nur statische/Oracle-Prüfungen

```powershell
python .\tools\verify.py .
python .\tools\check_protocol15_vectors.py .
python .\tools\check_protocol15_commands.py .
python .\tools\check_protocol15_serverdata.py --root .
```

Ist ein C-Compiler vorhanden, kann die neue Oracle-Kompilierung erzwungen
werden:

```powershell
python .\tools\check_protocol15_serverdata.py `
  --root . `
  --require-c-oracle
```

## Nur Build und assetfreie Tests

```powershell
.\build.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy
```

Dabei müssen fünf Regressionstestprogramme und das neue Serverdatentestprogramm
kompiliert werden. BP-012 löscht vor dem Build alte Zielprogramme und verwendet
für neue Ausgaben zunächst `*.partial.exe`, damit ein fehlgeschlagener Compile
nicht mit einer älteren EXE verwechselt werden kann.

## Ergebnis einsammeln

Unabhängig vom Testergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Erzeugt wird ungefähr:

```text
build\MiniQuake_BP-012_RESULTS_20260724-....zip
```

Das Archiv enthält Logs, JSON-Berichte, Traces und Hashmetadaten, aber keine
PAKs, Maps, Sounds, EXE- oder DLL-Dateien.
