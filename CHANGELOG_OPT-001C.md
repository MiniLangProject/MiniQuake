# MiniQuake OPT-001C

Parent: OPT-001B (Windows acceptance PASS, handle classification PLATEAU)

## Changes

- Removed per-call temporary trace arrays from the normal OpenGL wrapper fast path.
- Every `traceCommand(..., [...])` construction in `render/gl11.ml` is now short-circuited by `diagnosticTraceEnabled` before the argument array is evaluated.
- Direct renderer trace calls in `render/world.ml` are guarded by `gl.traceEnabled()` before arrays, lightmap hashes, or trace-only values are constructed.
- Added an allocation contract executable that proves the enabled trace format remains unchanged.
- Added a static source checker that rejects unguarded renderer trace arrays.
- Embedded the accepted OPT-001B performance baseline and added automatic median/P95/P99/throughput comparison.
- Preserved all OPT-001B correctness gates: e1m2 visible/headless soaks, deterministic traces, map transition and handle plateau analysis.

## Deliberately deferred

Persistent entity/viewmodel buffers, particle/audio scratch buffers, hot-Cvar caching, PVS/BSP restructuring, surface chains and QuakeC stack work remain scheduled for later OPT-001C/OPT-001D/OPT-001E revisions after this measurement.
