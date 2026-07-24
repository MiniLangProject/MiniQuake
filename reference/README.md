# GLQuake reference

`quake/` is the unmodified official id Software Quake repository pinned by
the top-level Git submodule.  `quake.lock.json` is the machine-verifiable
contract for the source tree used by MiniQuake's parity tests.

Run:

```powershell
python .\tools\verify_reference.py
```

The verifier checks the Git commit and tree, all C/header files below
`WinQuake`, and the historical `WinQuake/kit/GLQUAKE.EXE` oracle.  It never
uses or modifies the local `oiriginal quake source code` directory.

Reference-build instrumentation must be carried as patches below
`reference/patches/` and applied only to a generated worktree.  The submodule
itself stays clean.

The renderer oracle follows that rule end to end:

```powershell
python .\tools\renderer_differential.py
```

It compiles the pinned original `gl_draw.c`, `gl_warp.c`, `gl_rlight.c`,
`gl_rsurf.c`, `gl_refrag.c`, `gl_rmisc.c`, and `gl_rmain.c` bodies in a
detached generated worktree, then compares their normalized command/state
traces with the MiniLang counterparts.

The particle oracle follows the same generated-worktree rule:

```powershell
python .\tools\r_part_differential.py
```

It compiles every active `r_part.c` body from the pinned source and compares
pool order, deterministic Win32 `rand()` effects, protocol input, trails,
splashes, GL drawing, and per-frame particle physics with `particles.ml`.

The view oracle directly compiles the unchanged pinned source:

```powershell
python .\tools\view_differential.py
```

It executes all 23 active GLQuake `view.c` bodies and compares roll, bob,
pitch drift, damage/punch, color shifts, blend, gamma/palette hashes, refdef,
gun angles, intermission, stereo rendering, and initialization with
`view.ml`.  The non-GL software-renderer duplicate of `V_UpdatePalette` is
recorded as an explicit target exclusion.

The model oracle uses only generated, redistributable format fixtures:

```powershell
python .\tools\gl_model_differential.py
```

It directly compiles all 39 pinned `gl_model.c` bodies and compares registry,
cache, BSP29, MDL6, SPR1, PVS, hull, endian, bounds, and dispatch behavior.
Malformed BSP, MDL, and SPR inputs run in separate processes so the original
fatal error paths remain observable without checking in proprietary content.

The complete 2D draw and texture oracle also compiles unchanged pinned source:

```powershell
python .\tools\gl_draw_differential.py
```

It executes all 33 active `gl_draw.c` bodies against synthetic WAD/qpic,
palette, scrap, upload, mipmap, UI, and SGIS multitexture inputs. The two
earlier strict renderer claims (`GL_Bind` and `Draw_TileClear`) remain owned by
the renderer manifest; this manifest adds the other 31 without double
counting. Four malformed-input modes run as isolated fatal processes.
