# MiniQuake BP-020–BP-024R1

Runtime-Korrekturrevision für den kumulativen QuakeC-Block BP-020 bis BP-024.
Der eingefrorene QuakeC-Vertrag und Protocol 15 bleiben unverändert.

## Ergebnisbasis

Ausgewertet wurde `MiniQuake_BP-020-024_RESULTS_20260725-201735.zip`
(SHA-256 `91797f541fbcbe83bd304bcb1d3fcc02551ac6d2c51dce451abda5cc6ac1d5b8`).
Der Build und alle Protocol-15-Regressionsgruppen waren grün. Fehler traten im
großen synthetischen Parserkorpus, einer VM-Fixture, zwei Edict-Fixtures sowie
bei der nicht protokollierten Echtdatenvalidierung auf.

## Produktionskorrekturen

- `format/progs.ml`: Parameterwörter müssen nur bei echten Bytecodefunktionen
  in `locals` liegen. qcc-Builtins mit negativem `first_statement` dürfen ihre
  Signatur bei `locals == 0` behalten.
- `quakec/edict.ml`: Binary32-Werte werden für Save-/Edict-Text aus ihrem rohen
  32-Bit-Wort formatiert. Der Signbitzustand von `-0.0` bleibt erhalten.
- `quakec/edict.ml` und `savegame.ml`: gemeinsame schrittweise
  Quoted-Pair-Serialisierung statt tiefer Inline-Konkatenation.

## Fixturekorrekturen

- Der große synthetische `progs.dat`-Korpus besitzt eine ein Byte große,
  NUL-beginnende Stringtabelle.
- Der Trace-Builtin-Test installiert Builtin `#1` an Index 1 und behält einen
  Fehlerwächter an Index 0.
- Der Negative-Zero-Test konstruiert den Wert aus dem QuakeC-Wort
  `0x80000000`.
- Die Edict-Suite prüft Float-, Vector- und Void-Serialisierung vor dem
  vollständigen `ED_Write` separat.

## Rückkanal

`TEST_BP-020-024R1.ps1` führt Stock-`progs.dat`, installierte Spielvalidierung
und Headless-Runtime als unabhängige Gates aus. Jedes Gate besitzt ein eigenes
Log und läuft bei `-ContinueIndependentTests` nach anderen Fehlern weiter.
