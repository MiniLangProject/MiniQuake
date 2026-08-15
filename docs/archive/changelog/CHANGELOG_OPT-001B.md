# MiniQuake OPT-001B – Fehlerfreiheit

Parent: `OPT-001A`

## Änderungen

- Viewmodel-Depth-Range wird aus dem tatsächlich aktiven GL-Z-Trick-Bereich berechnet und anschließend exakt wiederhergestellt.
- `e1m2`-Renderabbruch durch eine unzulässige `void`-Indexzuweisung in einem leeren BSP-Texturslot behoben.
- Unterwasserflächen werden beim WorldRenderer-Aufbau in einem linearen Leaf-/Marksurface-Durchlauf markiert.
- Handlefolge `278,278,279,279` wird als einmalige Initialisierung mit anschließendem Plateau klassifiziert.
- Neue In-Process-Transition `e1m1 -> e1m2 -> e1m1`.
- Neue Zielgates: 1.000 sichtbare und 10.000 Headless-Frames auf `e1m2`.

## Nicht enthalten

Die breiten Frame-Allokations-, PVS-, Surface-Chain-, QuakeC- und Kollisionsoptimierungen folgen in OPT-001C bis OPT-001E.
