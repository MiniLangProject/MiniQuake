# MiniQuake – 1:1-Port-Audit gegen WinQuake/GLQuake 1.09

Stand dieser Revision: **Gameplay-/Parity-Pass**

Dieses Dokument ist die verbindliche Bestandsaufnahme. Ein Eintrag „teilportiert“
bedeutet ausdrücklich, dass die vorhandene Implementierung noch nicht als
bit- oder verhaltensgleiche 1:1-Umsetzung abgenommen ist.

## Größenordnung und Ziel

Der bereitgestellte Originalbaum umfasst rund 98.000 C-/Headerzeilen in 195
C-/Headerdateien. MiniQuake umfasst in dieser Revision rund 17.000
MiniLang-Zeilen plus die schmale native Win32-/OpenGL-/Audio-/UDP-Brücke. Die
Zeilenzahl ist kein Qualitätsmaß, zeigt aber, dass der Port noch nicht als
vollständige mechanische Übersetzung des gesamten Originalbaums bezeichnet
werden darf.

Als primärer Zielpfad gilt **Windows + GLQuake/Protokoll 15 + lokaler
Singleplayer**. Plattformfremde DOS-, Linux-, Sun-, Next- und serielle Treiber
werden separat bewertet.

Statusschlüssel:

- **PORTIERT** – funktionsfähiger MiniLang-Pfad mit Regressionen und/oder realer Abnahme.
- **TEILPORTIERT** – wesentliche Logik vorhanden, Sonderfälle oder Parität fehlen.
- **PLATTFORMBRÜCKE** – absichtlich native Betriebssystem-/ABI-Grenze.
- **OFFEN** – noch kein vollständiger entsprechender Pfad.
- **NICHT ZIELRELEVANT** – fremde historische Plattform für den Windows-Port.

## 1. Common, Dateisystem, Speicher und Datenformate

| Original | MiniQuake | Status | Noch zu prüfen/portieren |
|---|---|---:|---|
| `common.c/.h` | `common.ml`, `byteio.ml`, `message.ml`, `sizebuf.ml`, `filesystem.ml` | PORTIERT/TEILPORTIERT | vollständige Kommandozeilen- und Pfad-Sonderfälle, registrierte/Shareware-Prüfungen |
| `crc.c/.h` | `crc.ml` | PORTIERT | gegen weitere Originalvektoren abnehmen |
| `cmd.c/.h` | `cmd.ml`, `host.ml` | TEILPORTIERT | vollständige Befehlsregistrierung, `stuffcmds`, Alias-/Wait-Ecken |
| `cvar.c/.h` | `cvar.ml` | TEILPORTIERT | Archive-Schreiben, Server-Cvar-Broadcast, vollständige Originalsemantik |
| `zone.c/.h` | `memory.ml` + MiniLang-GC | TEILPORTIERT | exakte Zone/Hunk/Cache-Semantik ist durch GC-Modell ersetzt |
| `wad.c/.h` | `wad.ml` | PORTIERT | vollständige Fehlerparität |
| `model.c`, `gl_model.c` | `format/bsp.ml`, `format/mdl.ml`, `format/sprite.ml`, `model_registry.ml` | TEILPORTIERT | Cache-/Reload-Semantik, alle Fehlermeldungen, Animationsecken |
| `bspfile.h`, `modelgen.h`, `spritegn.h` | `types.ml`, Formatmodule | PORTIERT | Strukturvergleich weiter automatisieren |

## 2. Host, System und Windows-Plattform

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `host.c` | `host.ml`, `host_timing.ml` | TEILPORTIERT | vollständige Host-Error-/Abort-Semantik, Demo-/Server-Timing-Parität |
| `host_cmd.c` | `host.ml` | TEILPORTIERT | Save/Load, Name/Color, Connect/Reconnect, Status-/Cheat-Kommandos vollständig |
| `sys_win.c`, `sys_wind.c`, `conproc.c` | `platform/win32.ml`, native DLL | PLATTFORMBRÜCKE | Dedicated-Console-/WinQuake-IPC-Pfade |
| `in_win.c` | `input.ml`, native DLL | TEILPORTIERT | Joystick, vollständige Key-Event-/Wheel-Semantik |
| `vid_win.c`, `gl_vidnt.c` | native DLL, `render/gl11.ml` | TEILPORTIERT | Modusliste, Gamma-Ramp, Video-Menü, Resize-/Displaywechsel-Parität |

## 3. Client und Protokoll

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `cl_main.c` | `client.ml`, `client_state.ml` | TEILPORTIERT | vollständige Disconnect-/Reconnect-/Demo-/Interpolation-Zustände |
| `cl_input.c` | `input.ml`, `protocol_write.ml` | TEILPORTIERT | alle `+`-Buttons, Impuls-/Mlook-/Klook-/Strafe-Ecken |
| `cl_parse.c` | `client_protocol.ml`, `client.ml`, `client_effects.ml` | TEILPORTIERT | alle svc-Sonderfälle, genaue Entity-Lerp-/Stat-Semantik |
| `cl_tent.c` | `temp_entities.ml`, `particles.ml`, Renderer | TEILPORTIERT | alle Beam-/Explosion-/Sound-/Dlight-Sonderfälle |
| `cl_demo.c` | `demo.ml`, `demo_player.ml` | TEILPORTIERT | zeitgenaue Wiedergabe, Aufnahme und längere Original-Demos |
| `protocol.h` | `constants.ml`, Protokollmodule | PORTIERT/TEILPORTIERT | komplette Paketvergleichstests |

### In dieser Revision behoben

- Der integrierte Loopback-Client schreibt seine **alte, quantisierte
  `svc_clientdata`-Bodenmarke und Geschwindigkeit nicht mehr in den
  autoritativen Server-Spieler zurück**. Dieser Feedbackpfad war die
  wahrscheinlichste Ursache für „fallen – hochgeschoben werden – erneut
  fallen“.
- `SV_WriteClientdataToMessage` überträgt `SU_WEAPON` immer und liefert
  Punch-/Velocity-/Armor-/Weaponframe-Daten. Damit kann das Viewmodel nach dem
  Signon sichtbar werden.
- Lokale Präzision wird für Ursprung, Winkel, Bodenstatus, Geschwindigkeit,
  Gesundheit und Inventar durch Regressionen geschützt.

## 4. Server, Welt und Physik

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `world.c/.h` | `world_bsp.ml`, `world_hull.ml`, `server_collision.ml` | TEILPORTIERT | vollständige Area-Node-/Linking-Parität, Rotations-/BSP-Entity-Ecken |
| `sv_main.c` | `server.ml` | TEILPORTIERT | vollständige Datagramm-/Clientmanagement-/Overflow-Parität |
| `sv_user.c` | `player_move.ml`, `physics.ml`, `server.ml` | TEILPORTIERT | WaterJump, Edgefriction, idealpitch, alle Cheat-/Pause-/Clientzustände |
| `sv_phys.c` | `physics.ml`, `server.ml`, `server_collision.ml` | TEILPORTIERT | sämtliche Push-/Toss-/Bounce-/Noclip-/Follow-Sonderfälle beweisen |
| `sv_move.c` | `server_move.ml` | TEILPORTIERT | Monsterbewegung in allen Originalmaps und auf bewegten BSP-Modellen abnehmen |

### In dieser Revision behoben/ergänzt

- Mehrfach-Bump-/Mehrfach-Plane-FlyMove und WinQuake-nähere Step-/Wall-Friction-
  Logik.
- Pusher werden nach der Clientphysik ausgeführt; die durch Tür, Lift oder Zug
  verschobene Spielerposition wird anschließend erneut aus dem QuakeC-Edict in
  den lokalen Spieler übernommen.
- `MOVETYPE_PUSH`-Entitäten verschieben berührte/riding Entities und rollen bei
  Blockierung zurück.
- Punktgroße Helfer-Entities blockieren normale Movers nicht.
- Monster-`SV_MoveStep`, `SV_StepDirection`, `SV_NewChaseDir`,
  `SV_MoveToGoal`, `SV_CheckBottom` und `SV_ChangeYaw` sind als eigener
  MiniLang-Pfad vorhanden.

**Abnahme noch nötig:** Start-Hub-Bodenstabilität, alle Treppen, Türen,
Plattformen, Züge, Teleporter und `e1m1`-Monster über längere interaktive Läufe.

## 5. QuakeC-VM und Edicts

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `pr_exec.c`, `pr_comp.h` | `quakec/vm.ml`, `quakec/opcodes.ml` | TEILPORTIERT | vollständige Fehler-/Profiling-/Statement-Parität, lange Originalspielabläufe |
| `pr_edict.c`, `progs.h`, `progdefs.h` | `quakec/edict.ml`, `edict.ml`, `server.ml` | TEILPORTIERT | exakte String-/Field-/Savegame-/Free-/Global-Semantik |
| `pr_cmds.c` | `quakec/builtins.ml`, Server-/Move-/Collisionmodule | TEILPORTIERT | vollständige Builtin-Tabelle und jedes Detail von `checkclient`, `tracetoss`, `watermove`, Debug-/Write-Pfaden |

Wichtige gameplayrelevante Builtins wie `setorigin`, `setmodel`, `setsize`,
`sound`, `traceline`, `spawn`, `remove`, `find`, Precache, `walkmove`,
`droptofloor`, `checkbottom`, `pointcontents`, `aim`, `changeyaw`,
`movetogoal`, Netzwerk-Writefunktionen und `makestatic` besitzen bereits
MiniLang-Implementierungen. Der Audit stuft den Bereich trotzdem als
teilportiert ein, bis die gesamte Originaltabelle und ihre Seiteneffekte
abgeglichen sind.

## 6. OpenGL-Renderer

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `gl_rmain.c`, `gl_refrag.c` | `render/world.ml`, `render/entities.ml` | TEILPORTIERT | exakte Efrag-/Visibility-/Entitysortierung, Viewmodel-Parität |
| `gl_rsurf.c`, `gl_rlight.c` | `render/world.ml` | TEILPORTIERT | dynamische Lightmaps, Lightstyles, Dlights, Fullbright-/Overbrightdetails |
| `gl_warp.c` | `render/world.ml` | TEILPORTIERT | Sky- und Water-Warp exakt |
| `gl_mesh.c`, Alias-Pfad | `render/entities.ml` | TEILPORTIERT | Commandlists, Interpolation, Shading, Player-Skins |
| `gl_draw.c`, `gl_screen.c` | `render/draw2d.ml`, `screen.ml`, `menu.ml`, `statusbar.ml` | TEILPORTIERT | Console-/Screen-/Loading-/Modal-/Intermission-Parität |
| `r_part.c`/GL-Partikel | `render/particles.ml` | TEILPORTIERT | Partikelgröße/-blend/-trail exakt |

### In dieser Revision

- Erstperson-Waffe wird über das aktuelle Weaponmodel/Weaponframe als Aliasmodel
  in komprimierter Depth-Range gezeichnet.
- `r_drawentities` und `r_drawviewmodel` werden getrennt beachtet.
- Die originale `gfx.wad`-Statusbar (`sbar`, `ibar`, Zahlen, Gesichter,
  Waffen-, Ammo-, Key-, Powerup- und Sigil-Pics) ersetzt den Textplatzhalter.

Der komplette Software-Renderer (`r_*.c`, `d_*.c`) ist **OFFEN**. Ein wirklich
vollständiger Port des gesamten WinQuake-Quellbaums muss ihn entweder ebenfalls
portieren oder das Ziel ausdrücklich auf GLQuake beschränken.

## 7. Menü, Konsole, Statusbar und Eingabe

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `menu.c` | `menu.ml`, `host.ml` | TEILPORTIERT | Save/Load-Backend, Setup-Eingabe/Farbtranslation, komplette Netzwerk- und Video-Menüs |
| `keys.c/.h` | `input.ml`, `host.ml` | TEILPORTIERT | vollständige Keydest-/Buttonstate-/Console-Completion-Semantik |
| `console.c` | `console.ml`, `screen.ml` | TEILPORTIERT | Resize, Notify, Completion, Scrollback/Download, exakte Animation |
| `sbar.c` | `statusbar.ml` | TEILPORTIERT | Scoreboard/Deathmatch, Face-Animation, Item-Flashzeiten, Intermission |
| `screen.c` | `screen.ml` | TEILPORTIERT | Loading plaque, modal messages, screenshots, centerprint timingdetails |

### In dieser Revision

- Das originale `M_Keys`-Layout mit 18 `bindnames` ist vorhanden.
- Enter startet die Tastenaufnahme; Backspace/Delete löscht; Escape bricht ab.
- Zwei Bindings pro Aktion werden angezeigt; `bind`, `unbind`, `unbindall` und
  `default.cfg` wirken auf dieselbe Bindingtabelle.
- Load/Save-, Setup- und Video-Seiten besitzen die Originalnavigation und
  Originalgrafik, aber die zugrundeliegenden Savegame-/Setup-/Videomodus-
  Funktionen sind noch nicht als 1:1 abgeschlossen.

## 8. Sound und Musik

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `snd_dma.c`, `snd_mem.c`, `snd_mix.c` | `sound/mixer.ml`, `sound/wav.ml` | TEILPORTIERT | alle Kanalregeln, Resampling-/Loop-/Paintbuffer-Parität |
| `snd_win.c` | native `waveOut`-Bridge | PLATTFORMBRÜCKE | Gerätewechsel/Fehlerdetails |
| `cd_audio.c`, `cd_win.c` | kein vollständiger Pfad | OFFEN | CD-Track-/Loop-/Pause-/Resume-Semantik oder kompatible Musikquelle |

## 9. Netzwerk

| Original | MiniQuake | Status | Noch offen |
|---|---|---:|---|
| `net_loop.c` | `net_loop.ml` | PORTIERT | weitere Stresstests |
| `net_dgrm.c` | `net_datagram.ml` | TEILPORTIERT | kompletter Reliable-Handshake, Fragmentierung, Timeout, Connect-Control |
| `net_main.c` | Host-/Client-/Servermodule | TEILPORTIERT | Hostcache, Listen/Search/Connect/Reconnect |
| `net_udp.c`, `net_wins.c` | `net_udp.ml`, native Winsock-Bridge | TEILPORTIERT | echter Multiplayer über zwei Prozesse |
| IPX, VCR, serial, modem | — | OFFEN/NICHT ZIELRELEVANT | nur nötig, wenn historische Vollparität gefordert wird |

## 10. Plattformfremde und historische Pfade

DOS-, Linux-, Sun-, Next-, SVGAlib-, X11-, serielle und Modemtreiber sind für
den Windows-x64-Port nicht aktiv. Ihre Gameplay-unabhängige Existenz im
Originalbaum wird im Audit nicht als Windows-Blocker behandelt. Historische
IPX-/VCR-Kompatibilität bleibt gesondert offen.

## Verbindliche nächste Abnahmereihenfolge

1. `start`: 5 Minuten stillstehen, Treppen, alle vier Episodentüren, Lift/
   Teleporter; keine Bodenoszillation.
2. `e1m1`: Waffe sichtbar, Schießen, Itemaufnahme, Monsterchase, Türen,
   Plattformen, Exit.
3. `e1m2` und `dm1`: Wasser, Aufzüge, Trigger, Teleporter, dynamische Entities.
4. Originaldemo(s): Protokoll-/Timing-/Renderingvergleich.
5. Save/Load und vollständige Menüs.
6. Renderer-, Sound- und Multiplayer-Parität.
7. Optional Software-Renderer und historische Treiber.

## Fazit

Diese Revision behebt konkrete Gameplayblocker und erweitert die Original-UI,
ist aber **noch kein vollständig abgenommener 1:1-Port des gesamten Quake-1-
Quellbaums**. Dieses Audit soll verhindern, dass ein spielbarer Zwischenstand
mit vollständiger Parität verwechselt wird.
