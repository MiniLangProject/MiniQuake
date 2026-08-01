# MiniQuake BP-035–BP-039 — Client/render compatibility closure

This cumulative block advances the WinQuake/GLQuake 1.09 client and visual
state path without changing the accepted Protocol 15, QuakeC, world/physics or
host/lifecycle contracts.

| Step | Scope | Runtime fixtures |
|---|---|---:|
| BP-035 | client state, dlights, interpolation and visible handoff | 20 |
| BP-036 | view state, cshift and chase refdef | 22 |
| BP-037 | temporary beam model entities | 22 |
| BP-038 | particle runtime and `sv_gravity` handoff | 22 |
| BP-039 | efrag/submission closure and frozen contract | 24 |

Total new MiniLang fixtures: **110**.

The PowerShell trailing-comma error reported after the accepted BP-030–034R1
run is fixed in `COLLECT_RESULTS.ps1`.
