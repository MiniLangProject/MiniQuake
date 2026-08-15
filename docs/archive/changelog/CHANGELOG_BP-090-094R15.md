# Changelog BP-090–BP-094R15

## Korrektur

- Original-GLQuake-Captures setzen vor `timedemo` nun `host_framerate 0.02`.
- Original und MiniQuake verwenden dadurch dieselbe Simulationsschrittweite für Damage-Kick, Damage-Cshift und Bonus-Cshift.
- Prozess- und Visual-Summarys dokumentieren die Simulationszeit explizit.
- Der BP-093-Checker bindet die neue Versuchskonfiguration.

## Unverändert

- keine Änderung unter `src/` oder `native/`,
- keine Änderung des SSIM-Grenzwerts,
- keine Bildnormalisierung oder geometrische Nachbearbeitung,
- keine Erweiterung des zeitlichen Suchfensters,
- keine Änderung der bereits grünen bidirektionalen Original-Binary-Interop.
