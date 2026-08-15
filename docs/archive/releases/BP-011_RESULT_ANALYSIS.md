# BP-011 – Windows-Abnahme

Datum der Abnahme: 2026-07-24  
Ergebnisarchiv: `MiniQuake_BP-011_RESULTS_20260724-231530.zip`  
SHA-256 des Ergebnisarchivs: `9c1255139521c0ab4b09a7a95c616ad02598cb522dd4132e32fac6af8f9e34ec`

## Ergebnis

BP-011 ist vollständig angenommen. Alle 19 im Windows-Testskript definierten
Abnahmeschritte wurden erfolgreich ausgeführt.

| Gate | Ergebnis |
|---|---:|
| Statische Paket-/Quellprüfung | PASS |
| Build von Spiel und allen Testprogrammen | PASS |
| Core-Tests | 16/16 PASS |
| Milestone-Tests | 24/24 PASS |
| Diagnosetests | 10/10 PASS |
| Protocol-15-Wiretests | 15/15 PASS |
| Protocol-15-Command-/Update-Tests | 14/14 PASS |
| `id1/start`-Validierung | PASS |
| Headless-Lauf | 120 Frames PASS |
| Trace A | 64/64 Frames PASS |
| Trace B | 64/64 Frames PASS |
| Byteidentität beider Traces | PASS |
| Direkter Snapshot-CLI-Pfad | PASS |
| Winsock-UDP-Loopback | PASS |

## Deterministische Referenz

```text
Trace SHA-256: f60811d39320379d75abfeae2db1f2b4f426c91b782a0ca8cbb309fff0fe886c
Rolling hash:   2d302e1b
Tracezeilen:    65 (Header plus 64 Frames)
```

Die beiden Traces wurden in voneinander unabhängigen Prozessen mit identischen
Argumenten erzeugt und waren byteidentisch. Snapshot, Crashkontext und Summary
wurden anschließend vom eingebauten Kompatibilitätsreporter als gültig erkannt.

## Bestätigte BP-011-Funktionalität

Die Abnahme bestätigt zusätzlich zur gesamten Elternbaseline:

- Signonstufen 1 bis 4 ohne synthetisches `svc_signonnum 4`,
- signed-`char`-Framing der `clc_*`-Kommandos,
- vollständigen gültigen `svc_*`-Parserkatalog,
- baseline-relative Fast Entity Updates,
- `U_EFFECTS`, `U_NOLERP`, `U_MOREBITS` und `U_LONGENTITY`,
- gemeinsame Produktionswriter in der integrierten Serverpipeline und der
  direkten `sv_main`-Port-API.

## Konsequenz

BP-011 ist die verbindliche Elternbaseline für BP-012. Änderungen in BP-012
müssen alle oben aufgeführten Gates erneut bestehen; eine Abweichung des
64-Frame-Referenztraces ist nur mit einer nachvollziehbaren, beabsichtigten
Semantikänderung zulässig.
