# BP-090–BP-094R8 – Analyse des R7-Bildvergleichs

R7 hat die bidirektionale Original-Binary-Interoperabilität vollständig
bestanden. Der verbliebene Fehler lag im Rohbildvergleich von `demo1`. Das
Diagnosearchiv enthielt zwei byteidentische Originalbilder und fünf
MiniQuake-Kandidatenframes.

## Messbefund

```text
bester R7-Frame: 254
Rohbild-SSIM: 0.5773750816123187
Original-Unterkante (48 Zeilen): 255,0,0
MiniQuake-Unterkante (48 Zeilen): 0,0,0
obere statische Wand nach angenäherter Gamma-Korrektur: SSIM 0.936704
Plattform-Luminanzkorrelation nach Gamma-Korrektur: -0.547846
```

Die Kanten der Weltgeometrie, des Zielrahmens und des Viewmodels liegen bereits
weitgehend deckungsgleich. Der Fehler ist daher kein grundlegender Kamera- oder
Projektionsfehler. Drei konkrete Abweichungen erklären das Bild:

1. **Startpalettengamma:** Das Original wurde mit `-gamma 1` gestartet.
   MiniQuake setzte lediglich die spätere Cvar `+gamma 1`; seine Texturpalette
   wurde deshalb beim Video-Start mit dem Nicht-3Dfx-Standard `0.7` aufgehellt.
2. **Clear-Farbe:** Beide GL-Initialisierungen setzen Rot, aber MiniQuakes
   `renderViewport` überschrieb dies pro Frame mit Schwarz.
3. **Brushmodelle:** Der vereinfachte Entity-Renderer multiplizierte die bereits
   invertierten LUMINANCE-Lightmaps mit `GL_SRC_COLOR`. Die Plattform zeigt
   deshalb genau die gemessene negative Helligkeitskorrelation. Derselbe Pfad
   ignorierte `entity.frame` und zeigte beim Wandtaster die falsche alternative
   Animationsfolge.

Der beste Kandidat `254` bei Originalframe `256` ist erwartbar: Der originale
`screenshot`-Befehl läuft vor der nächsten Bildschirmaktualisierung und liest
im Double-Buffer-Betrieb den vorherigen Backbuffer. Der Suchradius wird daher
nicht aufgeweicht.

R8 korrigiert diese drei Pfade, ohne den SSIM-Grenzwert zu senken, Bilder zu
normalisieren oder Originaldaten in das Paket zu übernehmen.
