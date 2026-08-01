# BP-014R1 – Windows-Abnahme

BP-014R1 ist ein enger Hotfix für die Trennung von gespeichertem Beam-Slot-
Zustand und aktiver Beam-Sicht. Das Paket muss in einen neuen, vollständig
leeren Ordner entpackt werden.

## Vollständiger Test

```powershell
.\TEST_BP-014R1.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Kritische neue Gates

Die statische Prüfung muss enthalten:

```text
[PASS] protocol15_runtime_event_contract
[PASS] protocol15_beam_state_view_contract
```

Der bisherige BP-014-Abbruchpunkt muss nun ohne Fehler durchlaufen:

```text
[12/24] client effects
```

Danach muss die erweiterte Fixture-Suite enden mit:

```text
MiniQuake BP-014R1 Protocol 15 runtime-event tests passed: 28
```

## Vollständige erwartete Regression

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
MiniQuake BP-011 Protocol 15 command tests passed: 14
MiniQuake BP-012R1 Protocol 15 server-data tests passed: 17
MiniQuake BP-013 Protocol 15 event tests passed: 22
MiniQuake BP-014R1 Protocol 15 runtime-event tests passed: 28
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-014R1 acceptance test: PASS
```

## Rückkanal

Unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Ergebnisarchiv heißt ungefähr:

```text
build\MiniQuake_BP-014R1_RESULTS_20260725-....zip
```

Es enthält Logs, Reports, Traces und Hashes, jedoch keine Quake-Spieldaten und
keine erzeugten EXE-/DLL-Dateien.
