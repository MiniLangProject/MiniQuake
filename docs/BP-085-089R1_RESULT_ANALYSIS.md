# BP-085–BP-089 result analysis and R1 correction

The Windows result archive `MiniQuake_BP-085-089_RESULTS_20260731-133605.zip`
completed the build, every asset-free test through BP-089, `id1`, `rogue`,
`hipnotic`, normal runtime validation, retail core assets and retail audio.  The
first retail artifact evidence process then reported:

```text
save=version5 bytes=35113 crc=55983 exact=false semantic=false
NET_FreeQSocket: not active
```

All three retail demos (`demo1.dem`, `demo2.dem`, `demo3.dem`) parsed and
replayed successfully.  The failure was isolated to the Quake-v5 savegame
roundtrip and to the evidence process lifecycle.

## Problem 1: two complete Host sessions shared process-global NET state

The evidence retained `sessionA` while initializing `sessionB`.  WinQuake and
MiniQuake intentionally own process-global NET/QSocket state.  Initializing a
second complete Host replaces that global socket pool, so later shutdown of the
first Host can attempt to free a socket which is no longer in the active list.

R1 uses strictly sequential sessions: A is fully shut down before B is created,
and B is fully shut down before C is created.

## Problem 2: the saved edict high-water mark was trimmed after load

A Quake save contains one edict block for every index below `sv.num_edicts`,
including trailing free blocks.  `savegame.apply` restored that count, but the
subsequent generic `syncQuakeCEdicts` recomputed the highest currently non-free
edict and shortened both `runtime.numEdicts` and `server.numEdicts`.

That changed the serialized entity-block count and therefore made the A→B
savegame byte stream differ even when all live entities had been restored.

R1 introduces `miniquake.savegame_runtime.synchronizeLoadedServer`.  It:

1. remembers the saved high-water count;
2. rebuilds the derived MiniQuake edict view;
3. recreates any trailing free derived edicts;
4. restores both runtime and server high-water counts;
5. refreshes model indexes;
6. relinks every restored non-free edict without touching triggers.

The real `host.loadGame` path now uses the same helper, so this is an engine
compatibility correction rather than an evidence-only workaround.

## Problem 3: the old semantic check compared state not archived by Quake v5

The old evidence compared complete live QuakeC-global and derived server-edict
hashes.  Quake v5 archives only `DEF_SAVEGLOBAL` globals and serializable edict
fields.  Other VM values are transient by design and must not be treated as
save-format semantics.

R1 compares the parsed save-domain values: version, comment, 16 spawn
parameters, skill, map, time, 64 lightstyles, saved globals and every saved
edict pair.  Full live VM hashes remain in the log as diagnostics only.

## R1 acceptance model

1. Create source Host A, advance 64 deterministic frames, serialize and parse
   save A, then shut Host A down completely.
2. Create fresh Host B, apply parsed A through the production load
   synchronization, serialize and parse B, and require A/B byte and semantic
   identity.  Shut Host B down completely.
3. Create fresh Host C, apply parsed B, serialize C, and require B/C byte and
   semantic identity.  Shut Host C down completely.

On failure the evidence reports the first differing byte, lengths and first
semantic field without placing any savegame payload in the result archive.

Result archive SHA-256:

```text
cfaa061e9de12e13e9c38ba66f284eab8fb46986eebe5ddd27b2c3a0de777f87
```
