# MiniQuake BP-010R1 – Compiler-sichere Protocol-15-Kontrollflüsse

Datum: 2026-07-24  
Elternpaket: `BP-010`  
Zielprofil: `compat_109`

## Anlass

Der BP-010-Windows-Lauf bestand Manifest-, ABI-, Diagnose- und Goldenvektor-
prüfungen, brach aber beim ersten MiniLang-Compile mit einer undefinierten
Variablen in `protocol_text.encodeBytes` ab. Die Ursache war ein
zweiglokales temporäres Ergebnis, das außerhalb des inneren `if` gelesen wurde.

## Korrekturen

- `protocol_text.encodeBytes` schreibt U+0080..U+00FF ohne zweiglokalen
  Merge-Temporärwert direkt in den Zielpuffer.
- `sizebuf.printText` verwendet den gemeinsamen Helfer
  `writeEncodedCStringAt`, kehrt aber aus jedem Reservierungszweig direkt
  zurück. Damit wird auch der nächste gleichartige Scopefehler bei `offset`
  vermieden.
- `tools/verify.py` prüft den neuen `protocol15_lexical_scope_contract` und
  erkennt beide ursprünglichen fehlerhaften Kontrollflussmuster.
- Build-, Test- und Rückkanalartefakte tragen die Paketkennung `BP-010R1`.
- `docs/BP-010_RESULT_ANALYSIS.md` dokumentiert die exakte Windows-
  Fehlergrenze und die Klassifikation.

## Semantik

Der Hotfix verändert keine Protocol-15-Bytes, keine Goldenvektoren und keine
Spiel-, QuakeC-, Physik-, Renderer-, Audio- oder Netzwerksemantik. Er macht den
bereits in BP-010 implementierten Wirepfad lediglich mit MiniLangs lexikalischer
Namensauflösung kompilierbar.

## Noch offen

Die Windows-Kompilierung und Laufzeitabnahme der 15 BP-010-Wirefixtures steht
bis zum zurückgelieferten BP-010R1-Ergebnis aus. Danach kann BP-011 beginnen.
