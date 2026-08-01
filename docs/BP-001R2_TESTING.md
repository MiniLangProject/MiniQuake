# BP-001R2 unter Windows testen

BP-001R2 repariert den ersten echten BP-001R1-Traceabbruch bei sparse
Client-Entities. Das Paket bitte in einen neuen, leeren Ordner entpacken.

## Vollständige Abnahme

```powershell
.\TEST_BP-001R2.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Game id1 `
  -Map start `
  -Frames 120 `
  -TraceFrames 64 `
  -NetworkTests
```

## Erwartete frühe Prüfungen

Der Verifier muss insbesondere melden:

```text
[PASS] bp001r2_diagnostics_contract
[PASS] diagnostic_serialization_contract
[PASS] compiler_safe_diagnostic_expressions
[PASS] sparse_client_entity_diagnostics
```

Die assetfreien Tests müssen enden mit:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
MiniQuake BP-001R2 diagnostics tests passed: 9
```

Fixture 09 prüft eine Tabelle mit führenden, inneren und nachlaufenden
`void`-Slots. Sie muss vor dem Echtdatenlauf grün sein.

## Entscheidend für die Abnahme

Der frühere Lauf brach bei `deterministic compatibility trace A` direkt nach
Frame 0 ab. BP-001R2 muss nun:

1. Trace A mit 64 Framezeilen plus Header, also insgesamt 65 Zeilen, abschließen,
2. Trace B in einem unabhängigen Prozess abschließen,
3. beide `.mqtrace`-Dateien byteidentisch erzeugen,
4. gültige Snapshot-, Context- und Summary-Dateien schreiben,
5. den direkten `--compat-snapshot`-Pfad abschließen.

Bei erfolgreichem Lauf muss die Zusammenfassung außerdem
`frames_written=64`, `ok=true` und identische `rolling_hash`-Werte für A und B
melden.

Das erwartete Ende lautet:

```text
MiniQuake BP-001R2 acceptance test: PASS
```

## Zusätzliche Logs

Auch bei einem sehr frühen Tracefehler werden nun separat gesammelt:

```text
build\bp001r2-trace-a.log
build\bp001r2-trace-b.log
build\bp001r2-snapshot-command.log
build\bp001r2-traces\...
```

Ein kanonischer Fehler wird außerdem als Zeile nach dem Traceheader geschrieben:

```text
error_frame=N|last_stage=...|message_hex=...
```

## Rückmeldearchiv

Nach dem Test, unabhängig vom Ergebnis:

```powershell
.\COLLECT_RESULTS.ps1
```

Das erzeugte Archiv heißt ungefähr:

```text
build\MiniQuake_BP-001R2_RESULTS_20260724-....zip
```

Es enthält Logs, JSON und `.mqtrace`, aber keine EXEs, DLLs oder Quake-
Spieldaten. Hashes der Binärartefakte stehen nur in `environment.json`.
