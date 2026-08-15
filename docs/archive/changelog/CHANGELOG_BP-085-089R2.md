# MiniQuake BP-085–BP-089R2

Parent delivery: **BP-085–BP-089R1**.

- Replaces the overflow-prone integer-scaled fixed-six formatter with the same
  MSVCRT `%f` boundary used by WinQuake.
- Adds `mqt_f32_to_fixed6` to the caller-owned text bridge.
- Routes QuakeC edict text, Cvar values and Quake-v5 saves through one shared
  Binary32 six-decimal formatter.
- Adds regression vectors for `4097`, `-4097`, `16777215`, negative zero and
  rounding boundaries.
- Requires retail evidence to print and validate
  `save_float_format=4097:4097.000000 negative:-4097.000000`.
- Preserves the R1 sequential-session, edict-high-water and relinking fixes.
- Does not change the artifact or release-candidate fingerprints.
