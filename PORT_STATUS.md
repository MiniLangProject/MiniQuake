# Portierungsstatus

## Port-Sweep

Der definierte GLQuake-1.09-/Windows-x64-Quellumfang ist vollständig
zugeordnet. Alle Funktionen besitzen Differentialclaims; deren vollständiger
branchweiser Agenten-Reaudit läuft:

- **63/63** zielrelevante logische C/H-Einheiten besitzen mindestens ein
  bestehendes, sinnvolles MiniLang-Pendant.
- **1069/1069** zielrelevante C-Funktionsdefinitionen besitzen einen
  MiniLang-Codeort; es gibt keine Kandidaten und keine ungemappten
  Zielfunktionen.
- **9/9** zielrelevante Assemblerexporte besitzen einen Codeort.
- **52/1069 (4,864359 %)** Zieldefinitionen zählen derzeit durch das
  Vollreview-Gate als strikt bestätigt.
- **6/63** logische Ziel-Einheiten sind derzeit hashgebunden und branchweise
  semantisch vollständig reauditiert.
- **16/16** Core- und **24/24** Milestone-Tests sind im aktuellen Testtreiber
  verdrahtet und bestanden im letzten vollständigen Build.

Die verbindlichen maschinellen Berichte sind:

- `audit/GLQUAKE_PORT_INVENTORY.json` und
  `docs/GLQUAKE_PORT_INVENTORY.md` für Codeort- und Einheitenabdeckung
- `audit/BEHAVIORAL_PARITY.json` und `docs/BEHAVIORAL_PARITY.md` für den
  davon getrennten strikten Funktionsbeleg
- `audit/SEMANTIC_AUDIT_PLAN.json`, `audit/SEMANTIC_PORT_REVIEW.json` und
  `docs/SEMANTIC_PORT_REVIEW.md` für den 63-Einheiten-Vollreview
- `audit/PORT_COVERAGE.json` und `ORIGINAL_FILE_COVERAGE.md` für den
  vollständigen gepinnten WinQuake-Dateibaum

Die 850 nicht einzeln zugeordneten öffentlichen Header-Symbole sind rohe
Makro-/Typdeklarationen. Sie ändern nicht die C/H-Einheitenquote: Header und
zugehörige C-Datei werden bewusst als eine logische Portierungseinheit gezählt.

## Enthaltener Zielumfang

- PAK, WAD2, BSP29, MDL6, SPR1, `progs.dat` v6, WAV und DEM
- Quake-Protokoll 15, Signon, Baselines, Fast Updates und Reliable Datagramme
- QuakeC-VM, Edicts, Stock-Builtins, Host-, Client-, Server- und Physikpfade
- originale v5-Savegames, Config-Archivierung, Demoaufnahme, Wiedergabe und
  `timedemo`
- GLQuake-Rendererpfade, Konsole, Statusbar, Menüs und View-Effekte
- Software-Soundmixer, `waveOut` und OGG-Ersatz für CD-Tracknummern
- Win32/WGL, Eingabe, UDP und Audio als begrenzte native Plattformbrücke
- id1-, hipnotic- und rogue-Suchpfade; proprietäre Spieldaten werden nicht
  eingecheckt

Ausgeschlossen bleiben WinQuake-Software-Rendering, IPX, Serial/Modem, VCR,
physische CD-/MCI-Steuerung, Masterserver und NAT-Traversal.

## Automatisierte Integrationsbelege

- Build und statische Verifikation mit dem Python-MiniLang-Compiler
- Steam-Retailstart und 720 integrierte Frames für id1, hipnotic und rogue
- bytegenaues Parse-/Serialize-Replay der zehn Retail-Demos
- Save-/Load-, Config-, QuakeC-, Renderer-, Sound- und Protokoll-Fixtures
- WGL/OpenGL-Smokes, Pixel-Readback und 120 integrierte Renderframes je Spiel
- getrennte MiniQuake-Prozesse mit LAN-Suche, Protocol-15-Signon und
  Crash-Reconnect
- zwei gleichzeitig aktive Clients mit getrennten Loopback-LAN-Adressen,
  unabhängigen DATA-/ACK-Verlusten, Reordering, 32-KiB/s-Limit je Richtung,
  gemeinsamem Mapwechsel, isoliertem Timeout und Reconnect
- 100.000-Frame-id1-Singleplayer-Soak sowie je 10.000 Frames für hipnotic und
  rogue bei stabilen Heap-Bytes

## Noch nicht als End-to-End-GLQuake-Abnahme belegt

Die 100-%-Funktionsquote ist kein Ersatz für die noch ausstehenden
prozessweiten Abnahmen:

- MiniQuake-Client gegen historischen GLQuake-Server; die Gegenrichtung
  GLQuake-Client gegen MiniQuake-Server ist grün. Das unveränderte historische
  `GLQUAKE.EXE` stürzt im Serverbetrieb reproduzierbar vor Öffnung des
  Listeners mit `0xC0000005` ab.
- durchgehende instrumentierte Frame-Traces eines vollständigen
  Referenzprozesses
- Referenzscreenshots mit SSIM mindestens 0,99
- 100.000-Frame-Soaks für Listen-, Dedicated- und Demo-Betrieb

Alle 73 spielbaren Retail-Maps aus id1, hipnotic und rogue bestehen bereits
Protocol-15-Signon, QuakeC-Spawn und Headless-Physikframes.

Setup-, Video- und Netzwerkmenüfunktionen sind im Port-Sweep enthalten. Noch
offen ist deren prozessweite Abnahme zusammen mit realem Displaywechsel,
Gamma/Controller und den oben genannten Resten der Netzwerk-Interop-Matrix.

Der Self-Hosted-Compiler bleibt wie festgelegt außerhalb des
Funktionsparitäts-Gates.
