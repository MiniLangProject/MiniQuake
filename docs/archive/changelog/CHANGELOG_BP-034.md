# BP-034 – Host lifecycle closure

- Freezes the accepted host/lifecycle contract as `host_lifecycle_109_frozen_v1` with fingerprint `0x8cbb709f`.
- Routes map replacement, remote connect, demo start, disconnect and quit through the host shutdown path instead of clearing server state directly.
- Preserves the original distinction between `changelevel` (save change parms) and `restart` (reuse existing spawn parms).
- Adds 24 host lifecycle closure fixtures and an independent C/Python contract oracle.
