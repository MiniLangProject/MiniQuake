# BP-072 — WAD and graphics-data parity

- Makes `W_CleanupName` and stored WAD names byte-faithful for Quake characters `0x00..0xff`.
- Binds WAD2 directory layout, qpic byte swapping, lookup normalization and compressed-lump policy.
- Verifies `gfx.wad` as the primary console-font source with the historical loose-file fallback.
- Adds 20 runtime fixtures, an independent C oracle and a static checker.
