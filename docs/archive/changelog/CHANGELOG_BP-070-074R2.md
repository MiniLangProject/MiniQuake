# MiniQuake BP-070–BP-074R2

R2 repairs the first Windows compile gate of the core-assets/memory block.

- `tests/common_asset_parity_tests.ml` now calls the C-style endian entrypoints from `miniquake.common` instead of nonexistent uppercase members on `miniquake.byteio`.
- `common.LongNoSwap` now preserves the original signed 32-bit `int` call boundary.
- `common.FloatNoSwap` now preserves the original IEEE-754 Binary32 `float` call and return boundary.
- `tools/check_core_070.py` rejects the former member-resolution mistake before Windows code generation.
- The delivery revision, acceptance script, collector, manifests, ledgers and documentation were advanced to BP-070–BP-074R2.

The block scope, 116 runtime fixtures, retail evidence set and contract fingerprint remain unchanged:

```text
core_assets_memory_109_frozen_v1
fingerprint=0x6c8d974d
```

The native bridge and all non-Common engine subsystems are unchanged.
