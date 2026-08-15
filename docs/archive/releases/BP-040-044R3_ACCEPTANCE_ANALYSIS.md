# BP-040–BP-044R3 Windows acceptance

The uploaded archive `MiniQuake_BP-040-044R3_RESULTS_20260727-181619.zip`
completed the complete world-render acceptance run successfully.

## Confirmed gates

- static verification and cumulative Windows build: PASS;
- all historical Protocol 15, QuakeC, world/physics, host lifecycle and
  client/render regressions: PASS;
- BP-040 world surfaces: 20/20;
- BP-041 lightmap atlas: 22/22;
- BP-042 dynamic lights: 20/20;
- BP-043 sky/water: 22/22;
- BP-044 world-render closure: 24/24;
- installed `id1/start` validation: PASS;
- 300 deterministic headless frames: PASS;
- two independent 128-frame traces: byte-identical;
- Winsock UDP loopback: PASS.

## Accepted deterministic reference

```text
trace sha256  = a3c1c0019267d0c6b651c931b1044642b9ef0199cdf64156cef9e8e409a6ecfa
rolling hash  = 0658dd48
results sha256= ddb2345e4730c50a7072cd217bce8095e2e09dc64e96dd63c9116bc2a9da4534
```

The candidate contract `world_render_109_frozen_v1` with fingerprint
`0x846a74de` is therefore accepted as the parent baseline for BP-045–BP-049.
