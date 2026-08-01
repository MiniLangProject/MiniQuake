# MiniQuake BP-030–BP-034R1

Parent delivery: `BP-030-034`  
Engine package: `BP-034`  
Delivery revision: `BP-030-034R1`

## Corrected

- Fixed the BP-030 accumulated `Host_FilterTime` runtime fixture.
- The fixture now mirrors the independent C oracle sequence `0.001 + 0.007 + 0.007`.
- Added explicit checks for two filtered calls, one accepted frame, accumulated realtime, old-realtime update and the `0.015` frame time.
- Strengthened `tools/check_host_timing.py` so the former `0.007 + 0.007` false expectation is rejected during preflight.
- Added R1-specific test, collection, ledger and result-analysis metadata.

## Unchanged

- No production source under `src/` changed.
- No native source or DLL changed.
- Protocol 15, QuakeC, world/physics and host/lifecycle fingerprints are unchanged.
- Fixture totals remain BP-030=18 and block total=106.
