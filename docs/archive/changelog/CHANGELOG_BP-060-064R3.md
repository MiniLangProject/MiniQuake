# MiniQuake BP-060–BP-064R3

Delivery parent: `BP-060-064R2`  
Engine package: `BP-064`

## Windows result boundary

R2 built all 65 targets and passed every unit/component group, installed Quake
data validation, 300 headless frames and retail-audio evidence. Trace A completed
128 frames. Trace B matched through frame 25 and failed at frame 26 in
`trace_canonical` with `Cannot access member 'x' on non-struct value`.

## Changes

- Root every heap-backed `QuakeEdict` constructor argument in a named local before
  allocating the outer struct.
- Apply the same constructor-root discipline to client and temporary render
  entities that carry several `Vec3` values.
- Add typed `Vec3` hashing/formatting helpers that report the exact subsystem,
  entity slot and field before any component access.
- Compute all canonical state digests before long string construction.
- Split snapshot serialization failures from snapshot file-write failures.
- Extend the existing ten-test diagnostics suite with forced-GC pressure over
  192 edicts while preserving the historical fixture count.
- Keep the R1/R2 live-output runner: compiler and runtime lines are streamed and
  flushed immediately.

## Compatibility status

No native ABI or frozen contract changes. The candidate remains:

```text
network_platform_109_frozen_v1
fingerprint=0xb3ec7589
```
