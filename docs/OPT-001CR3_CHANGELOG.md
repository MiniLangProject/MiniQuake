# MiniQuake OPT-001CR3 – Inline-/Array-Hotpath-Zwischenschritt

Parent: OPT-001CR2 (Windows PASS)

- Live build output remains attached to the current console.
- Ten small scalar helpers are selectively marked `function inline`.
- `array_util.makeFilledArray` now uses MiniLang's exact `array(count, fill)` builtin.
- Visible-entity and particle per-frame lists no longer grow via repeated `+ [item]`.
- Known-size arrays use exact allocation.
- Normal gameplay no longer accumulates `frameTrace`; explicit compatibility diagnostics are unchanged.
- Partial IPv4 assembly uses a fixed four-element array.
- Full OPT-001B/CR2 correctness, trace, e1m2, resource and performance gates remain active.
