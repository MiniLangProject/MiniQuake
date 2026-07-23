# MiniQuake – absolute GLQuake 1.09 compatibility audit

Target: `winquake - Win32 GL Release` from the supplied `WinQuake.dsp`.

This ledger is exhaustive for the selected project configuration.  A symbol is
only marked `exact` after source-level semantic review; a matching name alone is
never sufficient.  `technical-equivalent` is reserved for unavoidable platform,
ABI, pointer, allocator, or assembly substitutions.

Files: **111** — symbols/declarations: **5335**

File status: review-required=111

Symbol status: review-required=5335

Strict completion gate: **FAIL**

## `anorm_dots.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `anorms.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `bspfile.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `lump_t` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lump_t.int fileofs, filelen` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dmodel_t` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmodel_t.float mins[3], maxs[3]` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmodel_t.float origin[3]` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmodel_t.int headnode[MAX_MAP_HULLS]` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmodel_t.int visleafs` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmodel_t.// not including the solid leaf 0 int firstface, numfaces` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dheader_t` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dheader_t.int version` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dheader_t.lump_t lumps[HEADER_LUMPS]` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dmiptexlump_t` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmiptexlump_t.int nummiptex` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dmiptexlump_t.int dataofs[4]` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `miptex_t` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `miptex_t.char name[16]` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `miptex_t.unsigned width, height` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `miptex_t.unsigned offsets[MIPLEVELS]` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dvertex_t` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dvertex_t.float point[3]` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dplane_t` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dplane_t.float normal[3]` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dplane_t.float dist` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dplane_t.int type` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dnode_t` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dnode_t.int planenum` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dnode_t.short children[2]` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dnode_t.// negative numbers are -(leafs+1), not nodes short mins[3]` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dnode_t.// for sphere culling short maxs[3]` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dnode_t.unsigned short firstface` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dnode_t.unsigned short numfaces` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dclipnode_t` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dclipnode_t.int planenum` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dclipnode_t.short children[2]` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `texinfo_t` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texinfo_t.float vecs[2][4]` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texinfo_t.// [s/t][xyz offset] int miptex` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texinfo_t.int flags` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dedge_t` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dedge_t.unsigned short v[2]` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dface_t` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.short planenum` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.short side` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.int firstedge` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.// we must support > 64k edges short numedges` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.short texinfo` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.// lighting info byte styles[MAXLIGHTMAPS]` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dface_t.int lightofs` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dleaf_t` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.int contents` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.int visofs` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.// -1 = no visibility info short mins[3]` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.// for frustum culling short maxs[3]` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.unsigned short firstmarksurface` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.unsigned short nummarksurfaces` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dleaf_t.byte ambient_level[NUM_AMBIENTS]` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `epair_t` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `epair_t.struct epair_s *next` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `epair_t.char *key` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `epair_t.char *value` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `entity_t` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.vec3_t origin` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.int firstbrush` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.int numbrushes` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.epair_t *epairs` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_HULLS` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_MODELS` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_BRUSHES` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_ENTITIES` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_ENTSTRING` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_PLANES` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_NODES` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_CLIPNODES` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_LEAFS` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_VERTS` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_FACES` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_MARKSURFACES` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_TEXINFO` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_EDGES` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_SURFEDGES` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_TEXTURES` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_MIPTEX` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_LIGHTING` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_VISIBILITY` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAP_PORTALS` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_KEY` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_VALUE` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BSPVERSION` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TOOLVERSION` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_ENTITIES` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_PLANES` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_TEXTURES` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_VERTEXES` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_VISIBILITY` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_NODES` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_TEXINFO` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_FACES` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_LIGHTING` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_CLIPNODES` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_LEAFS` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_MARKSURFACES` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_EDGES` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_SURFEDGES` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LUMP_MODELS` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HEADER_LUMPS` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MIPLEVELS` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PLANE_X` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PLANE_Y` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PLANE_Z` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PLANE_ANYX` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PLANE_ANYY` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PLANE_ANYZ` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_EMPTY` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_SOLID` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_WATER` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_SLIME` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_LAVA` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_SKY` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_ORIGIN` | 143 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CLIP` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CURRENT_0` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CURRENT_90` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CURRENT_180` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CURRENT_270` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CURRENT_UP` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENTS_CURRENT_DOWN` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TEX_SPECIAL` | 178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXLIGHTMAPS` | 187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AMBIENT_WATER` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AMBIENT_SKY` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AMBIENT_SLIME` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AMBIENT_LAVA` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_AMBIENTS` | 209 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ANGLE_UP` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ANGLE_DOWN` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lump_t` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dmodel_t` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dheader_t` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dmiptexlump_t` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `miptex_t` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dvertex_t` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dplane_t` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dnode_t` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dclipnode_t` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `texinfo_t` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dedge_t` | 185 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dface_t` | 200 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dleaf_t` | 225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================ #ifndef QUAKE_GAME #define ANGLE_UP -1 #define ANGLE_DOWN -2 // the utilities get to be lazy and just use large static arrays extern int nummodels` | 225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dmodel_t dmodels[MAX_MAP_MODELS]` | 238 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int visdatasize` | 239 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte dvisdata[MAX_MAP_VISIBILITY]` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int lightdatasize` | 242 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte dlightdata[MAX_MAP_LIGHTING]` | 244 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int texdatasize` | 245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte dtexdata[MAX_MAP_MIPTEX]` | 247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char dentdata[MAX_MAP_ENTSTRING]` | 250 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numleafs` | 251 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dleaf_t dleafs[MAX_MAP_LEAFS]` | 253 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numplanes` | 254 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dplane_t dplanes[MAX_MAP_PLANES]` | 256 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numvertexes` | 257 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dvertex_t dvertexes[MAX_MAP_VERTS]` | 259 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numnodes` | 260 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dnode_t dnodes[MAX_MAP_NODES]` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numtexinfo` | 263 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern texinfo_t texinfo[MAX_MAP_TEXINFO]` | 265 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numfaces` | 266 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dface_t dfaces[MAX_MAP_FACES]` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numclipnodes` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dclipnode_t dclipnodes[MAX_MAP_CLIPNODES]` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numedges` | 272 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dedge_t dedges[MAX_MAP_EDGES]` | 274 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int nummarksurfaces` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern unsigned short dmarksurfaces[MAX_MAP_MARKSURFACES]` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numsurfedges` | 278 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int dsurfedges[MAX_MAP_SURFEDGES]` | 280 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `epair_t` | 299 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int num_entities` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t entities[MAX_MAP_ENTITIES]` | 309 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `DecompressVis` | 281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CompressVis` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `LoadBSPFile` | 285 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WriteBSPFile` | 287 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PrintBSPFileSizes` | 288 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ParseEntities` | 310 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `UnparseEntities` | 312 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SetKeyValue` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ValueForKey` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `FloatForKey` | 316 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GetVectorForKey` | 319 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ParseEpair` | 320 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cd_win.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `CDAudio_Eject` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_CloseDoor` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_GetAudioDiskInfo` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Play` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Stop` | 178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Pause` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Resume` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CD_f` | 243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_MessageHandler` | 363 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Update` | 398 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Init` | 421 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CDAudio_Shutdown` | 470 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t bgmvolume` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean cdValid = false` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean playing = false` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean wasPlaying = false` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean initialized = false` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean enabled = false` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean playLooping = false` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static float cdvolume` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static byte remap[100]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static byte cdrom` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static byte playTrack` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static byte maxTrack` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `UINT wDeviceID` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cdaudio.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `CDAudio_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CDAudio_Play` | 21 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CDAudio_Stop` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CDAudio_Pause` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CDAudio_Resume` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CDAudio_Shutdown` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CDAudio_Update` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `chase.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Chase_Init` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Chase_Reset` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `TraceLine` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Chase_Update` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t chase_pos` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t chase_angles` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t chase_dest` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t chase_dest_angles` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cl_demo.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `CL_StopPlayback` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_WriteDemoMessage` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_GetMessage` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_Stop_f` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_Record_f` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_PlayDemo_f` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_FinishTimeDemo` | 325 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_TimeDemo_f` | 347 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_FinishTimeDemo` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cl_input.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `KeyDown` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `KeyUp` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_KLookDown` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_KLookUp` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MLookDown` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MLookUp` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_UpDown` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_UpUp` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_DownDown` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_DownUp` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_LeftDown` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_LeftUp` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_RightDown` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_RightUp` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_ForwardDown` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_ForwardUp` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_BackDown` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_BackUp` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_LookupDown` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_LookupUp` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_LookdownDown` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_LookdownUp` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MoveleftDown` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MoveleftUp` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MoverightDown` | 143 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MoverightUp` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_SpeedDown` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_SpeedUp` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_StrafeDown` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_StrafeUp` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_AttackDown` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_AttackUp` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_UseDown` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_UseUp` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_JumpDown` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_JumpUp` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_Impulse` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_KeyState` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_AdjustAngles` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_BaseMove` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_SendMove` | 332 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_InitInput` | 409 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `kbutton_t in_left, in_right, in_forward, in_back` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `kbutton_t in_lookup, in_lookdown, in_moveleft, in_moveright` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `kbutton_t in_strafe, in_speed, in_use, in_jump, in_attack` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `kbutton_t in_up, in_down` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int in_impulse` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cl_main.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `CL_ClearState` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_Disconnect` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_Disconnect_f` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_EstablishConnection` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_SignonReply` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_NextDemo` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_PrintEntities_f` | 249 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SetPal` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_AllocDlight` | 317 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_DecayLights` | 362 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_LerpPoint` | 391 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_RelinkEntities` | 442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ReadFromServer` | 634 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_SendCmd` | 670 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_Init` | 717 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `client_static_t cls` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `client_state_t cl` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// FIXME: put these on hunk? efrag_t cl_efrags[MAX_EFRAGS]` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t cl_entities[MAX_EDICTS]` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t cl_static_entities[MAX_STATIC_ENTITIES]` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES]` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dlight_t cl_dlights[MAX_DLIGHTS]` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int cl_numvisedicts` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t *cl_visedicts[MAX_VISEDICTS]` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cl_parse.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `CL_EntityNum` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseStartSoundPacket` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_KeepaliveMessage` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseServerInfo` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseUpdate` | 330 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseBaseline` | 491 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseClientdata` | 514 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_NewTranslation` | 630 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseStatic` | 668 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseStaticSound` | 697 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseServerMessage` | 720 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SHOWNET` | 713 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ================== CL_ParseUpdate Parse an entity update message from the server If an entities model or origin changes from frame to frame, it must be relinked. Other attributes can change without relinking. ================== */ int bitcounts[16]` | 316 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cl_tent.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `CL_InitTEnts` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseBeam` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_ParseTEnt` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_NewTempEntity` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CL_UpdateTEnts` | 325 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t cl_temp_entities[MAX_TEMP_ENTITIES]` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `beam_t cl_beams[MAX_BEAMS]` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_wizhit` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_knighthit` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_tink1` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_ric1` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_ric2` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_ric3` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_r_exp3` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *cl_sfx_rail` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `client.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `usercmd_t` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `usercmd_t.vec3_t viewangles` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `usercmd_t.// intended velocities float forwardmove` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `usercmd_t.float sidemove` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `usercmd_t.float upmove` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `lightstyle_t` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lightstyle_t.int length` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lightstyle_t.char map[MAX_STYLESTRING]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `scoreboard_t` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `scoreboard_t.char name[MAX_SCOREBOARDNAME]` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `scoreboard_t.float entertime` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `scoreboard_t.int frags` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `scoreboard_t.int colors` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `scoreboard_t.// two 4 bit fields byte translations[VID_GRADES*256]` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `cshift_t` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cshift_t.int destcolor[3]` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cshift_t.int percent` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dlight_t` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dlight_t.vec3_t origin` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dlight_t.float radius` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dlight_t.float die` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dlight_t.// stop lighting after this time float decay` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dlight_t.// drop this each second float minlight` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dlight_t.// don't add when contributing less int key` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `beam_t` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `beam_t.int entity` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `beam_t.struct model_s *model` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `beam_t.float endtime` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `beam_t.vec3_t start, end` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `cactive_t` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `cactive_t.ca_dedicated` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `cactive_t.// a dedicated server with no ability to start a client ca_disconnected` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `cactive_t.// full screen console with no connection ca_connected // valid netcon` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `cactive_t.talking to a server` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `client_static_t` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.cactive_t state` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// personalization data sent to server char mapstring[MAX_QPATH]` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.char spawnparms[MAX_MAPSTRING]` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// to restart a level // demo loop control int demonum` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// -1 = don't play demos char demos[MAX_DEMOS][MAX_DEMONAME]` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// when not playing // demo recording info must be here, because record is started before // entering a map (and clearing client_state_t) qboolean demorecording` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.qboolean demoplayback` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.qboolean timedemo` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.int forcetrack` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// -1 = use normal cd track FILE *demofile` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.int td_lastframe` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// to meter out one message a frame int td_startframe` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// host_framecount at start float td_starttime` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// realtime at second frame of timedemo // connection information int signon` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.// 0 to SIGNONS struct qsocket_s *netcon` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_static_t.sizebuf_t message` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `client_state_t` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.int movemessages` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// since connecting to this server // throw out the first couple, so the player // doesn't accidentally do something the // first frame usercmd_t cmd` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// last command sent to the server // information for local display int stats[MAX_CL_STATS]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// health, etc int items` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// inventory bit flags float item_gettime[32]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// cl.time of aquiring item, for blinking float faceanimtime` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// use anim frame if cl.time < this cshift_t cshifts[NUM_CSHIFTS]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// color shifts for damage, powerups cshift_t prev_cshifts[NUM_CSHIFTS]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// and content types // the client maintains its own idea of view angles, which are // sent to the server each frame. The server sets punchangle when // the view is temporarliy offset, and an angle reset commands at the start // of each level and after teleporting. vec3_t mviewangles[2]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// during demo playback viewangles is lerped // between these vec3_t viewangles` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.vec3_t mvelocity[2]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// update by server, used for lean+bob // (0 is newest) vec3_t velocity` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// lerped between mvelocity[0] and [1] vec3_t punchangle` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// temporary offset // pitch drifting vars float idealpitch` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.float pitchvel` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.qboolean nodrift` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.float driftmove` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.double laststop` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.float viewheight` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.float crouch` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// local amount for smoothing stepups qboolean paused` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// send over by server qboolean onground` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.qboolean inwater` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.int intermission` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// don't change view angle, full screen, etc int completed_time` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// latched at intermission start double mtime[2]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// the timestamp of last two messages double time` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// clients view of time, should be between // servertime and oldservertime to generate // a lerp point for other data double oldtime` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// previous cl.time, time-oldtime is used // to decay light values and smooth step ups float last_received_message` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// (realtime) for net trouble icon // // information that is static for the entire time connected to a server // struct model_s *model_precache[MAX_MODELS]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.struct sfx_s *sound_precache[MAX_SOUNDS]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.char levelname[40]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// for display on solo scoreboard int viewentity` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// cl_entitites[cl.viewentity] = player int maxclients` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.int gametype` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// refresh related state struct model_s *worldmodel` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// cl_entitites[0].model struct efrag_s *free_efrags` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.int num_entities` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// held in cl_entities array int num_statics` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// held in cl_staticentities array entity_t viewent` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// the gun model int cdtrack, looptrack` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// cd audio // frag scoreboard scoreboard_t *scores` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_state_t.// [cl.maxclients] #ifdef QUAKE2 // light level at player's position including dlights // this is sent back to the server each frame // architectually ugly but it works int light_level` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `kbutton_t` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `kbutton_t.int down[2]` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `kbutton_t.// key nums holding it down int state` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CSHIFT_CONTENTS` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CSHIFT_DAMAGE` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CSHIFT_BONUS` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CSHIFT_POWERUP` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_CSHIFTS` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NAME_LENGTH` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIGNONS` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_DLIGHTS` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_BEAMS` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_EFRAGS` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MAPSTRING` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_DEMOS` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_DEMONAME` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_TEMP_ENTITIES` | 272 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_STATIC_ENTITIES` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_VISEDICTS` | 306 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `usercmd_t` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lightstyle_t` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `scoreboard_t` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cshift_t` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dlight_t` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `beam_t` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cactive_t` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `client_static_t` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern client_static_t cls` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `client_state_t` | 235 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // cvars // extern cvar_t cl_name` | 235 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_color` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_upspeed` | 242 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_forwardspeed` | 244 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_backspeed` | 245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_sidespeed` | 246 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_movespeedkey` | 247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_yawspeed` | 249 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_pitchspeed` | 251 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_anglespeedkey` | 252 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_autofire` | 254 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_shownet` | 256 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_nolerp` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t cl_pitchdriftspeed` | 259 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t lookspring` | 261 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t lookstrafe` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t sensitivity` | 263 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t m_pitch` | 264 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t m_yaw` | 266 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t m_forward` | 267 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t m_side` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// FIXME, allocate dynamically extern efrag_t cl_efrags[MAX_EFRAGS]` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t cl_entities[MAX_EDICTS]` | 278 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t cl_static_entities[MAX_STATIC_ENTITIES]` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern lightstyle_t cl_lightstyle[MAX_LIGHTSTYLES]` | 280 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dlight_t cl_dlights[MAX_DLIGHTS]` | 281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t cl_temp_entities[MAX_TEMP_ENTITIES]` | 282 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern beam_t cl_beams[MAX_BEAMS]` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t *cl_visedicts[MAX_VISEDICTS]` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `kbutton_t` | 317 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern kbutton_t in_mlook, in_klook` | 317 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern kbutton_t in_strafe` | 319 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern kbutton_t in_speed` | 320 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_AllocDlight` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_DecayLights` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Init` | 292 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_EstablishConnection` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Signon1` | 296 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Signon2` | 297 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Signon3` | 298 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Signon4` | 299 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Disconnect` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Disconnect_f` | 302 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_NextDemo` | 303 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_InitInput` | 321 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_SendCmd` | 323 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_SendMove` | 324 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_ParseTEnt` | 325 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_UpdateTEnts` | 327 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_ClearState` | 328 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_ReadFromServer` | 330 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_WriteToServer` | 333 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_BaseMove` | 334 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_KeyState` | 335 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_KeynumToString` | 338 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_StopPlayback` | 339 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_GetMessage` | 344 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Stop_f` | 345 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_Record_f` | 347 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_PlayDemo_f` | 348 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_TimeDemo_f` | 349 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_ParseServerMessage` | 350 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_NewTranslation` | 355 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_StartPitchDrift` | 356 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_StopPitchDrift` | 361 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_RenderView` | 362 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_UpdatePalette` | 364 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_Register` | 365 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_ParseDamage` | 366 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_SetContentsColor` | 367 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_InitTEnts` | 368 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CL_SignonReply` | 374 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cmd.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Cmd_Wait_f` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cbuf_Init` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cbuf_AddText` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cbuf_InsertText` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cbuf_Execute` | 143 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_StuffCmds_f` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Exec_f` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Echo_f` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CopyString` | 332 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Alias_f` | 341 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Init` | 428 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Argc` | 446 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Argv` | 456 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Args` | 468 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_TokenizeString` | 481 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_AddCommand` | 532 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_Exists` | 568 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_CompleteCommand` | 588 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_ExecuteString` | 614 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_ForwardToServer` | 660 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cmd_CheckParm` | 693 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `cmdalias_t` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cmdalias_t.struct cmdalias_s *next` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cmdalias_t.char name[MAX_ALIAS_NAME]` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cmdalias_t.char *value` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `cmd_function_t` | 403 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cmd_function_t.struct cmd_function_s *next` | 403 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cmd_function_t.char *name` | 403 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cmd_function_t.xcommand_t function` | 403 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_ALIAS_NAME` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_ARGS` | 411 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cmdalias_t` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cmdalias_t *cmd_alias` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int trashtest` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int *trashspot` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean cmd_wait` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================= COMMAND BUFFER ============================================================================= */ sizebuf_t cmd_text` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cmd_function_t` | 408 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static char *cmd_argv[MAX_ARGS]` | 413 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static char *cmd_null_string = ""` | 414 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static char *cmd_args = NULL` | 415 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cmd_source_t cmd_source` | 416 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static cmd_function_t *cmd_functions` | 418 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_ForwardToServer` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cmd.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `cmd_source_t` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `cmd_source_t.src_client` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `cmd_source_t.// came in over a net connection as a clc_stringcmd // host_client will be valid during this state. src_command // from the command buffer` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cmd_source_t` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cmd_source_t cmd_source` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cbuf_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cbuf_AddText` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cbuf_InsertText` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cbuf_Execute` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Init` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_AddCommand` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Exists` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_CompleteCommand` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Argc` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Argv` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Args` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Argv` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `position` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_ExecuteString` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_ForwardToServer` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Print` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `common.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `ClearLink` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `RemoveLink` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `InsertLinkBefore` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `InsertLinkAfter` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_memset` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_memcpy` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_memcmp` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strcpy` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strncpy` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strlen` | 199 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strrchr` | 210 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strcat` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strcmp` | 225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strncmp` | 240 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strncasecmp` | 257 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_strcasecmp` | 287 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_atoi` | 292 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_atof` | 351 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ShortSwap` | 443 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ShortNoSwap` | 453 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `LongSwap` | 458 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `LongNoSwap` | 470 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FloatSwap` | 475 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FloatNoSwap` | 492 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteChar` | 510 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteByte` | 523 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteShort` | 536 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteLong` | 550 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteFloat` | 561 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteString` | 576 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteCoord` | 584 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_WriteAngle` | 589 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_BeginReading` | 600 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadChar` | 607 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadByte` | 623 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadShort` | 639 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadLong` | 657 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadFloat` | 677 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadString` | 697 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadCoord` | 717 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MSG_ReadAngle` | 722 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SZ_Alloc` | 731 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SZ_Free` | 741 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SZ_Clear` | 749 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SZ_GetSpace` | 754 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SZ_Write` | 777 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SZ_Print` | 782 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_SkipPath` | 804 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_StripExtension` | 823 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_FileExtension` | 835 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_FileBase` | 856 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_DefaultExtension` | 884 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_Parse` | 911 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_CheckParm` | 990 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_CheckRegistered` | 1015 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_InitArgv` | 1057 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_Init` | 1125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `va` | 1169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `memsearch` | 1183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_Path_f` | 1258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_WriteFile` | 1281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_CreatePath` | 1308 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_CopyFile` | 1332 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_FindFile` | 1365 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_OpenFile` | 1485 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_FOpenFile` | 1498 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_CloseFile` | 1510 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_LoadFile` | 1533 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_LoadHunkFile` | 1581 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_LoadTempFile` | 1586 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_LoadCacheFile` | 1591 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_LoadStackFile` | 1598 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_LoadPackFile` | 1619 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_AddGameDirectory` | 1689 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `COM_InitFilesystem` | 1732 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `packfile_t` | 1208 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `packfile_t.char name[MAX_QPATH]` | 1208 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `packfile_t.int filepos, filelen` | 1208 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `pack_t` | 1214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pack_t.char filename[MAX_OSPATH]` | 1214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pack_t.int handle` | 1214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pack_t.int numfiles` | 1214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pack_t.packfile_t *files` | 1214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dpackfile_t` | 1225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dpackfile_t.char name[56]` | 1225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dpackfile_t.int filepos, filelen` | 1225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dpackheader_t` | 1231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dpackheader_t.char id[4]` | 1231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dpackheader_t.int dirofs` | 1231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dpackheader_t.int dirlen` | 1231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `searchpath_t` | 1243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `searchpath_t.char filename[MAX_OSPATH]` | 1243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `searchpath_t.pack_t *pack` | 1243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `searchpath_t.// only one of filename / pack will be used struct searchpath_s *next` | 1243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_SAFE_ARGVS` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PAK0_COUNT` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PAK0_CRC` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CMDLINE_LENGTH` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_FILES_IN_PACK` | 1238 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static char *argvdummy = " "` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean com_modified` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// set true if using non-id files qboolean proghack` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int static_registered = 1` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// only for startup check, then set qboolean msg_suppress_1 = 0` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if a packfile directory differs from this, it is assumed to be hacked #define PAK0_COUNT 339 #define PAK0_CRC 32981 char com_token[1024]` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int com_argc` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char **com_argv` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean standard_quake = true, rogue, hipnotic` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================ BYTE ORDER FUNCTIONS ============================================================================ */ qboolean bigendien` | 424 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // reading functions // int msg_readcount` | 592 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean msg_badread` | 597 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================= QUAKE FILESYSTEM ============================================================================= */ int com_filesize` | 1191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `packfile_t` | 1212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `pack_t` | 1220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dpackfile_t` | 1229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dpackheader_t` | 1236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char com_gamedir[MAX_OSPATH]` | 1240 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `searchpath_t` | 1248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `searchpath_t *com_searchpaths` | 1248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============ COM_LoadFile Filename are reletive to the quake directory. Allways appends a 0 byte. ============ */ cache_user_t *loadcache` | 1519 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *loadbuf` | 1530 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int loadsize` | 1531 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_InitFilesystem` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `short` | 434 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `short` | 436 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 437 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 438 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `float` | 439 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `float` | 440 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_Path_f` | 1046 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `common.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `qboolean` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `qboolean.false` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `qboolean.true` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `sizebuf_t` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sizebuf_t.qboolean allowoverflow` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sizebuf_t.// if false, do a Sys_Error qboolean overflowed` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sizebuf_t.// set to true if the buffer size failed byte *data` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sizebuf_t.int maxsize` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sizebuf_t.int cursize` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `link_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `link_t.struct link_s *prev, *next` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BYTE_DEFINED` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STRUCT_FROM_LINK` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NULL` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MAXCHAR` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MAXSHORT` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MAXINT` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MAXLONG` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MAXFLOAT` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MINCHAR` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MINSHORT` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MININT` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MINLONG` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `Q_MINFLOAT` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sizebuf_t` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `link_t` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int msg_readcount` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean msg_badread` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================ extern char com_token[1024]` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean com_eof` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int com_argc` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char **com_argv` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// does a varargs printf into a temp buffer //============================================================================ extern int com_filesize` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `struct cache_user_s` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char com_gamedir[MAX_OSPATH]` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern struct cvar_s registered` | 178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean standard_quake, rogue, hipnotic` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SZ_Alloc` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SZ_Free` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SZ_Clear` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SZ_GetSpace` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SZ_Write` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SZ_Print` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ClearLink` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `RemoveLink` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `InsertLinkBefore` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `InsertLinkAfter` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `short` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `short` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `float` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `float` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteChar` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteByte` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteShort` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteLong` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteFloat` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteString` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteCoord` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_WriteAngle` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_BeginReading` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadChar` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadByte` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadShort` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadLong` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadFloat` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadString` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadCoord` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MSG_ReadAngle` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_memset` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_memcpy` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_memcmp` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strcpy` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strncpy` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strlen` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strrchr` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strcat` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strcmp` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strncmp` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strcasecmp` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_strncasecmp` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_atoi` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_atof` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_Parse` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_CheckParm` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_Init` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_InitArgv` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_SkipPath` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_StripExtension` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_FileBase` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_DefaultExtension` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `va` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_WriteFile` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_OpenFile` | 170 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_FOpenFile` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_CloseFile` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_LoadStackFile` | 173 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_LoadTempFile` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_LoadHunkFile` | 176 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `COM_LoadCacheFile` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `conproc.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `InitConProc` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DeinitConProc` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `RequestProc` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetMappedBuffer` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ReleaseMappedBuffer` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetScreenBufferLines` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SetScreenBufferLines` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ReadText` | 195 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WriteText` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CharToCode` | 265 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SetConsoleCXCY` | 290 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HANDLE hfileBuffer` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HANDLE heventChildSend` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HANDLE heventParentSend` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HANDLE hStdout` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HANDLE hStdin` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `RequestProc` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GetMappedBuffer` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ReleaseMappedBuffer` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GetScreenBufferLines` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SetScreenBufferLines` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ReadText` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WriteText` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CharToCode` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SetConsoleCXCY` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `conproc.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| macro | `CCOM_WRITE_TEXT` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCOM_GET_TEXT` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCOM_GET_SCR_LINES` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCOM_SET_SCR_LINES` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `InitConProc` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `DeinitConProc` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `console.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Con_ToggleConsole_f` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_Clear_f` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_ClearNotify` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_MessageMode_f` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_MessageMode2_f` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_CheckResize` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_Init` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_Linefeed` | 254 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_Print` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_DebugLog` | 353 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_Printf` | 377 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_DPrintf` | 424 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_SafePrintf` | 447 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_DrawInput` | 480 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_DrawNotify` | 520 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_DrawConsole` | 580 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Con_NotifyBox` | 621 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CON_TEXTSIZE` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_CON_TIMES` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXCMDLINE` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXGAMEDIRLEN` | 214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXPRINTMSG` | 375 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float con_cursorspeed = 4` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// because no entities to refresh int con_totallines` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// total lines in console scrollback int con_backscroll` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// lines up from bottom to display int con_current` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// where next message will be printed int con_x` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// offset in current line for next print char *con_text=0` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//seconds #define NUM_CON_TIMES 4 float con_times[NUM_CON_TIMES]` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// realtime time the line was generated // for transparent notify lines int con_vislines` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean con_debuglog` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int edit_line` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int key_linepos` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean con_initialized` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int con_notifylines` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ================ Con_MessageMode_f ================ */ extern qboolean team_message` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Main_f` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `console.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| global | `extern int con_backscroll` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean con_forcedup` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// because no entities to refresh extern qboolean con_initialized` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte *con_chars` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int con_notifylines` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_DrawCharacter` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_CheckResize` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_Init` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_DrawConsole` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_Print` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_Printf` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_DPrintf` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_SafePrintf` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_Clear_f` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_DrawNotify` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_ClearNotify` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_ToggleConsole_f` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Con_NotifyBox` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `crc.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `CRC_Init` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CRC_ProcessByte` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CRC_Value` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CRC_INIT_VALUE` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CRC_XOR_VALUE` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `crc.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `CRC_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CRC_ProcessByte` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CRC_Value` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cvar.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Cvar_FindVar` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_VariableValue` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_VariableString` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_CompleteVariable` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_Set` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_SetValue` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_RegisterVariable` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_Command` | 187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cvar_WriteVariables` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char *cvar_null_string = ""` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `cvar.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `cvar_t` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cvar_t.char *name` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cvar_t.char *string` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cvar_t.qboolean archive` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cvar_t.// set to true to cause it to be saved to vars.rc qboolean server` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cvar_t.// notifies players when changed float value` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cvar_t.struct cvar_s *next` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cvar_t` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t *cvar_vars` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_RegisterVariable` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_Set` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_SetValue` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_VariableValue` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_VariableString` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_CompleteVariable` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_Command` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cmd_Argv` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cvar_FindVar` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `d_iface.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `emitpoint_t` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `emitpoint_t.float u, v` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `emitpoint_t.float s, t` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `emitpoint_t.float zi` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `ptype_t` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_static` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_grav` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_slowgrav` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_fire` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_explode` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_explode2` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_blob` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_blob2` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `particle_t` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.// driver-usable fields vec3_t org` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.float color` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.// drivers never touch the following fields struct particle_s *next` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.vec3_t vel` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.float ramp` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.float die` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.ptype_t type` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `polyvert_t` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `polyvert_t.float u, v, zi, s, t` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `polydesc_t` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `polydesc_t.int numverts` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `polydesc_t.float nearzi` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `polydesc_t.msurface_t *pcurrentface` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `polydesc_t.polyvert_t *pverts` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `finalvert_t` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `finalvert_t.int v[6]` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `finalvert_t.// u, v, s, t, l, 1/z int flags` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `finalvert_t.float reserved` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `affinetridesc_t` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.void *pskin` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.maliasskindesc_t *pskindesc` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.int skinwidth` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.int skinheight` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.mtriangle_t *ptriangles` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.finalvert_t *pfinalverts` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.int numtriangles` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.int drawtype` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `affinetridesc_t.int seamfixupX16` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `screenpart_t` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `screenpart_t.float u, v, zi, color` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `spritedesc_t` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `spritedesc_t.int nump` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `spritedesc_t.emitpoint_t *pverts` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `spritedesc_t.// there's room for an extra element at [nump], // if the driver wants to duplicate element [0] at // element [nump] to avoid dealing with wrapping mspriteframe_t *pspriteframe` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `spritedesc_t.vec3_t vup, vright, vpn` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `spritedesc_t.// in worldspace float nearzi` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `zpointdesc_t` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `zpointdesc_t.int u, v` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `zpointdesc_t.float zi` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `zpointdesc_t.int color` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `drawsurf_t` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.pixel_t *surfdat` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// destination for generated surface int rowbytes` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// destination logical width in bytes msurface_t *surf` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// description for surface to generate fixed8_t lightadj[MAXLIGHTMAPS]` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// adjust for lightmap levels for dynamic lighting texture_t *texture` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// corrected for animating textures int surfmip` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// mipmapped ratio of surface texels / world pixels int surfwidth` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// in mipmapped texels int surfheight` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WARP_WIDTH` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WARP_HEIGHT` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_LBM_HEIGHT` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PARTICLE_Z_CLIP` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DR_SOLID` | 179 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DR_TRANSPARENT` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TRANSPARENT_COLOR` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TURB_TEX_SIZE` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CYCLE` | 214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TILE_SIZE` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKYSHIFT` | 218 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKYSIZE` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKYMASK` | 220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `emitpoint_t` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `ptype_t` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `particle_t` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `polyvert_t` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `polydesc_t` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `finalvert_t` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `affinetridesc_t` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `screenpart_t` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `spritedesc_t` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `zpointdesc_t` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_drawflat` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int d_spanpixcount` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_framecount` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// sequence # of current frame since Quake // started extern qboolean r_drawpolys` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 1 if driver wants clipped polygons // rather than a span list extern qboolean r_drawculledpolys` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 1 if driver wants clipped polygons that // have been culled by the edge list extern qboolean r_worldpolysbacktofront` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 1 if driver wants polygons // delivered back to front rather // than front to back extern qboolean r_recursiveaffinetriangles` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// scale-up factor for screen u and v // on Alias vertices passed to driver extern int r_pixbytes` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean r_dowarp` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern affinetridesc_t r_affinetridesc` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern spritedesc_t r_spritedesc` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern zpointdesc_t r_zpointdesc` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern polydesc_t r_polydesc` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int d_con_indirect` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if 0, Quake will draw console directly // to vid.buffer; if 1, Quake will // draw console via D_DrawRect. Must be // defined by driver extern vec3_t r_pright, r_pup, r_ppn` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// these are currently for internal use only, and should not be used by drivers extern int r_skydirect` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte *r_skysource` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `drawsurf_t` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern drawsurf_t r_drawsurf` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float skytime` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int c_surf` | 223 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vrect_t scr_vrect` | 225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte *r_warpbuffer` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_Aff8Patch` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_BeginDirectRect` | 145 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DisableBackBufferAccess` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_EndDirectRect` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_PolysetDraw` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_PolysetDrawFinalVerts` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawParticle` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawPoly` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawSprite` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawSurfaces` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawZPoint` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_EnableBackBufferAccess` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_EndParticles` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_Init` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_ViewChanged` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_SetupFrame` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_StartParticles` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_TurnZOn` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_WarpScreen` | 162 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_FillRect` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawRect` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_UpdateRects` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_PolysetUpdateTables` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSurface` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_GenTile` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `dosisms.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `regs_t` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.struct { unsigned long edi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long esi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long ebp` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long res` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long ebx` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long edx` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long ecx` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned long eax` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.} d` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.struct { unsigned short di, di_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short si, si_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short bp, bp_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short res, res_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short bx, bx_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short dx, dx_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short cx, cx_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short ax, ax_hi` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short flags` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short es` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short ds` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short fs` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short gs` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short ip` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short cs` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short sp` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned short ss` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.} x` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.struct { unsigned char edi[4]` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char esi[4]` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char ebp[4]` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char res[4]` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char bl, bh, ebx_b2, ebx_b3` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char dl, dh, edx_b2, edx_b3` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char cl, ch, ecx_b2, ecx_b3` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.unsigned char al, ah, eax_b2, eax_b3` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `regs_t.} h` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `_DOSISMS_H_` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `regs_t` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern regs_t regs` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_lockmem` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_unlockmem` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ptr2real` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `real2ptr` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `far2ptr` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ptr2far` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_inportb` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_inportw` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_outportb` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_outportw` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_irqenable` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_irqdisable` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_registerintr` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_restoreintr` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_int86` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_getmemory` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_freememory` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_usleep` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `dos_getheapsize` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `draw.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `Draw_Init` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_Character` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_DebugChar` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_Pic` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_TransPic` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_TransPicTranslate` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_ConsoleBackground` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_BeginDisc` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_EndDisc` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_TileClear` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_Fill` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_FadeScreen` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_String` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_PicFromWad` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Draw_CachePic` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_draw.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `GL_Bind` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Scrap_AllocBlock` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Scrap_Upload` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_PicFromWad` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_CachePic` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_CharToConback` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_TextureMode_f` | 320 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_Init` | 368 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_Character` | 497 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_String` | 540 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_DebugChar` | 559 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_AlphaPic` | 568 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_Pic` | 605 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_TransPic` | 635 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_TransPicTranslate` | 658 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_ConsoleBackground` | 708 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_TileClear` | 727 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_Fill` | 751 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_FadeScreen` | 777 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_BeginDisc` | 807 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Draw_EndDisc` | 825 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_Set2D` | 836 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_FindTexture` | 863 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_ResampleTexture` | 882 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_Resample8BitTexture` | 912 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_MipMap` | 945 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_MipMap8Bit` | 972 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_Upload32` | 1004 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_Upload8_EXT` | 1089 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_Upload8` | 1185 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_LoadTexture` | 1234 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_LoadPicTexture` | 1278 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_SelectTexture` | 1287 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `glpic_t` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpic_t.int texnum` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpic_t.float sl, tl, sh, th` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `gltexture_t` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `gltexture_t.int texnum` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `gltexture_t.char identifier[64]` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `gltexture_t.int width, height` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `gltexture_t.qboolean mipmap` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `cachepic_t` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cachepic_t.char name[MAX_QPATH]` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cachepic_t.qpic_t pic` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cachepic_t.byte padding[32]` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `glmode_t` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glmode_t.char *name` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glmode_t.int minimize, maximize` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GL_COLOR_INDEX8_EXT` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_GLTEXTURES` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SCRAPS` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BLOCK_WIDTH` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BLOCK_HEIGHT` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_CACHED_PICS` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *draw_chars` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 8*8 graphic characters qpic_t *draw_disc` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *draw_backtile` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int translate_texture` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int char_texture` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glpic_t` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int gl_lightmap_format = 4` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int gl_solid_format = 3` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int gl_alpha_format = 4` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int gl_filter_min = GL_LINEAR_MIPMAP_NEAREST` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int gl_filter_max = GL_LINEAR` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int texels` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `gltexture_t` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int numgltextures` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================= scrap allocation Allocate all the little status bar obejcts into a single texture to crutch up stupid hardware / drivers ============================================================================= */ #define MAX_SCRAPS 2 #define BLOCK_WIDTH 256 #define BLOCK_HEIGHT 256 int scrap_allocated[MAX_SCRAPS][BLOCK_WIDTH]` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte scrap_texels[MAX_SCRAPS][BLOCK_WIDTH*BLOCK_HEIGHT*4]` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean scrap_dirty` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scrap_texnum` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scrap_uploads` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cachepic_t` | 173 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int menu_numcachepics` | 176 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte menuplyr_pixels[4096]` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int pic_texels` | 179 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int pic_count` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glmode_t` | 304 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/****************************************/ static GLenum oldtarget = TEXTURE0_SGIS` | 1281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_mesh.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `StripLength` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FanLength` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `BuildTris` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_MakeAliasModelDisplayLists` | 290 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `aliashdr_t *paliashdr` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean used[8192]` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// the command list holds counts and s/t values that are valid for // every frame int commands[8192]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int numcommands` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// all frames will have their vertexes rearranged and expanded // so they are in the order expected by the command list int vertexorder[8192]` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int numorder` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int allverts, alltris` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int stripverts[128]` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int striptris[128]` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int stripcount` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_model.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Mod_Init` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_Extradata` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_PointInLeaf` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_DecompressVis` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LeafPVS` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_ClearAll` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_FindName` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_TouchModel` | 217 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadModel` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_ForName` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadTextures` | 339 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadLighting` | 495 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadVisibility` | 512 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadEntities` | 529 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadVertexes` | 546 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadSubmodels` | 574 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadEdges` | 610 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadTexinfo` | 637 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CalcSurfaceExtents` | 705 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadFaces` | 757 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_SetParent` | 832 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadNodes` | 846 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadLeafs` | 893 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadClipnodes` | 947 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_MakeHull0` | 1001 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadMarksurfaces` | 1038 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadSurfedges` | 1067 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadPlanes` | 1091 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `RadiusFromBounds` | 1129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadBrushModel` | 1147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadAliasFrame` | 1252 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadAliasGroup` | 1288 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_FloodFillSkin` | 1360 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadAllSkins` | 1411 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadAliasModel` | 1489 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadSpriteFrame` | 1655 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadSpriteGroup` | 1698 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_LoadSpriteModel` | 1750 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Mod_Print` | 1828 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `floodfill_t` | 1338 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `floodfill_t.short x, y` | 1338 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MOD_KNOWN` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ANIM_CYCLE` | 461 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FLOODFILL_FIFO_SIZE` | 1346 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FLOODFILL_FIFO_MASK` | 1347 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FLOODFILL_STEP` | 1349 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char loadname[32]` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte mod_novis[MAX_MAP_LEAFS/8]` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int mod_numknown` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============================================================================== BRUSHMODEL LOADING =============================================================================== */ byte *mod_base` | 320 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================== ALIAS MODELS ============================================================================== */ aliashdr_t *pheader` | 1224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `stvert_t stverts[MAXALIASVERTS]` | 1234 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mtriangle_t triangles[MAXALIASTRIS]` | 1236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// a pose is a single set of vertexes. a frame may be // an animating sequence of poses trivertx_t *poseverts[MAXALIASFRAMES]` | 1237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int posenum` | 1241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte **player_8bit_texels_tbl` | 1242 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *player_8bit_texels` | 1244 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `floodfill_t` | 1341 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern unsigned d_8to24table[]` | 1341 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_LoadSpriteModel` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_LoadBrushModel` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_LoadAliasModel` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_LoadModel` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_model.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `mvertex_t` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mvertex_t.vec3_t position` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mplane_t` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.vec3_t normal` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.float dist` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.byte type` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.// for texture axis selection and fast side tests byte signbits` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.// signx + signy<<1 + signz<<1 byte pad[2]` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `texture_t` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.char name[16]` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.unsigned width, height` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.int gl_texturenum` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.struct msurface_s *texturechain` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// for gl_texsort drawing int anim_total` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// total tenths in sequence ( 0 = no) int anim_min, anim_max` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// time for this frame min <=time< max struct texture_s *anim_next` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// in the animation sequence struct texture_s *alternate_anims` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// bmodels in frmae 1 use these unsigned offsets[MIPLEVELS]` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `medge_t` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `medge_t.unsigned short v[2]` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `medge_t.unsigned int cachededgeoffset` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mtexinfo_t` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.float vecs[2][4]` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.float mipadjust` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.texture_t *texture` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.int flags` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `glpoly_t` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpoly_t.struct glpoly_s *next` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpoly_t.struct glpoly_s *chain` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpoly_t.int numverts` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpoly_t.int flags` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glpoly_t.// for SURF_UNDERWATER float verts[4][VERTEXSIZE]` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `msurface_t` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int visframe` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// should be drawn when node is crossed mplane_t *plane` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int flags` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int firstedge` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// look up in model->surfedges[], negative numbers int numedges` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// are backwards edges short texturemins[2]` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.short extents[2]` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int light_s, light_t` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// gl lightmap coordinates glpoly_t *polys` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// multiple if warped struct msurface_s *texturechain` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.mtexinfo_t *texinfo` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// lighting info int dlightframe` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int dlightbits` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int lightmaptexturenum` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.byte styles[MAXLIGHTMAPS]` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int cached_light[MAXLIGHTMAPS]` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// values currently used in lightmap qboolean cached_dlight` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// true if dynamic light in cache byte *samples` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mnode_t` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// common with leaf int contents` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// 0, to differentiate from leafs int visframe` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// node needs to be traversed if current float minmaxs[6]` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// for bounding box culling struct mnode_s *parent` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// node specific mplane_t *plane` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.struct mnode_s *children[2]` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.unsigned short firstsurface` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.unsigned short numsurfaces` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mleaf_t` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// common with node int contents` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// wil be a negative contents number int visframe` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// node needs to be traversed if current float minmaxs[6]` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// for bounding box culling struct mnode_s *parent` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// leaf specific byte *compressed_vis` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.efrag_t *efrags` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.msurface_t **firstmarksurface` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.int nummarksurfaces` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.int key` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// BSP sequence number for leaf's contents byte ambient_sound_level[NUM_AMBIENTS]` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `hull_t` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.dclipnode_t *clipnodes` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.mplane_t *planes` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.int firstclipnode` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.int lastclipnode` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.vec3_t clip_mins` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.vec3_t clip_maxs` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mspriteframe_t` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.int width` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.int height` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.float up, down, left, right` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.int gl_texturenum` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mspritegroup_t` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspritegroup_t.int numframes` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspritegroup_t.float *intervals` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspritegroup_t.mspriteframe_t *frames[1]` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mspriteframedesc_t` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframedesc_t.spriteframetype_t type` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframedesc_t.mspriteframe_t *frameptr` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `msprite_t` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int type` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int maxwidth` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int maxheight` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int numframes` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.float beamlength` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.// remove? void *cachespot` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.// remove? mspriteframedesc_t frames[1]` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasframedesc_t` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.int firstpose` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.int numposes` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.float interval` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.trivertx_t bboxmin` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.trivertx_t bboxmax` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.int frame` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.char name[16]` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasgroupframedesc_t` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroupframedesc_t.trivertx_t bboxmin` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroupframedesc_t.trivertx_t bboxmax` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroupframedesc_t.int frame` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasgroup_t` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroup_t.int numframes` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroup_t.int intervals` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroup_t.maliasgroupframedesc_t frames[1]` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mtriangle_t` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtriangle_t.int facesfront` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtriangle_t.int vertindex[3]` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `aliashdr_t` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int ident` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int version` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.vec3_t scale` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.vec3_t scale_origin` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.float boundingradius` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.vec3_t eyeposition` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int numskins` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int skinwidth` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int skinheight` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int numverts` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int numtris` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int numframes` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.synctype_t synctype` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int flags` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.float size` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int numposes` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int poseverts` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int posedata` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.// numposes*poseverts trivert_t int commands` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.// gl command list with embedded s/t int gl_texturenum[MAX_SKINS][4]` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int texels[MAX_SKINS]` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.// only for player skins maliasframedesc_t frames[1]` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `modtype_t` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modtype_t.mod_brush` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modtype_t.mod_sprite` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modtype_t.mod_alias` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `model_t` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.char name[MAX_QPATH]` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.qboolean needload` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// bmodels and sprites don't cache normally modtype_t type` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numframes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.synctype_t synctype` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int flags` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // volume occupied by the model graphics // vec3_t mins, maxs` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.float radius` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // solid volume for clipping // qboolean clipbox` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.vec3_t clipmins, clipmaxs` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // brush model // int firstmodelsurface, nummodelsurfaces` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numsubmodels` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.dmodel_t *submodels` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numplanes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mplane_t *planes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numleafs` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// number of visible leafs, not counting 0 mleaf_t *leafs` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numvertexes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mvertex_t *vertexes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numedges` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.medge_t *edges` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numnodes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mnode_t *nodes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numtexinfo` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mtexinfo_t *texinfo` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numsurfaces` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.msurface_t *surfaces` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numsurfedges` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int *surfedges` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numclipnodes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.dclipnode_t *clipnodes` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int nummarksurfaces` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.msurface_t **marksurfaces` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.hull_t hulls[MAX_MAP_HULLS]` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numtextures` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.texture_t **textures` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.byte *visdata` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.byte *lightdata` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.char *entities` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // additional model data // cache_user_t cache` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `__MODEL__` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_BRIGHTFIELD` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_MUZZLEFLASH` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_BRIGHTLIGHT` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_DIMLIGHT` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIDE_FRONT` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIDE_BACK` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIDE_ON` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_PLANEBACK` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWSKY` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWSPRITE` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWTURB` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWTILED` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWBACKGROUND` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_UNDERWATER` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VERTEXSIZE` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SKINS` | 290 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXALIASVERTS` | 317 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXALIASFRAMES` | 318 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXALIASTRIS` | 319 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_ROCKET` | 333 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_GRENADE` | 334 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_GIB` | 335 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_ROTATE` | 336 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_TRACER` | 337 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_ZOMGIB` | 338 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_TRACER2` | 339 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_TRACER3` | 340 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mvertex_t` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mplane_t` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `texture_t` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `medge_t` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mtexinfo_t` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glpoly_t` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `msurface_t` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mnode_t` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mleaf_t` | 193 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `hull_t` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mspriteframe_t` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mspritegroup_t` | 229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mspriteframedesc_t` | 235 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `msprite_t` | 246 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasframedesc_t` | 267 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasgroupframedesc_t` | 274 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasgroup_t` | 281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mtriangle_t` | 287 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `aliashdr_t` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern stvert_t stverts[MAXALIASVERTS]` | 320 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mtriangle_t triangles[MAXALIASTRIS]` | 321 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern trivertx_t *poseverts[MAXALIASFRAMES]` | 322 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `modtype_t` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `model_t` | 417 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_Init` | 417 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_ClearAll` | 421 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_ForName` | 422 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_Extradata` | 423 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_TouchModel` | 424 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_PointInLeaf` | 425 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_LeafPVS` | 427 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_refrag.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `R_RemoveEfrags` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_SplitEntityOnNode` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_AddEfrags` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_StoreEfrags` | 197 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//=========================================================================== /* =============================================================================== ENTITY FRAGMENT FUNCTIONS =============================================================================== */ efrag_t **lastlink` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t r_emins, r_emaxs` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t *r_addent` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_rlight.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `R_AnimateLight` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `AddLightBlend` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RenderDlight` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RenderDlights` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_MarkLights` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_PushDlights` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `RecursiveLightPoint` | 236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_LightPoint` | 335 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================= LIGHT SAMPLING ============================================================================= */ mplane_t *lightplane` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t lightspot` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_rmain.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `R_CullBox` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RotateForEntity` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_GetSpriteFrame` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawSpriteModel` | 197 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_DrawAliasFrame` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_DrawAliasShadow` | 347 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_SetupAliasFrame` | 415 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawAliasModel` | 446 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawEntitiesOnList` | 602 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawViewModel` | 647 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_PolyBlend` | 718 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SignbitsForPlane` | 753 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_SetFrustum` | 769 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_SetupFrame` | 810 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MYgluPerspective` | 844 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_SetupGL` | 864 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RenderScene` | 949 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_Clear` | 983 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_Mirror` | 1035 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RenderView` | 1104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUMVERTEXNORMALS` | 265 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SHADEDOT_QUANT` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean r_cache_thrash` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// compatability vec3_t modelorg, r_entorigin` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t *currententity` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int r_visframecount` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// bumped when going to a new PVS int r_framecount` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// used for dlight push checking mplane_t frustum[4]` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int c_brush_polys, c_alias_polys` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean envmap` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// true during envmap command capture int currenttexture = -1` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// cached int particletexture` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// little dot for particles int playertextures` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// up to 16 color translated skins int mirrortexturenum` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// quake texturenum, not gltexturenum qboolean mirror` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mplane_t *mirror_plane` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // view origin // vec3_t vup` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t vpn` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t vright` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t r_origin` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float r_world_matrix[16]` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float r_base_world_matrix[16]` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // screen size info // refdef_t r_refdef` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mleaf_t *r_viewleaf, *r_oldviewleaf` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `texture_t *r_notexture_mip` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int d_lightstylevalue[256]` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_ztrick` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t shadevector` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float shadelight, ambientlight` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// precalculated dot products for quantized angles #define SHADEDOT_QUANT 16 float r_avertexnormal_dots[SHADEDOT_QUANT][256] = #include "anorm_dots.h"` | 272 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float *shadedots = r_avertexnormal_dots[0]` | 278 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int lastposenum` | 280 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============= GL_DrawAliasShadow ============= */ extern vec3_t lightspot` | 337 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_MarkLeaves` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_rmisc.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `R_InitTextures` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_InitParticleTexture` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_Envmap_f` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_Init` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_TranslatePlayerSkin` | 230 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_NewMap` | 379 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_TimeRefresh_f` | 425 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `D_FlushCaches` | 451 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_rsurf.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `R_AddDynamicLights` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_BuildLightMap` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_TextureAnimation` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_DisableMultitexture` | 286 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_EnableMultitexture` | 295 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawSequentialPoly` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawSequentialPoly` | 410 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DrawGLWaterPoly` | 593 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DrawGLWaterPolyLightmap` | 617 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DrawGLPoly` | 646 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_BlendLightmaps` | 667 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RenderBrushPoly` | 754 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RenderDynamicLightmaps` | 832 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_MirrorChain` | 890 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawWaterSurfaces` | 905 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawWaterSurfaces` | 954 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DrawTextureChains` | 1026 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawBrushModel` | 1075 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RecursiveWorldNode` | 1187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawWorld` | 1313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_MarkLeaves` | 1349 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `AllocBlock` | 1400 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `BuildSurfaceDisplayList` | 1452 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_CreateSurfaceLightmap` | 1572 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_BuildLightmaps` | 1598 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `glRect_t` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glRect_t.unsigned char l,t,w,h` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GL_RGBA4` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BLOCK_WIDTH` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BLOCK_HEIGHT` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_LIGHTMAPS` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `COLINEAR_EPSILON` | 1544 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 1, 2, or 4 int lightmap_textures` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `unsigned blocklights[18*18]` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glRect_t` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glpoly_t *lightmap_polys[MAX_LIGHTMAPS]` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean lightmap_modified[MAX_LIGHTMAPS]` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glRect_t lightmap_rectchange[MAX_LIGHTMAPS]` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int allocated[MAX_LIGHTMAPS][BLOCK_WIDTH]` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// the lightmap texture data needs to be kept in // main memory so texsubimage can update properly byte lightmaps[4*MAX_LIGHTMAPS*BLOCK_WIDTH*BLOCK_HEIGHT]` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// For gl_texsort 0 msurface_t *skychain = NULL` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `msurface_t *waterchain = NULL` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================= BRUSH MODELS ============================================================= */ extern int solidskytexture` | 260 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int alphaskytexture` | 272 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float speedscale` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lpMTexFUNC qglMTexCoord2fSGIS = NULL` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lpSelTexFUNC qglSelectTextureSGIS = NULL` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean mtexenabled = false` | 280 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mvertex_t *r_pcurrentvertbase` | 1439 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `model_t *currentmodel` | 1442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int nColinElim` | 1443 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RenderDynamicLightmaps` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `DrawGLWaterPoly` | 274 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `DrawGLWaterPolyLightmap` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_SelectTexture` | 282 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_screen.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SCR_CenterPrint` | 143 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawCenterString` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_CheckDrawCenterString` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CalcFov` | 230 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_CalcRefdef` | 255 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_SizeUp_f` | 343 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_SizeDown_f` | 357 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_Init` | 370 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawRam` | 404 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawTurtle` | 420 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawNet` | 445 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawPause` | 460 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawLoading` | 482 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_SetUpToDrawConsole` | 504 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawConsole` | 554 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_ScreenShot_f` | 592 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_BeginLoadingPlaque` | 653 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_EndLoadingPlaque` | 684 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_DrawNotifyString` | 696 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_ModalMessage` | 736 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_BringDownConsole` | 773 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_TileClear` | 786 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SCR_UpdateScreen` | 821 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `TargaHeader` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned char id_length, colormap_type, image_type` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned short colormap_index, colormap_length` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned char colormap_size` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned short x_origin, y_origin, width, height` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned char pixel_size, attributes` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// only the refresh window will be updated unless these variables are flagged int scr_copytop` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scr_copyeverything` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float scr_con_current` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float scr_conlines` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// lines of console to display float oldscreensize, oldfov` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t crosshair` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean scr_initialized` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// ready to draw qpic_t *scr_ram` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *scr_net` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *scr_turtle` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scr_fullupdate` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int clearconsole` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int clearnotify` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int sb_lines` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `viddef_t vid` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// global video state vrect_t scr_vrect` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean scr_disabled_for_loading` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean scr_drawloading` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float scr_disabled_time` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean block_drawing` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============================================================================== CENTER PRINTING =============================================================================== */ char scr_centerstring[1024]` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float scr_centertime_start` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// for slow victory printing float scr_centertime_off` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scr_center_lines` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scr_erase_lines` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scr_erase_center` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `TargaHeader` | 584 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= char *scr_notifystring` | 689 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean scr_drawdialog` | 693 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_ScreenShot_f` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_test.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Test_Init` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `HitPlane` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Test_Spawn` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DrawPuff` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Test_Draw` | 170 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `puff_t` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.plane_t *plane` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.vec3_t origin` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.vec3_t normal` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.vec3_t up` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.vec3_t right` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.vec3_t reflect` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `puff_t.float length` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_PUFFS` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `puff_t` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `plane_t junk` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_vidnt.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `VID_HandlePause` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_ForceLockState` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_LockBuffer` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_UnlockBuffer` | 173 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_ForceUnlockedAndReturnState` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `D_BeginDirectRect` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `D_EndDirectRect` | 186 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CenterWindow` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_SetWindowedMode` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_SetFullDIBMode` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_SetMode` | 373 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_UpdateWindowStatus` | 481 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CheckTextureExtensions` | 502 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CheckArrayExtensions` | 541 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CheckMultiTextureExtensions` | 578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CheckMultiTextureExtensions` | 588 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_Init` | 599 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_BeginRendering` | 659 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_EndRendering` | 674 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_SetPalette` | 703 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_ShiftPalette` | 765 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_SetDefaultMode` | 775 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_Shutdown` | 781 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `bSetupPixelFormat` | 814 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MapKey` | 907 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ClearAllStates` | 930 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `AppActivate` | 944 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MainWndProc` | 1016 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_NumModes` | 1147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_GetModePtr` | 1158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_GetModeDescription` | 1173 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_GetExtModeDescription` | 1201 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_DescribeCurrentMode_f` | 1240 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_NumModes_f` | 1251 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_DescribeMode_f` | 1266 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_DescribeModes_f` | 1286 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_InitDIB` | 1308 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_InitFullDIB` | 1365 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_Is8bit` | 1506 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_Init8bitPalette` | 1512 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Check_Gamma` | 1539 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_Init` | 1573 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_MenuDraw` | 1865 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VID_MenuKey` | 1937 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `vmode_t` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.modestate_t type` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int width` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int height` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int modenum` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int dib` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int fullscreen` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int bpp` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.int halfscreen` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vmode_t.char modedesc[17]` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `lmode_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lmode_t.int width` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lmode_t.int height` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `modedesc_t` | 1847 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `modedesc_t.int modenum` | 1847 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `modedesc_t.char *desc` | 1847 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `modedesc_t.int iscur` | 1847 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MODE_LIST` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VID_ROW_SIZE` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WARP_WIDTH` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WARP_HEIGHT` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXWIDTH` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXHEIGHT` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BASEWIDTH` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BASEHEIGHT` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MODE_WINDOWED` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NO_MODE` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MODE_FULLSCREEN_DEFAULT` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TEXTURE_EXT_STRING` | 499 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GL_SHARED_TEXTURE_PALETTE_EXT` | 1510 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_COLUMN_SIZE` | 1854 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MODE_AREA_HEIGHT` | 1855 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MODEDESCS` | 1856 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vmode_t` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lmode_t` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `const char *gl_vendor` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `const char *gl_renderer` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `const char *gl_version` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `const char *gl_extensions` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean DDActive` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean scr_skipupdate` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static vmode_t modelist[MAX_MODE_LIST]` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int nummodes` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static vmode_t *pcurrentmode` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static vmode_t badmode` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static DEVMODE gdevmode` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean vid_initialized = false` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean windowed, leavecurrentmode` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean vid_canalttab = false` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean vid_wassuspended = false` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int windowed_mouse` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean mouseactive` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// from in_win.c static HICON hIcon` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int DIBWidth, DIBHeight` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `RECT WindowRect` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD WindowStyle, ExWindowStyle` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HWND mainwindow, dibwindow` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int vid_modenum = NO_MODE` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int vid_realmode` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int vid_default = MODE_WINDOWED` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int windowed_default` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `unsigned char vid_curpal[256*3]` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean fullsbardraw = false` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static float vid_gamma = 1.0` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HGLRC baseRC` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HDC maindc` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glvert_t glv` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `viddef_t vid` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// global video state unsigned short d_8to16table[256]` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `unsigned d_8to24table[256]` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `unsigned char d_15to8table[65536]` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float gldepthmin, gldepthmax` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `modestate_t modestate = MS_UNINIT` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `PROC glArrayElementEXT` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `PROC glColorPointerEXT` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `PROC glTexCoordPointerEXT` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `PROC glVertexPointerEXT` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lp3DFXFUNC glColorTableEXT` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean is8bit = false` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean isPermedia = false` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean gl_mtexable = false` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int window_center_x, window_center_y, window_x, window_y, window_width, window_height` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `RECT window_rect` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//==================================== BINDTEXFUNCPTR bindTexFunc` | 492 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//int texture_mode = GL_NEAREST; //int texture_mode = GL_NEAREST_MIPMAP_NEAREST; //int texture_mode = GL_NEAREST_MIPMAP_LINEAR; int texture_mode = GL_LINEAR` | 566 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//int texture_mode = GL_LINEAR_MIPMAP_NEAREST; //int texture_mode = GL_LINEAR_MIPMAP_LINEAR; int texture_extension_number = 1` | 571 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `BOOL gammaworks` | 761 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int vid_line, vid_wmodes` | 1843 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `modedesc_t` | 1852 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `InitializeWindow` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_MenuDraw` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_MenuKey` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MainWndProc` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `AppActivate` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_GetModeDescription` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ClearAllStates` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_UpdateWindowStatus` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_Init` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Options_f` | 1831 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Print` | 1838 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_PrintWhite` | 1839 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_DrawCharacter` | 1840 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_DrawTransPic` | 1841 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_DrawPic` | 1842 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_warp.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `BoundPoly` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SubdividePolygon` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GL_SubdivideSurface` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `EmitWaterPolys` | 194 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `EmitSkyPolys` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `EmitBothSkyLayers` | 274 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawSkyChain` | 304 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `LoadPCX` | 376 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `fgetLittleShort` | 460 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `fgetLittleLong` | 470 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `LoadTGA` | 488 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_LoadSkys` | 642 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DrawSkyPolygon` | 717 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ClipSkyPolygon` | 799 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawSkyChain` | 895 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ClearSkyBox` | 927 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MakeSkyVec` | 939 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawSkyBox` | 982 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_InitSky` | 1034 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `pcx_t` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char manufacturer` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char version` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char encoding` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char bits_per_pixel` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.unsigned short xmin,ymin,xmax,ymax` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.unsigned short hres,vres` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.unsigned char palette[48]` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char reserved` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char color_planes` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.unsigned short bytes_per_line` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.unsigned short palette_type` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.char filler[58]` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `pcx_t.unsigned data` | 352 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `TargaHeader` | 448 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned char id_length, colormap_type, image_type` | 448 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned short colormap_index, colormap_length` | 448 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned char colormap_size` | 448 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned short x_origin, y_origin, width, height` | 448 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `TargaHeader.unsigned char pixel_size, attributes` | 448 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TURBSCALE` | 185 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKY_TEX` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_CLIP_VERTS` | 798 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int skytexturenum` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int solidskytexture` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int alphaskytexture` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float speedscale` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// for top sky and bottom sky msurface_t *warpface` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_subdivide_size` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `pcx_t` | 367 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *pcx_rgb` | 367 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `TargaHeader` | 454 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `TargaHeader targa_header` | 454 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *targa_rgba` | 457 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int c_sky` | 680 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float skymins[2][6], skymaxs[2][6]` | 713 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `gl_warp_sin.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `glquake.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `glvert_t` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glvert_t.float x, y, z` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glvert_t.float s, t` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `glvert_t.float r, g, b` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `surfcache_t` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.struct surfcache_s *next` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.struct surfcache_s **owner` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.// NULL is an empty chunk of memory int lightadj[MAXLIGHTMAPS]` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.// checked for strobe flush int dlight` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.int size` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.// including header unsigned width` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.unsigned height` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.// DEBUG only needed for debug float mipscale` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.struct texture_s *texture` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surfcache_t.// checked for animating textures byte data[4]` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `drawsurf_t` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.pixel_t *surfdat` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// destination for generated surface int rowbytes` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// destination logical width in bytes msurface_t *surf` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// description for surface to generate fixed8_t lightadj[MAXLIGHTMAPS]` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// adjust for lightmap levels for dynamic lighting texture_t *texture` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// corrected for animating textures int surfmip` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// mipmapped ratio of surface texels / world pixels int surfwidth` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `drawsurf_t.// in mipmapped texels int surfheight` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `ptype_t` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_static` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_grav` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_slowgrav` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_fire` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_explode` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_explode2` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_blob` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `ptype_t.pt_blob2` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `particle_t` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.// driver-usable fields vec3_t org` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.float color` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.// drivers never touch the following fields struct particle_s *next` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.vec3_t vel` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.float ramp` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.float die` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `particle_t.ptype_t type` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_BASE_SIZE_RATIO` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_LBM_HEIGHT` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TILE_SIZE` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKYSHIFT` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKYSIZE` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SKYMASK` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BACKFACE_EPSILON` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TEXTURE0_SGIS` | 236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TEXTURE1_SGIS` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `APIENTRY` | 240 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern BINDTEXFUNCPTR bindTexFunc` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern DELTEXFUNCPTR delTexFunc` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern TEXSUBIMAGEPTR TexSubImage2DFunc` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int texture_mode` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float gldepthmin, gldepthmax` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `glvert_t` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern glvert_t glv` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int glx, gly, glwidth, glheight` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern PROC glColorPointerEXT` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern PROC glTexturePointerEXT` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern PROC glVertexPointerEXT` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `surfcache_t` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `drawsurf_t` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `ptype_t` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `particle_t` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//==================================================== extern entity_t r_worldentity` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean r_cache_thrash` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// compatability extern vec3_t modelorg, r_entorigin` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t *currententity` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_visframecount` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// ??? what difs? extern int r_framecount` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mplane_t frustum[4]` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int c_brush_polys, c_alias_polys` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // view origin // extern vec3_t vup` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t vpn` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t vright` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t r_origin` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // screen size info // extern refdef_t r_refdef` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mleaf_t *r_viewleaf, *r_oldviewleaf` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern texture_t *r_notexture_mip` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int d_lightstylevalue[256]` | 176 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 8.8 fraction of base light value extern qboolean envmap` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int currenttexture` | 179 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int cnttextures[2]` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int particletexture` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int playertextures` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int skytexturenum` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// index in cl.loadmodel, not gl texture object extern cvar_t r_norefresh` | 185 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_drawentities` | 187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_drawworld` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_drawviewmodel` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_speeds` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_waterwarp` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_fullbright` | 192 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_lightmap` | 193 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_shadows` | 194 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_mirroralpha` | 195 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_wateralpha` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_dynamic` | 197 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_novis` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_clear` | 199 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_cull` | 201 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_poly` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_texsort` | 203 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_smoothmodels` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_affinemodels` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_polyblend` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_keeptjunctions` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_reporttjunctions` | 208 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_flashblend` | 209 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_nocolors` | 210 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_doubleeyes` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int gl_lightmap_format` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int gl_solid_format` | 214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int gl_alpha_format` | 215 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_max_size` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t gl_playermip` | 218 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int mirrortexturenum` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// quake texturenum, not gltexturenum extern qboolean mirror` | 221 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mplane_t *mirror_plane` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float r_world_matrix[16]` | 223 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern const char *gl_vendor` | 225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern const char *gl_renderer` | 227 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern const char *gl_version` | 228 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern const char *gl_extensions` | 229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern lpMTexFUNC qglMTexCoord2fSGIS` | 244 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern lpSelTexFUNC qglSelectTextureSGIS` | 245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean gl_mtexable` | 246 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `warning` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_EndRendering` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_Upload32` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_Upload8` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_LoadTexture` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_FindTexture` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ReadPointFile_f` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TextureAnimation` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TranslatePlayerSkin` | 230 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_Bind` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_DisableMultitexture` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GL_EnableMultitexture` | 250 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `host.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Host_EndGame` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Error` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_FindMaxClients` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_InitLocal` | 209 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_WriteConfiguration` | 246 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ClientPrintf` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_BroadcastPrintf` | 297 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_ClientCommands` | 322 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_DropClient` | 343 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_ShutdownServer` | 405 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_ClearMemory` | 477 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_FilterTime` | 501 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_GetConsoleCommands` | 532 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_Host_ServerFrame` | 554 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_ServerFrame` | 568 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_ServerFrame` | 600 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_Host_Frame` | 633 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Frame` | 729 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_InitVCR` | 772 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Init` | 835 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Shutdown` | 932 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VCR_SIGNATURE` | 769 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean host_initialized` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// true if into command execution double host_frametime` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `double host_time` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `double realtime` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// without any filtering or bounding double oldrealtime` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// last frame run int host_framecount` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int host_hunklevel` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int minimum_memory` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `client_t *host_client` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// current client jmp_buf host_abortserver` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *host_basepal` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *host_colormap` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================ extern int vcrFile` | 763 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `host_cmd.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Host_Quit_f` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Status_f` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_God_f` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Notarget_f` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Noclip_f` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Fly_f` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Ping_f` | 213 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Map_f` | 256 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Changelevel_f` | 311 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Restart_f` | 366 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Reconnect_f` | 396 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Connect_f` | 409 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_SavegameComment` | 442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Savegame_f` | 465 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Loadgame_f` | 561 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SaveGamestate` | 710 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `LoadGamestate` | 761 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Changelevel2_f` | 865 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Name_f` | 910 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Version_f` | 949 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Please_f` | 956 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Say` | 1008 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Say_f` | 1072 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Say_Team_f` | 1078 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Tell_f` | 1084 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Color_f` | 1141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Kill_f` | 1192 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Pause_f` | 1217 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_PreSpawn_f` | 1254 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Spawn_f` | 1279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Begin_f` | 1403 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Kick_f` | 1424 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Give_f` | 1516 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FindViewthing` | 1670 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Viewmodel_f` | 1690 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Viewframe_f` | 1715 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PrintFrameName` | 1734 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Viewnext_f` | 1752 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Viewprev_f` | 1774 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Startdemos_f` | 1806 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Demos_f` | 1845 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_Stopdemo_f` | 1862 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Host_InitCommands` | 1879 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SAVEGAME_VERSION` | 433 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int current_skill` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean noclip_anglehack` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_Print` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Quit_f` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `in_win.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Force_CenterView_f` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_UpdateClipCursor` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_ShowMouse` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_HideMouse` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_ActivateMouse` | 221 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_SetQuakeMouseState` | 263 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_DeactivateMouse` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_RestoreOriginalMouseState` | 312 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_InitDInput` | 332 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_StartupMouse` | 423 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_Init` | 484 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_Shutdown` | 524 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MouseEvent` | 549 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_MouseMove` | 581 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_Move` | 738 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_Accumulate` | 754 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_ClearStates` | 780 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_StartupJoystick` | 797 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `RawValuePointer` | 866 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Joy_AdvancedUpdate_f` | 891 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_Commands` | 963 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_ReadJoystick` | 1033 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IN_JoyMove` | 1068 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `MYDATA` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.LONG lX` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.// X axis goes here LONG lY` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.// Y axis goes here LONG lZ` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.// Z axis goes here BYTE bButtonA` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.// One button goes here BYTE bButtonB` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.// Another button goes here BYTE bButtonC` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `MYDATA.// Another button goes here BYTE bButtonD` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `_ControlList` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `_ControlList.AxisNada = 0` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `_ControlList.AxisForward` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `_ControlList.AxisLook` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `_ControlList.AxisSide` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `_ControlList.AxisTurn` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DINPUT_BUFFERSIZE` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `iDirectInputCreate` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_ABSOLUTE_AXIS` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_RELATIVE_AXIS` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_MAX_AXES` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_AXIS_X` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_AXIS_Y` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_AXIS_Z` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_AXIS_R` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_AXIS_U` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JOY_AXIS_V` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_OBJECTS` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int mouse_buttons` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int mouse_oldbuttonstate` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `POINT current_pos` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int mouse_x, mouse_y, old_mouse_x, old_mouse_y, mx_accum, my_accum` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean restore_spi` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `unsigned int uiWheelMessage` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean mouseactive` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean mouseinitialized` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean mouseparmsvalid, mouseactivatetoggle` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean mouseshowtoggle = 1` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean dinput_acquired` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static unsigned int mstate_di` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD dwAxisMap[JOY_MAX_AXES]` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD dwControlMap[JOY_MAX_AXES]` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `PDWORD pdwRawValue[JOY_MAX_AXES]` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean joy_avail, joy_advancedinit, joy_haspov` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD joy_oldbuttonstate, joy_oldpovstate` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int joy_id` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD joy_flags` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD joy_numbuttons` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static LPDIRECTINPUT g_pdi` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static LPDIRECTINPUTDEVICE g_pMouse` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static JOYINFOEX ji` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static HINSTANCE hInstDI` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean dinput` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `MYDATA` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `iDirectInputCreate` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_StartupJoystick` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Joy_AdvancedUpdate_f` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_JoyMove` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `input.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `external` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_Shutdown` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_Commands` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_Move` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_ClearStates` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `keys.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Key_Console` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_Message` | 282 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_StringToKeynum` | 341 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_KeynumToString` | 367 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_SetBinding` | 394 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_Unbind_f` | 422 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_Unbindall_f` | 442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_Bind_f` | 457 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_WriteBindings` | 504 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_Init` | 520 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_Event` | 599 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Key_ClearStates` | 749 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `keyname_t` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `keyname_t.char *name` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `keyname_t.int keynum` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXCMDLINE` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int key_linepos` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int shift_down=false` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int key_lastpress` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int edit_line=0` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int history_line=0` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `keydest_t key_dest` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int key_count` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// incremented every key event char *keybindings[256]` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean consolekeys[256]` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if true, can't be rebound while in console qboolean menubound[256]` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if true, can't be rebound while in menu int keyshift[256]` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// key to map to if shift held down in console int key_repeats[256]` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if > 1, it is autorepeating qboolean keydown[256]` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `keyname_t` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================ char chat_buffer[32]` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean team_message = false` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `keys.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `keydest_t` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `keydest_t.key_game` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `keydest_t.key_console` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `keydest_t.key_message` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `keydest_t.key_menu` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_TAB` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_ENTER` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_ESCAPE` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_SPACE` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_BACKSPACE` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_UPARROW` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_DOWNARROW` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_LEFTARROW` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_RIGHTARROW` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_ALT` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_CTRL` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_SHIFT` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F1` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F2` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F3` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F4` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F5` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F6` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F7` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F8` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F9` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F10` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F11` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_F12` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_INS` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_DEL` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_PGDN` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_PGUP` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_HOME` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_END` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_PAUSE` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_MOUSE1` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_MOUSE2` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_MOUSE3` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_JOY1` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_JOY2` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_JOY3` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_JOY4` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX1` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX2` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX3` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX4` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX5` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX6` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX7` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX8` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX9` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX10` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX11` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX12` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX13` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX14` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX15` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX16` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX17` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX18` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX19` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX20` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX21` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX22` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX23` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX24` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX25` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX26` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX27` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX28` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX29` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX30` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX31` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_AUX32` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_MWHEELUP` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `K_MWHEELDOWN` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `keydest_t` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern keydest_t key_dest` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char *keybindings[256]` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int key_repeats[256]` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int key_count` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// incremented every key event extern int key_lastpress` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_Event` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_Init` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_WriteBindings` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_SetBinding` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_ClearStates` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `math.s`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `mathlib.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `ProjectPointOnPlane` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PerpendicularVector` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `RotatePointAroundVector` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `anglemod` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `BOPS_Error` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `BoxOnPlaneSide` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `AngleVectors` | 292 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VectorCompare` | 318 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VectorMA` | 329 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_DotProduct` | 337 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_VectorSubtract` | 342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_VectorAdd` | 349 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_VectorCopy` | 356 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CrossProduct` | 363 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Length` | 372 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VectorNormalize` | 385 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VectorInverse` | 404 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VectorScale` | 411 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Q_log2` | 419 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ConcatRotations` | 433 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ConcatTransforms` | 461 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FloorDivMod` | 500 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GreatestCommonDivisor` | 547 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Invert24To16` | 576 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEG2RAD` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int nanmask = 255<<23` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_Error` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `sqrt` | 368 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `mathlib.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| macro | `M_PI` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IS_NAN` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DotProduct` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VectorSubtract` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VectorAdd` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VectorCopy` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BOX_ON_PLANE_SIDE` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t vec3_origin` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int nanmask` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VectorMA` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `_DotProduct` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `_VectorSubtract` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `_VectorAdd` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `_VectorCopy` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VectorCompare` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Length` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CrossProduct` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VectorNormalize` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VectorInverse` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VectorScale` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Q_log2` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ConcatRotations` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ConcatTransforms` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `FloorDivMod` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Invert24To16` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GreatestCommonDivisor` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `AngleVectors` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `BoxOnPlaneSide` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `anglemod` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `menu.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `M_DrawCharacter` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Print` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_PrintWhite` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_DrawTransPic` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_DrawPic` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_BuildTranslationTable` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_DrawTransPicTranslate` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_DrawTextBox` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ToggleMenu_f` | 245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Main_f` | 278 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Main_Draw` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Main_Key` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_SinglePlayer_f` | 366 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_SinglePlayer_Draw` | 374 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_SinglePlayer_Key` | 390 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ScanSaves` | 446 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Load_f` | 474 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Save_f` | 483 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Load_Draw` | 498 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Save_Draw` | 514 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Load_Key` | 530 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Save_Key` | 572 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_MultiPlayer_f` | 611 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_MultiPlayer_Draw` | 619 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_MultiPlayer_Key` | 639 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Setup_f` | 695 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Setup_Draw` | 707 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Setup_Key` | 745 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Net_f` | 885 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Net_Draw` | 899 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Net_Key` | 978 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Options_f` | 1049 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_AdjustSliders` | 1064 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_DrawSlider` | 1149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_DrawCheckbox` | 1164 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Options_Draw` | 1178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Options_Key` | 1239 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Keys_f` | 1342 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_FindKeysForCommand` | 1350 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_UnbindCommand` | 1376 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Keys_Draw` | 1395 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Keys_Key` | 1446 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Video_f` | 1509 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Video_Draw` | 1517 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Video_Key` | 1523 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Help_f` | 1535 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Help_Draw` | 1545 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Help_Key` | 1551 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Quit_f` | 1629 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Quit_Key` | 1642 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Quit_Draw` | 1674 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_SerialConfig_f` | 1733 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_SerialConfig_Draw` | 1774 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_SerialConfig_Key` | 1841 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_ModemConfig_f` | 2017 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ModemConfig_Draw` | 2026 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ModemConfig_Key` | 2067 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_LanConfig_f` | 2188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_LanConfig_Draw` | 2210 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_LanConfig_Key` | 2269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_GameOptions_f` | 2532 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_GameOptions_Draw` | 2548 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_NetStart_Change` | 2673 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_GameOptions_Key` | 2775 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_Search_f` | 2842 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Search_Draw` | 2855 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Search_Key` | 2892 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Menu_ServerList_f` | 2902 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ServerList_Draw` | 2914 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ServerList_Key` | 2955 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Init` | 3003 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Draw` | 3021 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_Keydown` | 3137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `M_ConfigureNetSubsystem` | 3219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `level_t` | 2382 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `level_t.char *name` | 2382 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `level_t.char *description` | 2382 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `episode_t` | 2487 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `episode_t.char *description` | 2487 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `episode_t.int firstLevel` | 2487 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `episode_t.int levels` | 2487 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `StartingGame` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `JoiningGame` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SerialConfig` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DirectConfig` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IPXConfig` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TCPIPConfig` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAIN_ITEMS` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SINGLEPLAYER_ITEMS` | 363 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SAVEGAMES` | 442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MULTIPLAYER_ITEMS` | 608 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_SETUP_CMDS` | 693 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OPTIONS_ITEMS` | 1040 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OPTIONS_ITEMS` | 1042 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SLIDER_RANGE` | 1045 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUMCOMMANDS` | 1337 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_HELP_PAGES` | 1532 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_SERIALCONFIG_CMDS` | 1722 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_MODEMCONFIG_CMDS` | 2010 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_LANCONFIG_CMDS` | 2182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_GAMEOPTIONS` | 2545 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `m_state` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean m_entersound` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// play after drawing a frame, so caching // won't disrupt the sound qboolean m_recursiveDraw` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int m_return_state` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean m_return_onerror` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char m_return_reason [32]` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte identityTable[256]` | 145 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte translationTable[256]` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= int m_save_demonum` | 234 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* MAIN MENU */ int m_main_cursor` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* SINGLE PLAYER MENU */ int m_singleplayer_cursor` | 357 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* LOAD/SAVE MENU */ int load_cursor` | 435 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 0 < load_cursor < MAX_SAVEGAMES #define MAX_SAVEGAMES 12 char m_filenames[MAX_SAVEGAMES][SAVEGAME_COMMENT_LENGTH+1]` | 440 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int loadable[MAX_SAVEGAMES]` | 443 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* MULTIPLAYER MENU */ int m_multiplayer_cursor` | 602 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* SETUP MENU */ int setup_cursor = 4` | 678 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char setup_hostname[16]` | 684 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char setup_myname[16]` | 686 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int setup_oldtop` | 687 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int setup_oldbottom` | 688 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int setup_top` | 689 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int setup_bottom` | 690 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* NET MENU */ int m_net_cursor` | 852 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int m_net_items` | 857 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int m_net_saveHeight` | 858 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* OPTIONS MENU */ #ifdef _WIN32 #define OPTIONS_ITEMS 14 #else #define OPTIONS_ITEMS 13 #endif #define SLIDER_RANGE 10 int options_cursor` | 1034 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int bind_grab` | 1339 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* HELP MENU */ int help_page` | 1526 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* QUIT MENU */ int msgNumber` | 1574 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int m_quit_prevstate` | 1579 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean wasInMenus` | 1580 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* SERIAL CONFIG MENU */ int serialConfig_cursor` | 1714 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int serialConfig_comport` | 1726 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int serialConfig_irq` | 1728 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int serialConfig_baud` | 1729 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char serialConfig_phone[16]` | 1730 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* MODEM CONFIG MENU */ int modemConfig_cursor` | 2003 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char modemConfig_clear [16]` | 2012 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char modemConfig_init [32]` | 2013 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char modemConfig_hangup [16]` | 2014 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* LAN CONFIG MENU */ int lanConfig_cursor = -1` | 2175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char lanConfig_portname[6]` | 2184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char lanConfig_joinname[22]` | 2185 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `level_t` | 2386 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `episode_t` | 2492 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int startepisode` | 2524 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int startlevel` | 2526 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int maxplayers` | 2527 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean m_serverInfoMessage = false` | 2528 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `double m_serverInfoMessageTime` | 2529 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* SEARCH MENU */ qboolean searchComplete = false` | 2834 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `double searchCompleteTime` | 2839 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= /* SLIST MENU */ int slist_cursor` | 2894 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean slist_sorted` | 2899 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Main_f` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_SinglePlayer_f` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Load_f` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Save_f` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_MultiPlayer_f` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Setup_f` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Net_f` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Options_f` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Keys_f` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Video_f` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Help_f` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Quit_f` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_SerialConfig_f` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_ModemConfig_f` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_LanConfig_f` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_GameOptions_f` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_Search_f` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Menu_ServerList_f` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Main_Draw` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_SinglePlayer_Draw` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Load_Draw` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Save_Draw` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_MultiPlayer_Draw` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Setup_Draw` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Net_Draw` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Options_Draw` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Keys_Draw` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Video_Draw` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Help_Draw` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Quit_Draw` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_SerialConfig_Draw` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_ModemConfig_Draw` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_LanConfig_Draw` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_GameOptions_Draw` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Search_Draw` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_ServerList_Draw` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Main_Key` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_SinglePlayer_Key` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Load_Key` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Save_Key` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_MultiPlayer_Key` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Setup_Key` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Net_Key` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Options_Key` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Keys_Key` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Video_Key` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Help_Key` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Quit_Key` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_SerialConfig_Key` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_ModemConfig_Key` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_LanConfig_Key` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_GameOptions_Key` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Search_Key` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_ServerList_Key` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `menu.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| macro | `MNET_IPX` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MNET_TCP` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Init` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Keydown` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_Draw` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_ToggleMenu_f` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `model.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `mvertex_t` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mvertex_t.vec3_t position` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mplane_t` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.vec3_t normal` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.float dist` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.byte type` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.// for texture axis selection and fast side tests byte signbits` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mplane_t.// signx + signy<<1 + signz<<1 byte pad[2]` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `texture_t` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.char name[16]` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.unsigned width, height` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.int anim_total` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// total tenths in sequence ( 0 = no) int anim_min, anim_max` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// time for this frame min <=time< max struct texture_s *anim_next` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// in the animation sequence struct texture_s *alternate_anims` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `texture_t.// bmodels in frmae 1 use these unsigned offsets[MIPLEVELS]` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `medge_t` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `medge_t.unsigned short v[2]` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `medge_t.unsigned int cachededgeoffset` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mtexinfo_t` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.float vecs[2][4]` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.float mipadjust` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.texture_t *texture` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtexinfo_t.int flags` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `msurface_t` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int visframe` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// should be drawn when node is crossed int dlightframe` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int dlightbits` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.mplane_t *plane` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int flags` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.int firstedge` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// look up in model->surfedges[], negative numbers int numedges` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// are backwards edges // surface generation data struct surfcache_s *cachespots[MIPLEVELS]` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.short texturemins[2]` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.short extents[2]` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.mtexinfo_t *texinfo` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.// lighting info byte styles[MAXLIGHTMAPS]` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msurface_t.byte *samples` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mnode_t` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// common with leaf int contents` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// 0, to differentiate from leafs int visframe` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// node needs to be traversed if current short minmaxs[6]` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// for bounding box culling struct mnode_s *parent` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.// node specific mplane_t *plane` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.struct mnode_s *children[2]` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.unsigned short firstsurface` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mnode_t.unsigned short numsurfaces` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mleaf_t` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// common with node int contents` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// wil be a negative contents number int visframe` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// node needs to be traversed if current short minmaxs[6]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// for bounding box culling struct mnode_s *parent` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// leaf specific byte *compressed_vis` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.efrag_t *efrags` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.msurface_t **firstmarksurface` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.int nummarksurfaces` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.int key` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mleaf_t.// BSP sequence number for leaf's contents byte ambient_sound_level[NUM_AMBIENTS]` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `hull_t` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.dclipnode_t *clipnodes` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.mplane_t *planes` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.int firstclipnode` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.int lastclipnode` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.vec3_t clip_mins` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hull_t.vec3_t clip_maxs` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mspriteframe_t` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.int width` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.int height` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.void *pcachespot` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.// remove? float up, down, left, right` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframe_t.byte pixels[4]` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mspritegroup_t` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspritegroup_t.int numframes` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspritegroup_t.float *intervals` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspritegroup_t.mspriteframe_t *frames[1]` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mspriteframedesc_t` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframedesc_t.spriteframetype_t type` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mspriteframedesc_t.mspriteframe_t *frameptr` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `msprite_t` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int type` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int maxwidth` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int maxheight` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.int numframes` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.float beamlength` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.// remove? void *cachespot` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `msprite_t.// remove? mspriteframedesc_t frames[1]` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasframedesc_t` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.aliasframetype_t type` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.trivertx_t bboxmin` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.trivertx_t bboxmax` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.int frame` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasframedesc_t.char name[16]` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasskindesc_t` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasskindesc_t.aliasskintype_t type` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasskindesc_t.void *pcachespot` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasskindesc_t.int skin` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasgroupframedesc_t` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroupframedesc_t.trivertx_t bboxmin` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroupframedesc_t.trivertx_t bboxmax` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroupframedesc_t.int frame` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasgroup_t` | 255 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroup_t.int numframes` | 255 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroup_t.int intervals` | 255 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasgroup_t.maliasgroupframedesc_t frames[1]` | 255 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `maliasskingroup_t` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasskingroup_t.int numskins` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasskingroup_t.int intervals` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `maliasskingroup_t.maliasskindesc_t skindescs[1]` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mtriangle_t` | 270 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtriangle_t.int facesfront` | 270 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mtriangle_t.int vertindex[3]` | 270 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `aliashdr_t` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int model` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int stverts` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int skindesc` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.int triangles` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `aliashdr_t.maliasframedesc_t frames[1]` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `modtype_t` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modtype_t.mod_brush` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modtype_t.mod_sprite` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modtype_t.mod_alias` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `model_t` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.char name[MAX_QPATH]` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.qboolean needload` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// bmodels and sprites don't cache normally modtype_t type` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numframes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.synctype_t synctype` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int flags` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // volume occupied by the model // vec3_t mins, maxs` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.float radius` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // brush model // int firstmodelsurface, nummodelsurfaces` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numsubmodels` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.dmodel_t *submodels` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numplanes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mplane_t *planes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numleafs` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// number of visible leafs, not counting 0 mleaf_t *leafs` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numvertexes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mvertex_t *vertexes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numedges` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.medge_t *edges` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numnodes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mnode_t *nodes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numtexinfo` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.mtexinfo_t *texinfo` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numsurfaces` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.msurface_t *surfaces` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numsurfedges` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int *surfedges` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numclipnodes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.dclipnode_t *clipnodes` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int nummarksurfaces` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.msurface_t **marksurfaces` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.hull_t hulls[MAX_MAP_HULLS]` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.int numtextures` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.texture_t **textures` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.byte *visdata` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.byte *lightdata` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.char *entities` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `model_t.// // additional model data // cache_user_t cache` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `__MODEL__` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIDE_FRONT` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIDE_BACK` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIDE_ON` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_PLANEBACK` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWSKY` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWSPRITE` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWTURB` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWTILED` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SURF_DRAWBACKGROUND` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_ROCKET` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_GRENADE` | 292 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_GIB` | 293 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_ROTATE` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_TRACER` | 295 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_ZOMGIB` | 296 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_TRACER2` | 297 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_TRACER3` | 298 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mvertex_t` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mplane_t` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `texture_t` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `medge_t` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mtexinfo_t` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `msurface_t` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mnode_t` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mleaf_t` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `hull_t` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mspriteframe_t` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mspritegroup_t` | 203 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mspriteframedesc_t` | 209 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `msprite_t` | 220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasframedesc_t` | 239 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasskindesc_t` | 246 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasgroupframedesc_t` | 253 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasgroup_t` | 260 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `maliasskingroup_t` | 267 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mtriangle_t` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `aliashdr_t` | 281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `modtype_t` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `model_t` | 369 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_Init` | 369 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_ClearAll` | 373 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_ForName` | 374 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_Extradata` | 375 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_TouchModel` | 376 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_PointInLeaf` | 377 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Mod_LeafPVS` | 379 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `modelgen.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `synctype_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `synctype_t.ST_SYNC=0` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `synctype_t.ST_RAND` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `aliasframetype_t` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `aliasframetype_t.ALIAS_SINGLE=0` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `aliasframetype_t.ALIAS_GROUP` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `aliasskintype_t` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `aliasskintype_t.ALIAS_SKIN_SINGLE=0` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `aliasskintype_t.ALIAS_SKIN_GROUP` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `mdl_t` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int ident` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int version` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.vec3_t scale` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.vec3_t scale_origin` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.float boundingradius` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.vec3_t eyeposition` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int numskins` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int skinwidth` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int skinheight` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int numverts` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int numtris` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int numframes` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.synctype_t synctype` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.int flags` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `mdl_t.float size` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `stvert_t` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `stvert_t.int onseam` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `stvert_t.int s` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `stvert_t.int t` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dtriangle_t` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dtriangle_t.int facesfront` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dtriangle_t.int vertindex[3]` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `trivertx_t` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trivertx_t.byte v[3]` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trivertx_t.byte lightnormalindex` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasframe_t` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasframe_t.trivertx_t bboxmin` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasframe_t.// lightnormal isn't used trivertx_t bboxmax` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasframe_t.// lightnormal isn't used char name[16]` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasgroup_t` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasgroup_t.int numframes` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasgroup_t.trivertx_t bboxmin` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasgroup_t.// lightnormal isn't used trivertx_t bboxmax` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasskingroup_t` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasskingroup_t.int numskins` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasinterval_t` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasinterval_t.float interval` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasskininterval_t` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasskininterval_t.float interval` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasframetype_t` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasframetype_t.aliasframetype_t type` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `daliasskintype_t` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `daliasskintype_t.aliasskintype_t type` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_VERSION` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_ONSEAM` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SYNCTYPE_T` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DT_FACES_FRONT` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IDPOLYHEADER` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `synctype_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `aliasframetype_t` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `aliasskintype_t` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `mdl_t` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `stvert_t` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dtriangle_t` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `trivertx_t` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasframe_t` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasgroup_t` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasskingroup_t` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasinterval_t` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasskininterval_t` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasframetype_t` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `daliasskintype_t` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `qsocket_t` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.struct qsocket_s *next` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.double connecttime` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.double lastMessageTime` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.double lastSendTime` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.qboolean disconnected` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.qboolean canSend` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.qboolean sendNext` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.int driver` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.int landriver` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.int socket` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.void *driverdata` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.unsigned int ackSequence` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.unsigned int sendSequence` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.unsigned int unreliableSendSequence` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.int sendMessageLength` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.byte sendMessage [NET_MAXMESSAGE]` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.unsigned int receiveSequence` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.unsigned int unreliableReceiveSequence` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.int receiveMessageLength` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.byte receiveMessage [NET_MAXMESSAGE]` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.struct qsockaddr addr` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsocket_t.char address[NET_NAMELEN]` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `net_landriver_t` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.char *name` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.qboolean initialized` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int controlSock` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*Init) (void)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.void (*Shutdown) (void)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.void (*Listen) (qboolean state)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*OpenSocket) (int port)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*CloseSocket) (int socket)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*Connect) (int socket, struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*CheckNewConnections) (void)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*Read) (int socket, byte *buf, int len, struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*Write) (int socket, byte *buf, int len, struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*Broadcast) (int socket, byte *buf, int len)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.char * (*AddrToString) (struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*StringToAddr) (char *string, struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*GetSocketAddr) (int socket, struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*GetNameFromAddr) (struct qsockaddr *addr, char *name)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*GetAddrFromName) (char *name, struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*AddrCompare) (struct qsockaddr *addr1, struct qsockaddr *addr2)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*GetSocketPort) (struct qsockaddr *addr)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_landriver_t.int (*SetSocketPort) (struct qsockaddr *addr, int port)` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `net_driver_t` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.char *name` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.qboolean initialized` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.int (*Init) (void)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.void (*Listen) (qboolean state)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.void (*SearchForHosts) (qboolean xmit)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.qsocket_t *(*Connect) (char *host)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.qsocket_t *(*CheckNewConnections) (void)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.int (*QGetMessage) (qsocket_t *sock)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.int (*QSendMessage) (qsocket_t *sock, sizebuf_t *data)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.int (*SendUnreliableMessage) (qsocket_t *sock, sizebuf_t *data)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.qboolean (*CanSendMessage) (qsocket_t *sock)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.qboolean (*CanSendUnreliableMessage) (qsocket_t *sock)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.void (*Close) (qsocket_t *sock)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.void (*Shutdown) (void)` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `net_driver_t.int controlSock` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `hostcache_t` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.char name[16]` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.char map[16]` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.char cname[32]` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.int users` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.int maxusers` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.int driver` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.int ldriver` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hostcache_t.struct qsockaddr addr` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `PollProcedure` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `PollProcedure.struct _PollProcedure *next` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `PollProcedure.double nextTime` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `PollProcedure.void (*procedure)()` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `PollProcedure.void *arg` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `qsockaddr` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsockaddr.short sa_family` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qsockaddr.unsigned char sa_data[14]` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NET_NAMELEN` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NET_MAXMESSAGE` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NET_HEADERSIZE` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NET_DATAGRAMSIZE` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_LENGTH_MASK` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_DATA` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_ACK` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_NAK` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_EOM` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_UNRELIABLE` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NETFLAG_CTL` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NET_PROTOCOL_VERSION` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREQ_CONNECT` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREQ_SERVER_INFO` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREQ_PLAYER_INFO` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREQ_RULE_INFO` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREP_ACCEPT` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREP_REJECT` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREP_SERVER_INFO` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREP_PLAYER_INFO` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CCREP_RULE_INFO` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_NET_DRIVERS` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HOSTCACHESIZE` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qsocket_t` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qsocket_t *net_activeSockets` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qsocket_t *net_freeSockets` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int net_numsockets` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `net_landriver_t` | 178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern net_landriver_t net_landrivers[MAX_NET_DRIVERS]` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `net_driver_t` | 201 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int net_numdrivers` | 201 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern net_driver_t net_drivers[MAX_NET_DRIVERS]` | 203 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int DEFAULTnet_hostport` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int net_hostport` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int net_driverlevel` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t hostname` | 209 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char playername[]` | 210 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int playercolor` | 211 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int messagesSent` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int messagesReceived` | 214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int unreliableMessagesSent` | 215 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int unreliableMessagesReceived` | 216 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `hostcache_t` | 236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int hostCacheCount` | 236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern hostcache_t hostcache[HOSTCACHESIZE]` | 238 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern sizebuf_t net_message` | 266 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int net_activeconnections` | 267 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `PollProcedure` | 319 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean serialAvailable` | 321 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean ipxAvailable` | 323 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean tcpipAvailable` | 324 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char my_ipx_address[NET_NAMELEN]` | 325 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char my_tcpip_address[NET_NAMELEN]` | 326 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean slistInProgress` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean slistSilent` | 333 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean slistLocal` | 334 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_NewQSocket` | 217 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_FreeQSocket` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SetNetTime` | 220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_Init` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_Shutdown` | 270 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_CheckNewConnections` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_Connect` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_CanSendMessage` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_GetMessage` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_SendMessage` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_SendUnreliableMessage` | 290 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_SendToAll` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_Close` | 297 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_Poll` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SchedulePollProcedure` | 319 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 327 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 328 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 329 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 330 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NET_Slist_f` | 335 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_dgrm.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `StrAddr` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Ban_f` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_SendMessage` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SendMessageNext` | 208 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ReSendMessage` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_CanSendMessage` | 274 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_CanSendUnreliableMessage` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_SendUnreliableMessage` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_GetMessage` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PrintStats` | 466 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Stats_f` | 474 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Test_Poll` | 522 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Test_f` | 579 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Test2_Poll` | 650 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Test2_f` | 708 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_Init` | 766 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_Shutdown` | 796 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_Close` | 814 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_Listen` | 820 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_Datagram_CheckNewConnections` | 830 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_CheckNewConnections` | 1091 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_Datagram_SearchForHosts` | 1103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_SearchForHosts` | 1202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `_Datagram_Connect` | 1214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Datagram_Connect` | 1381 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `in_addr` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `in_addr.union { struct { unsigned char s_b1,s_b2,s_b3,s_b4` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `in_addr.} S_un_b` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `in_addr.struct { unsigned short s_w1,s_w2` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `in_addr.} S_un_w` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `in_addr.unsigned long S_addr` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `in_addr.} S_un` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `sockaddr_in` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sockaddr_in.short sin_family` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sockaddr_in.unsigned short sin_port` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sockaddr_in.struct in_addr sin_addr` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sockaddr_in.char sin_zero[8]` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BAN_TEST` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AF_INET` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `s_addr` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `sfunc` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `dfunc` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* statistic counters */ int packetsSent = 0` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int packetsReSent = 0` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int packetsReceived = 0` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int receivedDuplicateCount = 0` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int shortPacketCount = 0` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int droppedDatagrams` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int myDriverLevel` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `packetBuffer` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int m_return_state` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int m_state` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean m_return_onerror` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char m_return_reason[32]` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `unsigned long banMask = 0xffffffff` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean testInProgress = false` | 511 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int testPollCount` | 514 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int testDriver` | 515 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int testSocket` | 516 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean test2InProgress = false` | 640 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int test2Driver` | 643 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int test2Socket` | 644 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `inet_ntoa` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `inet_addr` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Test_Poll` | 517 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Test2_Poll` | 645 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_dgrm.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `Datagram_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_Listen` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_SearchForHosts` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_Connect` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_CheckNewConnections` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_GetMessage` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_SendMessage` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_SendUnreliableMessage` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_CanSendMessage` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_CanSendUnreliableMessage` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_Close` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Datagram_Shutdown` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_loop.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Loop_Init` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_Shutdown` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_Listen` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_SearchForHosts` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_Connect` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_CheckNewConnections` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IntAlign` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_GetMessage` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_SendMessage` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_SendUnreliableMessage` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_CanSendMessage` | 220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_CanSendUnreliableMessage` | 228 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Loop_Close` | 234 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qsocket_t *loop_client = NULL` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qsocket_t *loop_server = NULL` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_loop.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `Loop_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_Listen` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_SearchForHosts` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_Connect` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_CheckNewConnections` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_GetMessage` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_SendMessage` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_SendUnreliableMessage` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_CanSendMessage` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_CanSendUnreliableMessage` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_Close` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Loop_Shutdown` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_main.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SetNetTime` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_NewQSocket` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_FreeQSocket` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Listen_f` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MaxPlayers_f` | 194 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Port_f` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PrintSlistHeader` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PrintSlist` | 270 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PrintSlistTrailer` | 285 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Slist_f` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Slist_Send` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Slist_Poll` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Connect` | 368 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_CheckNewConnections` | 457 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Close` | 500 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_GetMessage` | 540 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_SendMessage` | 625 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_SendUnreliableMessage` | 656 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_CanSendMessage` | 695 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_SendToAll` | 722 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Init` | 804 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Shutdown` | 896 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NET_Poll` | 927 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SchedulePollProcedure` | 958 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `IsID` | 985 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `sfunc` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `dfunc` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IDNET` | 983 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qsocket_t *net_freeSockets = NULL` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int net_numsockets = 0` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean serialAvailable = false` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean ipxAvailable = false` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean tcpipAvailable = false` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int net_hostport` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int DEFAULTnet_hostport = 26000` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char my_ipx_address[NET_NAMELEN]` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char my_tcpip_address[NET_NAMELEN]` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean listening = false` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean slistInProgress = false` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean slistSilent = false` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean slistLocal = true` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static double slistStartTime` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int slistLastShown` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sizebuf_t net_message` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int net_activeconnections = 0` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int messagesSent = 0` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int messagesReceived = 0` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int unreliableMessagesSent = 0` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int unreliableMessagesReceived = 0` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean configRestored = false` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean recording = false` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// these two macros are to make the code more readable #define sfunc net_drivers[sock->driver] #define dfunc net_drivers[net_driverlevel] int net_driverlevel` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `double net_time` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =================== NET_Connect =================== */ int hostCacheCount = 0` | 356 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `hostcache_t hostcache[HOSTCACHESIZE]` | 365 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vcrConnect` | 455 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vcrGetMessage` | 536 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vcrSendMessage` | 623 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static PollProcedure *pollProcedureList = NULL` | 922 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Slist_Send` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Slist_Poll` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PrintStats` | 536 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_ser.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `Serial_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_Listen` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_SearchForHosts` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_Connect` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_CheckNewConnections` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_GetMessage` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_SendMessage` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_SendUnreliableMessage` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_CanSendMessage` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_CanSendUnreliableMessage` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_Close` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Serial_Shutdown` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_vcr.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `VCR_Init` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_ReadNext` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_Listen` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_Shutdown` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_GetMessage` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_SendMessage` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_CanSendMessage` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_Close` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_SearchForHosts` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_Connect` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `VCR_CheckNewConnections` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `next` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_vcr.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| macro | `VCR_OP_CONNECT` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VCR_OP_GETMESSAGE` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VCR_OP_SENDMESSAGE` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VCR_OP_CANSENDMESSAGE` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VCR_MAX_MESSAGE` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_Listen` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_SearchForHosts` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_Connect` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_CheckNewConnections` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_GetMessage` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_SendMessage` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_CanSendMessage` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_Close` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VCR_Shutdown` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_win.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| global | `int net_numdrivers = 2` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int net_numlandrivers = 2` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_wins.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `BlockingHook` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_GetLocalAddress` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Init` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Shutdown` | 249 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Listen` | 259 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_OpenSocket` | 281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_CloseSocket` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PartialIPAddress` | 324 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Connect` | 374 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_CheckNewConnections` | 381 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Read` | 397 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_MakeSocketBroadcastCapable` | 416 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Broadcast` | 430 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_Write` | 452 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_AddrToString` | 466 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_StringToAddr` | 478 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_GetSocketAddr` | 494 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_GetNameFromAddr` | 510 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_GetAddrFromName` | 527 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_AddrCompare` | 547 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_GetSocketPort` | 563 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WINS_SetSocketPort` | 569 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXHOSTNAMELEN` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// socket for fielding new connections static int net_controlsocket` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int net_broadcastsocket = 0` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static struct qsockaddr broadcastaddr` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static unsigned long myAddr` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean winsock_lib_initialized` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `WSADATA winsockdata` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= static double blocktime` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SOCKET` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_wins.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `WINS_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_Shutdown` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_Listen` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_OpenSocket` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_CloseSocket` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_Connect` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_CheckNewConnections` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_Read` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_Write` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_Broadcast` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_AddrToString` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_StringToAddr` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_GetSocketAddr` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_GetNameFromAddr` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_GetAddrFromName` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_AddrCompare` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_GetSocketPort` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WINS_SetSocketPort` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_wipx.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `WIPX_Init` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_Shutdown` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_Listen` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_OpenSocket` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_CloseSocket` | 199 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_Connect` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_CheckNewConnections` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_Read` | 237 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_Broadcast` | 265 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_Write` | 272 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_AddrToString` | 293 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_StringToAddr` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_GetSocketAddr` | 351 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_GetNameFromAddr` | 368 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_GetAddrFromName` | 376 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_AddrCompare` | 401 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_GetSocketPort` | 420 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WIPX_SetSocketPort` | 426 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXHOSTNAMELEN` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IPXSOCKETS` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DO` | 324 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// socket for fielding new connections static int net_controlsocket` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static struct qsockaddr broadcastaddr` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean winsock_initialized` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern WSADATA winsockdata` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int sequence[IPXSOCKETS]` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= static byte packetBuffer[NET_DATAGRAMSIZE + 4]` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `net_wipx.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `WIPX_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_Shutdown` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_Listen` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_OpenSocket` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_CloseSocket` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_Connect` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_CheckNewConnections` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_Read` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_Write` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_Broadcast` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_AddrToString` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_StringToAddr` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_GetSocketAddr` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_GetNameFromAddr` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_GetAddrFromName` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_AddrCompare` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_GetSocketPort` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `WIPX_SetSocketPort` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `pr_cmds.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `PF_VarString` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_error` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_objerror` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_makevectors` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_setorigin` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SetMinMaxSize` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_setsize` | 215 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_setmodel` | 234 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_bprint` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_sprint` | 290 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_centerprint` | 321 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_normalize` | 350 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_vlen` | 381 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_vectoyaw` | 401 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_vectoangles` | 428 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_random` | 470 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_particle` | 486 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_ambientsound` | 506 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_sound` | 558 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_break` | 591 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_traceline` | 609 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_TraceToss` | 641 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_checkpos` | 678 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_newcheckclient` | 686 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_checkclient` | 753 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_stuffcmd` | 804 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_localcmd` | 830 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_cvar` | 845 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_cvar_set` | 861 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_findradius` | 880 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_dprint` | 918 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_ftos` | 925 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_fabs` | 937 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_vtos` | 944 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_etos` | 951 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_Spawn` | 958 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_Remove` | 965 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_CheckEmptyString` | 1056 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_precache_file` | 1062 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_precache_sound` | 1067 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_precache_model` | 1092 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_coredump` | 1119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_traceon` | 1124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_traceoff` | 1129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_eprint` | 1134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_walkmove` | 1146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_droptofloor` | 1189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_lightstyle` | 1221 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_rint` | 1247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_floor` | 1256 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_ceil` | 1260 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_checkbottom` | 1271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_pointcontents` | 1285 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_nextent` | 1301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_aim` | 1333 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_changeyaw` | 1412 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_changepitch` | 1455 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WriteDest` | 1506 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteByte` | 1539 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteChar` | 1544 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteShort` | 1549 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteLong` | 1554 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteAngle` | 1559 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteCoord` | 1564 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteString` | 1569 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WriteEntity` | 1575 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_makestatic` | 1584 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_setspawnparms` | 1615 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_changelevel` | 1638 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_WaterMove` | 1683 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_sin` | 1808 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_cos` | 1813 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_sqrt` | 1818 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PF_Fixme` | 1824 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RETURN_EDICT` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_CHECK` | 751 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MSG_BROADCAST` | 1501 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MSG_ONE` | 1502 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MSG_ALL` | 1503 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MSG_INIT` | 1504 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENT_WATER` | 1670 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENT_SLIME` | 1671 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONTENT_LAVA` | 1672 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_IMMUNE_WATER` | 1674 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_IMMUNE_SLIME` | 1675 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_IMMUNE_LAVA` | 1676 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CHAN_VOICE` | 1678 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CHAN_BODY` | 1679 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ATTN_NORM` | 1681 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================ byte checkpvs[MAX_MAP_LEAFS/8]` | 680 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char pr_string_temp[128]` | 921 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `builtin_t *pr_builtins = pr_builtin` | 1930 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_ModelIndex` | 1578 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `sizeof` | 1932 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `pr_comp.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `etype_t` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_void` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_string` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_float` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_vector` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_entity` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_field` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_function` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `etype_t.ev_pointer` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dstatement_t` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dstatement_t.unsigned short op` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dstatement_t.short a,b,c` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `ddef_t` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `ddef_t.unsigned short type` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `ddef_t.// if DEF_SAVEGLOBGAL bit is set // the variable needs to be saved in savegames unsigned short ofs` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `ddef_t.int s_name` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dfunction_t` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.int first_statement` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.// negative numbers are builtins int parm_start` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.int locals` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.// total ints of parms + locals int profile` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.// runtime int s_name` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.int s_file` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.// source file defined in int numparms` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dfunction_t.byte parm_size[MAX_PARMS]` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dprograms_t` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int version` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int crc` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.// check of header file int ofs_statements` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int numstatements` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.// statement 0 is an error int ofs_globaldefs` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int numglobaldefs` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int ofs_fielddefs` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int numfielddefs` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int ofs_functions` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int numfunctions` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.// function 0 is an empty int ofs_strings` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int numstrings` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.// first string is a null string int ofs_globals` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int numglobals` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dprograms_t.int entityfields` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_NULL` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_RETURN` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM0` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM1` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM2` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM3` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM4` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM5` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM6` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `OFS_PARM7` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RESERVED_OFS` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEF_SAVEGLOBAL` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_PARMS` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PROG_VERSION` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `etype_t` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dstatement_t` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `ddef_t` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dfunction_t` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dprograms_t` | 179 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `pr_edict.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `ED_ClearEdict` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_Alloc` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_Free` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_GlobalAtOfs` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_FieldAtOfs` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_FindField` | 186 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_FindGlobal` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_FindFunction` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetEdictFieldValue` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_ValueString` | 280 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_UglyValueString` | 332 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_GlobalString` | 381 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_GlobalStringNoContents` | 407 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_Print` | 435 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_Write` | 485 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_PrintNum` | 525 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_PrintEdicts` | 537 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_PrintEdict_f` | 553 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_Count` | 573 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_WriteGlobals` | 616 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_ParseGlobals` | 649 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_NewString` | 693 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_ParseEpair` | 728 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_ParseEdict` | 802 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ED_LoadFromFile` | 905 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_LoadProgs` | 985 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_Init` | 1068 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `EDICT_NUM` | 1089 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `NUM_FOR_EDICT` | 1096 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `gefv_cache` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `gefv_cache.ddef_t *pcache` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `gefv_cache.char field[MAX_FIELD_LEN]` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_FIELD_LEN` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GEFV_CACHESIZE` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dfunction_t *pr_functions` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char *pr_strings` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `ddef_t *pr_fielddefs` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `ddef_t *pr_globaldefs` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dstatement_t *pr_statements` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `globalvars_t *pr_global_struct` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float *pr_globals` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// same as pr_global_struct int pr_edict_size` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// in bytes unsigned short pr_crc` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `gefv_cache` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_FieldAtOfs` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_ParseEpair` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `pr_exec.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `PR_PrintStatement` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_StackTrace` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_Profile_f` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_RunError` | 261 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_EnterFunction` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_LeaveFunction` | 333 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `PR_ExecuteProgram` | 361 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `prstack_t` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `prstack_t.int s` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `prstack_t.dfunction_t *f` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_STACK_DEPTH` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LOCALSTACK_SIZE` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `prstack_t` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int pr_depth` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int localstack_used` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean pr_trace` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dfunction_t *pr_xfunction` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int pr_xstatement` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int pr_argc` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_GlobalString` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_GlobalStringNoContents` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `progdefs.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `progs.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `eval_t` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `eval_t.string_t string` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `eval_t.float _float` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `eval_t.float vector[3]` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `eval_t.func_t function` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `eval_t.int _int` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `eval_t.int edict` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `edict_t` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.qboolean free` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.link_t area` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.// linked to a division node or leaf int num_leafs` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.short leafnums[MAX_ENT_LEAFS]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.entity_state_t baseline` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.float freetime` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edict_t.// sv.time when the object was freed entvars_t v` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_ENT_LEAFS` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EDICT_FROM_AREA` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NEXT_EDICT` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EDICT_TO_PROG` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PROG_TO_EDICT` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_FLOAT` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_INT` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_EDICT` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_EDICTNUM` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_VECTOR` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_STRING` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `G_FUNCTION` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `E_FLOAT` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `E_INT` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `E_VECTOR` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `E_STRING` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `eval_t` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `edict_t` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dfunction_t *pr_functions` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern char *pr_strings` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern ddef_t *pr_globaldefs` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern ddef_t *pr_fielddefs` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dstatement_t *pr_statements` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern globalvars_t *pr_global_struct` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float *pr_globals` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// same as pr_global_struct extern int pr_edict_size` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern builtin_t *pr_builtins` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int pr_numbuiltins` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int pr_argc` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean pr_trace` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern dfunction_t *pr_xfunction` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int pr_xstatement` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern unsigned short pr_crc` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_Init` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_ExecuteProgram` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_LoadProgs` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_Profile_f` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_Alloc` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_Free` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_NewString` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_Print` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_Write` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_ParseEdict` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_WriteGlobals` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_ParseGlobals` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_LoadFromFile` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `EDICT_NUM` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `NUM_FOR_EDICT` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PR_RunError` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_PrintEdicts` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `ED_PrintNum` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GetEdictFieldValue` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `protocol.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| macro | `PROTOCOL_VERSION` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_MOREBITS` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_ORIGIN1` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_ORIGIN2` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_ORIGIN3` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_ANGLE2` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_NOLERP` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_FRAME` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_SIGNAL` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_ANGLE1` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_ANGLE3` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_MODEL` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_COLORMAP` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_SKIN` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_EFFECTS` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `U_LONGENTITY` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_VIEWHEIGHT` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_IDEALPITCH` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_PUNCH1` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_PUNCH2` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_PUNCH3` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_VELOCITY1` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_VELOCITY2` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_VELOCITY3` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_ITEMS` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_ONGROUND` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_INWATER` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_WEAPONFRAME` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_ARMOR` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SU_WEAPON` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SND_VOLUME` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SND_ATTENUATION` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SND_LOOPING` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEFAULT_VIEWHEIGHT` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GAME_COOP` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GAME_DEATHMATCH` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_bad` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_nop` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_disconnect` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_updatestat` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_version` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_setview` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_sound` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_time` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_print` | 91 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_stufftext` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_setangle` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_serverinfo` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_lightstyle` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_updatename` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_updatefrags` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_clientdata` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_stopsound` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_updatecolors` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_particle` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_damage` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_spawnstatic` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_spawnbaseline` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_temp_entity` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_setpause` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_signonnum` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_centerprint` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_killedmonster` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_foundsecret` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_spawnstaticsound` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_intermission` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_finale` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_cdtrack` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_sellscreen` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `svc_cutscene` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `clc_bad` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `clc_nop` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `clc_disconnect` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `clc_move` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `clc_stringcmd` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_SPIKE` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_SUPERSPIKE` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_GUNSHOT` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_EXPLOSION` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_TAREXPLOSION` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_LIGHTNING1` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_LIGHTNING2` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_WIZSPIKE` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_KNIGHTSPIKE` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_LIGHTNING3` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_LAVASPLASH` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_TELEPORT` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_EXPLOSION2` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_BEAM` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_IMPLOSION` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TE_RAILTRAIL` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `quakedef.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `entity_state_t` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.vec3_t origin` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.vec3_t angles` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.int modelindex` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.int frame` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.int colormap` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.int skin` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_state_t.int effects` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `quakeparms_t` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `quakeparms_t.char *basedir` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `quakeparms_t.char *cachedir` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `quakeparms_t.// for development over ISDN lines int argc` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `quakeparms_t.char **argv` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `quakeparms_t.void *membase` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `quakeparms_t.int memsize` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `QUAKE_GAME` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VERSION` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GLQUAKE_VERSION` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `D3DQUAKE_VERSION` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WINQUAKE_VERSION` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `LINUX_VERSION` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `X11_VERSION` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GAMENAME` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `GAMENAME` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `__i386__` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VID_LockBuffer` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VID_UnlockBuffer` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `id386` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `id386` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `UNALIGNED_OK` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `UNALIGNED_OK` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CACHE_SIZE` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `UNUSED` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MINIMUM_MEMORY` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MINIMUM_MEMORY_LEVELPAK` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_NUM_ARGVS` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PITCH` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `YAW` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ROLL` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_QPATH` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_OSPATH` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ON_EPSILON` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MSGLEN` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_DATAGRAM` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_EDICTS` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_LIGHTSTYLES` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_MODELS` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SOUNDS` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SAVEGAME_COMMENT_LENGTH` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_STYLESTRING` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_CL_STATS` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_HEALTH` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_FRAGS` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_WEAPON` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_AMMO` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_ARMOR` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_WEAPONFRAME` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_SHELLS` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_NAILS` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_ROCKETS` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_CELLS` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_ACTIVEWEAPON` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_TOTALSECRETS` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_TOTALMONSTERS` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_SECRETS` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_MONSTERS` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SHOTGUN` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SUPER_SHOTGUN` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_NAILGUN` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SUPER_NAILGUN` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_GRENADE_LAUNCHER` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_ROCKET_LAUNCHER` | 143 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_LIGHTNING` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SUPER_LIGHTNING` | 145 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SHELLS` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_NAILS` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_ROCKETS` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_CELLS` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_AXE` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_ARMOR1` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_ARMOR2` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_ARMOR3` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SUPERHEALTH` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_KEY1` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_KEY2` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_INVISIBILITY` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_INVULNERABILITY` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SUIT` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_QUAD` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SIGIL1` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SIGIL2` | 162 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SIGIL3` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IT_SIGIL4` | 164 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_SHELLS` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_NAILS` | 170 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_ROCKETS` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_CELLS` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_AXE` | 173 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_LAVA_NAILGUN` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_LAVA_SUPER_NAILGUN` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_MULTI_GRENADE` | 176 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_MULTI_ROCKET` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_PLASMA_GUN` | 178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_ARMOR1` | 179 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_ARMOR2` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_ARMOR3` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_LAVA_NAILS` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_PLASMA_AMMO` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_MULTI_ROCKETS` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_SHIELD` | 185 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_ANTIGRAV` | 186 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `RIT_SUPERHEALTH` | 187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_PROXIMITY_GUN_BIT` | 192 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_MJOLNIR_BIT` | 193 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_LASER_CANNON_BIT` | 194 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_PROXIMITY_GUN` | 195 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_MJOLNIR` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_LASER_CANNON` | 197 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_WETSUIT` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HIT_EMPATHY_SHIELDS` | 199 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SCOREBOARD` | 203 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SCOREBOARDNAME` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SOUND_CHANNELS` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_state_t` | 228 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `quakeparms_t` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= extern qboolean noclip_anglehack` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // host // extern quakeparms_t host_parms` | 286 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t sys_ticrate` | 292 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t sys_nostdout` | 294 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t developer` | 295 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean host_initialized` | 296 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// true if into command execution extern double host_frametime` | 298 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte *host_basepal` | 299 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte *host_colormap` | 300 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int host_framecount` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// incremented every frame, never reset extern double realtime` | 302 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean msg_suppress_1` | 316 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// suppresses resolution and cache size console output // an fullscreen DIB focus gain/loss extern int current_skill` | 318 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int minimum_memory` | 324 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // chase // extern cvar_t chase_active` | 326 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `defined` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_UnlockBuffer` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_ClearMemory` | 303 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_ServerFrame` | 306 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_InitCommands` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_Init` | 308 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_Shutdown` | 309 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_Error` | 310 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_EndGame` | 311 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_Frame` | 312 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_Quit_f` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_ClientCommands` | 314 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Host_ShutdownServer` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Chase_Init` | 331 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Chase_Reset` | 333 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Chase_Update` | 334 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `r_local.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `alight_t` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `alight_t.int ambientlight` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `alight_t.int shadelight` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `alight_t.float *plightvec` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `bedge_t` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `bedge_t.mvertex_t *v[2]` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `bedge_t.struct bedge_s *pnext` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `auxvert_t` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `auxvert_t.float fv[3]` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `clipplane_t` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `clipplane_t.vec3_t normal` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `clipplane_t.float dist` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `clipplane_t.struct clipplane_s *next` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `clipplane_t.byte leftedge` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `clipplane_t.byte rightedge` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `clipplane_t.byte reserved[2]` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `btofpoly_t` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `btofpoly_t.int clipflags` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `btofpoly_t.msurface_t *psurf` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_BASE_SIZE_RATIO` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BMODEL_FULLY_CLIPPED` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `XCENTERING` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `YCENTERING` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CLIP_EPSILON` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BACKFACE_EPSILON` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DIST_NOT_SET` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NEAR_CLIP` | 187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXBVERTINDEXES` | 195 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_BTOFPOLYS` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXALIASVERTS` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_Z_CLIP_PLANE` | 225 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AMP` | 243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AMP2` | 244 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPEED` | 245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `alight_t` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `bedge_t` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `auxvert_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//=========================================================================== extern cvar_t r_draworder` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_speeds` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_timegraph` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_graphheight` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_clearcolor` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_waterwarp` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_fullbright` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_drawentities` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_aliasstats` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_dspeeds` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_drawflat` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_ambient` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_reportsurfout` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_maxsurfs` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_numsurfs` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_reportedgeout` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_maxedges` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_numedges` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `clipplane_t` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern clipplane_t view_clipplanes[4]` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= extern mplane_t screenedge[4]` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t r_origin` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t r_entorigin` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float screenAspect` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float verticalFieldOfView` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float xOrigin, yOrigin` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_visframecount` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= extern int vstartscan` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // current entity info // extern qboolean insubmodel` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t r_worldmodelorg` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int c_faceclip` | 176 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_polycount` | 178 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_wholepolycount` | 179 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern model_t *cl_worldmodel` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int *pfrustum_indexes[4]` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// !!! if this is changed, it must be changed in asm_draw.h too !!! #define NEAR_CLIP 0.01 extern int ubasestep, errorterm, erroradjustup, erroradjustdown` | 184 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int vstartscan` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern fixed16_t sadjust, tadjust` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern fixed16_t bbextents, bbextentt` | 192 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t sbaseaxis[3], tbaseaxis[3]` | 197 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float entity_rotation[3][3]` | 199 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int reinit_surfcache` | 200 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_currentkey` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_currentbkey` | 204 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `btofpoly_t` | 210 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern btofpoly_t *pbtofpolys` | 214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//========================================================= // Alias models //========================================================= #define MAXALIASVERTS 2000 // TODO: tune this #define ALIAS_Z_CLIP_PLANE 5 extern int numverts` | 218 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int a_skinwidth` | 227 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mtriangle_t *ptriangles` | 228 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int numtriangles` | 229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern aliashdr_t *paliashdr` | 230 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mdl_t *pmdl` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float leftclip, topclip, rightclip, bottomclip` | 232 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_acliptype` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern finalvert_t *pfinalverts` | 234 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern auxvert_t *pauxverts` | 235 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_amodels_drawn` | 254 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edge_t *auxedges` | 256 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_numallocatededges` | 257 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edge_t *r_edges, *edge_p, *edge_max` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edge_t *newedges[MAXHEIGHT]` | 259 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edge_t *removeedges[MAXHEIGHT]` | 261 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int screenwidth` | 262 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// FIXME: make stack vars when debugging done extern edge_t edge_head` | 264 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edge_t edge_tail` | 267 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edge_t edge_aftertail` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_bmodelactive` | 269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vrect_t *pconupdate` | 270 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float aliasxscale, aliasyscale, aliasxcenter, aliasycenter` | 271 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float r_aliastransition, r_resfudge` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_outofsurfaces` | 274 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_outofedges` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mvertex_t *r_pcurrentvertbase` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_maxvalidedgeoffset` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float r_time1` | 282 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float dp_time1, dp_time2, db_time1, db_time2, rw_time1, rw_time2` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float se_time1, se_time2, de_time1, de_time2, dv_time1, dv_time2` | 285 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_frustum_indexes[4*6]` | 286 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_maxsurfsseen, r_maxedgesseen, r_cnumsurfs` | 287 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean r_surfsonstack` | 288 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cshift_t cshift_water` | 289 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean r_dowarpold, r_viewchanged` | 290 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mleaf_t *r_viewleaf, *r_oldviewleaf` | 291 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t r_emins, r_emaxs` | 293 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern mnode_t *r_pefragtopnode` | 295 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_clipflags` | 296 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_dlightframecount` | 297 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean r_fov_greater_than_90` | 298 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RenderWorld` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ClearPolyList` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawPolyList` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSprite` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RenderFace` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RenderPoly` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RenderBmodelFace` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TransformPlane` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TransformFrustum` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_SetSkyFrame` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSurfaceBlock16` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSurfaceBlock8` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TextureAnimation` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSurfaceBlock8_mip1` | 145 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSurfaceBlock8_mip2` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSurfaceBlock8_mip3` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_GenSkyTile16` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Surf8Patch` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Surf16Patch` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSubmodelPolygons` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawSolidClippedSubmodelPolygons` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_AddPolygonEdges` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_GetSurf` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_AliasDrawModel` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_BeginEdgeFrame` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ScanEdges` | 162 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DrawSurfaces` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_InsertNewEdges` | 164 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_StepActiveU` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RemoveEdges` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Surf8Start` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Surf8End` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Surf16Start` | 170 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Surf16End` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_EdgeCodeStart` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_EdgeCodeEnd` | 173 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RotateBmodel` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_InitTurb` | 215 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ZDrawSubmodelPolys` | 217 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_AliasCheckBBox` | 236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_DrawParticles` | 238 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_InitParticles` | 250 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ClearParticles` | 251 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ReadPointFile_f` | 252 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_SurfacePatch` | 253 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_AliasClipTriangle` | 280 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_StoreEfrags` | 299 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TimeRefresh_f` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TimeGraph` | 302 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_PrintAliasStats` | 303 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_PrintTimes` | 304 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_PrintDSpeeds` | 305 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_AnimateLight` | 306 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_LightPoint` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_SetupFrame` | 308 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_cshift_f` | 309 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_EmitEdge` | 310 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ClipEdge` | 311 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_SplitEntityOnNode2` | 312 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_MarkLights` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `r_part.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `R_InitParticles` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DarkFieldParticles` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_EntityParticles` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ClearParticles` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ReadPointFile_f` | 196 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ParseParticleEffect` | 251 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ParticleExplosion` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_ParticleExplosion2` | 321 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_BlobExplosion` | 355 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RunParticleEffect` | 400 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_LavaSplash` | 459 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_TeleportSplash` | 501 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_RocketTrail` | 537 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `R_DrawParticles` | 649 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_PARTICLES` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ABSOLUTE_MIN_PARTICLES` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUMVERTEXNORMALS` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `particle_t *active_particles, *free_particles` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `particle_t *particles` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int r_numparticles` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t r_pright, r_pup, r_ppn` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t avelocities[NUMVERTEXNORMALS]` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float beamlength = 16` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float partstep = 0.01` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float timescale = 0.01` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============== R_DrawParticles =============== */ extern cvar_t sv_gravity` | 639 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `r_shared.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `espan_t` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `espan_t.int u, v, count` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `espan_t.struct espan_s *pnext` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `surf_t` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.struct surf_s *next` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// active surface stack in r_edge.c struct surf_s *prev` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// used in r_edge.c for active surf stack struct espan_s *spans` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// pointer to linked list of spans to draw int key` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// sorting key (BSP order) int last_u` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// set during tracing int spanstate` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// 0 = not in span // 1 = in span // -1 = in inverted span (end before // start) int flags` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// currentface flags void *data` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// associated data like msurface_t entity_t *entity` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.float nearzi` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.// nearest 1/z on surface, for mipmapping qboolean insubmodel` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.float d_ziorigin, d_zistepu, d_zistepv` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `surf_t.int pad[2]` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `edge_t` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.fixed16_t u` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.fixed16_t u_step` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.struct edge_s *prev, *next` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.unsigned short surfs[2]` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.struct edge_s *nextremove` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.float nearzi` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `edge_t.medge_t *owner` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `_R_SHARED_H_` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXVERTS` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXWORKINGVERTS` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXHEIGHT` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXWIDTH` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXDIMENSION` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SIN_BUFFER_SIZE` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `INFINITE_DISTANCE` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUMSTACKEDGES` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MINEDGES` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUMSTACKSURFACES` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MINSURFACES` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXSPANS` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_LEFT_CLIP` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_TOP_CLIP` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_RIGHT_CLIP` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_BOTTOM_CLIP` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_Z_CLIP` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_ONSEAM` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ALIAS_XY_CLIP_MASK` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int cachewidth` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern pixel_t *cacheblock` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int screenwidth` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float pixelAspect` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_drawnpolycount` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t r_clearcolor` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int sintable[SIN_BUFFER_SIZE]` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int intsintable[SIN_BUFFER_SIZE]` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t vup, base_vup` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t vpn, base_vpn` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t vright, base_vright` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern entity_t *currententity` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `espan_t` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `surf_t` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern surf_t *surfaces, *surface_p, *surf_max` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// surfaces are generated in back to front order by the bsp, so if a surf // pointer is greater than another one, it should be drawn in front // surfaces[1] is the background, and is used as the active surface stack. // surfaces[0] is a dummy, because index 0 is used to indicate no surface // attached to an edge_t //=================================================================== extern vec3_t sxformaxis[4]` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// s axis transformed into viewspace extern vec3_t txformaxis[4]` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// t axis transformed into viewspac extern vec3_t modelorg, base_modelorg` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float xcenter, ycenter` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float xscale, yscale` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float xscaleinv, yscaleinv` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float xscaleshrink, yscaleshrink` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int d_lightstylevalue[256]` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int r_skymade` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int ubasestep, errorterm, erroradjustup, erroradjustdown` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `edge_t` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MAXWORKINGVERTS` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `TransformVector` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SetUpForLineScan` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_MakeSky` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `render.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `efrag_t` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `efrag_t.struct mleaf_s *leaf` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `efrag_t.struct efrag_s *leafnext` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `efrag_t.struct entity_s *entity` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `efrag_t.struct efrag_s *entnext` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `entity_t` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.qboolean forcelink` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// model changed int update_type` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.entity_state_t baseline` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// to fill in defaults in updates double msgtime` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// time of last update vec3_t msg_origins[2]` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// last two updates (0 is newest) vec3_t origin` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.vec3_t msg_angles[2]` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// last two updates (0 is newest) vec3_t angles` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.struct model_s *model` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// NULL = no model struct efrag_s *efrag` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// linked list of efrags int frame` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.float syncbase` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// for client-side animations byte *colormap` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.int effects` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// light, particals, etc int skinnum` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// for Alias models int visframe` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// last frame this entity was // found in an active leaf int dlightframe` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// dynamic lighting int dlightbits` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.// FIXME: could turn these into a union int trivial_accept` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `entity_t.struct mnode_s *topnode` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `refdef_t` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.vrect_t vrect` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// subwindow in video for refresh // FIXME: not need vrect next field here? vrect_t aliasvrect` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// scaled Alias version int vrectright, vrectbottom` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// right & bottom screen coords int aliasvrectright, aliasvrectbottom` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// scaled Alias versions float vrectrightedge` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// rightmost right edge we care about, // for use in edge list float fvrectx, fvrecty` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// for floating-point compares float fvrectx_adj, fvrecty_adj` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// left and top edges, for clamping int vrect_x_adj_shift20` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// (vrect.x + 0.5 - epsilon) << 20 int vrectright_adj_shift20` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// (vrectright + 0.5 - epsilon) << 20 float fvrectright_adj, fvrectbottom_adj` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// right and bottom edges, for clamping float fvrectright` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// rightmost edge, for Alias clamping float fvrectbottom` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// bottommost edge, for Alias clamping float horizontalFieldOfView` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// at Z = 1.0, this many X is visible // 2.0 = 90 degrees float xOrigin` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// should probably allways be 0.5 float yOrigin` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.// between be around 0.3 to 0.5 vec3_t vieworg` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.vec3_t viewangles` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.float fov_x, fov_y` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `refdef_t.int ambientlight` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXCLIPPLANES` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TOP_RANGE` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `BOTTOM_RANGE` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `efrag_t` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `entity_t` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `refdef_t` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // refresh // extern int reinit_surfcache` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern refdef_t r_refdef` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t r_origin, vpn, vright, vup` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern struct texture_s *r_notexture_mip` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// // surface cache related // extern int reinit_surfcache` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if 1, surface cache is currently empty and extern qboolean r_cache_thrash` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_Init` | 113 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_InitTextures` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_InitEfrags` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RenderView` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ViewChanged` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_InitSky` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_AddEfrags` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RemoveEfrags` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_NewMap` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ParseParticleEffect` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RunParticleEffect` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_RocketTrail` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_BlobExplosion` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ParticleExplosion` | 138 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_ParticleExplosion2` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_LavaSplash` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_TeleportSplash` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_PushDlights` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_SurfaceCacheForRes` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_FlushCaches` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_DeleteSurfaceCache` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `D_InitCaches` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_SetVrect` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sbar.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Sbar_ShowScores` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DontShowScores` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_Changed` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_Init` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawPic` | 260 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawTransPic` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawCharacter` | 288 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawString` | 301 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_itoa` | 314 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawNum` | 350 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_SortFrags` | 391 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_ColorForMap` | 416 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_UpdateScoreboard` | 426 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_SoloScoreboard` | 457 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawScoreboard` | 487 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawInventory` | 546 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawFrags` | 766 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DrawFace` | 828 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_Draw` | 926 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_IntermissionNumber` | 1054 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_DeathmatchOverlay` | 1086 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_MiniDeathmatchOverlay` | 1167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_IntermissionOverlay` | 1269 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sbar_FinaleOverlay` | 1315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STAT_MINUS` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// if >= vid.numpages, no update needed #define STAT_MINUS 10 // num frame for '-' stats digit qpic_t *sb_nums[2][11]` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_colon, *sb_slash` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_ibar` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_sbar` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_scorebar` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_weapons[7][8]` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 0 is active, 1 is owned, 2-5 are flashes qpic_t *sb_ammo[4]` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_sigil[4]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_armor[3]` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_items[32]` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_faces[7][2]` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 0 is gibbed, 1 is dead, 2-6 are alive // 0 is static, 1 is temporary animation qpic_t *sb_face_invis` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_face_quad` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_face_invuln` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *sb_face_invis_invuln` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean sb_showscores` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int sb_lines` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// scan lines to draw qpic_t *rsb_invbar[2]` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *rsb_weapons[5]` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *rsb_items[2]` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *rsb_ammo[3]` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t *rsb_teambord` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// PGM 01/19/97 - team color border //MED 01/04/97 added two more weapons + 3 alternates for grenade launcher qpic_t *hsb_weapons[7][5]` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//MED 01/04/97 added hipnotic items array qpic_t *hsb_items[2]` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= int fragsort[MAX_SCOREBOARD]` | 374 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char scoreboardtext[MAX_SCOREBOARD][20]` | 378 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scoreboardtop[MAX_SCOREBOARD]` | 380 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scoreboardbottom[MAX_SCOREBOARD]` | 381 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scoreboardcount[MAX_SCOREBOARD]` | 382 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int scoreboardlines` | 383 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_MiniDeathmatchOverlay` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_DeathmatchOverlay` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `M_DrawPic` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sbar.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| macro | `SBAR_HEIGHT` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_Init` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_Changed` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_Draw` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_IntermissionOverlay` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sbar_FinaleOverlay` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `screen.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| global | `extern float scr_con_current` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float scr_conlines` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// lines of console to display extern int scr_fullupdate` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// set to 0 to force full redraw extern int sb_lines` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int clearnotify` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// set to 0 whenever notify text is drawn extern qboolean scr_disabled_for_loading` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean scr_skipupdate` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t scr_viewsize` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t scr_viewsize` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// only the refresh window will be updated unless these variables are flagged extern int scr_copytop` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int scr_copyeverything` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean block_drawing` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_Init` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_UpdateScreen` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_SizeUp` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_SizeDown` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_BringDownConsole` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_CenterPrint` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_BeginLoadingPlaque` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_EndLoadingPlaque` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_ModalMessage` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SCR_UpdateWholeScreen` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `server.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `server_static_t` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_static_t.int maxclients` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_static_t.int maxclientslimit` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_static_t.struct client_s *clients` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_static_t.// [maxclients] int serverflags` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_static_t.// episode completion information qboolean changelevel_issued` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `server_state_t` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `server_state_t.ss_loading` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `server_state_t.ss_active` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `server_t` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.qboolean active` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// false if only a net client qboolean paused` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.qboolean loadgame` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// handle connections specially double time` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.int lastcheck` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// used by PF_checkclient double lastchecktime` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.char name[64]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// map name #ifdef QUAKE2 char startspot[64]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// maps/<name>.bsp, for model_precache[0] struct model_s *worldmodel` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.char *model_precache[MAX_MODELS]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// NULL terminated struct model_s *models[MAX_MODELS]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.char *sound_precache[MAX_SOUNDS]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// NULL terminated char *lightstyles[MAX_LIGHTSTYLES]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.int num_edicts` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.int max_edicts` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.edict_t *edicts` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// can NOT be array indexed, because // edict_t is variable sized, but can // be used to reference the world ent server_state_t state` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// some actions are only valid during load sizebuf_t datagram` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.byte datagram_buf[MAX_DATAGRAM]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.sizebuf_t reliable_datagram` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.// copied to all clients at end of frame byte reliable_datagram_buf[MAX_DATAGRAM]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.sizebuf_t signon` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `server_t.byte signon_buf[8192]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `client_t` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.qboolean active` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// false = client is free qboolean spawned` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// false = don't send datagrams qboolean dropasap` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// has been told to go to another level qboolean privileged` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// can execute any host command qboolean sendsignon` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// only valid before spawned double last_message` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// reliable messages must be sent // periodically struct qsocket_s *netconnection` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// communications handle usercmd_t cmd` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// movement vec3_t wishdir` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// intended motion calced from cmd sizebuf_t message` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// can be added to at any time, // copied and clear once per frame byte msgbuf[MAX_MSGLEN]` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.edict_t *edict` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// EDICT_NUM(clientnum+1) char name[32]` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// for printing to other people int colors` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.float ping_times[NUM_PING_TIMES]` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.int num_pings` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// ping_times[num_pings%NUM_PING_TIMES] // spawn parms are carried from level to level float spawn_parms[NUM_SPAWN_PARMS]` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `client_t.// client known data for deltas int old_frags` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_PING_TIMES` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NUM_SPAWN_PARMS` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_NONE` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_ANGLENOCLIP` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_ANGLECLIP` | 117 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_WALK` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_STEP` | 119 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_FLY` | 120 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_TOSS` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_PUSH` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_NOCLIP` | 123 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_FLYMISSILE` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_BOUNCE` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_BOUNCEMISSILE` | 127 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVETYPE_FOLLOW` | 128 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SOLID_NOT` | 132 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SOLID_TRIGGER` | 133 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SOLID_BBOX` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SOLID_SLIDEBOX` | 135 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SOLID_BSP` | 136 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEAD_NO` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEAD_DYING` | 140 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEAD_DEAD` | 141 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DAMAGE_NO` | 143 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DAMAGE_YES` | 144 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DAMAGE_AIM` | 145 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_FLY` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_SWIM` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_CONVEYOR` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_CLIENT` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_INWATER` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_MONSTER` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_GODMODE` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_NOTARGET` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_ITEM` | 157 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_ONGROUND` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_PARTIALGROUND` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_WATERJUMP` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_JUMPRELEASED` | 161 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_FLASHLIGHT` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `FL_ARCHIVE_OVERRIDE` | 164 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_BRIGHTFIELD` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_MUZZLEFLASH` | 170 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_BRIGHTLIGHT` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_DIMLIGHT` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_DARKLIGHT` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_DARKFIELD` | 175 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_LIGHT` | 176 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `EF_NODRAW` | 177 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPAWNFLAG_NOT_EASY` | 180 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPAWNFLAG_NOT_MEDIUM` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPAWNFLAG_NOT_HARD` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPAWNFLAG_NOT_DEATHMATCH` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_EPISODE_1` | 187 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_EPISODE_2` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_EPISODE_3` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_EPISODE_4` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_NEW_UNIT` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_NEW_EPISODE` | 192 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SFL_CROSS_TRIGGERS` | 193 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `server_static_t` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `server_state_t` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `server_t` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `client_t` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `//============================================================================= // edict->movetype values #define MOVETYPE_NONE 0 // never moves #define MOVETYPE_ANGLENOCLIP 1 #define MOVETYPE_ANGLECLIP 2 #define MOVETYPE_WALK 3 // gravity #define MOVETYPE_STEP 4 // gravity, special edge handling #define MOVETYPE_FLY 5 #define MOVETYPE_TOSS 6 // gravity #define MOVETYPE_PUSH 7 // no clip to world, push and crush #define MOVETYPE_NOCLIP 8 #define MOVETYPE_FLYMISSILE 9 // extra size to monsters #define MOVETYPE_BOUNCE 10 #ifdef QUAKE2 #define MOVETYPE_BOUNCEMISSILE 11 // bounce w/o gravity #define MOVETYPE_FOLLOW 12 // track movement of aiment #endif // edict->solid values #define SOLID_NOT 0 // no interaction with other objects #define SOLID_TRIGGER 1 // touch on edge, but not blocking #define SOLID_BBOX 2 // touch on edge, block #define SOLID_SLIDEBOX 3 // touch on edge, but not an onground #define SOLID_BSP 4 // bsp clip, touch on edge, block // edict->deadflag values #define DEAD_NO 0 #define DEAD_DYING 1 #define DEAD_DEAD 2 #define DAMAGE_NO 0 #define DAMAGE_YES 1 #define DAMAGE_AIM 2 // edict->flags #define FL_FLY 1 #define FL_SWIM 2 //#define FL_GLIMPSE 4 #define FL_CONVEYOR 4 #define FL_CLIENT 8 #define FL_INWATER 16 #define FL_MONSTER 32 #define FL_GODMODE 64 #define FL_NOTARGET 128 #define FL_ITEM 256 #define FL_ONGROUND 512 #define FL_PARTIALGROUND 1024 // not all corners are valid #define FL_WATERJUMP 2048 // player jumping out of water #define FL_JUMPRELEASED 4096 // for jump debouncing #ifdef QUAKE2 #define FL_FLASHLIGHT 8192 #define FL_ARCHIVE_OVERRIDE 1048576 #endif // entity effects #define EF_BRIGHTFIELD 1 #define EF_MUZZLEFLASH 2 #define EF_BRIGHTLIGHT 4 #define EF_DIMLIGHT 8 #ifdef QUAKE2 #define EF_DARKLIGHT 16 #define EF_DARKFIELD 32 #define EF_LIGHT 64 #define EF_NODRAW 128 #endif #define SPAWNFLAG_NOT_EASY 256 #define SPAWNFLAG_NOT_MEDIUM 512 #define SPAWNFLAG_NOT_HARD 1024 #define SPAWNFLAG_NOT_DEATHMATCH 2048 #ifdef QUAKE2 // server flags #define SFL_EPISODE_1 1 #define SFL_EPISODE_2 2 #define SFL_EPISODE_3 4 #define SFL_EPISODE_4 8 #define SFL_NEW_UNIT 16 #define SFL_NEW_EPISODE 32 #define SFL_CROSS_TRIGGERS 65280 #endif //============================================================================ extern cvar_t teamplay` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t skill` | 198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t deathmatch` | 199 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t coop` | 200 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t fraglimit` | 201 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t timelimit` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern server_static_t svs` | 203 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// persistant server info extern server_t sv` | 205 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// local server extern client_t *host_client` | 206 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern jmp_buf host_abortserver` | 208 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern double host_time` | 210 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern edict_t *sv_player` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_Init` | 214 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_StartParticle` | 218 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_StartSound` | 220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_DropClient` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_SendClientMessages` | 224 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_ClearDatagram` | 226 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_ModelIndex` | 227 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_SetIdealPitch` | 229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_AddUpdates` | 231 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_ClientThink` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_AddClientToServer` | 235 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_ClientPrintf` | 236 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_BroadcastPrintf` | 238 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_Physics` | 239 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_CheckBottom` | 241 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_movestep` | 243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_WriteClientdataToMessage` | 244 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_MoveToGoal` | 246 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_CheckForNewClients` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_RunClients` | 250 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_SaveSpawnparms` | 251 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `snd_dma.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `S_AmbientOff` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_AmbientOn` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_SoundInfo_f` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_Startup` | 137 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_Init` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_Shutdown` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_FindName` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_TouchSound` | 313 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_PrecacheSound` | 330 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SND_PickChannel` | 354 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SND_Spatialize` | 398 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_StartSound` | 451 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_StopSound` | 519 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_StopAllSounds` | 535 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_StopAllSoundsC` | 554 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_ClearBuffer` | 559 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_StaticSound` | 620 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_UpdateAmbientSounds` | 664 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_Update` | 721 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetSoundtime` | 810 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_ExtraUpdate` | 844 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_Update_` | 856 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_Play` | 912 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_PlayVol` | 935 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_SoundList` | 960 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_LocalSound` | 985 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_ClearPrecache` | 1004 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_BeginPrecaching` | 1009 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_EndPrecaching` | 1014 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_SFX` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// ======================================================================= // Internal sound data & structures // ======================================================================= channel_t channels[MAX_CHANNELS]` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int total_channels` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int snd_blocked = 0` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean snd_ambient = 1` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean snd_initialized = false` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// pointer should go away volatile dma_t *shm = 0` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `volatile dma_t sn` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t listener_origin` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t listener_forward` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t listener_right` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t listener_up` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec_t sound_nominal_clip_dist=1000.0` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int soundtime` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// sample PAIRS int paintedtime` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// sample PAIRS #define MAX_SFX 512 sfx_t *known_sfx` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// hunk allocated [MAX_SFX] int num_sfx` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t *ambient_sfx[NUM_AMBIENTS]` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int desired_speed = 11025` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int desired_bits = 16` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int sound_started=0` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int fakedma_updates = 15` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Play` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_PlayVol` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_SoundList` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Update_` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_StopAllSounds` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_StopAllSoundsC` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `snd_mem.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `ResampleSfx` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_LoadSound` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetLittleShort` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetLittleLong` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FindNextChunk` | 192 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FindChunk` | 220 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DumpChunks` | 227 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `GetWavinfo` | 248 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============================================================================== WAV loading =============================================================================== */ byte *data_p` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *iff_end` | 165 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *last_chunk` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *iff_data` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int iff_chunk_len` | 168 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Alloc` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `snd_mix.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Snd_WriteLinearBlastStereo16` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_TransferStereo16` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_TransferPaintBuffer` | 139 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_PaintChannels` | 261 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SND_InitScaletable` | 334 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SND_PaintChannelFrom8` | 346 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SND_PaintChannelFrom16` | 375 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DWORD` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PAINTBUFFER_SIZE` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int snd_scaletable[32][256]` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int *snd_p, snd_linear_count, snd_vol` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `short *snd_out` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Snd_WriteLinearBlastStereo16` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SND_PaintChannelFrom8` | 247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SND_PaintChannelFrom16` | 258 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `snd_mixa.s`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `snd_win.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `S_BlockSound` | 78 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `S_UnblockSound` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `FreeSound` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SNDDMA_InitDirect` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SNDDMA_InitWav` | 422 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SNDDMA_Init` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SNDDMA_GetDMAPos` | 635 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SNDDMA_Submit` | 667 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SNDDMA_Shutdown` | 725 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `sndinitstat` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `sndinitstat.SIS_SUCCESS` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `sndinitstat.SIS_FAILURE` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `sndinitstat.SIS_NOTAVAIL` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `iDirectSoundCreate` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WAV_BUFFERS` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WAV_MASK` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WAV_BUFFER_SIZE` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SECONDARY_BUFFER_SIZE` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sndinitstat` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean wavonly` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean dsound_init` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean wav_init` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean snd_firsttime = true, snd_isdirect, snd_iswave` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean primary_format_set` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int sample16` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int snd_sent, snd_completed` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* * Global variables. Must be visible to window-procedure function * so it can unlock and free the data block after it has been played. */ HANDLE hData` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HPSTR lpData, lpData2` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HGLOBAL hWaveHdr` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `LPWAVEHDR lpWaveHdr` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HWAVEOUT hWaveOut` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `WAVEOUTCAPS wavecaps` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `DWORD gSndBufSize` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `MMTIME mmstarttime` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `LPDIRECTSOUND pDS` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `LPDIRECTSOUNDBUFFER pDSBuf, pDSPBuf` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HINSTANCE hInstDS` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `iDirectSoundCreate` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SNDDMA_InitDirect` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SNDDMA_InitWav` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sound.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `portable_samplepair_t` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `portable_samplepair_t.int left` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `portable_samplepair_t.int right` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `sfx_t` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfx_t.char name[MAX_QPATH]` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfx_t.cache_user_t cache` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `sfxcache_t` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfxcache_t.int length` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfxcache_t.int loopstart` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfxcache_t.int speed` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfxcache_t.int width` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfxcache_t.int stereo` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `sfxcache_t.byte data[1]` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dma_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.qboolean gamealive` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.qboolean soundalive` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.qboolean splitbuffer` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.int channels` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.int samples` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.// mono samples in buffer int submission_chunk` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.// don't mix less than this # int samplepos` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.// in mono samples int samplebits` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.int speed` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dma_t.unsigned char *buffer` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `channel_t` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.sfx_t *sfx` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// sfx number int leftvol` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// 0-255 volume int rightvol` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// 0-255 volume int end` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// end time in global paintsamples int pos` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// sample position in sfx int looping` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// where to loop, -1 = no looping int entnum` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// to allow overriding a specific sound int entchannel` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// vec3_t origin` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// origin of sound effect vec_t dist_mult` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `channel_t.// distance multiplier (attenuation/clipK) int master_vol` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `wavinfo_t` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wavinfo_t.int rate` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wavinfo_t.int width` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wavinfo_t.int channels` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wavinfo_t.int loopstart` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wavinfo_t.int samples` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wavinfo_t.int dataofs` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `__SOUND__` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEFAULT_SOUND_PACKET_VOLUME` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DEFAULT_SOUND_PACKET_ATTENUATION` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_CHANNELS` | 130 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_DYNAMIC_CHANNELS` | 131 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `portable_samplepair_t` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfx_t` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `sfxcache_t` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dma_t` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `channel_t` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `wavinfo_t` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// ==================================================================== // User-setable variables // ==================================================================== #define MAX_CHANNELS 128 #define MAX_DYNAMIC_CHANNELS 8 extern channel_t channels[MAX_CHANNELS]` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// 0 to MAX_DYNAMIC_CHANNELS-1 = normal entity sounds // MAX_DYNAMIC_CHANNELS to MAX_DYNAMIC_CHANNELS + NUM_AMBIENTS -1 = water, etc // MAX_DYNAMIC_CHANNELS + NUM_AMBIENTS to total_channels = static sounds extern int total_channels` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int fakedma_updates` | 147 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int paintedtime` | 148 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t listener_origin` | 149 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t listener_forward` | 150 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t listener_right` | 151 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec3_t listener_up` | 152 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern volatile dma_t *shm` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern volatile dma_t sn` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern vec_t sound_nominal_clip_dist` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t loadas8bit` | 156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t bgmvolume` | 158 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t volume` | 159 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean snd_initialized` | 160 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int snd_blocked` | 162 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Init` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Startup` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Shutdown` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_StartSound` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_StaticSound` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_StopSound` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_StopAllSounds` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_ClearBuffer` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_Update` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_ExtraUpdate` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_PrecacheSound` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_TouchSound` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_ClearPrecache` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_BeginPrecaching` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_EndPrecaching` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_PaintChannels` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_InitPaintChannels` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SND_PickChannel` | 109 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SND_Spatialize` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SNDDMA_Init` | 115 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SNDDMA_GetDMAPos` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SNDDMA_Shutdown` | 121 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_LocalSound` | 164 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_LoadSound` | 166 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `GetWavinfo` | 167 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SND_InitScaletable` | 169 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SNDDMA_Submit` | 171 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_AmbientOff` | 172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_AmbientOn` | 174 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `spritegn.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `synctype_t` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `synctype_t.ST_SYNC=0` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `synctype_t.ST_RAND` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dsprite_t` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.int ident` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.int version` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.int type` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.float boundingradius` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.int width` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.int height` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.int numframes` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.float beamlength` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dsprite_t.synctype_t synctype` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dspriteframe_t` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dspriteframe_t.int origin[2]` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dspriteframe_t.int width` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dspriteframe_t.int height` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dspritegroup_t` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dspritegroup_t.int numframes` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dspriteinterval_t` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dspriteinterval_t.float interval` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `spriteframetype_t` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `spriteframetype_t.SPR_SINGLE=0` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `spriteframetype_t.SPR_GROUP` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `dspriteframetype_t` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `dspriteframetype_t.spriteframetype_t type` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPRITE_VERSION` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SYNCTYPE_T` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPR_VP_PARALLEL_UPRIGHT` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPR_FACING_UPRIGHT` | 83 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPR_VP_PARALLEL` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPR_ORIENTED` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `SPR_VP_PARALLEL_ORIENTED` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `IDSPRITEHEADER` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `synctype_t` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dsprite_t` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dspriteframe_t` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dspritegroup_t` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dspriteinterval_t` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `spriteframetype_t` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `dspriteframetype_t` | 106 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sv_main.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SV_Init` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_StartParticle` | 80 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_StartSound` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_SendServerinfo` | 189 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ConnectClient` | 243 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CheckForNewClients` | 302 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ClearDatagram` | 348 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_AddToFatPVS` | 367 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_FatPVS` | 410 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_WriteEntitiesToClient` | 427 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CleanupEnts` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_WriteClientdataToMessage` | 576 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_SendClientDatagram` | 720 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_UpdateToReliableMessages` | 756 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_SendNop` | 798 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_SendClientMessages` | 819 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ModelIndex` | 904 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CreateBaseline` | 925 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_SendReconnect` | 985 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_SaveSpawnparms` | 1015 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `server_static_t svs` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char localmodels[MAX_MODELS][5]` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================= The PVS must include a small area around the client to allow head bobbing or other small motion on the client side. Otherwise, a bob might cause an entity that should be visible to not show up, especially when the bob crosses a waterline. ============================================================================= */ int fatbytes` | 351 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte fatpvs[MAX_MAP_LEAFS/8]` | 364 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ================ SV_SpawnServer This is called at the start of each level ================ */ extern float scr_centertime_off` | 1032 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sv_move.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SV_CheckBottom` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_movestep` | 110 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_StepDirection` | 233 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_FixCheckBottom` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_NewChaseDir` | 284 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CloseEnough` | 373 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_MoveToGoal` | 393 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STEPSIZE` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DI_NODIR` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `PF_changeyaw` | 218 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sv_phys.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SV_CheckAllEnts` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CheckVelocity` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_RunThink` | 126 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Impact` | 153 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `ClipVelocity` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_FlyMove` | 229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_AddGravity` | 371 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_PushEntity` | 408 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_PushMove` | 439 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_PushRotate` | 566 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Pusher` | 704 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CheckStuck` | 762 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CheckWater` | 808 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_WallFriction` | 867 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_TryUnstick` | 901 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_WalkMove` | 958 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Client` | 1059 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_None` | 1142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Follow` | 1156 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Noclip` | 1172 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CheckWaterTransition` | 1198 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Toss` | 1245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Step` | 1363 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics_Step` | 1468 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Physics` | 1507 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Trace_Toss` | 1568 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVE_EPSILON` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STOP_EPSILON` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_CLIP_PLANES` | 228 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `STEPSIZE` | 957 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sv_user.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SV_SetIdealPitch` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_UserFriction` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Accelerate` | 170 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Accelerate` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_AirAccelerate` | 207 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `DropPunchAngle` | 229 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_WaterMove` | 247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_WaterJump` | 307 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_AirMove` | 326 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ClientThink` | 380 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ReadClientMove` | 438 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ReadClientMessage` | 482 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_RunClients` | 600 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_FORWARD` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t sv_friction` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t sv_stopspeed` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static vec3_t forward, right, up` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vec3_t wishdir` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float wishspeed` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// world float *angles` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float *origin` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float *velocity` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean onground` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `usercmd_t cmd` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sys.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| prototype | `Sys_FileOpenRead` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FileOpenWrite` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FileClose` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FileSeek` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FileRead` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FileWrite` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FileTime` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_mkdir` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_MakeCodeWriteable` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_DebugLog` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_Error` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_Printf` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_Quit` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_FloatTime` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_ConsoleInput` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_Sleep` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_SendKeyEvents` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Key_Event` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_HighFPPrecision` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_SetFPCW` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sys_win.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Sys_PageIn` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `findhandle` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `filelength` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileOpenRead` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileOpenWrite` | 163 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileClose` | 183 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileSeek` | 193 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileRead` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileWrite` | 212 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FileTime` | 222 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_mkdir` | 245 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_MakeCodeWriteable` | 264 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_SetFPCW` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_PushFPCW_SetHigh` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_PopFPCW` | 283 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `MaskExceptions` | 287 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_Init` | 298 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_Error` | 346 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_Printf` | 426 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_Quit` | 442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_FloatTime` | 467 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_InitFloatTime` | 534 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_ConsoleInput` | 555 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_Sleep` | 635 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Sys_SendKeyEvents` | 641 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SleepUntilInput` | 673 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `WinMain` | 692 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MINIMUM_WIN_MEMORY` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAXIMUM_WIN_MEMORY` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CONSOLE_ERROR_TIMEOUT` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `PAUSE_SLEEP` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `NOT_FOCUS_SLEEP` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MAX_HANDLES` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean ActiveApp, Minimized` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean WinNT` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static double pfreq` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static double curtime = 0.0` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static double lastcurtime = 0.0` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int lowshift` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean isDedicated` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static qboolean sc_return_on_enter = false` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HANDLE hinput, houtput` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static char *tracking_tag = "Clams & Mooses"` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static HANDLE tevent` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static HANDLE hFile` | 50 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static HANDLE heventParent` | 51 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static HANDLE heventChild` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `volatile int sys_checksum` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============================================================================== FILE IO =============================================================================== */ #define MAX_HANDLES 10 FILE *sys_handles[MAX_HANDLES]` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ================== WinMain ================== */ HINSTANCE global_hInstance` | 677 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int global_nCmdShow` | 685 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `char *argv[MAX_NUM_ARGVS]` | 686 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static char *empty_string = ""` | 687 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `HWND hwnd_dialog` | 688 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `MaskExceptions` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_InitFloatTime` | 55 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_PushFPCW_SetHigh` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Sys_PopFPCW` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `sys_wina.s`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `vid.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `vrect_t` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vrect_t.int x,y,width,height` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `vrect_t.struct vrect_s *pnext` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `viddef_t` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.pixel_t *buffer` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// invisible buffer pixel_t *colormap` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// 256 * VID_GRADES size unsigned short *colormap16` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// 256 * VID_GRADES size int fullbright` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// index of first fullbright color unsigned rowbytes` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// may be > width if displayed in a window unsigned width` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.unsigned height` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.float aspect` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// width / height -- < 0 is taller than wide int numpages` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.int recalc_refdef` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.// if true, recalc vid-based stuff pixel_t *conbuffer` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.int conrowbytes` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.unsigned conwidth` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.unsigned conheight` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.int maxwarpwidth` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.int maxwarpheight` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `viddef_t.pixel_t *direct` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VID_CBITS` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `VID_GRADES` | 23 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `vrect_t` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `viddef_t` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern viddef_t vid` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// global video state extern unsigned short d_8to16table[256]` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern unsigned d_8to24table[256]` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 58 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `void` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_SetPalette` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_ShiftPalette` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_Init` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_Shutdown` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_Update` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_SetMode` | 76 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_HandlePause` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `view.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `V_CalcRoll` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CalcBob` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_StartPitchDrift` | 146 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_StopPitchDrift` | 162 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_DriftPitch` | 182 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `BuildGammaTable` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CheckGamma` | 295 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_ParseDamage` | 316 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_cshift_f` | 387 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_BonusFlash_f` | 403 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_SetContentsColor` | 418 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CalcPowerupCshift` | 442 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CalcBlend` | 482 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_UpdatePalette` | 527 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_UpdatePalette` | 614 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `angledelta` | 692 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `CalcGunAngle` | 705 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_BoundOffsets` | 763 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_AddIdle` | 793 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CalcViewRoll` | 808 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CalcIntermissionRefdef` | 837 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_CalcRefdef` | 864 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_RenderView` | 995 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `V_Init` | 1071 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float v_dmg_time, v_dmg_roll, v_dmg_pitch` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int in_forward, in_forward2, in_back` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============== V_CalcRoll Used by view and sv_user =============== */ vec3_t forward, right, up` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte gammatable[256]` | 259 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// palette is sent through this #ifdef GLQUAKE byte ramps[3][256]` | 261 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `float v_blend[4]` | 264 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `view.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| global | `extern byte gammatable[256]` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `// palette is sent through this extern byte ramps[3][256]` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern float v_blend[4]` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t lcd_x` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_Init` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_RenderView` | 31 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_CalcRoll` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `V_UpdatePalette` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `wad.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `W_CleanupName` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `W_LoadWadFile` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `W_GetLumpinfo` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `W_GetLumpName` | 125 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `W_GetLumpNum` | 134 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SwapPic` | 154 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lumpinfo_t *wad_lumps` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *wad_base` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SwapPic` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `wad.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `qpic_t` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qpic_t.int width, height` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `qpic_t.byte data[4]` | 39 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `wadinfo_t` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wadinfo_t.char identification[4]` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wadinfo_t.// should be WAD2 or 2DAW int numlumps` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `wadinfo_t.int infotableofs` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `lumpinfo_t` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.int filepos` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.int disksize` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.int size` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.// uncompressed char type` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.char compression` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.char pad1, pad2` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `lumpinfo_t.char name[16]` | 54 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CMP_NONE` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `CMP_LZSS` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_NONE` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_LABEL` | 30 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_LUMPY` | 32 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_PALETTE` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_QTEX` | 34 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_QPIC` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_SOUND` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `TYP_MIPTEX` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qpic_t` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `wadinfo_t` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `lumpinfo_t` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int wad_numlumps` | 63 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern lumpinfo_t *wad_lumps` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern byte *wad_base` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `W_LoadWadFile` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `W_CleanupName` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `W_GetLumpinfo` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `W_GetLumpName` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `W_GetLumpNum` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SwapPic` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `winquake.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `modestate_t` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modestate_t.MS_WINDOWED` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modestate_t.MS_FULLSCREEN` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modestate_t.MS_FULLDIB` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| enum-value | `modestate_t.MS_UNINIT` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `WM_MOUSEWHEEL` | 25 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int global_nCmdShow` | 35 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean DDActive` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern LPDIRECTDRAWSURFACE lpPrimary` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern LPDIRECTDRAWSURFACE lpFrontBuffer` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern LPDIRECTDRAWSURFACE lpBackBuffer` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern LPDIRECTDRAWPALETTE lpDDPal` | 44 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern LPDIRECTSOUND pDS` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern LPDIRECTSOUNDBUFFER pDSBuf` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern DWORD gSndBufSize` | 47 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `modestate_t` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern modestate_t modestate` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern HWND mainwindow` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean ActiveApp, Minimized` | 61 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean WinNT` | 62 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean winsock_lib_initialized` | 75 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern cvar_t _windowed_mouse` | 77 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern int window_center_x, window_center_y` | 79 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern RECT window_rect` | 81 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern qboolean mouseinitialized` | 82 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern HWND hwnd_dialog` | 84 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `extern HANDLE hinput, houtput` | 85 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_LockBuffer` | 49 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_UnlockBuffer` | 52 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_ForceUnlockedAndReturnState` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_ForceLockState` | 66 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_ShowMouse` | 67 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_DeactivateMouse` | 69 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_HideMouse` | 70 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_ActivateMouse` | 71 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_RestoreOriginalMouseState` | 72 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_SetQuakeMouseState` | 73 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_MouseEvent` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `IN_UpdateClipCursor` | 87 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `CenterWindow` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_BlockSound` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `S_UnblockSound` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `VID_SetDefaultMode` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 95 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 98 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SOCKET` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 100 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 103 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 108 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `int` | 112 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `winquake.rc`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `world.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `SV_InitBoxHull` | 68 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_HullForBox` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_HullForEntity` | 129 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_CreateAreaNode` | 202 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ClearWorld` | 247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_UnlinkEdict` | 263 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_TouchLinks` | 277 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_FindTouchedLeafs` | 328 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_LinkEdict` | 372 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_HullPointContents` | 491 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_PointContents` | 527 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_TruePointContents` | 537 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_TestEntityPosition` | 551 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_RecursiveHullCheck` | 581 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ClipMoveToEntity` | 722 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_ClipToLinks` | 814 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_MoveBounds` | 893 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `SV_Move` | 923 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `moveclip_t` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.vec3_t boxmins, boxmaxs` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.// enclose the test object along entire move float *mins, *maxs` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.// size of the moving object vec3_t mins2, maxs2` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.// size when clipping against mosnters float *start, *end` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.trace_t trace` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.int type` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `moveclip_t.edict_t *passedict` | 33 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `areanode_t` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `areanode_t.int axis` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `areanode_t.// -1 = leaf node float dist` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `areanode_t.struct areanode_s *children[2]` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `areanode_t.link_t trigger_edicts` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `areanode_t.link_t solid_edicts` | 181 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AREA_DEPTH` | 190 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `AREA_NODES` | 191 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DIST_EPSILON` | 573 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `moveclip_t` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* =============================================================================== HULL BOXES =============================================================================== */ static hull_t box_hull` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static dclipnode_t box_clipnodes[6]` | 56 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static mplane_t box_planes[6]` | 57 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `areanode_t` | 188 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `static int sv_numareanodes` | 193 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_HullPointContents` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `world.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `plane_t` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `plane_t.vec3_t normal` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `plane_t.float dist` | 22 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `trace_t` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.qboolean allsolid` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.// if true, plane is not valid qboolean startsolid` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.// if true, the initial point was in a solid area qboolean inopen, inwater` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.float fraction` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.// time completed, 1.0 = didn't hit anything vec3_t endpos` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.// final position plane_t plane` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `trace_t.// surface normal at impact edict_t *ent` | 28 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVE_NORMAL` | 40 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVE_NOMONSTERS` | 41 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MOVE_MISSILE` | 42 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `plane_t` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `trace_t` | 37 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_UnlinkEdict` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_LinkEdict` | 48 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_PointContents` | 53 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_TruePointContents` | 59 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_TestEntityPosition` | 60 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `SV_Move` | 65 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `worlda.s`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|

## `zone.c`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| function | `Z_ClearZone` | 74 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Z_Free` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Z_Malloc` | 142 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Z_TagMalloc` | 155 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Z_Print` | 219 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Z_CheckHeap` | 247 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_Check` | 293 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_Print` | 315 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_AllocName` | 399 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_Alloc` | 434 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_LowMark` | 439 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_FreeToLowMark` | 444 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_HighMark` | 452 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_FreeToHighMark` | 463 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_HighAllocName` | 482 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Hunk_TempAlloc` | 528 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Move` | 575 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_FreeLow` | 606 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_FreeHigh` | 628 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_UnlinkLRU` | 650 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_MakeLRU` | 661 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_TryAlloc` | 680 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Flush` | 759 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Print` | 772 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Report` | 788 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Compact` | 799 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Init` | 809 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Free` | 824 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Check` | 849 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Cache_Alloc` | 871 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| function | `Memory_Init` | 913 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `memblock_t` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memblock_t.int size` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memblock_t.// including the header and possibly tiny fragments int tag` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memblock_t.// a tag of 0 is a free block int id` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memblock_t.// should be ZONEID struct memblock_s *next, *prev` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memblock_t.int pad` | 29 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `memzone_t` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memzone_t.int size` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memzone_t.// total bytes malloced, including header memblock_t blocklist` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `memzone_t.// start / end cap for linked list memblock_t *rover` | 38 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `hunk_t` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hunk_t.int sentinal` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hunk_t.int size` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `hunk_t.// including sizeof(hunk_t), -1 = not allocated char name[8]` | 268 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| type | `cache_system_t` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cache_system_t.int size` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cache_system_t.// including this header cache_user_t *user` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cache_system_t.char name[16]` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cache_system_t.struct cache_system_s *prev, *next` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cache_system_t.struct cache_system_s *lru_prev, *lru_next` | 557 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `DYNAMIC_SIZE` | 24 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `ZONEID` | 26 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `MINFRAGMENT` | 27 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| macro | `HUNK_SENTINAL` | 266 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `memblock_t` | 36 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `memzone_t` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `/* ============================================================================== ZONE MEMORY ALLOCATION There is never any space between memblocks, and there will never be two contiguous free memblocks. The rover can be left pointing at a non-empty block The zone calls are pretty much only used for small strings and structures, all big things are allocated on the hunk. ============================================================================== */ memzone_t *mainzone` | 46 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `hunk_t` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `byte *hunk_base` | 273 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int hunk_size` | 275 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int hunk_low_used` | 276 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int hunk_high_used` | 278 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `qboolean hunk_tempactive` | 279 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `int hunk_tempmark` | 281 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cache_system_t` | 564 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cache_system_t cache_head` | 566 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_FreeLow` | 43 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_FreeHigh` | 45 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_ClearZone` | 64 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `R_FreeTextures` | 282 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_TryAlloc` | 564 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

## `zone.h`

File status: **review-required** — Manual source review has not yet been recorded.

| Kind | Original declaration | Line | Status | MiniQuake mapping | Review reason |
|---|---|---:|---|---|---|
| type | `cache_user_t` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| field | `cache_user_t.void *data` | 111 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| global | `cache_user_t` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_Print` | 1 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_Free` | 86 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_Malloc` | 88 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_TagMalloc` | 89 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_DumpHeap` | 90 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_CheckHeap` | 92 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Z_FreeMemory` | 93 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_Alloc` | 94 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_AllocName` | 96 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_HighAllocName` | 97 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_LowMark` | 99 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_FreeToLowMark` | 101 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_HighMark` | 102 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_FreeToHighMark` | 104 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_TempAlloc` | 105 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Hunk_Check` | 107 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_Flush` | 114 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_Check` | 116 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_Free` | 118 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_Alloc` | 122 | review-required |  | Manual declaration/behavior review has not yet been recorded. |
| prototype | `Cache_Report` | 124 | review-required |  | Manual declaration/behavior review has not yet been recorded. |

