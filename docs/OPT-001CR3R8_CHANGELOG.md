# MiniQuake OPT-001CR3R8 – Changelog

## Parent

`OPT-001CR3R7`

## Kartenwechsel

- Der `changelevel`-Pfad erhält vor dem neuen `SV_SpawnServer` dieselbe Sound- und Rendererbereinigung wie der explizite Map-Pfad.
- Alte Mischkanäle werden vor dem synchronen Kartenaufbau gestoppt.
- Map-spezifischer Rendererzustand wird vor dem Laden der Folgewelt verworfen.
- Der Übergangstest verwendet standardmäßig 256 statt 64 Frames pro Abschnitt.

## Audio

- Der Standardwert für `s_mixahead` wird auf 0,35 Sekunden angehoben, damit der Hauptthread bei langsamen sichtbaren Frames seltener den WaveOut-Puffer leer laufen lässt.
- Sichere Append-Schleifen in Audioquellen werden auf direkt dimensionierte Arrays umgestellt.
- Wiederholte Cvar-Abfragen innerhalb desselben Audio-/Frameaufrufs werden lokal wiederverwendet.
- Der Test erzeugt `opt001cr3r8-audio-analysis.json` mit Audioanteil und Starvation-Risiko.

## MiniLang-Hotpaths

- aufeinanderfolgende sichere `array + [item]`-Operationen werden zusammengefasst,
- stabile `len(array)`-Werte werden aus geeigneten Schleifen gezogen,
- bekannte Größen verwenden direkt dimensionierte Arrays,
- kleine reine skalare Funktionen werden selektiv inlined.

### Zusätzliche Inline-Kandidaten

- `traceEnabled` in `src/miniquake/render/gl11.ml` (13 direkte Aufrufe im Quellbaum)
- `nextSequence` in `src/miniquake/net_datagram.ml` (8 direkte Aufrufe im Quellbaum)
- `SCR_IntermissionMode` in `src/miniquake/screen.ml` (7 direkte Aufrufe im Quellbaum)
- `privilegedCommandAllowed` in `src/miniquake/server.ml` (6 direkte Aufrufe im Quellbaum)
- `parameterOffset` in `src/miniquake/quakec/builtins.ml` (6 direkte Aufrufe im Quellbaum)
- `freeHunkBytes` in `src/miniquake/memory.ml` (6 direkte Aufrufe im Quellbaum)

## Renderer

- Ein unverändertes Viewleaf kann den bereits markierten PVS-Zustand wiederverwenden, sofern der bestehende Rendererzustand die erforderlichen Felder bereitstellt.
- Bereits vorhandene Viewmodel-, Underwater- und Trace-Allokationskorrekturen bleiben aktiv.

## Nicht geändert

- Protocol 15,
- QuakeC-Semantik,
- Physik,
- native Bridge-ABI,
- Original-GLQuake-Referenzgrenzen,
- Standard-Fenstermodus aus CR3R6.

## Fenstertitel und Netzwerkindikator

- Der Titel lautet immer `MiniQuake - <FPS> FPS` und klemmt ungültige Werte.
- Das Net-Symbol bleibt im lokalen Spiel und vor dem ersten echten Paket verborgen.
- 22 kleine skalare Hotpath-Helfer werden direkt inlined.
