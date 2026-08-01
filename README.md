# MiniQuake – BP-085–BP-089R8

> Accepted Windows parent: BP-080–BP-084R2.
>
> This delivery keeps the complete `compat_109` release-candidate matrix,
> retains R7's stable in-place QuakeC Edict mirror and corrects the final
> listen-server resource-soak interpretation of WinQuake's monotonic client
> entity high-water.

R7 completed all primary/corpus traces and the 5,000-frame host soak. Its only
red gate was the listen-server predicate after a bounded client-slot catch-up
from 66 to the unchanged server high-water 67. R8 preserves all leak-sensitive
limits and binds the refined stability fingerprint `0xd0e3c03f`.

```text
compat_109_release_candidate_v1
fingerprint=0x29b72a98
accepted_contracts=18
pending_external_gates=2
stability_fingerprint=0xd0e3c03f
client_entity_policy=server_high_water_plus_existing_static_offset
```

R7 follows a Windows result in which `e1m2` trace B matched trace A through
frame 55 and then lost only `server edict 77 origin` during diagnostic
serialization. Edict objects, their nested vectors and the derived server
array are now retained across frames; only raw QuakeC words are copied into
existing fields. The VM's `numEdicts` high-water mark is preserved exactly,
including trailing free slots, and the actual production mirror is stressed
for 80 forced-GC passes at the e1m2 scale of 227 Edicts.

Run `TEST_BP-085-089R8.ps1`; see `docs/BP-085-089R8_TESTING.md`. No Quake game
data is bundled or collected.

---

# MiniQuake – BP-080–BP-084R2

> Accepted Windows parent: BP-075–BP-079R3.
>
> Current delivery closes source-function accounting for the selected
> WinQuake/GLQuake 1.09 profile and adds a deterministic four-map black-port
> corpus. R2 also namespaces all global test-entry helpers and verifies import-closure symbol arity before Windows compilation.

```text
black_port_source_109_frozen_v1
fingerprint=0x309b0737
target_definitions=1094
missing=0
```

Run the Windows acceptance with `TEST_BP-080-084R2.ps1`; see
`docs/BP-080-084R2_TESTING.md`. Output is streamed live and the package contains
no Quake game data.

---

# MiniQuake

MiniQuake ist ein MiniLang-Portierungsprojekt auf Basis des unter GPL
veröffentlichten WinQuake-/GLQuake-Quellcodes. Binärformate, Protocol 15,
QuakeC-Wörter, BSP-Konventionen und zentrale Engine-Abläufe orientieren sich am
Original. Win32, WGL/OpenGL 1.1, `waveOut`, Winsock und notwendige ABI-Helfer
liegen in schmalen nativen AMD64-Bridges; die Engine-Logik bleibt in MiniLang.

Quake-Spieldaten (`pak0.pak`, Maps, Sounds, Grafiken usw.) sind nicht enthalten.
MiniQuake verwendet die legal vorhandenen Daten einer installierten Quake-
Version.


## Paketstand: BP-080–BP-084R2 (Engine-Endstand BP-084)

BP-075–BP-079R3 is the accepted Windows parent. The current block adds exact
source-surface adapters for the remaining `cvar.c` and mechanical `cd_win.c`
functions, a deterministic inventory of 53 C units and 10 header/data units,
and byte-identical 64-frame traces for `start`, `e1m1`, `e1m2` and `e1m3`.

| Step | Scope | Fixtures |
|---|---|---:|
| BP-080 | cvar source surface | 20 |
| BP-081 | CD audio mechanical source surface | 20 |
| BP-082 | source function inventory | 20 |
| BP-083 | deterministic black-port corpus | 18 |
| BP-084 | source-guided closure | 24 |
| **Total** |  | **102** |

Candidate contract: `black_port_source_109_frozen_v1`, fingerprint
`0x309b0737`.

## Paketstand: BP-075–BP-079R2 (Engine-Endstand BP-079)

BP-070–BP-074R6 is the accepted Windows parent. R1 repaired inherited BP-029 checker lineage; R2 repairs inherited BP-036 view-checker lineage after the later source-correct C-`atoi` change. The current block closes `mathlib.c`, `chase.c`, `view.c`, `gl_screen.c`, `sbar.c` and the remaining numeric host-command conversion paths.

| Step | Scope | Fixtures |
|---|---|---:|
| BP-075 | mathlib and chase camera | 22 |
| BP-076 | view, palette and refdef | 22 |
| BP-077 | screen, loading and screenshots | 22 |
| BP-078 | statusbar and scoreboard | 22 |
| BP-079 | host-command and gameplay/presentation closure | 24 |
| **Total** |  | **112** |

Candidate contract: `gameplay_presentation_109_frozen_v1`, fingerprint `0xad91624c`.

## Paketstand: BP-070–BP-074R6 (Engine-Endstand BP-074)

BP-065–BP-069R1 is the accepted Windows engine parent. R1 repaired inherited checker lineage; R2 repaired the BP-070 compile gate and tightened the original common.c no-swap boundaries. R3 fixes the BP-071 synthetic shareware-state setup. R4 filters synthetic build workspaces during result collection. R5 fixes the animated-texture and Windows PowerShell 5.1 collector fixtures. R6 binds the original `Mod_LoadSubmodels` one-unit spread (`mins - 1`, `maxs + 1`) in both direct BSP and model-registry tests. The block closes common and CRC semantics, filesystem/PACK search paths, WAD graphics, BSP/MDL/SPR model assets and observable zone/hunk/cache behavior.

| Step | Scope | Fixtures |
|---|---|---:|
| BP-070 | common, byte order and CRC | 24 |
| BP-071 | filesystem and PACK | 24 |
| BP-072 | WAD and graphics lumps | 20 |
| BP-073 | BSP, MDL, sprite and model registry | 24 |
| BP-074 | zone, hunk, cache and closure | 24 |
| **Total** |  | **116** |

Candidate contract: `core_assets_memory_109_frozen_v1`, fingerprint `0x6c8d974d`.


## Paketstand: BP-065–BP-069 (Engine-Endstand BP-069)

BP-060–BP-064R6 is the fully accepted Windows parent. The result confirmed two
real Protocol-3 UDP server/client pairs with typed exit codes and PASS markers,
300 headless frames, byte-identical traces, audio evidence, framebuffer evidence
and UDP loopback.

```text
parent_result_sha256=5f9812a0527ea426889b4ae0d08e6e40bb2b715e32e232ebe215dd3ab99674a1
parent_trace_sha256=03656a0e9f3b13d4430014de3787053c204acdd1e7f2e33c292ee8ee2b47c8cc
parent_rolling_hash=d905b042
parent_render_tga_sha256=9047f96e9bef8e06035119ff71ddfe7ad4dcad89b4740c66618252a13cd166fb
```

The new cumulative frontend block contains:

| Step | Scope | Fixtures |
|---|---|---:|
| BP-065 | key routing, bindings and synthetic focus releases | 20 |
| BP-066 | mouse filtering and device-only state clearing | 22 |
| BP-067 | console notify and modal screen lifecycle | 22 |
| BP-068 | menu toggle, save and Windows option behavior | 24 |
| BP-069 | video/focus/frontend closure contract | 24 |
| **Total** |  | **112** |

Candidate contract:

```text
frontend_109_frozen_v1
Contract-Fingerprint: 0x924251fa
```

The block preserves every previously accepted Protocol 15, QuakeC, physics,
host, renderer, audio and network/platform contract.

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

- 125 MiniLang-Quelldateien und 164 MiniLang-Testdateien
- 16 Kern-, 24 Meilenstein-, 10 Diagnose-, 15 Wire-, 14 Command-/Update-,
  17 Serverdaten-, 22 Event-, 28 Runtime-Event-, 12 Signon-, 14 Delivery-,
  18 Datagramm-, 19 Demo- und 15 Closure-Prüfungen
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

## BP-010: bytegenaue Protocol-15-Grundschicht

Vor BP-010 verwendeten `MSG_WriteString` und `SZ_Print` direkt
`bytes(minilangString)`. Das ist UTF-8 und war daher für originale Quake-Bytes
über 0x7f nicht wire-kompatibel. BP-010 trennt die Unicode-Darstellung von der
Quake-Einbyte-C-String-Darstellung und ergänzt rohe Read-/Write-Helfer.

Die gültigen Bytepfade entsprechen dem Original. Payload und Abschluss-NUL
werden wie in `SZ_Write(..., strlen+1)` atomar reserviert; dadurch stimmt auch
der Overflow-Neustart an der letzten freien Byteposition. `SZ_Print` reserviert
seinen gültigen No-NUL-Pfad ebenfalls in einem Schritt.

Drei undefinierte beziehungsweise speicherunsichere C-Pfade werden absichtlich
nicht nachgebildet: ein abgeschnittener `MSG_ReadFloat` setzt `badRead` und
liefert `-1.0`; `SZ_Print` behandelt `cursize==0` ohne `data[-1]`; und ein
Overflow aus dem alten Trailing-NUL-Zweig startet sicher mit der vollständigen
neuen C-Zeichenkette, statt nach `SZ_Clear` vor `data[0]` zu schreiben. Diese
Abweichungen ändern keine gültigen Protocol-15-Nachrichten.

## BP-011: Signon, Kommandoströme und Fast Entity Updates

BP-011 bindet die originalen Signonübergänge, alle gültigen Client-/Server-
Kommandorahmen und die baseline-relative Fast-Update-Bitwahl. Stufe 4 erzeugt
keinen eigenen Signonmarker; das erste Fast Update schließt den Client-Signon
ab. Ein C-Oracle, ein unabhängiger Pythonprüfer und 14 MiniLang-Fixtures
überwachen die Wirebytes und Parserreihenfolge.

## BP-012: Serverinfo, Clientdata, Sound, Baselines und Paketplanung

BP-012 vereinheitlicht die produktiven Serverwriter in
`protocol_serverdata.ml`. Das gemeinsame Modul wird sowohl von der integrierten
Serverpipeline als auch von der direkten `sv_main`-Port-API verwendet. Elf
vollständige C-abgeleitete Payloads sowie 25 Planungs-/Grenzfälle überwachen
Serverinfo, Sound, Clientdata, Baselines, Datagrammrest, Fast-Update-Größen und
die Reliable-Lifecycle-Entscheidungen.

Die einzige bewusst sichere Wire-nahe Abweichung betrifft den historischen
16-Byte-Update-Gate: MiniQuake behält ihn bei, schreibt ein 17-/18-Byte-Update
aber nur, wenn es tatsächlich vollständig in den Zielpuffer passt.

## BP-012R1: PlayerState-zu-Clientdata-Ground-Adapter

BP-012R1 repariert die einzige im BP-012-Windows-Lauf beobachtete Abweichung.
Die gemeinsame Funktion `playerProtocolFlags` erhält sämtliche Flagbits außer
`FL_ONGROUND` und rekonstruiert dieses eine Bit aus `PlayerState.onGround`.
Dieser Wert dient ausschließlich als Adapter/Fallback. Sobald ein echter
QuakeC-Edictzustand vorhanden ist, gewinnt weiterhin dessen `flags`-Feld genau
wie in `SV_WriteClientdataToMessage` des Originals.

Die zusätzliche Fixture prüft beide Mirror-Richtungen und den vollständigen
Wire-Roundtrip. Die bestehende Meilensteinfixture 19 bleibt unverändert und
stellt sicher, dass der reale BP-012-Fehler nicht zurückkehrt.

## BP-013: statische Ereignisse, Partikel, Scoreboard und Disconnect

`protocol_events.ml` ist die gemeinsame Protocol-15-Schicht für statische
Entities, statische Sounds, Partikel, Name/Farbe/Frags und den abschließenden
Disconnect. Integrierter Server, direkte `sv_main`-Port-API und QuakeC-Builtins
rufen dieselben Writer auf. Dadurch gibt es für die fünf Produktionspfade keine
separaten manuellen Bytefolgen mehr.

Die Golden-Evidenz umfasst 15 vollständige C-abgeleitete Wirevektoren und 13
semantische Grenzfälle. Dazu kommen 22 MiniLang-Fixtures mit Parser-Roundtrips,
Latin-1-Namen, fractional-frag-Rebroadcast, Reliable-Overflow, geordnetem
Disconnect und Scoreboard-Reset. Gültige Protocol-15-Pakete bleiben bytegenau;
kontrollierte MiniLang-Fehler ersetzen lediglich speicherunsichere C-Abbrüche.

## BP-014 und BP-014R1: Runtime-Ereignisse und Beam-Sicht

`protocol_transients.ml` bleibt die gemeinsame Protocol-15-Schicht für
Temporary-Entity-Payloads, dynamische und gestoppte Sounds, C-Float-
Konvertierungen, Beam-Slots und Reconnect. BP-014 lieferte 10 vollständige
Wirevektoren, 49 semantische Grenzfälle und 27 MiniLang-Fixtures.

BP-014R1 ergänzt die entscheidende Zustandsmodelltrennung: Der kompakte
24-Slot-Zustand behält abgelaufene Einträge, damit `CL_ParseBeam` dieselbe
Entity weiterhin im ursprünglichen Slot ersetzt. Eine getrennte aktive Sicht
filtert diese Einträge für `CL_UpdateTEnts`, Rendering und
`client_effects.pruneTemporary`. Die Runtime-Event-Suite umfasst nun 28
Fixtures; die bestehende Meilensteinfixture 12 bleibt unverändert.

## Build und Abnahme von BP-055–BP-059R2 unter Windows

Das vollständige ZIP in einen neuen, leeren Ordner entpacken:

```powershell
$QuakeBase = "C:\Pfad\zu\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"  # muss True liefern

.\TEST_BP-055-059R2.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Ein optionaler Original-GLQuake-Bildkorpus kann mit
`-OriginalRenderReference C:\Pfad\zu\OriginalCaptures` ergänzt werden.

Erwartete neue Marker:

```text
MiniQuake BP-055 audio memory tests passed: 20
MiniQuake BP-056 audio DMA tests passed: 22
MiniQuake BP-057 audio mixer tests passed: 22
MiniQuake BP-058 audio Win32 tests passed: 20
MiniQuake BP-059 audio closure tests passed: 24
MiniQuake BP-059 retail audio evidence: PASS
MiniQuake BP-055-059R2 acceptance test: PASS
```

## Build und Abnahme von BP-045–BP-049R2 unter Windows

R2 korrigiert ausschließlich die BP-048-Summary-Fixture: JSON wird nun über
`bytes(text)` bytegenau geprüft. Der R1-Lauf hatte 96 PASS, eine fehlerhafte
Fixture und 11 wegen fehlendem `-QuakeBase` übersprungene Echtdaten-Gates.
Eine normale R2-Abnahme verlangt deshalb einen gültigen Quake-Basispfad mit
`id1\pak0.pak`. Unter `src/` und `native/` wurde nichts verändert.

Empfohlen ist `MiniLangCompilerPy`. Das vollständige ZIP muss in einen neuen,
leeren Ordner entpackt werden. Die Abnahme baut den vollständigen BP-049-
Endstand einmal und führt unabhängige Testgruppen weiter aus:

```powershell
cd C:\Pfad\MiniQuake_BP-045-049R3

$QuakeBase = "C:\Pfad\zu\Quake"
Test-Path "$QuakeBase\id1\pak0.pak"  # muss True liefern

.\TEST_BP-045-049R3.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Game id1 `
  -Map start `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests `
  -ContinueIndependentTests `
  -BisectOnFailure
```

Nur bauen und alle assetfreien Tests ausführen:

```powershell
.\build.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy
```

Das erwartete Testende enthält zusätzlich zu allen Elternregressionen:

```text
MiniQuake BP-045 alias model tests passed: 22
MiniQuake BP-046 sprite sync tests passed: 22
MiniQuake BP-047 2D/HUD tests passed: 24
MiniQuake BP-048 render evidence tests passed: 18
MiniQuake BP-049 model/UI/render closure tests passed: 24
MiniQuake BP-045-049R3 acceptance test: PASS
```

Nützliche Buildschalter:

```powershell
.\build.ps1 -SkipTests
.\build.ps1 -SkipMilestoneTests
.\build.ps1 -NoRunTests
.\build.ps1 -NetworkTests
.\build.ps1 -RebuildNative
.\build.ps1 -SkipPreflight   # nur zur Diagnose; nicht für Abnahmen
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

## Validierung, deterministische Traces und Rückmeldung

Bevorzugt wird der Pakettest aus `docs/BP-045-049R3_TESTING.md`:

```powershell
.\TEST_BP-045-049R3.ps1 `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy `
  -QuakeBase $QuakeBase `
  -Frames 300 `
  -TraceFrames 128 `
  -RenderEvidenceFrame 128 `
  -NetworkTests
```

Der Wrapper ist ebenfalls vorhanden:

```powershell
.\scripts\validate_real_game.ps1 `
  -QuakeBase $QuakeBase `
  -Compiler C:\Pfad\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\Pfad\MiniLangCompilerPy
```

Ein manueller deterministischer Trace:

```powershell
.\build\MiniQuake.exe `
  --compat-trace $QuakeBase start 120 .\build\manual-start `
  -game id1
```

Ein manueller Framebuffer-Beweis:

```powershell
.\build\MiniQuake.exe `
  --render-evidence $QuakeBase start 128 .\build\manual-frame `
  -game id1
```

Erzeugt werden `manual-frame.tga` und `manual-frame-summary.json`. Zwei Bilder
lassen sich exakt oder über SSIM vergleichen:

```powershell
python .\tools\compare_render_evidence.py `
  .\build\frame-a.tga .\build\frame-b.tga `
  --require-exact --min-ssim 1.0
```

Nach jedem PASS, FAIL oder Crash erzeugt:

```powershell
.\COLLECT_RESULTS.ps1
```

sein Rückmelde-ZIP mit Logs, JSON, `.mqtrace` und `.tga`, aber ohne Quake-Daten
und ohne Binärdateien. EXE- und DLL-Hashes werden nur in Metadaten festgehalten.

## Statische Verifikation

```powershell
python .\tools\verify.py .
python .\tools\bp045_alias_model_checker.py --root .
python .\tools\bp046_sprite_sync_checker.py --root .
python .\tools\bp047_render_ui_checker.py --root .
python .\tools\bp048_render_evidence_checker.py
python .\tools\bp049_model_ui_render_checker.py
python .\tools\compare_render_evidence.py --self-test
```

Der Verifier kontrolliert Manifest, Package-/Dateipfadkonsistenz, direkte und
transitive Importaliases, Entry-Symbol-Shadows, beide nativen ABIs, AMD64-PE-
Merkmale, den angenommenen BP-040–BP-044R3-Elternstand und den neuen
Model-/UI-/Rendervertrag.

## Native Bridges neu bauen

Die von BP-000R1 übernommene Textbridge ist vollständig aus dem Paket
reproduzierbar:

```powershell
python .\native\build_text_bridge.py --clean
```

Dafür werden `clang-cl` und `lld-link` benötigt. Der finale Link verwendet
`/Brepro`. `build.ps1 -RebuildNative` führt denselben Schritt aus.

Die Hauptbridge würde grundsätzlich mit

```powershell
python .\native\build_bridge.py --clean
```

neu gebaut. Dem gelieferten Ausgangsbaum fehlt jedoch
`third_party\stb\stb_vorbis.c`; BP-012 behält deshalb die statisch geprüfte
vorgefertigte Hauptbridge bei und gibt beim angeforderten Neubau eine klare
Warnung aus.

## Evidenzstand und nächste Pakete

BP-055–BP-059R2 ist die bestätigte Elternbasis. BP-060–BP-064R2 baute 65/65
Programme und bestätigte sämtliche geerbten und neuen Netzwerk-/Plattformtests,
die installierten Spieldaten, 300 Headless-Frames und die Retail-Audio-Evidenz.
Trace A lief 128/128 Frames; Trace B war bis Frame 25 identisch und traf dann in
der kanonischen Diagnose einen strukturell ungültigen verschachtelten Vektor.

R4 behält die originalgetreue Protocol-3-Regelenumeration, den Live-Output und die GC-Verwurzelung aus R3
bei, verwurzelt heap-basierte Konstruktorargumente vor der äußeren Struct-
Allokation und liefert künftig präzise Entity-/Feldfehler. Der maschinenlesbare
Stand steht in `PORT_LEDGER.json` und `BLOCK_LEDGER.json`; der aktuelle
Testablauf in `docs/BP-060-064R6_TESTING.md`.

## Lizenz

Quake-abgeleitete Arbeiten und dieser Portierungsstand werden unter
GPL-2.0-or-later verteilt. Siehe `COPYING`.
