# BP-028 source audit – `sv_phys.c` and client movement

Compared original paths include:

- `SV_CheckVelocity`, `SV_RunThink`, `SV_Impact`
- `SV_PushMove`, `SV_Physics_Pusher`
- `SV_Physics_Client`, `SV_Physics_None`, `SV_Physics_Noclip`
- `SV_Physics_Toss`, `SV_Physics_Step`, `SV_Physics`
- `SV_UserFriction`, `SV_Accelerate`, `SV_AirAccelerate`, `SV_AirMove`

MiniLang target: `src/miniquake/physics.ml`.

The compatibility profile is the unconditioned WinQuake/GLQuake 1.09 branch.
QUAKE2-only movetypes are never selected by the strict dispatcher. The audit
also binds pusher rollback ordering, expanded linked bounds, corpse-bound
collapse, Binary32 angle/movement boundaries and final relinking. The block
contains 18 server-physics and 16 client-movement runtime fixtures.
