# GLQuake-1.09-Parität: Implementierungs- und Belegstand

Dieses Dokument trennt drei unterschiedliche Aussagen: vorhandene
MiniLang-Pendants, strikte Funktionsparität und prozessweite
End-to-End-Abnahme.

## Reproduzierbare Grundlage

- `reference/quake` ist auf
  `bf4ac424ce754894ac8f1dae6a3981954bc9852d` gepinnt.
- `reference/quake.lock.json`, `tools/verify_reference.py` und
  `tools/verify_dependencies.py` prüfen Referenz und Drittanbieter-Code.
- Der veränderte Ordner `oiriginal quake source code` wird nicht verwendet.
- Die Inventur leitet den aktiven Windows-GL-Release-Umfang aus dem
  Originalprojekt und seinen transitiven Headern ab.

## Aktueller Belegstand

| Aussage | Ergebnis | Verbindlicher Bericht |
|---|---:|---|
| Ziel-C/H-Einheiten mit MiniLang-Pendant | **63/63** | `docs/GLQUAKE_PORT_INVENTORY.md` |
| Ziel-C-Definitionen mit MiniLang-Codeort | **1069/1069** | `audit/GLQUAKE_PORT_INVENTORY.json` |
| Ziel-Assemblerexporte mit Codeort | **9/9** | `audit/GLQUAKE_PORT_INVENTORY.json` |
| Strikt nachgewiesene Zieldefinitionen nach Vollreview-Gate | **52/1069 (4,864359 %)** | `docs/BEHAVIORAL_PARITY.md` |
| Hashgebunden semantisch reauditiert | **6/63 Einheiten** | `docs/SEMANTIC_PORT_REVIEW.md` |
| Strikte Belegmanifeste | **47** | `audit/BEHAVIORAL_PARITY.json` |
| Core-/Milestone-Tests | **16/16**, **24/24** | `tests/core_tests.ml`, `tests/milestone_tests.ml` |

`located` in der Inventur ist nur ein Codeortbeleg. Die strikte Quote zählt
separat ausschließlich zulässige Referenzdifferentiale, direkte
Originalartefakt-Kompatibilität oder bidirektionale GLQuake-Kompatibilität.
Seit dem Vollreview-Gate muss zusätzlich die gesamte logische Einheit
hashgebunden und branchweise reauditiert sein. MiniQuake-only Tests erhöhen
diese Quote nicht.

Die 63 logischen Einheiten fassen zusammengehörige C- und Headerdateien
absichtlich zu einem Pendant zusammen. Rohe Header-Makros und Typnamen werden
daher nicht als eigene Portierungsdateien gezählt.

## Implementierter Funktionsumfang

Der Sweep umfasst Formate und Dateisystem, Host/Persistenz, QuakeC und Edicts,
Client, Server, Physik, Demos, Protocol 15/UDP, GLQuake-Rendering, Oberfläche,
Win32-Eingabe/Video, Sound und den OGG-Ersatz für CD-Musik. Die
plattformabhängigen Einheiten bleiben als klar ausgewiesene native Brücken
erhalten; physische CD-Steuerung und die übrigen vereinbarten Ausschlüsse
werden nicht in die Zielquote eingerechnet.

Retail-Smokes belegen Start und 720 Host-Frames für id1, hipnotic und rogue.
Alle 73 spielbaren Retail-Maps erreichen Protocol-15-Signon 4, QuakeC-Spawn
und Headless-Physikframes. Die zehn mitgelieferten Retail-Demos bestehen
bytegenaue Parse-/Serialize-Roundtrips. Der getrennte
MiniQuake-Dedicated-/Client-Pfad besteht LAN-Suche, Protocol-15-Signon,
Crash-Reconnect, verlorene DATA-/ACK-Pakete, Retransmits, Timeout, Mapwechsel
und Ersatzverbindung. Eine zusätzliche echte Zwei-Client-Matrix belegt
getrennte Sequence-Spaces, je Verbindung unabhängige DATA-/ACK-Verluste,
unzuverlässiges Packet-Reordering, ein reproduzierbares 32-KiB/s-Limit je
Richtung, gemeinsamen Mapwechsel sowie Timeout und Reconnect eines Clients bei
weiterlaufendem zweiten Client. Ein historischer GLQuake-Client erreicht vollständig
`prespawn`, `spawn` und `begin` auf einem MiniQuake-Dedicated-Server. id1
besteht einen 100.000-Frame-Singleplayer-Soak mit exakt stabilen Heap-Bytes;
hipnotic und rogue bestehen jeweils 10.000 Frames. Alle drei Spiele bestehen
120 integrierte Renderframes.

## Noch nicht als prozessweite 1:1-Abnahme belegt

- MiniQuake-Client gegen einen lauffähigen historischen GLQuake-Server; das
  lokal vorhandene unveränderte `GLQUAKE.EXE` stürzt als Server
  reproduzierbar vor Listener-Öffnung mit `0xC0000005` ab
- vollständiger instrumentierter Referenz-Framebuild und lange
  Frame-für-Frame-Traces
- Referenzscreenshots mit SSIM mindestens 0,99
- reale Displaywechsel-/Gamma-/Controller-Abnahme
- 100.000-Frame-Soaks für Listen-, Dedicated- und Demo-Betrieb

Die strukturelle Quote steht auf 100 %. Die strikte Funktionsquote wird im
laufenden 63-Einheiten-Reaudit neu aufgebaut und erst danach wieder als 100 %
ausgewiesen. Eine vollständige GLQuake-Prozessabnahme wird erst behauptet,
wenn zusätzlich die End-to-End-Matrix grün ist.
