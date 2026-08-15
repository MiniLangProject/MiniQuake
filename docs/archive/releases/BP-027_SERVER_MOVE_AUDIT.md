# BP-027 source audit – `sv_move.c`

Compared original paths:

- `SV_CheckBottom`
- `SV_movestep`
- `SV_StepDirection`
- `SV_FixCheckBottom`
- `SV_NewChaseDir`
- `SV_CloseEnough`
- `SV_MoveToGoal`

MiniLang target: `src/miniquake/server_move.ml`.

The audit covers flying/swimming movement, 18-unit stair attempts, partial
support, bottom checks, yaw gating, relink/touch ordering, historical diagonal
values and the random branch used to choose chase directions. Fourteen runtime
fixtures and an independent C oracle are included.
