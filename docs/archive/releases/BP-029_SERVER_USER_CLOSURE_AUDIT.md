# BP-029 source audit – `sv_user.c` and integrated production dispatch

Compared original paths include:

- `SV_SetIdealPitch`
- `SV_ReadClientMove`
- `SV_ReadClientMessage`
- `SV_RunClients`
- client string-command whitelist and privileged-source ordering
- frame-time, ping and water-jump decisions

MiniLang targets:

- `src/miniquake/sv_user.ml`
- `src/miniquake/server.ml`
- `src/miniquake/physics.ml`
- `src/miniquake/world_physics_contract.ml`

The integrated server frame now calls `SV_Physics_NonClientEntity` for world
entity zero and all non-client edicts. Client and non-client force-retouch links
occur in original edict order (world zero, clients, then remaining entities),
and `force_retouch` is decremented exactly once after the frame. This removes
the former simplified production-only movement path while
retaining the focused direct physics entry point for differential tests.

The cumulative status is `world_physics_109_frozen_v1`; the contract fingerprint
is `0x2235d77c`. Eighteen server-user fixtures and twenty closure fixtures bind
the final block.
