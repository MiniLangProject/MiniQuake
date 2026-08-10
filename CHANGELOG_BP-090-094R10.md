# MiniQuake BP-090–BP-094R10

## Ausgangspunkt

R9 lehnte den lokalen Demo-/Map-Fallback korrekt als ungültige Originalserver-Interop ab. Im Windows-Lauf antwortete der noch aktive Original-GLQuake-Prozess jedoch innerhalb des bisherigen 30-Sekunden-Harnessfensters nicht auf die vier vollständigen Clientversuche.

## Änderungen

- neuer Protocol-3-Readiness-Probe über `CCREQ_SERVER_INFO` / `CCREP_SERVER_INFO`,
- vollständiger MiniQuake-Interopclient startet erst nach bestätigter Originalserverbereitschaft,
- Standard-Readiness-Timeout 180 Sekunden, konfigurierbar über `-OriginalServerReadyTimeoutMs`,
- exakte Prüfung von Antwortadresse, Antwortport, Control-Flag, Paketlänge, Kommando und Protokollversion,
- maschinenlesbare Readiness-Berichte pro Prozesspaar,
- Prozess- und UDP-Endpunktdiagnose bei Timeout,
- bind-getestete zufällige Loopbackports für beide Interoperabilitätsrichtungen,
- generische Testlauncher und Collector auf R10 aktualisiert,
- neuer statischer R10-Vertrag im Paketverifier.

## Nicht verändert

- kein MiniLang-Produktionscode unter `src/`,
- kein nativer Code oder DLL unter `native/`,
- keine Contract-Fingerprints,
- keine Bildvergleichsschwelle,
- keine Lockerung der R9-Netzwerkprovenienz.
