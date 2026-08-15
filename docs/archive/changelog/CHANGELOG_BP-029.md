# BP-029 – Server user path and world/physics closure

- Aligns `SV_ReadClientMessage`, command privilege order, ping accumulation, frame clamping, water-jump gates and ideal-pitch sampling.
- Routes the integrated production non-client loop through the same strict `SV_Physics_*` dispatcher as the direct `sv_main` pendant.
- Preserves original entity-order `force_retouch` relinking and a single post-frame decrement.
- Processes world entity zero before client slots and all remaining non-client edicts afterwards, matching the original `SV_Physics` loop order.
- Freezes the cumulative contract as `world_physics_109_frozen_v1` with fingerprint `0x2235d77c`.
- Adds 18 server-user fixtures and 20 cumulative closure fixtures.
