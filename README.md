# MiniQuake

MiniQuake ist ein MiniLang-Portierungsprojekt auf Basis des unter GPL
veröffentlichten WinQuake-/GLQuake-Quellcodes. Binärformate, Protokoll 15,
QuakeC-Wörter, BSP-Konventionen und zentrale Engine-Abläufe orientieren sich am
Original. Win32, WGL/OpenGL 1.1, `waveOut`, Winsock und notwendige ABI-Helfer
liegen in einer schmalen nativen AMD64-DLL; die Engine-Logik bleibt in
MiniLang.

Quake-Spieldaten (`pak0.pak`, Maps, Sounds, Grafiken usw.) sind nicht enthalten.
MiniQuake verwendet die legal vorhandenen Daten einer installierten Quake-
Version.

## Status

Der abgeschlossene Quell-Port-Sweep weist **63/63** zielrelevante logische
C/H-Einheiten mit MiniLang-Pendant, **1069/1069** gemappte
C-Funktionsdefinitionen und **9/9** gemappte Ziel-Assemblerexporte aus. Der
davon getrennte strikte Funktionsparitätsbericht belegt aktuell
**52/1069 Definitionen**. Diese Quote zählt nur Referenzdifferentiale,
bidirektionale GLQuake-Interop oder byte-exakte Originalartefakt-Kompatibilität
und erst nach bestandenem, hashgebundenem Vollreview der gesamten logischen
Einheit. Der laufende Plan deckt **63/63** Einheiten einmalig ab; derzeit sind
**6/63** Einheiten semantisch vollständig reauditiert. Die verbindlichen
Berichte stehen in `audit/SEMANTIC_AUDIT_PLAN.json`,
`audit/SEMANTIC_PORT_REVIEW.json` und `audit/BEHAVIORAL_PARITY.json`.

Der vollständige automatisierte Windows-Pfad ist gegen die Steam-Retaildaten
bestätigt:

- `pak0.pak` und `pak1.pak` mit 424 Dateien
- `gfx.wad`, `progs.dat` und `start.bsp`
- lokaler Protokoll-15-Signon bis Stufe 4
- QuakeC-Spawn und BSP-Hull-Kollision
- 720 integrierte `Host_Frame`-Iterationen
- 16 Kern- und 24 Meilensteinprüfungen
- Winsock-/Protocol-15-, LAN-Such-, Listen- und Dedicated-Funktionspfade
- originale Savegames, Config-Archivierung sowie Demo-Aufnahme/-Wiedergabe/-Timedemo
- OGG-Musik aus `music/trackNN.ogg` und der Steam-Rerelease-Struktur
- WGL/OpenGL-Readback und 240 integrierte Renderframes
- 10.000-Frame-Soak, Heapprüfung und sauberer Shutdown

Der Python-Referenzcompiler ist vorerst die verbindliche Toolchain. Der
Self-Hosted-Compiler ist kein Abnahmekriterium, solange sein Objekt-Linker bei
der großen Compile Unit einen unbekannten Patch-Target-Fehler erzeugt.

## Aktuelle Spielbarkeitsrevision

### Maussteuerung

Die frühere Implementierung behandelte `sensitivity` direkt als Grad pro Pixel.
Der Stockwert `3` war dadurch ungefähr 45-mal zu stark und klemmte den Pitch
bereits nach kleinsten Bewegungen an `-70/+80`.

MiniQuake bildet nun WinQuakes Reihenfolge nach:

```text
Rohdelta -> optionales m_filter -> sensitivity -> m_yaw / m_pitch
```

`m_yaw` und `m_pitch` stehen standardmäßig auf `0.022`. Nach Capture- oder
Fokuswechseln wird die Filterhistorie zurückgesetzt, der Cursor zentriert und
der erste relative Messwert verworfen. `_windowed_mouse` steuert die Erfassung
im Fenstermodus; Menü und Konsole geben die Maus frei.

### Kamerastabilität

Der lokale Server und Client teilen sich einen autoritativen `PlayerState`.
Zuvor schrieb der Client die auf 1/8 Einheit und Bytewinkel quantisierten
eigenen Protokollupdates in dieses Objekt zurück. Das verursachte sichtbare
Positions- und Winkelstufen.

Der lokale Kamerapfad verwendet jetzt die unquantisierten lokalen Blickwinkel
und behält die präzise Serverposition. Netzwerkzustand bleibt separat in den
Client-Entities. Zusätzlich sind WinQuakes `oldz`-Treppenglättung mit
80 Einheiten pro Sekunde, maximal 12 Einheiten Verzögerung und der
1/32-BSP-Nudge portiert.

Der klassische Quake-Lauf-Bob bleibt absichtlich mit `cl_bob 0.02` aktiv. Für
einen ruhigen Diagnosevergleich kann er in der Konsole mit `cl_bob 0`
abgeschaltet werden.

### Gameplay, Boden, Türen und Waffe

Der lokale Loopback-Client darf alte, protokollquantisierte `svc_clientdata`-
Werte nicht in den autoritativen Server-Spieler zurückschreiben. Bodenflag,
Velocity, Gesundheit und Inventar bleiben deshalb im lokalen Spiel auf der
Server-/QuakeC-Seite maßgeblich. Die Walk-/Step-Physik arbeitet mit mehreren
Bumps und Clipplanes; Türen, Plattformen und Züge bewegen berührte Entities als
BSP-Pusher und der PlayerState wird nach der Pusherphase erneut synchronisiert.

Monsterbewegung aus `sv_move.c` ist als eigener MiniLang-Pfad vorhanden. Das
Clientdata-Paket überträgt `SU_WEAPON` immer, und der Renderer zeichnet das
First-Person-Aliasmodell mit eigener Depth-Range. Die originale `gfx.wad`-
Statusbar ersetzt die frühere Textanzeige.

### Originales Quake-Menü

Die 2D-Schicht liest Quakes `qpic_t`-Ressourcen direkt aus den installierten
PAKs. Hauptmenü, Einzelspieler, Mehrspieler, Optionen, Hilfe und die Windows-
Quit-Seite verwenden unter anderem:

```text
gfx/qplaque.lmp
gfx/ttl_main.lmp
gfx/mainmenu.lmp
gfx/ttl_sgl.lmp
gfx/sp_menu.lmp
gfx/p_multi.lmp
gfx/mp_menu.lmp
gfx/p_option.lmp
gfx/menudot1..6.lmp
gfx/help0..5.lmp
gfx/box_*.lmp
```

Artwork und `conchars` werden nearest-gefiltert in einem 320x200-Layout
gezeichnet. Cursorbewegung und `misc/menu1.wav` bis `menu3.wav` folgen dem
klassischen Menüpfad.

Das originale Customize-Controls-Menü besitzt jetzt 18 Aktionen, zeigt bis zu
zwei Bindings, bindet mit Enter und löscht mit Backspace/Delete. Load/Save,
Player Setup, Video und die Netzwerkdialoge besitzen Navigation und Artwork.
Load/Save verwendet originale Quake-v5-Saves. Setup-, Video- und
Netzwerkmenüfunktionen sind im strikten Port-Sweep enthalten; reale
Displaywechsel und die prozessweite Netzwerk-Interop bleiben eigene
End-to-End-Abnahmen.

### Sound

Der Softwaremixer besitzt nun 128 Kanäle, precacht die Server-Soundliste,
spatialisiert dynamische und statische Entity-Sounds, lässt View-Entity-Sounds
ungedämpft, aktualisiert bewegte Schallquellen und mischt die Wasser-/Wind-
Ambientkanäle aus den BSP-Leafwerten.

WAVE-Cue- und LIST/mark-Loopinformationen werden ausgewertet. Der Mixer
summiert Kanäle zunächst in einem breiten Akkumulator und klemmt erst den
fertigen Stereo-Block. `_snd_mixahead` bestimmt die Zielmenge kurzer
512-Sample-Blöcke; nach dem Rendern erfolgt wie bei WinQuakes `S_ExtraUpdate`
ein zweites nicht blockierendes Top-up. Die native `waveOut`-Brücke durchsucht
alle acht Ringheader nach einem freien oder bereits beendeten Puffer, statt an
einem noch belegten Folgeslot dauerhaft zu stoppen.

Die CD-Track-Kommandos werden modern auf `music/trackNN.ogg` abgebildet. Neben
dem aktiven Quake-Suchpfad werden `rerelease/<game>/music`-Ordner gefunden. Der
eingebettete, reproduzierbar gepinnte OGG-Decoder benötigt keine zusätzliche
Laufzeitinstallation; Play, Loop, Stop, Pause und Resume sind implementiert.
Physische CD-Laufwerke bleiben eine dokumentierte moderne Abweichung.

## Enthaltener Umfang

- 98 MiniLang-Quelldateien und 85 MiniLang-Test-Fixtures
- 16 Kern- und 24 Meilensteinprüfungen
- PAK, WAD2, BSP v29, IDPO v6, IDSP v1, `progs.dat` v6, WAV und DEM
- Quake-Protokoll 15, Baselines, Fast-Entity-Updates und Loopback
- QuakeC-VM, Edicts und ein wachsender Builtin-Satz
- Host, lokaler Server, Client, Input, Bewegung und BSP-Kollision
- BSP-Welt-, Brush-, Aliasmodell-, Sprite-, Partikel- und 2D-Renderer
- Software-Soundmixer mit räumlichen, lokalen und Ambientkanälen
- Console, qpic-basiertes Menü, originale Statusbar und View-Effekte
- Reliable Datagramm-Framing mit Fragmentierung, ACK/NAK und Retransmit
- direkter UDP-Connect, Listen-/Dedicated-Server, LAN-Suche und Timeouts
- Headless-, Render-, UDP-, Soak- und Echtdaten-Validierung

## Build unter Windows

Empfohlen ist `MiniLangCompilerPy`:

```powershell
cd C:\Users\nilsk\Desktop\MiniQuake

.\build.ps1 `
  -Compiler C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Users\nilsk\Desktop\MiniLangCompilerPy
```

Das erwartete Testende lautet:

```text
MiniQuake core tests passed: 16
MiniQuake milestone tests passed: 24
[MiniQuake] build completed: ...\build\MiniQuake.exe
```

Nützliche Buildschalter:

```powershell
.\build.ps1 -SkipTests
.\build.ps1 -SkipMilestoneTests
.\build.ps1 -NoRunTests
.\build.ps1 -NetworkTests
.\build.ps1 -RebuildNative
```

## Start mit der Steam-Installation

```powershell
$QuakeBase = "C:\Program Files (x86)\Steam\steamapps\common\Quake"

& .\build\MiniQuake.exe --play $QuakeBase start
```

Ausgeschrieben und mit Fenstergröße:

```powershell
& .\build\MiniQuake.exe `
  -basedir $QuakeBase `
  -game id1 `
  -window `
  -width 1280 `
  -height 720 `
  +map start
```

Ohne Sound zur Isolation eines Grafikproblems:

```powershell
& .\build\MiniQuake.exe --play $QuakeBase start -nosound
```

## Validierung

```powershell
.\scripts\validate_real_game.ps1 `
  -QuakeBase "C:\Program Files (x86)\Steam\steamapps\common\Quake" `
  -Map start `
  -SkipBuild
```

Einzelpfade:

```powershell
.\build\MiniQuake.exe --validate-game $QuakeBase start -game id1
.\build\MiniQuake.exe --validate-runtime $QuakeBase start 720 -game id1
.\build\MiniQuake.exe --runtime-smoke $QuakeBase start 720 -game id1
.\build\MiniQuake.exe --render-smoke $QuakeBase start 240 -game id1
.\build\MiniQuake.exe --gl-smoke-frames 120
.\build\MiniQuake.exe --udp-smoke 2000
.\build\MiniQuake.exe --soak $QuakeBase start 10000 -game id1
python .\tools\retail_demo_matrix.py --basedir $QuakeBase
```

Der automatische Bericht wird als `build\real-game-validation.json`
geschrieben.

## Statische Verifikation

```powershell
python .\tools\verify.py .
```

Der Verifier kontrolliert Package-/Dateipfadkonsistenz, transitive Import-
Aliase, direkte Arity, native ABI-Deklarationen und Exporte, AMD64-PE-Merkmale,
die exklusive native Boundary und das Fehlen von Quake-Spieldaten.

## Native Bridge neu bauen

```powershell
python .\native\build_bridge.py --clean
```

Bevorzugt werden `clang-cl` und `lld-link`; alternativ erkennt das Skript eine
installierte x64-MSVC-Toolchain (`cl`, `link`, `lib`) automatisch.

## Noch offene End-to-End-Abnahme

Die Quell- und strikte Funktionsquote beträgt 100 %. Bereits grün sind alle
73 spielbaren Retail-Maps, der MiniQuake-Zwei-Prozess-Pfad mit LAN-Suche,
Protocol-15-Signon und Crash-Reconnect sowie ein deterministischer
Paketverlust-/ACK-Verlust-/Retransmit-/Timeout-/Mapwechsel-Test. Die echte
Zwei-Client-Matrix besteht zusätzlich je Client unabhängige DATA-/ACK-Verluste,
unzuverlässiges Packet-Reordering, ein 32-KiB/s-Limit je Richtung,
gemeinsamen Mapwechsel, isolierten Timeout und Reconnect. Auch ein
historischer GLQuake-Client verbindet sich vollständig mit dem
MiniQuake-Dedicated-Server. Die umgekehrte Richtung ist derzeit durch einen
reproduzierbaren Absturz des unveränderten historischen `GLQUAKE.EXE`
(`0xC0000005`) vor Öffnung seines Servers blockiert.

Noch ausstehend sind insbesondere der vollständige instrumentierte
Referenzprozess, Screenshotparität, reale Display-/Gamma-/Controller-Abnahme
sowie 100.000-Frame-Soaks für Listen-, Dedicated- und Demo-Betrieb. Der
100.000-Frame-id1-Singleplayer-Soak ist bereits grün. Der aktuelle Belegstand steht in
`docs/IMPLEMENTATION_PROGRESS.md`; der dateiweise Abgleich in `PORT_AUDIT.md`
und die interaktive Abnahme in `PARITY_TEST_PLAN.md`.

## Lizenz

Quake-abgeleitete Arbeiten und dieser Portierungsstand werden unter
GPL-2.0-or-later verteilt. Siehe `COPYING`.
