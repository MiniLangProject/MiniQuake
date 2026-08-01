# MiniQuake BP-085–BP-089R8

Parent delivery: **BP-085–BP-089R7**.

- Reclassifies the R7 listen-server soak failure as a predicate false positive:
  the sparse client entity high-water advanced once from 66 to the already
  existing server Edict high-water 67 while every leak-sensitive resource
  remained within its bound.
- Models WinQuake's fixed `cl_entities[MAX_EDICTS]` and monotonic
  `cl_num_entities` semantics explicitly.
- Allows catch-up only to the maximum server high-water plus the static-entity
  offset that already existed at the measurement baseline.
- Continues to reject server Edict growth during the idle soak and rejects new
  static-table growth after the baseline.
- Centralizes the production soak predicate through
  `stability_contract.longStable(...)` and prints every individual gate.
- Adds explicit R7 catch-up, dynamic overflow, static-offset and server-growth
  fixtures while retaining the public total of 20 BP-088 tests.
- Revises the stability fingerprint to `0xd0e3c03f`; the cumulative release
  candidate fingerprint remains unchanged because its contract text binds the
  matrix shape rather than component fingerprints.
- Changes no gameplay, Protocol 15, QuakeC, physics, rendering, audio, network
  or native-bridge semantics.
