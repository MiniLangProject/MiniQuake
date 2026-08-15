# MiniQuake OPT-001CR3R6 – Ergebnisanalyse

Das hochgeladene Ergebnisarchiv trägt äußerlich einen CR3R4-Namen, enthält aber den Lauf der Lieferung `OPT-001CR3R5`. Der Paketverifier war grün; der Spielbuild brach beim Parsen von `src/main.ml` ab.

Die erste echte Diagnose lautet:

```text
ParseError: Expected KW then, got NL
  at src/main.ml:559:36
  if arguments[index] == expected
```

Die R5-Fensterhelfer enthielten drei Block-`if`-Anweisungen ohne `then`. Der Ansatz war außerdem semantisch ungeeignet: Das Anhängen von `-window` an das globale Argumentarray vor der Kommandoauswertung verändert die Argumentzahl von Diagnose- und `--play`-Kommandos.

OPT-001CR3R6 entfernt diese Argumentmutation vollständig und setzt den Fenstermodus an der Videoauswahl in `VID_FindRequestedMode`. Ohne expliziten Fullscreen-Selektor startet ein interaktiver Lauf im Fenster; `-fullscreen`, `-mode`, `-current`, `-bpp` und `-force` bleiben autoritativ.

Aus dem letzten vollständigen CR3R4-Lauf werden gleichzeitig zwei echte Folgeprobleme geschlossen: Die historische OPT-001C-Vertragsidentität wird von der aktuellen Lieferidentität getrennt, und map-eigener Renderer-Kompatibilitätszustand wird beim Destroy zurückgesetzt, damit `e1m1 -> e1m2 -> e1m1` kein veraltetes Surface-/Lightmap-State übernimmt.

Der feste Vergleich gegen OPT-001B bleibt ein hartes Performancegate. Der direkte Wallclock-Vergleich gegen CR2 bleibt sichtbar, wird wegen der starken Lauf-zu-Lauf-Streuung aber nur diagnostisch bewertet.

Ergebnisarchiv SHA-256: `9e01b7c03601080191146bcea2e9e76846fd77e258c8ce24acf9df22ef73acbb`.
