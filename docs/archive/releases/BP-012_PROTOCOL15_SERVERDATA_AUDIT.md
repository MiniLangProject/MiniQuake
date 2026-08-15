# BP-012 – Protocol-15-Serverdaten-Audit

## Referenz

- WinQuake 1.09 `sv_main.c`
- WinQuake 1.09 `common.c`
- WinQuake 1.09 `protocol.h`

## Funktionszuordnung

| Originalfunktion | MiniLang-Pfad | Evidenz |
|---|---|---|
| `SV_SendServerinfo` | `protocol_serverdata.writeServerInfo`, `SV_SendServerinfo` | zwei Goldenstreams |
| `SV_StartSound` | `protocol_serverdata.writeSound`, `SV_StartSound`, `writeQueuedSound` | drei Goldenstreams und Produktionsfixture |
| `SV_WriteClientdataToMessage` | `protocol_serverdata.writeClientData` sowie beide Produktionswrapper | vier Goldenstreams und zwei Integrationsfixtures |
| `SV_CreateBaseline` | `protocol_serverdata.writeBaseline`, beide Baselinepfade | World-/Player-Goldenstream und Produktionsauswahl |
| `SV_SendClientDatagram` | `appendDatagramIfFits` und Produktionsdatagramme | fünf strikte Grenzfälle |
| `SV_UpdateToReliableMessages` | Reliable-Verteilung in `server.ml` und `sv_main.ml` | Laufzeitfixture |
| `SV_SendClientMessages` | Initial-/Reliable-Planer und Produktionsschleifen | 14 Planfälle und Laufzeitpfad |
| `SV_CleanupEnts` | `cleanupMuzzleFlashes` / `SV_CleanupEnts` | Laufzeitfixture |
| `SV_WriteEntitiesToClient`-Gate | `protocol_update.encodedSize/canWrite` | sechs Größen-/Grenzfälle |

## Bytevektoren

Das Golden-Dokument enthält elf vollständige Payloads:

1. Coop-Serverinfo
2. Deathmatch-Serverinfo
3. Sound mit C-`int`-/C-`float`-Defaultkonvertierung
4. Sound mit optionaler Lautstärke/Dämpfung und Long-Entity
5. Sound-Dämpfung knapp über `1.0`, die am C-`float`-Eingang auf `1.0f` rundet
6. minimales Stock-Clientdata
7. vollständiges Stock-Clientdata mit C-Byte-/Short-Wrapping
8. Mission-Pack-Clientdata
9. Mission-Pack-Clientdata mit leerem Waffenbitfeld
10. World-Baseline
11. Player-Baseline

Das eigenständige C-Oracle implementiert dieselben C-Schreibregeln in einem
isolierten Programm. Der Pythonprüfer erzeugt die Vektoren unabhängig und
vergleicht Dokument, Oracle, Konstanten und MiniLang-Quellverträge.

## Clientdata-Bitregeln

`SU_ITEMS` und `SU_WEAPON` sind immer gesetzt. Weitere Bits werden nur gesetzt,
wenn die Werte von ihren Defaultwerten abweichen. Punchwinkel werden als Char,
Velocityachsen nach Division durch 16 als Char geschrieben. Health ist ein
Short; Munitions-, Armor-, Frame- und Modellwerte folgen den C-Cast-/Byte-Regeln
auf der bereits in BP-010 abgesicherten Message-Schicht.

Das Feld `items2` wird bei vorhandenem QuakeC-Field um 23 Bits verschoben und
mit `items` verknüpft. Ist das Field nicht vorhanden, werden `serverflags` um 28
Bits verschoben, wie im Nicht-QUAKE2-Zweig des Originals.

## Serverinfo

Die erste Print-Zeile beginnt mit Byte 2 und enthält die Version 1.09 sowie den
`progs.dat`-CRC. Precachelisten beginnen bei Index 1 und enden mit einem
NUL-String. Danach folgen Trackbyte zweimal, View-Entity und Signonstufe 1.

## Sound

Die Soundmaske setzt `SND_VOLUME` bei Lautstärke ungleich 255 und
`SND_ATTENUATION` bei Dämpfung ungleich 1.0. Entitynummer und Kanal werden als
`(entity << 3) | channel` gepackt. Das Zentrum ist
`origin + 0.5 * (mins + maxs)`.

Wie beim C-Aufruf werden Kanal und Lautstärke zunächst in C-`int` konvertiert;
Dämpfung wird bereits am Funktionseingang auf IEEE-754-Binary32 gerundet. Erst
diese konvertierten Werte entscheiden über Validierung und optionale Feldbits.
Danach wird die Dämpfung mit 64 multipliziert; die allgemeine Message-Schicht
übernimmt das abschließende C-Integer-/Byte-Verhalten. Der Default-Goldenfall
verwendet absichtlich `2.9`, `255.9` und `1.0000000298023224`, die beim C-Aufruf
zu `2`, `255` und exakt `1.0f` werden.

## Baselines

Die Baseline überträgt Modellindex, Frame, Colormap, Skin und drei Paare aus
Coord/Angle. Effects gehören zum internen Delta-Baselinezustand, werden im
`svc_spawnbaseline`-Payload aber nicht serialisiert.

## Datagramm- und Updategrenzen

Der globale Serverdatagrammrest wird nur angefügt, wenn

```text
destination.curSize + source.curSize < destination.maxSize
```

gilt. Gleichheit wird wie im Original verworfen.

Das Original stoppt Entityupdates, sobald weniger als 16 Bytes frei sind. Ein
Long-Entity-Maximalupdate kann theoretisch 18 Bytes benötigen. MiniQuake prüft
deshalb zusätzlich die exakte Größe. Diese Schutzmaßnahme ändert keine gültige
Wirefolge, verhindert aber den historischen potenziellen Out-of-bounds-Write.

## Paketplanung

Der Initialplan unterscheidet:

- gespawnter Client: Unreliable-Frame plus Reliable-Phase,
- ungespawnter Client mit angeforderter Signonstufe: Reliable-Phase,
- ungespawnter Client ohne Signonanforderung: nach mehr als fünf Sekunden NOP,
  sonst Warten.

Der Reliable-Plan priorisiert Messageoverflow, wartet auf Sendefähigkeit,
behandelt `dropasap` und sendet ansonsten den zuverlässigen Puffer. Nach
Erfolg werden Puffer, Last-Message-Zeit und Signonflag aktualisiert. Muzzleflash
wird erst nach der vollständigen Clientschleife entfernt.

## Abnahmegrenze

Die statische/C-Oracle-Evidenz belegt die isolierten Wire- und Planungsregeln.
Die endgültige Runtime-Abnahme erfolgt mit `TEST_BP-012.ps1` auf Windows und
muss zusätzlich alle BP-011-Regressionsgates, Echtdatenlauf, deterministische
Traces und UDP-Loopback bestehen.
