# MiniQuake BP-001R2 – Sparse-state-sichere Diagnosebasis

Datum: 2026-07-24
Elternpaket: BP-001R1

## Anlass

Der Windows-Lauf von BP-001R1 bestätigte Build, sämtliche Testbinaries,
`id1/start`, 120 Headless-Frames und UDP. Der erste Kompatibilitätstrace brach
nach dem vollständig abgeschlossenen Frame 0 ab. Die Trace-Datei enthielt nur
den Header; der persistente Kontext meldete `last_completed_stage=complete`.

Ursache war die ungeprüfte Dereferenzierung leerer Slots in der absichtlich
sparse aufgebauten Client-Entity-Tabelle.

## Änderungen

### Sparse Client-Entities

- `clientEntitiesHash` hasht jetzt:
  - Tabellenlänge,
  - Slotindex,
  - Belegungsmarke,
  - bei belegten Slots die bisherigen Entityfelder.
- `clientEntitiesJson` serialisiert leere Slots als JSON-`null`.
- Entitynummer und Tabellenindex bleiben dadurch in Snapshots eindeutig.

### Fehlerklassifikation

- `canonicalFrame` wird im echten Tracepfad mit `try(...)` ausgeführt.
- Ein Fehler erzeugt eine `error_frame=...`-Zeile im Trace.
- Der Host wird geordnet heruntergefahren; Summary und Kontext können erzeugt
  werden, statt dass ein ungefangener Runtimefehler den Prozess beendet.
- Eine äußere `runInternal`-Fehlerbarriere erzeugt bei unerwarteter
  Diagnosepropagation eine Emergency-Summary.
- Post-Frame-Stufen (`trace_canonical` bis `trace_frame_complete`) werden im
  Crashkontext persistiert, ohne den ursprünglichen 21-Stufen-Hostdigest zu
  verändern.

### Regressionstests

- Die Diagnose-Suite wächst von 8 auf 9 Fixtures.
- Die neue Fixture enthält führende, innere und nachlaufende `void`-Slots,
  prüft Hashstabilität, Mutationssensitivität, JSON-`null` und die kanonische
  Framebildung.

### Rückkanal

- Trace A, Trace B und der direkte Snapshot-Befehl schreiben eigene Logs.
- R1- und BP-001-Testskripte leiten auf `TEST_BP-001R2.ps1` weiter.
- Der statische Verifier kontrolliert den Sparse-Slot-Vertrag.

### Lokale Abnahme

- Frontend-Parsing: 192/192 MiniLang-Dateien PASS.
- Win64-Codegen: Hauptprogramm, Core-, Milestone- und Diagnosebinaries PASS.
- PowerShell-Strukturprüfung: 6/6 Skripte PASS.
- Eine Windows-Laufzeit wurde lokal nicht ausgeführt.

## Nicht geändert

- Protocol 15
- QuakeC und Edicts
- Host-/Physiksemantik
- Renderer und Audio
- Native Bridges
- Diagnose-Schemaversion 1

## Abnahme

```powershell
.\TEST_BP-001R2.ps1 `
  -Compiler <mlc_win64.py> `
  -StdLib <compiler-root> `
  -QuakeBase <quake-root> `
  -TraceFrames 64 `
  -NetworkTests
```

Danach:

```powershell
.\COLLECT_RESULTS.ps1
```
