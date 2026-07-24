# GLQuake-Port-Inventur

Diese Datei wird durch `tools/generate_port_inventory.py` erzeugt. **`located` und `candidate` sind keine Paritätsnachweise.** Sie belegen nur einen Codeort beziehungsweise einen zu prüfenden Namenskandidaten.

Referenz: `bf4ac424ce754894ac8f1dae6a3981954bc9852d`, Konfiguration `winquake - Win32 GL Release`.

## Zusammenfassung

- Ausgewählte C-Dateien: **56**
- Ausgewählte x86-Assemblerdateien: **4**
- Transitiv benötigte Header: **51**
- Logische C/H-Einheiten: **67** (63 Ziel, 4 ausgeschlossen)
- Ziel-C/H-Einheiten mit bestehendem MiniLang-Pendant: **63/63**
- C-Funktionsdefinitionen: **1149**
- Ziel-C-Funktionsdefinitionen mit Codeort: **1069/1069**
- Funktions-Codeorte: **1069 located**, **0 candidate**, **0 unmapped**, **80 excluded**
- Assemblerexporte: **9 located**, **0 candidate**, **0 unmapped**, **4 excluded**
- Ziel-Assemblerexporte mit Codeort: **9/9**
- Öffentliche Header-Symbole: **1929** (718 ohne Codeort)
- Strikte Funktionsparität wird getrennt in `audit/BEHAVIORAL_PARITY.json` und `docs/BEHAVIORAL_PARITY.md` geführt.

## Logische Einheiten

| Einheit | Originaldateien | MiniLang-Pendant | Status | Funktionen L/C/U/X | ASM L/C/U/X |
|---|---|---|---|---:|---:|
| `alias_tables` | `anorm_dots.h`, `anorms.h` | `src/miniquake/render/alias_normals.ml`, `src/miniquake/render/alias_mesh.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `bsp_format` | `bspfile.h` | `src/miniquake/format/bsp.ml`, `src/miniquake/constants.ml`, `src/miniquake/types.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `cd_audio` | `cd_win.c`, `cdaudio.h` | `src/miniquake/sound/cd_audio.ml`, `src/miniquake/sound/mixer.ml`, `src/miniquake/filesystem.ml`, `src/miniquake/host.ml`, `src/miniquake/native.ml` | modern-replacement-located | 8/0/0/4 | 0/0/0/0 |
| `chase` | `chase.c` | `src/miniquake/chase.ml` | all-function-code-locations-found | 4/0/0/0 | 0/0/0/0 |
| `cl_demo` | `cl_demo.c` | `src/miniquake/demo.ml`, `src/miniquake/demo_player.ml`, `src/miniquake/client.ml` | all-function-code-locations-found | 8/0/0/0 | 0/0/0/0 |
| `cl_input` | `cl_input.c` | `src/miniquake/input.ml`, `src/miniquake/protocol_write.ml`, `src/miniquake/client.ml` | all-function-code-locations-found | 42/0/0/0 | 0/0/0/0 |
| `cl_main` | `cl_main.c`, `client.h` | `src/miniquake/client.ml`, `src/miniquake/client_state.ml`, `src/miniquake/client_protocol.ml`, `src/miniquake/client_effects.ml`, `src/miniquake/demo.ml`, `src/miniquake/demo_player.ml`, `src/miniquake/input.ml`, `src/miniquake/protocol_write.ml`, `src/miniquake/temp_entities.ml`, `src/miniquake/particles.ml`, `src/miniquake/types.ml` | all-function-code-locations-found | 15/0/0/0 | 0/0/0/0 |
| `cl_parse` | `cl_parse.c` | `src/miniquake/client_protocol.ml`, `src/miniquake/client.ml`, `src/miniquake/client_effects.ml` | all-function-code-locations-found | 11/0/0/0 | 0/0/0/0 |
| `cl_tent` | `cl_tent.c` | `src/miniquake/temp_entities.ml`, `src/miniquake/client_effects.ml`, `src/miniquake/particles.ml` | all-function-code-locations-found | 5/0/0/0 | 0/0/0/0 |
| `cmd` | `cmd.c`, `cmd.h` | `src/miniquake/cmd.ml`, `src/miniquake/host.ml` | all-function-code-locations-found | 21/0/0/0 | 0/0/0/0 |
| `common` | `common.c`, `common.h` | `src/miniquake/common.ml`, `src/miniquake/filesystem.ml`, `src/miniquake/byteio.ml`, `src/miniquake/message.ml`, `src/miniquake/sizebuf.ml`, `src/miniquake/pak.ml`, `src/miniquake/launch.ml` | all-function-code-locations-found | 75/0/0/0 | 0/0/0/0 |
| `conproc` | `conproc.c`, `conproc.h` | `src/miniquake/conproc.ml`, `src/miniquake/platform/win32.ml`, `src/miniquake/native.ml` | all-function-code-locations-found | 11/0/0/0 | 0/0/0/0 |
| `console` | `console.c`, `console.h` | `src/miniquake/console.ml`, `src/miniquake/screen.ml` | all-function-code-locations-found | 17/0/0/0 | 0/0/0/0 |
| `crc` | `crc.c`, `crc.h` | `src/miniquake/crc.ml` | all-function-code-locations-found | 3/0/0/0 | 0/0/0/0 |
| `cvar` | `cvar.c`, `cvar.h` | `src/miniquake/cvar.ml` | all-function-code-locations-found | 9/0/0/0 | 0/0/0/0 |
| `gl_draw` | `draw.h`, `gl_draw.c` | `src/miniquake/render/draw2d.ml`, `src/miniquake/render/gl11.ml`, `src/miniquake/menu.ml`, `src/miniquake/statusbar.ml` | all-function-code-locations-found | 33/0/0/0 | 0/0/0/0 |
| `gl_mesh` | `gl_mesh.c` | `src/miniquake/render/alias_mesh.ml`, `src/miniquake/render/entities.ml` | all-function-code-locations-found | 4/0/0/0 | 0/0/0/0 |
| `gl_model` | `gl_model.c`, `gl_model.h`, `model.h` | `src/miniquake/format/bsp.ml`, `src/miniquake/format/mdl.ml`, `src/miniquake/format/sprite.ml`, `src/miniquake/model_registry.ml`, `src/miniquake/world_bsp.ml`, `src/miniquake/types.ml` | all-function-code-locations-found | 39/0/0/0 | 0/0/0/0 |
| `gl_refrag` | `gl_refrag.c` | `src/miniquake/render/gl_refrag.ml`, `src/miniquake/render/original.ml`, `src/miniquake/render/entities.ml` | all-function-code-locations-found | 4/0/0/0 | 0/0/0/0 |
| `gl_rlight` | `gl_rlight.c` | `src/miniquake/render/gl_rlight.ml`, `src/miniquake/render/world.ml` | all-function-code-locations-found | 8/0/0/0 | 0/0/0/0 |
| `gl_rmain` | `gl_rmain.c`, `glquake.h` | `src/miniquake/render/gl_rmain.ml`, `src/miniquake/render/original.ml`, `src/miniquake/render/alias_mesh.ml`, `src/miniquake/render/gl_rlight.ml`, `src/miniquake/render/gl_warp.ml`, `src/miniquake/render/gl11.ml`, `src/miniquake/render/draw2d.ml`, `src/miniquake/render/world.ml`, `src/miniquake/render/entities.ml`, `src/miniquake/render/particles.ml`, `src/miniquake/view.ml`, `src/miniquake/types.ml` | all-function-code-locations-found | 20/0/0/0 | 0/0/0/0 |
| `gl_rmisc` | `gl_rmisc.c` | `src/miniquake/render/gl_rmisc.ml`, `src/miniquake/render/original.ml`, `src/miniquake/render/world.ml`, `src/miniquake/render/entities.ml`, `src/miniquake/render/particles.ml` | all-function-code-locations-found | 8/0/0/0 | 0/0/0/0 |
| `gl_rsurf` | `gl_rsurf.c` | `src/miniquake/render/world.ml` | all-function-code-locations-found | 23/0/0/2 | 0/0/0/0 |
| `gl_screen` | `gl_screen.c`, `screen.h` | `src/miniquake/screen.ml`, `src/miniquake/console.ml`, `src/miniquake/menu.ml`, `src/miniquake/statusbar.ml` | all-function-code-locations-found | 23/0/0/0 | 0/0/0/0 |
| `gl_test` | `gl_test.c` | `src/miniquake/render/gl_test.ml`, `src/miniquake/gl_smoke.ml` | header-or-table-unit | 0/0/0/5 | 0/0/0/0 |
| `gl_vidnt` | `gl_vidnt.c`, `vid.h` | `src/miniquake/gl_vidnt.ml`, `src/miniquake/platform/win32.ml`, `src/miniquake/render/gl11.ml`, `src/miniquake/native.ml` | native-bridge-located | 43/0/0/1 | 0/0/0/0 |
| `gl_warp` | `gl_warp.c`, `gl_warp_sin.h` | `src/miniquake/render/gl_warp.ml`, `src/miniquake/render/world.ml` | all-function-code-locations-found | 8/0/0/11 | 0/0/0/0 |
| `host` | `host.c` | `src/miniquake/host.ml`, `src/miniquake/host_timing.ml` | all-function-code-locations-found | 19/0/0/2 | 0/0/0/0 |
| `host_cmd` | `host_cmd.c` | `src/miniquake/host.ml`, `src/miniquake/savegame.ml`, `src/miniquake/server.ml` | all-function-code-locations-found | 39/0/0/4 | 0/0/0/0 |
| `in_win` | `in_win.c`, `input.h` | `src/miniquake/input.ml`, `src/miniquake/platform/win32.ml`, `src/miniquake/native.ml` | native-bridge-located | 23/0/0/0 | 0/0/0/0 |
| `keys` | `keys.c`, `keys.h` | `src/miniquake/keys.ml`, `src/miniquake/input.ml`, `src/miniquake/host.ml`, `src/miniquake/menu.ml`, `src/miniquake/console.ml` | all-function-code-locations-found | 12/0/0/0 | 0/0/0/0 |
| `mathlib` | `math.s`, `mathlib.c`, `mathlib.h` | `src/miniquake/mathlib.ml` | all-function-code-locations-found | 24/0/0/0 | 2/0/0/1 |
| `menu` | `menu.c`, `menu.h` | `src/miniquake/menu.ml`, `src/miniquake/host.ml` | all-function-code-locations-found | 68/0/0/6 | 0/0/0/0 |
| `model_format` | `modelgen.h` | `src/miniquake/format/mdl.ml`, `src/miniquake/model_registry.ml`, `src/miniquake/constants.ml`, `src/miniquake/types.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `net_dgrm` | `net_dgrm.c`, `net_dgrm.h` | `src/miniquake/net_loop.ml`, `src/miniquake/net_datagram.ml`, `src/miniquake/net_udp.ml`, `src/miniquake/net_control.ml` | all-function-code-locations-found | 24/0/0/1 | 0/0/0/0 |
| `net_loop` | `net_loop.c`, `net_loop.h` | `src/miniquake/net_loop.ml` | all-function-code-locations-found | 13/0/0/0 | 0/0/0/0 |
| `net_main` | `net.h`, `net_main.c` | `src/miniquake/net_main.ml`, `src/miniquake/net_wins.ml`, `src/miniquake/net_loop.ml`, `src/miniquake/net_datagram.ml`, `src/miniquake/net_udp.ml`, `src/miniquake/net_control.ml`, `src/miniquake/client.ml`, `src/miniquake/server.ml` | all-function-code-locations-found | 24/0/0/1 | 0/0/0/0 |
| `net_vcr` | `net_vcr.c`, `net_vcr.h` | — | out-of-scope | 0/0/0/11 | 0/0/0/0 |
| `net_win` | `net_win.c` | `src/miniquake/net_loop.ml`, `src/miniquake/net_datagram.ml`, `src/miniquake/net_udp.ml`, `src/miniquake/native.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `net_wins` | `net_wins.c`, `net_wins.h` | `src/miniquake/net_wins.ml`, `src/miniquake/net_udp.ml`, `src/miniquake/native.ml` | native-bridge-located | 22/0/0/0 | 0/0/0/0 |
| `net_wipx` | `net_wipx.c`, `net_wipx.h` | — | out-of-scope | 0/0/0/18 | 0/0/0/0 |
| `pr_cmds` | `pr_cmds.c` | `src/miniquake/quakec/builtins.ml` | all-function-code-locations-found | 67/0/0/7 | 0/0/0/0 |
| `pr_edict` | `pr_edict.c` | `src/miniquake/quakec/edict.ml`, `src/miniquake/savegame.ml`, `src/miniquake/server.ml` | all-function-code-locations-found | 29/0/0/0 | 0/0/0/0 |
| `pr_exec` | `pr_exec.c` | `src/miniquake/quakec/vm.ml`, `src/miniquake/quakec/opcodes.ml` | all-function-code-locations-found | 7/0/0/0 | 0/0/0/0 |
| `protocol` | `protocol.h` | `src/miniquake/constants.ml`, `src/miniquake/client_protocol.ml`, `src/miniquake/protocol_write.ml`, `src/miniquake/message.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `quakec_abi` | `pr_comp.h`, `progdefs.h`, `progs.h` | `src/miniquake/format/progs.ml`, `src/miniquake/constants.ml`, `src/miniquake/quakec/opcodes.ml`, `src/miniquake/quakec/vm.ml`, `src/miniquake/quakec/edict.ml`, `src/miniquake/types.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `quakedef` | `quakedef.h` | `src/miniquake/types.ml`, `src/miniquake/constants.ml`, `src/miniquake/host.ml`, `src/miniquake/server.ml`, `src/miniquake/client.ml`, `src/miniquake/input.ml`, `src/miniquake/console.ml`, `src/miniquake/screen.ml`, `src/miniquake/view.ml`, `src/miniquake/filesystem.ml`, `src/miniquake/cvar.ml`, `src/miniquake/cmd.ml`, `src/miniquake/memory.ml`, `src/miniquake/audio.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `r_part` | `r_part.c` | `src/miniquake/particles.ml`, `src/miniquake/render/particles.ml` | all-function-code-locations-found | 13/0/0/1 | 0/0/0/0 |
| `render_types` | `render.h` | `src/miniquake/types.ml`, `src/miniquake/render/world.ml`, `src/miniquake/render/entities.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `resource` | `resource.h` | `src/miniquake/platform/win32.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `sbar` | `sbar.c`, `sbar.h` | `src/miniquake/statusbar.ml` | all-function-code-locations-found | 24/0/0/0 | 0/0/0/0 |
| `serial_network` | `net_ser.h` | — | out-of-scope | 0/0/0/0 | 0/0/0/0 |
| `snd_dma` | `snd_dma.c`, `sound.h` | `src/miniquake/sound/snd_dma.ml`, `src/miniquake/sound/mixer.ml`, `src/miniquake/audio.ml`, `src/miniquake/types.ml` | all-function-code-locations-found | 29/0/0/0 | 0/0/0/0 |
| `snd_mem` | `snd_mem.c` | `src/miniquake/sound/snd_mem.ml`, `src/miniquake/sound/wav.ml`, `src/miniquake/sound/mixer.ml` | all-function-code-locations-found | 8/0/0/0 | 0/0/0/0 |
| `snd_mix` | `snd_mix.c`, `snd_mixa.s` | `src/miniquake/sound/snd_mix.ml`, `src/miniquake/sound/mixer.ml` | all-function-code-locations-found | 7/0/0/0 | 2/0/0/0 |
| `snd_win` | `snd_win.c` | `src/miniquake/sound/snd_win.ml`, `src/miniquake/audio.ml`, `src/miniquake/native.ml` | native-bridge-located | 9/0/0/0 | 0/0/0/0 |
| `software_renderer_headers` | `d_iface.h`, `dosisms.h`, `r_local.h`, `r_shared.h` | — | out-of-scope | 0/0/0/0 | 0/0/0/0 |
| `sprite_format` | `spritegn.h` | `src/miniquake/format/sprite.ml`, `src/miniquake/constants.ml`, `src/miniquake/types.ml` | header-or-table-unit | 0/0/0/0 | 0/0/0/0 |
| `sv_main` | `server.h`, `sv_main.c` | `src/miniquake/sv_main.ml`, `src/miniquake/sv_user.ml`, `src/miniquake/server.ml`, `src/miniquake/server_move.ml`, `src/miniquake/physics.ml`, `src/miniquake/server_collision.ml`, `src/miniquake/world.ml`, `src/miniquake/types.ml` | all-function-code-locations-found | 20/0/0/0 | 0/0/0/0 |
| `sv_move` | `sv_move.c` | `src/miniquake/server_move.ml` | all-function-code-locations-found | 7/0/0/0 | 0/0/0/0 |
| `sv_phys` | `sv_phys.c` | `src/miniquake/physics.ml`, `src/miniquake/server.ml`, `src/miniquake/server_collision.ml` | all-function-code-locations-found | 22/0/0/4 | 0/0/0/0 |
| `sv_user` | `sv_user.c` | `src/miniquake/sv_user.ml`, `src/miniquake/player_move.ml`, `src/miniquake/physics.ml`, `src/miniquake/server.ml` | all-function-code-locations-found | 12/0/0/1 | 0/0/0/0 |
| `sys_win` | `sys.h`, `sys_win.c`, `sys_wina.s`, `winquake.h` | `src/miniquake/sys_win.ml`, `src/miniquake/host.ml`, `src/miniquake/platform/win32.ml`, `src/miniquake/native.ml` | native-bridge-located | 27/0/0/0 | 4/0/0/3 |
| `view` | `view.c`, `view.h` | `src/miniquake/view.ml` | all-function-code-locations-found | 23/0/0/1 | 0/0/0/0 |
| `wad` | `wad.c`, `wad.h` | `src/miniquake/wad.ml` | all-function-code-locations-found | 6/0/0/0 | 0/0/0/0 |
| `world` | `world.c`, `world.h`, `worlda.s` | `src/miniquake/world.ml`, `src/miniquake/server_collision.ml`, `src/miniquake/world_bsp.ml`, `src/miniquake/world_hull.ml` | all-function-code-locations-found | 18/0/0/0 | 1/0/0/0 |
| `zone` | `zone.c`, `zone.h` | `src/miniquake/memory.ml`, `src/miniquake/zone.ml`, `src/miniquake/sizebuf.ml` | all-function-code-locations-found | 31/0/0/0 | 0/0/0/0 |

## Zielrelevante, noch ungemappte C-Funktionen

Keine.

## Statusregeln

- `located`: normalisierter Namensmatch oder explizit geprüfte Umbenennung; nur Codeortbeleg.
- `candidate`: Präfix-bereinigter Namenskandidat; manuelle Prüfung nötig.
- `unmapped`: kein belastbarer MiniLang-Codeort gefunden.
- `excluded`: durch die verbindliche Zieldefinition ausgeschlossen.
- Die Inventur enthält bewusst keinen zweiten Paritätsstatus. Strikte Differential- und Kompatibilitätsbelege stehen ausschließlich im separaten Verhaltensparitätsbericht.
