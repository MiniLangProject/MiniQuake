# GLQuake 1.09 Win32 – symbolgenauer MiniQuake-Paritätsnachweis

Dieser Bericht wird aus dem Visual-C++-Projekt, dem Originalsymbolinventar und einer konservativen manuellen Review-Datei erzeugt. Ein bloßer Namensmatch gilt **nicht** als 1:1-Nachweis.

Zielkonfiguration: `winquake - Win32 GL Release`

## Gesamtstand

| Kategorie | exact | technical | partial | missing | review-required | not-applicable |
|---|---:|---:|---:|---:|---:|---:|
| Dateien | 0 | 14 | 0 | 0 | 97 | 0 |
| Symbole | 0 | 0 | 0 | 0 | 5335 | 0 |

## Dateien

| Originaldatei | Status | MiniQuake-Zuordnung | Symbole |
|---|---|---|---:|
| `anorm_dots.h` | review-required |  | 0 |
| `anorms.h` | review-required |  | 0 |
| `bspfile.h` | review-required |  | 193 |
| `cd_win.c` | technical-equivalent | `miniquake/audio.ml`, `miniquake/native.ml` | 25 |
| `cdaudio.h` | review-required |  | 7 |
| `chase.c` | review-required | `miniquake/chase.ml` | 8 |
| `cl_demo.c` | review-required | `miniquake/demo.ml`, `miniquake/demo_player.ml`, `miniquake/client.ml` | 9 |
| `cl_input.c` | review-required | `miniquake/input.ml`, `miniquake/protocol_write.ml`, `miniquake/client.ml` | 47 |
| `cl_main.c` | review-required | `miniquake/client.ml`, `miniquake/client_state.ml` | 24 |
| `cl_parse.c` | review-required | `miniquake/client_protocol.ml`, `miniquake/client.ml`, `miniquake/client_effects.ml` | 13 |
| `cl_tent.c` | review-required | `miniquake/temp_entities.ml`, `miniquake/client_effects.ml`, `miniquake/particles.ml` | 15 |
| `client.h` | review-required |  | 196 |
| `cmd.c` | review-required | `miniquake/cmd.ml`, `miniquake/host.ml` | 44 |
| `cmd.h` | review-required |  | 22 |
| `common.c` | review-required | `miniquake/common.ml`, `miniquake/filesystem.ml`, `miniquake/byteio.ml`, `miniquake/message.ml`, `miniquake/sizebuf.ml`, `miniquake/launch.ml` | 130 |
| `common.h` | review-required |  | 102 |
| `conproc.c` | technical-equivalent | `miniquake/native.ml`, `miniquake/platform/win32.ml` | 25 |
| `conproc.h` | review-required |  | 6 |
| `console.c` | review-required | `miniquake/console.ml`, `miniquake/screen.ml` | 37 |
| `console.h` | review-required |  | 18 |
| `crc.c` | review-required | `miniquake/crc.ml` | 5 |
| `crc.h` | review-required |  | 3 |
| `cvar.c` | review-required | `miniquake/cvar.ml` | 10 |
| `cvar.h` | review-required |  | 18 |
| `d_iface.h` | review-required |  | 134 |
| `dosisms.h` | review-required |  | 59 |
| `draw.h` | review-required |  | 15 |
| `gl_draw.c` | review-required | `miniquake/render/draw2d.ml`, `miniquake/render/gl11.ml`, `miniquake/menu.ml`, `miniquake/statusbar.ml` | 80 |
| `gl_mesh.c` | review-required | `miniquake/render/entities.ml` | 14 |
| `gl_model.c` | review-required | `miniquake/format/bsp.ml`, `miniquake/format/mdl.ml`, `miniquake/format/sprite.ml`, `miniquake/model_registry.ml`, `miniquake/world_bsp.ml` | 63 |
| `gl_model.h` | review-required |  | 244 |
| `gl_refrag.c` | review-required | `miniquake/render/entities.ml` | 7 |
| `gl_rlight.c` | review-required | `miniquake/render/world.ml` | 10 |
| `gl_rmain.c` | review-required | `miniquake/render/world.ml`, `miniquake/render/entities.ml`, `miniquake/view.ml` | 54 |
| `gl_rmisc.c` | review-required | `miniquake/render/world.ml`, `miniquake/render/entities.ml`, `miniquake/render/particles.ml` | 8 |
| `gl_rsurf.c` | review-required | `miniquake/render/world.ml` | 55 |
| `gl_screen.c` | review-required | `miniquake/screen.ml`, `miniquake/console.ml`, `miniquake/menu.ml`, `miniquake/statusbar.ml` | 59 |
| `gl_test.c` | review-required | `miniquake/gl_smoke.ml` | 16 |
| `gl_vidnt.c` | technical-equivalent | `miniquake/platform/win32.ml`, `miniquake/render/gl11.ml`, `miniquake/native.ml` | 148 |
| `gl_warp.c` | review-required | `miniquake/render/world.ml` | 55 |
| `gl_warp_sin.h` | review-required |  | 0 |
| `glquake.h` | review-required |  | 142 |
| `host.c` | review-required | `miniquake/host.ml`, `miniquake/host_timing.ml` | 35 |
| `host_cmd.c` | review-required | `miniquake/host.ml`, `miniquake/savegame.ml`, `miniquake/server.ml` | 48 |
| `in_win.c` | technical-equivalent | `miniquake/input.ml`, `miniquake/platform/win32.ml`, `miniquake/native.ml` | 79 |
| `input.h` | review-required |  | 5 |
| `keys.c` | review-required | `miniquake/input.ml`, `miniquake/host.ml`, `miniquake/menu.ml`, `miniquake/console.ml` | 32 |
| `keys.h` | review-required |  | 88 |
| `math.s` | technical-equivalent | `miniquake/mathlib.ml`, `miniquake/native.ml` | 0 |
| `mathlib.c` | review-required | `miniquake/mathlib.ml` | 28 |
| `mathlib.h` | review-required |  | 29 |
| `menu.c` | review-required | `miniquake/menu.ml`, `miniquake/host.ml` | 211 |
| `menu.h` | review-required |  | 6 |
| `model.h` | review-required |  | 207 |
| `modelgen.h` | review-required |  | 72 |
| `net.h` | review-required |  | 154 |
| `net_dgrm.c` | review-required | `miniquake/net_datagram.ml`, `miniquake/net_udp.ml` | 66 |
| `net_dgrm.h` | review-required |  | 12 |
| `net_loop.c` | review-required | `miniquake/net_loop.ml` | 15 |
| `net_loop.h` | review-required |  | 12 |
| `net_main.c` | review-required | `miniquake/net_loop.ml`, `miniquake/net_datagram.ml`, `miniquake/net_udp.ml`, `miniquake/client.ml`, `miniquake/server.ml` | 66 |
| `net_ser.h` | review-required |  | 12 |
| `net_vcr.c` | review-required | `miniquake/demo.ml` | 12 |
| `net_vcr.h` | review-required |  | 15 |
| `net_win.c` | technical-equivalent | `miniquake/net_udp.ml`, `miniquake/native.ml` | 2 |
| `net_wins.c` | technical-equivalent | `miniquake/net_udp.ml`, `miniquake/native.ml` | 41 |
| `net_wins.h` | review-required |  | 18 |
| `net_wipx.c` | technical-equivalent | `miniquake/native.ml` | 27 |
| `net_wipx.h` | review-required |  | 18 |
| `pr_cmds.c` | review-required | `miniquake/quakec/builtins.ml` | 94 |
| `pr_comp.h` | review-required |  | 60 |
| `pr_edict.c` | review-required | `miniquake/quakec/edict.ml`, `miniquake/savegame.ml`, `miniquake/server.ml` | 46 |
| `pr_exec.c` | review-required | `miniquake/quakec/vm.ml`, `miniquake/quakec/opcodes.ml` | 21 |
| `progdefs.h` | review-required |  | 0 |
| `progs.h` | review-required |  | 67 |
| `protocol.h` | review-required |  | 91 |
| `quakedef.h` | review-required |  | 156 |
| `r_local.h` | review-required |  | 185 |
| `r_part.c` | review-required | `miniquake/particles.ml`, `miniquake/render/particles.ml` | 26 |
| `r_shared.h` | review-required |  | 75 |
| `render.h` | review-required |  | 81 |
| `sbar.c` | review-required | `miniquake/statusbar.ml` | 58 |
| `sbar.h` | review-required |  | 6 |
| `screen.h` | review-required |  | 22 |
| `server.h` | review-required |  | 149 |
| `snd_dma.c` | review-required | `miniquake/sound/mixer.ml`, `miniquake/audio.ml` | 57 |
| `snd_mem.c` | review-required | `miniquake/sound/wav.ml`, `miniquake/sound/mixer.ml` | 14 |
| `snd_mix.c` | review-required | `miniquake/sound/mixer.ml` | 15 |
| `snd_mixa.s` | technical-equivalent | `miniquake/sound/mixer.ml`, `miniquake/native.ml` | 0 |
| `snd_win.c` | technical-equivalent | `miniquake/audio.ml`, `miniquake/native.ml` | 40 |
| `sound.h` | review-required |  | 99 |
| `spritegn.h` | review-required |  | 41 |
| `sv_main.c` | review-required | `miniquake/server.ml` | 25 |
| `sv_move.c` | review-required | `miniquake/server_move.ml` | 10 |
| `sv_phys.c` | review-required | `miniquake/physics.ml`, `miniquake/server.ml`, `miniquake/server_collision.ml` | 30 |
| `sv_user.c` | review-required | `miniquake/player_move.ml`, `miniquake/physics.ml`, `miniquake/server.ml` | 24 |
| `sys.h` | review-required |  | 20 |
| `sys_win.c` | technical-equivalent | `miniquake/host.ml`, `miniquake/platform/win32.ml`, `miniquake/native.ml` | 58 |
| `sys_wina.s` | technical-equivalent | `miniquake/native.ml` | 0 |
| `vid.h` | review-required |  | 37 |
| `view.c` | review-required | `miniquake/view.ml` | 30 |
| `view.h` | review-required |  | 8 |
| `wad.c` | review-required | `miniquake/wad.ml` | 9 |
| `wad.h` | review-required |  | 37 |
| `winquake.h` | review-required |  | 54 |
| `winquake.rc` | technical-equivalent | `miniquake/native.ml` | 0 |
| `world.c` | review-required | `miniquake/server_collision.ml`, `miniquake/world_bsp.ml`, `miniquake/world_hull.ml` | 42 |
| `world.h` | review-required |  | 22 |
| `worlda.s` | technical-equivalent | `miniquake/world_bsp.ml`, `miniquake/native.ml` | 0 |
| `zone.c` | review-required | `miniquake/memory.ml` | 72 |
| `zone.h` | review-required |  | 24 |

## Symboltabellen

### `bspfile.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `lump_t` | review-required |  |
| field | `lump_t.int fileofs, filelen` | review-required |  |
| type | `dmodel_t` | review-required |  |
| field | `dmodel_t.float mins[3], maxs[3]` | review-required |  |
| field | `dmodel_t.float origin[3]` | review-required |  |
| field | `dmodel_t.int headnode[MAX_MAP_HULLS]` | review-required |  |
| field | `dmodel_t.int visleafs` | review-required |  |
| field | `dmodel_t.// not including the solid leaf 0 int firstface, numfaces` | review-required |  |
| type | `dheader_t` | review-required |  |
| field | `dheader_t.int version` | review-required |  |
| field | `dheader_t.lump_t lumps[HEADER_LUMPS]` | review-required |  |
| type | `dmiptexlump_t` | review-required |  |
| field | `dmiptexlump_t.int nummiptex` | review-required |  |
| field | `dmiptexlump_t.int dataofs[4]` | review-required |  |
| type | `miptex_t` | review-required |  |
| field | `miptex_t.char name[16]` | review-required |  |
| field | `miptex_t.unsigned width, height` | review-required |  |
| field | `miptex_t.unsigned offsets[MIPLEVELS]` | review-required |  |
| type | `dvertex_t` | review-required |  |
| field | `dvertex_t.float point[3]` | review-required |  |
| type | `dplane_t` | review-required |  |
| field | `dplane_t.float normal[3]` | review-required |  |
| field | `dplane_t.float dist` | review-required |  |
| field | `dplane_t.int type` | review-required |  |
| type | `dnode_t` | review-required |  |
| field | `dnode_t.int planenum` | review-required |  |
| field | `dnode_t.short children[2]` | review-required |  |
| field | `dnode_t.// negative numbers are -(leafs+1), not nodes short mins[3]` | review-required |  |
| field | `dnode_t.// for sphere culling short maxs[3]` | review-required |  |
| field | `dnode_t.unsigned short firstface` | review-required |  |
| field | `dnode_t.unsigned short numfaces` | review-required |  |
| type | `dclipnode_t` | review-required |  |
| field | `dclipnode_t.int planenum` | review-required |  |
| field | `dclipnode_t.short children[2]` | review-required |  |
| type | `texinfo_t` | review-required |  |
| field | `texinfo_t.float vecs[2][4]` | review-required |  |
| field | `texinfo_t.// [s/t][xyz offset] int miptex` | review-required |  |
| field | `texinfo_t.int flags` | review-required |  |
| type | `dedge_t` | review-required |  |
| field | `dedge_t.unsigned short v[2]` | review-required |  |
| type | `dface_t` | review-required |  |
| field | `dface_t.short planenum` | review-required |  |
| field | `dface_t.short side` | review-required |  |
| field | `dface_t.int firstedge` | review-required |  |
| field | `dface_t.// we must support > 64k edges short numedges` | review-required |  |
| field | `dface_t.short texinfo` | review-required |  |
| field | `dface_t.// lighting info byte styles[MAXLIGHTMAPS]` | review-required |  |
| field | `dface_t.int lightofs` | review-required |  |
| type | `dleaf_t` | review-required |  |
| field | `dleaf_t.int contents` | review-required |  |
| field | `dleaf_t.int visofs` | review-required |  |
| field | `dleaf_t.// -1 = no visibility info short mins[3]` | review-required |  |
| field | `dleaf_t.// for frustum culling short maxs[3]` | review-required |  |
| field | `dleaf_t.unsigned short firstmarksurface` | review-required |  |
| field | `dleaf_t.unsigned short nummarksurfaces` | review-required |  |
| field | `dleaf_t.byte ambient_level[NUM_AMBIENTS]` | review-required |  |
| type | `epair_t` | review-required |  |
| field | `epair_t.struct epair_s *next` | review-required |  |
| field | `epair_t.char *key` | review-required |  |
| field | `epair_t.char *value` | review-required |  |
| type | `entity_t` | review-required |  |
| field | `entity_t.vec3_t origin` | review-required |  |
| field | `entity_t.int firstbrush` | review-required |  |
| field | `entity_t.int numbrushes` | review-required |  |
| field | `entity_t.epair_t *epairs` | review-required |  |
| macro | `MAX_MAP_HULLS` | review-required |  |
| macro | `MAX_MAP_MODELS` | review-required |  |
| macro | `MAX_MAP_BRUSHES` | review-required |  |
| macro | `MAX_MAP_ENTITIES` | review-required |  |
| macro | `MAX_MAP_ENTSTRING` | review-required |  |
| macro | `MAX_MAP_PLANES` | review-required |  |
| macro | `MAX_MAP_NODES` | review-required |  |
| macro | `MAX_MAP_CLIPNODES` | review-required |  |
| macro | `MAX_MAP_LEAFS` | review-required |  |
| macro | `MAX_MAP_VERTS` | review-required |  |
| macro | `MAX_MAP_FACES` | review-required |  |
| macro | `MAX_MAP_MARKSURFACES` | review-required |  |
| macro | `MAX_MAP_TEXINFO` | review-required |  |
| macro | `MAX_MAP_EDGES` | review-required |  |
| macro | `MAX_MAP_SURFEDGES` | review-required |  |
| macro | `MAX_MAP_TEXTURES` | review-required |  |
| macro | `MAX_MAP_MIPTEX` | review-required |  |
| macro | `MAX_MAP_LIGHTING` | review-required |  |
| macro | `MAX_MAP_VISIBILITY` | review-required |  |
| macro | `MAX_MAP_PORTALS` | review-required |  |
| macro | `MAX_KEY` | review-required |  |
| macro | `MAX_VALUE` | review-required |  |
| macro | `BSPVERSION` | review-required |  |
| macro | `TOOLVERSION` | review-required |  |
| macro | `LUMP_ENTITIES` | review-required |  |
| macro | `LUMP_PLANES` | review-required |  |
| macro | `LUMP_TEXTURES` | review-required |  |
| macro | `LUMP_VERTEXES` | review-required |  |
| macro | `LUMP_VISIBILITY` | review-required |  |
| macro | `LUMP_NODES` | review-required |  |
| macro | `LUMP_TEXINFO` | review-required |  |
| macro | `LUMP_FACES` | review-required |  |
| macro | `LUMP_LIGHTING` | review-required |  |
| macro | `LUMP_CLIPNODES` | review-required |  |
| macro | `LUMP_LEAFS` | review-required |  |
| macro | `LUMP_MARKSURFACES` | review-required |  |
| macro | `LUMP_EDGES` | review-required |  |
| macro | `LUMP_SURFEDGES` | review-required |  |
| macro | `LUMP_MODELS` | review-required |  |
| macro | `HEADER_LUMPS` | review-required |  |
| macro | `MIPLEVELS` | review-required |  |
| macro | `PLANE_X` | review-required |  |
| macro | `PLANE_Y` | review-required |  |
| macro | `PLANE_Z` | review-required |  |
| macro | `PLANE_ANYX` | review-required |  |
| macro | `PLANE_ANYY` | review-required |  |
| macro | `PLANE_ANYZ` | review-required |  |
| macro | `CONTENTS_EMPTY` | review-required |  |
| macro | `CONTENTS_SOLID` | review-required |  |
| macro | `CONTENTS_WATER` | review-required |  |
| macro | `CONTENTS_SLIME` | review-required |  |
| macro | `CONTENTS_LAVA` | review-required |  |
| macro | `CONTENTS_SKY` | review-required |  |
| macro | `CONTENTS_ORIGIN` | review-required |  |
| macro | `CONTENTS_CLIP` | review-required |  |
| macro | `CONTENTS_CURRENT_0` | review-required |  |
| macro | `CONTENTS_CURRENT_90` | review-required |  |
| macro | `CONTENTS_CURRENT_180` | review-required |  |
| macro | `CONTENTS_CURRENT_270` | review-required |  |
| macro | `CONTENTS_CURRENT_UP` | review-required |  |
| macro | `CONTENTS_CURRENT_DOWN` | review-required |  |
| macro | `TEX_SPECIAL` | review-required |  |
| macro | `MAXLIGHTMAPS` | review-required |  |
| macro | `AMBIENT_WATER` | review-required |  |
| macro | `AMBIENT_SKY` | review-required |  |
| macro | `AMBIENT_SLIME` | review-required |  |
| macro | `AMBIENT_LAVA` | review-required |  |
| macro | `NUM_AMBIENTS` | review-required |  |
| macro | `ANGLE_UP` | review-required |  |
| macro | `ANGLE_DOWN` | review-required |  |
| global | `lump_t` | review-required |  |
| global | `dmodel_t` | review-required |  |
| global | `dheader_t` | review-required |  |
| global | `dmiptexlump_t` | review-required |  |
| global | `miptex_t` | review-required |  |
| global | `dvertex_t` | review-required |  |
| global | `dplane_t` | review-required |  |
| global | `dnode_t` | review-required |  |
| global | `dclipnode_t` | review-required |  |
| global | `texinfo_t` | review-required |  |
| global | `dedge_t` | review-required |  |
| global | `dface_t` | review-required |  |
| global | `dleaf_t` | review-required |  |
| global | `//============================================================================ #ifndef QUAKE_GAME #define ANGLE_UP -1 #define ANGLE_DOWN -2 // the utilities get to be lazy and just use large static arrays extern int nummodels` | review-required |  |
| global | `extern dmodel_t dmodels[MAX_MAP_MODELS]` | review-required |  |
| global | `extern int visdatasize` | review-required |  |
| global | `extern byte dvisdata[MAX_MAP_VISIBILITY]` | review-required |  |
| global | `extern int lightdatasize` | review-required |  |
| global | `extern byte dlightdata[MAX_MAP_LIGHTING]` | review-required |  |
| global | `extern int texdatasize` | review-required |  |
| global | `extern byte dtexdata[MAX_MAP_MIPTEX]` | review-required |  |
| global | `extern char dentdata[MAX_MAP_ENTSTRING]` | review-required |  |
| global | `extern int numleafs` | review-required |  |
| global | `extern dleaf_t dleafs[MAX_MAP_LEAFS]` | review-required |  |
| global | `extern int numplanes` | review-required |  |
| global | `extern dplane_t dplanes[MAX_MAP_PLANES]` | review-required |  |
| global | `extern int numvertexes` | review-required |  |
| global | `extern dvertex_t dvertexes[MAX_MAP_VERTS]` | review-required |  |
| global | `extern int numnodes` | review-required |  |
| global | `extern dnode_t dnodes[MAX_MAP_NODES]` | review-required |  |
| global | `extern int numtexinfo` | review-required |  |
| global | `extern texinfo_t texinfo[MAX_MAP_TEXINFO]` | review-required |  |
| global | `extern int numfaces` | review-required |  |
| global | `extern dface_t dfaces[MAX_MAP_FACES]` | review-required |  |
| global | `extern int numclipnodes` | review-required |  |
| global | `extern dclipnode_t dclipnodes[MAX_MAP_CLIPNODES]` | review-required |  |
| global | `extern int numedges` | review-required |  |
| global | `extern dedge_t dedges[MAX_MAP_EDGES]` | review-required |  |
| global | `extern int nummarksurfaces` | review-required |  |
| global | `extern unsigned short dmarksurfaces[MAX_MAP_MARKSURFACES]` | review-required |  |
| global | `extern int numsurfedges` | review-required |  |
| global | `extern int dsurfedges[MAX_MAP_SURFEDGES]` | review-required |  |
| global | `epair_t` | review-required |  |
| global | `entity_t` | review-required |  |
| global | `extern int num_entities` | review-required |  |
| global | `extern entity_t entities[MAX_MAP_ENTITIES]` | review-required |  |
| prototype | `DecompressVis` | review-required |  |
| prototype | `CompressVis` | review-required |  |
| prototype | `LoadBSPFile` | review-required |  |
| prototype | `WriteBSPFile` | review-required |  |
| prototype | `PrintBSPFileSizes` | review-required |  |
| prototype | `ParseEntities` | review-required |  |
| prototype | `UnparseEntities` | review-required |  |
| prototype | `SetKeyValue` | review-required |  |
| prototype | `ValueForKey` | review-required |  |
| prototype | `FloatForKey` | review-required |  |
| prototype | `GetVectorForKey` | review-required |  |
| prototype | `ParseEpair` | review-required |  |

### `cd_win.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `CDAudio_Eject` | review-required |  |
| function | `CDAudio_CloseDoor` | review-required |  |
| function | `CDAudio_GetAudioDiskInfo` | review-required |  |
| function | `CDAudio_Play` | review-required |  |
| function | `CDAudio_Stop` | review-required |  |
| function | `CDAudio_Pause` | review-required |  |
| function | `CDAudio_Resume` | review-required |  |
| function | `CD_f` | review-required |  |
| function | `CDAudio_MessageHandler` | review-required |  |
| function | `CDAudio_Update` | review-required |  |
| function | `CDAudio_Init` | review-required |  |
| function | `CDAudio_Shutdown` | review-required |  |
| global | `extern cvar_t bgmvolume` | review-required |  |
| global | `static qboolean cdValid = false` | review-required |  |
| global | `static qboolean playing = false` | review-required |  |
| global | `static qboolean wasPlaying = false` | review-required |  |
| global | `static qboolean initialized = false` | review-required |  |
| global | `static qboolean enabled = false` | review-required |  |
| global | `static qboolean playLooping = false` | review-required |  |
| global | `static float cdvolume` | review-required |  |
| global | `static byte remap[100]` | review-required |  |
| global | `static byte cdrom` | review-required |  |
| global | `static byte playTrack` | review-required |  |
| global | `static byte maxTrack` | review-required |  |
| global | `UINT wDeviceID` | review-required |  |

### `cdaudio.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `CDAudio_Init` | review-required |  |
| prototype | `CDAudio_Play` | review-required |  |
| prototype | `CDAudio_Stop` | review-required |  |
| prototype | `CDAudio_Pause` | review-required |  |
| prototype | `CDAudio_Resume` | review-required |  |
| prototype | `CDAudio_Shutdown` | review-required |  |
| prototype | `CDAudio_Update` | review-required |  |

### `chase.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Chase_Init` | review-required | `miniquake/chase.ml:Chase_Init` |
| function | `Chase_Reset` | review-required | `miniquake/chase.ml:Chase_Reset`, `miniquake/chase.ml:reset` |
| function | `TraceLine` | review-required | `miniquake/chase.ml:traceLine`, `miniquake/chase.ml:TraceLine` |
| function | `Chase_Update` | review-required | `miniquake/chase.ml:Chase_Update`, `miniquake/chase.ml:update` |
| global | `vec3_t chase_pos` | review-required |  |
| global | `vec3_t chase_angles` | review-required |  |
| global | `vec3_t chase_dest` | review-required |  |
| global | `vec3_t chase_dest_angles` | review-required |  |

### `cl_demo.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `CL_StopPlayback` | review-required | `miniquake/demo.ml:CL_StopPlayback` |
| function | `CL_WriteDemoMessage` | review-required | `miniquake/demo.ml:CL_WriteDemoMessage` |
| function | `CL_GetMessage` | review-required | `miniquake/demo.ml:CL_GetMessage` |
| function | `CL_Stop_f` | review-required | `miniquake/demo.ml:CL_Stop_f` |
| function | `CL_Record_f` | review-required | `miniquake/demo.ml:CL_Record_f` |
| function | `CL_PlayDemo_f` | review-required | `miniquake/demo.ml:CL_PlayDemo_f` |
| function | `CL_FinishTimeDemo` | review-required | `miniquake/demo.ml:CL_FinishTimeDemo` |
| function | `CL_TimeDemo_f` | review-required | `miniquake/demo.ml:CL_TimeDemo_f` |
| prototype | `CL_FinishTimeDemo` | review-required | `miniquake/demo.ml:CL_FinishTimeDemo` |

### `cl_input.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `KeyDown` | review-required | `miniquake/input.ml:keyDown`, `miniquake/input.ml:KeyDown` |
| function | `KeyUp` | review-required | `miniquake/input.ml:keyUp`, `miniquake/input.ml:KeyUp` |
| function | `IN_KLookDown` | review-required | `miniquake/input.ml:IN_KLookDown` |
| function | `IN_KLookUp` | review-required | `miniquake/input.ml:IN_KLookUp` |
| function | `IN_MLookDown` | review-required | `miniquake/input.ml:IN_MLookDown` |
| function | `IN_MLookUp` | review-required | `miniquake/input.ml:IN_MLookUp` |
| function | `IN_UpDown` | review-required | `miniquake/input.ml:IN_UpDown` |
| function | `IN_UpUp` | review-required | `miniquake/input.ml:IN_UpUp` |
| function | `IN_DownDown` | review-required | `miniquake/input.ml:IN_DownDown` |
| function | `IN_DownUp` | review-required | `miniquake/input.ml:IN_DownUp` |
| function | `IN_LeftDown` | review-required | `miniquake/input.ml:IN_LeftDown` |
| function | `IN_LeftUp` | review-required | `miniquake/input.ml:IN_LeftUp` |
| function | `IN_RightDown` | review-required | `miniquake/input.ml:IN_RightDown` |
| function | `IN_RightUp` | review-required | `miniquake/input.ml:IN_RightUp` |
| function | `IN_ForwardDown` | review-required | `miniquake/input.ml:IN_ForwardDown` |
| function | `IN_ForwardUp` | review-required | `miniquake/input.ml:IN_ForwardUp` |
| function | `IN_BackDown` | review-required | `miniquake/input.ml:IN_BackDown` |
| function | `IN_BackUp` | review-required | `miniquake/input.ml:IN_BackUp` |
| function | `IN_LookupDown` | review-required | `miniquake/input.ml:IN_LookupDown` |
| function | `IN_LookupUp` | review-required | `miniquake/input.ml:IN_LookupUp` |
| function | `IN_LookdownDown` | review-required | `miniquake/input.ml:IN_LookdownDown` |
| function | `IN_LookdownUp` | review-required | `miniquake/input.ml:IN_LookdownUp` |
| function | `IN_MoveleftDown` | review-required | `miniquake/input.ml:IN_MoveleftDown` |
| function | `IN_MoveleftUp` | review-required | `miniquake/input.ml:IN_MoveleftUp` |
| function | `IN_MoverightDown` | review-required | `miniquake/input.ml:IN_MoverightDown` |
| function | `IN_MoverightUp` | review-required | `miniquake/input.ml:IN_MoverightUp` |
| function | `IN_SpeedDown` | review-required | `miniquake/input.ml:IN_SpeedDown` |
| function | `IN_SpeedUp` | review-required | `miniquake/input.ml:IN_SpeedUp` |
| function | `IN_StrafeDown` | review-required | `miniquake/input.ml:IN_StrafeDown` |
| function | `IN_StrafeUp` | review-required | `miniquake/input.ml:IN_StrafeUp` |
| function | `IN_AttackDown` | review-required | `miniquake/input.ml:IN_AttackDown` |
| function | `IN_AttackUp` | review-required | `miniquake/input.ml:IN_AttackUp` |
| function | `IN_UseDown` | review-required | `miniquake/input.ml:IN_UseDown` |
| function | `IN_UseUp` | review-required | `miniquake/input.ml:IN_UseUp` |
| function | `IN_JumpDown` | review-required | `miniquake/input.ml:IN_JumpDown` |
| function | `IN_JumpUp` | review-required | `miniquake/input.ml:IN_JumpUp` |
| function | `IN_Impulse` | review-required | `miniquake/input.ml:IN_Impulse` |
| function | `CL_KeyState` | review-required | `miniquake/input.ml:CL_KeyState`, `miniquake/input.ml:keyState` |
| function | `CL_AdjustAngles` | review-required | `miniquake/input.ml:CL_AdjustAngles` |
| function | `CL_BaseMove` | review-required | `miniquake/input.ml:CL_BaseMove` |
| function | `CL_SendMove` | review-required | `miniquake/input.ml:CL_SendMove`, `miniquake/client.ml:sendMove` |
| function | `CL_InitInput` | review-required | `miniquake/input.ml:CL_InitInput` |
| global | `kbutton_t in_left, in_right, in_forward, in_back` | review-required |  |
| global | `kbutton_t in_lookup, in_lookdown, in_moveleft, in_moveright` | review-required |  |
| global | `kbutton_t in_strafe, in_speed, in_use, in_jump, in_attack` | review-required |  |
| global | `kbutton_t in_up, in_down` | review-required |  |
| global | `int in_impulse` | review-required |  |

### `cl_main.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `CL_ClearState` | review-required | `miniquake/client.ml:CL_ClearState` |
| function | `CL_Disconnect` | review-required | `miniquake/client.ml:CL_Disconnect`, `miniquake/client.ml:disconnect` |
| function | `CL_Disconnect_f` | review-required | `miniquake/client.ml:CL_Disconnect_f` |
| function | `CL_EstablishConnection` | review-required | `miniquake/client.ml:CL_EstablishConnection` |
| function | `CL_SignonReply` | review-required | `miniquake/client.ml:CL_SignonReply` |
| function | `CL_NextDemo` | review-required | `miniquake/client.ml:CL_NextDemo` |
| function | `CL_PrintEntities_f` | review-required | `miniquake/client.ml:CL_PrintEntities_f` |
| function | `SetPal` | review-required | `miniquake/client.ml:SetPal` |
| function | `CL_AllocDlight` | review-required | `miniquake/client.ml:CL_AllocDlight` |
| function | `CL_DecayLights` | review-required | `miniquake/client.ml:CL_DecayLights` |
| function | `CL_LerpPoint` | review-required | `miniquake/client.ml:CL_LerpPoint` |
| function | `CL_RelinkEntities` | review-required | `miniquake/client.ml:CL_RelinkEntities` |
| function | `CL_ReadFromServer` | review-required | `miniquake/client.ml:CL_ReadFromServer` |
| function | `CL_SendCmd` | review-required | `miniquake/client.ml:CL_SendCmd` |
| function | `CL_Init` | review-required | `miniquake/client.ml:CL_Init` |
| global | `client_static_t cls` | review-required |  |
| global | `client_state_t cl` | review-required |  |
| global | `// FIXME: put these on hunk? efrag_t cl_efrags[MAX_EFRAGS]` | review-required |  |
| global | `entity_t cl_entities[MAX_EDICTS]` | review-required |  |
| global | `entity_t cl_static_entities[MAX_STATIC_ENTITIES]` | review-required |  |
| global | `lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES]` | review-required |  |
| global | `dlight_t cl_dlights[MAX_DLIGHTS]` | review-required |  |
| global | `int cl_numvisedicts` | review-required |  |
| global | `entity_t *cl_visedicts[MAX_VISEDICTS]` | review-required |  |

### `cl_parse.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `CL_EntityNum` | review-required | `miniquake/client.ml:CL_EntityNum` |
| function | `CL_ParseStartSoundPacket` | review-required | `miniquake/client_protocol.ml:CL_ParseStartSoundPacket` |
| function | `CL_KeepaliveMessage` | review-required | `miniquake/client_protocol.ml:CL_KeepaliveMessage` |
| function | `CL_ParseServerInfo` | review-required | `miniquake/client_protocol.ml:CL_ParseServerInfo` |
| function | `CL_ParseUpdate` | review-required | `miniquake/client_protocol.ml:CL_ParseUpdate` |
| function | `CL_ParseBaseline` | review-required | `miniquake/client_protocol.ml:CL_ParseBaseline` |
| function | `CL_ParseClientdata` | review-required | `miniquake/client_protocol.ml:CL_ParseClientdata` |
| function | `CL_NewTranslation` | review-required | `miniquake/client_protocol.ml:CL_NewTranslation` |
| function | `CL_ParseStatic` | review-required | `miniquake/client_protocol.ml:CL_ParseStatic` |
| function | `CL_ParseStaticSound` | review-required | `miniquake/client_protocol.ml:CL_ParseStaticSound` |
| function | `CL_ParseServerMessage` | review-required | `miniquake/client_protocol.ml:CL_ParseServerMessage` |
| macro | `SHOWNET` | review-required |  |
| global | `/* ================== CL_ParseUpdate Parse an entity update message from the server If an entities model or origin changes from frame to frame, it must be relinked. Other attributes can change without relinking. ================== */ int bitcounts[16]` | review-required |  |

### `cl_tent.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `CL_InitTEnts` | review-required | `miniquake/temp_entities.ml:CL_InitTEnts` |
| function | `CL_ParseBeam` | review-required | `miniquake/temp_entities.ml:CL_ParseBeam` |
| function | `CL_ParseTEnt` | review-required | `miniquake/temp_entities.ml:CL_ParseTEnt` |
| function | `CL_NewTempEntity` | review-required | `miniquake/temp_entities.ml:CL_NewTempEntity` |
| function | `CL_UpdateTEnts` | review-required | `miniquake/temp_entities.ml:CL_UpdateTEnts` |
| global | `entity_t cl_temp_entities[MAX_TEMP_ENTITIES]` | review-required |  |
| global | `beam_t cl_beams[MAX_BEAMS]` | review-required |  |
| global | `sfx_t *cl_sfx_wizhit` | review-required |  |
| global | `sfx_t *cl_sfx_knighthit` | review-required |  |
| global | `sfx_t *cl_sfx_tink1` | review-required |  |
| global | `sfx_t *cl_sfx_ric1` | review-required |  |
| global | `sfx_t *cl_sfx_ric2` | review-required |  |
| global | `sfx_t *cl_sfx_ric3` | review-required |  |
| global | `sfx_t *cl_sfx_r_exp3` | review-required |  |
| global | `sfx_t *cl_sfx_rail` | review-required |  |

### `client.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `usercmd_t` | review-required |  |
| field | `usercmd_t.vec3_t viewangles` | review-required |  |
| field | `usercmd_t.// intended velocities float forwardmove` | review-required |  |
| field | `usercmd_t.float sidemove` | review-required |  |
| field | `usercmd_t.float upmove` | review-required |  |
| type | `lightstyle_t` | review-required |  |
| field | `lightstyle_t.int length` | review-required |  |
| field | `lightstyle_t.char map[MAX_STYLESTRING]` | review-required |  |
| type | `scoreboard_t` | review-required |  |
| field | `scoreboard_t.char name[MAX_SCOREBOARDNAME]` | review-required |  |
| field | `scoreboard_t.float entertime` | review-required |  |
| field | `scoreboard_t.int frags` | review-required |  |
| field | `scoreboard_t.int colors` | review-required |  |
| field | `scoreboard_t.// two 4 bit fields byte translations[VID_GRADES*256]` | review-required |  |
| type | `cshift_t` | review-required |  |
| field | `cshift_t.int destcolor[3]` | review-required |  |
| field | `cshift_t.int percent` | review-required |  |
| type | `dlight_t` | review-required |  |
| field | `dlight_t.vec3_t origin` | review-required |  |
| field | `dlight_t.float radius` | review-required |  |
| field | `dlight_t.float die` | review-required |  |
| field | `dlight_t.// stop lighting after this time float decay` | review-required |  |
| field | `dlight_t.// drop this each second float minlight` | review-required |  |
| field | `dlight_t.// don't add when contributing less int key` | review-required |  |
| type | `beam_t` | review-required |  |
| field | `beam_t.int entity` | review-required |  |
| field | `beam_t.struct model_s *model` | review-required |  |
| field | `beam_t.float endtime` | review-required |  |
| field | `beam_t.vec3_t start, end` | review-required |  |
| type | `cactive_t` | review-required |  |
| enum-value | `cactive_t.ca_dedicated` | review-required |  |
| enum-value | `cactive_t.// a dedicated server with no ability to start a client ca_disconnected` | review-required |  |
| enum-value | `cactive_t.// full screen console with no connection ca_connected // valid netcon` | review-required |  |
| enum-value | `cactive_t.talking to a server` | review-required |  |
| type | `client_static_t` | review-required |  |
| field | `client_static_t.cactive_t state` | review-required |  |
| field | `client_static_t.// personalization data sent to server char mapstring[MAX_QPATH]` | review-required |  |
| field | `client_static_t.char spawnparms[MAX_MAPSTRING]` | review-required |  |
| field | `client_static_t.// to restart a level // demo loop control int demonum` | review-required |  |
| field | `client_static_t.// -1 = don't play demos char demos[MAX_DEMOS][MAX_DEMONAME]` | review-required |  |
| field | `client_static_t.// when not playing // demo recording info must be here, because record is started before // entering a map (and clearing client_state_t) qboolean demorecording` | review-required |  |
| field | `client_static_t.qboolean demoplayback` | review-required |  |
| field | `client_static_t.qboolean timedemo` | review-required |  |
| field | `client_static_t.int forcetrack` | review-required |  |
| field | `client_static_t.// -1 = use normal cd track FILE *demofile` | review-required |  |
| field | `client_static_t.int td_lastframe` | review-required |  |
| field | `client_static_t.// to meter out one message a frame int td_startframe` | review-required |  |
| field | `client_static_t.// host_framecount at start float td_starttime` | review-required |  |
| field | `client_static_t.// realtime at second frame of timedemo // connection information int signon` | review-required |  |
| field | `client_static_t.// 0 to SIGNONS struct qsocket_s *netcon` | review-required |  |
| field | `client_static_t.sizebuf_t message` | review-required |  |
| type | `client_state_t` | review-required |  |
| field | `client_state_t.int movemessages` | review-required |  |
| field | `client_state_t.// since connecting to this server // throw out the first couple, so the player // doesn't accidentally do something the // first frame usercmd_t cmd` | review-required |  |
| field | `client_state_t.// last command sent to the server // information for local display int stats[MAX_CL_STATS]` | review-required |  |
| field | `client_state_t.// health, etc int items` | review-required |  |
| field | `client_state_t.// inventory bit flags float item_gettime[32]` | review-required |  |
| field | `client_state_t.// cl.time of aquiring item, for blinking float faceanimtime` | review-required |  |
| field | `client_state_t.// use anim frame if cl.time < this cshift_t cshifts[NUM_CSHIFTS]` | review-required |  |
| field | `client_state_t.// color shifts for damage, powerups cshift_t prev_cshifts[NUM_CSHIFTS]` | review-required |  |
| field | `client_state_t.// and content types // the client maintains its own idea of view angles, which are // sent to the server each frame. The server sets punchangle when // the view is temporarliy offset, and an angle reset commands at the start // of each level and after teleporting. vec3_t mviewangles[2]` | review-required |  |
| field | `client_state_t.// during demo playback viewangles is lerped // between these vec3_t viewangles` | review-required |  |
| field | `client_state_t.vec3_t mvelocity[2]` | review-required |  |
| field | `client_state_t.// update by server, used for lean+bob // (0 is newest) vec3_t velocity` | review-required |  |
| field | `client_state_t.// lerped between mvelocity[0] and [1] vec3_t punchangle` | review-required |  |
| field | `client_state_t.// temporary offset // pitch drifting vars float idealpitch` | review-required |  |
| field | `client_state_t.float pitchvel` | review-required |  |
| field | `client_state_t.qboolean nodrift` | review-required |  |
| field | `client_state_t.float driftmove` | review-required |  |
| field | `client_state_t.double laststop` | review-required |  |
| field | `client_state_t.float viewheight` | review-required |  |
| field | `client_state_t.float crouch` | review-required |  |
| field | `client_state_t.// local amount for smoothing stepups qboolean paused` | review-required |  |
| field | `client_state_t.// send over by server qboolean onground` | review-required |  |
| field | `client_state_t.qboolean inwater` | review-required |  |
| field | `client_state_t.int intermission` | review-required |  |
| field | `client_state_t.// don't change view angle, full screen, etc int completed_time` | review-required |  |
| field | `client_state_t.// latched at intermission start double mtime[2]` | review-required |  |
| field | `client_state_t.// the timestamp of last two messages double time` | review-required |  |
| field | `client_state_t.// clients view of time, should be between // servertime and oldservertime to generate // a lerp point for other data double oldtime` | review-required |  |
| field | `client_state_t.// previous cl.time, time-oldtime is used // to decay light values and smooth step ups float last_received_message` | review-required |  |
| field | `client_state_t.// (realtime) for net trouble icon // // information that is static for the entire time connected to a server // struct model_s *model_precache[MAX_MODELS]` | review-required |  |
| field | `client_state_t.struct sfx_s *sound_precache[MAX_SOUNDS]` | review-required |  |
| field | `client_state_t.char levelname[40]` | review-required |  |
| field | `client_state_t.// for display on solo scoreboard int viewentity` | review-required |  |
| field | `client_state_t.// cl_entitites[cl.viewentity] = player int maxclients` | review-required |  |
| field | `client_state_t.int gametype` | review-required |  |
| field | `client_state_t.// refresh related state struct model_s *worldmodel` | review-required |  |
| field | `client_state_t.// cl_entitites[0].model struct efrag_s *free_efrags` | review-required |  |
| field | `client_state_t.int num_entities` | review-required |  |
| field | `client_state_t.// held in cl_entities array int num_statics` | review-required |  |
| field | `client_state_t.// held in cl_staticentities array entity_t viewent` | review-required |  |
| field | `client_state_t.// the gun model int cdtrack, looptrack` | review-required |  |
| field | `client_state_t.// cd audio // frag scoreboard scoreboard_t *scores` | review-required |  |
| field | `client_state_t.// [cl.maxclients] #ifdef QUAKE2 // light level at player's position including dlights // this is sent back to the server each frame // architectually ugly but it works int light_level` | review-required |  |
| type | `kbutton_t` | review-required |  |
| field | `kbutton_t.int down[2]` | review-required |  |
| field | `kbutton_t.// key nums holding it down int state` | review-required |  |
| macro | `CSHIFT_CONTENTS` | review-required |  |
| macro | `CSHIFT_DAMAGE` | review-required |  |
| macro | `CSHIFT_BONUS` | review-required |  |
| macro | `CSHIFT_POWERUP` | review-required |  |
| macro | `NUM_CSHIFTS` | review-required |  |
| macro | `NAME_LENGTH` | review-required |  |
| macro | `SIGNONS` | review-required |  |
| macro | `MAX_DLIGHTS` | review-required |  |
| macro | `MAX_BEAMS` | review-required |  |
| macro | `MAX_EFRAGS` | review-required |  |
| macro | `MAX_MAPSTRING` | review-required |  |
| macro | `MAX_DEMOS` | review-required |  |
| macro | `MAX_DEMONAME` | review-required |  |
| macro | `MAX_TEMP_ENTITIES` | review-required |  |
| macro | `MAX_STATIC_ENTITIES` | review-required |  |
| macro | `MAX_VISEDICTS` | review-required |  |
| global | `usercmd_t` | review-required |  |
| global | `lightstyle_t` | review-required |  |
| global | `scoreboard_t` | review-required |  |
| global | `cshift_t` | review-required |  |
| global | `dlight_t` | review-required |  |
| global | `beam_t` | review-required |  |
| global | `cactive_t` | review-required |  |
| global | `client_static_t` | review-required |  |
| global | `extern client_static_t cls` | review-required |  |
| global | `client_state_t` | review-required |  |
| global | `// // cvars // extern cvar_t cl_name` | review-required |  |
| global | `extern cvar_t cl_color` | review-required |  |
| global | `extern cvar_t cl_upspeed` | review-required |  |
| global | `extern cvar_t cl_forwardspeed` | review-required |  |
| global | `extern cvar_t cl_backspeed` | review-required |  |
| global | `extern cvar_t cl_sidespeed` | review-required |  |
| global | `extern cvar_t cl_movespeedkey` | review-required |  |
| global | `extern cvar_t cl_yawspeed` | review-required |  |
| global | `extern cvar_t cl_pitchspeed` | review-required |  |
| global | `extern cvar_t cl_anglespeedkey` | review-required |  |
| global | `extern cvar_t cl_autofire` | review-required |  |
| global | `extern cvar_t cl_shownet` | review-required |  |
| global | `extern cvar_t cl_nolerp` | review-required |  |
| global | `extern cvar_t cl_pitchdriftspeed` | review-required |  |
| global | `extern cvar_t lookspring` | review-required |  |
| global | `extern cvar_t lookstrafe` | review-required |  |
| global | `extern cvar_t sensitivity` | review-required |  |
| global | `extern cvar_t m_pitch` | review-required |  |
| global | `extern cvar_t m_yaw` | review-required |  |
| global | `extern cvar_t m_forward` | review-required |  |
| global | `extern cvar_t m_side` | review-required |  |
| global | `// FIXME, allocate dynamically extern efrag_t cl_efrags[MAX_EFRAGS]` | review-required |  |
| global | `extern entity_t cl_entities[MAX_EDICTS]` | review-required |  |
| global | `extern entity_t cl_static_entities[MAX_STATIC_ENTITIES]` | review-required |  |
| global | `extern lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES]` | review-required |  |
| global | `extern dlight_t cl_dlights[MAX_DLIGHTS]` | review-required |  |
| global | `extern entity_t cl_temp_entities[MAX_TEMP_ENTITIES]` | review-required |  |
| global | `extern beam_t cl_beams[MAX_BEAMS]` | review-required |  |
| global | `extern entity_t *cl_visedicts[MAX_VISEDICTS]` | review-required |  |
| global | `kbutton_t` | review-required |  |
| global | `extern kbutton_t in_mlook, in_klook` | review-required |  |
| global | `extern kbutton_t in_strafe` | review-required |  |
| global | `extern kbutton_t in_speed` | review-required |  |
| prototype | `CL_AllocDlight` | review-required |  |
| prototype | `CL_DecayLights` | review-required |  |
| prototype | `CL_Init` | review-required |  |
| prototype | `CL_EstablishConnection` | review-required |  |
| prototype | `CL_Signon1` | review-required |  |
| prototype | `CL_Signon2` | review-required |  |
| prototype | `CL_Signon3` | review-required |  |
| prototype | `CL_Signon4` | review-required |  |
| prototype | `CL_Disconnect` | review-required |  |
| prototype | `CL_Disconnect_f` | review-required |  |
| prototype | `CL_NextDemo` | review-required |  |
| prototype | `CL_InitInput` | review-required |  |
| prototype | `CL_SendCmd` | review-required |  |
| prototype | `CL_SendMove` | review-required |  |
| prototype | `CL_ParseTEnt` | review-required |  |
| prototype | `CL_UpdateTEnts` | review-required |  |
| prototype | `CL_ClearState` | review-required |  |
| prototype | `CL_ReadFromServer` | review-required |  |
| prototype | `CL_WriteToServer` | review-required |  |
| prototype | `CL_BaseMove` | review-required |  |
| prototype | `CL_KeyState` | review-required |  |
| prototype | `Key_KeynumToString` | review-required |  |
| prototype | `CL_StopPlayback` | review-required |  |
| prototype | `CL_GetMessage` | review-required |  |
| prototype | `CL_Stop_f` | review-required |  |
| prototype | `CL_Record_f` | review-required |  |
| prototype | `CL_PlayDemo_f` | review-required |  |
| prototype | `CL_TimeDemo_f` | review-required |  |
| prototype | `CL_ParseServerMessage` | review-required |  |
| prototype | `CL_NewTranslation` | review-required |  |
| prototype | `V_StartPitchDrift` | review-required |  |
| prototype | `V_StopPitchDrift` | review-required |  |
| prototype | `V_RenderView` | review-required |  |
| prototype | `V_UpdatePalette` | review-required |  |
| prototype | `V_Register` | review-required |  |
| prototype | `V_ParseDamage` | review-required |  |
| prototype | `V_SetContentsColor` | review-required |  |
| prototype | `CL_InitTEnts` | review-required |  |
| prototype | `CL_SignonReply` | review-required |  |

### `cmd.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Cmd_Wait_f` | review-required | `miniquake/cmd.ml:Cmd_Wait_f` |
| function | `Cbuf_Init` | review-required | `miniquake/cmd.ml:Cbuf_Init`, `miniquake/cmd.ml:Cmd_Init`, `miniquake/host.ml:Host_Init` |
| function | `Cbuf_AddText` | review-required | `miniquake/cmd.ml:Cbuf_AddText`, `miniquake/cmd.ml:addText` |
| function | `Cbuf_InsertText` | review-required | `miniquake/cmd.ml:Cbuf_InsertText`, `miniquake/cmd.ml:insertText` |
| function | `Cbuf_Execute` | review-required | `miniquake/cmd.ml:Cbuf_Execute` |
| function | `Cmd_StuffCmds_f` | review-required | `miniquake/cmd.ml:Cmd_StuffCmds_f` |
| function | `Cmd_Exec_f` | review-required | `miniquake/cmd.ml:Cmd_Exec_f` |
| function | `Cmd_Echo_f` | review-required | `miniquake/cmd.ml:Cmd_Echo_f` |
| function | `CopyString` | review-required | `miniquake/cmd.ml:copyString`, `miniquake/cmd.ml:CopyString` |
| function | `Cmd_Alias_f` | review-required | `miniquake/cmd.ml:Cmd_Alias_f` |
| function | `Cmd_Init` | review-required | `miniquake/cmd.ml:Cmd_Init`, `miniquake/cmd.ml:Cbuf_Init`, `miniquake/host.ml:Host_Init` |
| function | `Cmd_Argc` | review-required | `miniquake/cmd.ml:Cmd_Argc`, `miniquake/cmd.ml:argc` |
| function | `Cmd_Argv` | review-required | `miniquake/cmd.ml:Cmd_Argv`, `miniquake/cmd.ml:argv` |
| function | `Cmd_Args` | review-required | `miniquake/cmd.ml:Cmd_Args`, `miniquake/cmd.ml:args` |
| function | `Cmd_TokenizeString` | review-required | `miniquake/cmd.ml:Cmd_TokenizeString`, `miniquake/cmd.ml:tokenizeString` |
| function | `Cmd_AddCommand` | review-required | `miniquake/cmd.ml:Cmd_AddCommand`, `miniquake/cmd.ml:addCommand` |
| function | `Cmd_Exists` | review-required | `miniquake/cmd.ml:Cmd_Exists`, `miniquake/cmd.ml:exists` |
| function | `Cmd_CompleteCommand` | review-required | `miniquake/cmd.ml:Cmd_CompleteCommand`, `miniquake/cmd.ml:completeCommand` |
| function | `Cmd_ExecuteString` | review-required | `miniquake/cmd.ml:Cmd_ExecuteString`, `miniquake/cmd.ml:executeString` |
| function | `Cmd_ForwardToServer` | review-required | `miniquake/cmd.ml:Cmd_ForwardToServer` |
| function | `Cmd_CheckParm` | review-required | `miniquake/cmd.ml:Cmd_CheckParm`, `miniquake/cmd.ml:checkParm` |
| type | `cmdalias_t` | review-required |  |
| field | `cmdalias_t.struct cmdalias_s *next` | review-required |  |
| field | `cmdalias_t.char name[MAX_ALIAS_NAME]` | review-required |  |
| field | `cmdalias_t.char *value` | review-required |  |
| type | `cmd_function_t` | review-required |  |
| field | `cmd_function_t.struct cmd_function_s *next` | review-required |  |
| field | `cmd_function_t.char *name` | review-required |  |
| field | `cmd_function_t.xcommand_t function` | review-required |  |
| macro | `MAX_ALIAS_NAME` | review-required |  |
| macro | `MAX_ARGS` | review-required |  |
| global | `cmdalias_t` | review-required |  |
| global | `cmdalias_t *cmd_alias` | review-required |  |
| global | `int trashtest` | review-required |  |
| global | `int *trashspot` | review-required |  |
| global | `qboolean cmd_wait` | review-required |  |
| global | `/* ============================================================================= COMMAND BUFFER ============================================================================= */ sizebuf_t cmd_text` | review-required |  |
| global | `cmd_function_t` | review-required |  |
| global | `static char *cmd_argv[MAX_ARGS]` | review-required |  |
| global | `static char *cmd_null_string = ""` | review-required |  |
| global | `static char *cmd_args = NULL` | review-required |  |
| global | `cmd_source_t cmd_source` | review-required |  |
| global | `static cmd_function_t *cmd_functions` | review-required |  |
| prototype | `Cmd_ForwardToServer` | review-required | `miniquake/cmd.ml:Cmd_ForwardToServer` |

### `cmd.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `cmd_source_t` | review-required |  |
| enum-value | `cmd_source_t.src_client` | review-required |  |
| enum-value | `cmd_source_t.// came in over a net connection as a clc_stringcmd // host_client will be valid during this state. src_command // from the command buffer` | review-required |  |
| global | `cmd_source_t` | review-required |  |
| global | `extern cmd_source_t cmd_source` | review-required |  |
| prototype | `Cbuf_Init` | review-required |  |
| prototype | `Cbuf_AddText` | review-required |  |
| prototype | `Cbuf_InsertText` | review-required |  |
| prototype | `Cbuf_Execute` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `Cmd_Init` | review-required |  |
| prototype | `Cmd_AddCommand` | review-required |  |
| prototype | `Cmd_Exists` | review-required |  |
| prototype | `Cmd_CompleteCommand` | review-required |  |
| prototype | `Cmd_Argc` | review-required |  |
| prototype | `Cmd_Argv` | review-required |  |
| prototype | `Cmd_Args` | review-required |  |
| prototype | `Cmd_Argv` | review-required |  |
| prototype | `position` | review-required |  |
| prototype | `Cmd_ExecuteString` | review-required |  |
| prototype | `Cmd_ForwardToServer` | review-required |  |
| prototype | `Cmd_Print` | review-required |  |

### `common.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `ClearLink` | review-required | `miniquake/common.ml:clearLink`, `miniquake/common.ml:ClearLink` |
| function | `RemoveLink` | review-required | `miniquake/common.ml:removeLink`, `miniquake/common.ml:RemoveLink` |
| function | `InsertLinkBefore` | review-required | `miniquake/common.ml:insertLinkBefore`, `miniquake/common.ml:InsertLinkBefore` |
| function | `InsertLinkAfter` | review-required | `miniquake/common.ml:insertLinkAfter`, `miniquake/common.ml:InsertLinkAfter` |
| function | `Q_memset` | review-required | `miniquake/common.ml:Q_memset`, `miniquake/common.ml:qMemset` |
| function | `Q_memcpy` | review-required | `miniquake/common.ml:Q_memcpy`, `miniquake/common.ml:qMemcpy` |
| function | `Q_memcmp` | review-required | `miniquake/common.ml:Q_memcmp`, `miniquake/common.ml:qMemcmp` |
| function | `Q_strcpy` | review-required | `miniquake/common.ml:Q_strcpy`, `miniquake/common.ml:qStrcpy` |
| function | `Q_strncpy` | review-required | `miniquake/common.ml:Q_strncpy`, `miniquake/common.ml:qStrncpy` |
| function | `Q_strlen` | review-required | `miniquake/common.ml:Q_strlen`, `miniquake/common.ml:qStrlen` |
| function | `Q_strrchr` | review-required | `miniquake/common.ml:Q_strrchr`, `miniquake/common.ml:qStrrchr` |
| function | `Q_strcat` | review-required | `miniquake/common.ml:Q_strcat`, `miniquake/common.ml:qStrcat` |
| function | `Q_strcmp` | review-required | `miniquake/common.ml:Q_strcmp`, `miniquake/common.ml:qStrcmp` |
| function | `Q_strncmp` | review-required | `miniquake/common.ml:Q_strncmp`, `miniquake/common.ml:qStrncmp` |
| function | `Q_strncasecmp` | review-required | `miniquake/common.ml:Q_strncasecmp`, `miniquake/common.ml:qStrncasecmp` |
| function | `Q_strcasecmp` | review-required | `miniquake/common.ml:Q_strcasecmp`, `miniquake/common.ml:qStrcasecmp` |
| function | `Q_atoi` | review-required | `miniquake/common.ml:Q_atoi`, `miniquake/common.ml:qAtoi` |
| function | `Q_atof` | review-required | `miniquake/common.ml:Q_atof`, `miniquake/common.ml:qAtof` |
| function | `ShortSwap` | review-required | `miniquake/common.ml:shortSwap`, `miniquake/common.ml:ShortSwap` |
| function | `ShortNoSwap` | review-required | `miniquake/common.ml:shortNoSwap`, `miniquake/common.ml:ShortNoSwap` |
| function | `LongSwap` | review-required | `miniquake/common.ml:longSwap`, `miniquake/common.ml:LongSwap` |
| function | `LongNoSwap` | review-required | `miniquake/common.ml:longNoSwap`, `miniquake/common.ml:LongNoSwap` |
| function | `FloatSwap` | review-required | `miniquake/common.ml:floatSwap`, `miniquake/common.ml:FloatSwap` |
| function | `FloatNoSwap` | review-required | `miniquake/common.ml:floatNoSwap`, `miniquake/common.ml:FloatNoSwap` |
| function | `MSG_WriteChar` | review-required | `miniquake/common.ml:MSG_WriteChar` |
| function | `MSG_WriteByte` | review-required | `miniquake/common.ml:MSG_WriteByte` |
| function | `MSG_WriteShort` | review-required | `miniquake/common.ml:MSG_WriteShort` |
| function | `MSG_WriteLong` | review-required | `miniquake/common.ml:MSG_WriteLong` |
| function | `MSG_WriteFloat` | review-required | `miniquake/common.ml:MSG_WriteFloat` |
| function | `MSG_WriteString` | review-required | `miniquake/common.ml:MSG_WriteString` |
| function | `MSG_WriteCoord` | review-required | `miniquake/common.ml:MSG_WriteCoord` |
| function | `MSG_WriteAngle` | review-required | `miniquake/common.ml:MSG_WriteAngle` |
| function | `MSG_BeginReading` | review-required | `miniquake/common.ml:MSG_BeginReading` |
| function | `MSG_ReadChar` | review-required | `miniquake/common.ml:MSG_ReadChar` |
| function | `MSG_ReadByte` | review-required | `miniquake/common.ml:MSG_ReadByte` |
| function | `MSG_ReadShort` | review-required | `miniquake/common.ml:MSG_ReadShort` |
| function | `MSG_ReadLong` | review-required | `miniquake/common.ml:MSG_ReadLong` |
| function | `MSG_ReadFloat` | review-required | `miniquake/common.ml:MSG_ReadFloat` |
| function | `MSG_ReadString` | review-required | `miniquake/common.ml:MSG_ReadString` |
| function | `MSG_ReadCoord` | review-required | `miniquake/common.ml:MSG_ReadCoord` |
| function | `MSG_ReadAngle` | review-required | `miniquake/common.ml:MSG_ReadAngle` |
| function | `SZ_Alloc` | review-required | `miniquake/sizebuf.ml:SZ_Alloc`, `miniquake/sizebuf.ml:alloc` |
| function | `SZ_Free` | review-required | `miniquake/sizebuf.ml:SZ_Free` |
| function | `SZ_Clear` | review-required | `miniquake/sizebuf.ml:SZ_Clear`, `miniquake/sizebuf.ml:clear` |
| function | `SZ_GetSpace` | review-required | `miniquake/sizebuf.ml:SZ_GetSpace`, `miniquake/sizebuf.ml:getSpace` |
| function | `SZ_Write` | review-required | `miniquake/sizebuf.ml:SZ_Write`, `miniquake/sizebuf.ml:write` |
| function | `SZ_Print` | review-required | `miniquake/sizebuf.ml:SZ_Print` |
| function | `COM_SkipPath` | review-required | `miniquake/common.ml:COM_SkipPath`, `miniquake/common.ml:skipPath` |
| function | `COM_StripExtension` | review-required | `miniquake/common.ml:COM_StripExtension`, `miniquake/common.ml:stripExtension` |
| function | `COM_FileExtension` | review-required | `miniquake/common.ml:COM_FileExtension`, `miniquake/common.ml:fileExtension` |
| function | `COM_FileBase` | review-required | `miniquake/common.ml:COM_FileBase`, `miniquake/common.ml:fileBase` |
| function | `COM_DefaultExtension` | review-required | `miniquake/common.ml:COM_DefaultExtension`, `miniquake/common.ml:defaultExtension` |
| function | `COM_Parse` | review-required | `miniquake/common.ml:COM_Parse`, `miniquake/launch.ml:parse` |
| function | `COM_CheckParm` | review-required | `miniquake/common.ml:COM_CheckParm`, `miniquake/common.ml:checkParm`, `miniquake/common.ml:comCheckParm` |
| function | `COM_CheckRegistered` | review-required | `miniquake/common.ml:COM_CheckRegistered` |
| function | `COM_InitArgv` | review-required | `miniquake/common.ml:COM_InitArgv` |
| function | `COM_Init` | review-required | `miniquake/filesystem.ml:COM_Init` |
| function | `va` | review-required | `miniquake/common.ml:va` |
| function | `memsearch` | review-required | `miniquake/common.ml:memSearch`, `miniquake/common.ml:memsearch` |
| function | `COM_Path_f` | review-required | `miniquake/filesystem.ml:COM_Path_f` |
| function | `COM_WriteFile` | review-required | `miniquake/filesystem.ml:COM_WriteFile`, `miniquake/filesystem.ml:writeFile` |
| function | `COM_CreatePath` | review-required | `miniquake/filesystem.ml:COM_CreatePath` |
| function | `COM_CopyFile` | review-required | `miniquake/filesystem.ml:COM_CopyFile` |
| function | `COM_FindFile` | review-required | `miniquake/filesystem.ml:COM_FindFile` |
| function | `COM_OpenFile` | review-required | `miniquake/filesystem.ml:COM_OpenFile` |
| function | `COM_FOpenFile` | review-required | `miniquake/filesystem.ml:COM_FOpenFile` |
| function | `COM_CloseFile` | review-required | `miniquake/filesystem.ml:COM_CloseFile` |
| function | `COM_LoadFile` | review-required | `miniquake/filesystem.ml:COM_LoadFile` |
| function | `COM_LoadHunkFile` | review-required | `miniquake/filesystem.ml:COM_LoadHunkFile` |
| function | `COM_LoadTempFile` | review-required | `miniquake/filesystem.ml:COM_LoadTempFile` |
| function | `COM_LoadCacheFile` | review-required | `miniquake/filesystem.ml:COM_LoadCacheFile` |
| function | `COM_LoadStackFile` | review-required | `miniquake/filesystem.ml:COM_LoadStackFile` |
| function | `COM_LoadPackFile` | review-required | `miniquake/filesystem.ml:COM_LoadPackFile` |
| function | `COM_AddGameDirectory` | review-required | `miniquake/filesystem.ml:COM_AddGameDirectory`, `miniquake/filesystem.ml:addGameDirectory` |
| function | `COM_InitFilesystem` | review-required | `miniquake/filesystem.ml:COM_InitFilesystem` |
| type | `packfile_t` | review-required |  |
| field | `packfile_t.char name[MAX_QPATH]` | review-required |  |
| field | `packfile_t.int filepos, filelen` | review-required |  |
| type | `pack_t` | review-required |  |
| field | `pack_t.char filename[MAX_OSPATH]` | review-required |  |
| field | `pack_t.int handle` | review-required |  |
| field | `pack_t.int numfiles` | review-required |  |
| field | `pack_t.packfile_t *files` | review-required |  |
| type | `dpackfile_t` | review-required |  |
| field | `dpackfile_t.char name[56]` | review-required |  |
| field | `dpackfile_t.int filepos, filelen` | review-required |  |
| type | `dpackheader_t` | review-required |  |
| field | `dpackheader_t.char id[4]` | review-required |  |
| field | `dpackheader_t.int dirofs` | review-required |  |
| field | `dpackheader_t.int dirlen` | review-required |  |
| type | `searchpath_t` | review-required |  |
| field | `searchpath_t.char filename[MAX_OSPATH]` | review-required |  |
| field | `searchpath_t.pack_t *pack` | review-required |  |
| field | `searchpath_t.// only one of filename / pack will be used struct searchpath_s *next` | review-required |  |
| macro | `NUM_SAFE_ARGVS` | review-required |  |
| macro | `PAK0_COUNT` | review-required |  |
| macro | `PAK0_CRC` | review-required |  |
| macro | `CMDLINE_LENGTH` | review-required |  |
| macro | `MAX_FILES_IN_PACK` | review-required |  |
| global | `static char *argvdummy = " "` | review-required |  |
| global | `qboolean com_modified` | review-required |  |
| global | `// set true if using non-id files qboolean proghack` | review-required |  |
| global | `int static_registered = 1` | review-required |  |
| global | `// only for startup check, then set qboolean msg_suppress_1 = 0` | review-required |  |
| global | `// if a packfile directory differs from this, it is assumed to be hacked #define PAK0_COUNT 339 #define PAK0_CRC 32981 char com_token[1024]` | review-required |  |
| global | `int com_argc` | review-required |  |
| global | `char **com_argv` | review-required |  |
| global | `qboolean standard_quake = true, rogue, hipnotic` | review-required |  |
| global | `/* ============================================================================ BYTE ORDER FUNCTIONS ============================================================================ */ qboolean bigendien` | review-required |  |
| global | `// // reading functions // int msg_readcount` | review-required |  |
| global | `qboolean msg_badread` | review-required |  |
| global | `/* ============================================================================= QUAKE FILESYSTEM ============================================================================= */ int com_filesize` | review-required |  |
| global | `packfile_t` | review-required |  |
| global | `pack_t` | review-required |  |
| global | `dpackfile_t` | review-required |  |
| global | `dpackheader_t` | review-required |  |
| global | `char com_gamedir[MAX_OSPATH]` | review-required |  |
| global | `searchpath_t` | review-required |  |
| global | `searchpath_t *com_searchpaths` | review-required |  |
| global | `/* ============ COM_LoadFile Filename are reletive to the quake directory. Allways appends a 0 byte. ============ */ cache_user_t *loadcache` | review-required |  |
| global | `byte *loadbuf` | review-required |  |
| global | `int loadsize` | review-required |  |
| prototype | `COM_InitFilesystem` | review-required | `miniquake/filesystem.ml:COM_InitFilesystem` |
| prototype | `short` | review-required |  |
| prototype | `short` | review-required |  |
| prototype | `int` | review-required | `miniquake/sizebuf.ml:SZ_Print` |
| prototype | `int` | review-required | `miniquake/sizebuf.ml:SZ_Print` |
| prototype | `float` | review-required |  |
| prototype | `float` | review-required |  |
| prototype | `COM_Path_f` | review-required | `miniquake/filesystem.ml:COM_Path_f` |

### `common.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `qboolean` | review-required |  |
| enum-value | `qboolean.false` | review-required |  |
| enum-value | `qboolean.true` | review-required |  |
| type | `sizebuf_t` | review-required |  |
| field | `sizebuf_t.qboolean allowoverflow` | review-required |  |
| field | `sizebuf_t.// if false, do a Sys_Error qboolean overflowed` | review-required |  |
| field | `sizebuf_t.// set to true if the buffer size failed byte *data` | review-required |  |
| field | `sizebuf_t.int maxsize` | review-required |  |
| field | `sizebuf_t.int cursize` | review-required |  |
| type | `link_t` | review-required |  |
| field | `link_t.struct link_s *prev, *next` | review-required |  |
| macro | `BYTE_DEFINED` | review-required |  |
| macro | `STRUCT_FROM_LINK` | review-required |  |
| macro | `NULL` | review-required |  |
| macro | `Q_MAXCHAR` | review-required |  |
| macro | `Q_MAXSHORT` | review-required |  |
| macro | `Q_MAXINT` | review-required |  |
| macro | `Q_MAXLONG` | review-required |  |
| macro | `Q_MAXFLOAT` | review-required |  |
| macro | `Q_MINCHAR` | review-required |  |
| macro | `Q_MINSHORT` | review-required |  |
| macro | `Q_MININT` | review-required |  |
| macro | `Q_MINLONG` | review-required |  |
| macro | `Q_MINFLOAT` | review-required |  |
| global | `qboolean` | review-required |  |
| global | `sizebuf_t` | review-required |  |
| global | `link_t` | review-required |  |
| global | `extern int msg_readcount` | review-required |  |
| global | `extern qboolean msg_badread` | review-required |  |
| global | `//============================================================================ extern char com_token[1024]` | review-required |  |
| global | `extern qboolean com_eof` | review-required |  |
| global | `extern int com_argc` | review-required |  |
| global | `extern char **com_argv` | review-required |  |
| global | `// does a varargs printf into a temp buffer //============================================================================ extern int com_filesize` | review-required |  |
| global | `struct cache_user_s` | review-required |  |
| global | `extern char com_gamedir[MAX_OSPATH]` | review-required |  |
| global | `extern struct cvar_s registered` | review-required |  |
| global | `extern qboolean standard_quake, rogue, hipnotic` | review-required |  |
| prototype | `SZ_Alloc` | review-required |  |
| prototype | `SZ_Free` | review-required |  |
| prototype | `SZ_Clear` | review-required |  |
| prototype | `SZ_GetSpace` | review-required |  |
| prototype | `SZ_Write` | review-required |  |
| prototype | `SZ_Print` | review-required |  |
| prototype | `ClearLink` | review-required |  |
| prototype | `RemoveLink` | review-required |  |
| prototype | `InsertLinkBefore` | review-required |  |
| prototype | `InsertLinkAfter` | review-required |  |
| prototype | `short` | review-required |  |
| prototype | `short` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `float` | review-required |  |
| prototype | `float` | review-required |  |
| prototype | `MSG_WriteChar` | review-required |  |
| prototype | `MSG_WriteByte` | review-required |  |
| prototype | `MSG_WriteShort` | review-required |  |
| prototype | `MSG_WriteLong` | review-required |  |
| prototype | `MSG_WriteFloat` | review-required |  |
| prototype | `MSG_WriteString` | review-required |  |
| prototype | `MSG_WriteCoord` | review-required |  |
| prototype | `MSG_WriteAngle` | review-required |  |
| prototype | `MSG_BeginReading` | review-required |  |
| prototype | `MSG_ReadChar` | review-required |  |
| prototype | `MSG_ReadByte` | review-required |  |
| prototype | `MSG_ReadShort` | review-required |  |
| prototype | `MSG_ReadLong` | review-required |  |
| prototype | `MSG_ReadFloat` | review-required |  |
| prototype | `MSG_ReadString` | review-required |  |
| prototype | `MSG_ReadCoord` | review-required |  |
| prototype | `MSG_ReadAngle` | review-required |  |
| prototype | `Q_memset` | review-required |  |
| prototype | `Q_memcpy` | review-required |  |
| prototype | `Q_memcmp` | review-required |  |
| prototype | `Q_strcpy` | review-required |  |
| prototype | `Q_strncpy` | review-required |  |
| prototype | `Q_strlen` | review-required |  |
| prototype | `Q_strrchr` | review-required |  |
| prototype | `Q_strcat` | review-required |  |
| prototype | `Q_strcmp` | review-required |  |
| prototype | `Q_strncmp` | review-required |  |
| prototype | `Q_strcasecmp` | review-required |  |
| prototype | `Q_strncasecmp` | review-required |  |
| prototype | `Q_atoi` | review-required |  |
| prototype | `Q_atof` | review-required |  |
| prototype | `COM_Parse` | review-required |  |
| prototype | `COM_CheckParm` | review-required |  |
| prototype | `COM_Init` | review-required |  |
| prototype | `COM_InitArgv` | review-required |  |
| prototype | `COM_SkipPath` | review-required |  |
| prototype | `COM_StripExtension` | review-required |  |
| prototype | `COM_FileBase` | review-required |  |
| prototype | `COM_DefaultExtension` | review-required |  |
| prototype | `va` | review-required |  |
| prototype | `COM_WriteFile` | review-required |  |
| prototype | `COM_OpenFile` | review-required |  |
| prototype | `COM_FOpenFile` | review-required |  |
| prototype | `COM_CloseFile` | review-required |  |
| prototype | `COM_LoadStackFile` | review-required |  |
| prototype | `COM_LoadTempFile` | review-required |  |
| prototype | `COM_LoadHunkFile` | review-required |  |
| prototype | `COM_LoadCacheFile` | review-required |  |

### `conproc.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `InitConProc` | review-required |  |
| function | `DeinitConProc` | review-required |  |
| function | `RequestProc` | review-required |  |
| function | `GetMappedBuffer` | review-required |  |
| function | `ReleaseMappedBuffer` | review-required |  |
| function | `GetScreenBufferLines` | review-required |  |
| function | `SetScreenBufferLines` | review-required |  |
| function | `ReadText` | review-required |  |
| function | `WriteText` | review-required |  |
| function | `CharToCode` | review-required |  |
| function | `SetConsoleCXCY` | review-required |  |
| global | `HANDLE hfileBuffer` | review-required |  |
| global | `HANDLE heventChildSend` | review-required |  |
| global | `HANDLE heventParentSend` | review-required |  |
| global | `HANDLE hStdout` | review-required |  |
| global | `HANDLE hStdin` | review-required |  |
| prototype | `RequestProc` | review-required |  |
| prototype | `GetMappedBuffer` | review-required |  |
| prototype | `ReleaseMappedBuffer` | review-required |  |
| prototype | `GetScreenBufferLines` | review-required |  |
| prototype | `SetScreenBufferLines` | review-required |  |
| prototype | `ReadText` | review-required |  |
| prototype | `WriteText` | review-required |  |
| prototype | `CharToCode` | review-required |  |
| prototype | `SetConsoleCXCY` | review-required |  |

### `conproc.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| macro | `CCOM_WRITE_TEXT` | review-required |  |
| macro | `CCOM_GET_TEXT` | review-required |  |
| macro | `CCOM_GET_SCR_LINES` | review-required |  |
| macro | `CCOM_SET_SCR_LINES` | review-required |  |
| prototype | `InitConProc` | review-required |  |
| prototype | `DeinitConProc` | review-required |  |

### `console.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Con_ToggleConsole_f` | review-required | `miniquake/console.ml:Con_ToggleConsole_f` |
| function | `Con_Clear_f` | review-required | `miniquake/console.ml:Con_Clear_f` |
| function | `Con_ClearNotify` | review-required | `miniquake/console.ml:Con_ClearNotify` |
| function | `Con_MessageMode_f` | review-required | `miniquake/console.ml:Con_MessageMode_f` |
| function | `Con_MessageMode2_f` | review-required | `miniquake/console.ml:Con_MessageMode2_f` |
| function | `Con_CheckResize` | review-required | `miniquake/console.ml:Con_CheckResize` |
| function | `Con_Init` | review-required | `miniquake/console.ml:Con_Init` |
| function | `Con_Linefeed` | review-required | `miniquake/console.ml:Con_Linefeed` |
| function | `Con_Print` | review-required | `miniquake/console.ml:Con_Print` |
| function | `Con_DebugLog` | review-required | `miniquake/console.ml:Con_DebugLog` |
| function | `Con_Printf` | review-required | `miniquake/console.ml:Con_Printf` |
| function | `Con_DPrintf` | review-required | `miniquake/console.ml:Con_DPrintf` |
| function | `Con_SafePrintf` | review-required | `miniquake/console.ml:Con_SafePrintf` |
| function | `Con_DrawInput` | review-required | `miniquake/console.ml:Con_DrawInput` |
| function | `Con_DrawNotify` | review-required | `miniquake/console.ml:Con_DrawNotify`, `miniquake/screen.ml:drawNotify` |
| function | `Con_DrawConsole` | review-required | `miniquake/console.ml:Con_DrawConsole` |
| function | `Con_NotifyBox` | review-required | `miniquake/console.ml:Con_NotifyBox` |
| macro | `CON_TEXTSIZE` | review-required |  |
| macro | `NUM_CON_TIMES` | review-required |  |
| macro | `MAXCMDLINE` | review-required |  |
| macro | `MAXGAMEDIRLEN` | review-required |  |
| macro | `MAXPRINTMSG` | review-required |  |
| global | `float con_cursorspeed = 4` | review-required |  |
| global | `// because no entities to refresh int con_totallines` | review-required |  |
| global | `// total lines in console scrollback int con_backscroll` | review-required |  |
| global | `// lines up from bottom to display int con_current` | review-required |  |
| global | `// where next message will be printed int con_x` | review-required |  |
| global | `// offset in current line for next print char *con_text=0` | review-required |  |
| global | `//seconds #define NUM_CON_TIMES 4 float con_times[NUM_CON_TIMES]` | review-required |  |
| global | `// realtime time the line was generated // for transparent notify lines int con_vislines` | review-required |  |
| global | `qboolean con_debuglog` | review-required |  |
| global | `extern int edit_line` | review-required |  |
| global | `extern int key_linepos` | review-required |  |
| global | `qboolean con_initialized` | review-required |  |
| global | `int con_notifylines` | review-required |  |
| global | `/* ================ Con_MessageMode_f ================ */ extern qboolean team_message` | review-required |  |
| prototype | `M_Menu_Main_f` | review-required |  |

### `console.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| global | `extern int con_backscroll` | review-required |  |
| global | `extern qboolean con_forcedup` | review-required |  |
| global | `// because no entities to refresh extern qboolean con_initialized` | review-required |  |
| global | `extern byte *con_chars` | review-required |  |
| global | `extern int con_notifylines` | review-required |  |
| prototype | `Con_DrawCharacter` | review-required |  |
| prototype | `Con_CheckResize` | review-required |  |
| prototype | `Con_Init` | review-required |  |
| prototype | `Con_DrawConsole` | review-required |  |
| prototype | `Con_Print` | review-required |  |
| prototype | `Con_Printf` | review-required |  |
| prototype | `Con_DPrintf` | review-required |  |
| prototype | `Con_SafePrintf` | review-required |  |
| prototype | `Con_Clear_f` | review-required |  |
| prototype | `Con_DrawNotify` | review-required |  |
| prototype | `Con_ClearNotify` | review-required |  |
| prototype | `Con_ToggleConsole_f` | review-required |  |
| prototype | `Con_NotifyBox` | review-required |  |

### `crc.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `CRC_Init` | review-required | `miniquake/crc.ml:CRC_Init`, `miniquake/crc.ml:init` |
| function | `CRC_ProcessByte` | review-required | `miniquake/crc.ml:CRC_ProcessByte`, `miniquake/crc.ml:processByte` |
| function | `CRC_Value` | review-required | `miniquake/crc.ml:CRC_Value`, `miniquake/crc.ml:value` |
| macro | `CRC_INIT_VALUE` | review-required |  |
| macro | `CRC_XOR_VALUE` | review-required |  |

### `crc.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `CRC_Init` | review-required |  |
| prototype | `CRC_ProcessByte` | review-required |  |
| prototype | `CRC_Value` | review-required |  |

### `cvar.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Cvar_FindVar` | review-required | `miniquake/cvar.ml:Cvar_FindVar` |
| function | `Cvar_VariableValue` | review-required | `miniquake/cvar.ml:Cvar_VariableValue`, `miniquake/cvar.ml:variableValue` |
| function | `Cvar_VariableString` | review-required | `miniquake/cvar.ml:Cvar_VariableString`, `miniquake/cvar.ml:variableString` |
| function | `Cvar_CompleteVariable` | review-required | `miniquake/cvar.ml:Cvar_CompleteVariable`, `miniquake/cvar.ml:completeVariable` |
| function | `Cvar_Set` | review-required | `miniquake/cvar.ml:Cvar_Set`, `miniquake/cvar.ml:set` |
| function | `Cvar_SetValue` | review-required | `miniquake/cvar.ml:Cvar_SetValue`, `miniquake/cvar.ml:setValue` |
| function | `Cvar_RegisterVariable` | review-required | `miniquake/cvar.ml:Cvar_RegisterVariable` |
| function | `Cvar_Command` | review-required | `miniquake/cvar.ml:Cvar_Command`, `miniquake/cvar.ml:command` |
| function | `Cvar_WriteVariables` | review-required | `miniquake/cvar.ml:Cvar_WriteVariables` |
| global | `char *cvar_null_string = ""` | review-required |  |

### `cvar.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `cvar_t` | review-required |  |
| field | `cvar_t.char *name` | review-required |  |
| field | `cvar_t.char *string` | review-required |  |
| field | `cvar_t.qboolean archive` | review-required |  |
| field | `cvar_t.// set to true to cause it to be saved to vars.rc qboolean server` | review-required |  |
| field | `cvar_t.// notifies players when changed float value` | review-required |  |
| field | `cvar_t.struct cvar_s *next` | review-required |  |
| global | `cvar_t` | review-required |  |
| global | `extern cvar_t *cvar_vars` | review-required |  |
| prototype | `Cvar_RegisterVariable` | review-required |  |
| prototype | `Cvar_Set` | review-required |  |
| prototype | `Cvar_SetValue` | review-required |  |
| prototype | `Cvar_VariableValue` | review-required |  |
| prototype | `Cvar_VariableString` | review-required |  |
| prototype | `Cvar_CompleteVariable` | review-required |  |
| prototype | `Cvar_Command` | review-required |  |
| prototype | `Cmd_Argv` | review-required |  |
| prototype | `Cvar_FindVar` | review-required |  |

### `d_iface.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `emitpoint_t` | review-required |  |
| field | `emitpoint_t.float u, v` | review-required |  |
| field | `emitpoint_t.float s, t` | review-required |  |
| field | `emitpoint_t.float zi` | review-required |  |
| type | `ptype_t` | review-required |  |
| enum-value | `ptype_t.pt_static` | review-required |  |
| enum-value | `ptype_t.pt_grav` | review-required |  |
| enum-value | `ptype_t.pt_slowgrav` | review-required |  |
| enum-value | `ptype_t.pt_fire` | review-required |  |
| enum-value | `ptype_t.pt_explode` | review-required |  |
| enum-value | `ptype_t.pt_explode2` | review-required |  |
| enum-value | `ptype_t.pt_blob` | review-required |  |
| enum-value | `ptype_t.pt_blob2` | review-required |  |
| type | `particle_t` | review-required |  |
| field | `particle_t.// driver-usable fields vec3_t org` | review-required |  |
| field | `particle_t.float color` | review-required |  |
| field | `particle_t.// drivers never touch the following fields struct particle_s *next` | review-required |  |
| field | `particle_t.vec3_t vel` | review-required |  |
| field | `particle_t.float ramp` | review-required |  |
| field | `particle_t.float die` | review-required |  |
| field | `particle_t.ptype_t type` | review-required |  |
| type | `polyvert_t` | review-required |  |
| field | `polyvert_t.float u, v, zi, s, t` | review-required |  |
| type | `polydesc_t` | review-required |  |
| field | `polydesc_t.int numverts` | review-required |  |
| field | `polydesc_t.float nearzi` | review-required |  |
| field | `polydesc_t.msurface_t *pcurrentface` | review-required |  |
| field | `polydesc_t.polyvert_t *pverts` | review-required |  |
| type | `finalvert_t` | review-required |  |
| field | `finalvert_t.int v[6]` | review-required |  |
| field | `finalvert_t.// u, v, s, t, l, 1/z int flags` | review-required |  |
| field | `finalvert_t.float reserved` | review-required |  |
| type | `affinetridesc_t` | review-required |  |
| field | `affinetridesc_t.void *pskin` | review-required |  |
| field | `affinetridesc_t.maliasskindesc_t *pskindesc` | review-required |  |
| field | `affinetridesc_t.int skinwidth` | review-required |  |
| field | `affinetridesc_t.int skinheight` | review-required |  |
| field | `affinetridesc_t.mtriangle_t *ptriangles` | review-required |  |
| field | `affinetridesc_t.finalvert_t *pfinalverts` | review-required |  |
| field | `affinetridesc_t.int numtriangles` | review-required |  |
| field | `affinetridesc_t.int drawtype` | review-required |  |
| field | `affinetridesc_t.int seamfixupX16` | review-required |  |
| type | `screenpart_t` | review-required |  |
| field | `screenpart_t.float u, v, zi, color` | review-required |  |
| type | `spritedesc_t` | review-required |  |
| field | `spritedesc_t.int nump` | review-required |  |
| field | `spritedesc_t.emitpoint_t *pverts` | review-required |  |
| field | `spritedesc_t.// there's room for an extra element at [nump], // if the driver wants to duplicate element [0] at // element [nump] to avoid dealing with wrapping mspriteframe_t *pspriteframe` | review-required |  |
| field | `spritedesc_t.vec3_t vup, vright, vpn` | review-required |  |
| field | `spritedesc_t.// in worldspace float nearzi` | review-required |  |
| type | `zpointdesc_t` | review-required |  |
| field | `zpointdesc_t.int u, v` | review-required |  |
| field | `zpointdesc_t.float zi` | review-required |  |
| field | `zpointdesc_t.int color` | review-required |  |
| type | `drawsurf_t` | review-required |  |
| field | `drawsurf_t.pixel_t *surfdat` | review-required |  |
| field | `drawsurf_t.// destination for generated surface int rowbytes` | review-required |  |
| field | `drawsurf_t.// destination logical width in bytes msurface_t *surf` | review-required |  |
| field | `drawsurf_t.// description for surface to generate fixed8_t lightadj[MAXLIGHTMAPS]` | review-required |  |
| field | `drawsurf_t.// adjust for lightmap levels for dynamic lighting texture_t *texture` | review-required |  |
| field | `drawsurf_t.// corrected for animating textures int surfmip` | review-required |  |
| field | `drawsurf_t.// mipmapped ratio of surface texels / world pixels int surfwidth` | review-required |  |
| field | `drawsurf_t.// in mipmapped texels int surfheight` | review-required |  |
| macro | `WARP_WIDTH` | review-required |  |
| macro | `WARP_HEIGHT` | review-required |  |
| macro | `MAX_LBM_HEIGHT` | review-required |  |
| macro | `PARTICLE_Z_CLIP` | review-required |  |
| macro | `DR_SOLID` | review-required |  |
| macro | `DR_TRANSPARENT` | review-required |  |
| macro | `TRANSPARENT_COLOR` | review-required |  |
| macro | `TURB_TEX_SIZE` | review-required |  |
| macro | `CYCLE` | review-required |  |
| macro | `TILE_SIZE` | review-required |  |
| macro | `SKYSHIFT` | review-required |  |
| macro | `SKYSIZE` | review-required |  |
| macro | `SKYMASK` | review-required |  |
| global | `emitpoint_t` | review-required |  |
| global | `ptype_t` | review-required |  |
| global | `particle_t` | review-required |  |
| global | `polyvert_t` | review-required |  |
| global | `polydesc_t` | review-required |  |
| global | `finalvert_t` | review-required |  |
| global | `affinetridesc_t` | review-required |  |
| global | `screenpart_t` | review-required |  |
| global | `spritedesc_t` | review-required |  |
| global | `zpointdesc_t` | review-required |  |
| global | `extern cvar_t r_drawflat` | review-required |  |
| global | `extern int d_spanpixcount` | review-required |  |
| global | `extern int r_framecount` | review-required |  |
| global | `// sequence # of current frame since Quake // started extern qboolean r_drawpolys` | review-required |  |
| global | `// 1 if driver wants clipped polygons // rather than a span list extern qboolean r_drawculledpolys` | review-required |  |
| global | `// 1 if driver wants clipped polygons that // have been culled by the edge list extern qboolean r_worldpolysbacktofront` | review-required |  |
| global | `// 1 if driver wants polygons // delivered back to front rather // than front to back extern qboolean r_recursiveaffinetriangles` | review-required |  |
| global | `// scale-up factor for screen u and v // on Alias vertices passed to driver extern int r_pixbytes` | review-required |  |
| global | `extern qboolean r_dowarp` | review-required |  |
| global | `extern affinetridesc_t r_affinetridesc` | review-required |  |
| global | `extern spritedesc_t r_spritedesc` | review-required |  |
| global | `extern zpointdesc_t r_zpointdesc` | review-required |  |
| global | `extern polydesc_t r_polydesc` | review-required |  |
| global | `extern int d_con_indirect` | review-required |  |
| global | `// if 0, Quake will draw console directly // to vid.buffer; if 1, Quake will // draw console via D_DrawRect. Must be // defined by driver extern vec3_t r_pright, r_pup, r_ppn` | review-required |  |
| global | `// these are currently for internal use only, and should not be used by drivers extern int r_skydirect` | review-required |  |
| global | `extern byte *r_skysource` | review-required |  |
| global | `drawsurf_t` | review-required |  |
| global | `extern drawsurf_t r_drawsurf` | review-required |  |
| global | `extern float skytime` | review-required |  |
| global | `extern int c_surf` | review-required |  |
| global | `extern vrect_t scr_vrect` | review-required |  |
| global | `extern byte *r_warpbuffer` | review-required |  |
| prototype | `D_Aff8Patch` | review-required |  |
| prototype | `D_BeginDirectRect` | review-required |  |
| prototype | `D_DisableBackBufferAccess` | review-required |  |
| prototype | `D_EndDirectRect` | review-required |  |
| prototype | `D_PolysetDraw` | review-required |  |
| prototype | `D_PolysetDrawFinalVerts` | review-required |  |
| prototype | `D_DrawParticle` | review-required |  |
| prototype | `D_DrawPoly` | review-required |  |
| prototype | `D_DrawSprite` | review-required |  |
| prototype | `D_DrawSurfaces` | review-required |  |
| prototype | `D_DrawZPoint` | review-required |  |
| prototype | `D_EnableBackBufferAccess` | review-required |  |
| prototype | `D_EndParticles` | review-required |  |
| prototype | `D_Init` | review-required |  |
| prototype | `D_ViewChanged` | review-required |  |
| prototype | `D_SetupFrame` | review-required |  |
| prototype | `D_StartParticles` | review-required |  |
| prototype | `D_TurnZOn` | review-required |  |
| prototype | `D_WarpScreen` | review-required |  |
| prototype | `D_FillRect` | review-required |  |
| prototype | `D_DrawRect` | review-required |  |
| prototype | `D_UpdateRects` | review-required |  |
| prototype | `D_PolysetUpdateTables` | review-required |  |
| prototype | `R_DrawSurface` | review-required |  |
| prototype | `R_GenTile` | review-required |  |

### `dosisms.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `regs_t` | review-required |  |
| field | `regs_t.struct { unsigned long edi` | review-required |  |
| field | `regs_t.unsigned long esi` | review-required |  |
| field | `regs_t.unsigned long ebp` | review-required |  |
| field | `regs_t.unsigned long res` | review-required |  |
| field | `regs_t.unsigned long ebx` | review-required |  |
| field | `regs_t.unsigned long edx` | review-required |  |
| field | `regs_t.unsigned long ecx` | review-required |  |
| field | `regs_t.unsigned long eax` | review-required |  |
| field | `regs_t.} d` | review-required |  |
| field | `regs_t.struct { unsigned short di, di_hi` | review-required |  |
| field | `regs_t.unsigned short si, si_hi` | review-required |  |
| field | `regs_t.unsigned short bp, bp_hi` | review-required |  |
| field | `regs_t.unsigned short res, res_hi` | review-required |  |
| field | `regs_t.unsigned short bx, bx_hi` | review-required |  |
| field | `regs_t.unsigned short dx, dx_hi` | review-required |  |
| field | `regs_t.unsigned short cx, cx_hi` | review-required |  |
| field | `regs_t.unsigned short ax, ax_hi` | review-required |  |
| field | `regs_t.unsigned short flags` | review-required |  |
| field | `regs_t.unsigned short es` | review-required |  |
| field | `regs_t.unsigned short ds` | review-required |  |
| field | `regs_t.unsigned short fs` | review-required |  |
| field | `regs_t.unsigned short gs` | review-required |  |
| field | `regs_t.unsigned short ip` | review-required |  |
| field | `regs_t.unsigned short cs` | review-required |  |
| field | `regs_t.unsigned short sp` | review-required |  |
| field | `regs_t.unsigned short ss` | review-required |  |
| field | `regs_t.} x` | review-required |  |
| field | `regs_t.struct { unsigned char edi[4]` | review-required |  |
| field | `regs_t.unsigned char esi[4]` | review-required |  |
| field | `regs_t.unsigned char ebp[4]` | review-required |  |
| field | `regs_t.unsigned char res[4]` | review-required |  |
| field | `regs_t.unsigned char bl, bh, ebx_b2, ebx_b3` | review-required |  |
| field | `regs_t.unsigned char dl, dh, edx_b2, edx_b3` | review-required |  |
| field | `regs_t.unsigned char cl, ch, ecx_b2, ecx_b3` | review-required |  |
| field | `regs_t.unsigned char al, ah, eax_b2, eax_b3` | review-required |  |
| field | `regs_t.} h` | review-required |  |
| macro | `_DOSISMS_H_` | review-required |  |
| global | `regs_t` | review-required |  |
| global | `extern regs_t regs` | review-required |  |
| prototype | `dos_lockmem` | review-required |  |
| prototype | `dos_unlockmem` | review-required |  |
| prototype | `ptr2real` | review-required |  |
| prototype | `real2ptr` | review-required |  |
| prototype | `far2ptr` | review-required |  |
| prototype | `ptr2far` | review-required |  |
| prototype | `dos_inportb` | review-required |  |
| prototype | `dos_inportw` | review-required |  |
| prototype | `dos_outportb` | review-required |  |
| prototype | `dos_outportw` | review-required |  |
| prototype | `dos_irqenable` | review-required |  |
| prototype | `dos_irqdisable` | review-required |  |
| prototype | `dos_registerintr` | review-required |  |
| prototype | `dos_restoreintr` | review-required |  |
| prototype | `dos_int86` | review-required |  |
| prototype | `dos_getmemory` | review-required |  |
| prototype | `dos_freememory` | review-required |  |
| prototype | `dos_usleep` | review-required |  |
| prototype | `dos_getheapsize` | review-required |  |

### `draw.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `Draw_Init` | review-required |  |
| prototype | `Draw_Character` | review-required |  |
| prototype | `Draw_DebugChar` | review-required |  |
| prototype | `Draw_Pic` | review-required |  |
| prototype | `Draw_TransPic` | review-required |  |
| prototype | `Draw_TransPicTranslate` | review-required |  |
| prototype | `Draw_ConsoleBackground` | review-required |  |
| prototype | `Draw_BeginDisc` | review-required |  |
| prototype | `Draw_EndDisc` | review-required |  |
| prototype | `Draw_TileClear` | review-required |  |
| prototype | `Draw_Fill` | review-required |  |
| prototype | `Draw_FadeScreen` | review-required |  |
| prototype | `Draw_String` | review-required |  |
| prototype | `Draw_PicFromWad` | review-required |  |
| prototype | `Draw_CachePic` | review-required |  |

### `gl_draw.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `GL_Bind` | review-required |  |
| function | `Scrap_AllocBlock` | review-required |  |
| function | `Scrap_Upload` | review-required |  |
| function | `Draw_PicFromWad` | review-required |  |
| function | `Draw_CachePic` | review-required | `miniquake/menu.ml:M_DrawPic` |
| function | `Draw_CharToConback` | review-required |  |
| function | `Draw_TextureMode_f` | review-required |  |
| function | `Draw_Init` | review-required | `miniquake/menu.ml:M_Init` |
| function | `Draw_Character` | review-required | `miniquake/render/draw2d.ml:character`, `miniquake/menu.ml:M_DrawCharacter` |
| function | `Draw_String` | review-required | `miniquake/render/draw2d.ml:string` |
| function | `Draw_DebugChar` | review-required |  |
| function | `Draw_AlphaPic` | review-required |  |
| function | `Draw_Pic` | review-required | `miniquake/menu.ml:M_DrawPic` |
| function | `Draw_TransPic` | review-required | `miniquake/menu.ml:M_DrawTransPic` |
| function | `Draw_TransPicTranslate` | review-required | `miniquake/menu.ml:M_DrawTransPicTranslate` |
| function | `Draw_ConsoleBackground` | review-required |  |
| function | `Draw_TileClear` | review-required |  |
| function | `Draw_Fill` | review-required |  |
| function | `Draw_FadeScreen` | review-required |  |
| function | `Draw_BeginDisc` | review-required |  |
| function | `Draw_EndDisc` | review-required |  |
| function | `GL_Set2D` | review-required |  |
| function | `GL_FindTexture` | review-required |  |
| function | `GL_ResampleTexture` | review-required |  |
| function | `GL_Resample8BitTexture` | review-required |  |
| function | `GL_MipMap` | review-required |  |
| function | `GL_MipMap8Bit` | review-required |  |
| function | `GL_Upload32` | review-required |  |
| function | `GL_Upload8_EXT` | review-required |  |
| function | `GL_Upload8` | review-required |  |
| function | `GL_LoadTexture` | review-required |  |
| function | `GL_LoadPicTexture` | review-required |  |
| function | `GL_SelectTexture` | review-required |  |
| type | `glpic_t` | review-required |  |
| field | `glpic_t.int texnum` | review-required |  |
| field | `glpic_t.float sl, tl, sh, th` | review-required |  |
| type | `gltexture_t` | review-required |  |
| field | `gltexture_t.int texnum` | review-required |  |
| field | `gltexture_t.char identifier[64]` | review-required |  |
| field | `gltexture_t.int width, height` | review-required |  |
| field | `gltexture_t.qboolean mipmap` | review-required |  |
| type | `cachepic_t` | review-required |  |
| field | `cachepic_t.char name[MAX_QPATH]` | review-required |  |
| field | `cachepic_t.qpic_t pic` | review-required |  |
| field | `cachepic_t.byte padding[32]` | review-required |  |
| type | `glmode_t` | review-required |  |
| field | `glmode_t.char *name` | review-required |  |
| field | `glmode_t.int minimize, maximize` | review-required |  |
| macro | `GL_COLOR_INDEX8_EXT` | review-required |  |
| macro | `MAX_GLTEXTURES` | review-required |  |
| macro | `MAX_SCRAPS` | review-required |  |
| macro | `BLOCK_WIDTH` | review-required |  |
| macro | `BLOCK_HEIGHT` | review-required |  |
| macro | `MAX_CACHED_PICS` | review-required |  |
| global | `byte *draw_chars` | review-required |  |
| global | `// 8*8 graphic characters qpic_t *draw_disc` | review-required |  |
| global | `qpic_t *draw_backtile` | review-required |  |
| global | `int translate_texture` | review-required |  |
| global | `int char_texture` | review-required |  |
| global | `glpic_t` | review-required |  |
| global | `int gl_lightmap_format = 4` | review-required |  |
| global | `int gl_solid_format = 3` | review-required |  |
| global | `int gl_alpha_format = 4` | review-required |  |
| global | `int gl_filter_min = GL_LINEAR_MIPMAP_NEAREST` | review-required |  |
| global | `int gl_filter_max = GL_LINEAR` | review-required |  |
| global | `int texels` | review-required |  |
| global | `gltexture_t` | review-required |  |
| global | `int numgltextures` | review-required |  |
| global | `/* ============================================================================= scrap allocation Allocate all the little status bar obejcts into a single texture to crutch up stupid hardware / drivers ============================================================================= */ #define MAX_SCRAPS 2 #define BLOCK_WIDTH 256 #define BLOCK_HEIGHT 256 int scrap_allocated[MAX_SCRAPS][BLOCK_WIDTH]` | review-required |  |
| global | `byte scrap_texels[MAX_SCRAPS][BLOCK_WIDTH*BLOCK_HEIGHT*4]` | review-required |  |
| global | `qboolean scrap_dirty` | review-required |  |
| global | `int scrap_texnum` | review-required |  |
| global | `int scrap_uploads` | review-required |  |
| global | `cachepic_t` | review-required |  |
| global | `int menu_numcachepics` | review-required |  |
| global | `byte menuplyr_pixels[4096]` | review-required |  |
| global | `int pic_texels` | review-required |  |
| global | `int pic_count` | review-required |  |
| global | `glmode_t` | review-required |  |
| global | `/****************************************/ static GLenum oldtarget = TEXTURE0_SGIS` | review-required |  |

### `gl_mesh.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `StripLength` | review-required |  |
| function | `FanLength` | review-required |  |
| function | `BuildTris` | review-required |  |
| function | `GL_MakeAliasModelDisplayLists` | review-required |  |
| global | `aliashdr_t *paliashdr` | review-required |  |
| global | `qboolean used[8192]` | review-required |  |
| global | `// the command list holds counts and s/t values that are valid for // every frame int commands[8192]` | review-required |  |
| global | `int numcommands` | review-required |  |
| global | `// all frames will have their vertexes rearranged and expanded // so they are in the order expected by the command list int vertexorder[8192]` | review-required |  |
| global | `int numorder` | review-required |  |
| global | `int allverts, alltris` | review-required |  |
| global | `int stripverts[128]` | review-required |  |
| global | `int striptris[128]` | review-required |  |
| global | `int stripcount` | review-required |  |

### `gl_model.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Mod_Init` | review-required |  |
| function | `Mod_Extradata` | review-required |  |
| function | `Mod_PointInLeaf` | review-required |  |
| function | `Mod_DecompressVis` | review-required |  |
| function | `Mod_LeafPVS` | review-required |  |
| function | `Mod_ClearAll` | review-required |  |
| function | `Mod_FindName` | review-required |  |
| function | `Mod_TouchModel` | review-required |  |
| function | `Mod_LoadModel` | review-required |  |
| function | `Mod_ForName` | review-required |  |
| function | `Mod_LoadTextures` | review-required |  |
| function | `Mod_LoadLighting` | review-required |  |
| function | `Mod_LoadVisibility` | review-required |  |
| function | `Mod_LoadEntities` | review-required |  |
| function | `Mod_LoadVertexes` | review-required |  |
| function | `Mod_LoadSubmodels` | review-required |  |
| function | `Mod_LoadEdges` | review-required |  |
| function | `Mod_LoadTexinfo` | review-required |  |
| function | `CalcSurfaceExtents` | review-required |  |
| function | `Mod_LoadFaces` | review-required |  |
| function | `Mod_SetParent` | review-required |  |
| function | `Mod_LoadNodes` | review-required |  |
| function | `Mod_LoadLeafs` | review-required |  |
| function | `Mod_LoadClipnodes` | review-required |  |
| function | `Mod_MakeHull0` | review-required |  |
| function | `Mod_LoadMarksurfaces` | review-required |  |
| function | `Mod_LoadSurfedges` | review-required |  |
| function | `Mod_LoadPlanes` | review-required |  |
| function | `RadiusFromBounds` | review-required |  |
| function | `Mod_LoadBrushModel` | review-required |  |
| function | `Mod_LoadAliasFrame` | review-required |  |
| function | `Mod_LoadAliasGroup` | review-required |  |
| function | `Mod_FloodFillSkin` | review-required |  |
| function | `Mod_LoadAllSkins` | review-required |  |
| function | `Mod_LoadAliasModel` | review-required |  |
| function | `Mod_LoadSpriteFrame` | review-required |  |
| function | `Mod_LoadSpriteGroup` | review-required |  |
| function | `Mod_LoadSpriteModel` | review-required |  |
| function | `Mod_Print` | review-required |  |
| type | `floodfill_t` | review-required |  |
| field | `floodfill_t.short x, y` | review-required |  |
| macro | `MAX_MOD_KNOWN` | review-required |  |
| macro | `ANIM_CYCLE` | review-required |  |
| macro | `FLOODFILL_FIFO_SIZE` | review-required |  |
| macro | `FLOODFILL_FIFO_MASK` | review-required |  |
| macro | `FLOODFILL_STEP` | review-required |  |
| global | `char loadname[32]` | review-required |  |
| global | `byte mod_novis[MAX_MAP_LEAFS/8]` | review-required |  |
| global | `int mod_numknown` | review-required |  |
| global | `/* =============================================================================== BRUSHMODEL LOADING =============================================================================== */ byte *mod_base` | review-required |  |
| global | `/* ============================================================================== ALIAS MODELS ============================================================================== */ aliashdr_t *pheader` | review-required |  |
| global | `stvert_t stverts[MAXALIASVERTS]` | review-required |  |
| global | `mtriangle_t triangles[MAXALIASTRIS]` | review-required |  |
| global | `// a pose is a single set of vertexes. a frame may be // an animating sequence of poses trivertx_t *poseverts[MAXALIASFRAMES]` | review-required |  |
| global | `int posenum` | review-required |  |
| global | `byte **player_8bit_texels_tbl` | review-required |  |
| global | `byte *player_8bit_texels` | review-required |  |
| global | `floodfill_t` | review-required |  |
| global | `extern unsigned d_8to24table[]` | review-required |  |
| prototype | `Mod_LoadSpriteModel` | review-required |  |
| prototype | `Mod_LoadBrushModel` | review-required |  |
| prototype | `Mod_LoadAliasModel` | review-required |  |
| prototype | `Mod_LoadModel` | review-required |  |

### `gl_model.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `mvertex_t` | review-required |  |
| field | `mvertex_t.vec3_t position` | review-required |  |
| type | `mplane_t` | review-required |  |
| field | `mplane_t.vec3_t normal` | review-required |  |
| field | `mplane_t.float dist` | review-required |  |
| field | `mplane_t.byte type` | review-required |  |
| field | `mplane_t.// for texture axis selection and fast side tests byte signbits` | review-required |  |
| field | `mplane_t.// signx + signy<<1 + signz<<1 byte pad[2]` | review-required |  |
| type | `texture_t` | review-required |  |
| field | `texture_t.char name[16]` | review-required |  |
| field | `texture_t.unsigned width, height` | review-required |  |
| field | `texture_t.int gl_texturenum` | review-required |  |
| field | `texture_t.struct msurface_s *texturechain` | review-required |  |
| field | `texture_t.// for gl_texsort drawing int anim_total` | review-required |  |
| field | `texture_t.// total tenths in sequence ( 0 = no) int anim_min, anim_max` | review-required |  |
| field | `texture_t.// time for this frame min <=time< max struct texture_s *anim_next` | review-required |  |
| field | `texture_t.// in the animation sequence struct texture_s *alternate_anims` | review-required |  |
| field | `texture_t.// bmodels in frmae 1 use these unsigned offsets[MIPLEVELS]` | review-required |  |
| type | `medge_t` | review-required |  |
| field | `medge_t.unsigned short v[2]` | review-required |  |
| field | `medge_t.unsigned int cachededgeoffset` | review-required |  |
| type | `mtexinfo_t` | review-required |  |
| field | `mtexinfo_t.float vecs[2][4]` | review-required |  |
| field | `mtexinfo_t.float mipadjust` | review-required |  |
| field | `mtexinfo_t.texture_t *texture` | review-required |  |
| field | `mtexinfo_t.int flags` | review-required |  |
| type | `glpoly_t` | review-required |  |
| field | `glpoly_t.struct glpoly_s *next` | review-required |  |
| field | `glpoly_t.struct glpoly_s *chain` | review-required |  |
| field | `glpoly_t.int numverts` | review-required |  |
| field | `glpoly_t.int flags` | review-required |  |
| field | `glpoly_t.// for SURF_UNDERWATER float verts[4][VERTEXSIZE]` | review-required |  |
| type | `msurface_t` | review-required |  |
| field | `msurface_t.int visframe` | review-required |  |
| field | `msurface_t.// should be drawn when node is crossed mplane_t *plane` | review-required |  |
| field | `msurface_t.int flags` | review-required |  |
| field | `msurface_t.int firstedge` | review-required |  |
| field | `msurface_t.// look up in model->surfedges[], negative numbers int numedges` | review-required |  |
| field | `msurface_t.// are backwards edges short texturemins[2]` | review-required |  |
| field | `msurface_t.short extents[2]` | review-required |  |
| field | `msurface_t.int light_s, light_t` | review-required |  |
| field | `msurface_t.// gl lightmap coordinates glpoly_t *polys` | review-required |  |
| field | `msurface_t.// multiple if warped struct msurface_s *texturechain` | review-required |  |
| field | `msurface_t.mtexinfo_t *texinfo` | review-required |  |
| field | `msurface_t.// lighting info int dlightframe` | review-required |  |
| field | `msurface_t.int dlightbits` | review-required |  |
| field | `msurface_t.int lightmaptexturenum` | review-required |  |
| field | `msurface_t.byte styles[MAXLIGHTMAPS]` | review-required |  |
| field | `msurface_t.int cached_light[MAXLIGHTMAPS]` | review-required |  |
| field | `msurface_t.// values currently used in lightmap qboolean cached_dlight` | review-required |  |
| field | `msurface_t.// true if dynamic light in cache byte *samples` | review-required |  |
| type | `mnode_t` | review-required |  |
| field | `mnode_t.// common with leaf int contents` | review-required |  |
| field | `mnode_t.// 0, to differentiate from leafs int visframe` | review-required |  |
| field | `mnode_t.// node needs to be traversed if current float minmaxs[6]` | review-required |  |
| field | `mnode_t.// for bounding box culling struct mnode_s *parent` | review-required |  |
| field | `mnode_t.// node specific mplane_t *plane` | review-required |  |
| field | `mnode_t.struct mnode_s *children[2]` | review-required |  |
| field | `mnode_t.unsigned short firstsurface` | review-required |  |
| field | `mnode_t.unsigned short numsurfaces` | review-required |  |
| type | `mleaf_t` | review-required |  |
| field | `mleaf_t.// common with node int contents` | review-required |  |
| field | `mleaf_t.// wil be a negative contents number int visframe` | review-required |  |
| field | `mleaf_t.// node needs to be traversed if current float minmaxs[6]` | review-required |  |
| field | `mleaf_t.// for bounding box culling struct mnode_s *parent` | review-required |  |
| field | `mleaf_t.// leaf specific byte *compressed_vis` | review-required |  |
| field | `mleaf_t.efrag_t *efrags` | review-required |  |
| field | `mleaf_t.msurface_t **firstmarksurface` | review-required |  |
| field | `mleaf_t.int nummarksurfaces` | review-required |  |
| field | `mleaf_t.int key` | review-required |  |
| field | `mleaf_t.// BSP sequence number for leaf's contents byte ambient_sound_level[NUM_AMBIENTS]` | review-required |  |
| type | `hull_t` | review-required |  |
| field | `hull_t.dclipnode_t *clipnodes` | review-required |  |
| field | `hull_t.mplane_t *planes` | review-required |  |
| field | `hull_t.int firstclipnode` | review-required |  |
| field | `hull_t.int lastclipnode` | review-required |  |
| field | `hull_t.vec3_t clip_mins` | review-required |  |
| field | `hull_t.vec3_t clip_maxs` | review-required |  |
| type | `mspriteframe_t` | review-required |  |
| field | `mspriteframe_t.int width` | review-required |  |
| field | `mspriteframe_t.int height` | review-required |  |
| field | `mspriteframe_t.float up, down, left, right` | review-required |  |
| field | `mspriteframe_t.int gl_texturenum` | review-required |  |
| type | `mspritegroup_t` | review-required |  |
| field | `mspritegroup_t.int numframes` | review-required |  |
| field | `mspritegroup_t.float *intervals` | review-required |  |
| field | `mspritegroup_t.mspriteframe_t *frames[1]` | review-required |  |
| type | `mspriteframedesc_t` | review-required |  |
| field | `mspriteframedesc_t.spriteframetype_t type` | review-required |  |
| field | `mspriteframedesc_t.mspriteframe_t *frameptr` | review-required |  |
| type | `msprite_t` | review-required |  |
| field | `msprite_t.int type` | review-required |  |
| field | `msprite_t.int maxwidth` | review-required |  |
| field | `msprite_t.int maxheight` | review-required |  |
| field | `msprite_t.int numframes` | review-required |  |
| field | `msprite_t.float beamlength` | review-required |  |
| field | `msprite_t.// remove? void *cachespot` | review-required |  |
| field | `msprite_t.// remove? mspriteframedesc_t frames[1]` | review-required |  |
| type | `maliasframedesc_t` | review-required |  |
| field | `maliasframedesc_t.int firstpose` | review-required |  |
| field | `maliasframedesc_t.int numposes` | review-required |  |
| field | `maliasframedesc_t.float interval` | review-required |  |
| field | `maliasframedesc_t.trivertx_t bboxmin` | review-required |  |
| field | `maliasframedesc_t.trivertx_t bboxmax` | review-required |  |
| field | `maliasframedesc_t.int frame` | review-required |  |
| field | `maliasframedesc_t.char name[16]` | review-required |  |
| type | `maliasgroupframedesc_t` | review-required |  |
| field | `maliasgroupframedesc_t.trivertx_t bboxmin` | review-required |  |
| field | `maliasgroupframedesc_t.trivertx_t bboxmax` | review-required |  |
| field | `maliasgroupframedesc_t.int frame` | review-required |  |
| type | `maliasgroup_t` | review-required |  |
| field | `maliasgroup_t.int numframes` | review-required |  |
| field | `maliasgroup_t.int intervals` | review-required |  |
| field | `maliasgroup_t.maliasgroupframedesc_t frames[1]` | review-required |  |
| type | `mtriangle_t` | review-required |  |
| field | `mtriangle_t.int facesfront` | review-required |  |
| field | `mtriangle_t.int vertindex[3]` | review-required |  |
| type | `aliashdr_t` | review-required |  |
| field | `aliashdr_t.int ident` | review-required |  |
| field | `aliashdr_t.int version` | review-required |  |
| field | `aliashdr_t.vec3_t scale` | review-required |  |
| field | `aliashdr_t.vec3_t scale_origin` | review-required |  |
| field | `aliashdr_t.float boundingradius` | review-required |  |
| field | `aliashdr_t.vec3_t eyeposition` | review-required |  |
| field | `aliashdr_t.int numskins` | review-required |  |
| field | `aliashdr_t.int skinwidth` | review-required |  |
| field | `aliashdr_t.int skinheight` | review-required |  |
| field | `aliashdr_t.int numverts` | review-required |  |
| field | `aliashdr_t.int numtris` | review-required |  |
| field | `aliashdr_t.int numframes` | review-required |  |
| field | `aliashdr_t.synctype_t synctype` | review-required |  |
| field | `aliashdr_t.int flags` | review-required |  |
| field | `aliashdr_t.float size` | review-required |  |
| field | `aliashdr_t.int numposes` | review-required |  |
| field | `aliashdr_t.int poseverts` | review-required |  |
| field | `aliashdr_t.int posedata` | review-required |  |
| field | `aliashdr_t.// numposes*poseverts trivert_t int commands` | review-required |  |
| field | `aliashdr_t.// gl command list with embedded s/t int gl_texturenum[MAX_SKINS][4]` | review-required |  |
| field | `aliashdr_t.int texels[MAX_SKINS]` | review-required |  |
| field | `aliashdr_t.// only for player skins maliasframedesc_t frames[1]` | review-required |  |
| type | `modtype_t` | review-required |  |
| enum-value | `modtype_t.mod_brush` | review-required |  |
| enum-value | `modtype_t.mod_sprite` | review-required |  |
| enum-value | `modtype_t.mod_alias` | review-required |  |
| type | `model_t` | review-required |  |
| field | `model_t.char name[MAX_QPATH]` | review-required |  |
| field | `model_t.qboolean needload` | review-required |  |
| field | `model_t.// bmodels and sprites don't cache normally modtype_t type` | review-required |  |
| field | `model_t.int numframes` | review-required |  |
| field | `model_t.synctype_t synctype` | review-required |  |
| field | `model_t.int flags` | review-required |  |
| field | `model_t.// // volume occupied by the model graphics // vec3_t mins, maxs` | review-required |  |
| field | `model_t.float radius` | review-required |  |
| field | `model_t.// // solid volume for clipping // qboolean clipbox` | review-required |  |
| field | `model_t.vec3_t clipmins, clipmaxs` | review-required |  |
| field | `model_t.// // brush model // int firstmodelsurface, nummodelsurfaces` | review-required |  |
| field | `model_t.int numsubmodels` | review-required |  |
| field | `model_t.dmodel_t *submodels` | review-required |  |
| field | `model_t.int numplanes` | review-required |  |
| field | `model_t.mplane_t *planes` | review-required |  |
| field | `model_t.int numleafs` | review-required |  |
| field | `model_t.// number of visible leafs, not counting 0 mleaf_t *leafs` | review-required |  |
| field | `model_t.int numvertexes` | review-required |  |
| field | `model_t.mvertex_t *vertexes` | review-required |  |
| field | `model_t.int numedges` | review-required |  |
| field | `model_t.medge_t *edges` | review-required |  |
| field | `model_t.int numnodes` | review-required |  |
| field | `model_t.mnode_t *nodes` | review-required |  |
| field | `model_t.int numtexinfo` | review-required |  |
| field | `model_t.mtexinfo_t *texinfo` | review-required |  |
| field | `model_t.int numsurfaces` | review-required |  |
| field | `model_t.msurface_t *surfaces` | review-required |  |
| field | `model_t.int numsurfedges` | review-required |  |
| field | `model_t.int *surfedges` | review-required |  |
| field | `model_t.int numclipnodes` | review-required |  |
| field | `model_t.dclipnode_t *clipnodes` | review-required |  |
| field | `model_t.int nummarksurfaces` | review-required |  |
| field | `model_t.msurface_t **marksurfaces` | review-required |  |
| field | `model_t.hull_t hulls[MAX_MAP_HULLS]` | review-required |  |
| field | `model_t.int numtextures` | review-required |  |
| field | `model_t.texture_t **textures` | review-required |  |
| field | `model_t.byte *visdata` | review-required |  |
| field | `model_t.byte *lightdata` | review-required |  |
| field | `model_t.char *entities` | review-required |  |
| field | `model_t.// // additional model data // cache_user_t cache` | review-required |  |
| macro | `__MODEL__` | review-required |  |
| macro | `EF_BRIGHTFIELD` | review-required |  |
| macro | `EF_MUZZLEFLASH` | review-required |  |
| macro | `EF_BRIGHTLIGHT` | review-required |  |
| macro | `EF_DIMLIGHT` | review-required |  |
| macro | `SIDE_FRONT` | review-required |  |
| macro | `SIDE_BACK` | review-required |  |
| macro | `SIDE_ON` | review-required |  |
| macro | `SURF_PLANEBACK` | review-required |  |
| macro | `SURF_DRAWSKY` | review-required |  |
| macro | `SURF_DRAWSPRITE` | review-required |  |
| macro | `SURF_DRAWTURB` | review-required |  |
| macro | `SURF_DRAWTILED` | review-required |  |
| macro | `SURF_DRAWBACKGROUND` | review-required |  |
| macro | `SURF_UNDERWATER` | review-required |  |
| macro | `VERTEXSIZE` | review-required |  |
| macro | `MAX_SKINS` | review-required |  |
| macro | `MAXALIASVERTS` | review-required |  |
| macro | `MAXALIASFRAMES` | review-required |  |
| macro | `MAXALIASTRIS` | review-required |  |
| macro | `EF_ROCKET` | review-required |  |
| macro | `EF_GRENADE` | review-required |  |
| macro | `EF_GIB` | review-required |  |
| macro | `EF_ROTATE` | review-required |  |
| macro | `EF_TRACER` | review-required |  |
| macro | `EF_ZOMGIB` | review-required |  |
| macro | `EF_TRACER2` | review-required |  |
| macro | `EF_TRACER3` | review-required |  |
| global | `mvertex_t` | review-required |  |
| global | `mplane_t` | review-required |  |
| global | `texture_t` | review-required |  |
| global | `medge_t` | review-required |  |
| global | `mtexinfo_t` | review-required |  |
| global | `glpoly_t` | review-required |  |
| global | `msurface_t` | review-required |  |
| global | `mnode_t` | review-required |  |
| global | `mleaf_t` | review-required |  |
| global | `hull_t` | review-required |  |
| global | `mspriteframe_t` | review-required |  |
| global | `mspritegroup_t` | review-required |  |
| global | `mspriteframedesc_t` | review-required |  |
| global | `msprite_t` | review-required |  |
| global | `maliasframedesc_t` | review-required |  |
| global | `maliasgroupframedesc_t` | review-required |  |
| global | `maliasgroup_t` | review-required |  |
| global | `mtriangle_t` | review-required |  |
| global | `aliashdr_t` | review-required |  |
| global | `extern stvert_t stverts[MAXALIASVERTS]` | review-required |  |
| global | `extern mtriangle_t triangles[MAXALIASTRIS]` | review-required |  |
| global | `extern trivertx_t *poseverts[MAXALIASFRAMES]` | review-required |  |
| global | `modtype_t` | review-required |  |
| global | `model_t` | review-required |  |
| prototype | `Mod_Init` | review-required |  |
| prototype | `Mod_ClearAll` | review-required |  |
| prototype | `Mod_ForName` | review-required |  |
| prototype | `Mod_Extradata` | review-required |  |
| prototype | `Mod_TouchModel` | review-required |  |
| prototype | `Mod_PointInLeaf` | review-required |  |
| prototype | `Mod_LeafPVS` | review-required |  |

### `gl_refrag.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `R_RemoveEfrags` | review-required |  |
| function | `R_SplitEntityOnNode` | review-required |  |
| function | `R_AddEfrags` | review-required |  |
| function | `R_StoreEfrags` | review-required |  |
| global | `//=========================================================================== /* =============================================================================== ENTITY FRAGMENT FUNCTIONS =============================================================================== */ efrag_t **lastlink` | review-required |  |
| global | `vec3_t r_emins, r_emaxs` | review-required |  |
| global | `entity_t *r_addent` | review-required |  |

### `gl_rlight.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `R_AnimateLight` | review-required |  |
| function | `AddLightBlend` | review-required |  |
| function | `R_RenderDlight` | review-required |  |
| function | `R_RenderDlights` | review-required |  |
| function | `R_MarkLights` | review-required |  |
| function | `R_PushDlights` | review-required |  |
| function | `RecursiveLightPoint` | review-required |  |
| function | `R_LightPoint` | review-required |  |
| global | `/* ============================================================================= LIGHT SAMPLING ============================================================================= */ mplane_t *lightplane` | review-required |  |
| global | `vec3_t lightspot` | review-required |  |

### `gl_rmain.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `R_CullBox` | review-required |  |
| function | `R_RotateForEntity` | review-required |  |
| function | `R_GetSpriteFrame` | review-required |  |
| function | `R_DrawSpriteModel` | review-required |  |
| function | `GL_DrawAliasFrame` | review-required | `miniquake/render/entities.ml:aliasFrame` |
| function | `GL_DrawAliasShadow` | review-required |  |
| function | `R_SetupAliasFrame` | review-required |  |
| function | `R_DrawAliasModel` | review-required |  |
| function | `R_DrawEntitiesOnList` | review-required |  |
| function | `R_DrawViewModel` | review-required |  |
| function | `R_PolyBlend` | review-required |  |
| function | `SignbitsForPlane` | review-required |  |
| function | `R_SetFrustum` | review-required |  |
| function | `R_SetupFrame` | review-required |  |
| function | `MYgluPerspective` | review-required |  |
| function | `R_SetupGL` | review-required |  |
| function | `R_RenderScene` | review-required |  |
| function | `R_Clear` | review-required |  |
| function | `R_Mirror` | review-required |  |
| function | `R_RenderView` | review-required | `miniquake/view.ml:V_RenderView` |
| macro | `NUMVERTEXNORMALS` | review-required |  |
| macro | `SHADEDOT_QUANT` | review-required |  |
| global | `qboolean r_cache_thrash` | review-required |  |
| global | `// compatability vec3_t modelorg, r_entorigin` | review-required |  |
| global | `entity_t *currententity` | review-required |  |
| global | `int r_visframecount` | review-required |  |
| global | `// bumped when going to a new PVS int r_framecount` | review-required |  |
| global | `// used for dlight push checking mplane_t frustum[4]` | review-required |  |
| global | `int c_brush_polys, c_alias_polys` | review-required |  |
| global | `qboolean envmap` | review-required |  |
| global | `// true during envmap command capture int currenttexture = -1` | review-required |  |
| global | `// cached int particletexture` | review-required |  |
| global | `// little dot for particles int playertextures` | review-required |  |
| global | `// up to 16 color translated skins int mirrortexturenum` | review-required |  |
| global | `// quake texturenum, not gltexturenum qboolean mirror` | review-required |  |
| global | `mplane_t *mirror_plane` | review-required |  |
| global | `// // view origin // vec3_t vup` | review-required |  |
| global | `vec3_t vpn` | review-required |  |
| global | `vec3_t vright` | review-required |  |
| global | `vec3_t r_origin` | review-required |  |
| global | `float r_world_matrix[16]` | review-required |  |
| global | `float r_base_world_matrix[16]` | review-required |  |
| global | `// // screen size info // refdef_t r_refdef` | review-required |  |
| global | `mleaf_t *r_viewleaf, *r_oldviewleaf` | review-required |  |
| global | `texture_t *r_notexture_mip` | review-required |  |
| global | `int d_lightstylevalue[256]` | review-required |  |
| global | `extern cvar_t gl_ztrick` | review-required |  |
| global | `vec3_t shadevector` | review-required |  |
| global | `float shadelight, ambientlight` | review-required |  |
| global | `// precalculated dot products for quantized angles #define SHADEDOT_QUANT 16 float r_avertexnormal_dots[SHADEDOT_QUANT][256] = #include "anorm_dots.h"` | review-required |  |
| global | `float *shadedots = r_avertexnormal_dots[0]` | review-required |  |
| global | `int lastposenum` | review-required |  |
| global | `/* ============= GL_DrawAliasShadow ============= */ extern vec3_t lightspot` | review-required |  |
| prototype | `R_MarkLeaves` | review-required |  |

### `gl_rmisc.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `R_InitTextures` | review-required |  |
| function | `R_InitParticleTexture` | review-required |  |
| function | `R_Envmap_f` | review-required |  |
| function | `R_Init` | review-required |  |
| function | `R_TranslatePlayerSkin` | review-required |  |
| function | `R_NewMap` | review-required |  |
| function | `R_TimeRefresh_f` | review-required |  |
| function | `D_FlushCaches` | review-required |  |

### `gl_rsurf.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `R_AddDynamicLights` | review-required |  |
| function | `R_BuildLightMap` | review-required | `miniquake/render/world.ml:buildLightmap` |
| function | `R_TextureAnimation` | review-required |  |
| function | `GL_DisableMultitexture` | review-required |  |
| function | `GL_EnableMultitexture` | review-required |  |
| function | `R_DrawSequentialPoly` | review-required |  |
| function | `R_DrawSequentialPoly` | review-required |  |
| function | `DrawGLWaterPoly` | review-required |  |
| function | `DrawGLWaterPolyLightmap` | review-required |  |
| function | `DrawGLPoly` | review-required |  |
| function | `R_BlendLightmaps` | review-required |  |
| function | `R_RenderBrushPoly` | review-required |  |
| function | `R_RenderDynamicLightmaps` | review-required |  |
| function | `R_MirrorChain` | review-required |  |
| function | `R_DrawWaterSurfaces` | review-required |  |
| function | `R_DrawWaterSurfaces` | review-required |  |
| function | `DrawTextureChains` | review-required |  |
| function | `R_DrawBrushModel` | review-required |  |
| function | `R_RecursiveWorldNode` | review-required |  |
| function | `R_DrawWorld` | review-required |  |
| function | `R_MarkLeaves` | review-required |  |
| function | `AllocBlock` | review-required |  |
| function | `BuildSurfaceDisplayList` | review-required |  |
| function | `GL_CreateSurfaceLightmap` | review-required |  |
| function | `GL_BuildLightmaps` | review-required |  |
| type | `glRect_t` | review-required |  |
| field | `glRect_t.unsigned char l,t,w,h` | review-required |  |
| macro | `GL_RGBA4` | review-required |  |
| macro | `BLOCK_WIDTH` | review-required |  |
| macro | `BLOCK_HEIGHT` | review-required |  |
| macro | `MAX_LIGHTMAPS` | review-required |  |
| macro | `COLINEAR_EPSILON` | review-required |  |
| global | `// 1, 2, or 4 int lightmap_textures` | review-required |  |
| global | `unsigned blocklights[18*18]` | review-required |  |
| global | `glRect_t` | review-required |  |
| global | `glpoly_t *lightmap_polys[MAX_LIGHTMAPS]` | review-required |  |
| global | `qboolean lightmap_modified[MAX_LIGHTMAPS]` | review-required |  |
| global | `glRect_t lightmap_rectchange[MAX_LIGHTMAPS]` | review-required |  |
| global | `int allocated[MAX_LIGHTMAPS][BLOCK_WIDTH]` | review-required |  |
| global | `// the lightmap texture data needs to be kept in // main memory so texsubimage can update properly byte lightmaps[4*MAX_LIGHTMAPS*BLOCK_WIDTH*BLOCK_HEIGHT]` | review-required |  |
| global | `// For gl_texsort 0 msurface_t *skychain = NULL` | review-required |  |
| global | `msurface_t *waterchain = NULL` | review-required |  |
| global | `/* ============================================================= BRUSH MODELS ============================================================= */ extern int solidskytexture` | review-required |  |
| global | `extern int alphaskytexture` | review-required |  |
| global | `extern float speedscale` | review-required |  |
| global | `lpMTexFUNC qglMTexCoord2fSGIS = NULL` | review-required |  |
| global | `lpSelTexFUNC qglSelectTextureSGIS = NULL` | review-required |  |
| global | `qboolean mtexenabled = false` | review-required |  |
| global | `mvertex_t *r_pcurrentvertbase` | review-required |  |
| global | `model_t *currentmodel` | review-required |  |
| global | `int nColinElim` | review-required |  |
| prototype | `R_RenderDynamicLightmaps` | review-required |  |
| prototype | `DrawGLWaterPoly` | review-required |  |
| prototype | `DrawGLWaterPolyLightmap` | review-required |  |
| prototype | `GL_SelectTexture` | review-required |  |

### `gl_screen.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SCR_CenterPrint` | review-required |  |
| function | `SCR_DrawCenterString` | review-required |  |
| function | `SCR_CheckDrawCenterString` | review-required |  |
| function | `CalcFov` | review-required |  |
| function | `SCR_CalcRefdef` | review-required |  |
| function | `SCR_SizeUp_f` | review-required |  |
| function | `SCR_SizeDown_f` | review-required |  |
| function | `SCR_Init` | review-required |  |
| function | `SCR_DrawRam` | review-required |  |
| function | `SCR_DrawTurtle` | review-required |  |
| function | `SCR_DrawNet` | review-required |  |
| function | `SCR_DrawPause` | review-required |  |
| function | `SCR_DrawLoading` | review-required |  |
| function | `SCR_SetUpToDrawConsole` | review-required |  |
| function | `SCR_DrawConsole` | review-required |  |
| function | `SCR_ScreenShot_f` | review-required |  |
| function | `SCR_BeginLoadingPlaque` | review-required |  |
| function | `SCR_EndLoadingPlaque` | review-required |  |
| function | `SCR_DrawNotifyString` | review-required |  |
| function | `SCR_ModalMessage` | review-required |  |
| function | `SCR_BringDownConsole` | review-required |  |
| function | `SCR_TileClear` | review-required |  |
| function | `SCR_UpdateScreen` | review-required |  |
| type | `TargaHeader` | review-required |  |
| field | `TargaHeader.unsigned char id_length, colormap_type, image_type` | review-required |  |
| field | `TargaHeader.unsigned short colormap_index, colormap_length` | review-required |  |
| field | `TargaHeader.unsigned char colormap_size` | review-required |  |
| field | `TargaHeader.unsigned short x_origin, y_origin, width, height` | review-required |  |
| field | `TargaHeader.unsigned char pixel_size, attributes` | review-required |  |
| global | `// only the refresh window will be updated unless these variables are flagged int scr_copytop` | review-required |  |
| global | `int scr_copyeverything` | review-required |  |
| global | `float scr_con_current` | review-required |  |
| global | `float scr_conlines` | review-required |  |
| global | `// lines of console to display float oldscreensize, oldfov` | review-required |  |
| global | `extern cvar_t crosshair` | review-required |  |
| global | `qboolean scr_initialized` | review-required |  |
| global | `// ready to draw qpic_t *scr_ram` | review-required |  |
| global | `qpic_t *scr_net` | review-required |  |
| global | `qpic_t *scr_turtle` | review-required |  |
| global | `int scr_fullupdate` | review-required |  |
| global | `int clearconsole` | review-required |  |
| global | `int clearnotify` | review-required |  |
| global | `int sb_lines` | review-required |  |
| global | `viddef_t vid` | review-required |  |
| global | `// global video state vrect_t scr_vrect` | review-required |  |
| global | `qboolean scr_disabled_for_loading` | review-required |  |
| global | `qboolean scr_drawloading` | review-required |  |
| global | `float scr_disabled_time` | review-required |  |
| global | `qboolean block_drawing` | review-required |  |
| global | `/* =============================================================================== CENTER PRINTING =============================================================================== */ char scr_centerstring[1024]` | review-required |  |
| global | `float scr_centertime_start` | review-required |  |
| global | `// for slow victory printing float scr_centertime_off` | review-required |  |
| global | `int scr_center_lines` | review-required |  |
| global | `int scr_erase_lines` | review-required |  |
| global | `int scr_erase_center` | review-required |  |
| global | `TargaHeader` | review-required |  |
| global | `//============================================================================= char *scr_notifystring` | review-required |  |
| global | `qboolean scr_drawdialog` | review-required |  |
| prototype | `SCR_ScreenShot_f` | review-required |  |

### `gl_test.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Test_Init` | review-required |  |
| function | `HitPlane` | review-required |  |
| function | `Test_Spawn` | review-required |  |
| function | `DrawPuff` | review-required |  |
| function | `Test_Draw` | review-required |  |
| type | `puff_t` | review-required |  |
| field | `puff_t.plane_t *plane` | review-required |  |
| field | `puff_t.vec3_t origin` | review-required |  |
| field | `puff_t.vec3_t normal` | review-required |  |
| field | `puff_t.vec3_t up` | review-required |  |
| field | `puff_t.vec3_t right` | review-required |  |
| field | `puff_t.vec3_t reflect` | review-required |  |
| field | `puff_t.float length` | review-required |  |
| macro | `MAX_PUFFS` | review-required |  |
| global | `puff_t` | review-required |  |
| global | `plane_t junk` | review-required |  |

### `gl_vidnt.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `VID_HandlePause` | review-required |  |
| function | `VID_ForceLockState` | review-required |  |
| function | `VID_LockBuffer` | review-required |  |
| function | `VID_UnlockBuffer` | review-required |  |
| function | `VID_ForceUnlockedAndReturnState` | review-required |  |
| function | `D_BeginDirectRect` | review-required |  |
| function | `D_EndDirectRect` | review-required |  |
| function | `CenterWindow` | review-required |  |
| function | `VID_SetWindowedMode` | review-required |  |
| function | `VID_SetFullDIBMode` | review-required |  |
| function | `VID_SetMode` | review-required |  |
| function | `VID_UpdateWindowStatus` | review-required |  |
| function | `CheckTextureExtensions` | review-required |  |
| function | `CheckArrayExtensions` | review-required |  |
| function | `CheckMultiTextureExtensions` | review-required |  |
| function | `CheckMultiTextureExtensions` | review-required |  |
| function | `GL_Init` | review-required |  |
| function | `GL_BeginRendering` | review-required |  |
| function | `GL_EndRendering` | review-required |  |
| function | `VID_SetPalette` | review-required |  |
| function | `VID_ShiftPalette` | review-required |  |
| function | `VID_SetDefaultMode` | review-required |  |
| function | `VID_Shutdown` | review-required |  |
| function | `bSetupPixelFormat` | review-required |  |
| function | `MapKey` | review-required |  |
| function | `ClearAllStates` | review-required |  |
| function | `AppActivate` | review-required |  |
| function | `MainWndProc` | review-required |  |
| function | `VID_NumModes` | review-required |  |
| function | `VID_GetModePtr` | review-required |  |
| function | `VID_GetModeDescription` | review-required |  |
| function | `VID_GetExtModeDescription` | review-required |  |
| function | `VID_DescribeCurrentMode_f` | review-required |  |
| function | `VID_NumModes_f` | review-required |  |
| function | `VID_DescribeMode_f` | review-required |  |
| function | `VID_DescribeModes_f` | review-required |  |
| function | `VID_InitDIB` | review-required |  |
| function | `VID_InitFullDIB` | review-required |  |
| function | `VID_Is8bit` | review-required |  |
| function | `VID_Init8bitPalette` | review-required |  |
| function | `Check_Gamma` | review-required |  |
| function | `VID_Init` | review-required |  |
| function | `VID_MenuDraw` | review-required |  |
| function | `VID_MenuKey` | review-required |  |
| type | `vmode_t` | review-required |  |
| field | `vmode_t.modestate_t type` | review-required |  |
| field | `vmode_t.int width` | review-required |  |
| field | `vmode_t.int height` | review-required |  |
| field | `vmode_t.int modenum` | review-required |  |
| field | `vmode_t.int dib` | review-required |  |
| field | `vmode_t.int fullscreen` | review-required |  |
| field | `vmode_t.int bpp` | review-required |  |
| field | `vmode_t.int halfscreen` | review-required |  |
| field | `vmode_t.char modedesc[17]` | review-required |  |
| type | `lmode_t` | review-required |  |
| field | `lmode_t.int width` | review-required |  |
| field | `lmode_t.int height` | review-required |  |
| type | `modedesc_t` | review-required |  |
| field | `modedesc_t.int modenum` | review-required |  |
| field | `modedesc_t.char *desc` | review-required |  |
| field | `modedesc_t.int iscur` | review-required |  |
| macro | `MAX_MODE_LIST` | review-required |  |
| macro | `VID_ROW_SIZE` | review-required |  |
| macro | `WARP_WIDTH` | review-required |  |
| macro | `WARP_HEIGHT` | review-required |  |
| macro | `MAXWIDTH` | review-required |  |
| macro | `MAXHEIGHT` | review-required |  |
| macro | `BASEWIDTH` | review-required |  |
| macro | `BASEHEIGHT` | review-required |  |
| macro | `MODE_WINDOWED` | review-required |  |
| macro | `NO_MODE` | review-required |  |
| macro | `MODE_FULLSCREEN_DEFAULT` | review-required |  |
| macro | `TEXTURE_EXT_STRING` | review-required |  |
| macro | `GL_SHARED_TEXTURE_PALETTE_EXT` | review-required |  |
| macro | `MAX_COLUMN_SIZE` | review-required |  |
| macro | `MODE_AREA_HEIGHT` | review-required |  |
| macro | `MAX_MODEDESCS` | review-required |  |
| global | `vmode_t` | review-required |  |
| global | `lmode_t` | review-required |  |
| global | `const char *gl_vendor` | review-required |  |
| global | `const char *gl_renderer` | review-required |  |
| global | `const char *gl_version` | review-required |  |
| global | `const char *gl_extensions` | review-required |  |
| global | `qboolean DDActive` | review-required |  |
| global | `qboolean scr_skipupdate` | review-required |  |
| global | `static vmode_t modelist[MAX_MODE_LIST]` | review-required |  |
| global | `static int nummodes` | review-required |  |
| global | `static vmode_t *pcurrentmode` | review-required |  |
| global | `static vmode_t badmode` | review-required |  |
| global | `static DEVMODE gdevmode` | review-required |  |
| global | `static qboolean vid_initialized = false` | review-required |  |
| global | `static qboolean windowed, leavecurrentmode` | review-required |  |
| global | `static qboolean vid_canalttab = false` | review-required |  |
| global | `static qboolean vid_wassuspended = false` | review-required |  |
| global | `static int windowed_mouse` | review-required |  |
| global | `extern qboolean mouseactive` | review-required |  |
| global | `// from in_win.c static HICON hIcon` | review-required |  |
| global | `int DIBWidth, DIBHeight` | review-required |  |
| global | `RECT WindowRect` | review-required |  |
| global | `DWORD WindowStyle, ExWindowStyle` | review-required |  |
| global | `HWND mainwindow, dibwindow` | review-required |  |
| global | `int vid_modenum = NO_MODE` | review-required |  |
| global | `int vid_realmode` | review-required |  |
| global | `int vid_default = MODE_WINDOWED` | review-required |  |
| global | `static int windowed_default` | review-required |  |
| global | `unsigned char vid_curpal[256*3]` | review-required |  |
| global | `static qboolean fullsbardraw = false` | review-required |  |
| global | `static float vid_gamma = 1.0` | review-required |  |
| global | `HGLRC baseRC` | review-required |  |
| global | `HDC maindc` | review-required |  |
| global | `glvert_t glv` | review-required |  |
| global | `viddef_t vid` | review-required |  |
| global | `// global video state unsigned short d_8to16table[256]` | review-required |  |
| global | `unsigned d_8to24table[256]` | review-required |  |
| global | `unsigned char d_15to8table[65536]` | review-required |  |
| global | `float gldepthmin, gldepthmax` | review-required |  |
| global | `modestate_t modestate = MS_UNINIT` | review-required |  |
| global | `PROC glArrayElementEXT` | review-required |  |
| global | `PROC glColorPointerEXT` | review-required |  |
| global | `PROC glTexCoordPointerEXT` | review-required |  |
| global | `PROC glVertexPointerEXT` | review-required |  |
| global | `lp3DFXFUNC glColorTableEXT` | review-required |  |
| global | `qboolean is8bit = false` | review-required |  |
| global | `qboolean isPermedia = false` | review-required |  |
| global | `qboolean gl_mtexable = false` | review-required |  |
| global | `int window_center_x, window_center_y, window_x, window_y, window_width, window_height` | review-required |  |
| global | `RECT window_rect` | review-required |  |
| global | `//==================================== BINDTEXFUNCPTR bindTexFunc` | review-required |  |
| global | `//int texture_mode = GL_NEAREST; //int texture_mode = GL_NEAREST_MIPMAP_NEAREST; //int texture_mode = GL_NEAREST_MIPMAP_LINEAR; int texture_mode = GL_LINEAR` | review-required |  |
| global | `//int texture_mode = GL_LINEAR_MIPMAP_NEAREST; //int texture_mode = GL_LINEAR_MIPMAP_LINEAR; int texture_extension_number = 1` | review-required |  |
| global | `BOOL gammaworks` | review-required |  |
| global | `static int vid_line, vid_wmodes` | review-required |  |
| global | `modedesc_t` | review-required |  |
| prototype | `InitializeWindow` | review-required |  |
| prototype | `VID_MenuDraw` | review-required |  |
| prototype | `VID_MenuKey` | review-required |  |
| prototype | `MainWndProc` | review-required |  |
| prototype | `AppActivate` | review-required |  |
| prototype | `VID_GetModeDescription` | review-required |  |
| prototype | `ClearAllStates` | review-required |  |
| prototype | `VID_UpdateWindowStatus` | review-required |  |
| prototype | `GL_Init` | review-required |  |
| prototype | `M_Menu_Options_f` | review-required |  |
| prototype | `M_Print` | review-required |  |
| prototype | `M_PrintWhite` | review-required |  |
| prototype | `M_DrawCharacter` | review-required |  |
| prototype | `M_DrawTransPic` | review-required |  |
| prototype | `M_DrawPic` | review-required |  |

### `gl_warp.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `BoundPoly` | review-required |  |
| function | `SubdividePolygon` | review-required |  |
| function | `GL_SubdivideSurface` | review-required |  |
| function | `EmitWaterPolys` | review-required |  |
| function | `EmitSkyPolys` | review-required |  |
| function | `EmitBothSkyLayers` | review-required |  |
| function | `R_DrawSkyChain` | review-required |  |
| function | `LoadPCX` | review-required |  |
| function | `fgetLittleShort` | review-required |  |
| function | `fgetLittleLong` | review-required |  |
| function | `LoadTGA` | review-required |  |
| function | `R_LoadSkys` | review-required |  |
| function | `DrawSkyPolygon` | review-required |  |
| function | `ClipSkyPolygon` | review-required |  |
| function | `R_DrawSkyChain` | review-required |  |
| function | `R_ClearSkyBox` | review-required |  |
| function | `MakeSkyVec` | review-required |  |
| function | `R_DrawSkyBox` | review-required |  |
| function | `R_InitSky` | review-required |  |
| type | `pcx_t` | review-required |  |
| field | `pcx_t.char manufacturer` | review-required |  |
| field | `pcx_t.char version` | review-required |  |
| field | `pcx_t.char encoding` | review-required |  |
| field | `pcx_t.char bits_per_pixel` | review-required |  |
| field | `pcx_t.unsigned short xmin,ymin,xmax,ymax` | review-required |  |
| field | `pcx_t.unsigned short hres,vres` | review-required |  |
| field | `pcx_t.unsigned char palette[48]` | review-required |  |
| field | `pcx_t.char reserved` | review-required |  |
| field | `pcx_t.char color_planes` | review-required |  |
| field | `pcx_t.unsigned short bytes_per_line` | review-required |  |
| field | `pcx_t.unsigned short palette_type` | review-required |  |
| field | `pcx_t.char filler[58]` | review-required |  |
| field | `pcx_t.unsigned data` | review-required |  |
| type | `TargaHeader` | review-required |  |
| field | `TargaHeader.unsigned char id_length, colormap_type, image_type` | review-required |  |
| field | `TargaHeader.unsigned short colormap_index, colormap_length` | review-required |  |
| field | `TargaHeader.unsigned char colormap_size` | review-required |  |
| field | `TargaHeader.unsigned short x_origin, y_origin, width, height` | review-required |  |
| field | `TargaHeader.unsigned char pixel_size, attributes` | review-required |  |
| macro | `TURBSCALE` | review-required |  |
| macro | `SKY_TEX` | review-required |  |
| macro | `MAX_CLIP_VERTS` | review-required |  |
| global | `int skytexturenum` | review-required |  |
| global | `int solidskytexture` | review-required |  |
| global | `int alphaskytexture` | review-required |  |
| global | `float speedscale` | review-required |  |
| global | `// for top sky and bottom sky msurface_t *warpface` | review-required |  |
| global | `extern cvar_t gl_subdivide_size` | review-required |  |
| global | `pcx_t` | review-required |  |
| global | `byte *pcx_rgb` | review-required |  |
| global | `TargaHeader` | review-required |  |
| global | `TargaHeader targa_header` | review-required |  |
| global | `byte *targa_rgba` | review-required |  |
| global | `int c_sky` | review-required |  |
| global | `float skymins[2][6], skymaxs[2][6]` | review-required |  |

### `glquake.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `glvert_t` | review-required |  |
| field | `glvert_t.float x, y, z` | review-required |  |
| field | `glvert_t.float s, t` | review-required |  |
| field | `glvert_t.float r, g, b` | review-required |  |
| type | `surfcache_t` | review-required |  |
| field | `surfcache_t.struct surfcache_s *next` | review-required |  |
| field | `surfcache_t.struct surfcache_s **owner` | review-required |  |
| field | `surfcache_t.// NULL is an empty chunk of memory int lightadj[MAXLIGHTMAPS]` | review-required |  |
| field | `surfcache_t.// checked for strobe flush int dlight` | review-required |  |
| field | `surfcache_t.int size` | review-required |  |
| field | `surfcache_t.// including header unsigned width` | review-required |  |
| field | `surfcache_t.unsigned height` | review-required |  |
| field | `surfcache_t.// DEBUG only needed for debug float mipscale` | review-required |  |
| field | `surfcache_t.struct texture_s *texture` | review-required |  |
| field | `surfcache_t.// checked for animating textures byte data[4]` | review-required |  |
| type | `drawsurf_t` | review-required |  |
| field | `drawsurf_t.pixel_t *surfdat` | review-required |  |
| field | `drawsurf_t.// destination for generated surface int rowbytes` | review-required |  |
| field | `drawsurf_t.// destination logical width in bytes msurface_t *surf` | review-required |  |
| field | `drawsurf_t.// description for surface to generate fixed8_t lightadj[MAXLIGHTMAPS]` | review-required |  |
| field | `drawsurf_t.// adjust for lightmap levels for dynamic lighting texture_t *texture` | review-required |  |
| field | `drawsurf_t.// corrected for animating textures int surfmip` | review-required |  |
| field | `drawsurf_t.// mipmapped ratio of surface texels / world pixels int surfwidth` | review-required |  |
| field | `drawsurf_t.// in mipmapped texels int surfheight` | review-required |  |
| type | `ptype_t` | review-required |  |
| enum-value | `ptype_t.pt_static` | review-required |  |
| enum-value | `ptype_t.pt_grav` | review-required |  |
| enum-value | `ptype_t.pt_slowgrav` | review-required |  |
| enum-value | `ptype_t.pt_fire` | review-required |  |
| enum-value | `ptype_t.pt_explode` | review-required |  |
| enum-value | `ptype_t.pt_explode2` | review-required |  |
| enum-value | `ptype_t.pt_blob` | review-required |  |
| enum-value | `ptype_t.pt_blob2` | review-required |  |
| type | `particle_t` | review-required |  |
| field | `particle_t.// driver-usable fields vec3_t org` | review-required |  |
| field | `particle_t.float color` | review-required |  |
| field | `particle_t.// drivers never touch the following fields struct particle_s *next` | review-required |  |
| field | `particle_t.vec3_t vel` | review-required |  |
| field | `particle_t.float ramp` | review-required |  |
| field | `particle_t.float die` | review-required |  |
| field | `particle_t.ptype_t type` | review-required |  |
| macro | `ALIAS_BASE_SIZE_RATIO` | review-required |  |
| macro | `MAX_LBM_HEIGHT` | review-required |  |
| macro | `TILE_SIZE` | review-required |  |
| macro | `SKYSHIFT` | review-required |  |
| macro | `SKYSIZE` | review-required |  |
| macro | `SKYMASK` | review-required |  |
| macro | `BACKFACE_EPSILON` | review-required |  |
| macro | `TEXTURE0_SGIS` | review-required |  |
| macro | `TEXTURE1_SGIS` | review-required |  |
| macro | `APIENTRY` | review-required |  |
| global | `extern BINDTEXFUNCPTR bindTexFunc` | review-required |  |
| global | `extern DELTEXFUNCPTR delTexFunc` | review-required |  |
| global | `extern TEXSUBIMAGEPTR TexSubImage2DFunc` | review-required |  |
| global | `extern int texture_mode` | review-required |  |
| global | `extern float gldepthmin, gldepthmax` | review-required |  |
| global | `glvert_t` | review-required |  |
| global | `extern glvert_t glv` | review-required |  |
| global | `extern int glx, gly, glwidth, glheight` | review-required |  |
| global | `extern PROC glColorPointerEXT` | review-required |  |
| global | `extern PROC glTexturePointerEXT` | review-required |  |
| global | `extern PROC glVertexPointerEXT` | review-required |  |
| global | `surfcache_t` | review-required |  |
| global | `drawsurf_t` | review-required |  |
| global | `ptype_t` | review-required |  |
| global | `particle_t` | review-required |  |
| global | `//==================================================== extern entity_t r_worldentity` | review-required |  |
| global | `extern qboolean r_cache_thrash` | review-required |  |
| global | `// compatability extern vec3_t modelorg, r_entorigin` | review-required |  |
| global | `extern entity_t *currententity` | review-required |  |
| global | `extern int r_visframecount` | review-required |  |
| global | `// ??? what difs? extern int r_framecount` | review-required |  |
| global | `extern mplane_t frustum[4]` | review-required |  |
| global | `extern int c_brush_polys, c_alias_polys` | review-required |  |
| global | `// // view origin // extern vec3_t vup` | review-required |  |
| global | `extern vec3_t vpn` | review-required |  |
| global | `extern vec3_t vright` | review-required |  |
| global | `extern vec3_t r_origin` | review-required |  |
| global | `// // screen size info // extern refdef_t r_refdef` | review-required |  |
| global | `extern mleaf_t *r_viewleaf, *r_oldviewleaf` | review-required |  |
| global | `extern texture_t *r_notexture_mip` | review-required |  |
| global | `extern int d_lightstylevalue[256]` | review-required |  |
| global | `// 8.8 fraction of base light value extern qboolean envmap` | review-required |  |
| global | `extern int currenttexture` | review-required |  |
| global | `extern int cnttextures[2]` | review-required |  |
| global | `extern int particletexture` | review-required |  |
| global | `extern int playertextures` | review-required |  |
| global | `extern int skytexturenum` | review-required |  |
| global | `// index in cl.loadmodel, not gl texture object extern cvar_t r_norefresh` | review-required |  |
| global | `extern cvar_t r_drawentities` | review-required |  |
| global | `extern cvar_t r_drawworld` | review-required |  |
| global | `extern cvar_t r_drawviewmodel` | review-required |  |
| global | `extern cvar_t r_speeds` | review-required |  |
| global | `extern cvar_t r_waterwarp` | review-required |  |
| global | `extern cvar_t r_fullbright` | review-required |  |
| global | `extern cvar_t r_lightmap` | review-required |  |
| global | `extern cvar_t r_shadows` | review-required |  |
| global | `extern cvar_t r_mirroralpha` | review-required |  |
| global | `extern cvar_t r_wateralpha` | review-required |  |
| global | `extern cvar_t r_dynamic` | review-required |  |
| global | `extern cvar_t r_novis` | review-required |  |
| global | `extern cvar_t gl_clear` | review-required |  |
| global | `extern cvar_t gl_cull` | review-required |  |
| global | `extern cvar_t gl_poly` | review-required |  |
| global | `extern cvar_t gl_texsort` | review-required |  |
| global | `extern cvar_t gl_smoothmodels` | review-required |  |
| global | `extern cvar_t gl_affinemodels` | review-required |  |
| global | `extern cvar_t gl_polyblend` | review-required |  |
| global | `extern cvar_t gl_keeptjunctions` | review-required |  |
| global | `extern cvar_t gl_reporttjunctions` | review-required |  |
| global | `extern cvar_t gl_flashblend` | review-required |  |
| global | `extern cvar_t gl_nocolors` | review-required |  |
| global | `extern cvar_t gl_doubleeyes` | review-required |  |
| global | `extern int gl_lightmap_format` | review-required |  |
| global | `extern int gl_solid_format` | review-required |  |
| global | `extern int gl_alpha_format` | review-required |  |
| global | `extern cvar_t gl_max_size` | review-required |  |
| global | `extern cvar_t gl_playermip` | review-required |  |
| global | `extern int mirrortexturenum` | review-required |  |
| global | `// quake texturenum, not gltexturenum extern qboolean mirror` | review-required |  |
| global | `extern mplane_t *mirror_plane` | review-required |  |
| global | `extern float r_world_matrix[16]` | review-required |  |
| global | `extern const char *gl_vendor` | review-required |  |
| global | `extern const char *gl_renderer` | review-required |  |
| global | `extern const char *gl_version` | review-required |  |
| global | `extern const char *gl_extensions` | review-required |  |
| global | `extern lpMTexFUNC qglMTexCoord2fSGIS` | review-required |  |
| global | `extern lpSelTexFUNC qglSelectTextureSGIS` | review-required |  |
| global | `extern qboolean gl_mtexable` | review-required |  |
| prototype | `warning` | review-required |  |
| prototype | `GL_EndRendering` | review-required |  |
| prototype | `GL_Upload32` | review-required |  |
| prototype | `GL_Upload8` | review-required |  |
| prototype | `GL_LoadTexture` | review-required |  |
| prototype | `GL_FindTexture` | review-required |  |
| prototype | `R_ReadPointFile_f` | review-required |  |
| prototype | `R_TextureAnimation` | review-required |  |
| prototype | `R_TranslatePlayerSkin` | review-required |  |
| prototype | `GL_Bind` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `GL_DisableMultitexture` | review-required |  |
| prototype | `GL_EnableMultitexture` | review-required |  |

### `host.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Host_EndGame` | review-required | `miniquake/host.ml:Host_EndGame` |
| function | `Host_Error` | review-required | `miniquake/host.ml:Host_Error` |
| function | `Host_FindMaxClients` | review-required | `miniquake/host.ml:Host_FindMaxClients` |
| function | `Host_InitLocal` | review-required | `miniquake/host.ml:Host_InitLocal` |
| function | `Host_WriteConfiguration` | review-required | `miniquake/host.ml:Host_WriteConfiguration` |
| function | `SV_ClientPrintf` | review-required | `miniquake/host.ml:SV_ClientPrintf` |
| function | `SV_BroadcastPrintf` | review-required | `miniquake/host.ml:SV_BroadcastPrintf` |
| function | `Host_ClientCommands` | review-required | `miniquake/host.ml:Host_ClientCommands` |
| function | `SV_DropClient` | review-required | `miniquake/host.ml:SV_DropClient` |
| function | `Host_ShutdownServer` | review-required | `miniquake/host.ml:Host_ShutdownServer` |
| function | `Host_ClearMemory` | review-required | `miniquake/host.ml:Host_ClearMemory` |
| function | `Host_FilterTime` | review-required | `miniquake/host.ml:Host_FilterTime`, `miniquake/host.ml:filterTime` |
| function | `Host_GetConsoleCommands` | review-required | `miniquake/host.ml:Host_GetConsoleCommands` |
| function | `_Host_ServerFrame` | review-required | `miniquake/host.ml:_Host_ServerFrame`, `miniquake/host.ml:Host_ServerFrame` |
| function | `Host_ServerFrame` | review-required | `miniquake/host.ml:Host_ServerFrame`, `miniquake/host.ml:_Host_ServerFrame` |
| function | `Host_ServerFrame` | review-required | `miniquake/host.ml:Host_ServerFrame`, `miniquake/host.ml:_Host_ServerFrame` |
| function | `_Host_Frame` | review-required | `miniquake/host.ml:_Host_Frame`, `miniquake/host.ml:frame`, `miniquake/host.ml:Host_Frame` |
| function | `Host_Frame` | review-required | `miniquake/host.ml:Host_Frame`, `miniquake/host.ml:frame`, `miniquake/host.ml:_Host_Frame` |
| function | `Host_InitVCR` | review-required |  |
| function | `Host_Init` | review-required | `miniquake/host.ml:Host_Init` |
| function | `Host_Shutdown` | review-required | `miniquake/host.ml:Host_Shutdown`, `miniquake/host.ml:shutdown` |
| macro | `VCR_SIGNATURE` | review-required |  |
| global | `qboolean host_initialized` | review-required |  |
| global | `// true if into command execution double host_frametime` | review-required |  |
| global | `double host_time` | review-required |  |
| global | `double realtime` | review-required |  |
| global | `// without any filtering or bounding double oldrealtime` | review-required |  |
| global | `// last frame run int host_framecount` | review-required |  |
| global | `int host_hunklevel` | review-required |  |
| global | `int minimum_memory` | review-required |  |
| global | `client_t *host_client` | review-required |  |
| global | `// current client jmp_buf host_abortserver` | review-required |  |
| global | `byte *host_basepal` | review-required |  |
| global | `byte *host_colormap` | review-required |  |
| global | `//============================================================================ extern int vcrFile` | review-required |  |

### `host_cmd.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Host_Quit_f` | review-required | `miniquake/host.ml:Host_Quit_f` |
| function | `Host_Status_f` | review-required | `miniquake/host.ml:Host_Status_f` |
| function | `Host_God_f` | review-required | `miniquake/host.ml:Host_God_f` |
| function | `Host_Notarget_f` | review-required | `miniquake/host.ml:Host_Notarget_f` |
| function | `Host_Noclip_f` | review-required | `miniquake/host.ml:Host_Noclip_f` |
| function | `Host_Fly_f` | review-required | `miniquake/host.ml:Host_Fly_f` |
| function | `Host_Ping_f` | review-required | `miniquake/host.ml:Host_Ping_f` |
| function | `Host_Map_f` | review-required | `miniquake/host.ml:Host_Map_f` |
| function | `Host_Changelevel_f` | review-required | `miniquake/host.ml:Host_Changelevel_f` |
| function | `Host_Restart_f` | review-required | `miniquake/host.ml:Host_Restart_f` |
| function | `Host_Reconnect_f` | review-required | `miniquake/host.ml:Host_Reconnect_f` |
| function | `Host_Connect_f` | review-required | `miniquake/host.ml:Host_Connect_f` |
| function | `Host_SavegameComment` | review-required | `miniquake/host.ml:Host_SavegameComment` |
| function | `Host_Savegame_f` | review-required | `miniquake/host.ml:Host_Savegame_f` |
| function | `Host_Loadgame_f` | review-required | `miniquake/host.ml:Host_Loadgame_f` |
| function | `SaveGamestate` | review-required |  |
| function | `LoadGamestate` | review-required |  |
| function | `Host_Changelevel2_f` | review-required |  |
| function | `Host_Name_f` | review-required | `miniquake/host.ml:Host_Name_f` |
| function | `Host_Version_f` | review-required | `miniquake/host.ml:Host_Version_f` |
| function | `Host_Please_f` | review-required |  |
| function | `Host_Say` | review-required | `miniquake/host.ml:Host_Say` |
| function | `Host_Say_f` | review-required | `miniquake/host.ml:Host_Say_f` |
| function | `Host_Say_Team_f` | review-required | `miniquake/host.ml:Host_Say_Team_f` |
| function | `Host_Tell_f` | review-required | `miniquake/host.ml:Host_Tell_f` |
| function | `Host_Color_f` | review-required | `miniquake/host.ml:Host_Color_f` |
| function | `Host_Kill_f` | review-required | `miniquake/host.ml:Host_Kill_f` |
| function | `Host_Pause_f` | review-required | `miniquake/host.ml:Host_Pause_f` |
| function | `Host_PreSpawn_f` | review-required | `miniquake/host.ml:Host_PreSpawn_f` |
| function | `Host_Spawn_f` | review-required | `miniquake/host.ml:Host_Spawn_f` |
| function | `Host_Begin_f` | review-required | `miniquake/host.ml:Host_Begin_f` |
| function | `Host_Kick_f` | review-required | `miniquake/host.ml:Host_Kick_f` |
| function | `Host_Give_f` | review-required | `miniquake/host.ml:Host_Give_f` |
| function | `FindViewthing` | review-required | `miniquake/host.ml:FindViewthing` |
| function | `Host_Viewmodel_f` | review-required | `miniquake/host.ml:Host_Viewmodel_f` |
| function | `Host_Viewframe_f` | review-required | `miniquake/host.ml:Host_Viewframe_f` |
| function | `PrintFrameName` | review-required | `miniquake/host.ml:PrintFrameName` |
| function | `Host_Viewnext_f` | review-required | `miniquake/host.ml:Host_Viewnext_f` |
| function | `Host_Viewprev_f` | review-required | `miniquake/host.ml:Host_Viewprev_f` |
| function | `Host_Startdemos_f` | review-required | `miniquake/host.ml:Host_Startdemos_f` |
| function | `Host_Demos_f` | review-required | `miniquake/host.ml:Host_Demos_f` |
| function | `Host_Stopdemo_f` | review-required | `miniquake/host.ml:Host_Stopdemo_f` |
| function | `Host_InitCommands` | review-required | `miniquake/host.ml:Host_InitCommands` |
| macro | `SAVEGAME_VERSION` | review-required |  |
| global | `int current_skill` | review-required |  |
| global | `qboolean noclip_anglehack` | review-required |  |
| prototype | `Mod_Print` | review-required |  |
| prototype | `M_Menu_Quit_f` | review-required |  |

### `in_win.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Force_CenterView_f` | review-required | `miniquake/input.ml:Force_CenterView_f` |
| function | `IN_UpdateClipCursor` | review-required | `miniquake/input.ml:IN_UpdateClipCursor` |
| function | `IN_ShowMouse` | review-required | `miniquake/input.ml:IN_ShowMouse` |
| function | `IN_HideMouse` | review-required | `miniquake/input.ml:IN_HideMouse` |
| function | `IN_ActivateMouse` | review-required | `miniquake/input.ml:IN_ActivateMouse` |
| function | `IN_SetQuakeMouseState` | review-required | `miniquake/input.ml:IN_SetQuakeMouseState` |
| function | `IN_DeactivateMouse` | review-required | `miniquake/input.ml:IN_DeactivateMouse` |
| function | `IN_RestoreOriginalMouseState` | review-required | `miniquake/input.ml:IN_RestoreOriginalMouseState` |
| function | `IN_InitDInput` | review-required |  |
| function | `IN_StartupMouse` | review-required | `miniquake/input.ml:IN_StartupMouse` |
| function | `IN_Init` | review-required | `miniquake/input.ml:IN_Init`, `miniquake/input.ml:Key_Init` |
| function | `IN_Shutdown` | review-required | `miniquake/input.ml:IN_Shutdown` |
| function | `IN_MouseEvent` | review-required | `miniquake/input.ml:IN_MouseEvent` |
| function | `IN_MouseMove` | review-required |  |
| function | `IN_Move` | review-required |  |
| function | `IN_Accumulate` | review-required | `miniquake/input.ml:IN_Accumulate` |
| function | `IN_ClearStates` | review-required | `miniquake/input.ml:IN_ClearStates`, `miniquake/input.ml:Key_ClearStates` |
| function | `IN_StartupJoystick` | review-required |  |
| function | `RawValuePointer` | review-required |  |
| function | `Joy_AdvancedUpdate_f` | review-required |  |
| function | `IN_Commands` | review-required |  |
| function | `IN_ReadJoystick` | review-required |  |
| function | `IN_JoyMove` | review-required |  |
| type | `MYDATA` | review-required |  |
| field | `MYDATA.LONG lX` | review-required |  |
| field | `MYDATA.// X axis goes here LONG lY` | review-required |  |
| field | `MYDATA.// Y axis goes here LONG lZ` | review-required |  |
| field | `MYDATA.// Z axis goes here BYTE bButtonA` | review-required |  |
| field | `MYDATA.// One button goes here BYTE bButtonB` | review-required |  |
| field | `MYDATA.// Another button goes here BYTE bButtonC` | review-required |  |
| field | `MYDATA.// Another button goes here BYTE bButtonD` | review-required |  |
| type | `_ControlList` | review-required |  |
| enum-value | `_ControlList.AxisNada = 0` | review-required |  |
| enum-value | `_ControlList.AxisForward` | review-required |  |
| enum-value | `_ControlList.AxisLook` | review-required |  |
| enum-value | `_ControlList.AxisSide` | review-required |  |
| enum-value | `_ControlList.AxisTurn` | review-required |  |
| macro | `DINPUT_BUFFERSIZE` | review-required |  |
| macro | `iDirectInputCreate` | review-required |  |
| macro | `JOY_ABSOLUTE_AXIS` | review-required |  |
| macro | `JOY_RELATIVE_AXIS` | review-required |  |
| macro | `JOY_MAX_AXES` | review-required |  |
| macro | `JOY_AXIS_X` | review-required |  |
| macro | `JOY_AXIS_Y` | review-required |  |
| macro | `JOY_AXIS_Z` | review-required |  |
| macro | `JOY_AXIS_R` | review-required |  |
| macro | `JOY_AXIS_U` | review-required |  |
| macro | `JOY_AXIS_V` | review-required |  |
| macro | `NUM_OBJECTS` | review-required |  |
| global | `int mouse_buttons` | review-required |  |
| global | `int mouse_oldbuttonstate` | review-required |  |
| global | `POINT current_pos` | review-required |  |
| global | `int mouse_x, mouse_y, old_mouse_x, old_mouse_y, mx_accum, my_accum` | review-required |  |
| global | `static qboolean restore_spi` | review-required |  |
| global | `unsigned int uiWheelMessage` | review-required |  |
| global | `qboolean mouseactive` | review-required |  |
| global | `qboolean mouseinitialized` | review-required |  |
| global | `static qboolean mouseparmsvalid, mouseactivatetoggle` | review-required |  |
| global | `static qboolean mouseshowtoggle = 1` | review-required |  |
| global | `static qboolean dinput_acquired` | review-required |  |
| global | `static unsigned int mstate_di` | review-required |  |
| global | `DWORD dwAxisMap[JOY_MAX_AXES]` | review-required |  |
| global | `DWORD dwControlMap[JOY_MAX_AXES]` | review-required |  |
| global | `PDWORD pdwRawValue[JOY_MAX_AXES]` | review-required |  |
| global | `qboolean joy_avail, joy_advancedinit, joy_haspov` | review-required |  |
| global | `DWORD joy_oldbuttonstate, joy_oldpovstate` | review-required |  |
| global | `int joy_id` | review-required |  |
| global | `DWORD joy_flags` | review-required |  |
| global | `DWORD joy_numbuttons` | review-required |  |
| global | `static LPDIRECTINPUT g_pdi` | review-required |  |
| global | `static LPDIRECTINPUTDEVICE g_pMouse` | review-required |  |
| global | `static JOYINFOEX ji` | review-required |  |
| global | `static HINSTANCE hInstDI` | review-required |  |
| global | `static qboolean dinput` | review-required |  |
| global | `MYDATA` | review-required |  |
| prototype | `iDirectInputCreate` | review-required |  |
| prototype | `IN_StartupJoystick` | review-required |  |
| prototype | `Joy_AdvancedUpdate_f` | review-required |  |
| prototype | `IN_JoyMove` | review-required |  |

### `input.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `external` | review-required |  |
| prototype | `IN_Shutdown` | review-required |  |
| prototype | `IN_Commands` | review-required |  |
| prototype | `IN_Move` | review-required |  |
| prototype | `IN_ClearStates` | review-required |  |

### `keys.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Key_Console` | review-required | `miniquake/console.ml:Con_DrawConsole` |
| function | `Key_Message` | review-required |  |
| function | `Key_StringToKeynum` | review-required | `miniquake/input.ml:Key_StringToKeynum` |
| function | `Key_KeynumToString` | review-required | `miniquake/input.ml:Key_KeynumToString` |
| function | `Key_SetBinding` | review-required | `miniquake/input.ml:Key_SetBinding` |
| function | `Key_Unbind_f` | review-required | `miniquake/input.ml:Key_Unbind_f` |
| function | `Key_Unbindall_f` | review-required | `miniquake/input.ml:Key_Unbindall_f` |
| function | `Key_Bind_f` | review-required | `miniquake/input.ml:Key_Bind_f` |
| function | `Key_WriteBindings` | review-required | `miniquake/input.ml:Key_WriteBindings` |
| function | `Key_Init` | review-required | `miniquake/input.ml:Key_Init`, `miniquake/input.ml:IN_Init`, `miniquake/host.ml:Host_Init`, `miniquake/menu.ml:M_Init` |
| function | `Key_Event` | review-required | `miniquake/input.ml:Key_Event` |
| function | `Key_ClearStates` | review-required | `miniquake/input.ml:Key_ClearStates`, `miniquake/input.ml:IN_ClearStates` |
| type | `keyname_t` | review-required |  |
| field | `keyname_t.char *name` | review-required |  |
| field | `keyname_t.int keynum` | review-required |  |
| macro | `MAXCMDLINE` | review-required |  |
| global | `int key_linepos` | review-required |  |
| global | `int shift_down=false` | review-required |  |
| global | `int key_lastpress` | review-required |  |
| global | `int edit_line=0` | review-required |  |
| global | `int history_line=0` | review-required |  |
| global | `keydest_t key_dest` | review-required |  |
| global | `int key_count` | review-required |  |
| global | `// incremented every key event char *keybindings[256]` | review-required |  |
| global | `qboolean consolekeys[256]` | review-required |  |
| global | `// if true, can't be rebound while in console qboolean menubound[256]` | review-required |  |
| global | `// if true, can't be rebound while in menu int keyshift[256]` | review-required |  |
| global | `// key to map to if shift held down in console int key_repeats[256]` | review-required |  |
| global | `// if > 1, it is autorepeating qboolean keydown[256]` | review-required |  |
| global | `keyname_t` | review-required |  |
| global | `//============================================================================ char chat_buffer[32]` | review-required |  |
| global | `qboolean team_message = false` | review-required |  |

### `keys.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `keydest_t` | review-required |  |
| enum-value | `keydest_t.key_game` | review-required |  |
| enum-value | `keydest_t.key_console` | review-required |  |
| enum-value | `keydest_t.key_message` | review-required |  |
| enum-value | `keydest_t.key_menu` | review-required |  |
| macro | `K_TAB` | review-required |  |
| macro | `K_ENTER` | review-required |  |
| macro | `K_ESCAPE` | review-required |  |
| macro | `K_SPACE` | review-required |  |
| macro | `K_BACKSPACE` | review-required |  |
| macro | `K_UPARROW` | review-required |  |
| macro | `K_DOWNARROW` | review-required |  |
| macro | `K_LEFTARROW` | review-required |  |
| macro | `K_RIGHTARROW` | review-required |  |
| macro | `K_ALT` | review-required |  |
| macro | `K_CTRL` | review-required |  |
| macro | `K_SHIFT` | review-required |  |
| macro | `K_F1` | review-required |  |
| macro | `K_F2` | review-required |  |
| macro | `K_F3` | review-required |  |
| macro | `K_F4` | review-required |  |
| macro | `K_F5` | review-required |  |
| macro | `K_F6` | review-required |  |
| macro | `K_F7` | review-required |  |
| macro | `K_F8` | review-required |  |
| macro | `K_F9` | review-required |  |
| macro | `K_F10` | review-required |  |
| macro | `K_F11` | review-required |  |
| macro | `K_F12` | review-required |  |
| macro | `K_INS` | review-required |  |
| macro | `K_DEL` | review-required |  |
| macro | `K_PGDN` | review-required |  |
| macro | `K_PGUP` | review-required |  |
| macro | `K_HOME` | review-required |  |
| macro | `K_END` | review-required |  |
| macro | `K_PAUSE` | review-required |  |
| macro | `K_MOUSE1` | review-required |  |
| macro | `K_MOUSE2` | review-required |  |
| macro | `K_MOUSE3` | review-required |  |
| macro | `K_JOY1` | review-required |  |
| macro | `K_JOY2` | review-required |  |
| macro | `K_JOY3` | review-required |  |
| macro | `K_JOY4` | review-required |  |
| macro | `K_AUX1` | review-required |  |
| macro | `K_AUX2` | review-required |  |
| macro | `K_AUX3` | review-required |  |
| macro | `K_AUX4` | review-required |  |
| macro | `K_AUX5` | review-required |  |
| macro | `K_AUX6` | review-required |  |
| macro | `K_AUX7` | review-required |  |
| macro | `K_AUX8` | review-required |  |
| macro | `K_AUX9` | review-required |  |
| macro | `K_AUX10` | review-required |  |
| macro | `K_AUX11` | review-required |  |
| macro | `K_AUX12` | review-required |  |
| macro | `K_AUX13` | review-required |  |
| macro | `K_AUX14` | review-required |  |
| macro | `K_AUX15` | review-required |  |
| macro | `K_AUX16` | review-required |  |
| macro | `K_AUX17` | review-required |  |
| macro | `K_AUX18` | review-required |  |
| macro | `K_AUX19` | review-required |  |
| macro | `K_AUX20` | review-required |  |
| macro | `K_AUX21` | review-required |  |
| macro | `K_AUX22` | review-required |  |
| macro | `K_AUX23` | review-required |  |
| macro | `K_AUX24` | review-required |  |
| macro | `K_AUX25` | review-required |  |
| macro | `K_AUX26` | review-required |  |
| macro | `K_AUX27` | review-required |  |
| macro | `K_AUX28` | review-required |  |
| macro | `K_AUX29` | review-required |  |
| macro | `K_AUX30` | review-required |  |
| macro | `K_AUX31` | review-required |  |
| macro | `K_AUX32` | review-required |  |
| macro | `K_MWHEELUP` | review-required |  |
| macro | `K_MWHEELDOWN` | review-required |  |
| global | `keydest_t` | review-required |  |
| global | `extern keydest_t key_dest` | review-required |  |
| global | `extern char *keybindings[256]` | review-required |  |
| global | `extern int key_repeats[256]` | review-required |  |
| global | `extern int key_count` | review-required |  |
| global | `// incremented every key event extern int key_lastpress` | review-required |  |
| prototype | `Key_Event` | review-required |  |
| prototype | `Key_Init` | review-required |  |
| prototype | `Key_WriteBindings` | review-required |  |
| prototype | `Key_SetBinding` | review-required |  |
| prototype | `Key_ClearStates` | review-required |  |

### `mathlib.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `ProjectPointOnPlane` | review-required | `miniquake/mathlib.ml:projectPointOnPlane`, `miniquake/mathlib.ml:ProjectPointOnPlane` |
| function | `PerpendicularVector` | review-required | `miniquake/mathlib.ml:perpendicularVector`, `miniquake/mathlib.ml:PerpendicularVector` |
| function | `RotatePointAroundVector` | review-required | `miniquake/mathlib.ml:rotatePointAroundVector`, `miniquake/mathlib.ml:RotatePointAroundVector` |
| function | `anglemod` | review-required | `miniquake/mathlib.ml:angleMod`, `miniquake/mathlib.ml:anglemod` |
| function | `BOPS_Error` | review-required | `miniquake/mathlib.ml:BOPS_Error` |
| function | `BoxOnPlaneSide` | review-required | `miniquake/mathlib.ml:boxOnPlaneSide`, `miniquake/mathlib.ml:BoxOnPlaneSide` |
| function | `AngleVectors` | review-required | `miniquake/mathlib.ml:angleVectors`, `miniquake/mathlib.ml:AngleVectors` |
| function | `VectorCompare` | review-required | `miniquake/mathlib.ml:vectorCompare`, `miniquake/mathlib.ml:VectorCompare` |
| function | `VectorMA` | review-required | `miniquake/mathlib.ml:vectorMA`, `miniquake/mathlib.ml:VectorMA` |
| function | `_DotProduct` | review-required | `miniquake/mathlib.ml:_DotProduct`, `miniquake/mathlib.ml:dotProduct`, `miniquake/mathlib.ml:DotProduct` |
| function | `_VectorSubtract` | review-required | `miniquake/mathlib.ml:_VectorSubtract`, `miniquake/mathlib.ml:vectorSubtract`, `miniquake/mathlib.ml:VectorSubtract` |
| function | `_VectorAdd` | review-required | `miniquake/mathlib.ml:_VectorAdd`, `miniquake/mathlib.ml:vectorAdd`, `miniquake/mathlib.ml:VectorAdd` |
| function | `_VectorCopy` | review-required | `miniquake/mathlib.ml:_VectorCopy`, `miniquake/mathlib.ml:vectorCopy`, `miniquake/mathlib.ml:VectorCopy` |
| function | `CrossProduct` | review-required | `miniquake/mathlib.ml:crossProduct`, `miniquake/mathlib.ml:CrossProduct` |
| function | `Length` | review-required | `miniquake/mathlib.ml:length`, `miniquake/mathlib.ml:Length` |
| function | `VectorNormalize` | review-required | `miniquake/mathlib.ml:vectorNormalize`, `miniquake/mathlib.ml:VectorNormalize` |
| function | `VectorInverse` | review-required | `miniquake/mathlib.ml:vectorInverse`, `miniquake/mathlib.ml:VectorInverse` |
| function | `VectorScale` | review-required | `miniquake/mathlib.ml:vectorScale`, `miniquake/mathlib.ml:VectorScale` |
| function | `Q_log2` | review-required | `miniquake/mathlib.ml:Q_log2`, `miniquake/mathlib.ml:qLog2` |
| function | `R_ConcatRotations` | review-required | `miniquake/mathlib.ml:R_ConcatRotations`, `miniquake/mathlib.ml:concatRotations` |
| function | `R_ConcatTransforms` | review-required | `miniquake/mathlib.ml:R_ConcatTransforms`, `miniquake/mathlib.ml:concatTransforms` |
| function | `FloorDivMod` | review-required | `miniquake/mathlib.ml:floorDivMod`, `miniquake/mathlib.ml:FloorDivMod` |
| function | `GreatestCommonDivisor` | review-required | `miniquake/mathlib.ml:greatestCommonDivisor`, `miniquake/mathlib.ml:GreatestCommonDivisor` |
| function | `Invert24To16` | review-required | `miniquake/mathlib.ml:invert24To16`, `miniquake/mathlib.ml:Invert24To16` |
| macro | `DEG2RAD` | review-required |  |
| global | `int nanmask = 255<<23` | review-required |  |
| prototype | `Sys_Error` | review-required |  |
| prototype | `sqrt` | review-required | `miniquake/mathlib.ml:sqrt` |

### `mathlib.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| macro | `M_PI` | review-required |  |
| macro | `IS_NAN` | review-required |  |
| macro | `DotProduct` | review-required |  |
| macro | `VectorSubtract` | review-required |  |
| macro | `VectorAdd` | review-required |  |
| macro | `VectorCopy` | review-required |  |
| macro | `BOX_ON_PLANE_SIDE` | review-required |  |
| global | `extern vec3_t vec3_origin` | review-required |  |
| global | `extern int nanmask` | review-required |  |
| prototype | `VectorMA` | review-required |  |
| prototype | `_DotProduct` | review-required |  |
| prototype | `_VectorSubtract` | review-required |  |
| prototype | `_VectorAdd` | review-required |  |
| prototype | `_VectorCopy` | review-required |  |
| prototype | `VectorCompare` | review-required |  |
| prototype | `Length` | review-required |  |
| prototype | `CrossProduct` | review-required |  |
| prototype | `VectorNormalize` | review-required |  |
| prototype | `VectorInverse` | review-required |  |
| prototype | `VectorScale` | review-required |  |
| prototype | `Q_log2` | review-required |  |
| prototype | `R_ConcatRotations` | review-required |  |
| prototype | `R_ConcatTransforms` | review-required |  |
| prototype | `FloorDivMod` | review-required |  |
| prototype | `Invert24To16` | review-required |  |
| prototype | `GreatestCommonDivisor` | review-required |  |
| prototype | `AngleVectors` | review-required |  |
| prototype | `BoxOnPlaneSide` | review-required |  |
| prototype | `anglemod` | review-required |  |

### `menu.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `M_DrawCharacter` | review-required | `miniquake/menu.ml:M_DrawCharacter` |
| function | `M_Print` | review-required | `miniquake/menu.ml:M_Print` |
| function | `M_PrintWhite` | review-required | `miniquake/menu.ml:M_PrintWhite` |
| function | `M_DrawTransPic` | review-required | `miniquake/menu.ml:M_DrawTransPic` |
| function | `M_DrawPic` | review-required | `miniquake/menu.ml:M_DrawPic` |
| function | `M_BuildTranslationTable` | review-required | `miniquake/menu.ml:M_BuildTranslationTable` |
| function | `M_DrawTransPicTranslate` | review-required | `miniquake/menu.ml:M_DrawTransPicTranslate` |
| function | `M_DrawTextBox` | review-required | `miniquake/menu.ml:M_DrawTextBox`, `miniquake/menu.ml:drawTextBox` |
| function | `M_ToggleMenu_f` | review-required | `miniquake/menu.ml:M_ToggleMenu_f` |
| function | `M_Menu_Main_f` | review-required | `miniquake/menu.ml:M_Menu_Main_f` |
| function | `M_Main_Draw` | review-required | `miniquake/menu.ml:M_Main_Draw` |
| function | `M_Main_Key` | review-required | `miniquake/menu.ml:M_Main_Key` |
| function | `M_Menu_SinglePlayer_f` | review-required | `miniquake/menu.ml:M_Menu_SinglePlayer_f` |
| function | `M_SinglePlayer_Draw` | review-required | `miniquake/menu.ml:M_SinglePlayer_Draw` |
| function | `M_SinglePlayer_Key` | review-required | `miniquake/menu.ml:M_SinglePlayer_Key` |
| function | `M_ScanSaves` | review-required | `miniquake/menu.ml:M_ScanSaves`, `miniquake/menu.ml:scanSaves` |
| function | `M_Menu_Load_f` | review-required | `miniquake/menu.ml:M_Menu_Load_f` |
| function | `M_Menu_Save_f` | review-required | `miniquake/menu.ml:M_Menu_Save_f` |
| function | `M_Load_Draw` | review-required | `miniquake/menu.ml:M_Load_Draw` |
| function | `M_Save_Draw` | review-required | `miniquake/menu.ml:M_Save_Draw` |
| function | `M_Load_Key` | review-required | `miniquake/menu.ml:M_Load_Key` |
| function | `M_Save_Key` | review-required | `miniquake/menu.ml:M_Save_Key` |
| function | `M_Menu_MultiPlayer_f` | review-required | `miniquake/menu.ml:M_Menu_MultiPlayer_f` |
| function | `M_MultiPlayer_Draw` | review-required | `miniquake/menu.ml:M_MultiPlayer_Draw` |
| function | `M_MultiPlayer_Key` | review-required | `miniquake/menu.ml:M_MultiPlayer_Key` |
| function | `M_Menu_Setup_f` | review-required | `miniquake/menu.ml:M_Menu_Setup_f` |
| function | `M_Setup_Draw` | review-required | `miniquake/menu.ml:M_Setup_Draw` |
| function | `M_Setup_Key` | review-required | `miniquake/menu.ml:M_Setup_Key` |
| function | `M_Menu_Net_f` | review-required | `miniquake/menu.ml:M_Menu_Net_f` |
| function | `M_Net_Draw` | review-required | `miniquake/menu.ml:M_Net_Draw`, `miniquake/menu.ml:M_Draw`, `miniquake/menu.ml:M_Keys_Draw` |
| function | `M_Net_Key` | review-required | `miniquake/menu.ml:M_Net_Key`, `miniquake/menu.ml:M_Keys_Key` |
| function | `M_Menu_Options_f` | review-required | `miniquake/menu.ml:M_Menu_Options_f` |
| function | `M_AdjustSliders` | review-required | `miniquake/menu.ml:M_AdjustSliders` |
| function | `M_DrawSlider` | review-required | `miniquake/menu.ml:M_DrawSlider`, `miniquake/menu.ml:drawSlider` |
| function | `M_DrawCheckbox` | review-required | `miniquake/menu.ml:M_DrawCheckbox`, `miniquake/menu.ml:drawCheckbox` |
| function | `M_Options_Draw` | review-required | `miniquake/menu.ml:M_Options_Draw` |
| function | `M_Options_Key` | review-required | `miniquake/menu.ml:M_Options_Key` |
| function | `M_Menu_Keys_f` | review-required | `miniquake/menu.ml:M_Menu_Keys_f` |
| function | `M_FindKeysForCommand` | review-required | `miniquake/menu.ml:M_FindKeysForCommand` |
| function | `M_UnbindCommand` | review-required | `miniquake/menu.ml:M_UnbindCommand` |
| function | `M_Keys_Draw` | review-required | `miniquake/menu.ml:M_Keys_Draw`, `miniquake/menu.ml:M_Draw`, `miniquake/menu.ml:M_Net_Draw` |
| function | `M_Keys_Key` | review-required | `miniquake/menu.ml:M_Keys_Key`, `miniquake/menu.ml:M_Net_Key` |
| function | `M_Menu_Video_f` | review-required | `miniquake/menu.ml:M_Menu_Video_f` |
| function | `M_Video_Draw` | review-required | `miniquake/menu.ml:M_Video_Draw` |
| function | `M_Video_Key` | review-required | `miniquake/menu.ml:M_Video_Key` |
| function | `M_Menu_Help_f` | review-required | `miniquake/menu.ml:M_Menu_Help_f` |
| function | `M_Help_Draw` | review-required | `miniquake/menu.ml:M_Help_Draw` |
| function | `M_Help_Key` | review-required | `miniquake/menu.ml:M_Help_Key` |
| function | `M_Menu_Quit_f` | review-required | `miniquake/menu.ml:M_Menu_Quit_f` |
| function | `M_Quit_Key` | review-required | `miniquake/menu.ml:M_Quit_Key` |
| function | `M_Quit_Draw` | review-required | `miniquake/menu.ml:M_Quit_Draw` |
| function | `M_Menu_SerialConfig_f` | review-required | `miniquake/menu.ml:M_Menu_SerialConfig_f` |
| function | `M_SerialConfig_Draw` | review-required | `miniquake/menu.ml:M_SerialConfig_Draw` |
| function | `M_SerialConfig_Key` | review-required | `miniquake/menu.ml:M_SerialConfig_Key` |
| function | `M_Menu_ModemConfig_f` | review-required | `miniquake/menu.ml:M_Menu_ModemConfig_f` |
| function | `M_ModemConfig_Draw` | review-required | `miniquake/menu.ml:M_ModemConfig_Draw` |
| function | `M_ModemConfig_Key` | review-required | `miniquake/menu.ml:M_ModemConfig_Key` |
| function | `M_Menu_LanConfig_f` | review-required | `miniquake/menu.ml:M_Menu_LanConfig_f` |
| function | `M_LanConfig_Draw` | review-required | `miniquake/menu.ml:M_LanConfig_Draw` |
| function | `M_LanConfig_Key` | review-required | `miniquake/menu.ml:M_LanConfig_Key` |
| function | `M_Menu_GameOptions_f` | review-required | `miniquake/menu.ml:M_Menu_GameOptions_f` |
| function | `M_GameOptions_Draw` | review-required | `miniquake/menu.ml:M_GameOptions_Draw` |
| function | `M_NetStart_Change` | review-required | `miniquake/menu.ml:M_NetStart_Change` |
| function | `M_GameOptions_Key` | review-required | `miniquake/menu.ml:M_GameOptions_Key` |
| function | `M_Menu_Search_f` | review-required | `miniquake/menu.ml:M_Menu_Search_f` |
| function | `M_Search_Draw` | review-required | `miniquake/menu.ml:M_Search_Draw` |
| function | `M_Search_Key` | review-required | `miniquake/menu.ml:M_Search_Key` |
| function | `M_Menu_ServerList_f` | review-required | `miniquake/menu.ml:M_Menu_ServerList_f` |
| function | `M_ServerList_Draw` | review-required | `miniquake/menu.ml:M_ServerList_Draw` |
| function | `M_ServerList_Key` | review-required | `miniquake/menu.ml:M_ServerList_Key` |
| function | `M_Init` | review-required | `miniquake/menu.ml:M_Init`, `miniquake/host.ml:Host_Init` |
| function | `M_Draw` | review-required | `miniquake/menu.ml:M_Draw`, `miniquake/menu.ml:M_Net_Draw`, `miniquake/menu.ml:M_Keys_Draw` |
| function | `M_Keydown` | review-required | `miniquake/menu.ml:M_Keydown` |
| function | `M_ConfigureNetSubsystem` | review-required | `miniquake/menu.ml:M_ConfigureNetSubsystem` |
| type | `level_t` | review-required |  |
| field | `level_t.char *name` | review-required |  |
| field | `level_t.char *description` | review-required |  |
| type | `episode_t` | review-required |  |
| field | `episode_t.char *description` | review-required |  |
| field | `episode_t.int firstLevel` | review-required |  |
| field | `episode_t.int levels` | review-required |  |
| macro | `StartingGame` | review-required |  |
| macro | `JoiningGame` | review-required |  |
| macro | `SerialConfig` | review-required |  |
| macro | `DirectConfig` | review-required |  |
| macro | `IPXConfig` | review-required |  |
| macro | `TCPIPConfig` | review-required |  |
| macro | `MAIN_ITEMS` | review-required |  |
| macro | `SINGLEPLAYER_ITEMS` | review-required |  |
| macro | `MAX_SAVEGAMES` | review-required |  |
| macro | `MULTIPLAYER_ITEMS` | review-required |  |
| macro | `NUM_SETUP_CMDS` | review-required |  |
| macro | `OPTIONS_ITEMS` | review-required |  |
| macro | `OPTIONS_ITEMS` | review-required |  |
| macro | `SLIDER_RANGE` | review-required |  |
| macro | `NUMCOMMANDS` | review-required |  |
| macro | `NUM_HELP_PAGES` | review-required |  |
| macro | `NUM_SERIALCONFIG_CMDS` | review-required |  |
| macro | `NUM_MODEMCONFIG_CMDS` | review-required |  |
| macro | `NUM_LANCONFIG_CMDS` | review-required |  |
| macro | `NUM_GAMEOPTIONS` | review-required |  |
| global | `m_state` | review-required |  |
| global | `qboolean m_entersound` | review-required |  |
| global | `// play after drawing a frame, so caching // won't disrupt the sound qboolean m_recursiveDraw` | review-required |  |
| global | `int m_return_state` | review-required |  |
| global | `qboolean m_return_onerror` | review-required |  |
| global | `char m_return_reason [32]` | review-required |  |
| global | `byte identityTable[256]` | review-required |  |
| global | `byte translationTable[256]` | review-required |  |
| global | `//============================================================================= int m_save_demonum` | review-required |  |
| global | `//============================================================================= /* MAIN MENU */ int m_main_cursor` | review-required |  |
| global | `//============================================================================= /* SINGLE PLAYER MENU */ int m_singleplayer_cursor` | review-required |  |
| global | `//============================================================================= /* LOAD/SAVE MENU */ int load_cursor` | review-required |  |
| global | `// 0 < load_cursor < MAX_SAVEGAMES #define MAX_SAVEGAMES 12 char m_filenames[MAX_SAVEGAMES][SAVEGAME_COMMENT_LENGTH+1]` | review-required |  |
| global | `int loadable[MAX_SAVEGAMES]` | review-required |  |
| global | `//============================================================================= /* MULTIPLAYER MENU */ int m_multiplayer_cursor` | review-required |  |
| global | `//============================================================================= /* SETUP MENU */ int setup_cursor = 4` | review-required |  |
| global | `char setup_hostname[16]` | review-required |  |
| global | `char setup_myname[16]` | review-required |  |
| global | `int setup_oldtop` | review-required |  |
| global | `int setup_oldbottom` | review-required |  |
| global | `int setup_top` | review-required |  |
| global | `int setup_bottom` | review-required |  |
| global | `//============================================================================= /* NET MENU */ int m_net_cursor` | review-required |  |
| global | `int m_net_items` | review-required |  |
| global | `int m_net_saveHeight` | review-required |  |
| global | `//============================================================================= /* OPTIONS MENU */ #ifdef _WIN32 #define OPTIONS_ITEMS 14 #else #define OPTIONS_ITEMS 13 #endif #define SLIDER_RANGE 10 int options_cursor` | review-required |  |
| global | `int bind_grab` | review-required |  |
| global | `//============================================================================= /* HELP MENU */ int help_page` | review-required |  |
| global | `//============================================================================= /* QUIT MENU */ int msgNumber` | review-required |  |
| global | `int m_quit_prevstate` | review-required |  |
| global | `qboolean wasInMenus` | review-required |  |
| global | `//============================================================================= /* SERIAL CONFIG MENU */ int serialConfig_cursor` | review-required |  |
| global | `int serialConfig_comport` | review-required |  |
| global | `int serialConfig_irq` | review-required |  |
| global | `int serialConfig_baud` | review-required |  |
| global | `char serialConfig_phone[16]` | review-required |  |
| global | `//============================================================================= /* MODEM CONFIG MENU */ int modemConfig_cursor` | review-required |  |
| global | `char modemConfig_clear [16]` | review-required |  |
| global | `char modemConfig_init [32]` | review-required |  |
| global | `char modemConfig_hangup [16]` | review-required |  |
| global | `//============================================================================= /* LAN CONFIG MENU */ int lanConfig_cursor = -1` | review-required |  |
| global | `char lanConfig_portname[6]` | review-required |  |
| global | `char lanConfig_joinname[22]` | review-required |  |
| global | `level_t` | review-required |  |
| global | `episode_t` | review-required |  |
| global | `int startepisode` | review-required |  |
| global | `int startlevel` | review-required |  |
| global | `int maxplayers` | review-required |  |
| global | `qboolean m_serverInfoMessage = false` | review-required |  |
| global | `double m_serverInfoMessageTime` | review-required |  |
| global | `//============================================================================= /* SEARCH MENU */ qboolean searchComplete = false` | review-required |  |
| global | `double searchCompleteTime` | review-required |  |
| global | `//============================================================================= /* SLIST MENU */ int slist_cursor` | review-required |  |
| global | `qboolean slist_sorted` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `M_Menu_Main_f` | review-required | `miniquake/menu.ml:M_Menu_Main_f` |
| prototype | `M_Menu_SinglePlayer_f` | review-required | `miniquake/menu.ml:M_Menu_SinglePlayer_f` |
| prototype | `M_Menu_Load_f` | review-required | `miniquake/menu.ml:M_Menu_Load_f` |
| prototype | `M_Menu_Save_f` | review-required | `miniquake/menu.ml:M_Menu_Save_f` |
| prototype | `M_Menu_MultiPlayer_f` | review-required | `miniquake/menu.ml:M_Menu_MultiPlayer_f` |
| prototype | `M_Menu_Setup_f` | review-required | `miniquake/menu.ml:M_Menu_Setup_f` |
| prototype | `M_Menu_Net_f` | review-required | `miniquake/menu.ml:M_Menu_Net_f` |
| prototype | `M_Menu_Options_f` | review-required | `miniquake/menu.ml:M_Menu_Options_f` |
| prototype | `M_Menu_Keys_f` | review-required | `miniquake/menu.ml:M_Menu_Keys_f` |
| prototype | `M_Menu_Video_f` | review-required | `miniquake/menu.ml:M_Menu_Video_f` |
| prototype | `M_Menu_Help_f` | review-required | `miniquake/menu.ml:M_Menu_Help_f` |
| prototype | `M_Menu_Quit_f` | review-required | `miniquake/menu.ml:M_Menu_Quit_f` |
| prototype | `M_Menu_SerialConfig_f` | review-required | `miniquake/menu.ml:M_Menu_SerialConfig_f` |
| prototype | `M_Menu_ModemConfig_f` | review-required | `miniquake/menu.ml:M_Menu_ModemConfig_f` |
| prototype | `M_Menu_LanConfig_f` | review-required | `miniquake/menu.ml:M_Menu_LanConfig_f` |
| prototype | `M_Menu_GameOptions_f` | review-required | `miniquake/menu.ml:M_Menu_GameOptions_f` |
| prototype | `M_Menu_Search_f` | review-required | `miniquake/menu.ml:M_Menu_Search_f` |
| prototype | `M_Menu_ServerList_f` | review-required | `miniquake/menu.ml:M_Menu_ServerList_f` |
| prototype | `M_Main_Draw` | review-required | `miniquake/menu.ml:M_Main_Draw` |
| prototype | `M_SinglePlayer_Draw` | review-required | `miniquake/menu.ml:M_SinglePlayer_Draw` |
| prototype | `M_Load_Draw` | review-required | `miniquake/menu.ml:M_Load_Draw` |
| prototype | `M_Save_Draw` | review-required | `miniquake/menu.ml:M_Save_Draw` |
| prototype | `M_MultiPlayer_Draw` | review-required | `miniquake/menu.ml:M_MultiPlayer_Draw` |
| prototype | `M_Setup_Draw` | review-required | `miniquake/menu.ml:M_Setup_Draw` |
| prototype | `M_Net_Draw` | review-required | `miniquake/menu.ml:M_Net_Draw`, `miniquake/menu.ml:M_Draw`, `miniquake/menu.ml:M_Keys_Draw` |
| prototype | `M_Options_Draw` | review-required | `miniquake/menu.ml:M_Options_Draw` |
| prototype | `M_Keys_Draw` | review-required | `miniquake/menu.ml:M_Keys_Draw`, `miniquake/menu.ml:M_Draw`, `miniquake/menu.ml:M_Net_Draw` |
| prototype | `M_Video_Draw` | review-required | `miniquake/menu.ml:M_Video_Draw` |
| prototype | `M_Help_Draw` | review-required | `miniquake/menu.ml:M_Help_Draw` |
| prototype | `M_Quit_Draw` | review-required | `miniquake/menu.ml:M_Quit_Draw` |
| prototype | `M_SerialConfig_Draw` | review-required | `miniquake/menu.ml:M_SerialConfig_Draw` |
| prototype | `M_ModemConfig_Draw` | review-required | `miniquake/menu.ml:M_ModemConfig_Draw` |
| prototype | `M_LanConfig_Draw` | review-required | `miniquake/menu.ml:M_LanConfig_Draw` |
| prototype | `M_GameOptions_Draw` | review-required | `miniquake/menu.ml:M_GameOptions_Draw` |
| prototype | `M_Search_Draw` | review-required | `miniquake/menu.ml:M_Search_Draw` |
| prototype | `M_ServerList_Draw` | review-required | `miniquake/menu.ml:M_ServerList_Draw` |
| prototype | `M_Main_Key` | review-required | `miniquake/menu.ml:M_Main_Key` |
| prototype | `M_SinglePlayer_Key` | review-required | `miniquake/menu.ml:M_SinglePlayer_Key` |
| prototype | `M_Load_Key` | review-required | `miniquake/menu.ml:M_Load_Key` |
| prototype | `M_Save_Key` | review-required | `miniquake/menu.ml:M_Save_Key` |
| prototype | `M_MultiPlayer_Key` | review-required | `miniquake/menu.ml:M_MultiPlayer_Key` |
| prototype | `M_Setup_Key` | review-required | `miniquake/menu.ml:M_Setup_Key` |
| prototype | `M_Net_Key` | review-required | `miniquake/menu.ml:M_Net_Key`, `miniquake/menu.ml:M_Keys_Key` |
| prototype | `M_Options_Key` | review-required | `miniquake/menu.ml:M_Options_Key` |
| prototype | `M_Keys_Key` | review-required | `miniquake/menu.ml:M_Keys_Key`, `miniquake/menu.ml:M_Net_Key` |
| prototype | `M_Video_Key` | review-required | `miniquake/menu.ml:M_Video_Key` |
| prototype | `M_Help_Key` | review-required | `miniquake/menu.ml:M_Help_Key` |
| prototype | `M_Quit_Key` | review-required | `miniquake/menu.ml:M_Quit_Key` |
| prototype | `M_SerialConfig_Key` | review-required | `miniquake/menu.ml:M_SerialConfig_Key` |
| prototype | `M_ModemConfig_Key` | review-required | `miniquake/menu.ml:M_ModemConfig_Key` |
| prototype | `M_LanConfig_Key` | review-required | `miniquake/menu.ml:M_LanConfig_Key` |
| prototype | `M_GameOptions_Key` | review-required | `miniquake/menu.ml:M_GameOptions_Key` |
| prototype | `M_Search_Key` | review-required | `miniquake/menu.ml:M_Search_Key` |
| prototype | `M_ServerList_Key` | review-required | `miniquake/menu.ml:M_ServerList_Key` |

### `menu.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| macro | `MNET_IPX` | review-required |  |
| macro | `MNET_TCP` | review-required |  |
| prototype | `M_Init` | review-required |  |
| prototype | `M_Keydown` | review-required |  |
| prototype | `M_Draw` | review-required |  |
| prototype | `M_ToggleMenu_f` | review-required |  |

### `model.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `mvertex_t` | review-required |  |
| field | `mvertex_t.vec3_t position` | review-required |  |
| type | `mplane_t` | review-required |  |
| field | `mplane_t.vec3_t normal` | review-required |  |
| field | `mplane_t.float dist` | review-required |  |
| field | `mplane_t.byte type` | review-required |  |
| field | `mplane_t.// for texture axis selection and fast side tests byte signbits` | review-required |  |
| field | `mplane_t.// signx + signy<<1 + signz<<1 byte pad[2]` | review-required |  |
| type | `texture_t` | review-required |  |
| field | `texture_t.char name[16]` | review-required |  |
| field | `texture_t.unsigned width, height` | review-required |  |
| field | `texture_t.int anim_total` | review-required |  |
| field | `texture_t.// total tenths in sequence ( 0 = no) int anim_min, anim_max` | review-required |  |
| field | `texture_t.// time for this frame min <=time< max struct texture_s *anim_next` | review-required |  |
| field | `texture_t.// in the animation sequence struct texture_s *alternate_anims` | review-required |  |
| field | `texture_t.// bmodels in frmae 1 use these unsigned offsets[MIPLEVELS]` | review-required |  |
| type | `medge_t` | review-required |  |
| field | `medge_t.unsigned short v[2]` | review-required |  |
| field | `medge_t.unsigned int cachededgeoffset` | review-required |  |
| type | `mtexinfo_t` | review-required |  |
| field | `mtexinfo_t.float vecs[2][4]` | review-required |  |
| field | `mtexinfo_t.float mipadjust` | review-required |  |
| field | `mtexinfo_t.texture_t *texture` | review-required |  |
| field | `mtexinfo_t.int flags` | review-required |  |
| type | `msurface_t` | review-required |  |
| field | `msurface_t.int visframe` | review-required |  |
| field | `msurface_t.// should be drawn when node is crossed int dlightframe` | review-required |  |
| field | `msurface_t.int dlightbits` | review-required |  |
| field | `msurface_t.mplane_t *plane` | review-required |  |
| field | `msurface_t.int flags` | review-required |  |
| field | `msurface_t.int firstedge` | review-required |  |
| field | `msurface_t.// look up in model->surfedges[], negative numbers int numedges` | review-required |  |
| field | `msurface_t.// are backwards edges // surface generation data struct surfcache_s *cachespots[MIPLEVELS]` | review-required |  |
| field | `msurface_t.short texturemins[2]` | review-required |  |
| field | `msurface_t.short extents[2]` | review-required |  |
| field | `msurface_t.mtexinfo_t *texinfo` | review-required |  |
| field | `msurface_t.// lighting info byte styles[MAXLIGHTMAPS]` | review-required |  |
| field | `msurface_t.byte *samples` | review-required |  |
| type | `mnode_t` | review-required |  |
| field | `mnode_t.// common with leaf int contents` | review-required |  |
| field | `mnode_t.// 0, to differentiate from leafs int visframe` | review-required |  |
| field | `mnode_t.// node needs to be traversed if current short minmaxs[6]` | review-required |  |
| field | `mnode_t.// for bounding box culling struct mnode_s *parent` | review-required |  |
| field | `mnode_t.// node specific mplane_t *plane` | review-required |  |
| field | `mnode_t.struct mnode_s *children[2]` | review-required |  |
| field | `mnode_t.unsigned short firstsurface` | review-required |  |
| field | `mnode_t.unsigned short numsurfaces` | review-required |  |
| type | `mleaf_t` | review-required |  |
| field | `mleaf_t.// common with node int contents` | review-required |  |
| field | `mleaf_t.// wil be a negative contents number int visframe` | review-required |  |
| field | `mleaf_t.// node needs to be traversed if current short minmaxs[6]` | review-required |  |
| field | `mleaf_t.// for bounding box culling struct mnode_s *parent` | review-required |  |
| field | `mleaf_t.// leaf specific byte *compressed_vis` | review-required |  |
| field | `mleaf_t.efrag_t *efrags` | review-required |  |
| field | `mleaf_t.msurface_t **firstmarksurface` | review-required |  |
| field | `mleaf_t.int nummarksurfaces` | review-required |  |
| field | `mleaf_t.int key` | review-required |  |
| field | `mleaf_t.// BSP sequence number for leaf's contents byte ambient_sound_level[NUM_AMBIENTS]` | review-required |  |
| type | `hull_t` | review-required |  |
| field | `hull_t.dclipnode_t *clipnodes` | review-required |  |
| field | `hull_t.mplane_t *planes` | review-required |  |
| field | `hull_t.int firstclipnode` | review-required |  |
| field | `hull_t.int lastclipnode` | review-required |  |
| field | `hull_t.vec3_t clip_mins` | review-required |  |
| field | `hull_t.vec3_t clip_maxs` | review-required |  |
| type | `mspriteframe_t` | review-required |  |
| field | `mspriteframe_t.int width` | review-required |  |
| field | `mspriteframe_t.int height` | review-required |  |
| field | `mspriteframe_t.void *pcachespot` | review-required |  |
| field | `mspriteframe_t.// remove? float up, down, left, right` | review-required |  |
| field | `mspriteframe_t.byte pixels[4]` | review-required |  |
| type | `mspritegroup_t` | review-required |  |
| field | `mspritegroup_t.int numframes` | review-required |  |
| field | `mspritegroup_t.float *intervals` | review-required |  |
| field | `mspritegroup_t.mspriteframe_t *frames[1]` | review-required |  |
| type | `mspriteframedesc_t` | review-required |  |
| field | `mspriteframedesc_t.spriteframetype_t type` | review-required |  |
| field | `mspriteframedesc_t.mspriteframe_t *frameptr` | review-required |  |
| type | `msprite_t` | review-required |  |
| field | `msprite_t.int type` | review-required |  |
| field | `msprite_t.int maxwidth` | review-required |  |
| field | `msprite_t.int maxheight` | review-required |  |
| field | `msprite_t.int numframes` | review-required |  |
| field | `msprite_t.float beamlength` | review-required |  |
| field | `msprite_t.// remove? void *cachespot` | review-required |  |
| field | `msprite_t.// remove? mspriteframedesc_t frames[1]` | review-required |  |
| type | `maliasframedesc_t` | review-required |  |
| field | `maliasframedesc_t.aliasframetype_t type` | review-required |  |
| field | `maliasframedesc_t.trivertx_t bboxmin` | review-required |  |
| field | `maliasframedesc_t.trivertx_t bboxmax` | review-required |  |
| field | `maliasframedesc_t.int frame` | review-required |  |
| field | `maliasframedesc_t.char name[16]` | review-required |  |
| type | `maliasskindesc_t` | review-required |  |
| field | `maliasskindesc_t.aliasskintype_t type` | review-required |  |
| field | `maliasskindesc_t.void *pcachespot` | review-required |  |
| field | `maliasskindesc_t.int skin` | review-required |  |
| type | `maliasgroupframedesc_t` | review-required |  |
| field | `maliasgroupframedesc_t.trivertx_t bboxmin` | review-required |  |
| field | `maliasgroupframedesc_t.trivertx_t bboxmax` | review-required |  |
| field | `maliasgroupframedesc_t.int frame` | review-required |  |
| type | `maliasgroup_t` | review-required |  |
| field | `maliasgroup_t.int numframes` | review-required |  |
| field | `maliasgroup_t.int intervals` | review-required |  |
| field | `maliasgroup_t.maliasgroupframedesc_t frames[1]` | review-required |  |
| type | `maliasskingroup_t` | review-required |  |
| field | `maliasskingroup_t.int numskins` | review-required |  |
| field | `maliasskingroup_t.int intervals` | review-required |  |
| field | `maliasskingroup_t.maliasskindesc_t skindescs[1]` | review-required |  |
| type | `mtriangle_t` | review-required |  |
| field | `mtriangle_t.int facesfront` | review-required |  |
| field | `mtriangle_t.int vertindex[3]` | review-required |  |
| type | `aliashdr_t` | review-required |  |
| field | `aliashdr_t.int model` | review-required |  |
| field | `aliashdr_t.int stverts` | review-required |  |
| field | `aliashdr_t.int skindesc` | review-required |  |
| field | `aliashdr_t.int triangles` | review-required |  |
| field | `aliashdr_t.maliasframedesc_t frames[1]` | review-required |  |
| type | `modtype_t` | review-required |  |
| enum-value | `modtype_t.mod_brush` | review-required |  |
| enum-value | `modtype_t.mod_sprite` | review-required |  |
| enum-value | `modtype_t.mod_alias` | review-required |  |
| type | `model_t` | review-required |  |
| field | `model_t.char name[MAX_QPATH]` | review-required |  |
| field | `model_t.qboolean needload` | review-required |  |
| field | `model_t.// bmodels and sprites don't cache normally modtype_t type` | review-required |  |
| field | `model_t.int numframes` | review-required |  |
| field | `model_t.synctype_t synctype` | review-required |  |
| field | `model_t.int flags` | review-required |  |
| field | `model_t.// // volume occupied by the model // vec3_t mins, maxs` | review-required |  |
| field | `model_t.float radius` | review-required |  |
| field | `model_t.// // brush model // int firstmodelsurface, nummodelsurfaces` | review-required |  |
| field | `model_t.int numsubmodels` | review-required |  |
| field | `model_t.dmodel_t *submodels` | review-required |  |
| field | `model_t.int numplanes` | review-required |  |
| field | `model_t.mplane_t *planes` | review-required |  |
| field | `model_t.int numleafs` | review-required |  |
| field | `model_t.// number of visible leafs, not counting 0 mleaf_t *leafs` | review-required |  |
| field | `model_t.int numvertexes` | review-required |  |
| field | `model_t.mvertex_t *vertexes` | review-required |  |
| field | `model_t.int numedges` | review-required |  |
| field | `model_t.medge_t *edges` | review-required |  |
| field | `model_t.int numnodes` | review-required |  |
| field | `model_t.mnode_t *nodes` | review-required |  |
| field | `model_t.int numtexinfo` | review-required |  |
| field | `model_t.mtexinfo_t *texinfo` | review-required |  |
| field | `model_t.int numsurfaces` | review-required |  |
| field | `model_t.msurface_t *surfaces` | review-required |  |
| field | `model_t.int numsurfedges` | review-required |  |
| field | `model_t.int *surfedges` | review-required |  |
| field | `model_t.int numclipnodes` | review-required |  |
| field | `model_t.dclipnode_t *clipnodes` | review-required |  |
| field | `model_t.int nummarksurfaces` | review-required |  |
| field | `model_t.msurface_t **marksurfaces` | review-required |  |
| field | `model_t.hull_t hulls[MAX_MAP_HULLS]` | review-required |  |
| field | `model_t.int numtextures` | review-required |  |
| field | `model_t.texture_t **textures` | review-required |  |
| field | `model_t.byte *visdata` | review-required |  |
| field | `model_t.byte *lightdata` | review-required |  |
| field | `model_t.char *entities` | review-required |  |
| field | `model_t.// // additional model data // cache_user_t cache` | review-required |  |
| macro | `__MODEL__` | review-required |  |
| macro | `SIDE_FRONT` | review-required |  |
| macro | `SIDE_BACK` | review-required |  |
| macro | `SIDE_ON` | review-required |  |
| macro | `SURF_PLANEBACK` | review-required |  |
| macro | `SURF_DRAWSKY` | review-required |  |
| macro | `SURF_DRAWSPRITE` | review-required |  |
| macro | `SURF_DRAWTURB` | review-required |  |
| macro | `SURF_DRAWTILED` | review-required |  |
| macro | `SURF_DRAWBACKGROUND` | review-required |  |
| macro | `EF_ROCKET` | review-required |  |
| macro | `EF_GRENADE` | review-required |  |
| macro | `EF_GIB` | review-required |  |
| macro | `EF_ROTATE` | review-required |  |
| macro | `EF_TRACER` | review-required |  |
| macro | `EF_ZOMGIB` | review-required |  |
| macro | `EF_TRACER2` | review-required |  |
| macro | `EF_TRACER3` | review-required |  |
| global | `mvertex_t` | review-required |  |
| global | `mplane_t` | review-required |  |
| global | `texture_t` | review-required |  |
| global | `medge_t` | review-required |  |
| global | `mtexinfo_t` | review-required |  |
| global | `msurface_t` | review-required |  |
| global | `mnode_t` | review-required |  |
| global | `mleaf_t` | review-required |  |
| global | `hull_t` | review-required |  |
| global | `mspriteframe_t` | review-required |  |
| global | `mspritegroup_t` | review-required |  |
| global | `mspriteframedesc_t` | review-required |  |
| global | `msprite_t` | review-required |  |
| global | `maliasframedesc_t` | review-required |  |
| global | `maliasskindesc_t` | review-required |  |
| global | `maliasgroupframedesc_t` | review-required |  |
| global | `maliasgroup_t` | review-required |  |
| global | `maliasskingroup_t` | review-required |  |
| global | `mtriangle_t` | review-required |  |
| global | `aliashdr_t` | review-required |  |
| global | `modtype_t` | review-required |  |
| global | `model_t` | review-required |  |
| prototype | `Mod_Init` | review-required |  |
| prototype | `Mod_ClearAll` | review-required |  |
| prototype | `Mod_ForName` | review-required |  |
| prototype | `Mod_Extradata` | review-required |  |
| prototype | `Mod_TouchModel` | review-required |  |
| prototype | `Mod_PointInLeaf` | review-required |  |
| prototype | `Mod_LeafPVS` | review-required |  |

### `modelgen.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `synctype_t` | review-required |  |
| enum-value | `synctype_t.ST_SYNC=0` | review-required |  |
| enum-value | `synctype_t.ST_RAND` | review-required |  |
| type | `aliasframetype_t` | review-required |  |
| enum-value | `aliasframetype_t.ALIAS_SINGLE=0` | review-required |  |
| enum-value | `aliasframetype_t.ALIAS_GROUP` | review-required |  |
| type | `aliasskintype_t` | review-required |  |
| enum-value | `aliasskintype_t.ALIAS_SKIN_SINGLE=0` | review-required |  |
| enum-value | `aliasskintype_t.ALIAS_SKIN_GROUP` | review-required |  |
| type | `mdl_t` | review-required |  |
| field | `mdl_t.int ident` | review-required |  |
| field | `mdl_t.int version` | review-required |  |
| field | `mdl_t.vec3_t scale` | review-required |  |
| field | `mdl_t.vec3_t scale_origin` | review-required |  |
| field | `mdl_t.float boundingradius` | review-required |  |
| field | `mdl_t.vec3_t eyeposition` | review-required |  |
| field | `mdl_t.int numskins` | review-required |  |
| field | `mdl_t.int skinwidth` | review-required |  |
| field | `mdl_t.int skinheight` | review-required |  |
| field | `mdl_t.int numverts` | review-required |  |
| field | `mdl_t.int numtris` | review-required |  |
| field | `mdl_t.int numframes` | review-required |  |
| field | `mdl_t.synctype_t synctype` | review-required |  |
| field | `mdl_t.int flags` | review-required |  |
| field | `mdl_t.float size` | review-required |  |
| type | `stvert_t` | review-required |  |
| field | `stvert_t.int onseam` | review-required |  |
| field | `stvert_t.int s` | review-required |  |
| field | `stvert_t.int t` | review-required |  |
| type | `dtriangle_t` | review-required |  |
| field | `dtriangle_t.int facesfront` | review-required |  |
| field | `dtriangle_t.int vertindex[3]` | review-required |  |
| type | `trivertx_t` | review-required |  |
| field | `trivertx_t.byte v[3]` | review-required |  |
| field | `trivertx_t.byte lightnormalindex` | review-required |  |
| type | `daliasframe_t` | review-required |  |
| field | `daliasframe_t.trivertx_t bboxmin` | review-required |  |
| field | `daliasframe_t.// lightnormal isn't used trivertx_t bboxmax` | review-required |  |
| field | `daliasframe_t.// lightnormal isn't used char name[16]` | review-required |  |
| type | `daliasgroup_t` | review-required |  |
| field | `daliasgroup_t.int numframes` | review-required |  |
| field | `daliasgroup_t.trivertx_t bboxmin` | review-required |  |
| field | `daliasgroup_t.// lightnormal isn't used trivertx_t bboxmax` | review-required |  |
| type | `daliasskingroup_t` | review-required |  |
| field | `daliasskingroup_t.int numskins` | review-required |  |
| type | `daliasinterval_t` | review-required |  |
| field | `daliasinterval_t.float interval` | review-required |  |
| type | `daliasskininterval_t` | review-required |  |
| field | `daliasskininterval_t.float interval` | review-required |  |
| type | `daliasframetype_t` | review-required |  |
| field | `daliasframetype_t.aliasframetype_t type` | review-required |  |
| type | `daliasskintype_t` | review-required |  |
| field | `daliasskintype_t.aliasskintype_t type` | review-required |  |
| macro | `ALIAS_VERSION` | review-required |  |
| macro | `ALIAS_ONSEAM` | review-required |  |
| macro | `SYNCTYPE_T` | review-required |  |
| macro | `DT_FACES_FRONT` | review-required |  |
| macro | `IDPOLYHEADER` | review-required |  |
| global | `synctype_t` | review-required |  |
| global | `aliasframetype_t` | review-required |  |
| global | `aliasskintype_t` | review-required |  |
| global | `mdl_t` | review-required |  |
| global | `stvert_t` | review-required |  |
| global | `dtriangle_t` | review-required |  |
| global | `trivertx_t` | review-required |  |
| global | `daliasframe_t` | review-required |  |
| global | `daliasgroup_t` | review-required |  |
| global | `daliasskingroup_t` | review-required |  |
| global | `daliasinterval_t` | review-required |  |
| global | `daliasskininterval_t` | review-required |  |
| global | `daliasframetype_t` | review-required |  |
| global | `daliasskintype_t` | review-required |  |

### `net.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `qsocket_t` | review-required |  |
| field | `qsocket_t.struct qsocket_s *next` | review-required |  |
| field | `qsocket_t.double connecttime` | review-required |  |
| field | `qsocket_t.double lastMessageTime` | review-required |  |
| field | `qsocket_t.double lastSendTime` | review-required |  |
| field | `qsocket_t.qboolean disconnected` | review-required |  |
| field | `qsocket_t.qboolean canSend` | review-required |  |
| field | `qsocket_t.qboolean sendNext` | review-required |  |
| field | `qsocket_t.int driver` | review-required |  |
| field | `qsocket_t.int landriver` | review-required |  |
| field | `qsocket_t.int socket` | review-required |  |
| field | `qsocket_t.void *driverdata` | review-required |  |
| field | `qsocket_t.unsigned int ackSequence` | review-required |  |
| field | `qsocket_t.unsigned int sendSequence` | review-required |  |
| field | `qsocket_t.unsigned int unreliableSendSequence` | review-required |  |
| field | `qsocket_t.int sendMessageLength` | review-required |  |
| field | `qsocket_t.byte sendMessage [NET_MAXMESSAGE]` | review-required |  |
| field | `qsocket_t.unsigned int receiveSequence` | review-required |  |
| field | `qsocket_t.unsigned int unreliableReceiveSequence` | review-required |  |
| field | `qsocket_t.int receiveMessageLength` | review-required |  |
| field | `qsocket_t.byte receiveMessage [NET_MAXMESSAGE]` | review-required |  |
| field | `qsocket_t.struct qsockaddr addr` | review-required |  |
| field | `qsocket_t.char address[NET_NAMELEN]` | review-required |  |
| type | `net_landriver_t` | review-required |  |
| field | `net_landriver_t.char *name` | review-required |  |
| field | `net_landriver_t.qboolean initialized` | review-required |  |
| field | `net_landriver_t.int controlSock` | review-required |  |
| field | `net_landriver_t.int (*Init) (void)` | review-required |  |
| field | `net_landriver_t.void (*Shutdown) (void)` | review-required |  |
| field | `net_landriver_t.void (*Listen) (qboolean state)` | review-required |  |
| field | `net_landriver_t.int (*OpenSocket) (int port)` | review-required |  |
| field | `net_landriver_t.int (*CloseSocket) (int socket)` | review-required |  |
| field | `net_landriver_t.int (*Connect) (int socket, struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*CheckNewConnections) (void)` | review-required |  |
| field | `net_landriver_t.int (*Read) (int socket, byte *buf, int len, struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*Write) (int socket, byte *buf, int len, struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*Broadcast) (int socket, byte *buf, int len)` | review-required |  |
| field | `net_landriver_t.char * (*AddrToString) (struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*StringToAddr) (char *string, struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*GetSocketAddr) (int socket, struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*GetNameFromAddr) (struct qsockaddr *addr, char *name)` | review-required |  |
| field | `net_landriver_t.int (*GetAddrFromName) (char *name, struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*AddrCompare) (struct qsockaddr *addr1, struct qsockaddr *addr2)` | review-required |  |
| field | `net_landriver_t.int (*GetSocketPort) (struct qsockaddr *addr)` | review-required |  |
| field | `net_landriver_t.int (*SetSocketPort) (struct qsockaddr *addr, int port)` | review-required |  |
| type | `net_driver_t` | review-required |  |
| field | `net_driver_t.char *name` | review-required |  |
| field | `net_driver_t.qboolean initialized` | review-required |  |
| field | `net_driver_t.int (*Init) (void)` | review-required |  |
| field | `net_driver_t.void (*Listen) (qboolean state)` | review-required |  |
| field | `net_driver_t.void (*SearchForHosts) (qboolean xmit)` | review-required |  |
| field | `net_driver_t.qsocket_t *(*Connect) (char *host)` | review-required |  |
| field | `net_driver_t.qsocket_t *(*CheckNewConnections) (void)` | review-required |  |
| field | `net_driver_t.int (*QGetMessage) (qsocket_t *sock)` | review-required |  |
| field | `net_driver_t.int (*QSendMessage) (qsocket_t *sock, sizebuf_t *data)` | review-required |  |
| field | `net_driver_t.int (*SendUnreliableMessage) (qsocket_t *sock, sizebuf_t *data)` | review-required |  |
| field | `net_driver_t.qboolean (*CanSendMessage) (qsocket_t *sock)` | review-required |  |
| field | `net_driver_t.qboolean (*CanSendUnreliableMessage) (qsocket_t *sock)` | review-required |  |
| field | `net_driver_t.void (*Close) (qsocket_t *sock)` | review-required |  |
| field | `net_driver_t.void (*Shutdown) (void)` | review-required |  |
| field | `net_driver_t.int controlSock` | review-required |  |
| type | `hostcache_t` | review-required |  |
| field | `hostcache_t.char name[16]` | review-required |  |
| field | `hostcache_t.char map[16]` | review-required |  |
| field | `hostcache_t.char cname[32]` | review-required |  |
| field | `hostcache_t.int users` | review-required |  |
| field | `hostcache_t.int maxusers` | review-required |  |
| field | `hostcache_t.int driver` | review-required |  |
| field | `hostcache_t.int ldriver` | review-required |  |
| field | `hostcache_t.struct qsockaddr addr` | review-required |  |
| type | `PollProcedure` | review-required |  |
| field | `PollProcedure.struct _PollProcedure *next` | review-required |  |
| field | `PollProcedure.double nextTime` | review-required |  |
| field | `PollProcedure.void (*procedure)()` | review-required |  |
| field | `PollProcedure.void *arg` | review-required |  |
| type | `qsockaddr` | review-required |  |
| field | `qsockaddr.short sa_family` | review-required |  |
| field | `qsockaddr.unsigned char sa_data[14]` | review-required |  |
| macro | `NET_NAMELEN` | review-required |  |
| macro | `NET_MAXMESSAGE` | review-required |  |
| macro | `NET_HEADERSIZE` | review-required |  |
| macro | `NET_DATAGRAMSIZE` | review-required |  |
| macro | `NETFLAG_LENGTH_MASK` | review-required |  |
| macro | `NETFLAG_DATA` | review-required |  |
| macro | `NETFLAG_ACK` | review-required |  |
| macro | `NETFLAG_NAK` | review-required |  |
| macro | `NETFLAG_EOM` | review-required |  |
| macro | `NETFLAG_UNRELIABLE` | review-required |  |
| macro | `NETFLAG_CTL` | review-required |  |
| macro | `NET_PROTOCOL_VERSION` | review-required |  |
| macro | `CCREQ_CONNECT` | review-required |  |
| macro | `CCREQ_SERVER_INFO` | review-required |  |
| macro | `CCREQ_PLAYER_INFO` | review-required |  |
| macro | `CCREQ_RULE_INFO` | review-required |  |
| macro | `CCREP_ACCEPT` | review-required |  |
| macro | `CCREP_REJECT` | review-required |  |
| macro | `CCREP_SERVER_INFO` | review-required |  |
| macro | `CCREP_PLAYER_INFO` | review-required |  |
| macro | `CCREP_RULE_INFO` | review-required |  |
| macro | `MAX_NET_DRIVERS` | review-required |  |
| macro | `HOSTCACHESIZE` | review-required |  |
| global | `qsocket_t` | review-required |  |
| global | `extern qsocket_t *net_activeSockets` | review-required |  |
| global | `extern qsocket_t *net_freeSockets` | review-required |  |
| global | `extern int net_numsockets` | review-required |  |
| global | `net_landriver_t` | review-required |  |
| global | `extern net_landriver_t net_landrivers[MAX_NET_DRIVERS]` | review-required |  |
| global | `net_driver_t` | review-required |  |
| global | `extern int net_numdrivers` | review-required |  |
| global | `extern net_driver_t net_drivers[MAX_NET_DRIVERS]` | review-required |  |
| global | `extern int DEFAULTnet_hostport` | review-required |  |
| global | `extern int net_hostport` | review-required |  |
| global | `extern int net_driverlevel` | review-required |  |
| global | `extern cvar_t hostname` | review-required |  |
| global | `extern char playername[]` | review-required |  |
| global | `extern int playercolor` | review-required |  |
| global | `extern int messagesSent` | review-required |  |
| global | `extern int messagesReceived` | review-required |  |
| global | `extern int unreliableMessagesSent` | review-required |  |
| global | `extern int unreliableMessagesReceived` | review-required |  |
| global | `hostcache_t` | review-required |  |
| global | `extern int hostCacheCount` | review-required |  |
| global | `extern hostcache_t hostcache[HOSTCACHESIZE]` | review-required |  |
| global | `extern sizebuf_t net_message` | review-required |  |
| global | `extern int net_activeconnections` | review-required |  |
| global | `PollProcedure` | review-required |  |
| global | `extern qboolean serialAvailable` | review-required |  |
| global | `extern qboolean ipxAvailable` | review-required |  |
| global | `extern qboolean tcpipAvailable` | review-required |  |
| global | `extern char my_ipx_address[NET_NAMELEN]` | review-required |  |
| global | `extern char my_tcpip_address[NET_NAMELEN]` | review-required |  |
| global | `extern qboolean slistInProgress` | review-required |  |
| global | `extern qboolean slistSilent` | review-required |  |
| global | `extern qboolean slistLocal` | review-required |  |
| prototype | `NET_NewQSocket` | review-required |  |
| prototype | `NET_FreeQSocket` | review-required |  |
| prototype | `SetNetTime` | review-required |  |
| prototype | `NET_Init` | review-required |  |
| prototype | `NET_Shutdown` | review-required |  |
| prototype | `NET_CheckNewConnections` | review-required |  |
| prototype | `NET_Connect` | review-required |  |
| prototype | `NET_CanSendMessage` | review-required |  |
| prototype | `NET_GetMessage` | review-required |  |
| prototype | `NET_SendMessage` | review-required |  |
| prototype | `NET_SendUnreliableMessage` | review-required |  |
| prototype | `NET_SendToAll` | review-required |  |
| prototype | `NET_Close` | review-required |  |
| prototype | `NET_Poll` | review-required |  |
| prototype | `SchedulePollProcedure` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `NET_Slist_f` | review-required |  |

### `net_dgrm.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `StrAddr` | review-required |  |
| function | `NET_Ban_f` | review-required |  |
| function | `Datagram_SendMessage` | review-required |  |
| function | `SendMessageNext` | review-required |  |
| function | `ReSendMessage` | review-required |  |
| function | `Datagram_CanSendMessage` | review-required |  |
| function | `Datagram_CanSendUnreliableMessage` | review-required |  |
| function | `Datagram_SendUnreliableMessage` | review-required |  |
| function | `Datagram_GetMessage` | review-required |  |
| function | `PrintStats` | review-required |  |
| function | `NET_Stats_f` | review-required |  |
| function | `Test_Poll` | review-required |  |
| function | `Test_f` | review-required |  |
| function | `Test2_Poll` | review-required |  |
| function | `Test2_f` | review-required |  |
| function | `Datagram_Init` | review-required |  |
| function | `Datagram_Shutdown` | review-required |  |
| function | `Datagram_Close` | review-required |  |
| function | `Datagram_Listen` | review-required |  |
| function | `_Datagram_CheckNewConnections` | review-required |  |
| function | `Datagram_CheckNewConnections` | review-required |  |
| function | `_Datagram_SearchForHosts` | review-required |  |
| function | `Datagram_SearchForHosts` | review-required |  |
| function | `_Datagram_Connect` | review-required |  |
| function | `Datagram_Connect` | review-required |  |
| type | `in_addr` | review-required |  |
| field | `in_addr.union { struct { unsigned char s_b1,s_b2,s_b3,s_b4` | review-required |  |
| field | `in_addr.} S_un_b` | review-required |  |
| field | `in_addr.struct { unsigned short s_w1,s_w2` | review-required |  |
| field | `in_addr.} S_un_w` | review-required |  |
| field | `in_addr.unsigned long S_addr` | review-required |  |
| field | `in_addr.} S_un` | review-required |  |
| type | `sockaddr_in` | review-required |  |
| field | `sockaddr_in.short sin_family` | review-required |  |
| field | `sockaddr_in.unsigned short sin_port` | review-required |  |
| field | `sockaddr_in.struct in_addr sin_addr` | review-required |  |
| field | `sockaddr_in.char sin_zero[8]` | review-required |  |
| macro | `BAN_TEST` | review-required |  |
| macro | `AF_INET` | review-required |  |
| macro | `s_addr` | review-required |  |
| macro | `sfunc` | review-required |  |
| macro | `dfunc` | review-required |  |
| global | `/* statistic counters */ int packetsSent = 0` | review-required |  |
| global | `int packetsReSent = 0` | review-required |  |
| global | `int packetsReceived = 0` | review-required |  |
| global | `int receivedDuplicateCount = 0` | review-required |  |
| global | `int shortPacketCount = 0` | review-required |  |
| global | `int droppedDatagrams` | review-required |  |
| global | `static int myDriverLevel` | review-required |  |
| global | `packetBuffer` | review-required |  |
| global | `extern int m_return_state` | review-required |  |
| global | `extern int m_state` | review-required |  |
| global | `extern qboolean m_return_onerror` | review-required |  |
| global | `extern char m_return_reason[32]` | review-required |  |
| global | `unsigned long banMask = 0xffffffff` | review-required |  |
| global | `static qboolean testInProgress = false` | review-required |  |
| global | `static int testPollCount` | review-required |  |
| global | `static int testDriver` | review-required |  |
| global | `static int testSocket` | review-required |  |
| global | `static qboolean test2InProgress = false` | review-required |  |
| global | `static int test2Driver` | review-required |  |
| global | `static int test2Socket` | review-required |  |
| prototype | `inet_ntoa` | review-required |  |
| prototype | `inet_addr` | review-required |  |
| prototype | `Test_Poll` | review-required |  |
| prototype | `Test2_Poll` | review-required |  |

### `net_dgrm.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `Datagram_Init` | review-required |  |
| prototype | `Datagram_Listen` | review-required |  |
| prototype | `Datagram_SearchForHosts` | review-required |  |
| prototype | `Datagram_Connect` | review-required |  |
| prototype | `Datagram_CheckNewConnections` | review-required |  |
| prototype | `Datagram_GetMessage` | review-required |  |
| prototype | `Datagram_SendMessage` | review-required |  |
| prototype | `Datagram_SendUnreliableMessage` | review-required |  |
| prototype | `Datagram_CanSendMessage` | review-required |  |
| prototype | `Datagram_CanSendUnreliableMessage` | review-required |  |
| prototype | `Datagram_Close` | review-required |  |
| prototype | `Datagram_Shutdown` | review-required |  |

### `net_loop.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Loop_Init` | review-required | `miniquake/net_loop.ml:Loop_Init` |
| function | `Loop_Shutdown` | review-required | `miniquake/net_loop.ml:Loop_Shutdown`, `miniquake/net_loop.ml:shutdown` |
| function | `Loop_Listen` | review-required | `miniquake/net_loop.ml:Loop_Listen`, `miniquake/net_loop.ml:listen` |
| function | `Loop_SearchForHosts` | review-required | `miniquake/net_loop.ml:Loop_SearchForHosts`, `miniquake/net_loop.ml:searchForHosts` |
| function | `Loop_Connect` | review-required | `miniquake/net_loop.ml:Loop_Connect`, `miniquake/net_loop.ml:connect` |
| function | `Loop_CheckNewConnections` | review-required | `miniquake/net_loop.ml:Loop_CheckNewConnections`, `miniquake/net_loop.ml:checkNewConnections` |
| function | `IntAlign` | review-required | `miniquake/net_loop.ml:IntAlign` |
| function | `Loop_GetMessage` | review-required | `miniquake/net_loop.ml:Loop_GetMessage`, `miniquake/net_loop.ml:getMessage` |
| function | `Loop_SendMessage` | review-required | `miniquake/net_loop.ml:Loop_SendMessage`, `miniquake/net_loop.ml:sendMessage` |
| function | `Loop_SendUnreliableMessage` | review-required | `miniquake/net_loop.ml:Loop_SendUnreliableMessage`, `miniquake/net_loop.ml:sendUnreliableMessage` |
| function | `Loop_CanSendMessage` | review-required | `miniquake/net_loop.ml:Loop_CanSendMessage`, `miniquake/net_loop.ml:canSendMessage` |
| function | `Loop_CanSendUnreliableMessage` | review-required | `miniquake/net_loop.ml:Loop_CanSendUnreliableMessage`, `miniquake/net_loop.ml:canSendUnreliableMessage` |
| function | `Loop_Close` | review-required | `miniquake/net_loop.ml:Loop_Close`, `miniquake/net_loop.ml:close` |
| global | `qsocket_t *loop_client = NULL` | review-required |  |
| global | `qsocket_t *loop_server = NULL` | review-required |  |

### `net_loop.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `Loop_Init` | review-required |  |
| prototype | `Loop_Listen` | review-required |  |
| prototype | `Loop_SearchForHosts` | review-required |  |
| prototype | `Loop_Connect` | review-required |  |
| prototype | `Loop_CheckNewConnections` | review-required |  |
| prototype | `Loop_GetMessage` | review-required |  |
| prototype | `Loop_SendMessage` | review-required |  |
| prototype | `Loop_SendUnreliableMessage` | review-required |  |
| prototype | `Loop_CanSendMessage` | review-required |  |
| prototype | `Loop_CanSendUnreliableMessage` | review-required |  |
| prototype | `Loop_Close` | review-required |  |
| prototype | `Loop_Shutdown` | review-required |  |

### `net_main.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SetNetTime` | review-required |  |
| function | `NET_NewQSocket` | review-required |  |
| function | `NET_FreeQSocket` | review-required |  |
| function | `NET_Listen_f` | review-required |  |
| function | `MaxPlayers_f` | review-required |  |
| function | `NET_Port_f` | review-required |  |
| function | `PrintSlistHeader` | review-required |  |
| function | `PrintSlist` | review-required |  |
| function | `PrintSlistTrailer` | review-required |  |
| function | `NET_Slist_f` | review-required |  |
| function | `Slist_Send` | review-required |  |
| function | `Slist_Poll` | review-required |  |
| function | `NET_Connect` | review-required | `miniquake/net_loop.ml:connect`, `miniquake/net_loop.ml:Loop_Connect`, `miniquake/client.ml:connect` |
| function | `NET_CheckNewConnections` | review-required | `miniquake/net_loop.ml:checkNewConnections`, `miniquake/net_loop.ml:Loop_CheckNewConnections` |
| function | `NET_Close` | review-required | `miniquake/net_loop.ml:close`, `miniquake/net_loop.ml:Loop_Close`, `miniquake/net_udp.ml:close` |
| function | `NET_GetMessage` | review-required | `miniquake/net_loop.ml:getMessage`, `miniquake/net_loop.ml:Loop_GetMessage` |
| function | `NET_SendMessage` | review-required | `miniquake/net_loop.ml:sendMessage`, `miniquake/net_loop.ml:Loop_SendMessage` |
| function | `NET_SendUnreliableMessage` | review-required | `miniquake/net_loop.ml:sendUnreliableMessage`, `miniquake/net_loop.ml:Loop_SendUnreliableMessage` |
| function | `NET_CanSendMessage` | review-required | `miniquake/net_loop.ml:canSendMessage`, `miniquake/net_loop.ml:Loop_CanSendMessage` |
| function | `NET_SendToAll` | review-required |  |
| function | `NET_Init` | review-required | `miniquake/net_loop.ml:Loop_Init`, `miniquake/client.ml:CL_Init`, `miniquake/server.ml:SV_Init` |
| function | `NET_Shutdown` | review-required | `miniquake/net_loop.ml:shutdown`, `miniquake/net_loop.ml:Loop_Shutdown`, `miniquake/server.ml:shutdown` |
| function | `NET_Poll` | review-required |  |
| function | `SchedulePollProcedure` | review-required |  |
| function | `IsID` | review-required |  |
| macro | `sfunc` | review-required |  |
| macro | `dfunc` | review-required |  |
| macro | `IDNET` | review-required |  |
| global | `qsocket_t *net_freeSockets = NULL` | review-required |  |
| global | `int net_numsockets = 0` | review-required |  |
| global | `qboolean serialAvailable = false` | review-required |  |
| global | `qboolean ipxAvailable = false` | review-required |  |
| global | `qboolean tcpipAvailable = false` | review-required |  |
| global | `int net_hostport` | review-required |  |
| global | `int DEFAULTnet_hostport = 26000` | review-required |  |
| global | `char my_ipx_address[NET_NAMELEN]` | review-required |  |
| global | `char my_tcpip_address[NET_NAMELEN]` | review-required |  |
| global | `static qboolean listening = false` | review-required |  |
| global | `qboolean slistInProgress = false` | review-required |  |
| global | `qboolean slistSilent = false` | review-required |  |
| global | `qboolean slistLocal = true` | review-required |  |
| global | `static double slistStartTime` | review-required |  |
| global | `static int slistLastShown` | review-required |  |
| global | `sizebuf_t net_message` | review-required |  |
| global | `int net_activeconnections = 0` | review-required |  |
| global | `int messagesSent = 0` | review-required |  |
| global | `int messagesReceived = 0` | review-required |  |
| global | `int unreliableMessagesSent = 0` | review-required |  |
| global | `int unreliableMessagesReceived = 0` | review-required |  |
| global | `qboolean configRestored = false` | review-required |  |
| global | `qboolean recording = false` | review-required |  |
| global | `// these two macros are to make the code more readable #define sfunc net_drivers[sock->driver] #define dfunc net_drivers[net_driverlevel] int net_driverlevel` | review-required |  |
| global | `double net_time` | review-required |  |
| global | `/* =================== NET_Connect =================== */ int hostCacheCount = 0` | review-required |  |
| global | `hostcache_t hostcache[HOSTCACHESIZE]` | review-required |  |
| global | `vcrConnect` | review-required |  |
| global | `vcrGetMessage` | review-required |  |
| global | `vcrSendMessage` | review-required |  |
| global | `static PollProcedure *pollProcedureList = NULL` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `Slist_Send` | review-required |  |
| prototype | `Slist_Poll` | review-required |  |
| prototype | `PrintStats` | review-required |  |

### `net_ser.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `Serial_Init` | review-required |  |
| prototype | `Serial_Listen` | review-required |  |
| prototype | `Serial_SearchForHosts` | review-required |  |
| prototype | `Serial_Connect` | review-required |  |
| prototype | `Serial_CheckNewConnections` | review-required |  |
| prototype | `Serial_GetMessage` | review-required |  |
| prototype | `Serial_SendMessage` | review-required |  |
| prototype | `Serial_SendUnreliableMessage` | review-required |  |
| prototype | `Serial_CanSendMessage` | review-required |  |
| prototype | `Serial_CanSendUnreliableMessage` | review-required |  |
| prototype | `Serial_Close` | review-required |  |
| prototype | `Serial_Shutdown` | review-required |  |

### `net_vcr.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `VCR_Init` | review-required |  |
| function | `VCR_ReadNext` | review-required |  |
| function | `VCR_Listen` | review-required |  |
| function | `VCR_Shutdown` | review-required |  |
| function | `VCR_GetMessage` | review-required |  |
| function | `VCR_SendMessage` | review-required |  |
| function | `VCR_CanSendMessage` | review-required |  |
| function | `VCR_Close` | review-required |  |
| function | `VCR_SearchForHosts` | review-required |  |
| function | `VCR_Connect` | review-required |  |
| function | `VCR_CheckNewConnections` | review-required |  |
| global | `next` | review-required |  |

### `net_vcr.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| macro | `VCR_OP_CONNECT` | review-required |  |
| macro | `VCR_OP_GETMESSAGE` | review-required |  |
| macro | `VCR_OP_SENDMESSAGE` | review-required |  |
| macro | `VCR_OP_CANSENDMESSAGE` | review-required |  |
| macro | `VCR_MAX_MESSAGE` | review-required |  |
| prototype | `VCR_Init` | review-required |  |
| prototype | `VCR_Listen` | review-required |  |
| prototype | `VCR_SearchForHosts` | review-required |  |
| prototype | `VCR_Connect` | review-required |  |
| prototype | `VCR_CheckNewConnections` | review-required |  |
| prototype | `VCR_GetMessage` | review-required |  |
| prototype | `VCR_SendMessage` | review-required |  |
| prototype | `VCR_CanSendMessage` | review-required |  |
| prototype | `VCR_Close` | review-required |  |
| prototype | `VCR_Shutdown` | review-required |  |

### `net_win.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| global | `int net_numdrivers = 2` | review-required |  |
| global | `int net_numlandrivers = 2` | review-required |  |

### `net_wins.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `BlockingHook` | review-required |  |
| function | `WINS_GetLocalAddress` | review-required |  |
| function | `WINS_Init` | review-required |  |
| function | `WINS_Shutdown` | review-required |  |
| function | `WINS_Listen` | review-required |  |
| function | `WINS_OpenSocket` | review-required |  |
| function | `WINS_CloseSocket` | review-required |  |
| function | `PartialIPAddress` | review-required |  |
| function | `WINS_Connect` | review-required |  |
| function | `WINS_CheckNewConnections` | review-required |  |
| function | `WINS_Read` | review-required |  |
| function | `WINS_MakeSocketBroadcastCapable` | review-required |  |
| function | `WINS_Broadcast` | review-required |  |
| function | `WINS_Write` | review-required |  |
| function | `WINS_AddrToString` | review-required |  |
| function | `WINS_StringToAddr` | review-required |  |
| function | `WINS_GetSocketAddr` | review-required |  |
| function | `WINS_GetNameFromAddr` | review-required |  |
| function | `WINS_GetAddrFromName` | review-required |  |
| function | `WINS_AddrCompare` | review-required |  |
| function | `WINS_GetSocketPort` | review-required |  |
| function | `WINS_SetSocketPort` | review-required |  |
| macro | `MAXHOSTNAMELEN` | review-required |  |
| global | `// socket for fielding new connections static int net_controlsocket` | review-required |  |
| global | `static int net_broadcastsocket = 0` | review-required |  |
| global | `static struct qsockaddr broadcastaddr` | review-required |  |
| global | `static unsigned long myAddr` | review-required |  |
| global | `qboolean winsock_lib_initialized` | review-required |  |
| global | `WSADATA winsockdata` | review-required |  |
| global | `//============================================================================= static double blocktime` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `SOCKET` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |

### `net_wins.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `WINS_Init` | review-required |  |
| prototype | `WINS_Shutdown` | review-required |  |
| prototype | `WINS_Listen` | review-required |  |
| prototype | `WINS_OpenSocket` | review-required |  |
| prototype | `WINS_CloseSocket` | review-required |  |
| prototype | `WINS_Connect` | review-required |  |
| prototype | `WINS_CheckNewConnections` | review-required |  |
| prototype | `WINS_Read` | review-required |  |
| prototype | `WINS_Write` | review-required |  |
| prototype | `WINS_Broadcast` | review-required |  |
| prototype | `WINS_AddrToString` | review-required |  |
| prototype | `WINS_StringToAddr` | review-required |  |
| prototype | `WINS_GetSocketAddr` | review-required |  |
| prototype | `WINS_GetNameFromAddr` | review-required |  |
| prototype | `WINS_GetAddrFromName` | review-required |  |
| prototype | `WINS_AddrCompare` | review-required |  |
| prototype | `WINS_GetSocketPort` | review-required |  |
| prototype | `WINS_SetSocketPort` | review-required |  |

### `net_wipx.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `WIPX_Init` | review-required |  |
| function | `WIPX_Shutdown` | review-required |  |
| function | `WIPX_Listen` | review-required |  |
| function | `WIPX_OpenSocket` | review-required |  |
| function | `WIPX_CloseSocket` | review-required |  |
| function | `WIPX_Connect` | review-required |  |
| function | `WIPX_CheckNewConnections` | review-required |  |
| function | `WIPX_Read` | review-required |  |
| function | `WIPX_Broadcast` | review-required |  |
| function | `WIPX_Write` | review-required |  |
| function | `WIPX_AddrToString` | review-required |  |
| function | `WIPX_StringToAddr` | review-required |  |
| function | `WIPX_GetSocketAddr` | review-required |  |
| function | `WIPX_GetNameFromAddr` | review-required |  |
| function | `WIPX_GetAddrFromName` | review-required |  |
| function | `WIPX_AddrCompare` | review-required |  |
| function | `WIPX_GetSocketPort` | review-required |  |
| function | `WIPX_SetSocketPort` | review-required |  |
| macro | `MAXHOSTNAMELEN` | review-required |  |
| macro | `IPXSOCKETS` | review-required |  |
| macro | `DO` | review-required |  |
| global | `// socket for fielding new connections static int net_controlsocket` | review-required |  |
| global | `static struct qsockaddr broadcastaddr` | review-required |  |
| global | `extern qboolean winsock_initialized` | review-required |  |
| global | `extern WSADATA winsockdata` | review-required |  |
| global | `static int sequence[IPXSOCKETS]` | review-required |  |
| global | `//============================================================================= static byte packetBuffer[NET_DATAGRAMSIZE + 4]` | review-required |  |

### `net_wipx.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `WIPX_Init` | review-required |  |
| prototype | `WIPX_Shutdown` | review-required |  |
| prototype | `WIPX_Listen` | review-required |  |
| prototype | `WIPX_OpenSocket` | review-required |  |
| prototype | `WIPX_CloseSocket` | review-required |  |
| prototype | `WIPX_Connect` | review-required |  |
| prototype | `WIPX_CheckNewConnections` | review-required |  |
| prototype | `WIPX_Read` | review-required |  |
| prototype | `WIPX_Write` | review-required |  |
| prototype | `WIPX_Broadcast` | review-required |  |
| prototype | `WIPX_AddrToString` | review-required |  |
| prototype | `WIPX_StringToAddr` | review-required |  |
| prototype | `WIPX_GetSocketAddr` | review-required |  |
| prototype | `WIPX_GetNameFromAddr` | review-required |  |
| prototype | `WIPX_GetAddrFromName` | review-required |  |
| prototype | `WIPX_AddrCompare` | review-required |  |
| prototype | `WIPX_GetSocketPort` | review-required |  |
| prototype | `WIPX_SetSocketPort` | review-required |  |

### `pr_cmds.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `PF_VarString` | review-required | `miniquake/quakec/builtins.ml:PF_VarString`, `miniquake/quakec/builtins.ml:varString` |
| function | `PF_error` | review-required | `miniquake/quakec/builtins.ml:PF_error` |
| function | `PF_objerror` | review-required | `miniquake/quakec/builtins.ml:PF_objerror` |
| function | `PF_makevectors` | review-required | `miniquake/quakec/builtins.ml:PF_makevectors`, `miniquake/quakec/builtins.ml:makeVectors` |
| function | `PF_setorigin` | review-required | `miniquake/quakec/builtins.ml:PF_setorigin`, `miniquake/quakec/builtins.ml:setOrigin` |
| function | `SetMinMaxSize` | review-required | `miniquake/quakec/builtins.ml:SetMinMaxSize` |
| function | `PF_setsize` | review-required | `miniquake/quakec/builtins.ml:PF_setsize`, `miniquake/quakec/builtins.ml:setSize` |
| function | `PF_setmodel` | review-required | `miniquake/quakec/builtins.ml:PF_setmodel`, `miniquake/quakec/builtins.ml:setModel` |
| function | `PF_bprint` | review-required | `miniquake/quakec/builtins.ml:PF_bprint` |
| function | `PF_sprint` | review-required | `miniquake/quakec/builtins.ml:PF_sprint`, `miniquake/quakec/builtins.ml:PF_rint` |
| function | `PF_centerprint` | review-required | `miniquake/quakec/builtins.ml:PF_centerprint` |
| function | `PF_normalize` | review-required | `miniquake/quakec/builtins.ml:PF_normalize` |
| function | `PF_vlen` | review-required | `miniquake/quakec/builtins.ml:PF_vlen` |
| function | `PF_vectoyaw` | review-required | `miniquake/quakec/builtins.ml:PF_vectoyaw` |
| function | `PF_vectoangles` | review-required | `miniquake/quakec/builtins.ml:PF_vectoangles` |
| function | `PF_random` | review-required | `miniquake/quakec/builtins.ml:PF_random` |
| function | `PF_particle` | review-required | `miniquake/quakec/builtins.ml:PF_particle` |
| function | `PF_ambientsound` | review-required | `miniquake/quakec/builtins.ml:PF_ambientsound` |
| function | `PF_sound` | review-required | `miniquake/quakec/builtins.ml:PF_sound` |
| function | `PF_break` | review-required | `miniquake/quakec/builtins.ml:PF_break` |
| function | `PF_traceline` | review-required | `miniquake/quakec/builtins.ml:PF_traceline` |
| function | `PF_TraceToss` | review-required |  |
| function | `PF_checkpos` | review-required |  |
| function | `PF_newcheckclient` | review-required | `miniquake/quakec/builtins.ml:PF_newcheckclient`, `miniquake/quakec/builtins.ml:newCheckClient` |
| function | `PF_checkclient` | review-required | `miniquake/quakec/builtins.ml:PF_checkclient` |
| function | `PF_stuffcmd` | review-required | `miniquake/quakec/builtins.ml:PF_stuffcmd` |
| function | `PF_localcmd` | review-required | `miniquake/quakec/builtins.ml:PF_localcmd` |
| function | `PF_cvar` | review-required | `miniquake/quakec/builtins.ml:PF_cvar` |
| function | `PF_cvar_set` | review-required | `miniquake/quakec/builtins.ml:PF_cvar_set` |
| function | `PF_findradius` | review-required | `miniquake/quakec/builtins.ml:PF_findradius` |
| function | `PF_dprint` | review-required | `miniquake/quakec/builtins.ml:PF_dprint` |
| function | `PF_ftos` | review-required | `miniquake/quakec/builtins.ml:PF_ftos` |
| function | `PF_fabs` | review-required | `miniquake/quakec/builtins.ml:PF_fabs` |
| function | `PF_vtos` | review-required | `miniquake/quakec/builtins.ml:PF_vtos` |
| function | `PF_etos` | review-required |  |
| function | `PF_Spawn` | review-required | `miniquake/quakec/builtins.ml:PF_Spawn` |
| function | `PF_Remove` | review-required | `miniquake/quakec/builtins.ml:PF_Remove` |
| function | `PR_CheckEmptyString` | review-required | `miniquake/quakec/builtins.ml:PR_CheckEmptyString` |
| function | `PF_precache_file` | review-required | `miniquake/quakec/builtins.ml:PF_precache_file` |
| function | `PF_precache_sound` | review-required | `miniquake/quakec/builtins.ml:PF_precache_sound` |
| function | `PF_precache_model` | review-required | `miniquake/quakec/builtins.ml:PF_precache_model` |
| function | `PF_coredump` | review-required | `miniquake/quakec/builtins.ml:PF_coredump` |
| function | `PF_traceon` | review-required | `miniquake/quakec/builtins.ml:PF_traceon` |
| function | `PF_traceoff` | review-required | `miniquake/quakec/builtins.ml:PF_traceoff` |
| function | `PF_eprint` | review-required | `miniquake/quakec/builtins.ml:PF_eprint` |
| function | `PF_walkmove` | review-required | `miniquake/quakec/builtins.ml:PF_walkmove` |
| function | `PF_droptofloor` | review-required | `miniquake/quakec/builtins.ml:PF_droptofloor` |
| function | `PF_lightstyle` | review-required | `miniquake/quakec/builtins.ml:PF_lightstyle` |
| function | `PF_rint` | review-required | `miniquake/quakec/builtins.ml:PF_rint`, `miniquake/quakec/builtins.ml:PF_sprint` |
| function | `PF_floor` | review-required | `miniquake/quakec/builtins.ml:PF_floor` |
| function | `PF_ceil` | review-required | `miniquake/quakec/builtins.ml:PF_ceil` |
| function | `PF_checkbottom` | review-required | `miniquake/quakec/builtins.ml:PF_checkbottom` |
| function | `PF_pointcontents` | review-required | `miniquake/quakec/builtins.ml:PF_pointcontents` |
| function | `PF_nextent` | review-required | `miniquake/quakec/builtins.ml:PF_nextent` |
| function | `PF_aim` | review-required | `miniquake/quakec/builtins.ml:PF_aim` |
| function | `PF_changeyaw` | review-required | `miniquake/quakec/builtins.ml:PF_changeyaw` |
| function | `PF_changepitch` | review-required |  |
| function | `WriteDest` | review-required | `miniquake/quakec/builtins.ml:WriteDest` |
| function | `PF_WriteByte` | review-required | `miniquake/quakec/builtins.ml:PF_WriteByte` |
| function | `PF_WriteChar` | review-required | `miniquake/quakec/builtins.ml:PF_WriteChar` |
| function | `PF_WriteShort` | review-required | `miniquake/quakec/builtins.ml:PF_WriteShort` |
| function | `PF_WriteLong` | review-required | `miniquake/quakec/builtins.ml:PF_WriteLong` |
| function | `PF_WriteAngle` | review-required | `miniquake/quakec/builtins.ml:PF_WriteAngle` |
| function | `PF_WriteCoord` | review-required | `miniquake/quakec/builtins.ml:PF_WriteCoord` |
| function | `PF_WriteString` | review-required | `miniquake/quakec/builtins.ml:PF_WriteString` |
| function | `PF_WriteEntity` | review-required | `miniquake/quakec/builtins.ml:PF_WriteEntity` |
| function | `PF_makestatic` | review-required | `miniquake/quakec/builtins.ml:PF_makestatic` |
| function | `PF_setspawnparms` | review-required | `miniquake/quakec/builtins.ml:PF_setspawnparms` |
| function | `PF_changelevel` | review-required | `miniquake/quakec/builtins.ml:PF_changelevel` |
| function | `PF_WaterMove` | review-required |  |
| function | `PF_sin` | review-required |  |
| function | `PF_cos` | review-required |  |
| function | `PF_sqrt` | review-required |  |
| function | `PF_Fixme` | review-required | `miniquake/quakec/builtins.ml:PF_Fixme`, `miniquake/quakec/builtins.ml:fixme` |
| macro | `RETURN_EDICT` | review-required |  |
| macro | `MAX_CHECK` | review-required |  |
| macro | `MSG_BROADCAST` | review-required |  |
| macro | `MSG_ONE` | review-required |  |
| macro | `MSG_ALL` | review-required |  |
| macro | `MSG_INIT` | review-required |  |
| macro | `CONTENT_WATER` | review-required |  |
| macro | `CONTENT_SLIME` | review-required |  |
| macro | `CONTENT_LAVA` | review-required |  |
| macro | `FL_IMMUNE_WATER` | review-required |  |
| macro | `FL_IMMUNE_SLIME` | review-required |  |
| macro | `FL_IMMUNE_LAVA` | review-required |  |
| macro | `CHAN_VOICE` | review-required |  |
| macro | `CHAN_BODY` | review-required |  |
| macro | `ATTN_NORM` | review-required |  |
| global | `//============================================================================ byte checkpvs[MAX_MAP_LEAFS/8]` | review-required |  |
| global | `char pr_string_temp[128]` | review-required |  |
| global | `builtin_t *pr_builtins = pr_builtin` | review-required |  |
| prototype | `SV_ModelIndex` | review-required |  |
| prototype | `sizeof` | review-required |  |

### `pr_comp.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `etype_t` | review-required |  |
| enum-value | `etype_t.ev_void` | review-required |  |
| enum-value | `etype_t.ev_string` | review-required |  |
| enum-value | `etype_t.ev_float` | review-required |  |
| enum-value | `etype_t.ev_vector` | review-required |  |
| enum-value | `etype_t.ev_entity` | review-required |  |
| enum-value | `etype_t.ev_field` | review-required |  |
| enum-value | `etype_t.ev_function` | review-required |  |
| enum-value | `etype_t.ev_pointer` | review-required |  |
| type | `dstatement_t` | review-required |  |
| field | `dstatement_t.unsigned short op` | review-required |  |
| field | `dstatement_t.short a,b,c` | review-required |  |
| type | `ddef_t` | review-required |  |
| field | `ddef_t.unsigned short type` | review-required |  |
| field | `ddef_t.// if DEF_SAVEGLOBGAL bit is set // the variable needs to be saved in savegames unsigned short ofs` | review-required |  |
| field | `ddef_t.int s_name` | review-required |  |
| type | `dfunction_t` | review-required |  |
| field | `dfunction_t.int first_statement` | review-required |  |
| field | `dfunction_t.// negative numbers are builtins int parm_start` | review-required |  |
| field | `dfunction_t.int locals` | review-required |  |
| field | `dfunction_t.// total ints of parms + locals int profile` | review-required |  |
| field | `dfunction_t.// runtime int s_name` | review-required |  |
| field | `dfunction_t.int s_file` | review-required |  |
| field | `dfunction_t.// source file defined in int numparms` | review-required |  |
| field | `dfunction_t.byte parm_size[MAX_PARMS]` | review-required |  |
| type | `dprograms_t` | review-required |  |
| field | `dprograms_t.int version` | review-required |  |
| field | `dprograms_t.int crc` | review-required |  |
| field | `dprograms_t.// check of header file int ofs_statements` | review-required |  |
| field | `dprograms_t.int numstatements` | review-required |  |
| field | `dprograms_t.// statement 0 is an error int ofs_globaldefs` | review-required |  |
| field | `dprograms_t.int numglobaldefs` | review-required |  |
| field | `dprograms_t.int ofs_fielddefs` | review-required |  |
| field | `dprograms_t.int numfielddefs` | review-required |  |
| field | `dprograms_t.int ofs_functions` | review-required |  |
| field | `dprograms_t.int numfunctions` | review-required |  |
| field | `dprograms_t.// function 0 is an empty int ofs_strings` | review-required |  |
| field | `dprograms_t.int numstrings` | review-required |  |
| field | `dprograms_t.// first string is a null string int ofs_globals` | review-required |  |
| field | `dprograms_t.int numglobals` | review-required |  |
| field | `dprograms_t.int entityfields` | review-required |  |
| macro | `OFS_NULL` | review-required |  |
| macro | `OFS_RETURN` | review-required |  |
| macro | `OFS_PARM0` | review-required |  |
| macro | `OFS_PARM1` | review-required |  |
| macro | `OFS_PARM2` | review-required |  |
| macro | `OFS_PARM3` | review-required |  |
| macro | `OFS_PARM4` | review-required |  |
| macro | `OFS_PARM5` | review-required |  |
| macro | `OFS_PARM6` | review-required |  |
| macro | `OFS_PARM7` | review-required |  |
| macro | `RESERVED_OFS` | review-required |  |
| macro | `DEF_SAVEGLOBAL` | review-required |  |
| macro | `MAX_PARMS` | review-required |  |
| macro | `PROG_VERSION` | review-required |  |
| global | `etype_t` | review-required |  |
| global | `dstatement_t` | review-required |  |
| global | `ddef_t` | review-required |  |
| global | `dfunction_t` | review-required |  |
| global | `dprograms_t` | review-required |  |

### `pr_edict.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `ED_ClearEdict` | review-required | `miniquake/quakec/edict.ml:ED_ClearEdict` |
| function | `ED_Alloc` | review-required | `miniquake/quakec/edict.ml:ED_Alloc` |
| function | `ED_Free` | review-required | `miniquake/quakec/edict.ml:ED_Free` |
| function | `ED_GlobalAtOfs` | review-required | `miniquake/quakec/edict.ml:ED_GlobalAtOfs` |
| function | `ED_FieldAtOfs` | review-required | `miniquake/quakec/edict.ml:ED_FieldAtOfs` |
| function | `ED_FindField` | review-required | `miniquake/quakec/edict.ml:ED_FindField` |
| function | `ED_FindGlobal` | review-required | `miniquake/quakec/edict.ml:ED_FindGlobal` |
| function | `ED_FindFunction` | review-required | `miniquake/quakec/edict.ml:ED_FindFunction` |
| function | `GetEdictFieldValue` | review-required | `miniquake/quakec/edict.ml:GetEdictFieldValue` |
| function | `PR_ValueString` | review-required | `miniquake/quakec/edict.ml:PR_ValueString`, `miniquake/quakec/edict.ml:valueString` |
| function | `PR_UglyValueString` | review-required | `miniquake/quakec/edict.ml:PR_UglyValueString`, `miniquake/quakec/edict.ml:uglyValueString` |
| function | `PR_GlobalString` | review-required | `miniquake/quakec/edict.ml:PR_GlobalString`, `miniquake/quakec/edict.ml:globalString` |
| function | `PR_GlobalStringNoContents` | review-required | `miniquake/quakec/edict.ml:PR_GlobalStringNoContents`, `miniquake/quakec/edict.ml:globalStringNoContents` |
| function | `ED_Print` | review-required | `miniquake/quakec/edict.ml:ED_Print` |
| function | `ED_Write` | review-required | `miniquake/quakec/edict.ml:ED_Write` |
| function | `ED_PrintNum` | review-required | `miniquake/quakec/edict.ml:ED_PrintNum` |
| function | `ED_PrintEdicts` | review-required | `miniquake/quakec/edict.ml:ED_PrintEdicts` |
| function | `ED_PrintEdict_f` | review-required | `miniquake/quakec/edict.ml:ED_PrintEdict_f` |
| function | `ED_Count` | review-required | `miniquake/quakec/edict.ml:ED_Count` |
| function | `ED_WriteGlobals` | review-required | `miniquake/quakec/edict.ml:ED_WriteGlobals` |
| function | `ED_ParseGlobals` | review-required | `miniquake/quakec/edict.ml:ED_ParseGlobals` |
| function | `ED_NewString` | review-required | `miniquake/quakec/edict.ml:ED_NewString` |
| function | `ED_ParseEpair` | review-required | `miniquake/quakec/edict.ml:ED_ParseEpair` |
| function | `ED_ParseEdict` | review-required | `miniquake/quakec/edict.ml:ED_ParseEdict` |
| function | `ED_LoadFromFile` | review-required | `miniquake/quakec/edict.ml:ED_LoadFromFile` |
| function | `PR_LoadProgs` | review-required | `miniquake/quakec/edict.ml:PR_LoadProgs` |
| function | `PR_Init` | review-required | `miniquake/quakec/edict.ml:PR_Init`, `miniquake/server.ml:SV_Init` |
| function | `EDICT_NUM` | review-required | `miniquake/quakec/edict.ml:EDICT_NUM` |
| function | `NUM_FOR_EDICT` | review-required | `miniquake/quakec/edict.ml:NUM_FOR_EDICT` |
| type | `gefv_cache` | review-required |  |
| field | `gefv_cache.ddef_t *pcache` | review-required |  |
| field | `gefv_cache.char field[MAX_FIELD_LEN]` | review-required |  |
| macro | `MAX_FIELD_LEN` | review-required |  |
| macro | `GEFV_CACHESIZE` | review-required |  |
| global | `dfunction_t *pr_functions` | review-required |  |
| global | `char *pr_strings` | review-required |  |
| global | `ddef_t *pr_fielddefs` | review-required |  |
| global | `ddef_t *pr_globaldefs` | review-required |  |
| global | `dstatement_t *pr_statements` | review-required |  |
| global | `globalvars_t *pr_global_struct` | review-required |  |
| global | `float *pr_globals` | review-required |  |
| global | `// same as pr_global_struct int pr_edict_size` | review-required |  |
| global | `// in bytes unsigned short pr_crc` | review-required |  |
| global | `gefv_cache` | review-required |  |
| prototype | `ED_FieldAtOfs` | review-required | `miniquake/quakec/edict.ml:ED_FieldAtOfs` |
| prototype | `ED_ParseEpair` | review-required | `miniquake/quakec/edict.ml:ED_ParseEpair` |

### `pr_exec.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `PR_PrintStatement` | review-required | `miniquake/quakec/vm.ml:PR_PrintStatement` |
| function | `PR_StackTrace` | review-required | `miniquake/quakec/vm.ml:PR_StackTrace` |
| function | `PR_Profile_f` | review-required | `miniquake/quakec/vm.ml:PR_Profile_f` |
| function | `PR_RunError` | review-required | `miniquake/quakec/vm.ml:PR_RunError` |
| function | `PR_EnterFunction` | review-required | `miniquake/quakec/vm.ml:PR_EnterFunction`, `miniquake/quakec/vm.ml:enterFunction` |
| function | `PR_LeaveFunction` | review-required | `miniquake/quakec/vm.ml:PR_LeaveFunction`, `miniquake/quakec/vm.ml:leaveFunction` |
| function | `PR_ExecuteProgram` | review-required | `miniquake/quakec/vm.ml:PR_ExecuteProgram` |
| type | `prstack_t` | review-required |  |
| field | `prstack_t.int s` | review-required |  |
| field | `prstack_t.dfunction_t *f` | review-required |  |
| macro | `MAX_STACK_DEPTH` | review-required |  |
| macro | `LOCALSTACK_SIZE` | review-required |  |
| global | `prstack_t` | review-required |  |
| global | `int pr_depth` | review-required |  |
| global | `int localstack_used` | review-required |  |
| global | `qboolean pr_trace` | review-required |  |
| global | `dfunction_t *pr_xfunction` | review-required |  |
| global | `int pr_xstatement` | review-required |  |
| global | `int pr_argc` | review-required |  |
| prototype | `PR_GlobalString` | review-required |  |
| prototype | `PR_GlobalStringNoContents` | review-required |  |

### `progs.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `eval_t` | review-required |  |
| field | `eval_t.string_t string` | review-required |  |
| field | `eval_t.float _float` | review-required |  |
| field | `eval_t.float vector[3]` | review-required |  |
| field | `eval_t.func_t function` | review-required |  |
| field | `eval_t.int _int` | review-required |  |
| field | `eval_t.int edict` | review-required |  |
| type | `edict_t` | review-required |  |
| field | `edict_t.qboolean free` | review-required |  |
| field | `edict_t.link_t area` | review-required |  |
| field | `edict_t.// linked to a division node or leaf int num_leafs` | review-required |  |
| field | `edict_t.short leafnums[MAX_ENT_LEAFS]` | review-required |  |
| field | `edict_t.entity_state_t baseline` | review-required |  |
| field | `edict_t.float freetime` | review-required |  |
| field | `edict_t.// sv.time when the object was freed entvars_t v` | review-required |  |
| macro | `MAX_ENT_LEAFS` | review-required |  |
| macro | `EDICT_FROM_AREA` | review-required |  |
| macro | `NEXT_EDICT` | review-required |  |
| macro | `EDICT_TO_PROG` | review-required |  |
| macro | `PROG_TO_EDICT` | review-required |  |
| macro | `G_FLOAT` | review-required |  |
| macro | `G_INT` | review-required |  |
| macro | `G_EDICT` | review-required |  |
| macro | `G_EDICTNUM` | review-required |  |
| macro | `G_VECTOR` | review-required |  |
| macro | `G_STRING` | review-required |  |
| macro | `G_FUNCTION` | review-required |  |
| macro | `E_FLOAT` | review-required |  |
| macro | `E_INT` | review-required |  |
| macro | `E_VECTOR` | review-required |  |
| macro | `E_STRING` | review-required |  |
| global | `eval_t` | review-required |  |
| global | `edict_t` | review-required |  |
| global | `extern dfunction_t *pr_functions` | review-required |  |
| global | `extern char *pr_strings` | review-required |  |
| global | `extern ddef_t *pr_globaldefs` | review-required |  |
| global | `extern ddef_t *pr_fielddefs` | review-required |  |
| global | `extern dstatement_t *pr_statements` | review-required |  |
| global | `extern globalvars_t *pr_global_struct` | review-required |  |
| global | `extern float *pr_globals` | review-required |  |
| global | `// same as pr_global_struct extern int pr_edict_size` | review-required |  |
| global | `extern builtin_t *pr_builtins` | review-required |  |
| global | `extern int pr_numbuiltins` | review-required |  |
| global | `extern int pr_argc` | review-required |  |
| global | `extern qboolean pr_trace` | review-required |  |
| global | `extern dfunction_t *pr_xfunction` | review-required |  |
| global | `extern int pr_xstatement` | review-required |  |
| global | `extern unsigned short pr_crc` | review-required |  |
| prototype | `PR_Init` | review-required |  |
| prototype | `PR_ExecuteProgram` | review-required |  |
| prototype | `PR_LoadProgs` | review-required |  |
| prototype | `PR_Profile_f` | review-required |  |
| prototype | `ED_Alloc` | review-required |  |
| prototype | `ED_Free` | review-required |  |
| prototype | `ED_NewString` | review-required |  |
| prototype | `ED_Print` | review-required |  |
| prototype | `ED_Write` | review-required |  |
| prototype | `ED_ParseEdict` | review-required |  |
| prototype | `ED_WriteGlobals` | review-required |  |
| prototype | `ED_ParseGlobals` | review-required |  |
| prototype | `ED_LoadFromFile` | review-required |  |
| prototype | `EDICT_NUM` | review-required |  |
| prototype | `NUM_FOR_EDICT` | review-required |  |
| prototype | `PR_RunError` | review-required |  |
| prototype | `ED_PrintEdicts` | review-required |  |
| prototype | `ED_PrintNum` | review-required |  |
| prototype | `GetEdictFieldValue` | review-required |  |

### `protocol.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| macro | `PROTOCOL_VERSION` | review-required |  |
| macro | `U_MOREBITS` | review-required |  |
| macro | `U_ORIGIN1` | review-required |  |
| macro | `U_ORIGIN2` | review-required |  |
| macro | `U_ORIGIN3` | review-required |  |
| macro | `U_ANGLE2` | review-required |  |
| macro | `U_NOLERP` | review-required |  |
| macro | `U_FRAME` | review-required |  |
| macro | `U_SIGNAL` | review-required |  |
| macro | `U_ANGLE1` | review-required |  |
| macro | `U_ANGLE3` | review-required |  |
| macro | `U_MODEL` | review-required |  |
| macro | `U_COLORMAP` | review-required |  |
| macro | `U_SKIN` | review-required |  |
| macro | `U_EFFECTS` | review-required |  |
| macro | `U_LONGENTITY` | review-required |  |
| macro | `SU_VIEWHEIGHT` | review-required |  |
| macro | `SU_IDEALPITCH` | review-required |  |
| macro | `SU_PUNCH1` | review-required |  |
| macro | `SU_PUNCH2` | review-required |  |
| macro | `SU_PUNCH3` | review-required |  |
| macro | `SU_VELOCITY1` | review-required |  |
| macro | `SU_VELOCITY2` | review-required |  |
| macro | `SU_VELOCITY3` | review-required |  |
| macro | `SU_ITEMS` | review-required |  |
| macro | `SU_ONGROUND` | review-required |  |
| macro | `SU_INWATER` | review-required |  |
| macro | `SU_WEAPONFRAME` | review-required |  |
| macro | `SU_ARMOR` | review-required |  |
| macro | `SU_WEAPON` | review-required |  |
| macro | `SND_VOLUME` | review-required |  |
| macro | `SND_ATTENUATION` | review-required |  |
| macro | `SND_LOOPING` | review-required |  |
| macro | `DEFAULT_VIEWHEIGHT` | review-required |  |
| macro | `GAME_COOP` | review-required |  |
| macro | `GAME_DEATHMATCH` | review-required |  |
| macro | `svc_bad` | review-required |  |
| macro | `svc_nop` | review-required |  |
| macro | `svc_disconnect` | review-required |  |
| macro | `svc_updatestat` | review-required |  |
| macro | `svc_version` | review-required |  |
| macro | `svc_setview` | review-required |  |
| macro | `svc_sound` | review-required |  |
| macro | `svc_time` | review-required |  |
| macro | `svc_print` | review-required |  |
| macro | `svc_stufftext` | review-required |  |
| macro | `svc_setangle` | review-required |  |
| macro | `svc_serverinfo` | review-required |  |
| macro | `svc_lightstyle` | review-required |  |
| macro | `svc_updatename` | review-required |  |
| macro | `svc_updatefrags` | review-required |  |
| macro | `svc_clientdata` | review-required |  |
| macro | `svc_stopsound` | review-required |  |
| macro | `svc_updatecolors` | review-required |  |
| macro | `svc_particle` | review-required |  |
| macro | `svc_damage` | review-required |  |
| macro | `svc_spawnstatic` | review-required |  |
| macro | `svc_spawnbaseline` | review-required |  |
| macro | `svc_temp_entity` | review-required |  |
| macro | `svc_setpause` | review-required |  |
| macro | `svc_signonnum` | review-required |  |
| macro | `svc_centerprint` | review-required |  |
| macro | `svc_killedmonster` | review-required |  |
| macro | `svc_foundsecret` | review-required |  |
| macro | `svc_spawnstaticsound` | review-required |  |
| macro | `svc_intermission` | review-required |  |
| macro | `svc_finale` | review-required |  |
| macro | `svc_cdtrack` | review-required |  |
| macro | `svc_sellscreen` | review-required |  |
| macro | `svc_cutscene` | review-required |  |
| macro | `clc_bad` | review-required |  |
| macro | `clc_nop` | review-required |  |
| macro | `clc_disconnect` | review-required |  |
| macro | `clc_move` | review-required |  |
| macro | `clc_stringcmd` | review-required |  |
| macro | `TE_SPIKE` | review-required |  |
| macro | `TE_SUPERSPIKE` | review-required |  |
| macro | `TE_GUNSHOT` | review-required |  |
| macro | `TE_EXPLOSION` | review-required |  |
| macro | `TE_TAREXPLOSION` | review-required |  |
| macro | `TE_LIGHTNING1` | review-required |  |
| macro | `TE_LIGHTNING2` | review-required |  |
| macro | `TE_WIZSPIKE` | review-required |  |
| macro | `TE_KNIGHTSPIKE` | review-required |  |
| macro | `TE_LIGHTNING3` | review-required |  |
| macro | `TE_LAVASPLASH` | review-required |  |
| macro | `TE_TELEPORT` | review-required |  |
| macro | `TE_EXPLOSION2` | review-required |  |
| macro | `TE_BEAM` | review-required |  |
| macro | `TE_IMPLOSION` | review-required |  |
| macro | `TE_RAILTRAIL` | review-required |  |

### `quakedef.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `entity_state_t` | review-required |  |
| field | `entity_state_t.vec3_t origin` | review-required |  |
| field | `entity_state_t.vec3_t angles` | review-required |  |
| field | `entity_state_t.int modelindex` | review-required |  |
| field | `entity_state_t.int frame` | review-required |  |
| field | `entity_state_t.int colormap` | review-required |  |
| field | `entity_state_t.int skin` | review-required |  |
| field | `entity_state_t.int effects` | review-required |  |
| type | `quakeparms_t` | review-required |  |
| field | `quakeparms_t.char *basedir` | review-required |  |
| field | `quakeparms_t.char *cachedir` | review-required |  |
| field | `quakeparms_t.// for development over ISDN lines int argc` | review-required |  |
| field | `quakeparms_t.char **argv` | review-required |  |
| field | `quakeparms_t.void *membase` | review-required |  |
| field | `quakeparms_t.int memsize` | review-required |  |
| macro | `QUAKE_GAME` | review-required |  |
| macro | `VERSION` | review-required |  |
| macro | `GLQUAKE_VERSION` | review-required |  |
| macro | `D3DQUAKE_VERSION` | review-required |  |
| macro | `WINQUAKE_VERSION` | review-required |  |
| macro | `LINUX_VERSION` | review-required |  |
| macro | `X11_VERSION` | review-required |  |
| macro | `GAMENAME` | review-required |  |
| macro | `GAMENAME` | review-required |  |
| macro | `__i386__` | review-required |  |
| macro | `VID_LockBuffer` | review-required |  |
| macro | `VID_UnlockBuffer` | review-required |  |
| macro | `id386` | review-required |  |
| macro | `id386` | review-required |  |
| macro | `UNALIGNED_OK` | review-required |  |
| macro | `UNALIGNED_OK` | review-required |  |
| macro | `CACHE_SIZE` | review-required |  |
| macro | `UNUSED` | review-required |  |
| macro | `MINIMUM_MEMORY` | review-required |  |
| macro | `MINIMUM_MEMORY_LEVELPAK` | review-required |  |
| macro | `MAX_NUM_ARGVS` | review-required |  |
| macro | `PITCH` | review-required |  |
| macro | `YAW` | review-required |  |
| macro | `ROLL` | review-required |  |
| macro | `MAX_QPATH` | review-required |  |
| macro | `MAX_OSPATH` | review-required |  |
| macro | `ON_EPSILON` | review-required |  |
| macro | `MAX_MSGLEN` | review-required |  |
| macro | `MAX_DATAGRAM` | review-required |  |
| macro | `MAX_EDICTS` | review-required |  |
| macro | `MAX_LIGHTSTYLES` | review-required |  |
| macro | `MAX_MODELS` | review-required |  |
| macro | `MAX_SOUNDS` | review-required |  |
| macro | `SAVEGAME_COMMENT_LENGTH` | review-required |  |
| macro | `MAX_STYLESTRING` | review-required |  |
| macro | `MAX_CL_STATS` | review-required |  |
| macro | `STAT_HEALTH` | review-required |  |
| macro | `STAT_FRAGS` | review-required |  |
| macro | `STAT_WEAPON` | review-required |  |
| macro | `STAT_AMMO` | review-required |  |
| macro | `STAT_ARMOR` | review-required |  |
| macro | `STAT_WEAPONFRAME` | review-required |  |
| macro | `STAT_SHELLS` | review-required |  |
| macro | `STAT_NAILS` | review-required |  |
| macro | `STAT_ROCKETS` | review-required |  |
| macro | `STAT_CELLS` | review-required |  |
| macro | `STAT_ACTIVEWEAPON` | review-required |  |
| macro | `STAT_TOTALSECRETS` | review-required |  |
| macro | `STAT_TOTALMONSTERS` | review-required |  |
| macro | `STAT_SECRETS` | review-required |  |
| macro | `STAT_MONSTERS` | review-required |  |
| macro | `IT_SHOTGUN` | review-required |  |
| macro | `IT_SUPER_SHOTGUN` | review-required |  |
| macro | `IT_NAILGUN` | review-required |  |
| macro | `IT_SUPER_NAILGUN` | review-required |  |
| macro | `IT_GRENADE_LAUNCHER` | review-required |  |
| macro | `IT_ROCKET_LAUNCHER` | review-required |  |
| macro | `IT_LIGHTNING` | review-required |  |
| macro | `IT_SUPER_LIGHTNING` | review-required |  |
| macro | `IT_SHELLS` | review-required |  |
| macro | `IT_NAILS` | review-required |  |
| macro | `IT_ROCKETS` | review-required |  |
| macro | `IT_CELLS` | review-required |  |
| macro | `IT_AXE` | review-required |  |
| macro | `IT_ARMOR1` | review-required |  |
| macro | `IT_ARMOR2` | review-required |  |
| macro | `IT_ARMOR3` | review-required |  |
| macro | `IT_SUPERHEALTH` | review-required |  |
| macro | `IT_KEY1` | review-required |  |
| macro | `IT_KEY2` | review-required |  |
| macro | `IT_INVISIBILITY` | review-required |  |
| macro | `IT_INVULNERABILITY` | review-required |  |
| macro | `IT_SUIT` | review-required |  |
| macro | `IT_QUAD` | review-required |  |
| macro | `IT_SIGIL1` | review-required |  |
| macro | `IT_SIGIL2` | review-required |  |
| macro | `IT_SIGIL3` | review-required |  |
| macro | `IT_SIGIL4` | review-required |  |
| macro | `RIT_SHELLS` | review-required |  |
| macro | `RIT_NAILS` | review-required |  |
| macro | `RIT_ROCKETS` | review-required |  |
| macro | `RIT_CELLS` | review-required |  |
| macro | `RIT_AXE` | review-required |  |
| macro | `RIT_LAVA_NAILGUN` | review-required |  |
| macro | `RIT_LAVA_SUPER_NAILGUN` | review-required |  |
| macro | `RIT_MULTI_GRENADE` | review-required |  |
| macro | `RIT_MULTI_ROCKET` | review-required |  |
| macro | `RIT_PLASMA_GUN` | review-required |  |
| macro | `RIT_ARMOR1` | review-required |  |
| macro | `RIT_ARMOR2` | review-required |  |
| macro | `RIT_ARMOR3` | review-required |  |
| macro | `RIT_LAVA_NAILS` | review-required |  |
| macro | `RIT_PLASMA_AMMO` | review-required |  |
| macro | `RIT_MULTI_ROCKETS` | review-required |  |
| macro | `RIT_SHIELD` | review-required |  |
| macro | `RIT_ANTIGRAV` | review-required |  |
| macro | `RIT_SUPERHEALTH` | review-required |  |
| macro | `HIT_PROXIMITY_GUN_BIT` | review-required |  |
| macro | `HIT_MJOLNIR_BIT` | review-required |  |
| macro | `HIT_LASER_CANNON_BIT` | review-required |  |
| macro | `HIT_PROXIMITY_GUN` | review-required |  |
| macro | `HIT_MJOLNIR` | review-required |  |
| macro | `HIT_LASER_CANNON` | review-required |  |
| macro | `HIT_WETSUIT` | review-required |  |
| macro | `HIT_EMPATHY_SHIELDS` | review-required |  |
| macro | `MAX_SCOREBOARD` | review-required |  |
| macro | `MAX_SCOREBOARDNAME` | review-required |  |
| macro | `SOUND_CHANNELS` | review-required |  |
| global | `entity_state_t` | review-required |  |
| global | `quakeparms_t` | review-required |  |
| global | `//============================================================================= extern qboolean noclip_anglehack` | review-required |  |
| global | `// // host // extern quakeparms_t host_parms` | review-required |  |
| global | `extern cvar_t sys_ticrate` | review-required |  |
| global | `extern cvar_t sys_nostdout` | review-required |  |
| global | `extern cvar_t developer` | review-required |  |
| global | `extern qboolean host_initialized` | review-required |  |
| global | `// true if into command execution extern double host_frametime` | review-required |  |
| global | `extern byte *host_basepal` | review-required |  |
| global | `extern byte *host_colormap` | review-required |  |
| global | `extern int host_framecount` | review-required |  |
| global | `// incremented every frame, never reset extern double realtime` | review-required |  |
| global | `extern qboolean msg_suppress_1` | review-required |  |
| global | `// suppresses resolution and cache size console output // an fullscreen DIB focus gain/loss extern int current_skill` | review-required |  |
| global | `extern int minimum_memory` | review-required |  |
| global | `// // chase // extern cvar_t chase_active` | review-required |  |
| prototype | `defined` | review-required |  |
| prototype | `VID_UnlockBuffer` | review-required |  |
| prototype | `Host_ClearMemory` | review-required |  |
| prototype | `Host_ServerFrame` | review-required |  |
| prototype | `Host_InitCommands` | review-required |  |
| prototype | `Host_Init` | review-required |  |
| prototype | `Host_Shutdown` | review-required |  |
| prototype | `Host_Error` | review-required |  |
| prototype | `Host_EndGame` | review-required |  |
| prototype | `Host_Frame` | review-required |  |
| prototype | `Host_Quit_f` | review-required |  |
| prototype | `Host_ClientCommands` | review-required |  |
| prototype | `Host_ShutdownServer` | review-required |  |
| prototype | `Chase_Init` | review-required |  |
| prototype | `Chase_Reset` | review-required |  |
| prototype | `Chase_Update` | review-required |  |

### `r_local.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `alight_t` | review-required |  |
| field | `alight_t.int ambientlight` | review-required |  |
| field | `alight_t.int shadelight` | review-required |  |
| field | `alight_t.float *plightvec` | review-required |  |
| type | `bedge_t` | review-required |  |
| field | `bedge_t.mvertex_t *v[2]` | review-required |  |
| field | `bedge_t.struct bedge_s *pnext` | review-required |  |
| type | `auxvert_t` | review-required |  |
| field | `auxvert_t.float fv[3]` | review-required |  |
| type | `clipplane_t` | review-required |  |
| field | `clipplane_t.vec3_t normal` | review-required |  |
| field | `clipplane_t.float dist` | review-required |  |
| field | `clipplane_t.struct clipplane_s *next` | review-required |  |
| field | `clipplane_t.byte leftedge` | review-required |  |
| field | `clipplane_t.byte rightedge` | review-required |  |
| field | `clipplane_t.byte reserved[2]` | review-required |  |
| type | `btofpoly_t` | review-required |  |
| field | `btofpoly_t.int clipflags` | review-required |  |
| field | `btofpoly_t.msurface_t *psurf` | review-required |  |
| macro | `ALIAS_BASE_SIZE_RATIO` | review-required |  |
| macro | `BMODEL_FULLY_CLIPPED` | review-required |  |
| macro | `XCENTERING` | review-required |  |
| macro | `YCENTERING` | review-required |  |
| macro | `CLIP_EPSILON` | review-required |  |
| macro | `BACKFACE_EPSILON` | review-required |  |
| macro | `DIST_NOT_SET` | review-required |  |
| macro | `NEAR_CLIP` | review-required |  |
| macro | `MAXBVERTINDEXES` | review-required |  |
| macro | `MAX_BTOFPOLYS` | review-required |  |
| macro | `MAXALIASVERTS` | review-required |  |
| macro | `ALIAS_Z_CLIP_PLANE` | review-required |  |
| macro | `AMP` | review-required |  |
| macro | `AMP2` | review-required |  |
| macro | `SPEED` | review-required |  |
| global | `alight_t` | review-required |  |
| global | `bedge_t` | review-required |  |
| global | `auxvert_t` | review-required |  |
| global | `//=========================================================================== extern cvar_t r_draworder` | review-required |  |
| global | `extern cvar_t r_speeds` | review-required |  |
| global | `extern cvar_t r_timegraph` | review-required |  |
| global | `extern cvar_t r_graphheight` | review-required |  |
| global | `extern cvar_t r_clearcolor` | review-required |  |
| global | `extern cvar_t r_waterwarp` | review-required |  |
| global | `extern cvar_t r_fullbright` | review-required |  |
| global | `extern cvar_t r_drawentities` | review-required |  |
| global | `extern cvar_t r_aliasstats` | review-required |  |
| global | `extern cvar_t r_dspeeds` | review-required |  |
| global | `extern cvar_t r_drawflat` | review-required |  |
| global | `extern cvar_t r_ambient` | review-required |  |
| global | `extern cvar_t r_reportsurfout` | review-required |  |
| global | `extern cvar_t r_maxsurfs` | review-required |  |
| global | `extern cvar_t r_numsurfs` | review-required |  |
| global | `extern cvar_t r_reportedgeout` | review-required |  |
| global | `extern cvar_t r_maxedges` | review-required |  |
| global | `extern cvar_t r_numedges` | review-required |  |
| global | `clipplane_t` | review-required |  |
| global | `extern clipplane_t view_clipplanes[4]` | review-required |  |
| global | `//============================================================================= extern mplane_t screenedge[4]` | review-required |  |
| global | `extern vec3_t r_origin` | review-required |  |
| global | `extern vec3_t r_entorigin` | review-required |  |
| global | `extern float screenAspect` | review-required |  |
| global | `extern float verticalFieldOfView` | review-required |  |
| global | `extern float xOrigin, yOrigin` | review-required |  |
| global | `extern int r_visframecount` | review-required |  |
| global | `//============================================================================= extern int vstartscan` | review-required |  |
| global | `// // current entity info // extern qboolean insubmodel` | review-required |  |
| global | `extern vec3_t r_worldmodelorg` | review-required |  |
| global | `extern int c_faceclip` | review-required |  |
| global | `extern int r_polycount` | review-required |  |
| global | `extern int r_wholepolycount` | review-required |  |
| global | `extern model_t *cl_worldmodel` | review-required |  |
| global | `extern int *pfrustum_indexes[4]` | review-required |  |
| global | `// !!! if this is changed, it must be changed in asm_draw.h too !!! #define NEAR_CLIP 0.01 extern int ubasestep, errorterm, erroradjustup, erroradjustdown` | review-required |  |
| global | `extern int vstartscan` | review-required |  |
| global | `extern fixed16_t sadjust, tadjust` | review-required |  |
| global | `extern fixed16_t bbextents, bbextentt` | review-required |  |
| global | `extern vec3_t sbaseaxis[3], tbaseaxis[3]` | review-required |  |
| global | `extern float entity_rotation[3][3]` | review-required |  |
| global | `extern int reinit_surfcache` | review-required |  |
| global | `extern int r_currentkey` | review-required |  |
| global | `extern int r_currentbkey` | review-required |  |
| global | `btofpoly_t` | review-required |  |
| global | `extern btofpoly_t *pbtofpolys` | review-required |  |
| global | `//========================================================= // Alias models //========================================================= #define MAXALIASVERTS 2000 // TODO: tune this #define ALIAS_Z_CLIP_PLANE 5 extern int numverts` | review-required |  |
| global | `extern int a_skinwidth` | review-required |  |
| global | `extern mtriangle_t *ptriangles` | review-required |  |
| global | `extern int numtriangles` | review-required |  |
| global | `extern aliashdr_t *paliashdr` | review-required |  |
| global | `extern mdl_t *pmdl` | review-required |  |
| global | `extern float leftclip, topclip, rightclip, bottomclip` | review-required |  |
| global | `extern int r_acliptype` | review-required |  |
| global | `extern finalvert_t *pfinalverts` | review-required |  |
| global | `extern auxvert_t *pauxverts` | review-required |  |
| global | `extern int r_amodels_drawn` | review-required |  |
| global | `extern edge_t *auxedges` | review-required |  |
| global | `extern int r_numallocatededges` | review-required |  |
| global | `extern edge_t *r_edges, *edge_p, *edge_max` | review-required |  |
| global | `extern edge_t *newedges[MAXHEIGHT]` | review-required |  |
| global | `extern edge_t *removeedges[MAXHEIGHT]` | review-required |  |
| global | `extern int screenwidth` | review-required |  |
| global | `// FIXME: make stack vars when debugging done extern edge_t edge_head` | review-required |  |
| global | `extern edge_t edge_tail` | review-required |  |
| global | `extern edge_t edge_aftertail` | review-required |  |
| global | `extern int r_bmodelactive` | review-required |  |
| global | `extern vrect_t *pconupdate` | review-required |  |
| global | `extern float aliasxscale, aliasyscale, aliasxcenter, aliasycenter` | review-required |  |
| global | `extern float r_aliastransition, r_resfudge` | review-required |  |
| global | `extern int r_outofsurfaces` | review-required |  |
| global | `extern int r_outofedges` | review-required |  |
| global | `extern mvertex_t *r_pcurrentvertbase` | review-required |  |
| global | `extern int r_maxvalidedgeoffset` | review-required |  |
| global | `extern float r_time1` | review-required |  |
| global | `extern float dp_time1, dp_time2, db_time1, db_time2, rw_time1, rw_time2` | review-required |  |
| global | `extern float se_time1, se_time2, de_time1, de_time2, dv_time1, dv_time2` | review-required |  |
| global | `extern int r_frustum_indexes[4*6]` | review-required |  |
| global | `extern int r_maxsurfsseen, r_maxedgesseen, r_cnumsurfs` | review-required |  |
| global | `extern qboolean r_surfsonstack` | review-required |  |
| global | `extern cshift_t cshift_water` | review-required |  |
| global | `extern qboolean r_dowarpold, r_viewchanged` | review-required |  |
| global | `extern mleaf_t *r_viewleaf, *r_oldviewleaf` | review-required |  |
| global | `extern vec3_t r_emins, r_emaxs` | review-required |  |
| global | `extern mnode_t *r_pefragtopnode` | review-required |  |
| global | `extern int r_clipflags` | review-required |  |
| global | `extern int r_dlightframecount` | review-required |  |
| global | `extern qboolean r_fov_greater_than_90` | review-required |  |
| prototype | `R_RenderWorld` | review-required |  |
| prototype | `R_ClearPolyList` | review-required |  |
| prototype | `R_DrawPolyList` | review-required |  |
| prototype | `R_DrawSprite` | review-required |  |
| prototype | `R_RenderFace` | review-required |  |
| prototype | `R_RenderPoly` | review-required |  |
| prototype | `R_RenderBmodelFace` | review-required |  |
| prototype | `R_TransformPlane` | review-required |  |
| prototype | `R_TransformFrustum` | review-required |  |
| prototype | `R_SetSkyFrame` | review-required |  |
| prototype | `R_DrawSurfaceBlock16` | review-required |  |
| prototype | `R_DrawSurfaceBlock8` | review-required |  |
| prototype | `R_TextureAnimation` | review-required |  |
| prototype | `R_DrawSurfaceBlock8_mip1` | review-required |  |
| prototype | `R_DrawSurfaceBlock8_mip2` | review-required |  |
| prototype | `R_DrawSurfaceBlock8_mip3` | review-required |  |
| prototype | `R_GenSkyTile16` | review-required |  |
| prototype | `R_Surf8Patch` | review-required |  |
| prototype | `R_Surf16Patch` | review-required |  |
| prototype | `R_DrawSubmodelPolygons` | review-required |  |
| prototype | `R_DrawSolidClippedSubmodelPolygons` | review-required |  |
| prototype | `R_AddPolygonEdges` | review-required |  |
| prototype | `R_GetSurf` | review-required |  |
| prototype | `R_AliasDrawModel` | review-required |  |
| prototype | `R_BeginEdgeFrame` | review-required |  |
| prototype | `R_ScanEdges` | review-required |  |
| prototype | `D_DrawSurfaces` | review-required |  |
| prototype | `R_InsertNewEdges` | review-required |  |
| prototype | `R_StepActiveU` | review-required |  |
| prototype | `R_RemoveEdges` | review-required |  |
| prototype | `R_Surf8Start` | review-required |  |
| prototype | `R_Surf8End` | review-required |  |
| prototype | `R_Surf16Start` | review-required |  |
| prototype | `R_Surf16End` | review-required |  |
| prototype | `R_EdgeCodeStart` | review-required |  |
| prototype | `R_EdgeCodeEnd` | review-required |  |
| prototype | `R_RotateBmodel` | review-required |  |
| prototype | `R_InitTurb` | review-required |  |
| prototype | `R_ZDrawSubmodelPolys` | review-required |  |
| prototype | `R_AliasCheckBBox` | review-required |  |
| prototype | `R_DrawParticles` | review-required |  |
| prototype | `R_InitParticles` | review-required |  |
| prototype | `R_ClearParticles` | review-required |  |
| prototype | `R_ReadPointFile_f` | review-required |  |
| prototype | `R_SurfacePatch` | review-required |  |
| prototype | `R_AliasClipTriangle` | review-required |  |
| prototype | `R_StoreEfrags` | review-required |  |
| prototype | `R_TimeRefresh_f` | review-required |  |
| prototype | `R_TimeGraph` | review-required |  |
| prototype | `R_PrintAliasStats` | review-required |  |
| prototype | `R_PrintTimes` | review-required |  |
| prototype | `R_PrintDSpeeds` | review-required |  |
| prototype | `R_AnimateLight` | review-required |  |
| prototype | `R_LightPoint` | review-required |  |
| prototype | `R_SetupFrame` | review-required |  |
| prototype | `R_cshift_f` | review-required |  |
| prototype | `R_EmitEdge` | review-required |  |
| prototype | `R_ClipEdge` | review-required |  |
| prototype | `R_SplitEntityOnNode2` | review-required |  |
| prototype | `R_MarkLights` | review-required |  |

### `r_part.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `R_InitParticles` | review-required | `miniquake/particles.ml:R_InitParticles` |
| function | `R_DarkFieldParticles` | review-required | `miniquake/particles.ml:R_DarkFieldParticles` |
| function | `R_EntityParticles` | review-required | `miniquake/particles.ml:R_EntityParticles` |
| function | `R_ClearParticles` | review-required | `miniquake/particles.ml:R_ClearParticles` |
| function | `R_ReadPointFile_f` | review-required | `miniquake/particles.ml:R_ReadPointFile_f` |
| function | `R_ParseParticleEffect` | review-required | `miniquake/particles.ml:R_ParseParticleEffect` |
| function | `R_ParticleExplosion` | review-required | `miniquake/particles.ml:R_ParticleExplosion` |
| function | `R_ParticleExplosion2` | review-required | `miniquake/particles.ml:R_ParticleExplosion2` |
| function | `R_BlobExplosion` | review-required | `miniquake/particles.ml:R_BlobExplosion`, `miniquake/particles.ml:blobExplosion` |
| function | `R_RunParticleEffect` | review-required | `miniquake/particles.ml:R_RunParticleEffect` |
| function | `R_LavaSplash` | review-required | `miniquake/particles.ml:R_LavaSplash`, `miniquake/particles.ml:lavaSplash` |
| function | `R_TeleportSplash` | review-required | `miniquake/particles.ml:R_TeleportSplash`, `miniquake/particles.ml:teleportSplash` |
| function | `R_RocketTrail` | review-required | `miniquake/particles.ml:R_RocketTrail` |
| function | `R_DrawParticles` | review-required | `miniquake/particles.ml:R_DrawParticles` |
| macro | `MAX_PARTICLES` | review-required |  |
| macro | `ABSOLUTE_MIN_PARTICLES` | review-required |  |
| macro | `NUMVERTEXNORMALS` | review-required |  |
| global | `particle_t *active_particles, *free_particles` | review-required |  |
| global | `particle_t *particles` | review-required |  |
| global | `int r_numparticles` | review-required |  |
| global | `vec3_t r_pright, r_pup, r_ppn` | review-required |  |
| global | `vec3_t avelocities[NUMVERTEXNORMALS]` | review-required |  |
| global | `float beamlength = 16` | review-required |  |
| global | `float partstep = 0.01` | review-required |  |
| global | `float timescale = 0.01` | review-required |  |
| global | `/* =============== R_DrawParticles =============== */ extern cvar_t sv_gravity` | review-required |  |

### `r_shared.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `espan_t` | review-required |  |
| field | `espan_t.int u, v, count` | review-required |  |
| field | `espan_t.struct espan_s *pnext` | review-required |  |
| type | `surf_t` | review-required |  |
| field | `surf_t.struct surf_s *next` | review-required |  |
| field | `surf_t.// active surface stack in r_edge.c struct surf_s *prev` | review-required |  |
| field | `surf_t.// used in r_edge.c for active surf stack struct espan_s *spans` | review-required |  |
| field | `surf_t.// pointer to linked list of spans to draw int key` | review-required |  |
| field | `surf_t.// sorting key (BSP order) int last_u` | review-required |  |
| field | `surf_t.// set during tracing int spanstate` | review-required |  |
| field | `surf_t.// 0 = not in span // 1 = in span // -1 = in inverted span (end before // start) int flags` | review-required |  |
| field | `surf_t.// currentface flags void *data` | review-required |  |
| field | `surf_t.// associated data like msurface_t entity_t *entity` | review-required |  |
| field | `surf_t.float nearzi` | review-required |  |
| field | `surf_t.// nearest 1/z on surface, for mipmapping qboolean insubmodel` | review-required |  |
| field | `surf_t.float d_ziorigin, d_zistepu, d_zistepv` | review-required |  |
| field | `surf_t.int pad[2]` | review-required |  |
| type | `edge_t` | review-required |  |
| field | `edge_t.fixed16_t u` | review-required |  |
| field | `edge_t.fixed16_t u_step` | review-required |  |
| field | `edge_t.struct edge_s *prev, *next` | review-required |  |
| field | `edge_t.unsigned short surfs[2]` | review-required |  |
| field | `edge_t.struct edge_s *nextremove` | review-required |  |
| field | `edge_t.float nearzi` | review-required |  |
| field | `edge_t.medge_t *owner` | review-required |  |
| macro | `_R_SHARED_H_` | review-required |  |
| macro | `MAXVERTS` | review-required |  |
| macro | `MAXWORKINGVERTS` | review-required |  |
| macro | `MAXHEIGHT` | review-required |  |
| macro | `MAXWIDTH` | review-required |  |
| macro | `MAXDIMENSION` | review-required |  |
| macro | `SIN_BUFFER_SIZE` | review-required |  |
| macro | `INFINITE_DISTANCE` | review-required |  |
| macro | `NUMSTACKEDGES` | review-required |  |
| macro | `MINEDGES` | review-required |  |
| macro | `NUMSTACKSURFACES` | review-required |  |
| macro | `MINSURFACES` | review-required |  |
| macro | `MAXSPANS` | review-required |  |
| macro | `ALIAS_LEFT_CLIP` | review-required |  |
| macro | `ALIAS_TOP_CLIP` | review-required |  |
| macro | `ALIAS_RIGHT_CLIP` | review-required |  |
| macro | `ALIAS_BOTTOM_CLIP` | review-required |  |
| macro | `ALIAS_Z_CLIP` | review-required |  |
| macro | `ALIAS_ONSEAM` | review-required |  |
| macro | `ALIAS_XY_CLIP_MASK` | review-required |  |
| global | `extern int cachewidth` | review-required |  |
| global | `extern pixel_t *cacheblock` | review-required |  |
| global | `extern int screenwidth` | review-required |  |
| global | `extern float pixelAspect` | review-required |  |
| global | `extern int r_drawnpolycount` | review-required |  |
| global | `extern cvar_t r_clearcolor` | review-required |  |
| global | `extern int sintable[SIN_BUFFER_SIZE]` | review-required |  |
| global | `extern int intsintable[SIN_BUFFER_SIZE]` | review-required |  |
| global | `extern vec3_t vup, base_vup` | review-required |  |
| global | `extern vec3_t vpn, base_vpn` | review-required |  |
| global | `extern vec3_t vright, base_vright` | review-required |  |
| global | `extern entity_t *currententity` | review-required |  |
| global | `espan_t` | review-required |  |
| global | `surf_t` | review-required |  |
| global | `extern surf_t *surfaces, *surface_p, *surf_max` | review-required |  |
| global | `// surfaces are generated in back to front order by the bsp, so if a surf // pointer is greater than another one, it should be drawn in front // surfaces[1] is the background, and is used as the active surface stack. // surfaces[0] is a dummy, because index 0 is used to indicate no surface // attached to an edge_t //=================================================================== extern vec3_t sxformaxis[4]` | review-required |  |
| global | `// s axis transformed into viewspace extern vec3_t txformaxis[4]` | review-required |  |
| global | `// t axis transformed into viewspac extern vec3_t modelorg, base_modelorg` | review-required |  |
| global | `extern float xcenter, ycenter` | review-required |  |
| global | `extern float xscale, yscale` | review-required |  |
| global | `extern float xscaleinv, yscaleinv` | review-required |  |
| global | `extern float xscaleshrink, yscaleshrink` | review-required |  |
| global | `extern int d_lightstylevalue[256]` | review-required |  |
| global | `extern int r_skymade` | review-required |  |
| global | `extern int ubasestep, errorterm, erroradjustup, erroradjustdown` | review-required |  |
| global | `edge_t` | review-required |  |
| prototype | `MAXWORKINGVERTS` | review-required |  |
| prototype | `TransformVector` | review-required |  |
| prototype | `SetUpForLineScan` | review-required |  |
| prototype | `R_MakeSky` | review-required |  |

### `render.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `efrag_t` | review-required |  |
| field | `efrag_t.struct mleaf_s *leaf` | review-required |  |
| field | `efrag_t.struct efrag_s *leafnext` | review-required |  |
| field | `efrag_t.struct entity_s *entity` | review-required |  |
| field | `efrag_t.struct efrag_s *entnext` | review-required |  |
| type | `entity_t` | review-required |  |
| field | `entity_t.qboolean forcelink` | review-required |  |
| field | `entity_t.// model changed int update_type` | review-required |  |
| field | `entity_t.entity_state_t baseline` | review-required |  |
| field | `entity_t.// to fill in defaults in updates double msgtime` | review-required |  |
| field | `entity_t.// time of last update vec3_t msg_origins[2]` | review-required |  |
| field | `entity_t.// last two updates (0 is newest) vec3_t origin` | review-required |  |
| field | `entity_t.vec3_t msg_angles[2]` | review-required |  |
| field | `entity_t.// last two updates (0 is newest) vec3_t angles` | review-required |  |
| field | `entity_t.struct model_s *model` | review-required |  |
| field | `entity_t.// NULL = no model struct efrag_s *efrag` | review-required |  |
| field | `entity_t.// linked list of efrags int frame` | review-required |  |
| field | `entity_t.float syncbase` | review-required |  |
| field | `entity_t.// for client-side animations byte *colormap` | review-required |  |
| field | `entity_t.int effects` | review-required |  |
| field | `entity_t.// light, particals, etc int skinnum` | review-required |  |
| field | `entity_t.// for Alias models int visframe` | review-required |  |
| field | `entity_t.// last frame this entity was // found in an active leaf int dlightframe` | review-required |  |
| field | `entity_t.// dynamic lighting int dlightbits` | review-required |  |
| field | `entity_t.// FIXME: could turn these into a union int trivial_accept` | review-required |  |
| field | `entity_t.struct mnode_s *topnode` | review-required |  |
| type | `refdef_t` | review-required |  |
| field | `refdef_t.vrect_t vrect` | review-required |  |
| field | `refdef_t.// subwindow in video for refresh // FIXME: not need vrect next field here? vrect_t aliasvrect` | review-required |  |
| field | `refdef_t.// scaled Alias version int vrectright, vrectbottom` | review-required |  |
| field | `refdef_t.// right & bottom screen coords int aliasvrectright, aliasvrectbottom` | review-required |  |
| field | `refdef_t.// scaled Alias versions float vrectrightedge` | review-required |  |
| field | `refdef_t.// rightmost right edge we care about, // for use in edge list float fvrectx, fvrecty` | review-required |  |
| field | `refdef_t.// for floating-point compares float fvrectx_adj, fvrecty_adj` | review-required |  |
| field | `refdef_t.// left and top edges, for clamping int vrect_x_adj_shift20` | review-required |  |
| field | `refdef_t.// (vrect.x + 0.5 - epsilon) << 20 int vrectright_adj_shift20` | review-required |  |
| field | `refdef_t.// (vrectright + 0.5 - epsilon) << 20 float fvrectright_adj, fvrectbottom_adj` | review-required |  |
| field | `refdef_t.// right and bottom edges, for clamping float fvrectright` | review-required |  |
| field | `refdef_t.// rightmost edge, for Alias clamping float fvrectbottom` | review-required |  |
| field | `refdef_t.// bottommost edge, for Alias clamping float horizontalFieldOfView` | review-required |  |
| field | `refdef_t.// at Z = 1.0, this many X is visible // 2.0 = 90 degrees float xOrigin` | review-required |  |
| field | `refdef_t.// should probably allways be 0.5 float yOrigin` | review-required |  |
| field | `refdef_t.// between be around 0.3 to 0.5 vec3_t vieworg` | review-required |  |
| field | `refdef_t.vec3_t viewangles` | review-required |  |
| field | `refdef_t.float fov_x, fov_y` | review-required |  |
| field | `refdef_t.int ambientlight` | review-required |  |
| macro | `MAXCLIPPLANES` | review-required |  |
| macro | `TOP_RANGE` | review-required |  |
| macro | `BOTTOM_RANGE` | review-required |  |
| global | `efrag_t` | review-required |  |
| global | `entity_t` | review-required |  |
| global | `refdef_t` | review-required |  |
| global | `// // refresh // extern int reinit_surfcache` | review-required |  |
| global | `extern refdef_t r_refdef` | review-required |  |
| global | `extern vec3_t r_origin, vpn, vright, vup` | review-required |  |
| global | `extern struct texture_s *r_notexture_mip` | review-required |  |
| global | `// // surface cache related // extern int reinit_surfcache` | review-required |  |
| global | `// if 1, surface cache is currently empty and extern qboolean r_cache_thrash` | review-required |  |
| prototype | `R_Init` | review-required |  |
| prototype | `R_InitTextures` | review-required |  |
| prototype | `R_InitEfrags` | review-required |  |
| prototype | `R_RenderView` | review-required |  |
| prototype | `R_ViewChanged` | review-required |  |
| prototype | `R_InitSky` | review-required |  |
| prototype | `R_AddEfrags` | review-required |  |
| prototype | `R_RemoveEfrags` | review-required |  |
| prototype | `R_NewMap` | review-required |  |
| prototype | `R_ParseParticleEffect` | review-required |  |
| prototype | `R_RunParticleEffect` | review-required |  |
| prototype | `R_RocketTrail` | review-required |  |
| prototype | `R_BlobExplosion` | review-required |  |
| prototype | `R_ParticleExplosion` | review-required |  |
| prototype | `R_ParticleExplosion2` | review-required |  |
| prototype | `R_LavaSplash` | review-required |  |
| prototype | `R_TeleportSplash` | review-required |  |
| prototype | `R_PushDlights` | review-required |  |
| prototype | `D_SurfaceCacheForRes` | review-required |  |
| prototype | `D_FlushCaches` | review-required |  |
| prototype | `D_DeleteSurfaceCache` | review-required |  |
| prototype | `D_InitCaches` | review-required |  |
| prototype | `R_SetVrect` | review-required |  |

### `sbar.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Sbar_ShowScores` | review-required |  |
| function | `Sbar_DontShowScores` | review-required |  |
| function | `Sbar_Changed` | review-required |  |
| function | `Sbar_Init` | review-required |  |
| function | `Sbar_DrawPic` | review-required |  |
| function | `Sbar_DrawTransPic` | review-required |  |
| function | `Sbar_DrawCharacter` | review-required |  |
| function | `Sbar_DrawString` | review-required |  |
| function | `Sbar_itoa` | review-required |  |
| function | `Sbar_DrawNum` | review-required |  |
| function | `Sbar_SortFrags` | review-required |  |
| function | `Sbar_ColorForMap` | review-required |  |
| function | `Sbar_UpdateScoreboard` | review-required |  |
| function | `Sbar_SoloScoreboard` | review-required |  |
| function | `Sbar_DrawScoreboard` | review-required |  |
| function | `Sbar_DrawInventory` | review-required |  |
| function | `Sbar_DrawFrags` | review-required |  |
| function | `Sbar_DrawFace` | review-required |  |
| function | `Sbar_Draw` | review-required |  |
| function | `Sbar_IntermissionNumber` | review-required |  |
| function | `Sbar_DeathmatchOverlay` | review-required |  |
| function | `Sbar_MiniDeathmatchOverlay` | review-required |  |
| function | `Sbar_IntermissionOverlay` | review-required |  |
| function | `Sbar_FinaleOverlay` | review-required |  |
| macro | `STAT_MINUS` | review-required |  |
| global | `// if >= vid.numpages, no update needed #define STAT_MINUS 10 // num frame for '-' stats digit qpic_t *sb_nums[2][11]` | review-required |  |
| global | `qpic_t *sb_colon, *sb_slash` | review-required |  |
| global | `qpic_t *sb_ibar` | review-required |  |
| global | `qpic_t *sb_sbar` | review-required |  |
| global | `qpic_t *sb_scorebar` | review-required |  |
| global | `qpic_t *sb_weapons[7][8]` | review-required |  |
| global | `// 0 is active, 1 is owned, 2-5 are flashes qpic_t *sb_ammo[4]` | review-required |  |
| global | `qpic_t *sb_sigil[4]` | review-required |  |
| global | `qpic_t *sb_armor[3]` | review-required |  |
| global | `qpic_t *sb_items[32]` | review-required |  |
| global | `qpic_t *sb_faces[7][2]` | review-required |  |
| global | `// 0 is gibbed, 1 is dead, 2-6 are alive // 0 is static, 1 is temporary animation qpic_t *sb_face_invis` | review-required |  |
| global | `qpic_t *sb_face_quad` | review-required |  |
| global | `qpic_t *sb_face_invuln` | review-required |  |
| global | `qpic_t *sb_face_invis_invuln` | review-required |  |
| global | `qboolean sb_showscores` | review-required |  |
| global | `int sb_lines` | review-required |  |
| global | `// scan lines to draw qpic_t *rsb_invbar[2]` | review-required |  |
| global | `qpic_t *rsb_weapons[5]` | review-required |  |
| global | `qpic_t *rsb_items[2]` | review-required |  |
| global | `qpic_t *rsb_ammo[3]` | review-required |  |
| global | `qpic_t *rsb_teambord` | review-required |  |
| global | `// PGM 01/19/97 - team color border //MED 01/04/97 added two more weapons + 3 alternates for grenade launcher qpic_t *hsb_weapons[7][5]` | review-required |  |
| global | `//MED 01/04/97 added hipnotic items array qpic_t *hsb_items[2]` | review-required |  |
| global | `//============================================================================= int fragsort[MAX_SCOREBOARD]` | review-required |  |
| global | `char scoreboardtext[MAX_SCOREBOARD][20]` | review-required |  |
| global | `int scoreboardtop[MAX_SCOREBOARD]` | review-required |  |
| global | `int scoreboardbottom[MAX_SCOREBOARD]` | review-required |  |
| global | `int scoreboardcount[MAX_SCOREBOARD]` | review-required |  |
| global | `int scoreboardlines` | review-required |  |
| prototype | `Sbar_MiniDeathmatchOverlay` | review-required |  |
| prototype | `Sbar_DeathmatchOverlay` | review-required |  |
| prototype | `M_DrawPic` | review-required |  |

### `sbar.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| macro | `SBAR_HEIGHT` | review-required |  |
| prototype | `Sbar_Init` | review-required |  |
| prototype | `Sbar_Changed` | review-required |  |
| prototype | `Sbar_Draw` | review-required |  |
| prototype | `Sbar_IntermissionOverlay` | review-required |  |
| prototype | `Sbar_FinaleOverlay` | review-required |  |

### `screen.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| global | `extern float scr_con_current` | review-required |  |
| global | `extern float scr_conlines` | review-required |  |
| global | `// lines of console to display extern int scr_fullupdate` | review-required |  |
| global | `// set to 0 to force full redraw extern int sb_lines` | review-required |  |
| global | `extern int clearnotify` | review-required |  |
| global | `// set to 0 whenever notify text is drawn extern qboolean scr_disabled_for_loading` | review-required |  |
| global | `extern qboolean scr_skipupdate` | review-required |  |
| global | `extern cvar_t scr_viewsize` | review-required |  |
| global | `extern cvar_t scr_viewsize` | review-required |  |
| global | `// only the refresh window will be updated unless these variables are flagged extern int scr_copytop` | review-required |  |
| global | `extern int scr_copyeverything` | review-required |  |
| global | `extern qboolean block_drawing` | review-required |  |
| prototype | `SCR_Init` | review-required |  |
| prototype | `SCR_UpdateScreen` | review-required |  |
| prototype | `SCR_SizeUp` | review-required |  |
| prototype | `SCR_SizeDown` | review-required |  |
| prototype | `SCR_BringDownConsole` | review-required |  |
| prototype | `SCR_CenterPrint` | review-required |  |
| prototype | `SCR_BeginLoadingPlaque` | review-required |  |
| prototype | `SCR_EndLoadingPlaque` | review-required |  |
| prototype | `SCR_ModalMessage` | review-required |  |
| prototype | `SCR_UpdateWholeScreen` | review-required |  |

### `server.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `server_static_t` | review-required |  |
| field | `server_static_t.int maxclients` | review-required |  |
| field | `server_static_t.int maxclientslimit` | review-required |  |
| field | `server_static_t.struct client_s *clients` | review-required |  |
| field | `server_static_t.// [maxclients] int serverflags` | review-required |  |
| field | `server_static_t.// episode completion information qboolean changelevel_issued` | review-required |  |
| type | `server_state_t` | review-required |  |
| enum-value | `server_state_t.ss_loading` | review-required |  |
| enum-value | `server_state_t.ss_active` | review-required |  |
| type | `server_t` | review-required |  |
| field | `server_t.qboolean active` | review-required |  |
| field | `server_t.// false if only a net client qboolean paused` | review-required |  |
| field | `server_t.qboolean loadgame` | review-required |  |
| field | `server_t.// handle connections specially double time` | review-required |  |
| field | `server_t.int lastcheck` | review-required |  |
| field | `server_t.// used by PF_checkclient double lastchecktime` | review-required |  |
| field | `server_t.char name[64]` | review-required |  |
| field | `server_t.// map name #ifdef QUAKE2 char startspot[64]` | review-required |  |
| field | `server_t.// maps/<name>.bsp, for model_precache[0] struct model_s *worldmodel` | review-required |  |
| field | `server_t.char *model_precache[MAX_MODELS]` | review-required |  |
| field | `server_t.// NULL terminated struct model_s *models[MAX_MODELS]` | review-required |  |
| field | `server_t.char *sound_precache[MAX_SOUNDS]` | review-required |  |
| field | `server_t.// NULL terminated char *lightstyles[MAX_LIGHTSTYLES]` | review-required |  |
| field | `server_t.int num_edicts` | review-required |  |
| field | `server_t.int max_edicts` | review-required |  |
| field | `server_t.edict_t *edicts` | review-required |  |
| field | `server_t.// can NOT be array indexed, because // edict_t is variable sized, but can // be used to reference the world ent server_state_t state` | review-required |  |
| field | `server_t.// some actions are only valid during load sizebuf_t datagram` | review-required |  |
| field | `server_t.byte datagram_buf[MAX_DATAGRAM]` | review-required |  |
| field | `server_t.sizebuf_t reliable_datagram` | review-required |  |
| field | `server_t.// copied to all clients at end of frame byte reliable_datagram_buf[MAX_DATAGRAM]` | review-required |  |
| field | `server_t.sizebuf_t signon` | review-required |  |
| field | `server_t.byte signon_buf[8192]` | review-required |  |
| type | `client_t` | review-required |  |
| field | `client_t.qboolean active` | review-required |  |
| field | `client_t.// false = client is free qboolean spawned` | review-required |  |
| field | `client_t.// false = don't send datagrams qboolean dropasap` | review-required |  |
| field | `client_t.// has been told to go to another level qboolean privileged` | review-required |  |
| field | `client_t.// can execute any host command qboolean sendsignon` | review-required |  |
| field | `client_t.// only valid before spawned double last_message` | review-required |  |
| field | `client_t.// reliable messages must be sent // periodically struct qsocket_s *netconnection` | review-required |  |
| field | `client_t.// communications handle usercmd_t cmd` | review-required |  |
| field | `client_t.// movement vec3_t wishdir` | review-required |  |
| field | `client_t.// intended motion calced from cmd sizebuf_t message` | review-required |  |
| field | `client_t.// can be added to at any time, // copied and clear once per frame byte msgbuf[MAX_MSGLEN]` | review-required |  |
| field | `client_t.edict_t *edict` | review-required |  |
| field | `client_t.// EDICT_NUM(clientnum+1) char name[32]` | review-required |  |
| field | `client_t.// for printing to other people int colors` | review-required |  |
| field | `client_t.float ping_times[NUM_PING_TIMES]` | review-required |  |
| field | `client_t.int num_pings` | review-required |  |
| field | `client_t.// ping_times[num_pings%NUM_PING_TIMES] // spawn parms are carried from level to level float spawn_parms[NUM_SPAWN_PARMS]` | review-required |  |
| field | `client_t.// client known data for deltas int old_frags` | review-required |  |
| macro | `NUM_PING_TIMES` | review-required |  |
| macro | `NUM_SPAWN_PARMS` | review-required |  |
| macro | `MOVETYPE_NONE` | review-required |  |
| macro | `MOVETYPE_ANGLENOCLIP` | review-required |  |
| macro | `MOVETYPE_ANGLECLIP` | review-required |  |
| macro | `MOVETYPE_WALK` | review-required |  |
| macro | `MOVETYPE_STEP` | review-required |  |
| macro | `MOVETYPE_FLY` | review-required |  |
| macro | `MOVETYPE_TOSS` | review-required |  |
| macro | `MOVETYPE_PUSH` | review-required |  |
| macro | `MOVETYPE_NOCLIP` | review-required |  |
| macro | `MOVETYPE_FLYMISSILE` | review-required |  |
| macro | `MOVETYPE_BOUNCE` | review-required |  |
| macro | `MOVETYPE_BOUNCEMISSILE` | review-required |  |
| macro | `MOVETYPE_FOLLOW` | review-required |  |
| macro | `SOLID_NOT` | review-required |  |
| macro | `SOLID_TRIGGER` | review-required |  |
| macro | `SOLID_BBOX` | review-required |  |
| macro | `SOLID_SLIDEBOX` | review-required |  |
| macro | `SOLID_BSP` | review-required |  |
| macro | `DEAD_NO` | review-required |  |
| macro | `DEAD_DYING` | review-required |  |
| macro | `DEAD_DEAD` | review-required |  |
| macro | `DAMAGE_NO` | review-required |  |
| macro | `DAMAGE_YES` | review-required |  |
| macro | `DAMAGE_AIM` | review-required |  |
| macro | `FL_FLY` | review-required |  |
| macro | `FL_SWIM` | review-required |  |
| macro | `FL_CONVEYOR` | review-required |  |
| macro | `FL_CLIENT` | review-required |  |
| macro | `FL_INWATER` | review-required |  |
| macro | `FL_MONSTER` | review-required |  |
| macro | `FL_GODMODE` | review-required |  |
| macro | `FL_NOTARGET` | review-required |  |
| macro | `FL_ITEM` | review-required |  |
| macro | `FL_ONGROUND` | review-required |  |
| macro | `FL_PARTIALGROUND` | review-required |  |
| macro | `FL_WATERJUMP` | review-required |  |
| macro | `FL_JUMPRELEASED` | review-required |  |
| macro | `FL_FLASHLIGHT` | review-required |  |
| macro | `FL_ARCHIVE_OVERRIDE` | review-required |  |
| macro | `EF_BRIGHTFIELD` | review-required |  |
| macro | `EF_MUZZLEFLASH` | review-required |  |
| macro | `EF_BRIGHTLIGHT` | review-required |  |
| macro | `EF_DIMLIGHT` | review-required |  |
| macro | `EF_DARKLIGHT` | review-required |  |
| macro | `EF_DARKFIELD` | review-required |  |
| macro | `EF_LIGHT` | review-required |  |
| macro | `EF_NODRAW` | review-required |  |
| macro | `SPAWNFLAG_NOT_EASY` | review-required |  |
| macro | `SPAWNFLAG_NOT_MEDIUM` | review-required |  |
| macro | `SPAWNFLAG_NOT_HARD` | review-required |  |
| macro | `SPAWNFLAG_NOT_DEATHMATCH` | review-required |  |
| macro | `SFL_EPISODE_1` | review-required |  |
| macro | `SFL_EPISODE_2` | review-required |  |
| macro | `SFL_EPISODE_3` | review-required |  |
| macro | `SFL_EPISODE_4` | review-required |  |
| macro | `SFL_NEW_UNIT` | review-required |  |
| macro | `SFL_NEW_EPISODE` | review-required |  |
| macro | `SFL_CROSS_TRIGGERS` | review-required |  |
| global | `server_static_t` | review-required |  |
| global | `server_state_t` | review-required |  |
| global | `server_t` | review-required |  |
| global | `client_t` | review-required |  |
| global | `//============================================================================= // edict->movetype values #define MOVETYPE_NONE 0 // never moves #define MOVETYPE_ANGLENOCLIP 1 #define MOVETYPE_ANGLECLIP 2 #define MOVETYPE_WALK 3 // gravity #define MOVETYPE_STEP 4 // gravity, special edge handling #define MOVETYPE_FLY 5 #define MOVETYPE_TOSS 6 // gravity #define MOVETYPE_PUSH 7 // no clip to world, push and crush #define MOVETYPE_NOCLIP 8 #define MOVETYPE_FLYMISSILE 9 // extra size to monsters #define MOVETYPE_BOUNCE 10 #ifdef QUAKE2 #define MOVETYPE_BOUNCEMISSILE 11 // bounce w/o gravity #define MOVETYPE_FOLLOW 12 // track movement of aiment #endif // edict->solid values #define SOLID_NOT 0 // no interaction with other objects #define SOLID_TRIGGER 1 // touch on edge, but not blocking #define SOLID_BBOX 2 // touch on edge, block #define SOLID_SLIDEBOX 3 // touch on edge, but not an onground #define SOLID_BSP 4 // bsp clip, touch on edge, block // edict->deadflag values #define DEAD_NO 0 #define DEAD_DYING 1 #define DEAD_DEAD 2 #define DAMAGE_NO 0 #define DAMAGE_YES 1 #define DAMAGE_AIM 2 // edict->flags #define FL_FLY 1 #define FL_SWIM 2 //#define FL_GLIMPSE 4 #define FL_CONVEYOR 4 #define FL_CLIENT 8 #define FL_INWATER 16 #define FL_MONSTER 32 #define FL_GODMODE 64 #define FL_NOTARGET 128 #define FL_ITEM 256 #define FL_ONGROUND 512 #define FL_PARTIALGROUND 1024 // not all corners are valid #define FL_WATERJUMP 2048 // player jumping out of water #define FL_JUMPRELEASED 4096 // for jump debouncing #ifdef QUAKE2 #define FL_FLASHLIGHT 8192 #define FL_ARCHIVE_OVERRIDE 1048576 #endif // entity effects #define EF_BRIGHTFIELD 1 #define EF_MUZZLEFLASH 2 #define EF_BRIGHTLIGHT 4 #define EF_DIMLIGHT 8 #ifdef QUAKE2 #define EF_DARKLIGHT 16 #define EF_DARKFIELD 32 #define EF_LIGHT 64 #define EF_NODRAW 128 #endif #define SPAWNFLAG_NOT_EASY 256 #define SPAWNFLAG_NOT_MEDIUM 512 #define SPAWNFLAG_NOT_HARD 1024 #define SPAWNFLAG_NOT_DEATHMATCH 2048 #ifdef QUAKE2 // server flags #define SFL_EPISODE_1 1 #define SFL_EPISODE_2 2 #define SFL_EPISODE_3 4 #define SFL_EPISODE_4 8 #define SFL_NEW_UNIT 16 #define SFL_NEW_EPISODE 32 #define SFL_CROSS_TRIGGERS 65280 #endif //============================================================================ extern cvar_t teamplay` | review-required |  |
| global | `extern cvar_t skill` | review-required |  |
| global | `extern cvar_t deathmatch` | review-required |  |
| global | `extern cvar_t coop` | review-required |  |
| global | `extern cvar_t fraglimit` | review-required |  |
| global | `extern cvar_t timelimit` | review-required |  |
| global | `extern server_static_t svs` | review-required |  |
| global | `// persistant server info extern server_t sv` | review-required |  |
| global | `// local server extern client_t *host_client` | review-required |  |
| global | `extern jmp_buf host_abortserver` | review-required |  |
| global | `extern double host_time` | review-required |  |
| global | `extern edict_t *sv_player` | review-required |  |
| prototype | `SV_Init` | review-required |  |
| prototype | `SV_StartParticle` | review-required |  |
| prototype | `SV_StartSound` | review-required |  |
| prototype | `SV_DropClient` | review-required |  |
| prototype | `SV_SendClientMessages` | review-required |  |
| prototype | `SV_ClearDatagram` | review-required |  |
| prototype | `SV_ModelIndex` | review-required |  |
| prototype | `SV_SetIdealPitch` | review-required |  |
| prototype | `SV_AddUpdates` | review-required |  |
| prototype | `SV_ClientThink` | review-required |  |
| prototype | `SV_AddClientToServer` | review-required |  |
| prototype | `SV_ClientPrintf` | review-required |  |
| prototype | `SV_BroadcastPrintf` | review-required |  |
| prototype | `SV_Physics` | review-required |  |
| prototype | `SV_CheckBottom` | review-required |  |
| prototype | `SV_movestep` | review-required |  |
| prototype | `SV_WriteClientdataToMessage` | review-required |  |
| prototype | `SV_MoveToGoal` | review-required |  |
| prototype | `SV_CheckForNewClients` | review-required |  |
| prototype | `SV_RunClients` | review-required |  |
| prototype | `SV_SaveSpawnparms` | review-required |  |

### `snd_dma.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `S_AmbientOff` | review-required | `miniquake/sound/mixer.ml:S_AmbientOff` |
| function | `S_AmbientOn` | review-required | `miniquake/sound/mixer.ml:S_AmbientOn` |
| function | `S_SoundInfo_f` | review-required | `miniquake/sound/mixer.ml:S_SoundInfo_f` |
| function | `S_Startup` | review-required | `miniquake/sound/mixer.ml:S_Startup` |
| function | `S_Init` | review-required | `miniquake/sound/mixer.ml:S_Init` |
| function | `S_Shutdown` | review-required | `miniquake/sound/mixer.ml:S_Shutdown` |
| function | `S_FindName` | review-required | `miniquake/sound/mixer.ml:S_FindName` |
| function | `S_TouchSound` | review-required | `miniquake/sound/mixer.ml:S_TouchSound` |
| function | `S_PrecacheSound` | review-required | `miniquake/sound/mixer.ml:S_PrecacheSound` |
| function | `SND_PickChannel` | review-required | `miniquake/sound/mixer.ml:SND_PickChannel` |
| function | `SND_Spatialize` | review-required | `miniquake/sound/mixer.ml:SND_Spatialize` |
| function | `S_StartSound` | review-required | `miniquake/sound/mixer.ml:S_StartSound`, `miniquake/sound/mixer.ml:startSound` |
| function | `S_StopSound` | review-required | `miniquake/sound/mixer.ml:S_StopSound`, `miniquake/sound/mixer.ml:stopSound` |
| function | `S_StopAllSounds` | review-required | `miniquake/sound/mixer.ml:S_StopAllSounds` |
| function | `S_StopAllSoundsC` | review-required | `miniquake/sound/mixer.ml:S_StopAllSoundsC` |
| function | `S_ClearBuffer` | review-required | `miniquake/sound/mixer.ml:S_ClearBuffer` |
| function | `S_StaticSound` | review-required | `miniquake/sound/mixer.ml:S_StaticSound`, `miniquake/sound/mixer.ml:staticSound` |
| function | `S_UpdateAmbientSounds` | review-required | `miniquake/sound/mixer.ml:S_UpdateAmbientSounds` |
| function | `S_Update` | review-required | `miniquake/sound/mixer.ml:S_Update`, `miniquake/sound/mixer.ml:update`, `miniquake/sound/mixer.ml:S_Update_` |
| function | `GetSoundtime` | review-required | `miniquake/sound/mixer.ml:GetSoundtime` |
| function | `S_ExtraUpdate` | review-required | `miniquake/sound/mixer.ml:S_ExtraUpdate` |
| function | `S_Update_` | review-required | `miniquake/sound/mixer.ml:S_Update_`, `miniquake/sound/mixer.ml:update`, `miniquake/sound/mixer.ml:S_Update` |
| function | `S_Play` | review-required | `miniquake/sound/mixer.ml:S_Play` |
| function | `S_PlayVol` | review-required | `miniquake/sound/mixer.ml:S_PlayVol` |
| function | `S_SoundList` | review-required | `miniquake/sound/mixer.ml:S_SoundList` |
| function | `S_LocalSound` | review-required | `miniquake/sound/mixer.ml:S_LocalSound`, `miniquake/sound/mixer.ml:localSound` |
| function | `S_ClearPrecache` | review-required | `miniquake/sound/mixer.ml:S_ClearPrecache` |
| function | `S_BeginPrecaching` | review-required | `miniquake/sound/mixer.ml:S_BeginPrecaching` |
| function | `S_EndPrecaching` | review-required | `miniquake/sound/mixer.ml:S_EndPrecaching` |
| macro | `MAX_SFX` | review-required |  |
| global | `// ======================================================================= // Internal sound data & structures // ======================================================================= channel_t channels[MAX_CHANNELS]` | review-required |  |
| global | `int total_channels` | review-required |  |
| global | `int snd_blocked = 0` | review-required |  |
| global | `static qboolean snd_ambient = 1` | review-required |  |
| global | `qboolean snd_initialized = false` | review-required |  |
| global | `// pointer should go away volatile dma_t *shm = 0` | review-required |  |
| global | `volatile dma_t sn` | review-required |  |
| global | `vec3_t listener_origin` | review-required |  |
| global | `vec3_t listener_forward` | review-required |  |
| global | `vec3_t listener_right` | review-required |  |
| global | `vec3_t listener_up` | review-required |  |
| global | `vec_t sound_nominal_clip_dist=1000.0` | review-required |  |
| global | `int soundtime` | review-required |  |
| global | `// sample PAIRS int paintedtime` | review-required |  |
| global | `// sample PAIRS #define MAX_SFX 512 sfx_t *known_sfx` | review-required |  |
| global | `// hunk allocated [MAX_SFX] int num_sfx` | review-required |  |
| global | `sfx_t *ambient_sfx[NUM_AMBIENTS]` | review-required |  |
| global | `int desired_speed = 11025` | review-required |  |
| global | `int desired_bits = 16` | review-required |  |
| global | `int sound_started=0` | review-required |  |
| global | `int fakedma_updates = 15` | review-required |  |
| prototype | `S_Play` | review-required | `miniquake/sound/mixer.ml:S_Play` |
| prototype | `S_PlayVol` | review-required | `miniquake/sound/mixer.ml:S_PlayVol` |
| prototype | `S_SoundList` | review-required | `miniquake/sound/mixer.ml:S_SoundList` |
| prototype | `S_Update_` | review-required | `miniquake/sound/mixer.ml:S_Update_`, `miniquake/sound/mixer.ml:update`, `miniquake/sound/mixer.ml:S_Update` |
| prototype | `S_StopAllSounds` | review-required | `miniquake/sound/mixer.ml:S_StopAllSounds` |
| prototype | `S_StopAllSoundsC` | review-required | `miniquake/sound/mixer.ml:S_StopAllSoundsC` |

### `snd_mem.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `ResampleSfx` | review-required | `miniquake/sound/wav.ml:ResampleSfx` |
| function | `S_LoadSound` | review-required | `miniquake/sound/wav.ml:S_LoadSound` |
| function | `GetLittleShort` | review-required | `miniquake/sound/wav.ml:GetLittleShort` |
| function | `GetLittleLong` | review-required | `miniquake/sound/wav.ml:GetLittleLong` |
| function | `FindNextChunk` | review-required | `miniquake/sound/wav.ml:FindNextChunk` |
| function | `FindChunk` | review-required | `miniquake/sound/wav.ml:FindChunk` |
| function | `DumpChunks` | review-required | `miniquake/sound/wav.ml:DumpChunks` |
| function | `GetWavinfo` | review-required | `miniquake/sound/wav.ml:GetWavinfo` |
| global | `/* =============================================================================== WAV loading =============================================================================== */ byte *data_p` | review-required |  |
| global | `byte *iff_end` | review-required |  |
| global | `byte *last_chunk` | review-required |  |
| global | `byte *iff_data` | review-required |  |
| global | `int iff_chunk_len` | review-required |  |
| prototype | `S_Alloc` | review-required |  |

### `snd_mix.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Snd_WriteLinearBlastStereo16` | review-required | `miniquake/sound/mixer.ml:Snd_WriteLinearBlastStereo16` |
| function | `S_TransferStereo16` | review-required | `miniquake/sound/mixer.ml:S_TransferStereo16` |
| function | `S_TransferPaintBuffer` | review-required | `miniquake/sound/mixer.ml:S_TransferPaintBuffer` |
| function | `S_PaintChannels` | review-required | `miniquake/sound/mixer.ml:S_PaintChannels` |
| function | `SND_InitScaletable` | review-required | `miniquake/sound/mixer.ml:SND_InitScaletable` |
| function | `SND_PaintChannelFrom8` | review-required | `miniquake/sound/mixer.ml:SND_PaintChannelFrom8` |
| function | `SND_PaintChannelFrom16` | review-required | `miniquake/sound/mixer.ml:SND_PaintChannelFrom16` |
| macro | `DWORD` | review-required |  |
| macro | `PAINTBUFFER_SIZE` | review-required |  |
| global | `int snd_scaletable[32][256]` | review-required |  |
| global | `int *snd_p, snd_linear_count, snd_vol` | review-required |  |
| global | `short *snd_out` | review-required |  |
| prototype | `Snd_WriteLinearBlastStereo16` | review-required | `miniquake/sound/mixer.ml:Snd_WriteLinearBlastStereo16` |
| prototype | `SND_PaintChannelFrom8` | review-required | `miniquake/sound/mixer.ml:SND_PaintChannelFrom8` |
| prototype | `SND_PaintChannelFrom16` | review-required | `miniquake/sound/mixer.ml:SND_PaintChannelFrom16` |

### `snd_win.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `S_BlockSound` | review-required |  |
| function | `S_UnblockSound` | review-required |  |
| function | `FreeSound` | review-required |  |
| function | `SNDDMA_InitDirect` | review-required |  |
| function | `SNDDMA_InitWav` | review-required |  |
| function | `SNDDMA_Init` | review-required |  |
| function | `SNDDMA_GetDMAPos` | review-required |  |
| function | `SNDDMA_Submit` | review-required |  |
| function | `SNDDMA_Shutdown` | review-required |  |
| type | `sndinitstat` | review-required |  |
| enum-value | `sndinitstat.SIS_SUCCESS` | review-required |  |
| enum-value | `sndinitstat.SIS_FAILURE` | review-required |  |
| enum-value | `sndinitstat.SIS_NOTAVAIL` | review-required |  |
| macro | `iDirectSoundCreate` | review-required |  |
| macro | `WAV_BUFFERS` | review-required |  |
| macro | `WAV_MASK` | review-required |  |
| macro | `WAV_BUFFER_SIZE` | review-required |  |
| macro | `SECONDARY_BUFFER_SIZE` | review-required |  |
| global | `sndinitstat` | review-required |  |
| global | `static qboolean wavonly` | review-required |  |
| global | `static qboolean dsound_init` | review-required |  |
| global | `static qboolean wav_init` | review-required |  |
| global | `static qboolean snd_firsttime = true, snd_isdirect, snd_iswave` | review-required |  |
| global | `static qboolean primary_format_set` | review-required |  |
| global | `static int sample16` | review-required |  |
| global | `static int snd_sent, snd_completed` | review-required |  |
| global | `/* * Global variables. Must be visible to window-procedure function * so it can unlock and free the data block after it has been played. */ HANDLE hData` | review-required |  |
| global | `HPSTR lpData, lpData2` | review-required |  |
| global | `HGLOBAL hWaveHdr` | review-required |  |
| global | `LPWAVEHDR lpWaveHdr` | review-required |  |
| global | `HWAVEOUT hWaveOut` | review-required |  |
| global | `WAVEOUTCAPS wavecaps` | review-required |  |
| global | `DWORD gSndBufSize` | review-required |  |
| global | `MMTIME mmstarttime` | review-required |  |
| global | `LPDIRECTSOUND pDS` | review-required |  |
| global | `LPDIRECTSOUNDBUFFER pDSBuf, pDSPBuf` | review-required |  |
| global | `HINSTANCE hInstDS` | review-required |  |
| prototype | `iDirectSoundCreate` | review-required |  |
| prototype | `SNDDMA_InitDirect` | review-required |  |
| prototype | `SNDDMA_InitWav` | review-required |  |

### `sound.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `portable_samplepair_t` | review-required |  |
| field | `portable_samplepair_t.int left` | review-required |  |
| field | `portable_samplepair_t.int right` | review-required |  |
| type | `sfx_t` | review-required |  |
| field | `sfx_t.char name[MAX_QPATH]` | review-required |  |
| field | `sfx_t.cache_user_t cache` | review-required |  |
| type | `sfxcache_t` | review-required |  |
| field | `sfxcache_t.int length` | review-required |  |
| field | `sfxcache_t.int loopstart` | review-required |  |
| field | `sfxcache_t.int speed` | review-required |  |
| field | `sfxcache_t.int width` | review-required |  |
| field | `sfxcache_t.int stereo` | review-required |  |
| field | `sfxcache_t.byte data[1]` | review-required |  |
| type | `dma_t` | review-required |  |
| field | `dma_t.qboolean gamealive` | review-required |  |
| field | `dma_t.qboolean soundalive` | review-required |  |
| field | `dma_t.qboolean splitbuffer` | review-required |  |
| field | `dma_t.int channels` | review-required |  |
| field | `dma_t.int samples` | review-required |  |
| field | `dma_t.// mono samples in buffer int submission_chunk` | review-required |  |
| field | `dma_t.// don't mix less than this # int samplepos` | review-required |  |
| field | `dma_t.// in mono samples int samplebits` | review-required |  |
| field | `dma_t.int speed` | review-required |  |
| field | `dma_t.unsigned char *buffer` | review-required |  |
| type | `channel_t` | review-required |  |
| field | `channel_t.sfx_t *sfx` | review-required |  |
| field | `channel_t.// sfx number int leftvol` | review-required |  |
| field | `channel_t.// 0-255 volume int rightvol` | review-required |  |
| field | `channel_t.// 0-255 volume int end` | review-required |  |
| field | `channel_t.// end time in global paintsamples int pos` | review-required |  |
| field | `channel_t.// sample position in sfx int looping` | review-required |  |
| field | `channel_t.// where to loop, -1 = no looping int entnum` | review-required |  |
| field | `channel_t.// to allow overriding a specific sound int entchannel` | review-required |  |
| field | `channel_t.// vec3_t origin` | review-required |  |
| field | `channel_t.// origin of sound effect vec_t dist_mult` | review-required |  |
| field | `channel_t.// distance multiplier (attenuation/clipK) int master_vol` | review-required |  |
| type | `wavinfo_t` | review-required |  |
| field | `wavinfo_t.int rate` | review-required |  |
| field | `wavinfo_t.int width` | review-required |  |
| field | `wavinfo_t.int channels` | review-required |  |
| field | `wavinfo_t.int loopstart` | review-required |  |
| field | `wavinfo_t.int samples` | review-required |  |
| field | `wavinfo_t.int dataofs` | review-required |  |
| macro | `__SOUND__` | review-required |  |
| macro | `DEFAULT_SOUND_PACKET_VOLUME` | review-required |  |
| macro | `DEFAULT_SOUND_PACKET_ATTENUATION` | review-required |  |
| macro | `MAX_CHANNELS` | review-required |  |
| macro | `MAX_DYNAMIC_CHANNELS` | review-required |  |
| global | `portable_samplepair_t` | review-required |  |
| global | `sfx_t` | review-required |  |
| global | `sfxcache_t` | review-required |  |
| global | `dma_t` | review-required |  |
| global | `channel_t` | review-required |  |
| global | `wavinfo_t` | review-required |  |
| global | `// ==================================================================== // User-setable variables // ==================================================================== #define MAX_CHANNELS 128 #define MAX_DYNAMIC_CHANNELS 8 extern channel_t channels[MAX_CHANNELS]` | review-required |  |
| global | `// 0 to MAX_DYNAMIC_CHANNELS-1 = normal entity sounds // MAX_DYNAMIC_CHANNELS to MAX_DYNAMIC_CHANNELS + NUM_AMBIENTS -1 = water, etc // MAX_DYNAMIC_CHANNELS + NUM_AMBIENTS to total_channels = static sounds extern int total_channels` | review-required |  |
| global | `extern int fakedma_updates` | review-required |  |
| global | `extern int paintedtime` | review-required |  |
| global | `extern vec3_t listener_origin` | review-required |  |
| global | `extern vec3_t listener_forward` | review-required |  |
| global | `extern vec3_t listener_right` | review-required |  |
| global | `extern vec3_t listener_up` | review-required |  |
| global | `extern volatile dma_t *shm` | review-required |  |
| global | `extern volatile dma_t sn` | review-required |  |
| global | `extern vec_t sound_nominal_clip_dist` | review-required |  |
| global | `extern cvar_t loadas8bit` | review-required |  |
| global | `extern cvar_t bgmvolume` | review-required |  |
| global | `extern cvar_t volume` | review-required |  |
| global | `extern qboolean snd_initialized` | review-required |  |
| global | `extern int snd_blocked` | review-required |  |
| prototype | `S_Init` | review-required |  |
| prototype | `S_Startup` | review-required |  |
| prototype | `S_Shutdown` | review-required |  |
| prototype | `S_StartSound` | review-required |  |
| prototype | `S_StaticSound` | review-required |  |
| prototype | `S_StopSound` | review-required |  |
| prototype | `S_StopAllSounds` | review-required |  |
| prototype | `S_ClearBuffer` | review-required |  |
| prototype | `S_Update` | review-required |  |
| prototype | `S_ExtraUpdate` | review-required |  |
| prototype | `S_PrecacheSound` | review-required |  |
| prototype | `S_TouchSound` | review-required |  |
| prototype | `S_ClearPrecache` | review-required |  |
| prototype | `S_BeginPrecaching` | review-required |  |
| prototype | `S_EndPrecaching` | review-required |  |
| prototype | `S_PaintChannels` | review-required |  |
| prototype | `S_InitPaintChannels` | review-required |  |
| prototype | `SND_PickChannel` | review-required |  |
| prototype | `SND_Spatialize` | review-required |  |
| prototype | `SNDDMA_Init` | review-required |  |
| prototype | `SNDDMA_GetDMAPos` | review-required |  |
| prototype | `SNDDMA_Shutdown` | review-required |  |
| prototype | `S_LocalSound` | review-required |  |
| prototype | `S_LoadSound` | review-required |  |
| prototype | `GetWavinfo` | review-required |  |
| prototype | `SND_InitScaletable` | review-required |  |
| prototype | `SNDDMA_Submit` | review-required |  |
| prototype | `S_AmbientOff` | review-required |  |
| prototype | `S_AmbientOn` | review-required |  |

### `spritegn.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `synctype_t` | review-required |  |
| enum-value | `synctype_t.ST_SYNC=0` | review-required |  |
| enum-value | `synctype_t.ST_RAND` | review-required |  |
| type | `dsprite_t` | review-required |  |
| field | `dsprite_t.int ident` | review-required |  |
| field | `dsprite_t.int version` | review-required |  |
| field | `dsprite_t.int type` | review-required |  |
| field | `dsprite_t.float boundingradius` | review-required |  |
| field | `dsprite_t.int width` | review-required |  |
| field | `dsprite_t.int height` | review-required |  |
| field | `dsprite_t.int numframes` | review-required |  |
| field | `dsprite_t.float beamlength` | review-required |  |
| field | `dsprite_t.synctype_t synctype` | review-required |  |
| type | `dspriteframe_t` | review-required |  |
| field | `dspriteframe_t.int origin[2]` | review-required |  |
| field | `dspriteframe_t.int width` | review-required |  |
| field | `dspriteframe_t.int height` | review-required |  |
| type | `dspritegroup_t` | review-required |  |
| field | `dspritegroup_t.int numframes` | review-required |  |
| type | `dspriteinterval_t` | review-required |  |
| field | `dspriteinterval_t.float interval` | review-required |  |
| type | `spriteframetype_t` | review-required |  |
| enum-value | `spriteframetype_t.SPR_SINGLE=0` | review-required |  |
| enum-value | `spriteframetype_t.SPR_GROUP` | review-required |  |
| type | `dspriteframetype_t` | review-required |  |
| field | `dspriteframetype_t.spriteframetype_t type` | review-required |  |
| macro | `SPRITE_VERSION` | review-required |  |
| macro | `SYNCTYPE_T` | review-required |  |
| macro | `SPR_VP_PARALLEL_UPRIGHT` | review-required |  |
| macro | `SPR_FACING_UPRIGHT` | review-required |  |
| macro | `SPR_VP_PARALLEL` | review-required |  |
| macro | `SPR_ORIENTED` | review-required |  |
| macro | `SPR_VP_PARALLEL_ORIENTED` | review-required |  |
| macro | `IDSPRITEHEADER` | review-required |  |
| global | `synctype_t` | review-required |  |
| global | `dsprite_t` | review-required |  |
| global | `dspriteframe_t` | review-required |  |
| global | `dspritegroup_t` | review-required |  |
| global | `dspriteinterval_t` | review-required |  |
| global | `spriteframetype_t` | review-required |  |
| global | `dspriteframetype_t` | review-required |  |

### `sv_main.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SV_Init` | review-required | `miniquake/server.ml:SV_Init` |
| function | `SV_StartParticle` | review-required | `miniquake/server.ml:SV_StartParticle` |
| function | `SV_StartSound` | review-required | `miniquake/server.ml:SV_StartSound` |
| function | `SV_SendServerinfo` | review-required | `miniquake/server.ml:SV_SendServerinfo`, `miniquake/server.ml:sendServerInfo` |
| function | `SV_ConnectClient` | review-required | `miniquake/server.ml:SV_ConnectClient` |
| function | `SV_CheckForNewClients` | review-required | `miniquake/server.ml:SV_CheckForNewClients` |
| function | `SV_ClearDatagram` | review-required | `miniquake/server.ml:SV_ClearDatagram` |
| function | `SV_AddToFatPVS` | review-required | `miniquake/server.ml:SV_AddToFatPVS` |
| function | `SV_FatPVS` | review-required | `miniquake/server.ml:SV_FatPVS` |
| function | `SV_WriteEntitiesToClient` | review-required | `miniquake/server.ml:SV_WriteEntitiesToClient` |
| function | `SV_CleanupEnts` | review-required | `miniquake/server.ml:SV_CleanupEnts` |
| function | `SV_WriteClientdataToMessage` | review-required | `miniquake/server.ml:SV_WriteClientdataToMessage` |
| function | `SV_SendClientDatagram` | review-required | `miniquake/server.ml:SV_SendClientDatagram` |
| function | `SV_UpdateToReliableMessages` | review-required | `miniquake/server.ml:SV_UpdateToReliableMessages` |
| function | `SV_SendNop` | review-required | `miniquake/server.ml:SV_SendNop` |
| function | `SV_SendClientMessages` | review-required | `miniquake/server.ml:SV_SendClientMessages` |
| function | `SV_ModelIndex` | review-required | `miniquake/server.ml:SV_ModelIndex`, `miniquake/server.ml:modelIndex` |
| function | `SV_CreateBaseline` | review-required | `miniquake/server.ml:SV_CreateBaseline` |
| function | `SV_SendReconnect` | review-required | `miniquake/server.ml:SV_SendReconnect` |
| function | `SV_SaveSpawnparms` | review-required | `miniquake/server.ml:SV_SaveSpawnparms` |
| global | `server_static_t svs` | review-required |  |
| global | `char localmodels[MAX_MODELS][5]` | review-required |  |
| global | `/* ============================================================================= The PVS must include a small area around the client to allow head bobbing or other small motion on the client side. Otherwise, a bob might cause an entity that should be visible to not show up, especially when the bob crosses a waterline. ============================================================================= */ int fatbytes` | review-required |  |
| global | `byte fatpvs[MAX_MAP_LEAFS/8]` | review-required |  |
| global | `/* ================ SV_SpawnServer This is called at the start of each level ================ */ extern float scr_centertime_off` | review-required |  |

### `sv_move.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SV_CheckBottom` | review-required | `miniquake/server_move.ml:SV_CheckBottom` |
| function | `SV_movestep` | review-required | `miniquake/server_move.ml:SV_movestep`, `miniquake/server_move.ml:moveStep` |
| function | `SV_StepDirection` | review-required | `miniquake/server_move.ml:SV_StepDirection`, `miniquake/server_move.ml:stepDirection` |
| function | `SV_FixCheckBottom` | review-required | `miniquake/server_move.ml:SV_FixCheckBottom`, `miniquake/server_move.ml:fixCheckBottom` |
| function | `SV_NewChaseDir` | review-required | `miniquake/server_move.ml:SV_NewChaseDir` |
| function | `SV_CloseEnough` | review-required | `miniquake/server_move.ml:SV_CloseEnough`, `miniquake/server_move.ml:closeEnough` |
| function | `SV_MoveToGoal` | review-required | `miniquake/server_move.ml:SV_MoveToGoal`, `miniquake/server_move.ml:moveToGoal` |
| macro | `STEPSIZE` | review-required |  |
| macro | `DI_NODIR` | review-required |  |
| prototype | `PF_changeyaw` | review-required | `miniquake/server_move.ml:changeYaw` |

### `sv_phys.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SV_CheckAllEnts` | review-required | `miniquake/server.ml:SV_CheckAllEnts` |
| function | `SV_CheckVelocity` | review-required | `miniquake/physics.ml:SV_CheckVelocity` |
| function | `SV_RunThink` | review-required | `miniquake/server.ml:SV_RunThink` |
| function | `SV_Impact` | review-required | `miniquake/server.ml:SV_Impact`, `miniquake/server_collision.ml:impact` |
| function | `ClipVelocity` | review-required | `miniquake/physics.ml:clipVelocity`, `miniquake/physics.ml:ClipVelocity` |
| function | `SV_FlyMove` | review-required | `miniquake/physics.ml:SV_FlyMove`, `miniquake/physics.ml:flyMove` |
| function | `SV_AddGravity` | review-required | `miniquake/physics.ml:SV_AddGravity` |
| function | `SV_PushEntity` | review-required | `miniquake/physics.ml:SV_PushEntity`, `miniquake/server_collision.ml:pushEntity` |
| function | `SV_PushMove` | review-required | `miniquake/server.ml:SV_PushMove` |
| function | `SV_PushRotate` | review-required |  |
| function | `SV_Physics_Pusher` | review-required | `miniquake/server.ml:SV_Physics_Pusher`, `miniquake/server.ml:physicsPusher` |
| function | `SV_CheckStuck` | review-required | `miniquake/physics.ml:SV_CheckStuck`, `miniquake/physics.ml:checkStuck` |
| function | `SV_CheckWater` | review-required | `miniquake/physics.ml:SV_CheckWater` |
| function | `SV_WallFriction` | review-required | `miniquake/physics.ml:SV_WallFriction`, `miniquake/physics.ml:wallFriction` |
| function | `SV_TryUnstick` | review-required | `miniquake/physics.ml:SV_TryUnstick`, `miniquake/physics.ml:tryUnstick` |
| function | `SV_WalkMove` | review-required | `miniquake/physics.ml:SV_WalkMove` |
| function | `SV_Physics_Client` | review-required | `miniquake/physics.ml:SV_Physics_Client` |
| function | `SV_Physics_None` | review-required | `miniquake/server.ml:SV_Physics_None` |
| function | `SV_Physics_Follow` | review-required |  |
| function | `SV_Physics_Noclip` | review-required | `miniquake/server.ml:SV_Physics_Noclip` |
| function | `SV_CheckWaterTransition` | review-required | `miniquake/physics.ml:SV_CheckWaterTransition` |
| function | `SV_Physics_Toss` | review-required | `miniquake/server.ml:SV_Physics_Toss` |
| function | `SV_Physics_Step` | review-required | `miniquake/server.ml:SV_Physics_Step` |
| function | `SV_Physics_Step` | review-required | `miniquake/server.ml:SV_Physics_Step` |
| function | `SV_Physics` | review-required | `miniquake/server.ml:SV_Physics` |
| function | `SV_Trace_Toss` | review-required | `miniquake/server.ml:SV_Trace_Toss` |
| macro | `MOVE_EPSILON` | review-required |  |
| macro | `STOP_EPSILON` | review-required |  |
| macro | `MAX_CLIP_PLANES` | review-required |  |
| macro | `STEPSIZE` | review-required |  |

### `sv_user.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SV_SetIdealPitch` | review-required | `miniquake/physics.ml:SV_SetIdealPitch` |
| function | `SV_UserFriction` | review-required | `miniquake/physics.ml:SV_UserFriction`, `miniquake/player_move.ml:userFriction` |
| function | `SV_Accelerate` | review-required | `miniquake/physics.ml:SV_Accelerate`, `miniquake/player_move.ml:accelerate`, `miniquake/physics.ml:accelerate` |
| function | `SV_Accelerate` | review-required | `miniquake/physics.ml:SV_Accelerate`, `miniquake/player_move.ml:accelerate`, `miniquake/physics.ml:accelerate` |
| function | `SV_AirAccelerate` | review-required | `miniquake/physics.ml:SV_AirAccelerate`, `miniquake/player_move.ml:airAccelerate`, `miniquake/physics.ml:airAccelerate` |
| function | `DropPunchAngle` | review-required | `miniquake/physics.ml:dropPunchAngle`, `miniquake/physics.ml:DropPunchAngle` |
| function | `SV_WaterMove` | review-required | `miniquake/physics.ml:SV_WaterMove`, `miniquake/player_move.ml:waterMove`, `miniquake/physics.ml:waterMove` |
| function | `SV_WaterJump` | review-required | `miniquake/physics.ml:SV_WaterJump` |
| function | `SV_AirMove` | review-required | `miniquake/physics.ml:SV_AirMove`, `miniquake/physics.ml:airMove` |
| function | `SV_ClientThink` | review-required | `miniquake/physics.ml:SV_ClientThink`, `miniquake/physics.ml:clientThink` |
| function | `SV_ReadClientMove` | review-required | `miniquake/server.ml:SV_ReadClientMove` |
| function | `SV_ReadClientMessage` | review-required | `miniquake/server.ml:SV_ReadClientMessage`, `miniquake/server.ml:readClientMessage` |
| function | `SV_RunClients` | review-required | `miniquake/server.ml:SV_RunClients` |
| macro | `MAX_FORWARD` | review-required |  |
| global | `extern cvar_t sv_friction` | review-required |  |
| global | `extern cvar_t sv_stopspeed` | review-required |  |
| global | `static vec3_t forward, right, up` | review-required |  |
| global | `vec3_t wishdir` | review-required |  |
| global | `float wishspeed` | review-required |  |
| global | `// world float *angles` | review-required |  |
| global | `float *origin` | review-required |  |
| global | `float *velocity` | review-required |  |
| global | `qboolean onground` | review-required |  |
| global | `usercmd_t cmd` | review-required |  |

### `sys.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| prototype | `Sys_FileOpenRead` | review-required |  |
| prototype | `Sys_FileOpenWrite` | review-required |  |
| prototype | `Sys_FileClose` | review-required |  |
| prototype | `Sys_FileSeek` | review-required |  |
| prototype | `Sys_FileRead` | review-required |  |
| prototype | `Sys_FileWrite` | review-required |  |
| prototype | `Sys_FileTime` | review-required |  |
| prototype | `Sys_mkdir` | review-required |  |
| prototype | `Sys_MakeCodeWriteable` | review-required |  |
| prototype | `Sys_DebugLog` | review-required |  |
| prototype | `Sys_Error` | review-required |  |
| prototype | `Sys_Printf` | review-required |  |
| prototype | `Sys_Quit` | review-required |  |
| prototype | `Sys_FloatTime` | review-required |  |
| prototype | `Sys_ConsoleInput` | review-required |  |
| prototype | `Sys_Sleep` | review-required |  |
| prototype | `Sys_SendKeyEvents` | review-required |  |
| prototype | `Key_Event` | review-required |  |
| prototype | `Sys_HighFPPrecision` | review-required |  |
| prototype | `Sys_SetFPCW` | review-required |  |

### `sys_win.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Sys_PageIn` | review-required |  |
| function | `findhandle` | review-required |  |
| function | `filelength` | review-required |  |
| function | `Sys_FileOpenRead` | review-required |  |
| function | `Sys_FileOpenWrite` | review-required |  |
| function | `Sys_FileClose` | review-required |  |
| function | `Sys_FileSeek` | review-required |  |
| function | `Sys_FileRead` | review-required |  |
| function | `Sys_FileWrite` | review-required |  |
| function | `Sys_FileTime` | review-required |  |
| function | `Sys_mkdir` | review-required |  |
| function | `Sys_MakeCodeWriteable` | review-required |  |
| function | `Sys_SetFPCW` | review-required |  |
| function | `Sys_PushFPCW_SetHigh` | review-required |  |
| function | `Sys_PopFPCW` | review-required |  |
| function | `MaskExceptions` | review-required |  |
| function | `Sys_Init` | review-required |  |
| function | `Sys_Error` | review-required |  |
| function | `Sys_Printf` | review-required |  |
| function | `Sys_Quit` | review-required |  |
| function | `Sys_FloatTime` | review-required |  |
| function | `Sys_InitFloatTime` | review-required |  |
| function | `Sys_ConsoleInput` | review-required |  |
| function | `Sys_Sleep` | review-required |  |
| function | `Sys_SendKeyEvents` | review-required |  |
| function | `SleepUntilInput` | review-required |  |
| function | `WinMain` | review-required |  |
| macro | `MINIMUM_WIN_MEMORY` | review-required |  |
| macro | `MAXIMUM_WIN_MEMORY` | review-required |  |
| macro | `CONSOLE_ERROR_TIMEOUT` | review-required |  |
| macro | `PAUSE_SLEEP` | review-required |  |
| macro | `NOT_FOCUS_SLEEP` | review-required |  |
| macro | `MAX_HANDLES` | review-required |  |
| global | `qboolean ActiveApp, Minimized` | review-required |  |
| global | `qboolean WinNT` | review-required |  |
| global | `static double pfreq` | review-required |  |
| global | `static double curtime = 0.0` | review-required |  |
| global | `static double lastcurtime = 0.0` | review-required |  |
| global | `static int lowshift` | review-required |  |
| global | `qboolean isDedicated` | review-required |  |
| global | `static qboolean sc_return_on_enter = false` | review-required |  |
| global | `HANDLE hinput, houtput` | review-required |  |
| global | `static char *tracking_tag = "Clams & Mooses"` | review-required |  |
| global | `static HANDLE tevent` | review-required |  |
| global | `static HANDLE hFile` | review-required |  |
| global | `static HANDLE heventParent` | review-required |  |
| global | `static HANDLE heventChild` | review-required |  |
| global | `volatile int sys_checksum` | review-required |  |
| global | `/* =============================================================================== FILE IO =============================================================================== */ #define MAX_HANDLES 10 FILE *sys_handles[MAX_HANDLES]` | review-required |  |
| global | `/* ================== WinMain ================== */ HINSTANCE global_hInstance` | review-required |  |
| global | `int global_nCmdShow` | review-required |  |
| global | `char *argv[MAX_NUM_ARGVS]` | review-required |  |
| global | `static char *empty_string = ""` | review-required |  |
| global | `HWND hwnd_dialog` | review-required |  |
| prototype | `MaskExceptions` | review-required |  |
| prototype | `Sys_InitFloatTime` | review-required |  |
| prototype | `Sys_PushFPCW_SetHigh` | review-required |  |
| prototype | `Sys_PopFPCW` | review-required |  |

### `vid.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `vrect_t` | review-required |  |
| field | `vrect_t.int x,y,width,height` | review-required |  |
| field | `vrect_t.struct vrect_s *pnext` | review-required |  |
| type | `viddef_t` | review-required |  |
| field | `viddef_t.pixel_t *buffer` | review-required |  |
| field | `viddef_t.// invisible buffer pixel_t *colormap` | review-required |  |
| field | `viddef_t.// 256 * VID_GRADES size unsigned short *colormap16` | review-required |  |
| field | `viddef_t.// 256 * VID_GRADES size int fullbright` | review-required |  |
| field | `viddef_t.// index of first fullbright color unsigned rowbytes` | review-required |  |
| field | `viddef_t.// may be > width if displayed in a window unsigned width` | review-required |  |
| field | `viddef_t.unsigned height` | review-required |  |
| field | `viddef_t.float aspect` | review-required |  |
| field | `viddef_t.// width / height -- < 0 is taller than wide int numpages` | review-required |  |
| field | `viddef_t.int recalc_refdef` | review-required |  |
| field | `viddef_t.// if true, recalc vid-based stuff pixel_t *conbuffer` | review-required |  |
| field | `viddef_t.int conrowbytes` | review-required |  |
| field | `viddef_t.unsigned conwidth` | review-required |  |
| field | `viddef_t.unsigned conheight` | review-required |  |
| field | `viddef_t.int maxwarpwidth` | review-required |  |
| field | `viddef_t.int maxwarpheight` | review-required |  |
| field | `viddef_t.pixel_t *direct` | review-required |  |
| macro | `VID_CBITS` | review-required |  |
| macro | `VID_GRADES` | review-required |  |
| global | `vrect_t` | review-required |  |
| global | `viddef_t` | review-required |  |
| global | `extern viddef_t vid` | review-required |  |
| global | `// global video state extern unsigned short d_8to16table[256]` | review-required |  |
| global | `extern unsigned d_8to24table[256]` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `void` | review-required |  |
| prototype | `VID_SetPalette` | review-required |  |
| prototype | `VID_ShiftPalette` | review-required |  |
| prototype | `VID_Init` | review-required |  |
| prototype | `VID_Shutdown` | review-required |  |
| prototype | `VID_Update` | review-required |  |
| prototype | `VID_SetMode` | review-required |  |
| prototype | `VID_HandlePause` | review-required |  |

### `view.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `V_CalcRoll` | review-required | `miniquake/view.ml:V_CalcRoll`, `miniquake/view.ml:calcRoll` |
| function | `V_CalcBob` | review-required | `miniquake/view.ml:V_CalcBob`, `miniquake/view.ml:calcBob` |
| function | `V_StartPitchDrift` | review-required | `miniquake/view.ml:V_StartPitchDrift`, `miniquake/view.ml:startPitchDrift` |
| function | `V_StopPitchDrift` | review-required | `miniquake/view.ml:V_StopPitchDrift`, `miniquake/view.ml:stopPitchDrift` |
| function | `V_DriftPitch` | review-required | `miniquake/view.ml:V_DriftPitch`, `miniquake/view.ml:driftPitch` |
| function | `BuildGammaTable` | review-required | `miniquake/view.ml:buildGammaTable`, `miniquake/view.ml:BuildGammaTable` |
| function | `V_CheckGamma` | review-required | `miniquake/view.ml:V_CheckGamma`, `miniquake/view.ml:checkGamma` |
| function | `V_ParseDamage` | review-required | `miniquake/view.ml:V_ParseDamage` |
| function | `V_cshift_f` | review-required | `miniquake/view.ml:V_cshift_f` |
| function | `V_BonusFlash_f` | review-required | `miniquake/view.ml:V_BonusFlash_f` |
| function | `V_SetContentsColor` | review-required | `miniquake/view.ml:V_SetContentsColor`, `miniquake/view.ml:setContentsColor` |
| function | `V_CalcPowerupCshift` | review-required | `miniquake/view.ml:V_CalcPowerupCshift` |
| function | `V_CalcBlend` | review-required | `miniquake/view.ml:V_CalcBlend`, `miniquake/view.ml:calcBlend` |
| function | `V_UpdatePalette` | review-required | `miniquake/view.ml:V_UpdatePalette`, `miniquake/view.ml:updatePalette` |
| function | `V_UpdatePalette` | review-required | `miniquake/view.ml:V_UpdatePalette`, `miniquake/view.ml:updatePalette` |
| function | `angledelta` | review-required | `miniquake/view.ml:angleDelta`, `miniquake/view.ml:angledelta` |
| function | `CalcGunAngle` | review-required | `miniquake/view.ml:calcGunAngle`, `miniquake/view.ml:CalcGunAngle` |
| function | `V_BoundOffsets` | review-required | `miniquake/view.ml:V_BoundOffsets`, `miniquake/view.ml:boundOffsets` |
| function | `V_AddIdle` | review-required | `miniquake/view.ml:V_AddIdle`, `miniquake/view.ml:addIdle` |
| function | `V_CalcViewRoll` | review-required | `miniquake/view.ml:V_CalcViewRoll` |
| function | `V_CalcIntermissionRefdef` | review-required | `miniquake/view.ml:V_CalcIntermissionRefdef` |
| function | `V_CalcRefdef` | review-required | `miniquake/view.ml:V_CalcRefdef` |
| function | `V_RenderView` | review-required | `miniquake/view.ml:V_RenderView` |
| function | `V_Init` | review-required | `miniquake/view.ml:V_Init` |
| global | `float v_dmg_time, v_dmg_roll, v_dmg_pitch` | review-required |  |
| global | `extern int in_forward, in_forward2, in_back` | review-required |  |
| global | `/* =============== V_CalcRoll Used by view and sv_user =============== */ vec3_t forward, right, up` | review-required |  |
| global | `byte gammatable[256]` | review-required |  |
| global | `// palette is sent through this #ifdef GLQUAKE byte ramps[3][256]` | review-required |  |
| global | `float v_blend[4]` | review-required |  |

### `view.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| global | `extern byte gammatable[256]` | review-required |  |
| global | `// palette is sent through this extern byte ramps[3][256]` | review-required |  |
| global | `extern float v_blend[4]` | review-required |  |
| global | `extern cvar_t lcd_x` | review-required |  |
| prototype | `V_Init` | review-required |  |
| prototype | `V_RenderView` | review-required |  |
| prototype | `V_CalcRoll` | review-required |  |
| prototype | `V_UpdatePalette` | review-required |  |

### `wad.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `W_CleanupName` | review-required | `miniquake/wad.ml:W_CleanupName`, `miniquake/wad.ml:cleanupName` |
| function | `W_LoadWadFile` | review-required | `miniquake/wad.ml:W_LoadWadFile`, `miniquake/wad.ml:loadWadFile` |
| function | `W_GetLumpinfo` | review-required | `miniquake/wad.ml:W_GetLumpinfo`, `miniquake/wad.ml:getLumpInfo` |
| function | `W_GetLumpName` | review-required | `miniquake/wad.ml:W_GetLumpName`, `miniquake/wad.ml:getLumpName` |
| function | `W_GetLumpNum` | review-required | `miniquake/wad.ml:W_GetLumpNum`, `miniquake/wad.ml:getLumpNum` |
| function | `SwapPic` | review-required | `miniquake/wad.ml:swapPic`, `miniquake/wad.ml:SwapPic` |
| global | `lumpinfo_t *wad_lumps` | review-required |  |
| global | `byte *wad_base` | review-required |  |
| prototype | `SwapPic` | review-required | `miniquake/wad.ml:swapPic`, `miniquake/wad.ml:SwapPic` |

### `wad.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `qpic_t` | review-required |  |
| field | `qpic_t.int width, height` | review-required |  |
| field | `qpic_t.byte data[4]` | review-required |  |
| type | `wadinfo_t` | review-required |  |
| field | `wadinfo_t.char identification[4]` | review-required |  |
| field | `wadinfo_t.// should be WAD2 or 2DAW int numlumps` | review-required |  |
| field | `wadinfo_t.int infotableofs` | review-required |  |
| type | `lumpinfo_t` | review-required |  |
| field | `lumpinfo_t.int filepos` | review-required |  |
| field | `lumpinfo_t.int disksize` | review-required |  |
| field | `lumpinfo_t.int size` | review-required |  |
| field | `lumpinfo_t.// uncompressed char type` | review-required |  |
| field | `lumpinfo_t.char compression` | review-required |  |
| field | `lumpinfo_t.char pad1, pad2` | review-required |  |
| field | `lumpinfo_t.char name[16]` | review-required |  |
| macro | `CMP_NONE` | review-required |  |
| macro | `CMP_LZSS` | review-required |  |
| macro | `TYP_NONE` | review-required |  |
| macro | `TYP_LABEL` | review-required |  |
| macro | `TYP_LUMPY` | review-required |  |
| macro | `TYP_PALETTE` | review-required |  |
| macro | `TYP_QTEX` | review-required |  |
| macro | `TYP_QPIC` | review-required |  |
| macro | `TYP_SOUND` | review-required |  |
| macro | `TYP_MIPTEX` | review-required |  |
| global | `qpic_t` | review-required |  |
| global | `wadinfo_t` | review-required |  |
| global | `lumpinfo_t` | review-required |  |
| global | `extern int wad_numlumps` | review-required |  |
| global | `extern lumpinfo_t *wad_lumps` | review-required |  |
| global | `extern byte *wad_base` | review-required |  |
| prototype | `W_LoadWadFile` | review-required |  |
| prototype | `W_CleanupName` | review-required |  |
| prototype | `W_GetLumpinfo` | review-required |  |
| prototype | `W_GetLumpName` | review-required |  |
| prototype | `W_GetLumpNum` | review-required |  |
| prototype | `SwapPic` | review-required |  |

### `winquake.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `modestate_t` | review-required |  |
| enum-value | `modestate_t.MS_WINDOWED` | review-required |  |
| enum-value | `modestate_t.MS_FULLSCREEN` | review-required |  |
| enum-value | `modestate_t.MS_FULLDIB` | review-required |  |
| enum-value | `modestate_t.MS_UNINIT` | review-required |  |
| macro | `WM_MOUSEWHEEL` | review-required |  |
| global | `extern int global_nCmdShow` | review-required |  |
| global | `extern qboolean DDActive` | review-required |  |
| global | `extern LPDIRECTDRAWSURFACE lpPrimary` | review-required |  |
| global | `extern LPDIRECTDRAWSURFACE lpFrontBuffer` | review-required |  |
| global | `extern LPDIRECTDRAWSURFACE lpBackBuffer` | review-required |  |
| global | `extern LPDIRECTDRAWPALETTE lpDDPal` | review-required |  |
| global | `extern LPDIRECTSOUND pDS` | review-required |  |
| global | `extern LPDIRECTSOUNDBUFFER pDSBuf` | review-required |  |
| global | `extern DWORD gSndBufSize` | review-required |  |
| global | `modestate_t` | review-required |  |
| global | `extern modestate_t modestate` | review-required |  |
| global | `extern HWND mainwindow` | review-required |  |
| global | `extern qboolean ActiveApp, Minimized` | review-required |  |
| global | `extern qboolean WinNT` | review-required |  |
| global | `extern qboolean winsock_lib_initialized` | review-required |  |
| global | `extern cvar_t _windowed_mouse` | review-required |  |
| global | `extern int window_center_x, window_center_y` | review-required |  |
| global | `extern RECT window_rect` | review-required |  |
| global | `extern qboolean mouseinitialized` | review-required |  |
| global | `extern HWND hwnd_dialog` | review-required |  |
| global | `extern HANDLE hinput, houtput` | review-required |  |
| prototype | `VID_LockBuffer` | review-required |  |
| prototype | `VID_UnlockBuffer` | review-required |  |
| prototype | `VID_ForceUnlockedAndReturnState` | review-required |  |
| prototype | `VID_ForceLockState` | review-required |  |
| prototype | `IN_ShowMouse` | review-required |  |
| prototype | `IN_DeactivateMouse` | review-required |  |
| prototype | `IN_HideMouse` | review-required |  |
| prototype | `IN_ActivateMouse` | review-required |  |
| prototype | `IN_RestoreOriginalMouseState` | review-required |  |
| prototype | `IN_SetQuakeMouseState` | review-required |  |
| prototype | `IN_MouseEvent` | review-required |  |
| prototype | `IN_UpdateClipCursor` | review-required |  |
| prototype | `CenterWindow` | review-required |  |
| prototype | `S_BlockSound` | review-required |  |
| prototype | `S_UnblockSound` | review-required |  |
| prototype | `VID_SetDefaultMode` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `SOCKET` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |
| prototype | `int` | review-required |  |

### `world.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `SV_InitBoxHull` | review-required | `miniquake/server_collision.ml:SV_InitBoxHull` |
| function | `SV_HullForBox` | review-required | `miniquake/server_collision.ml:SV_HullForBox` |
| function | `SV_HullForEntity` | review-required | `miniquake/server_collision.ml:SV_HullForEntity` |
| function | `SV_CreateAreaNode` | review-required | `miniquake/server_collision.ml:SV_CreateAreaNode` |
| function | `SV_ClearWorld` | review-required | `miniquake/server_collision.ml:SV_ClearWorld` |
| function | `SV_UnlinkEdict` | review-required | `miniquake/server_collision.ml:SV_UnlinkEdict`, `miniquake/server_collision.ml:unlinkEdict` |
| function | `SV_TouchLinks` | review-required | `miniquake/server_collision.ml:SV_TouchLinks` |
| function | `SV_FindTouchedLeafs` | review-required | `miniquake/server_collision.ml:SV_FindTouchedLeafs` |
| function | `SV_LinkEdict` | review-required | `miniquake/server_collision.ml:SV_LinkEdict`, `miniquake/server_collision.ml:linkEdict` |
| function | `SV_HullPointContents` | review-required | `miniquake/server_collision.ml:SV_HullPointContents` |
| function | `SV_PointContents` | review-required | `miniquake/server_collision.ml:SV_PointContents`, `miniquake/world_bsp.ml:pointContents` |
| function | `SV_TruePointContents` | review-required | `miniquake/server_collision.ml:SV_TruePointContents`, `miniquake/world_bsp.ml:truePointContents`, `miniquake/world_hull.ml:truePointContents` |
| function | `SV_TestEntityPosition` | review-required | `miniquake/server_collision.ml:SV_TestEntityPosition`, `miniquake/server_collision.ml:testEntityPosition` |
| function | `SV_RecursiveHullCheck` | review-required | `miniquake/server_collision.ml:SV_RecursiveHullCheck`, `miniquake/world_bsp.ml:recursiveHullCheck` |
| function | `SV_ClipMoveToEntity` | review-required | `miniquake/server_collision.ml:SV_ClipMoveToEntity` |
| function | `SV_ClipToLinks` | review-required | `miniquake/server_collision.ml:SV_ClipToLinks` |
| function | `SV_MoveBounds` | review-required | `miniquake/server_collision.ml:SV_MoveBounds`, `miniquake/server_collision.ml:moveBounds` |
| function | `SV_Move` | review-required | `miniquake/server_collision.ml:SV_Move`, `miniquake/server_collision.ml:move` |
| type | `moveclip_t` | review-required |  |
| field | `moveclip_t.vec3_t boxmins, boxmaxs` | review-required |  |
| field | `moveclip_t.// enclose the test object along entire move float *mins, *maxs` | review-required |  |
| field | `moveclip_t.// size of the moving object vec3_t mins2, maxs2` | review-required |  |
| field | `moveclip_t.// size when clipping against mosnters float *start, *end` | review-required |  |
| field | `moveclip_t.trace_t trace` | review-required |  |
| field | `moveclip_t.int type` | review-required |  |
| field | `moveclip_t.edict_t *passedict` | review-required |  |
| type | `areanode_t` | review-required |  |
| field | `areanode_t.int axis` | review-required |  |
| field | `areanode_t.// -1 = leaf node float dist` | review-required |  |
| field | `areanode_t.struct areanode_s *children[2]` | review-required |  |
| field | `areanode_t.link_t trigger_edicts` | review-required |  |
| field | `areanode_t.link_t solid_edicts` | review-required |  |
| macro | `AREA_DEPTH` | review-required |  |
| macro | `AREA_NODES` | review-required |  |
| macro | `DIST_EPSILON` | review-required |  |
| global | `moveclip_t` | review-required |  |
| global | `/* =============================================================================== HULL BOXES =============================================================================== */ static hull_t box_hull` | review-required |  |
| global | `static dclipnode_t box_clipnodes[6]` | review-required |  |
| global | `static mplane_t box_planes[6]` | review-required |  |
| global | `areanode_t` | review-required |  |
| global | `static int sv_numareanodes` | review-required |  |
| prototype | `SV_HullPointContents` | review-required | `miniquake/server_collision.ml:SV_HullPointContents` |

### `world.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `plane_t` | review-required |  |
| field | `plane_t.vec3_t normal` | review-required |  |
| field | `plane_t.float dist` | review-required |  |
| type | `trace_t` | review-required |  |
| field | `trace_t.qboolean allsolid` | review-required |  |
| field | `trace_t.// if true, plane is not valid qboolean startsolid` | review-required |  |
| field | `trace_t.// if true, the initial point was in a solid area qboolean inopen, inwater` | review-required |  |
| field | `trace_t.float fraction` | review-required |  |
| field | `trace_t.// time completed, 1.0 = didn't hit anything vec3_t endpos` | review-required |  |
| field | `trace_t.// final position plane_t plane` | review-required |  |
| field | `trace_t.// surface normal at impact edict_t *ent` | review-required |  |
| macro | `MOVE_NORMAL` | review-required |  |
| macro | `MOVE_NOMONSTERS` | review-required |  |
| macro | `MOVE_MISSILE` | review-required |  |
| global | `plane_t` | review-required |  |
| global | `trace_t` | review-required |  |
| prototype | `SV_UnlinkEdict` | review-required |  |
| prototype | `SV_LinkEdict` | review-required |  |
| prototype | `SV_PointContents` | review-required |  |
| prototype | `SV_TruePointContents` | review-required |  |
| prototype | `SV_TestEntityPosition` | review-required |  |
| prototype | `SV_Move` | review-required |  |

### `zone.c`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| function | `Z_ClearZone` | review-required | `miniquake/memory.ml:Z_ClearZone` |
| function | `Z_Free` | review-required | `miniquake/memory.ml:Z_Free`, `miniquake/memory.ml:cacheFree`, `miniquake/memory.ml:Cache_Free` |
| function | `Z_Malloc` | review-required | `miniquake/memory.ml:Z_Malloc`, `miniquake/memory.ml:cacheAlloc`, `miniquake/memory.ml:Hunk_Alloc`, `miniquake/memory.ml:Cache_Alloc` |
| function | `Z_TagMalloc` | review-required | `miniquake/memory.ml:Z_TagMalloc` |
| function | `Z_Print` | review-required | `miniquake/memory.ml:Z_Print`, `miniquake/memory.ml:Hunk_Print`, `miniquake/memory.ml:Cache_Print` |
| function | `Z_CheckHeap` | review-required | `miniquake/memory.ml:Z_CheckHeap` |
| function | `Hunk_Check` | review-required | `miniquake/memory.ml:Hunk_Check`, `miniquake/memory.ml:cacheCheck`, `miniquake/memory.ml:Cache_Check` |
| function | `Hunk_Print` | review-required | `miniquake/memory.ml:Hunk_Print`, `miniquake/memory.ml:Z_Print`, `miniquake/memory.ml:Cache_Print` |
| function | `Hunk_AllocName` | review-required | `miniquake/memory.ml:Hunk_AllocName`, `miniquake/memory.ml:hunkAllocName` |
| function | `Hunk_Alloc` | review-required | `miniquake/memory.ml:Hunk_Alloc`, `miniquake/memory.ml:cacheAlloc`, `miniquake/memory.ml:Z_Malloc`, `miniquake/memory.ml:Cache_Alloc` |
| function | `Hunk_LowMark` | review-required | `miniquake/memory.ml:Hunk_LowMark`, `miniquake/memory.ml:lowMark` |
| function | `Hunk_FreeToLowMark` | review-required | `miniquake/memory.ml:Hunk_FreeToLowMark`, `miniquake/memory.ml:freeToLowMark` |
| function | `Hunk_HighMark` | review-required | `miniquake/memory.ml:Hunk_HighMark`, `miniquake/memory.ml:highMark` |
| function | `Hunk_FreeToHighMark` | review-required | `miniquake/memory.ml:Hunk_FreeToHighMark`, `miniquake/memory.ml:freeToHighMark` |
| function | `Hunk_HighAllocName` | review-required | `miniquake/memory.ml:Hunk_HighAllocName` |
| function | `Hunk_TempAlloc` | review-required | `miniquake/memory.ml:Hunk_TempAlloc` |
| function | `Cache_Move` | review-required | `miniquake/memory.ml:Cache_Move` |
| function | `Cache_FreeLow` | review-required | `miniquake/memory.ml:Cache_FreeLow` |
| function | `Cache_FreeHigh` | review-required | `miniquake/memory.ml:Cache_FreeHigh` |
| function | `Cache_UnlinkLRU` | review-required | `miniquake/memory.ml:Cache_UnlinkLRU` |
| function | `Cache_MakeLRU` | review-required | `miniquake/memory.ml:Cache_MakeLRU` |
| function | `Cache_TryAlloc` | review-required | `miniquake/memory.ml:Cache_TryAlloc` |
| function | `Cache_Flush` | review-required | `miniquake/memory.ml:Cache_Flush` |
| function | `Cache_Print` | review-required | `miniquake/memory.ml:Cache_Print`, `miniquake/memory.ml:Z_Print`, `miniquake/memory.ml:Hunk_Print` |
| function | `Cache_Report` | review-required | `miniquake/memory.ml:Cache_Report` |
| function | `Cache_Compact` | review-required | `miniquake/memory.ml:Cache_Compact` |
| function | `Cache_Init` | review-required | `miniquake/memory.ml:Cache_Init` |
| function | `Cache_Free` | review-required | `miniquake/memory.ml:Cache_Free`, `miniquake/memory.ml:cacheFree`, `miniquake/memory.ml:Z_Free` |
| function | `Cache_Check` | review-required | `miniquake/memory.ml:Cache_Check`, `miniquake/memory.ml:cacheCheck`, `miniquake/memory.ml:Hunk_Check` |
| function | `Cache_Alloc` | review-required | `miniquake/memory.ml:Cache_Alloc`, `miniquake/memory.ml:cacheAlloc`, `miniquake/memory.ml:Z_Malloc`, `miniquake/memory.ml:Hunk_Alloc` |
| function | `Memory_Init` | review-required | `miniquake/memory.ml:Memory_Init` |
| type | `memblock_t` | review-required |  |
| field | `memblock_t.int size` | review-required |  |
| field | `memblock_t.// including the header and possibly tiny fragments int tag` | review-required |  |
| field | `memblock_t.// a tag of 0 is a free block int id` | review-required |  |
| field | `memblock_t.// should be ZONEID struct memblock_s *next, *prev` | review-required |  |
| field | `memblock_t.int pad` | review-required |  |
| type | `memzone_t` | review-required |  |
| field | `memzone_t.int size` | review-required |  |
| field | `memzone_t.// total bytes malloced, including header memblock_t blocklist` | review-required |  |
| field | `memzone_t.// start / end cap for linked list memblock_t *rover` | review-required |  |
| type | `hunk_t` | review-required |  |
| field | `hunk_t.int sentinal` | review-required |  |
| field | `hunk_t.int size` | review-required |  |
| field | `hunk_t.// including sizeof(hunk_t), -1 = not allocated char name[8]` | review-required |  |
| type | `cache_system_t` | review-required |  |
| field | `cache_system_t.int size` | review-required |  |
| field | `cache_system_t.// including this header cache_user_t *user` | review-required |  |
| field | `cache_system_t.char name[16]` | review-required |  |
| field | `cache_system_t.struct cache_system_s *prev, *next` | review-required |  |
| field | `cache_system_t.struct cache_system_s *lru_prev, *lru_next` | review-required |  |
| macro | `DYNAMIC_SIZE` | review-required |  |
| macro | `ZONEID` | review-required |  |
| macro | `MINFRAGMENT` | review-required |  |
| macro | `HUNK_SENTINAL` | review-required |  |
| global | `memblock_t` | review-required |  |
| global | `memzone_t` | review-required |  |
| global | `/* ============================================================================== ZONE MEMORY ALLOCATION There is never any space between memblocks, and there will never be two contiguous free memblocks. The rover can be left pointing at a non-empty block The zone calls are pretty much only used for small strings and structures, all big things are allocated on the hunk. ============================================================================== */ memzone_t *mainzone` | review-required |  |
| global | `hunk_t` | review-required |  |
| global | `byte *hunk_base` | review-required |  |
| global | `int hunk_size` | review-required |  |
| global | `int hunk_low_used` | review-required |  |
| global | `int hunk_high_used` | review-required |  |
| global | `qboolean hunk_tempactive` | review-required |  |
| global | `int hunk_tempmark` | review-required |  |
| global | `cache_system_t` | review-required |  |
| global | `cache_system_t cache_head` | review-required |  |
| prototype | `Cache_FreeLow` | review-required | `miniquake/memory.ml:Cache_FreeLow` |
| prototype | `Cache_FreeHigh` | review-required | `miniquake/memory.ml:Cache_FreeHigh` |
| prototype | `Z_ClearZone` | review-required | `miniquake/memory.ml:Z_ClearZone` |
| prototype | `R_FreeTextures` | review-required |  |
| prototype | `Cache_TryAlloc` | review-required | `miniquake/memory.ml:Cache_TryAlloc` |

### `zone.h`

| Art | Originalsymbol/-attribut | Status | Zuordnung |
|---|---|---|---|
| type | `cache_user_t` | review-required |  |
| field | `cache_user_t.void *data` | review-required |  |
| global | `cache_user_t` | review-required |  |
| prototype | `Hunk_Print` | review-required |  |
| prototype | `Z_Free` | review-required |  |
| prototype | `Z_Malloc` | review-required |  |
| prototype | `Z_TagMalloc` | review-required |  |
| prototype | `Z_DumpHeap` | review-required |  |
| prototype | `Z_CheckHeap` | review-required |  |
| prototype | `Z_FreeMemory` | review-required |  |
| prototype | `Hunk_Alloc` | review-required |  |
| prototype | `Hunk_AllocName` | review-required |  |
| prototype | `Hunk_HighAllocName` | review-required |  |
| prototype | `Hunk_LowMark` | review-required |  |
| prototype | `Hunk_FreeToLowMark` | review-required |  |
| prototype | `Hunk_HighMark` | review-required |  |
| prototype | `Hunk_FreeToHighMark` | review-required |  |
| prototype | `Hunk_TempAlloc` | review-required |  |
| prototype | `Hunk_Check` | review-required |  |
| prototype | `Cache_Flush` | review-required |  |
| prototype | `Cache_Check` | review-required |  |
| prototype | `Cache_Free` | review-required |  |
| prototype | `Cache_Alloc` | review-required |  |
| prototype | `Cache_Report` | review-required |  |

