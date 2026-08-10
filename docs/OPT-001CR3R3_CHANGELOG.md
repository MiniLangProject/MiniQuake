# MiniQuake OPT-001CR3R3 – Changelog

- Behebt die falsche Parameterbindung des CR3R2-Buildstarts.
- Startet `build.ps1` direkt über `powershell.exe -File` mit echten benannten Argumenten.
- Entfernt `-EncodedCommand` und das positionsabhängige Array-Splatting aus dem aktuellen Harness.
- Behält die binärsichere ungepufferte Live-Ausgabe samt Status-JSON bei.
- Buildabhängige Tests bleiben nach einem Buildfehler gesperrt.
- Alle Inline-, Array-Builder-, Trace- und Hotpath-Optimierungen bleiben erhalten.

## UTF-8/BOM packaging hotfix

- Removed the UTF-8 BOM from every MiniLang source file.
- Added a strict preflight that rejects UTF-8/UTF-16 BOMs and invalid UTF-8 before the Windows build.
- `tests/opt001cr3_hotpath_tests.ml` now begins directly with `import`, matching the native compiler's accepted source encoding.
