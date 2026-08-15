# MiniQuake BP-090–BP-094R11

## Änderung gegenüber R10

R11 korrigiert die Übergabe der externen Original-GLQuake-Referenz zwischen
PowerShell und `prepare_original_reference.py`.

### Test-Harness

- Referenzauflösung vor UAC-Neustart und langem Build.
- Fallback auf `%USERPROFILE%\Downloads\OriginalQuakeSourceCode.zip`.
- Strikte Ablehnung einer Referenz im MiniQuake-Projektbaum.
- Explizite Weitergabe an den erhöhten Kindprozess.
- Zusätzlicher Environment-Fallback.
- Typisierte Argumentliste mit genau einem `--archive`-/`--exe`-Selektor.
- Maschinenlesbarer Eingabebericht.
- Benannter Aufruf des Live-Prozesshelfers.

### Python-Stagingwerkzeug

- CLI-Schalter bleiben der kanonische Pfad.
- Zusätzliche Unterstützung für `MINIQUAKE_ORIGINAL_SOURCE` und
  `MINIQUAKE_ORIGINAL_EXE`.
- Ablehnung mehrdeutiger Environmentquellen.
- Ausgabe und Bericht des tatsächlich verwendeten Selektors.

### Unverändert

- kein Enginecode unter `src/`,
- kein nativer Code unter `native/`,
- keine Änderung der R8-Visual-Parity,
- keine Änderung der R9-Provenienzprüfung,
- keine Änderung der R10-Readinessprobe,
- keine Änderung der Kompatibilitätsfingerprints.
