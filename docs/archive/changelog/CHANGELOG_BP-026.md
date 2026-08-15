# BP-026 – Entity linking and collision filtering

- Restores one-unit absolute-bound expansion and the 15-unit item expansion used by `SV_LinkEdict`.
- Aligns area-node insertion, trigger overlap and unlink/relink behavior.
- Restores owner, point-entity, monster and `MOVE_NOMONSTERS` filtering at the production collision boundary.
- Routes QuakeC `setorigin`/`setsize` and entity pushes through the shared relink implementation.
- Adds 15 runtime fixtures and an independent C oracle.
