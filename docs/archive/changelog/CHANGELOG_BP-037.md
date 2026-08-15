# BP-037 — Temporary beam model entities

- Builds `CL_UpdateTEnts`-style temporary alias entities for beams.
- Maps the four beam types to `bolt.mdl`, `bolt2.mdl`, `bolt3.mdl` and `beam.mdl`.
- Emits 30-unit segments with original-style random roll.
- Uses the current view-entity origin for player-owned beams.
- Enforces both `MAX_TEMP_ENTITIES` and `MAX_VISEDICTS`.
- Adds 22 MiniLang runtime fixtures and an independent C oracle.
