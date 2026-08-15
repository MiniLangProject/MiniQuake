# MiniQuake OPT-001CR3R8 – Ergebnis- und Änderungsanalyse

## Elternbasis OPT-001CR3R7

Der hochgeladene CR3R7-Lauf bestand Build, Korrektheitsmatrix, e1m2-Langläufe und Kartenwechsel. Gegen die OPT-001B-Ausgangsbasis erreichte er das Performanceziel. Die direkte CR2-Vergleichsmessung schwankte, während die Audioanalyse den Engpass klar dem langsamen Renderpfad und nicht der Mixer-CPU-Zeit zuordnete.

Gemessene CR3R7-Renderwerte:

- e1m1: Median 63 ms, P99 93 ms
- e1m2: Median 63 ms, P99 79 ms
- Audioanteil: unter 0,01 % der gemessenen Framezeit
- Klassifikation: `FRAME_STARVATION_RISK`

## Ziel von CR3R8

CR3R8 reduziert weitere MiniLang-Aufrufkosten über 22 kleine direkte Inlinefunktionen, behält den Same-Leaf-PVS-Cache und die frame-lokalen Cvarwerte bei und versorgt die Audioqueue vor dem teuren Renderabschnitt. `_snd_mixahead` wird standardmäßig auf 0,35 Sekunden gesetzt.

Zusätzlich werden zwei langjährige UI-Probleme geschlossen:

- Der Netzwerkindikator wird vor dem ersten Paket sowie im lokalen Einzelspieler-/Listen-Server-Fall nicht gezeichnet.
- Der Fenstertitel lautet vom Erstellen des Fensters an `MiniQuake - <FPS> FPS`; ungültige und negative Werte werden geklemmt.

Die tatsächliche Win64-Kompilierung, Laufzeit und Performancewirkung bleibt Gegenstand des Windows-Akzeptanzlaufs.
