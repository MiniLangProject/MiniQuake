# MiniQuake OPT-001CR3R2 – Auswertung des CR3R1-Laufs

CR3R1 führte ausschließlich die Paketprüfung aus. Diese bestand vollständig. Der Runner behandelte das Ergebnis dennoch als Fehler, weil die live weitergereichten Textzeilen des nativen Pythonprozesses zusammen mit dem abschließenden Exitcode in die PowerShell-Funktionsausgabe gelangten. `$PackageVerifyCode` war deshalb ein Array, obwohl der letzte Wert `0` war. Der Vergleich mit `0` lieferte für die Textzeilen Treffer und aktivierte den Fehlerzweig.

Belegt ist dies durch die Kombination aus `package verification: PASS`, `failures=0`, genau einem ausgeführten Schritt und `overall=FAIL`. Der Build wurde nicht gestartet; es liegt daher weder ein Compiler- noch ein Enginefehler vor.

CR3R2 konsumiert jede Kindprozesszeile explizit für die Konsole, verwendet einen separaten JSON-Status als autoritativen Exitcode und gibt aus den Prozesshelfern nur noch einen einzelnen Integer zurück.
## Binary-safe Live-Runner-Hotfix (2026-08-09)

Der zweite CR3R2-Versuch erreichte den Paket-PASS, der Python-Live-Runner brach jedoch beim Start des Build-Kindprozesses mit einer nicht vollständig erhaltenen Traceback-Ausgabe ab. Der Runner leitet Kindprozessdaten nun binär ohne Codepage-Roundtrip weiter, fängt Streamingfehler vollständig ab und schreibt Diagnose sowie Exitcode in `*.status.json`. PowerShell konsumiert den nativen Stream über `Out-Host` bei vorübergehend nicht-terminierender Native-Fehlerbehandlung; der Funktionsrückgabewert bleibt ein einzelner Integer.

