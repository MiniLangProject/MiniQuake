# BP-053 deterministic render-evidence corpus

The corpus extends the single-frame BP-048 proof to three fixed scenarios:

| Name | Map | Frame |
|---|---|---:|
| start-064 | start | 64 |
| start-128 | start | 128 |
| e1m1-128 | e1m1 | 128 |

Every MiniQuake scenario is captured in two independent processes and must be byte-identical. An optional external Original GLQuake reference directory can provide `<scenario>.tga` files; each comparison must reach SSIM >= 0.95. Original game/reference images are never bundled.

Asset-free fixtures: 18.
