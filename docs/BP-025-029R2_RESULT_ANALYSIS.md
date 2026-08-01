# Auswertung BP-025–BP-029R2

## Ergebnisarchiv

```text
MiniQuake_BP-025-029R2_RESULTS_20260726-101120.zip
SHA-256: b036b509ec770e20407eda763978f32cdda5009d5651369c2916ebe76e9365dc
```

## Gesamtstatus

Der vollständige Windows-Build, alle historischen Protocol-15- und QuakeC-
Regressionen, die installierte Spieldatenprüfung, 300 Headless-Frames, zwei
unabhängige 128-Frame-Traces, der bytegenaue Tracevergleich und UDP-Loopback
waren erfolgreich. Von 67 unabhängigen Abnahmegruppen bestanden 63.

```text
Trace SHA-256: 24830a3e183784de44a9c7261a42cc8e5aebf8fd1c8fdbafc32ea447ee0eba9f
Rolling Hash:  4d8fc98d
```

## Vier Fehlergrenzen

### 1. BP-025 World Trace

```text
FAIL: translated brush hit: translated hit fraction: expected true
```

Die Fixture verwendete für Hull 0 den BSP-Drawing-Node mit Childfolge
`EMPTY, SOLID`, obwohl Kommentar und erwarteter Treffer `SOLID, EMPTY`
verlangten. `createModelHull(..., 0)` nutzt korrekt die Drawing-Nodes, nicht die
separate Clipnode-Tabelle. R3 korrigiert nur den synthetischen Knoten auf
`-2, -1`.

### 2. BP-028 `sv_user`-Winkel

```text
FAIL: move angle y: expected 180., got -180
```

`MSG_ReadAngle` basiert im Original auf `MSG_ReadChar`. Das Wirebyte `0x80`
wird daher als signed char `-128` gelesen und ergibt `-180` Grad. Die Runtime
war korrekt; R3 korrigiert die Erwartung.

### 3. BP-029 erlaubtes Clientkommando und Ping

```text
FAIL: privileged allowed command
FAIL: ping binary32: got 1036831936 expected 1036831949
```

`Cmd_ExecuteString` besitzt im C-Original keine boolesche Handler-Rückgabe. Die
MiniLang-Adapterfunktion darf den Rückgabewert von `Host_Name_f` daher nicht als
Akzeptanzsignal verwenden. R3 dispatcht den Handler und liefert danach `true`.

Beim Ping wird `MSG_ReadFloat()` zuerst als Binary32 dekodiert, zu `double`
promoviert, von `sv.time` abgezogen und anschließend wieder in `float`
gespeichert. R3 bildet genau diese Reihenfolge in Oracle und Fixture ab.

### 4. BP-029 Closure

```text
FAIL: Struct has no member 'nodes'
```

`types.Hull` speichert keine Knotentabelle. Der Box-Hull wird in
`world_hull.pointContentsFromNode` algorithmisch als sechs Knoten dargestellt.
R3 prüft deshalb Knoten 5 als gültig und Knoten 6 als kontrollierten Fehler.

## Klassifikation

Drei Fehler waren ausschließlich veraltete oder falsch konstruierte Fixtures.
Eine kleine Produktionskorrektur normalisiert die Akzeptanz eines erfolgreich
dispatchten, erlaubten Clientkommandos auf die `void`-Semantik des C-Originals.
Der Welt-/Physik-Fingerprint bleibt unverändert.
