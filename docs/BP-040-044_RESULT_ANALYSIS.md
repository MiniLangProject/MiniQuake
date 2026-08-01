# BP-040–BP-044 Windows result analysis

## Result boundary

The first BP-040–BP-044 delivery passed all 38 static package and source-guided
checks. The cumulative Windows build then stopped while compiling the game
executable; no MiniLang runtime, installed-game, trace, screenshot or UDP gate
was reached.

```text
CompileError: Undefined global variable 'rCompatRenderer.lightmaps'
  at src/miniquake/render/world.ml:1918:3
    rCompatRenderer.lightmaps = []
    ^
```

Result archive:

```text
MiniQuake_BP-040-044_RESULTS_20260727-071848.zip
SHA-256 4c847c6249f51bf68b1763cf83b27e6316ebc5963e29b8a5f368bc49e5eb3d89
```

## Classification

This is a B0 compile blocker in the newly added BP-041 lightmap ownership path.
It is not evidence of a world-render runtime or semantic failure because the
compiler did not produce `MiniQuake.exe` for this delivery.

## Root cause

MiniLang accepts member writes on local object references, for example:

```ml
renderer.lightmaps = []
```

The failing assignment used a package-global root directly:

```ml
rCompatRenderer.lightmaps = []
```

At that assignment boundary the frontend resolved the dotted target as the
qualified global binding `rCompatRenderer.lightmaps`. Such a global does not
exist; `lightmaps` is a member of the `WorldRenderer` object stored in the
package global `rCompatRenderer`.

## R1 correction

`GL_BuildLightmaps` now takes a local reference to the existing renderer object
before changing its members:

```ml
renderer = rCompatRenderer
renderer.lightmaps = []
...
renderer.lightmaps = renderer.lightmaps + [textureId]
```

The object identity is unchanged. Only the MiniLang assignment target is made
unambiguous.

A complete source scan found the same latent form in the canonical
`render/original.ml` compatibility module. Its renderer/view member writes now
also use local references. This prevents the same compile class when that direct
GLQuake counterpart is pulled into a later import closure.

## Unchanged semantics

R1 does not change:

- lightmap allocation, page count or texture IDs,
- atlas uploads or pixel bytes,
- world-surface ordering,
- dynamic-light, sky or water math,
- the seven central render stages,
- any Protocol 15, QuakeC, world/physics, host/lifecycle or client/render rule,
- native bridge code or ABI,
- the 108 BP-040–BP-044 runtime fixtures,
- `world_render_109_frozen_v1` or fingerprint `0x846a74de`.

## Prevention

The R1 verifier rejects direct member assignments rooted at a package global in
the affected renderer compatibility modules and binds the required local-alias
markers in the BP-041 component checker.
