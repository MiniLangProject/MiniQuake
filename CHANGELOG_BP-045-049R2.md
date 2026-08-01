# Changelog BP-045–BP-049R2

## Render-evidence fixture hotfix

- Die BP-048-Summary-Fixture prüft JSON nun über `bytes(text)` statt ein
  Stringelement direkt mit dem Bytewert 34 zu vergleichen.
- JSON-Anfang, erstes Anführungszeichen, Dokumentende und abschließender
  Zeilenumbruch werden bytegenau gebunden.
- Der BP-048-Preflight erkennt die frühere fehlerhafte Vergleichsform.
- Die R2-Abnahme verlangt standardmäßig einen gültigen `-QuakeBase` mit
  `id1\pak0.pak`; assetfreie Läufe müssen alle drei Skip-Gates explizit setzen.
- R2-Test-, Collector-, Ledger- und Ergebnisnamen wurden ergänzt.
- Sämtliche historischen BP-012-Collector-Artefakte bleiben erhalten.
- Unter `src/` und `native/` wurde nichts verändert.
