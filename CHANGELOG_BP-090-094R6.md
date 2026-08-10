# MiniQuake BP-090–BP-094R6

## Unbeaufsichtigte Original-Interop mit temporären Loopback-Firewallregeln

R5 bewies, dass eine Bindung an `127.0.0.1` allein auf dem getesteten Windows-
System die erstmalige programmbezogene Defender-Firewallabfrage nicht sicher
verhindert. R6 ergänzt deshalb:

- automatische Administratoranforderung unmittelbar vor dem Build,
- vier temporäre exakte Programmregeln für `MiniQuake.exe` und `GLQUAKE.EXE`,
- UDP ausschließlich `127.0.0.1 -> 127.0.0.1`,
- automatische Entfernung in `finally`,
- JSON-Bericht über Setup und Cleanup,
- vollständige Server-stdout/stderr-Erfassung auch bei Timeout.

Keine Engine- oder Native-Datei wurde gegenüber R5 verändert.
