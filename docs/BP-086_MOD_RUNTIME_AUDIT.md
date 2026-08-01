# BP-086 mod/runtime audit

MiniQuake validates and runs a game profile through the same search-path
initialization used by the engine. The compatibility gate is format/ABI based:

- `progs.dat` version 6;
- BSP version 29;
- non-empty QuakeC functions and map faces;
- at least one external PAK entry available through the selected profile.

Stock `id1` is mandatory for the cumulative acceptance. `rogue` and `hipnotic`
are tested automatically when their PAKs are installed. Arbitrary `-game`
directories use the same inspector without requiring stock-id1 counts.

Contract: `mod_runtime_109_frozen_v1`, fingerprint `0x4649813d`.
