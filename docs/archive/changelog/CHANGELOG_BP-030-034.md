# MiniQuake BP-030–BP-034

Cumulative host, command/cvar, demo, savegame-v5 and lifecycle compatibility block.

- BP-030: WinQuake `Host_FilterTime` and frame-clock boundaries.
- BP-031: command-buffer, alias and cvar lifecycle parity.
- BP-032: demo recording, playback, view-angle and timedemo parity.
- BP-033: byte-preserving Quake-v5 savegame parsing and serialization.
- BP-034: map/changelevel/restart/disconnect/quit, shutdown and error lifecycle closure.

The package preserves the Windows-accepted Protocol 15, QuakeC and world/physics
contracts. The new candidate contract is:

```text
host_lifecycle_109_frozen_v1
fingerprint=0x8cbb709f
```

The five new runtime suites contain 106 fixtures in total.
