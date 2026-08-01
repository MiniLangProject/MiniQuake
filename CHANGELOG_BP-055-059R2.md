# MiniQuake BP-055–BP-059R2

## Zweck

R2 korrigiert die vier im BP-055–BP-059R1-Windows-Lauf gefundenen Audiofehler.
Der Lauf erreichte 117/121 Schritte, validierte die installierten Quake-Daten
und absolvierte 300 Headless-Frames.

## Änderungen

### BP-055

- Die `FindChunk`-Fixture bildet nun den Originalablauf ab: zuerst `RIFF`, dann
  `iff_data = 12`, anschließend `fmt ` und `data`.
- Golden- und C-Oracle-Daten binden die Post-`WAVE`-Grenze.

### BP-056

- Die Kanal-0-Fixture erwartet die normale Auswahl nach Restlebenszeit und
  keine Same-Entity-Überschreibung.
- `S_ClearPrecache` wird wie im Original als No-op getestet; Deskriptoren und
  Caches bleiben erhalten.

### BP-059

- Der CD-Infotext bildet `Con_Printf("Volume is %f\n", cdvolume)` mit sechs
  Nachkommastellen nach.
- Die Retail-Evidenz leitet die Kanalzahl aus `stereo + 1` ab.

## Abgrenzung

- Produktionscode geändert: nur `src/miniquake/sound/cd_audio.ml`.
- Native-Code geändert: nein.
- Eingefrorener Audiovertrag oder Fingerprint geändert: nein.
- Anzahl der Audiofixtures geändert: nein; weiterhin 108.
- Lieferrevision: `BP-055-059R2`, Elternrevision: `BP-055-059R1`.
