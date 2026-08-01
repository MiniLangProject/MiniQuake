# BP-025 source audit – `world.c` hull and trace paths

Compared original paths:

- `SV_InitBoxHull`
- `SV_HullForBox`
- `SV_HullPointContents`
- `SV_RecursiveHullCheck`
- `SV_Move` world/brush coordinate conversion

MiniLang targets:

- `src/miniquake/world_hull.ml`
- `src/miniquake/world.ml`
- `src/miniquake/world_bsp.ml`

The audit binds node/plane orientation, child contents, epsilon handling,
start-solid/all-solid flags, clear-trace endpoint preservation and conversion
of translated brush impact planes back to world space. The runtime suites are
`world_hull_parity_tests.ml` (14) and `world_trace_parity_tests.ml` (10).
