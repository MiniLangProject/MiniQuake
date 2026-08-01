# BP-030–BP-034R1 Windows acceptance analysis

The uploaded result archive `MiniQuake_BP-030-034R1_RESULTS_20260726-142334.zip`
confirms the complete host/lifecycle block.

## Accepted gates

- all independent compile and runtime groups: PASS
- installed `id1/start` validation: PASS
- headless runtime: 300 frames
- two independent compatibility traces: 128 frames each and byte-identical
- trace SHA-256: `31647a08ecb3204cd58b71b4fc6f441f5ed814d6c27aa6813ac3e566bf1c4769`
- rolling hash: `0658dd48`
- Winsock UDP loopback: PASS

The result collector initially contained a PowerShell trailing comma after
`patches\BP-034R1.diff`. The user repaired it locally. That parser error is
fixed in this source tree and guarded by the delivery checks for BP-035–039.

The following contracts are accepted Windows baselines:

```text
protocol15_frozen_v1
quakec_109_frozen_v1
world_physics_109_frozen_v1
host_lifecycle_109_frozen_v1
```
