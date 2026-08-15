# BP-036 — View state and chase camera

- Uses Quake `atoi` semantics for `v_cshift` command arguments.
- Adds a refdef-aware chase-camera update matching `chase.c`.
- Replaces only chase pitch while preserving rendered yaw and roll.
- Keeps the traced chase destination and view-vector recomputation explicit.
- Adds 22 MiniLang runtime fixtures and an independent C oracle.
