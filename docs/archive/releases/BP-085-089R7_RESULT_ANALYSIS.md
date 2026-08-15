# BP-085–BP-089R6 result analysis

## Result boundary

The Windows build, all unit/regression suites, `id1`, `rogue`, `hipnotic`,
retail core/audio/demo/save evidence, the primary 128-frame trace pair and the
`start` and `e1m1` black-port corpus pairs all passed.

The first failure was the second `e1m2` corpus process:

```text
frames=56/64
last-stage=trace_canonical
error=server edict 77 origin expected Vec3, got unknown
```

Trace A completed 64/64 frames. Both traces were byte-identical through frame
55. In trace B, Host frame 56 itself completed; the failure appeared only when
the diagnostic layer read the derived server-edict mirror.

## Classification

R6 still allocated a new exact-size array, a new `QuakeEdict` and six or more
new nested vectors for every active Edict on every frame. Named return-value
locals reduced the risk but did not remove the allocation/lifetime dependency.
The observed outer Edict remained present while only `origin` no longer had a
valid concrete struct type. That strongly supports an allocation/GC-timing
problem in the derived mirror rather than a gameplay, QuakeC, physics or
Protocol-15 divergence.

## R7 correction

R7 follows the original engine's persistent Edict storage model:

1. `EdictRuntime.numEdicts` remains the authoritative high-water mark.
2. `GameServer.edicts` is resized only when that count changes.
3. Existing `QuakeEdict` records are mutated in place.
4. Existing Origin/Angle/Velocity/Bounds/ViewOffset vectors are mutated in
   place from raw VM words.
5. Baselines keep stable identity and are not rebuilt every frame.
6. Quake-v5 loads use the explicitly saved high-water count.
7. The player mirror uses the same in-place vector path.

The public diagnostics count remains ten, but its production-path stress now
uses 227 Edicts for 80 passes with forced collections and raw identity checks.
