# MiniQuake BP-020–BP-024R3

Parent delivery: BP-020–BP-024R2  
Engine package: BP-024R3  
Logical block: BP-020–BP-024  
Protocol status: `protocol15_frozen_v1`  
QuakeC status: `quakec_109_frozen_v1`

## Fixed

- Replaced the progressively concatenated `ED_Write`/`ED_WriteGlobals` output
  with an exact-size two-pass Quake-byte serializer.
- Unified direct QuakeC and savegame definition serialization.
- Preserved extended Quake one-byte text through
  `quake_latin1_cstring_v1` during ED_* document construction.
- Added explicit output-size, output-type and byte-buffer checks.
- Made the BP-022 runtime fixture report a non-string return directly instead
  of failing while stringifying it in the assertion helper.
- Added exact byte comparison with an extended `0xe9` Quake character.
- Preserved the original `ED_WriteGlobals` behavior for zero-valued and empty `DEF_SAVEGLOBAL` entries.

## Unchanged

- Protocol-15 contract and fingerprint;
- QuakeC 1.09 logical contract and fingerprint `0xbc89cbf1`;
- progs.dat parsing, VM execution, builtins, physics and renderer behavior;
- native bridge binaries and ABI.
