# BP-028 – Strict server physics and client movement

- Uses only the unconditioned WinQuake 1.09 movetype dispatch; optional QUAKE2 branches are retained only as named compatibility helpers.
- Aligns pusher bounds, rollback, corpse collapse, gravity, toss/bounce, step, noclip and relink semantics.
- Restores Binary32 boundaries and full view-angle participation in client air movement.
- Adds 18 server-physics fixtures and 16 client-movement fixtures backed by independent C/Python models.
