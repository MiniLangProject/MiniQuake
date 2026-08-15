# BP-010 unter Windows testen

Das vollständige ZIP in einen neuen, leeren Ordner entpacken. Nicht über einen
älteren MiniQuake-Baum kopieren.

## Vollständige Abnahme

```powershell
.\TEST_BP-010.ps1 `
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
MiniQuake BP-010 Protocol 15 vector verification: PASS
MiniQuake BP-010 Protocol 15 wire tests passed: 15
Protocol text ABI: quake_latin1_cstring_v1
```

Die bisherigen Regressionen müssen ebenfalls bestehen:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke ... result=PASS
MiniQuake BP-010 acceptance test: PASS
```

## Nur statische und Golden-Prüfung

```powershell
python .\tools\verify.py .
python .\tools\check_protocol15_vectors.py .
```

Ist ein C-Compiler auf `PATH`, baut und startet der zweite Befehl zusätzlich das
C-Oracle. Ohne C-Compiler bleibt die paketierte Oracle-Quelle durch ihren
SHA-256-Wert gebunden und das unabhängige Pythonmodell wird ausgeführt.

## Ergebnisarchiv

Unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Erwarteter Name:

```text
build\MiniQuake_BP-010_RESULTS_YYYYMMDD-HHMMSS.zip
```

Das Archiv enthält Logs, JSON-Berichte und Traces, aber keine Quake-Spieldaten
und keine Binärdateien. Die Binärhashes werden nur in `environment.json`
protokolliert.
