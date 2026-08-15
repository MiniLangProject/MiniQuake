# BP-001 Trace-, Snapshot- und Crashkontextformat

> **BP-001R3:** Schema und kanonische Feldreihenfolge bleiben bei Version 1.
> Headless-Traces pollten in BP-001R2 noch live Desktop-Tasten; BP-001R3
> isoliert externe Eingaben und ergänzt einen separaten feldweisen
> Tracevergleich. Gegenüber BP-001R1 ist die Implementierung außerdem für sparse
> Client-Entity-Tabellen sicher. Unbelegte Slots erscheinen im Snapshot als
> JSON-`null`; der kanonische Hash berücksichtigt Tabellenlänge, Slotindex und
> Belegungsmarke.

## Ausgabesatz

Für den Präfix `build/bp001r3-traces/run-a` entstehen:

```text
run-a.mqtrace
run-a-snapshot.json
run-a-context.json
run-a-summary.json
```

Alle Formate tragen Schema `1`. Erweiterungen innerhalb eines Schemas dürfen
nur additiv erfolgen; inkompatible Änderungen benötigen eine neue Schemanummer.

## `.mqtrace`

Die erste Zeile enthält Metadaten:

```text
MiniQuakeCompatTrace|schema=1|package=BP-001R3|profile=compat_109|...
```

Danach folgt bei einem erfolgreichen Lauf genau eine kanonische Zeile pro
angefordertem Frame. Werte werden in fester Feldreihenfolge geschrieben.
Binary32-Werte erscheinen als acht Hexziffern ihrer exakten IEEE-754-Bits.
Textwerte, die in einer Tracezeile vorkommen, werden als UTF-8-Hex geschrieben.

Jede Framezeile enthält unter anderem:

- Host-, Server- und Clientzeit,
- Signon- und Spawnzustand,
- Spielerposition, -geschwindigkeit und -winkel,
- Flags, Movetype, Wasserlevel, Items und Waffe,
- QuakeC-Funktion, Statement und Calltiefe,
- Hashes über QuakeC-Globals/-Edicts,
- Hashes über Server-Edicts und Client-Entities,
- Hash über ausstehende Protocol-15-Puffer,
- Hash über die abgeschlossenen Host-Frame-Schritte,
- abschließenden `state_hash`.

Nicht enthalten sind:

- Wanduhrzeit,
- Prozess- oder Heapadressen,
- absolute Ausgabe- oder Installationspfade,
- Quake-Assetbytes.

Dadurch ist ein bytegenauer Vergleich zweier unabhängiger Läufe möglich.

### Client-Entity-Digest

`client.entities` ist eine logisch nach Entitynummer indizierte, sparse Tabelle.
`CL_EntityNum` erweitert sie bei Bedarf mit `void`, bevor die angeforderte
Entity angelegt wird. Der Digest kodiert daher in dieser Reihenfolge:

1. Tabellenlänge,
2. für jeden Slot den Slotindex,
3. eine Belegungsmarke (`0` leer, `1` belegt),
4. nur bei belegten Slots die kanonischen Entityfelder.

Damit unterscheiden sich beispielsweise `[entity0, entity2]` und
`[entity0, void, entity2]`, obwohl die belegten Datensätze gleich sein können.

### Klassifizierte Fehlerzeile

Scheitert die kanonische Zustandsbildung nach einem abgeschlossenen Host-Frame,
schreibt BP-001R2 nach Möglichkeit eine Zeile dieses Formats:

```text
error_frame=N|last_stage=trace_canonical|message_hex=...
```

Der Fehlertext ist UTF-8-Hex, damit Zeilenstruktur und Vergleichbarkeit erhalten
bleiben. Ein solcher Trace gilt als fehlgeschlagen und hat nicht die normale
Anzahl von Framezeilen.

## `-snapshot.json`

Schema:

```text
MiniQuakeSnapshot/1
```

Der Snapshot enthält einen detaillierten letzten beobachteten Enginezustand,
Server-Edicts, Client-Entities, QuakeC-Hashes und Ressourcenmesswerte. Er dient
der Diagnose nach dem ersten unterschiedlichen Traceframe; er ist nicht das
primäre bytegenaue Vergleichsformat.

`client_entities` ist ein positionsgetreues Array. Ein JSON-`null` bedeutet,
dass die entsprechende Entitynummer im Client nicht belegt ist. Belegte Slots
enthalten weiterhin die bekannten Entityobjekte. Dadurch bleibt
`Arrayindex == Entitynummer` auch in Diagnoseartefakten erhalten.

## `-context.json`

Schema:

```text
MiniQuakeCrashContext/1
```

Diese Datei wird während eines expliziten Trace-Laufs nach jedem abgeschlossenen
Host-Abschnitt vollständig überschrieben. Nach einem harten Prozessabbruch
enthält sie normalerweise den zuletzt vollständig geschriebenen Checkpoint.
Ein Abbruch genau während des Dateischreibens kann eine unvollständige Datei
hinterlassen.

Host-Schritte umfassen unter anderem:

```text
before_filter, filter, commands, net_poll, server, host_time,
client_read, entity_relink, client_events, view, screen, audio, complete
```

BP-001R2 ergänzt danach Post-Frame-Schritte, ohne sie in den eigentlichen
Host-Stages-Hash aufzunehmen:

```text
trace_canonical
trace_state_hash
trace_append
trace_rolling_hash
trace_frame_complete
```

Der Kontext enthält außerdem Frame, Map, Spielerzustand, QuakeC-Position und
einen eventuell abgefangenen Fehlertext.

## `-summary.json`

Schema:

```text
MiniQuakeTraceSummary/1
```

Wichtige Felder:

- `ok`
- `frames_requested`
- `frames_written`
- `accepted_frames`
- `rolling_hash`
- `last_stage`
- `error`
- `diagnostic_write_error`
- `clean_shutdown`

Auch ein unerwarteter Diagnosefehler soll in BP-001R2 als reguläres
`CompatibilityTraceResult` mit `ok=false` und nach Möglichkeit als
`-summary.json` zurückkehren, statt als unklassifizierter Prozessabbruch zu
enden.

## Vergleichsregel

Für denselben Paketstand, dieselben Quake-Daten, dieselbe Map und dieselben
Argumente muss SHA-256 über die beiden erfolgreichen `.mqtrace`-Dateien
identisch sein. Bei einer Abweichung werden beide Traces, Snapshots, Kontexte,
Summaries und die separaten Prozesslogs mit `COLLECT_RESULTS.ps1` eingesammelt.
