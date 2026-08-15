# MiniQuake BP-085–BP-089R6

Parent delivery: **BP-085–BP-089R5**.

- Keeps the now-passing Retail demo and Quake-v5 savegame roundtrip from R5.
- Fixes a remaining native-GC rooting edge in the per-frame QuakeC-to-server
  Edict mirror (`syncQuakeCEdict` / `syncQuakeCEdicts`).
- Roots every returned `Vec3`, the constructed `EntityBaseline`, and the
  returned `QuakeEdict` in named locals before storing them in heap fields or
  arrays.
- Applies the same rooted handoff to QuakeC-to-player vector synchronization.
- Adds precise production errors that name the Edict and vector field if a
  non-`Vec3` value is ever observed during synchronization.
- Extends the existing ten-test diagnostics suite with an internal forced-GC
  mirror regression: 96 real QuakeC Edicts, six complete mirror rebuilds,
  `gc_set_limit(512)`, explicit collections, and validation of every vector and
  baseline field.
- Updates inherited source-contract checkers without weakening their historical
  modes: BP-012 accepts either direct or explicitly GC-rooted baseline
  preservation, while the BP-029 downstream checker keeps the three frozen
  physics sections byte-bound and separately hashes all five R6 mirror
  functions.
- Keeps all compatibility statuses and fingerprints unchanged; R6 repairs the
  implementation required by the existing deterministic-trace contract.
