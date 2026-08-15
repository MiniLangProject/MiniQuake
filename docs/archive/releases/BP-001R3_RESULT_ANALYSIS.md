# BP-001R3 – Windows-Ergebnisanalyse

Datum der Abnahme: 2026-07-24  
Ergebnisarchiv: `MiniQuake_BP-001R3_RESULTS_20260724-191119.zip`  
SHA-256 des Ergebnisarchivs: `59ae0c40c959287020ca9411fe3aca65241036027bc7586817172693c3ea7ff3`

## Gesamturteil

BP-001R3 wurde unter Windows vollständig angenommen. Damit ist die in BP-001
begonnene deterministische Diagnosebasis abgeschlossen und die Codearbeit kann
mit den eigentlichen Kompatibilitätspaketen fortgesetzt werden.

| Gate | Ergebnis |
|---|---:|
| Statische Paket-/ABI-/Diagnoseprüfung | PASS |
| Trace-Comparator-Selbsttest | PASS |
| Vollständiger MiniLang-Build | PASS |
| Core-Tests | 16/16 PASS |
| Milestone-Tests | 24/24 PASS |
| Diagnosefixtures | 10/10 PASS |
| Native Haupt- und Textbridge | Hashgleich, PASS |
| Paketidentität | PASS |
| Installierte Daten `id1/start` | PASS |
| Headless-Lauf | 120 Frames PASS |
| Kompatibilitätstrace A | 64/64 Frames PASS |
| Kompatibilitätstrace B | 64/64 Frames PASS |
| Byteidentität A/B | PASS |
| Snapshot-/Context-/Summary-Schemas | PASS |
| Direkter Snapshot-Befehl | PASS |
| Winsock-UDP-Loopback | PASS |

Alle 17 protokollierten Annahmeschritte meldeten `PASS`.

## Deterministische Referenz

Beide unabhängigen Prozesse erzeugten denselben Trace:

```text
Zeilen:       65 (Header + 64 Frames)
Bytes:        46570
SHA-256:      d77620a5f14a0ba2c5d983f3398b539a3dda6fc2cb27d4fe8131bbfa27b52918
Rolling hash: 7f4939f9
```

Der Feldvergleich meldete `equal=true` und keine erste Differenz. Damit ist die
Headless-Eingabeisolierung aus BP-001R3 bestätigt; die zuvor in Frame 15
beobachtete externe Pitch-Eingabe ist nicht mehr vorhanden.

## Testumgebung

```text
OS:          Microsoft Windows NT 10.0.26200.0
Architektur: AMD64
PowerShell:  5.1.26100.8894
Profil:      Release / compat_109
Map:         id1/start
```

Das geprüfte Quellmanifest hatte den SHA-256-Wert
`f991999a147bdcd3ddd779d0f6ad5c24cfb5322a3ba3181ba321dd7389b5d61d`.
Das zugrunde liegende BP-001R3-Quellarchiv hatte den SHA-256-Wert
`6bff3638fd1f2ae7731db28b60cdb74cb837d3cd1769692f5a5dee522c820d7a`.

## Konsequenz

BP-001R3 ist die verbindliche Elternrevision für BP-010. Spätere Änderungen
müssen die oben genannten 17 Gates weiterhin bestehen und zwei byteidentische
Traces erzeugen. BP-010 beginnt den funktionsweisen Originalabgleich bei
`common.c`/`protocol.h`: `SizeBuffer`, `MSG_*`, Quake-C-Strings und ausgewählte
komplette Protocol-15-Nachrichten.
