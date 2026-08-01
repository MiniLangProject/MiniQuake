# MiniQuake BP-040–BP-044R1

## Compile blocker fixed

The first BP-040–BP-044 Windows build stopped in
`render/world.ml:GL_BuildLightmaps` because a member assignment rooted directly
at the package global `rCompatRenderer` was interpreted as the nonexistent
qualified global `rCompatRenderer.lightmaps`.

R1 mutates the same `WorldRenderer` object through a local reference:

```ml
renderer = rCompatRenderer
renderer.lightmaps = []
```

The same compiler-sensitive assignment form was removed from the latent direct
GLQuake compatibility paths in `render/original.ml`.

## Verification

- added `bp040044r1_renderer_member_write_contract`,
- BP-041 checker now binds the local renderer alias and both lightmap writes,
- no direct package-global-root member assignment remains under `src/`,
- no native source or ABI change,
- runtime fixture counts stay unchanged,
- world-render fingerprint remains `0x846a74de`.

## Delivery

- new acceptance entry: `TEST_BP-040-044R1.ps1`,
- new collector revision: `BP-040-044R1`,
- new logical hotfix patch: `patches/BP-044R1.diff`,
- result analysis and R1 test instructions included.
