# MiniQuake BP-025–BP-029R3

## Zweck

BP-025–BP-029R3 korrigiert die vier voneinander unabhängigen Abweichungen, die
im vollständigen Windows-Lauf von BP-025–BP-029R2 sichtbar wurden. Der R2-Lauf
baute alle Ziele, validierte die installierten Quake-Daten, lief 300 Headless-
Frames, erzeugte zwei byteidentische 128-Frame-Traces und bestand UDP-Loopback.
Von 67 unabhängigen Abnahmegruppen bestanden 63.

## Änderungen

### BP-025: synthetischer Brush-Hull

Der Test-BSP-Knoten ordnet nun Child 0 dem soliden und Child 1 dem leeren Blatt
zu (`-2, -1`). Damit entspricht das synthetische Hull-0-Modell der im Test
beschriebenen Halbebene. Der Produktions-Tracecode war bereits korrekt.

### BP-028: signed `MSG_ReadAngle`

Die Fixture erwartet für das Wirebyte `0x80` nun `-180.0`. WinQuake liest den
Winkel über `MSG_ReadChar`, also als vorzeichenbehaftetes Byte.

### BP-029: Clientkommando-Rückgabe

Ein erlaubtes Clientkommando gilt nach erfolgreichem Dispatch als angenommen,
unabhängig vom Komfort-Rückgabewert des konkreten MiniLang-Handlers. Das bildet
die `void`-Semantik von `Cmd_ExecuteString` im C-Original ab; propagierte
Runtimefehler bleiben Fehler.

### BP-029: Ping-Binary32-Grenze

Der erwartete Ping wird aus dem tatsächlich über das Protokoll dekodierten
Binary32-Clientzeitwert gebildet. Dies entspricht `double sv.time - float
MSG_ReadFloat()`, anschließend gespeichert in einem `float`-Pingring.

### BP-029: algorithmischer Box-Hull

Die Closure-Fixture greift nicht mehr auf ein nicht existentes `Hull.nodes`-
Feld zu. Sie prüft stattdessen den letzten gültigen Startknoten 5 und den ersten
ungültigen Startknoten 6 über `pointContentsFromNode`.

## Unverändert

- Protocol-15-Vertrag und Fingerprint
- QuakeC-1.09-Vertrag und Fingerprint
- Welt-/Physik-Vertrag `world_physics_109_frozen_v1`
- Welt-/Physik-Fingerprint `0x2235d77c`
- Fixturezahlen der acht Welt-/Physik-Testprogramme
- Native Bridges und ABI
