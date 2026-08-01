# BP-079 — gameplay/presentation closure

- Introduces one shared host-command numeric conversion surface.
- Uses the C runtime `atoi` decimal-prefix semantics for color, give and viewframe arguments.
- Uses Quake `Q_atoi` for the `edict` debug command and `Q_atof` for `#` player indexes.
- Adds the `gameplay_presentation_109_frozen_v1` candidate contract.
