# BP-038 — Particle runtime parity

- Passes the current `sv_gravity` value into client particle simulation.
- Stores particle frame variables, origins, ramps and velocities at Binary32 boundaries.
- Preserves type-specific gravity, acceleration, damping and ramp behavior from `r_part.c`.
- Keeps the MSVCRT-compatible random stream shared with temporary beam rolls.
- Adds 22 MiniLang runtime fixtures and an independent C oracle.
