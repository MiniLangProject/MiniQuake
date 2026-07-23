# Portierungsstatus

## Enthaltener Meilenstein

- MiniLang-Basis, Binär-I/O, CRC, `sizebuf_t`, `MSG_*`, Cvars und Commands
- PAK-/WAD2-Dateisystem sowie BSP-, MDL-, SPR-, `progs.dat`-, WAV- und DEM-Lader
- QuakeC-VM, Edict-Grundlagen und ein wachsender Builtin-Satz
- Protokoll 15, Signon, Baselines, Fast-Entity-Updates und Loopback
- integrierter Host-, lokaler Server- und Clientpfad
- Input, Spielerbewegung, BSP-Hull-Trace und Physikgrundlagen
- texturierter BSP-Pfad, CPU-Lightmaps, Brush-Entities, Modelle, Sprites und Partikel
- Console, qpic-basiertes WinQuake-Menü, Screen-/HUD-Grundlagen und View-Effekte
- Software-Soundmixer, 128 Kanäle, Ambient-Loops und `waveOut`
- Demo-Verifikation, Datagramm-Framing und Winsock-/UDP-Smoke-Test
- Headless-, Runtime-, Render-, Soak- und Echtdaten-Prüfpfade
- 15 Kern- und 22 Meilensteinprüfungen

## Aktuelle Spielbarkeitsrevision

### Maus

- WinQuakes `sensitivity * m_yaw/m_pitch`-Skalierung
- optionales `m_filter`
- Pitchgrenzen `-70..80`
- Reset der Filterhistorie bei Capture-/Fokuswechsel
- Zentrieren und Verwerfen der ersten nativen Cursorprobe
- `_windowed_mouse` sowie Freigabe in Menü und Konsole

### Kamera

- getrennte lokale, unquantisierte Blickwinkel
- keine Rückschreibung eigener Protokoll-15-Ursprünge in den autoritativen Spieler
- originale `oldz`-Treppenglättung mit 80 Einheiten/s und 12-Einheiten-Grenze
- 1/32-BSP-Nudge
- originaler `cl_bob` bleibt konfigurierbar erhalten

### Menü

- originale PAK-qpic-Ressourcen für Haupt-, Singleplayer-, Multiplayer-,
  Optionen-, Hilfe- und Windows-Quit-Seite
- animierte Menüpunkte und klassische Menü-Sounds
- nearest-gefiltertes 320x200-Layout
- originales 18-Aktionen-Tastenmenü mit Bind/Unbind/Key-Grab
- Load/Save-, Setup- und Video-Seiten navigierbar; deren Backends sind noch offen
- vollständige Netzwerkseiten funktional offen

### Sound

- 128 Softwarekanäle
- komplette Level-Sound-Precacheliste
- View-Entity-Ausnahme von der Distanzdämpfung
- bewegte Entity-Schallquellen
- Wasser-/Wind-Ambientkanäle aus BSP-Leafwerten
- WAVE-Cue-/LIST-Loopmarker
- breiter Mix-Akkumulator mit einmaliger 16-Bit-Begrenzung
- `_snd_mixahead`-gesteuerte Queue von drei bis sieben 512-Sample-Blöcken
- zusätzliches Auffüllen nach dem OpenGL-Swap (`S_ExtraUpdate`-Pfad)
- `waveOut`-Ring mit Suche nach jedem freien oder fertigen Header
- Queue-Leerlauf- und Submit-Zähler für Diagnosen
- CD-Audio/Musik weiterhin offen

## Aktueller Gameplay-/Parity-Pass

- stale lokale `svc_clientdata`-Boden-/Velocity-Rückkopplung entfernt
- WinQuake-nähere Walk-/Step-/Wall-Friction- und Multi-Plane-FlyMove-Physik
- BSP-Pusher für Türen, Plattformen und Züge mit Blockierungs-Rollback
- Spielerzustand nach Pusherbewegung erneut aus dem QuakeC-Edict synchronisiert
- `sv_move.c`-nahe Monsterbewegung (`MoveStep`, ChaseDir, CheckBottom, MoveToGoal)
- `SU_WEAPON` und Weaponframe/Punch/Velocity im Clientdata-Paket
- Erstperson-Waffenmodell mit eigener Depth-Range
- Original-`gfx.wad`-Statusbar mit Zahlen, Faces, Waffen, Ammo, Items und Sigils
- originales Customize-Controls-Menü mit funktionalem Bind/Unbind
- systematischer Abgleich in `PORT_AUDIT.md` und `PARITY_TEST_PLAN.md`

## Statisch verifiziert

- offizieller MiniLang-Parser: 77 Dateien akzeptiert
- Projekt-Linter: Package-, Import-, Block- und direkte Arity-Prüfungen bestanden
- transitive Import-Alias-Eindeutigkeit pro Compile Unit
- MiniLang-Extern-Deklarationen und DLL-Exporte stimmen überein
- `miniquake_native.dll` ist eine AMD64-PE-DLL mit 81 Exporten
- die native Boundary bleibt auf `src/miniquake/native.ml` beschränkt
- keine Quake-Spieldaten werden verteilt
- 15 Kern- und 22 Meilensteinprüfungen sind verdrahtet

## Unter Windows automatisiert bestätigt

Der aktuelle Stand besteht:

- vollständigen Build mit `MiniLangCompilerPy`
- 15 Kern- und 22 Meilensteinprüfungen
- Steam-Retaildaten mit 424 PAK-Dateien, `gfx.wad`, `progs.dat` und `start.bsp`
- lokalen Protokoll-15-Handshake bis Signon 4 und QuakeC-Spawn
- 720 integrierte Headless-Frames
- BSP-Hull-Trace, Heapprüfung und sauberen Shutdown
- Winsock-UDP-Loopback
- WGL/OpenGL-Smoke mit erfolgreichem Pixel-Readback
- 240 integrierte Frames des texturierten Hosts mit aktivem Audiopfad
- 10.000-Frame-Soak nach stabilisierter Gameplay-Aufwärmphase

## Manuell noch zu bestätigen

- Maus-Look ohne Pitch-Sprung nach Start, Alt-Tab, Menü und Konsole
- originales Menü-Artwork und Cursor-/Soundverhalten
- kontinuierliche Effekt-, Loop- und Ambient-Audioausgabe
- ruhige lokale Kamera ohne Protokollquantisierungs-Flimmern
- interaktives Spiel in `start` und anschließend `e1m1`

Der Self-Hosted-Compiler ist derzeit kein Abnahmekriterium: Sein Objekt-Linker
bricht bei der großen Compile Unit mit einem unbekannten Patch-Target ab,
während der Python-Referenzcompiler den bisherigen Stand erfolgreich erzeugt.

## Bereits behobene Integrationsblocker

- Standardbibliothek-Importroot und reservierter Importalias
- Raw-Float-ABI und exakte 32-Bit-Integerbitmasken
- quadratische Allokationen in Retail-Parsern
- Signon-Folge `serverinfo -> prespawn -> spawn -> begin -> signon 4`
- `gfx.wad:conchars`
- PVS-Zeilenlänge als Integer-Shift
- Headless-Rendererzugriff im Validator
- Float-zu-Short-Konvertierung für `clc_move`
- linearer Client-Protokoll-Eventbuilder für dichte Serverframes
- korrekte `cstr`-Rückgabekonvertierung des Python-Referenzcompilers

## Noch offen für vollständige 1:1-Parität

- sämtliche QuakeC-Builtins und vollständige Edict-/Savegame-Semantik
- alle Serverphysik-, Entity-Linking-, Trigger- und Pusher-Sonderfälle
- vollständige Clientinterpolation, Temporary Entities und Effekte
- vollständige Lightmap-, Dynamic-Light-, Sky-, Water- und Model-Darstellung
- vollständige Console-, Scoreboard-, Intermission- und Menü-Backends
- vollständige Soundparität einschließlich Musik/CD-Audio
- UDP-Multiplayer, Verbindungsaufbau und zuverlässiger Datagrammtransport
- Demo-Kompatibilität und deterministisches Timing über längere Läufe
- historische IPX-/VCR-Pfade, sofern diese Parität gefordert ist
