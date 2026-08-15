# BP-045–BP-049R1 – Ergebnisanalyse

## Ergebnis

Der Windows-Lauf kompilierte den vollständigen BP-049-Stand und führte alle
assetfreien Testgruppen aus. Von 108 protokollierten Schritten waren 96 grün,
11 wegen fehlendem `-QuakeBase` übersprungen und genau eine Gruppe rot:

```text
[BP-048] deterministic render evidence
FAIL: summary JSON: expected true
MiniQuake BP-048 render evidence tests failed: 17/18
```

Der seit BP-040–BP-044R3 aktive Runtime-Logchecker erkannte den Fehler korrekt,
obwohl das historische Top-Level-Testprogramm danach noch seine alte
Erfolgsmeldung ausgab.

Ergebnisarchiv:

```text
MiniQuake_BP-045-049R1_RESULTS_20260727-221019.zip
SHA-256: 2aef7b2b8eacd19f8c17c4883ade88644dc61a2a1232fb8b60bcd8720e9393a5
```

## Ursache

Die Fixture prüfte den zweiten Inhalt eines MiniLang-Strings direkt gegen den
Bytewert 34:

```ml
text[1] == 34
```

MiniLang-Stringindexierung ist keine Byte-Schnittstelle. Für eine
reproduzierbare JSON-Syntaxprüfung muss der Text ausdrücklich über
`bytes(text)` in UTF-8-Bytes umgewandelt werden. Der produktive
`summaryJson(...)`-Writer selbst war nicht die Ursache; alle anderen
BP-048-Fixtures und die statische Schema-Prüfung bestanden.

## R2-Korrektur

Die Fixture bindet nun die tatsächlichen Bytes:

```ml
encoded = bytes(text)
encoded[0] == 123
encoded[1] == 34
encoded[len(encoded) - 2] == 125
encoded[len(encoded) - 1] == 10
```

Damit werden öffnende Klammer, erstes JSON-Anführungszeichen, schließende
Klammer und abschließender Zeilenumbruch geprüft. Der BP-048-Checker lehnt die
frühere String-vs.-Integer-Prüfung künftig schon im Preflight ab.

## Nicht ausgeführte Echtdaten-Gates

Im R1-Lauf wurde no `-QuakeBase` supplied; die Summary enthält
`base_supplied=false`. Deshalb waren folgende Gates `SKIPPED`:

- Stock-`progs.dat` und installierte Quake-Daten,
- 300 Headless-Frames,
- beide 128-Frame-Traces und Snapshotprüfung,
- beide 640×480-Framebuffer-Captures und SSIM-Vergleich.

R2 verlangt für eine normale Abnahme nun einen gültigen `-QuakeBase` mit
`id1\pak0.pak`. Ein absichtlich assetfreier Diagnoselauf ist nur noch möglich,
wenn alle drei Skip-Schalter ausdrücklich gesetzt werden.

## Abgrenzung

Unter `src/` und `native/` wurde nichts verändert. Sämtliche eingefrorenen
Engineverträge und der Model-/UI-/Render-Fingerprint `0x0a62f5b1` bleiben
unverändert.
