# BP-025–BP-029R3 – Windows acceptance analysis

The uploaded result archive `MiniQuake_BP-025-029R3_RESULTS_20260726-115205.zip`
completed successfully.

- result archive SHA-256: `518b080fe6dbb69d10c5395a7d96ad0c9cbab585b0054a6e810ca762da88c556`
- status: `PASS`
- all independent test groups: `PASS`
- installed `id1/start` validation: `PASS`
- headless runtime: 300 frames
- two deterministic traces: 128 frames each and byte-identical
- trace SHA-256: `24830a3e183784de44a9c7261a42cc8e5aebf8fd1c8fdbafc32ea447ee0eba9f`
- rolling hash: `4d8fc98d`
- UDP loopback: `PASS`

This accepts the candidate contract as the current Windows baseline:

```text
world_physics_109_frozen_v1
fingerprint=0x2235d77c
```

The accepted result is the parent baseline of BP-030–BP-034.
