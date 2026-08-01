# MiniQuake BP-075–BP-079R1

## Fixed

- The inherited BP-029 world/physics checker no longer rejects unrelated downstream edits in `src/miniquake/server.ml`.
- Historical strict mode still binds the exact accepted BP-029 whole-file source hashes.
- New downstream mode binds all eight unchanged authoritative files by their accepted hashes, the three world/physics-relevant `server.ml` functions independently, and the complete `server.ml` source after masking only the documented BP-079 host-command regions.
- `build.ps1` invokes the inherited world/physics checker with `--allow-downstream-package`.
- Added a revision-specific Windows runner, collector metadata, result analysis and block ledger.

## Unchanged

- No file under `src/` or `native/` changed from BP-075–BP-079.
- All 112 BP-075..BP-079 runtime fixtures are unchanged.
- `world_physics_109_frozen_v1` remains `0x2235d77c`.
- `gameplay_presentation_109_frozen_v1` remains `0xad91624c`.
