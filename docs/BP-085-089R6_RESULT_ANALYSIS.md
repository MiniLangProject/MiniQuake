# BP-085–BP-089R5 Windows result analysis

Result archive:

```text
MiniQuake_BP-085-089R5_RESULTS_20260801-113442.zip
SHA-256: e869baa6928241d5fed8b145e3b2184cee844b5f94dfdfc6bc8ec523ba6f454e
```

## Confirmed successful areas

The complete Windows build and every MiniLang unit/regression program passed.
`id1`, `rogue`, `hipnotic`, the three retail demos, retail core assets, retail
audio, and both independent Quake-v5 savegame evidence processes passed.
The savegame evidence now reports:

```text
save_float_format=4097:4097.000000 negative:-4097.000000
save_float_parse=-0.000000:80000000
first_pass_exact=true
semantic=true
stable_exact=true
stable_semantic=true
result=PASS
```

R5 therefore fixed the signed-zero and exact roundtrip defects.

## Remaining failure

Compatibility trace A completed all 128 frames:

```text
frames=128/128
rolling-hash=d905b042
result=PASS
```

Trace B matched trace A through frame 80 and then failed while serializing
frame 81:

```text
frames=81/128
last-stage=trace_canonical
error=canonical frame: server edict 66 origin expected Vec3, got unknown
```

The host frame itself was complete. Player state, server time, random state,
QuakeC state, Protocol 15, and all prior canonical rows were valid and
byte-identical. The first difference is the explicit error row at frame 81.

## Root-cause assessment

The failure is strongly consistent with the remaining unrooted heap-value
handoff in the QuakeC mirror:

```ml
item.origin = qcVector(...)
result[index] = syncQuakeCEdict(...)
```

`Vec3` and `QuakeEdict` are heap-backed MiniLang structs. The native collector
roots named locals, but a returned heap value that exists only in a nested RHS
expression can be exposed if periodic GC runs between the return and the outer
field/array write. The earlier GC fix rooted nested constructor arguments but
left these return-to-field and return-to-array transfers direct.

This classification is supported by:

- one process completing 128 frames;
- the second process failing only after 81 otherwise identical frames;
- a valid `QuakeEdict` whose single nested `origin` field has type `unknown`;
- no preceding semantic divergence;
- the same class of failure previously observed at an earlier heap layout.

R6 removes every direct heap-return transfer in this mirror and adds a forced
GC regression that executes the actual `syncQuakeCEdicts` production path.
The Windows R6 run remains the final confirmation of this diagnosis.

## Inherited checker lineage

R6 changes `server.ml` in a cross-layer synchronization region while preserving
the frozen Protocol-15 baseline and world/physics semantics.  The inherited
BP-012 server-data checker now accepts either its historical direct baseline
copy or the complete R6 rooted copy sequence.  The BP-029 downstream checker
continues to bind the three frozen physics functions exactly and additionally
binds the five R6 synchronization functions by exact SHA-256 section hashes.
Its strict historical BP-029 mode remains unchanged.
