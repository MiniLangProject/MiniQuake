# GLQuake-1.09-Portaudit

Stand dieser Revision: abgeschlossener Quell-Port-Sweep für GLQuake 1.09,
Windows x64 und Protocol 15.

## Verbindliche Ergebnisse

| Prüfebene | Ergebnis | Bedeutung |
|---|---:|---|
| Logische Ziel-C/H-Einheiten | **63/63** | Jede zusammengehörige Original-C/Header-Einheit besitzt ein bestehendes MiniLang-Pendant. |
| Ziel-C-Funktionsdefinitionen | **1069/1069** | Jede Zieldefinition besitzt einen belastbaren MiniLang-Codeort; 0 Kandidaten, 0 ungemappt. |
| Ziel-Assemblerexporte | **9/9** | Alle im Zielumfang benötigten Exporte besitzen einen Codeort. |
| Strikte Funktionsparität nach Vollreview-Gate | **52/1069 (4,864359 %)** | Nur Referenzdifferentiale, bidirektionale GLQuake-Interop oder byte-exakte Originalartefakt-Kompatibilität zählen; zusätzlich muss die komplette logische Einheit hashgebunden semantisch reauditiert sein. |

Die vollständige maschinelle Einheiten- und Funktionsliste steht in
`audit/GLQUAKE_PORT_INVENTORY.json` und
`docs/GLQUAKE_PORT_INVENTORY.md`. Der separate strikte Belegstand steht in
`audit/BEHAVIORAL_PARITY.json` und `docs/BEHAVIORAL_PARITY.md`.
Der laufende 63-Einheiten-Reaudit steht zusätzlich in
`audit/SEMANTIC_PORT_REVIEW.json`, `docs/SEMANTIC_PORT_REVIEW.md` und
`audit/SEMANTIC_AUDIT_PLAN.json`.

## Dateiweise Abdeckung

`ORIGINAL_FILE_COVERAGE.md` wird aus dem gepinnten offiziellen Baum generiert.
Von 213 C-/Headerdateien sind:

- **88** als Teil einer portierten logischen Einheit klassifiziert,
- **10** als Plattformbrücke klassifiziert,
- **115** gemäß Zieldefinition nicht relevant,
- **0** teilportiert und **0** offen.

Diese Dateiwerte dürfen nicht mit der Einheitenzahl addiert werden:
zusammengehörige Header und C-Dateien bilden bewusst nur ein MiniLang-Pendant.
Auch die rohe Liste öffentlicher Makros und Typnamen ist kein eigenes
Portierungsziel.

## Plattformbrücken und Ausschlüsse

Win32/WGL, Eingabe, Winsock, `waveOut` und notwendige ABI-Helfer dürfen in der
nativen Windows-Brücke liegen. Die Engine-Logik bleibt in MiniLang.

Ausgeschlossen sind WinQuake-Software-Rendering, IPX, Serial/Modem, VCR,
physische CD-/MCI-Steuerung, Masterserver und NAT-Traversal. CD-Tracknummern
werden stattdessen auf OGG-Dateien abgebildet.

## Abgrenzung zur End-to-End-Abnahme

100 % strukturelle Abdeckung und 100 % strikte Funktionsparität belegen nicht
automatisch den vollständigen historischen Prozess als Ganzes. Die erweiterte
Matrix für zwei gleichzeitig aktive Clients ist inzwischen grün: unabhängige
DATA-/ACK-Verluste, Sequenzräume, Reordering, Bandbreitenbegrenzung,
gemeinsamer Mapwechsel, isolierter Timeout und Reconnect wurden in realen
Prozessen geprüft. Noch separat abzunehmen sind:

- MiniQuake-Client gegen einen lauffähigen historischen GLQuake-Server. Die
  Richtung GLQuake-Client→MiniQuake-Server ist grün; das lokale unveränderte
  `GLQUAKE.EXE` crasht als Server reproduzierbar mit `0xC0000005`, bevor es
  einen Listener öffnet,
- vollständige instrumentierte Referenzframes,
- Referenzscreenshots mit SSIM mindestens 0,99,
- 100.000-Frame-Soaks für Listen-, Dedicated- und Demo-Betrieb. Alle 73
  spielbaren Retail-Maps und der id1-Singleplayer-Soak über 100.000 Frames
  sind grün.

Diese offenen Integrations-Gates ändern die erreichten Port-Sweep-Zahlen nicht;
eine vollständige GLQuake-Prozessabnahme wird aber erst nach ihrem Bestehen
behauptet.
