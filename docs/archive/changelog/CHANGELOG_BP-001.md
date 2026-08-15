# MiniQuake BP-001 – Deterministische Diagnosebasis

Datum: 24. Juli 2026  
Elternpaket: `BP-000R1`  
Kompatibilitätsprofil: `compat_109`

## Bestätigte Ausgangsbasis

BP-001 baut bytegenau auf dem vom Anwender getesteten Paket
`MiniQuake_BP000R1_TextBridgeFix_20260724.zip` auf.

Der zurückgelieferte BP-000R1-Test bestand unter Windows vollständig:

- statische Paketprüfung,
- Build von Spiel, 16 Core- und 24 Milestone-Tests,
- alle Core- und Milestone-Tests,
- Paket- und DLL-Identität,
- Echtdatenprüfung mit `id1/start`,
- 120 Headless-Frames,
- Winsock-UDP-Loopback.

Der Ergebnisbericht wird in `docs/BP-000R1_RESULT_ANALYSIS.md` festgehalten.

## Neue Funktionalität

### Deterministischer Frame-Trace

Der neue Befehl

```text
--compat-trace BASE MAP FRAMES PREFIX [-game DIR]
```

führt einen festen Headless-Lauf mit `0.02` Sekunden je Host-Frame aus und
schreibt vier Dateien:

```text
PREFIX.mqtrace
PREFIX-snapshot.json
PREFIX-context.json
PREFIX-summary.json
```

Der kanonische Trace enthält keine Pfade, Heapadressen oder Wanduhrzeiten. Zwei
unabhängige Prozesse mit identischen Daten und Argumenten sollen daher eine
byteidentische `.mqtrace`-Datei erzeugen.

### Zustands-Snapshot

`PREFIX-snapshot.json` enthält einen detaillierten letzten Zustand mit:

- Host-, Server-, Client- und Spielerzustand,
- exakten IEEE-754-binary32-Wörtern,
- QuakeC-Funktions-/Statementkontext und Zustands-Hashes,
- Server-Edicts und Client-Entities,
- Protokoll- und Ressourcen-Snapshots.

Der Befehl `--compat-snapshot` verwendet dieselbe Pipeline und hält den Zustand
nach der angeforderten Zahl fester Frames fest.

### Persistenter Crashkontext

Während eines expliziten Kompatibilitätslaufs wird nach jedem abgeschlossenen
Host-Frame-Abschnitt `PREFIX-context.json` vollständig neu geschrieben. Bei einem
nativen Prozessabbruch bleibt dadurch der zuletzt vollständig abgeschlossene
Schritt erhalten, zum Beispiel `server`, `client_read`, `entity_relink` oder
`screen`.

Im normalen Spielbetrieb bleibt der Diagnosepfad deaktiviert und führt keine
Datei-I/O aus.

### Artefaktprüfung

```text
--compat-report FILE
```

erkennt die vier BP-001-Formate und ermöglicht einen einfachen Rückkanaltest.

## Engine-Änderungen

- `GameSession` erhielt vier ausschließlich diagnostische Felder.
- `_Host_Frame` verwendet eine zyklusfreie Checkpoint-Hilfe, bewahrt aber die
  bisherige `frameTrace`-Reihenfolge.
- Ein FNV-1a-Hash über explizite Little-Endian-Wörter bildet den deterministischen
  Zustandsfingerabdruck.
- Floatwerte werden als exakte 32-Bit-Hexwörter serialisiert; damit entstehen
  keine locale- oder Formatierungsabweichungen.

## Tests und Lieferung

- neuer MiniLang-Test `tests/compat_trace_tests.ml` mit acht Fixtures,
- `build.ps1` kompiliert und startet die Diagnosefixtures zusätzlich,
- `TEST_BP-001.ps1` erzeugt zwei unabhängige Echtdaten-Traces und verlangt
  identische SHA-256-Werte,
- JSON-Schemas, CLI-Berichte und der direkte `--compat-snapshot`-Pfad werden im Pakettest validiert,
- `COLLECT_RESULTS.ps1` sammelt nun auch `.mqtrace`, weiterhin ohne Quake-PAKs,
  Maps, Modelle, Sounds oder Binärdateien.

## Bewusste Abgrenzung

BP-001 verändert keine beabsichtigte Gameplay-, Protokoll-, QuakeC-, Physik-,
Render- oder Audiosemantik. Es stellt das Mess- und Rückmeldesystem für die
folgenden Black-Port-Pakete bereit.
