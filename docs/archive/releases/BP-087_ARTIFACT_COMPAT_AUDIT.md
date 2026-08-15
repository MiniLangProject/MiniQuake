# BP-087 demo/save artifact audit

The asset-free fixture suite binds Protocol-15 demo framing and Quake savegame
version 5. The Windows retail evidence performs two independent evidence runs.
Each run:

1. loads `demo1.dem`, `demo2.dem` and `demo3.dem` through the Quake filesystem;
2. parses every frame and verifies the resulting client protocol stream;
3. initializes a live map, advances 64 deterministic frames and serializes a
   version-5 savegame A;
4. shuts Host A down completely before creating another Host session;
5. initializes Host B, applies parsed A through the production load path,
   preserves the saved `sv.num_edicts` high-water mark, relinks all restored
   non-free edicts, and serializes savegame B;
6. requires A and B to be byte-identical and semantically identical in the
   parsed save domain;
7. shuts Host B down, initializes Host C, applies parsed B and requires B and C
   to be byte-identical and semantically identical.

The semantic save domain consists of version, comment, sixteen spawn
parameters, skill, map, time, sixty-four lightstyles, `DEF_SAVEGLOBAL` values
and all serialized edict pairs. Complete live VM hashes include transient state
which Quake v5 does not archive; they are logged as diagnostics only.

The sequential sessions are required because WinQuake's NET/QSocket state is
process-global. The high-water preservation mirrors `Host_Loadgame_f`, which
sets `sv.num_edicts` to the number of parsed edict blocks, including trailing
free blocks.

No demo, save, PAK or other game-data payload is copied into the result archive.

Contract: `artifact_compat_109_frozen_v1`, fingerprint `0x59531091`.
Evidence revision: `sequential_exact_v1`.
