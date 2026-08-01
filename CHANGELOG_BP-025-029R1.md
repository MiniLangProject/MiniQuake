# MiniQuake BP-025–BP-029R1

Parent delivery: BP-025–BP-029  
Engine package: BP-029  
Logical block: BP-025–BP-029  
World/physics status: `world_physics_109_frozen_v1` candidate

## Fixed

- Applied a test-only import-alias repair to the two affected executable
  fixtures.
- Renamed the world-trace fixture alias from `bsp` to `bspworld`, avoiding the
  package collision with the integrated server's `miniquake.format.bsp` alias.
- Renamed the closure fixture alias from `movement` to `serverMovement`,
  avoiding the package collision with `miniquake.player_move`.
- Added a verifier that evaluates the full transitive import closure for every
  MiniLang executable entrypoint and rejects aliases that resolve to multiple
  packages.
- Added a negative regression check so either original alias collision is
  detected before the Windows compiler is started.
- Added R1-specific test logs, result collection metadata and documented the
  exact first Windows failure.

## Unchanged

- No production source under `src/` changed.
- No native source or DLL changed.
- All 125 BP-025–BP-029 runtime fixtures remain unchanged.
- Protocol 15 and QuakeC frozen contracts remain unchanged.
- The world/physics contract fingerprint remains `0x2235d77c`.
