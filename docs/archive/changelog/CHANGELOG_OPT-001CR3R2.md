# MiniQuake OPT-001CR3R2 – Changelog

- Behebt den PowerShell-Success-Stream-Fehler des CR3R1-Live-Runners.
- Native Kindprozessausgabe wird live konsumiert und explizit an die Konsole geschrieben.
- `Invoke-ExternalProcessLive` gibt ausschließlich einen einzelnen Integer-Exitcode zurück.
- `run_process_live.py` schreibt zusätzlich einen atomaren Statusbericht je Kindprozess.
- Ein Array statt eines skalaren Exitcodes wird als interner Harnessfehler abgelehnt.
- Alle Inline-, Array-Builder-, Diagnose- und Hotpath-Optimierungen aus CR3R1 bleiben unverändert.
- Engine- und Native-Code sind gegenüber CR3R1 byteidentisch.
## Binary-safe Live-Runner-Hotfix (2026-08-09)

Der zweite CR3R2-Versuch erreichte den Paket-PASS, der Python-Live-Runner brach jedoch beim Start des Build-Kindprozesses mit einer nicht vollständig erhaltenen Traceback-Ausgabe ab. Der Runner leitet Kindprozessdaten nun binär ohne Codepage-Roundtrip weiter, fängt Streamingfehler vollständig ab und schreibt Diagnose sowie Exitcode in `*.status.json`. PowerShell konsumiert den nativen Stream über `Out-Host` bei vorübergehend nicht-terminierender Native-Fehlerbehandlung; der Funktionsrückgabewert bleibt ein einzelner Integer.

