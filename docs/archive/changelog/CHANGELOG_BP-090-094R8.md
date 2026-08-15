# MiniQuake BP-090–BP-094R8

- Analysiert den vom Windows-Lauf gelieferten `demo1`-Bildsatz ohne die
  Originalbilder in das Paket zu übernehmen.
- Bindet für MiniQuakes Demo-Evidenz die originale Startpalettenoption
  `-gamma 1`; `+gamma 1` allein war nicht äquivalent.
- Stellt GLQuakes roten Clear-Wert `(1,0,0,0)` wieder her.
- Ersetzt den vereinfachten Brush-Entity-Pfad durch die kanonische
  `R_DrawBrushModelForSubmodel`-Implementierung.
- Setzt Brush-Lightmap-Chains pro Modell zurück.
- Verwendet für invertierte LUMINANCE-Lightmaps wieder
  `GL_ZERO / GL_ONE_MINUS_SRC_COLOR`.
- Verwendet `entity.frame` zur Auswahl alternativer animierter Brush-Texturen.
- Behält die Rohbildanforderung SSIM >= 0,95 ohne Bildnormalisierung bei.
- Original-Binary-Interop, Loopback-/Firewall-Harness und Live-Ausgabe aus R7
  bleiben erhalten.
