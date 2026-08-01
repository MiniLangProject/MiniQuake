# MiniQuake BP-012 – Changelog

Elternpaket: `BP-011`  
Datum: 2026-07-24  
Profil: `compat_109`

## Ziel

BP-012 gleicht die produktionsnahen Protocol-15-Serverdaten und die
Nachrichtenplanung mit WinQuake 1.09 ab. Referenz sind insbesondere
`sv_main.c`, `common.c` und `protocol.h`.

## Neu und geändert

### Gemeinsame Protocol-15-Serverwriter

Neu ist `src/miniquake/protocol_serverdata.ml`. Das Modul enthält die von
`server.ml`, `sv_main.ml` und den Golden-Fixtures gemeinsam verwendeten Writer
für:

- `SV_SendServerinfo`,
- `SV_StartSound`,
- `SV_WriteClientdataToMessage`,
- `SV_CreateBaseline`,
- die strikte Datagramm-Anfügung,
- die erste und zuverlässige Phase von `SV_SendClientMessages`.

### `svc_serverinfo`

Der Writer überträgt die Versions-/CRC-Zeile, Protocol 15, maximale
Clientanzahl, Coop-/Deathmatchtyp, Levelname, Modell- und Sound-Precachelisten,
CD-Track, View-Entity und Signonstufe 1 in der Originalreihenfolge.

### `svc_sound`

Die Feldmaske für optionale Lautstärke und Dämpfung, Entity-/Kanalpacking,
Soundindex und drei Koordinaten entsprechen dem C-Pfad. Kanal und Lautstärke
durchlaufen vor Validierung und Serialisierung die C-`int`-Grenze; Dämpfung wird
vor Vergleich und Multiplikation mit 64 auf IEEE-754-Binary32 gerundet. Ein
Goldenfall belegt dadurch ausdrücklich, dass `2.9`, `255.9` und ein knapp über
`1.0` liegender Double-Wert am C-Funktionseingang zu `2`, `255` und `1.0f`
werden. Produktionsereignisse speichern die Lautstärke wieder als Quake-Byte
`0..255` statt als normalisierten Wert `0..1`.

### `svc_clientdata`

Implementiert sind alle Stock-Quake-Bits und Felder:

- Viewheight und Idealpitch,
- Ground-/Waterflags,
- Punch- und Velocityachsen,
- Items inklusive `items2` beziehungsweise `serverflags`,
- Weaponframe, Armor, Weaponmodel,
- Health und Munition,
- Stock- sowie Mission-Pack-Codierung der aktiven Waffe.

Im Mission-Pack-Modus emittiert ein leeres Waffenbitfeld wie im C-Original kein
zusätzliches Byte.

### Baselines

Spielerslots verwenden `progs/player.mdl` und ihre Clientnummer als Colormap.
Andere Entities lösen ihr Modell über die Precacheliste auf. `baseline.effects`
bleibt nullinitialisiert; das Feld wird erst von Fast Entity Updates als Delta
verwendet und nicht von `svc_spawnbaseline` übertragen.

### Paketplanung und Overflowgrenzen

- `sv.datagram` und `sv.reliable_datagram` sind nicht überlaufend.
- Der zuverlässige Clientpuffer ist überlaufend, damit die Verbindung
  kontrolliert getrennt werden kann.
- Der globale Datagrammrest wird nur kopiert, wenn die resultierende Größe
  **strictly less than** `MAX_DATAGRAM` ist.
- Der historische 16-Byte-Gate für Fast Updates bleibt erhalten.
- Zusätzlich prüft MiniQuake die tatsächliche Updategröße von bis zu 18 Bytes,
  um den potenziellen C-Pufferüberlauf nicht nachzubilden.
- Keepalive, Signon-Warten, zuverlässiges Senden, `dropasap`, Overflowdrop und
  Muzzleflash-Cleanup folgen der Originalreihenfolge.

### Tests und Oracle

Neu enthalten sind:

- `tests/protocol15_serverdata_tests.ml` mit 16 Laufzeitfixtures,
- `tools/oracle/protocol15_serverdata_oracle.c`,
- `tools/check_protocol15_serverdata.py`,
- `audit/protocol15_serverdata_golden.json`,
- `TEST_BP-012.ps1`.

Die Evidenz umfasst elf Golden-Bytefolgen, sechs Initialplanfälle, acht
Reliable-Planfälle, fünf Datagrammgrenzen, sechs Fast-Update-Größenfälle und 28
Konstanten.

## Bewusste sichere Abweichung

Das originale `SV_WriteEntitiesToClient` prüft pauschal auf 16 freie Bytes,
obwohl ein maximales Long-Entity-Update 18 Bytes benötigt. BP-012 behält die
16-Byte-Planungsgrenze bei, verweigert das Schreiben aber zusätzlich, wenn die
tatsächliche codierte Größe nicht mehr vollständig passt. Gültige Pakete
bleiben unverändert; ein Speicherüberlauf wird nicht reproduziert.

## Nicht Teil von BP-012

Noch nicht vollständig auditiert werden unter anderem:

- `svc_spawnstatic`, `svc_spawnstaticsound` und Partikelpakete,
- Namen-/Farben-/Frag-Updates jenseits des bereits vorhandenen Reliable-Pfads,
- Mehrprozess-Interop mit einem Original-Quake-Client/Server,
- Fault-Injection für Paketverlust und Retransmit.
