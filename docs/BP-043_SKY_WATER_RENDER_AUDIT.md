# BP-043 audit – sky, water and subdivision

## Original reference

`gl_warp.c` and its `gl_warp_sin.h` table.

## Ported behavior

- Turbulent water texture coordinates retain the original sine-table indexing,
  scale and Binary32 storage.
- Sky coordinates normalize the direction vector and apply the original layer
  scales.
- Wrapped sky speeds remain stable at their modulo boundary.
- Recursive subdivision uses the original 128-unit default and split rules.
- Sky texture initialization preserves the transparent foreground and averaged
  opaque background layers.

## Evidence

The C oracle, JSON golden rows and 22 MiniLang fixtures bind exact Binary32
words for representative water/sky coordinates, wrap boundaries, subdivision,
invalid textures/palettes and two-layer speeds.
