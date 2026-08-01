# MiniQuake BP-085–BP-089R7

Parent delivery: **BP-085–BP-089R6**.

- Replaces per-frame reconstruction of `GameServer.edicts` with a stable,
  exact-length mirror that is resized only when the QuakeC high-water mark
  changes.
- Reuses every existing `QuakeEdict`, `EntityBaseline` and nested `Vec3`; raw
  QuakeC words are copied into those objects in place.
- Preserves `EdictRuntime.numEdicts` as the authoritative, non-shrinking
  WinQuake high-water mark.
- Uses the same explicit saved-count path for Quake-v5 load synchronization.
- Applies stable in-place vector synchronization to `PlayerState`.
- Adds backend-independent guards for `QuakeEdict` and `EntityBaseline`.
- Strengthens the existing diagnostics fixture to 227 Edicts, 80 mirror
  passes, forced GC, raw object-identity checks, changing QuakeC values and a
  freed-tail high-water regression.
- Updates inherited BP-012/BP-029/BP-087 source contracts to recognize the stable mirror while preserving their historical strict modes.
- Keeps native DLLs and all compatibility fingerprints unchanged.
