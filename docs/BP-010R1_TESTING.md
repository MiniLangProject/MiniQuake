# BP-010R1 unter Windows testen

BP-010R1 ist der compiler-sichere Hotfix für BP-010. Das vollständige ZIP in
einen **neuen, leeren Ordner** entpacken. Nicht über einen älteren MiniQuake-
Baum kopieren.

## Vollständige Abnahme

```powershell
.\TEST_BP-010R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Entscheidend nach dem BP-010-Fehler

Der Spielcompile muss nun über `protocol_text.ml` und `sizebuf.ml` hinauslaufen.
Die Versionsausgabe muss enthalten:

```text
Package: BP-010R1
Parent package: BP-010
Protocol text ABI: quake_latin1_cstring_v1
```

Danach werden weiterhin dieselben 15 Wirefixtures von BP-010 ausgeführt:

```text
MiniQuake BP-010R1 Protocol 15 vector verification: PASS
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
```

Außerdem müssen alle Elternregressionen grün bleiben:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-010R1 acceptance test: PASS
```

## Ergebnisarchiv

Unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Erwarteter Name:

```text
build\MiniQuake_BP-010R1_RESULTS_YYYYMMDD-HHMMSS.zip
```
