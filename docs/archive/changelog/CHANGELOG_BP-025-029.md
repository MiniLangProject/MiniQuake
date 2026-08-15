# MiniQuake BP-025–BP-029 – World, collision and physics closure

Parent: **BP-024R3** (`protocol15_frozen_v1`, `quakec_109_frozen_v1`).
Final package: **BP-029**. Delivery revision: **BP-025-029**.

| Step | Scope | Runtime fixtures |
|---|---|---:|
| BP-025 | box hull and world-space trace parity | 14 + 10 |
| BP-026 | entity linking and collision filtering | 15 |
| BP-027 | monster stepping and chase movement | 14 |
| BP-028 | strict server physics and client movement | 18 + 16 |
| BP-029 | server-user path and cumulative closure | 18 + 20 |
| **Total** |  | **125** |

The integrated server now uses the shared strict non-client physics dispatcher.
World entity zero is processed before the client slots, and the remaining
non-client edicts follow afterwards; there is no longer a separate simplified
production movement implementation for
doors, lifts, trains, monsters, toss objects or projectiles.

The block candidate status is:

```text
world_physics_109_frozen_v1
fingerprint=0x2235d77c
```

The status becomes an accepted frozen contract after the Windows block test,
real-game validation, 300-frame headless run, two byte-identical 128-frame
traces and UDP loopback all pass.
