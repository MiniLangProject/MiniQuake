# BP-001R1 – Auswertung des Windows-Ergebnisarchivs

Ausgewertetes Archiv:

```text
MiniQuake_BP-001R1_RESULTS_20260724-172632.zip
SHA-256 5f0c9edf96187e3b4e310cc7a759308f0cbadb45645619a28003e66753caec81
```

Zielsystem:

```text
Microsoft Windows NT 10.0.26200.0
AMD64, 64-Bit-Prozess
Windows PowerShell 5.1.26100.8894
```

## Erreichte Gates

| Gate | Ergebnis |
|---|---:|
| statische Paketprüfung | PASS |
| Manifest | 226/226 PASS |
| MiniLang-Imports | 1.153 PASS |
| Hauptbridge-ABI | 160/160 PASS |
| Textbridge-ABI | 11/11 PASS |
| vollständiger MiniQuake-Build | PASS |
| Core-Tests | 16/16 PASS |
| Milestone-Tests | 24/24 PASS |
| BP-001R1-Diagnosefixtures | 8/8 PASS |
| `id1/start`-Datenvalidierung | PASS |
| 120 Headless-Frames | PASS |
| Winsock-UDP-Loopback | PASS |
| erster 64-Frame-Kompatibilitätstrace | FAIL nach Frame 0 |

Der erzeugte Build war eindeutig BP-001R1. Die vier EXE-Ziele und beide DLLs
waren vorhanden; es blieben keine `*.partial.exe`-Dateien zurück.

## Fehlergrenze

`run-a.mqtrace` enthält den vollständigen 129-Byte-Header, aber noch keine
Framezeile. Der persistente Kontext wurde dagegen nach dem ersten Host-Frame
erfolgreich geschrieben:

```text
phase=frame_complete
frame=0
last_completed_stage=complete
diagnostic_write_error=""
server.num_edicts=86
server.active_edicts=86
client.entities=85
```

Damit sind Dateieröffnung, Engineinitialisierung und der gesamte erste
Host-Frame bestätigt. Der Fehler liegt danach in der kanonischen
Zustandsbildung, noch vor dem Append der ersten Framezeile. Da BP-001R1 diesen
Aufruf noch nicht mit `try(...)` umschloss, erreichte der Runtimefehler weder
`printResult` noch Snapshot und Summary; der Prozess endete mit Exitcode 1.

## Reproduzierte Quellursache

MiniQuakes Client-Entity-Tabelle ist absichtlich sparse:

1. `CL_EntityNum` beziehungsweise `ensureEntity` erweitert die Tabelle mit
   `void`-Slots bis zur angeforderten Entitynummer.
2. `SV_CreateBaseline` sendet Nichtspieler-Entities nur, wenn sie ein Modell
   besitzen. Trigger und andere nicht gerenderte Edicts erzeugen deshalb Lücken
   in der Clienttabelle.
3. BP-001R1 iterierte in `clientEntitiesHash` und `clientEntitiesJson` über alle
   Slots und griff ohne `void`-Prüfung auf `item.number`, `item.modelIndex` usw.
   zu.

Der assetfreie BP-001R1-Testzustand enthielt nur eine leere beziehungsweise
kompakte Tabelle und deckte die reale Sparse-Topologie daher nicht ab.

## Klassifikation

```text
B1 – Runtimeblocker in neu hinzugefügter Diagnosefunktion
```

Es gibt aus diesem Lauf keinen Hinweis auf eine Regression in Gameplay,
Protocol 15, QuakeC, Physik, Rendering, Audio oder Netzwerk. Alle vor dem neuen
Tracepfad liegenden Engine- und Testgates waren grün.

## Korrektur in BP-001R2

BP-001R2:

- hasht Tabellenlänge, Slotindex und Belegungsmarke,
- dereferenziert nur belegte Client-Entity-Slots,
- schreibt leere Snapshot-Slots als JSON-`null`,
- fängt `canonicalFrame`-Fehler ab und schreibt einen klassifizierten
  Trace-Fehlereintrag,
- ergänzt einen Sparse-Regressionstest,
- speichert stdout/stderr von Trace A, Trace B und direktem Snapshot separat.
