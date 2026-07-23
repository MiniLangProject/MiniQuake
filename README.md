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

Der vollständige automatisierte Windows-Pfad ist gegen die Steam-Retaildaten
bestätigt:

- `pak0.pak` und `pak1.pak` mit 424 Dateien
- `gfx.wad`, `progs.dat` und `start.bsp`
- lokaler Protokoll-15-Signon bis Stufe 4
- QuakeC-Spawn und BSP-Hull-Kollision
- 720 integrierte `Host_Frame`-Iterationen
- 15 Kern- und 22 Meilensteinprüfungen
- Winsock-UDP-Loopback
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
Player Setup, Video und die Netzwerkdialoge besitzen Navigation und Artwork;
die zugrundeliegenden Savegame-, Setup-, Videomodus- und Netzwerk-Backends sind
noch nicht 1:1 abgeschlossen.

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
einem noch belegten Folgeslot dauerhaft zu stoppen. CD-Audio beziehungsweise
Musik ist weiterhin offen.

## Enthaltener Umfang

- 77 MiniLang-Quell- und Testdateien
- 15 Kern- und 22 Meilensteinprüfungen
- PAK, WAD2, BSP v29, IDPO v6, IDSP v1, `progs.dat` v6, WAV und DEM
- Quake-Protokoll 15, Baselines, Fast-Entity-Updates und Loopback
- QuakeC-VM, Edicts und ein wachsender Builtin-Satz
- Host, lokaler Server, Client, Input, Bewegung und BSP-Kollision
- BSP-Welt-, Brush-, Aliasmodell-, Sprite-, Partikel- und 2D-Renderer
- Software-Soundmixer mit räumlichen, lokalen und Ambientkanälen
- Console, qpic-basiertes Menü, originale Statusbar und View-Effekte
- Datagramm-Framing und Winsock-/UDP-Brücke
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
MiniQuake core tests passed: 15
MiniQuake milestone tests passed: 22
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

Dafür werden `clang-cl` und `lld-link` benötigt.

## Noch offene 1:1-Parität

Insbesondere fehlen noch vollständige Savegame-/Edict-Semantik, die restliche
QuakeC-Builtin- und Physikparität, Renderer- und Soundsonderfälle, vollständige
Setup-/Video-/Netzwerkmenüs, CD-Audio, kompletter UDP-Verbindungsaufbau sowie
längere Demo-/Timing-Abnahmen. Der dateiweise Abgleich steht in
`PORT_AUDIT.md`; die interaktive Abnahme in `PARITY_TEST_PLAN.md`.

## Lizenz

Quake-abgeleitete Arbeiten und dieser Portierungsstand werden unter
GPL-2.0-or-later verteilt. Siehe `COPYING`.
