# BP-055–BP-059R1: Windows-Ergebnisanalyse

## Ergebnisgrenze

Das Ergebnisarchiv `MiniQuake_BP-055-059R1_RESULTS_20260728-140756.zip`
besitzt den SHA-256-Wert:

```text
b7849b4a333f77633eb5caf578fda683c40eff3b9384ebe6d0265a981d91df45
```

Der Windows-Lauf kompilierte das Spiel und sämtliche Audiotestprogramme. Von
121 protokollierten Schritten bestanden **117/121**. Installierte Quake-Daten
und 300 Headless-Frames waren erfolgreich. Der Lauf stoppte bei **retail audio evidence A**, bevor Doppeltrace, geerbte Framebuffer-Evidenz und UDP-Loopback
erreicht wurden.

| Gruppe | Ergebnis | Erste Meldung |
|---|---:|---|
| BP-055 Audio Memory | 19/20 | `fmt offset: expected 12, got -1` |
| BP-056 Audio DMA | 20/22 | `channel zero uses lifetime selection: expected true` |
| BP-057 Mixer | 22/22 | PASS |
| BP-058 Win32 Audio | 20/20 | PASS |
| BP-059 Audio Closure | 23/24 | `info text: expected true` |
| Retail-Evidenz A | FAIL | `SoundCache.channels` existiert nicht |

## BP-055: `FindChunk`-Fixture

`FindChunk` aus `snd_mem.c` startet bei `iff_data`. `GetWavinfo` sucht zunächst
`RIFF`, prüft `WAVE` und setzt danach `iff_data` auf Byte 12. Die alte Fixture
suchte `fmt ` direkt ab Offset 0. Dadurch wurde der gesamte RIFF-Container als
ein einzelner Chunk übersprungen. R2 prüft zuerst `RIFF == 0`, setzt
`cursor.iffData = 12` und erwartet anschließend `fmt == 12` sowie `data == 36`.
Der Produktionsparser war bereits korrekt.

## BP-056: Kanal 0 und `S_ClearPrecache`

Im Original überschreibt `entchannel == 0` niemals allein wegen derselben
Entity-/Kanalkombination. Stattdessen gilt die normale Auswahl nach der
kürzesten Restlebenszeit. Die R1-Fixture erwartete fälschlich den bestehenden
Kanal derselben Entity. R2 füllt den dynamischen Pool und bindet ausdrücklich
die kürzeste Restlebenszeit als Auswahlkriterium.

`S_ClearPrecache` ist in `snd_dma.c` eine leere Funktion. Die zweite R1-
Erwartung `precache cleared` war daher ebenfalls falsch. R2 erwartet, dass
Deskriptoren und Caches erhalten bleiben.

## BP-059: CD-Infotext

Das Original verwendet für die Lautstärke:

```c
Con_Printf("Volume is %f\n", cdvolume);
```

`%f` erzeugt sechs Nachkommastellen. Der MiniLang-Pfad verwendete dagegen eine
kompakte `%.9g`-ähnliche Ausgabe und lieferte bei voller Lautstärke `1` statt
`1.000000`. R2 rundet zuerst auf Binary32 und verwendet dann die gemeinsame
sechsstellige Quake-Floatformatierung.

## Retail-Audio-Evidenz

`SoundCache` besitzt die Felder `length`, `loopStart`, `speed`, `width`,
`stereo` und `data`; ein Feld `SoundCache.channels` existiert nicht. Nach dem
Resampling ergibt sich die Kanalzahl aus `stereo + 1`. Die Evidenzfixture
verwendet deshalb nun `cache.stereo + 1`.

## Klassifikation

- drei fehlerhafte Testadapter/Erwartungen: BP-055 und zwei Fälle in BP-056;
- ein echter Produktionsformatierungsfehler: CD-Infotext in BP-059;
- ein fehlerhafter Retail-Evidenzadapter;
- keine Änderung an Native-Bridge, Audio-Fingerprint oder Fixturezahl;
- `audio_109_frozen_v1` bleibt unverändert und wird nach erfolgreicher R2-
  Windows-Abnahme formal bestätigt.
