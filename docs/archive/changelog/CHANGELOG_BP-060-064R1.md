# MiniQuake BP-060–BP-064R1

## Live-Ausgabe statt gepufferter Kindprozesse

Diese Lieferrevision ändert ausschließlich Build-, Test- und Ergebnis-Infrastruktur.
Der Engine-Stand bleibt BP-064.

- `TEST_BP-060-064R1.ps1` leitet jede empfangene Ausgabezeile sofort an die Konsole weiter.
- Dieselbe Zeile wird unmittelbar und mit Flush in die zugehörige Logdatei geschrieben.
- Der kumulative `build.ps1` streamt nun auch die Ausgaben aller MiniQuake-Testprogramme live.
- Python-Tools und der Python-MiniLang-Compiler laufen mit `PYTHONUNBUFFERED=1`.
- Vordergrund-Clientausgaben der Mehrprozess-Netzwerkevidenz werden live angezeigt.
- Jeder gestartete Testabschnitt erhält vor Prozessstart eine sichtbare Fortschrittsmeldung.
- `test.ps1` verweist auf die R1-Abnahme.

Unverändert bleiben alle Dateien unter `src/` und `native/`, alle 113 Block-Fixtures
sowie der Kandidatenvertrag `network_platform_109_frozen_v1` mit Fingerprint
`0xb3ec7589`.
