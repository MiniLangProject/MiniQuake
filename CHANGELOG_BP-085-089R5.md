# MiniQuake BP-085–BP-089R5

Parent delivery: **BP-085–BP-089R4**.

- Preserves IEEE-754 negative zero while parsing Quake-v5 savegame numbers.
- Adds `common.cAtof`, backed by the existing native `strtod` → C-`float`
  boundary (`mq_f32_from_text`).
- Routes QuakeC scalar globals, scalar fields, vector components and savegame
  scalar lines through the original-compatible C `atof` boundary.
- Extends BP-070, BP-022, BP-033 and BP-087 fixtures with explicit
  `-0.000000` → `0x80000000` checks.
- Adds a hexadecimal signed-zero marker to retail savegame evidence.
- Separates the historical BP-033 `toNumber` parser checker from the accepted
  downstream native `strtod` parser contract.
- Keeps the artifact contract and release-candidate fingerprints unchanged;
  this revision fixes the implementation required by the existing exact
  savegame-roundtrip claim.
