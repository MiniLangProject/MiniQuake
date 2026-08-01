# MiniQuake BP-040–BP-044 – world-render closure block

This cumulative block builds on the accepted `BP-035-039R1` client/render
baseline and ports the next GLQuake 1.09 renderer layer.

| Step | Scope | Runtime fixtures |
|---|---|---:|
| BP-040 | world surface facing, texture chains and deferred water classification | 20 |
| BP-041 | lightmap formats, row strides and shared atlas ownership | 22 |
| BP-042 | dynamic-light frame ordering and movable brush marking | 20 |
| BP-043 | Binary32 sky/water and subdivision math | 22 |
| BP-044 | viewport, culling and central world-render pass contract | 24 |
| **Total** |  | **108** |

## Candidate contract

```text
world_render_109_frozen_v1
fingerprint=0x846a74de
```

The contract remains a candidate until the complete Windows acceptance script,
installed Quake-data gate, 300-frame headless run, two independent 128-frame
traces and UDP loopback all pass.

## Compatibility boundaries

The block changes the classic compatibility renderer. It does not alter the
already frozen Protocol 15, QuakeC, world/physics, host/lifecycle or
client/render contracts. Modern rendering backends can consume the same
higher-level state later, but `compat_109` remains the reference path.
