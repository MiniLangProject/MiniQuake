# BP-012R1 – Windows-Abnahme

BP-012R1 ist ein enger Hotfix für die PlayerState-zu-Protocol-15-Adaptergrenze.
Das Paket muss in einen neuen, vollständig leeren Ordner entpackt werden.

## Vollständiger Test

```powershell
.\TEST_BP-012R1.ps1 `
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
[PASS] protocol15_player_ground_adapter_contract
```

Der bisherige BP-012-Abbruchpunkt muss nun ohne Fehler durchlaufen:

```text
[19/24] client inventory/view weapon protocol
```

ohne anschließende Fehlermeldung. Danach muss die neue Fixture enden mit:

```text
MiniQuake BP-012R1 Protocol 15 server-data tests passed: 17
```

## Vollständige erwartete Regression

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R3 diagnostics tests passed: 10
MiniQuake BP-010R1 Protocol 15 wire tests passed: 15
MiniQuake BP-011 Protocol 15 command tests passed: 14
MiniQuake BP-012R1 Protocol 15 server-data tests passed: 17
byte-identical trace comparison: PASS
MiniQuake UDP loopback smoke
  result=PASS
MiniQuake BP-012R1 acceptance test: PASS
```

## Rückkanal

Unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Das Ergebnisarchiv heißt ungefähr:

```text
build\MiniQuake_BP-012R1_RESULTS_20260725-....zip
```

Es enthält Logs, Reports, Traces und Hashes, aber keine Quake-Spieldaten und
keine Binärdateien.
