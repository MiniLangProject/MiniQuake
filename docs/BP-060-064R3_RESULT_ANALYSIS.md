# BP-060–BP-064R2 Windows result analysis

## Result boundary

The R2 result archive is:

```text
MiniQuake_BP-060-064R2_RESULTS_20260728-215240.zip
SHA-256: 4c784f8afbd02624552c18339a1f8ab48c052c38dced9057ca044a12c8be4fef
```

The build and all inherited/new runtime test groups passed. Installed Quake data
validation, 300 headless frames and two retail-audio evidence runs also passed.

Trace A completed 128/128 frames:

```text
trace SHA-256: 03656a0e9f3b13d4430014de3787053c204acdd1e7f2e33c292ee8ee2b47c8cc
rolling hash: d905b042
```

Trace B was byte-identical through frame 25, then failed at frame 26:

```text
frames: 26/128
last stage: trace_canonical
trace SHA-256: a09230346fe487f787533300ade45ecc731680a60cccffd8cefcd582f9a1f3d5
rolling hash: 69e05234
error: canonical frame: Cannot access member 'x' on non-struct value
follow-up: snapshot: writeAllText: invalid args
```

The persisted context proves that the host frame itself completed and that the
player origin, velocity and angles were valid `Vec3` values. The failure therefore
occurred while canonical diagnostics traversed a nested vector in the rebuilt
server-edict or client-entity tables.

## Root-cause assessment

The exact offending entity and field were not captured by the R2 formatter, so
this classification is deliberately stated as **strongly supported**, not as a
mathematically proven single instruction. The evidence points to the native
MiniLang GC-rooting edge already seen elsewhere in this codebase:

- `syncQuakeCEdicts` rebuilds approximately 85 heap-backed `QuakeEdict` structs
  every accepted frame.
- `edict.create` previously nested arrays, seven `Vec3` structs and an
  `EntityBaseline` directly inside the outer `QuakeEdict(...)` call.
- A GC triggered between constructor arguments could leave an earlier heap value
  reachable only through a transient expression slot.
- The failure was process/heap-layout dependent: run A completed, run B failed
  after 26 otherwise identical frames.
- The error was a structurally invalid nested vector rather than a gameplay-state
  divergence.

## R3 correction

R3 roots every heap-backed constructor argument in named locals before allocating
the outer edict/client entity. Canonical diagnostics now validate every `Vec3`
before reading `.x`, `.y` or `.z`, and identify the exact entity slot/field if a
future malformed value is encountered. All digests are calculated before long
trace-string allocations. Snapshot serialization and snapshot writing are also
separated, so a serializer error can no longer be mislabeled as `writeAllText`
invalid arguments.

The diagnostics fixture intentionally creates 192 edicts, creates 2048 additional
vectors, forces GC, verifies all nested vector types, checks canonical stability,
and validates precise malformed-vector classification. The public diagnostics
test count remains 10 to preserve every inherited acceptance marker.

No native bridge, network/platform contract or fingerprint changed.
