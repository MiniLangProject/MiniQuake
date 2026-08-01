# BP-074 core assets/memory audit

The frozen contract combines the black-port results for `common.c`, `crc.c`,
PACK search paths, `wad.c`, `gl_model.c`, the BSP/MDL/SPR format headers and
`zone.c`.

The retail evidence reads `gfx.wad`, `maps/start.bsp`, `progs/player.mdl` and
`progs.dat` from the user's Quake installation. It emits only sizes, CRCs and
parsed counts; no game data is copied into result archives.
