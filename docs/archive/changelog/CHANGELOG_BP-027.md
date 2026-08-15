# BP-027 – Monster movement parity

- Aligns `SV_CheckBottom`, `SV_movestep`, `SV_StepDirection`, `SV_NewChaseDir` and `SV_MoveToGoal` with WinQuake 1.09.
- Restores partial-ground behavior, 18-unit stair stepping and final relink/touch ordering.
- Preserves the historical diagonal direction constants and the engine random sequence used for chase decisions.
- Adds 14 runtime fixtures and an independent C oracle.
