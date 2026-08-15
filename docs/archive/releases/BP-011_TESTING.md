# BP-011 unter Windows testen

Das vollständige ZIP in einen **neuen, leeren Ordner** entpacken. Nicht über
ein älteres Paket kopieren.

## Vollständige Abnahme

```powershell
.\TEST_BP-011.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Neue Erfolgstore

Die Vorprüfung muss melden:

```text
MiniQuake BP-011 Protocol 15 command verification: PASS
```

Der neue MiniLang-Test muss enden mit:

```text
MiniQuake BP-011 Protocol 15 command tests passed: 14
```

Alle Elternregressionen bleiben verpflichtend:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-011 acceptance test: PASS
```

## Ergebnisarchiv

Unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Erwarteter Name:

```text
build\MiniQuake_BP-011_RESULTS_YYYYMMDD-HHMMSS.zip
```
