# BP-044 audit – central world-render closure

## Original reference

`gl_rmain.c`, `gl_rsurf.c`, `gl_rlight.c`, `gl_warp.c` and `gl_refrag.c`.

## Bound contract

```text
status=world_render_109_frozen_v1
fingerprint=0x846a74de
near_clip=4
far_clip=4096
lightmap_atlas=128x128
max_lightmap_pages=64
max_visible_entities=256
backface_epsilon=0.01
```

The compatibility pass order is:

```text
world
entities
dynamic lights
particles
view model
deferred water
polyblend
```

The viewport calculation preserves GLQuake's full-screen and inset edge fudge,
and face culling uses the original front-face selection. `gl_cull` controls the
compatibility state without changing the default.

## Scope boundary

This contract closes the central world-render handoff and its deterministic
math/state rules. It does not yet claim complete visual acceptance of every map
or the future modern backend; screenshot/Golden-image and extended interactive
coverage remain later gates.

## Evidence

The closure C oracle, golden report and 24 MiniLang fixtures bind the contract
fingerprint, clip planes, stage order, viewport edge cases and culling toggle.
