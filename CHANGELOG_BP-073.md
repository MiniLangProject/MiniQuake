# BP-073 – BSP/MDL/SPR model asset parity

- Binds the Quake BSP v29, alias MDL v6 and sprite v1 loaders to 24 runtime fixtures.
- Exercises grouped skins/frames, sprite groups, texture animation sequencing, bounds, registry dispatch and cache lifecycle.
- Preserves case-sensitive model identity and the original alias-cache behavior of `Mod_ClearAll`.
- Adds malformed-version/count/interval fixtures and an independent C oracle.
