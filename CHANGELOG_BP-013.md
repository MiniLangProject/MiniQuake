# MiniQuake BP-013 Changelog

Datum: 2026-07-25  
Elternpaket: `BP-012R1`  
Zielprofil: `compat_109`

## Zweck

BP-013 portiert die noch offenen Protocol-15-Pfade für statische Entities,
statische Sounds, Partikel, zuverlässige Scoreboardupdates und den geordneten
Client-Disconnect. Der originale C-Code aus `sv_main.c`, `host.c`,
`host_cmd.c`, `pr_cmds.c` und `r_part.c` dient als verbindliche Spezifikation.

## Neue gemeinsame Protocol-Schicht

Neu ist `src/miniquake/protocol_events.ml`. Das Modul enthält gemeinsame Writer
und Konvertierungsgrenzen für:

- `svc_spawnstatic`,
- `svc_spawnstaticsound`,
- `svc_particle`,
- `svc_updatename`,
- `svc_updatefrags`,
- `svc_updatecolors`,
- Scoreboard-Reset,
- `svc_disconnect`.

Die integrierte Serverpipeline, das direkte `sv_main`-Pendant und die
QuakeC-Builtins verwenden dadurch dieselben Wirewriter.

## Originalgetreue Details

- `PF_ambientsound` multipliziert Volume und Attenuation als Binary32 und
  übergibt den anschließend gegen null abgeschnittenen Wert an `MSG_WriteByte`.
  Es findet wie im Original keine zusätzliche Klammerung statt.
- `SV_StartParticle` übernimmt das historische Gate
  `cursize <= MAX_DATAGRAM-16`.
- Partikelrichtungen werden als Binary32 mit 16 multipliziert, gegen null
  abgeschnitten und auf signed Char `-128..127` geklammert.
- Der Wirewert 255 für die Partikelzahl wird beim Client zu 1024 erweitert.
- Playernamen werden auf 15 Quake-Einbytezeichen begrenzt; erweiterte Bytes
  `0x80..0xff` bleiben über die bestehende Latin-1-Protokoll-ABI erhalten.
- `client_t.old_frags` bleibt Integer. Beim Vergleich mit dem QuakeC-Float wird
  der Integer wie in C zuerst zu Binary32 konvertiert. Der neue Wert wird beim
  Speichern wieder gegen null abgeschnitten.
- `Host_Spawn_f` schreibt den bereits gespeicherten `old_frags`-Wert.
- Ein geordneter Drop hängt `svc_disconnect` an bereits ausstehende Reliable-
  Daten an, sendet genau diese Nachricht, schließt anschließend die Verbindung
  und setzt Name, Frags und Farben bei allen verbleibenden aktiven Clients
  zurück.

## Clientparser

`client_protocol.readParticle` bildet `msgcount == 255` nun auf 1024 Partikel
ab, entsprechend `R_ParseParticleEffect` im Original.

## Tests und Evidenz

Neu enthalten:

- `tests/protocol15_event_tests.ml` mit 22 MiniLang-Fixtures,
- `tools/oracle/protocol15_events_oracle.c`,
- `tools/check_protocol15_events.py`,
- `audit/protocol15_events_golden.json`,
- ein neuer statischer Verifiervertrag `protocol15_event_contract`,
- `TEST_BP-013.ps1` und erweiterte Build-/Ergebniswerkzeuge.

Der C-Oracle- und Python-Vektorsatz enthält 15 vollständige Wirepayloads und 13
semantische Grenzfälle. Die Windows-Laufzeitabnahme der 22 MiniLang-Fixtures ist
noch ausstehend.

## Nicht geändert

BP-013 ändert keine Diagnoseformate, keine Physik-, QuakeC-Opcode-, Render-,
Audio-, Demo- oder Savegameformate. Die Protocol-Text-ABI bleibt:

```text
quake_latin1_cstring_v1
```
