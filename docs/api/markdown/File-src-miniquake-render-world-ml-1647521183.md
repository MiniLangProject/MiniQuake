# `src/miniquake/render/world.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.world`](Package-miniquake-render-world-70727533.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `byteio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/optimization_baseline.ml` as `optBaseline` → [src/miniquake/optimization_baseline.ml](File-src-miniquake-optimization-baseline-ml-636998107.md)
- `miniquake/render/colored_lightmaps.ml` as `coloredLightmaps` → [src/miniquake/render/colored_lightmaps.ml](File-src-miniquake-render-colored-lightmaps-ml-2051146857.md)
- `miniquake/render/draw2d.ml` as `draw2d` → [src/miniquake/render/draw2d.ml](File-src-miniquake-render-draw2d-ml-1547120567.md)
- `miniquake/render/enhanced.ml` as `enhanced` → [src/miniquake/render/enhanced.ml](File-src-miniquake-render-enhanced-ml-802793533.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/gl_rlight.ml` as `glRlight` → [src/miniquake/render/gl_rlight.ml](File-src-miniquake-render-gl-rlight-ml-1917075617.md)
- `miniquake/render/gl_warp.ml` as `glWarp` → [src/miniquake/render/gl_warp.ml](File-src-miniquake-render-gl-warp-ml-268398757.md)
- `miniquake/render/ray_shadow.ml` as `rayShadow` → [src/miniquake/render/ray_shadow.ml](File-src-miniquake-render-ray-shadow-ml-233970536.md)
- `miniquake/render/special_paths.ml` as `specialPaths` → [src/miniquake/render/special_paths.ml](File-src-miniquake-render-special-paths-ml-2012876531.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="global-global-miniquake-render-world-active-lightmaps-active-lightmaps-src-miniquake-render-world-ml-1351656994"></a>
### active_lightmaps

```ml
active_lightmaps
```

Tracks the module-level active lightmaps state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1586)

<a id="function-function-miniquake-render-world-addlightblend-function-addlightblend-red-green-blue-alpha2-src-miniquake-render-world-ml-1296706838"></a>
### AddLightBlend

```ml
function AddLightBlend(red, green, blue, alpha2)
```

Add state for add light blend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `red` | `dynamic` | — | The red input consumed by `AddLightBlend`. |
| `green` | `dynamic` | — | The green input consumed by `AddLightBlend`. |
| `blue` | `dynamic` | — | The blue input consumed by `AddLightBlend`. |
| `alpha2` | `dynamic` | — | The alpha2 input consumed by `AddLightBlend`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2600)

<a id="global-global-miniquake-render-world-allocated-allocated-src-miniquake-render-world-ml-837181878"></a>
### allocated

```ml
allocated
```

Tracks the module-level allocated state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1596)

<a id="function-function-miniquake-render-world-allocblock-function-allocblock-width-height-xout-yout-src-miniquake-render-world-ml-1377157658"></a>
### AllocBlock

```ml
function AllocBlock(width, height, xOut, yOut)
```

Create and initialize block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `xOut` | `dynamic` | — | The x out input consumed by `AllocBlock`. |
| `yOut` | `dynamic` | — | The y out input consumed by `AllocBlock`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3990)

<a id="global-global-miniquake-render-world-alphaskytexture-alphaskytexture-src-miniquake-render-world-ml-1455194478"></a>
### alphaskytexture

```ml
alphaskytexture
```

Tracks the module-level alphaskytexture state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1646)

<a id="global-global-miniquake-render-world-blocklights-blocklights-src-miniquake-render-world-ml-1212511202"></a>
### blocklights

```ml
blocklights
```

Tracks the module-level blocklights state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1588)

<a id="function-function-miniquake-render-world-boundpoly-function-boundpoly-numverts-vertices-minimums-maximums-src-miniquake-render-world-ml-1131054757"></a>
### BoundPoly

```ml
function BoundPoly(numverts, vertices, minimums, maximums)
```

----------------------------------------------------------------------------- gl_warp.c -----------------------------------------------------------------------------

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numverts` | `dynamic` | — | The numverts input consumed by `BoundPoly`. |
| `vertices` | `dynamic` | — | The vertices input consumed by `BoundPoly`. |
| `minimums` | `dynamic` | — | The minimums input consumed by `BoundPoly`. |
| `maximums` | `dynamic` | — | The maximums input consumed by `BoundPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4214)

<a id="function-function-miniquake-render-world-buildlightmap-function-buildlightmap-renderer-surface-src-miniquake-render-world-ml-1639418574"></a>
### buildLightmap

```ml
function buildLightmap(renderer, surface)
```

Create and initialize lightmap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `surface` | `dynamic` | — | The surface input consumed by `buildLightmap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L299)

<a id="function-function-miniquake-render-world-buildstandalonelightmap-function-buildstandalonelightmap-renderer-surface-src-miniquake-render-world-ml-63975284"></a>
### buildStandaloneLightmap

```ml
function buildStandaloneLightmap(renderer, surface)
```

External BSP models such as maps/b_bh25.bsp are independent brush models, not *n submodels of the active world. GLQuake includes all of them in GL_BuildLightmaps. Keep their uploads independent from the world's shared atlas so loading one cannot replace the active world's compatibility state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `surface` | `dynamic` | — | The surface input consumed by `buildStandaloneLightmap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L456)

<a id="function-function-miniquake-render-world-buildsurface-function-buildsurface-map-faceindex-underwaterflags-src-miniquake-render-world-ml-2105487945"></a>
### buildSurface

```ml
function buildSurface(map, faceIndex, underwaterFlags)
```

Create and initialize surface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `buildSurface`. |
| `faceIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `underwaterFlags` | `dynamic` | — | The underwater flags input consumed by `buildSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L201)

<a id="function-function-miniquake-render-world-buildsurfacedisplaylist-function-buildsurfacedisplaylist-surface-src-miniquake-render-world-ml-686707451"></a>
### BuildSurfaceDisplayList

```ml
function BuildSurfaceDisplayList(surface)
```

Create and initialize surface display list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `BuildSurfaceDisplayList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4031)

<a id="function-function-miniquake-render-world-buildunderwaterflags-function-buildunderwaterflags-map-src-miniquake-render-world-ml-440529954"></a>
### buildUnderwaterFlags

```ml
function buildUnderwaterFlags(map)
```

Create and initialize underwater flags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `buildUnderwaterFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L176)

<a id="global-global-miniquake-render-world-c-brush-polys-c-brush-polys-src-miniquake-render-world-ml-2115140626"></a>
### c_brush_polys

```ml
c_brush_polys
```

Tracks the module-level c brush polys state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1652)

<a id="function-function-miniquake-render-world-ceilvalue-function-ceilvalue-value-src-miniquake-render-world-ml-534346739"></a>
### ceilValue

```ml
function ceilValue(value)
```

Return ceil value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ceilValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L74)

<a id="global-global-miniquake-render-world-clearstaticcacheoncreate-clearstaticcacheoncreate-src-miniquake-render-world-ml-1297929922"></a>
### clearStaticCacheOnCreate

```ml
clearStaticCacheOnCreate
```

Tracks the module-level clear static cache on create state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L34)

<a id="global-global-miniquake-render-world-coloredlightmapsrequested-coloredlightmapsrequested-src-miniquake-render-world-ml-286719514"></a>
### coloredLightmapsRequested

```ml
coloredLightmapsRequested
```

Tracks the module-level colored lightmaps requested state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1604)

<a id="function-function-miniquake-render-world-compatabs-inline-function-compatabs-value-src-miniquake-render-world-ml-1649049572"></a>
### compatAbs

```ml
inline function compatAbs(value)
```

Implements the `compatAbs` operation for `miniquake.render.world` (compat abs).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `compatAbs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1776)

<a id="function-function-miniquake-render-world-compataddlightmappoly-function-compataddlightmappoly-page-value-src-miniquake-render-world-ml-2011097822"></a>
### compatAddLightmapPoly

```ml
function compatAddLightmapPoly(page, value)
```

Implements the `compatAddLightmapPoly` operation for `miniquake.render.world` (compat add lightmap poly).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `compatAddLightmapPoly`. |
| `value` | `dynamic` | — | Value consumed by `compatAddLightmapPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1968)

<a id="function-function-miniquake-render-world-compatassignlightblend-function-compatassignlightblend-updated-src-miniquake-render-world-ml-1345759933"></a>
### compatAssignLightBlend

```ml
function compatAssignLightBlend(updated)
```

Implements the `compatAssignLightBlend` operation for `miniquake.render.world` (compat assign light blend).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `updated` | `dynamic` | — | The updated input consumed by `compatAssignLightBlend`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2584)

<a id="function-function-miniquake-render-world-compatbrushmodelorigin-function-compatbrushmodelorigin-entity-src-miniquake-render-world-ml-824668535"></a>
### compatBrushModelOrigin

```ml
function compatBrushModelOrigin(entity)
```

Return compat brush model origin derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3681)

<a id="function-function-miniquake-render-world-compatcleartexturechain-function-compatcleartexturechain-index-src-miniquake-render-world-ml-872268930"></a>
### compatClearTextureChain

```ml
function compatClearTextureChain(index)
```

Clear one consumed texture chain without discarding its reusable capacity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2109)

<a id="function-function-miniquake-render-world-compatcontainsinteger-function-compatcontainsinteger-values-wanted-src-miniquake-render-world-ml-1839159807"></a>
### compatContainsInteger

```ml
function compatContainsInteger(values, wanted)
```

Implements the `compatContainsInteger` operation for `miniquake.render.world` (compat contains integer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `compatContainsInteger`. |
| `wanted` | `dynamic` | — | The wanted input consumed by `compatContainsInteger`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L829)

<a id="function-function-miniquake-render-world-compatcopysurfacelightmaptoatlas-function-compatcopysurfacelightmaptoatlas-surface-pixels-src-miniquake-render-world-ml-1295449862"></a>
### compatCopySurfaceLightmapToAtlas

```ml
function compatCopySurfaceLightmapToAtlas(surface, pixels)
```

Implements the `compatCopySurfaceLightmapToAtlas` operation for `miniquake.render.world` (compat copy surface lightmap to atlas).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatCopySurfaceLightmapToAtlas`. |
| `pixels` | `dynamic` | — | The pixels input consumed by `compatCopySurfaceLightmapToAtlas`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2288)

<a id="function-function-miniquake-render-world-compatemptyplane-function-compatemptyplane-src-miniquake-render-world-ml-1094354278"></a>
### compatEmptyPlane

```ml
function compatEmptyPlane()
```

Implements the `compatEmptyPlane` operation for `miniquake.render.world` (compat empty plane).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1770)

<a id="function-function-miniquake-render-world-compatenhancedbatchkeys-function-compatenhancedbatchkeys-values-count-src-miniquake-render-world-ml-1969823055"></a>
### compatEnhancedBatchKeys

```ml
function compatEnhancedBatchKeys(values, count)
```

Pack the populated prefix of a surface builder into the reusable native-key buffer used by the static geometry batch bridge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `compatEnhancedBatchKeys`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2417)

<a id="function-function-miniquake-render-world-compatensurearraysize-function-compatensurearraysize-values-count-fillvalue-src-miniquake-render-world-ml-1430266385"></a>
### compatEnsureArraySize

```ml
function compatEnsureArraySize(values, count, fillValue)
```

Return compat ensure array size derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `compatEnsureArraySize`. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `fillValue` | `dynamic` | — | The fill value input consumed by `compatEnsureArraySize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1785)

<a id="function-function-miniquake-render-world-compatensureenhancedbuilders-function-compatensureenhancedbuilders-src-miniquake-render-world-ml-1975332426"></a>
### compatEnsureEnhancedBuilders

```ml
function compatEnsureEnhancedBuilders()
```

Ensure one persistent surface builder per BSP texture for the enhanced additive pass.  Reusing these builders avoids per-frame chain allocations.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2395)

<a id="function-function-miniquake-render-world-compatensureworldstate-function-compatensureworldstate-src-miniquake-render-world-ml-1884507198"></a>
### compatEnsureWorldState

```ml
function compatEnsureWorldState()
```

Return compat ensure world state derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1802)

<a id="function-function-miniquake-render-world-compatface-function-compatface-surface-src-miniquake-render-world-ml-165389937"></a>
### compatFace

```ml
function compatFace(surface)
```

Implements the `compatFace` operation for `miniquake.render.world` (compat face).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatFace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2531)

<a id="function-function-miniquake-render-world-compatfinishlightmapchain-function-compatfinishlightmapchain-page-src-miniquake-render-world-ml-969095839"></a>
### compatFinishLightmapChain

```ml
function compatFinishLightmapChain(page)
```

Implements the `compatFinishLightmapChain` operation for `miniquake.render.world` (compat finish lightmap chain).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `compatFinishLightmapChain`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1989)

<a id="function-function-miniquake-render-world-compatfinishtexturechain-function-compatfinishtexturechain-index-src-miniquake-render-world-ml-1821093520"></a>
### compatFinishTextureChain

```ml
function compatFinishTextureChain(index)
```

Resolve one texture chain in GLQuake head-insertion order. Production keeps a reusable tail-appending builder to avoid allocating/copying an array for every visible world polygon; only the consumed chain is materialized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2089)

<a id="function-function-miniquake-render-world-compatfnv1a-function-compatfnv1a-data-offset-count-src-miniquake-render-world-ml-1499428322"></a>
### compatFnv1a

```ml
function compatFnv1a(data, offset, count)
```

Implements the `compatFnv1a` operation for `miniquake.render.world` (compat fnv1a).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2243)

<a id="function-function-miniquake-render-world-compatfreshlightmapallocation-function-compatfreshlightmapallocation-src-miniquake-render-world-ml-1436870970"></a>
### compatFreshLightmapAllocation

```ml
function compatFreshLightmapAllocation()
```

Implements the `compatFreshLightmapAllocation` operation for `miniquake.render.world` (compat fresh lightmap allocation).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1791)

<a id="function-function-miniquake-render-world-compathashlightmaprows-function-compathashlightmaprows-page-firstrow-rowcount-src-miniquake-render-world-ml-1550871324"></a>
### compatHashLightmapRows

```ml
function compatHashLightmapRows(page, firstRow, rowCount)
```

Implements the `compatHashLightmapRows` operation for `miniquake.render.world` (compat hash lightmap rows).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `compatHashLightmapRows`. |
| `firstRow` | `dynamic` | — | The first row input consumed by `compatHashLightmapRows`. |
| `rowCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2257)

<a id="function-function-miniquake-render-world-compatlightmapformat-function-compatlightmapformat-src-miniquake-render-world-ml-1824590662"></a>
### compatLightmapFormat

```ml
function compatLightmapFormat()
```

Return the active atlas transfer format without changing compatibility traces for ordinary grayscale BSP light data.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2264)

<a id="function-function-miniquake-render-world-compatmultitexturerecords-function-compatmultitexturerecords-surfaces-surfacecount-src-miniquake-render-world-ml-1153900256"></a>
### compatMultitextureRecords

```ml
function compatMultitextureRecords(surfaces, surfaceCount)
```

Implements the `compatMultitextureRecords` operation for `miniquake.render.world` (compat multitexture records).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `compatMultitextureRecords`. |
| `surfaceCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3259)

<a id="function-function-miniquake-render-world-compatplane-function-compatplane-surface-src-miniquake-render-world-ml-799662977"></a>
### compatPlane

```ml
function compatPlane(surface)
```

Implements the `compatPlane` operation for `miniquake.render.world` (compat plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatPlane`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2540)

<a id="function-function-miniquake-render-world-compatplanedistance-function-compatplanedistance-plane-point-src-miniquake-render-world-ml-331085584"></a>
### compatPlaneDistance

```ml
function compatPlaneDistance(plane, point)
```

Implements the `compatPlaneDistance` operation for `miniquake.render.world` (compat plane distance).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `compatPlaneDistance`. |
| `point` | `dynamic` | — | The point input consumed by `compatPlaneDistance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2559)

<a id="function-function-miniquake-render-world-compatpreparebatchedbrushpoly-function-compatpreparebatchedbrushpoly-surface-src-miniquake-render-world-ml-850193505"></a>
### compatPrepareBatchedBrushPoly

```ml
function compatPrepareBatchedBrushPoly(surface)
```

Implements the `compatPrepareBatchedBrushPoly` operation for `miniquake.render.world` (compat prepare batched brush poly).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatPrepareBatchedBrushPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3540)

<a id="function-function-miniquake-render-world-compatrecursiveworldnode-function-compatrecursiveworldnode-nodenumber-nodecount-surfacecount-visiblefacecount-usevisiblemask-src-miniquake-render-world-ml-486312141"></a>
### compatRecursiveWorldNode

```ml
function compatRecursiveWorldNode(nodeNumber, nodeCount, surfaceCount, visibleFaceCount, useVisibleMask)
```

Traverse one visible BSP subtree with frame-stable collection sizes.  The public wrapper computes these values once; recursive calls no longer repeat array-length and visible-mask identity checks at every node and surface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `compatRecursiveWorldNode`. |
| `nodeCount` | `dynamic` | — | Number of entries or units to process. |
| `surfaceCount` | `dynamic` | — | Number of entries or units to process. |
| `visibleFaceCount` | `dynamic` | — | Number of entries or units to process. |
| `useVisibleMask` | `dynamic` | — | The use visible mask input consumed by `compatRecursiveWorldNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3870)

<a id="function-function-miniquake-render-world-compatrenderdynamiclightmaps-function-compatrenderdynamiclightmaps-surface-addtochain-src-miniquake-render-world-ml-377636164"></a>
### compatRenderDynamicLightmaps

```ml
function compatRenderDynamicLightmaps(surface, addToChain)
```

Implements the `compatRenderDynamicLightmaps` operation for `miniquake.render.world` (compat render dynamic lightmaps).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatRenderDynamicLightmaps`. |
| `addToChain` | `dynamic` | — | The add to chain input consumed by `compatRenderDynamicLightmaps`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3469)

<a id="function-function-miniquake-render-world-compatresetlightmaprectangle-function-compatresetlightmaprectangle-page-src-miniquake-render-world-ml-23951799"></a>
### compatResetLightmapRectangle

```ml
function compatResetLightmapRectangle(page)
```

Reset a dirty rectangle in place. Animated lightstyles hit this path often, so retaining the four-slot record avoids one heap object per atlas upload.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `compatResetLightmapRectangle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1947)

<a id="function-function-miniquake-render-world-compatsurface-function-compatsurface-surface-src-miniquake-render-world-ml-1423958799"></a>
### compatSurface

```ml
function compatSurface(surface)
```

Implements the `compatSurface` operation for `miniquake.render.world` (compat surface).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2520)

<a id="function-function-miniquake-render-world-compatsurfacebatchkeys-function-compatsurfacebatchkeys-surfaces-src-miniquake-render-world-ml-1699539674"></a>
### compatSurfaceBatchKeys

```ml
function compatSurfaceBatchKeys(surfaces)
```

Implements the `compatSurfaceBatchKeys` operation for `miniquake.render.world` (compat surface batch keys).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `compatSurfaceBatchKeys`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3241)

<a id="function-function-miniquake-render-world-compatsurfaceindex-function-compatsurfaceindex-surface-src-miniquake-render-world-ml-587633685"></a>
### compatSurfaceIndex

```ml
function compatSurfaceIndex(surface)
```

Return compat surface index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatSurfaceIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2505)

<a id="function-function-miniquake-render-world-compattexinfo-function-compattexinfo-surface-src-miniquake-render-world-ml-1297994031"></a>
### compatTexInfo

```ml
function compatTexInfo(surface)
```

Implements the `compatTexInfo` operation for `miniquake.render.world` (compat tex info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `compatTexInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2549)

<a id="function-function-miniquake-render-world-compatuploadlightmapsubimage-function-compatuploadlightmapsubimage-page-rectangle-src-miniquake-render-world-ml-1704776428"></a>
### compatUploadLightmapSubImage

```ml
function compatUploadLightmapSubImage(page, rectangle)
```

Transfer one dirty atlas rectangle using the format selected at map load.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `compatUploadLightmapSubImage`. |
| `rectangle` | `dynamic` | — | The rectangle input consumed by `compatUploadLightmapSubImage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2272)

<a id="function-function-miniquake-render-world-compatzerovector-function-compatzerovector-src-miniquake-render-world-ml-158276310"></a>
### compatZeroVector

```ml
function compatZeroVector()
```

Return compat zero vector derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1765)

<a id="function-function-miniquake-render-world-countvisiblefaces-function-countvisiblefaces-visiblefaces-src-miniquake-render-world-ml-1837404076"></a>
### countVisibleFaces

```ml
function countVisibleFaces(visibleFaces)
```

Report whether count visible faces holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visibleFaces` | `dynamic` | — | The visible faces input consumed by `countVisibleFaces`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L933)

<a id="function-function-miniquake-render-world-create-function-create-map-palette-src-miniquake-render-world-ml-2066706889"></a>
### create

```ml
function create(map, palette)
```

Implements the `create` operation for `miniquake.render.world` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `create`. |
| `palette` | `dynamic` | — | The palette input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L329)

<a id="function-function-miniquake-render-world-createexternal-function-createexternal-map-palette-src-miniquake-render-world-ml-913205329"></a>
### createExternal

```ml
function createExternal(map, palette)
```

Create and initialize external.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `createExternal`. |
| `palette` | `dynamic` | — | The palette input consumed by `createExternal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L384)

<a id="global-global-miniquake-render-world-currenttextureframe-currenttextureframe-src-miniquake-render-world-ml-727377210"></a>
### currentTextureFrame

```ml
currentTextureFrame
```

Tracks the module-level current texture frame state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3040)

<a id="global-global-miniquake-render-world-d-lightstylevalue-d-lightstylevalue-src-miniquake-render-world-ml-619051586"></a>
### d_lightstylevalue

```ml
d_lightstylevalue
```

Tracks the module-level d lightstylevalue state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1636)

<a id="function-function-miniquake-render-world-destroy-function-destroy-renderer-src-miniquake-render-world-ml-1033884499"></a>
### destroy

```ml
function destroy(renderer)
```

Implements the `destroy` operation for `miniquake.render.world` (destroy).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L798)

<a id="function-function-miniquake-render-world-destroystandalonebrush-function-destroystandalonebrush-renderer-src-miniquake-render-world-ml-159015163"></a>
### destroyStandaloneBrush

```ml
function destroyStandaloneBrush(renderer)
```

Release resources owned by standalone brush.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L779)

<a id="function-function-miniquake-render-world-drawbasesurface-function-drawbasesurface-renderer-surface-src-miniquake-render-world-ml-76057062"></a>
### drawBaseSurface

```ml
function drawBaseSurface(renderer, surface)
```

Render base surface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `surface` | `dynamic` | — | The surface input consumed by `drawBaseSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1052)

<a id="function-function-miniquake-render-world-drawglpoly-function-drawglpoly-poly-src-miniquake-render-world-ml-1206937808"></a>
### DrawGLPoly

```ml
function DrawGLPoly(poly)
```

Render glpoly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `poly` | `dynamic` | — | The poly input consumed by `DrawGLPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3172)

<a id="function-function-miniquake-render-world-drawglwaterpoly-function-drawglwaterpoly-poly-src-miniquake-render-world-ml-59903872"></a>
### DrawGLWaterPoly

```ml
function DrawGLWaterPoly(poly)
```

Render glwater poly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `poly` | `dynamic` | — | The poly input consumed by `DrawGLWaterPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3138)

<a id="function-function-miniquake-render-world-drawglwaterpolylightmap-function-drawglwaterpolylightmap-poly-src-miniquake-render-world-ml-539344672"></a>
### DrawGLWaterPolyLightmap

```ml
function DrawGLWaterPolyLightmap(poly)
```

Render glwater poly lightmap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `poly` | `dynamic` | — | The poly input consumed by `DrawGLWaterPolyLightmap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3155)

<a id="function-function-miniquake-render-world-drawlightsurface-function-drawlightsurface-surface-src-miniquake-render-world-ml-1529683693"></a>
### drawLightSurface

```ml
function drawLightSurface(surface)
```

Render light surface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `drawLightSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1070)

<a id="function-function-miniquake-render-world-drawstandalonebase-function-drawstandalonebase-renderer-surface-currenttime-alternate-src-miniquake-render-world-ml-506466456"></a>
### drawStandaloneBase

```ml
function drawStandaloneBase(renderer, surface, currentTime, alternate)
```

Render standalone base.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `surface` | `dynamic` | — | The surface input consumed by `drawStandaloneBase`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `alternate` | `dynamic` | — | The alternate input consumed by `drawStandaloneBase`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L583)

<a id="function-function-miniquake-render-world-drawstandalonebrush-function-drawstandalonebrush-renderer-entity-vieworigin-currenttime-src-miniquake-render-world-ml-1776642017"></a>
### drawStandaloneBrush

```ml
function drawStandaloneBrush(renderer, entity, viewOrigin, currentTime)
```

Render standalone brush.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `drawStandaloneBrush`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L621)

<a id="function-function-miniquake-render-world-drawstandalonebrushenhanced-function-drawstandalonebrushenhanced-renderer-entity-vieworigin-currenttime-src-miniquake-render-world-ml-1205377457"></a>
### drawStandaloneBrushEnhanced

```ml
function drawStandaloneBrushEnhanced(renderer, entity, viewOrigin, currentTime)
```

Draw only the base polygons of an external BSP entity for the additive per-pixel light pass.  The caller owns blend/depth/shader state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `drawStandaloneBrushEnhanced`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L689)

<a id="function-function-miniquake-render-world-drawstandalonebrushshadow-function-drawstandalonebrushshadow-renderer-entity-floorworldz-offsetx-offsety-contactonly-pointlightactive-lightx-lighty-lightz-src-miniquake-render-world-ml-877711092"></a>
### drawStandaloneBrushShadow

```ml
function drawStandaloneBrushShadow(renderer, entity, floorWorldZ, offsetX, offsetY, contactOnly, pointLightActive, lightX, lightY, lightZ)
```

Ray-project every polygon of an external BSP object onto the first visible main-world receiver. The legacy floor/contact parameters remain in the ABI; receiver selection now comes exclusively from the configured BSP ray caster.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `floorWorldZ` | `dynamic` | — | The floor world z input consumed by `drawStandaloneBrushShadow`. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `drawStandaloneBrushShadow`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `drawStandaloneBrushShadow`. |
| `contactOnly` | `dynamic` | — | The contact only input consumed by `drawStandaloneBrushShadow`. |
| `pointLightActive` | `dynamic` | — | The point light active input consumed by `drawStandaloneBrushShadow`. |
| `lightX` | `dynamic` | — | The light x input consumed by `drawStandaloneBrushShadow`. |
| `lightY` | `dynamic` | — | The light y input consumed by `drawStandaloneBrushShadow`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `drawStandaloneBrushShadow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L735)

<a id="function-function-miniquake-render-world-drawstandalonelight-function-drawstandalonelight-surface-src-miniquake-render-world-ml-206874807"></a>
### drawStandaloneLight

```ml
function drawStandaloneLight(surface)
```

Render standalone light.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `drawStandaloneLight`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L604)

<a id="function-function-miniquake-render-world-drawtexturechains-function-drawtexturechains-src-miniquake-render-world-ml-1855617736"></a>
### DrawTextureChains

```ml
function DrawTextureChains()
```

Render texture chains.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3614)

<a id="function-function-miniquake-render-world-emitbothskylayers-function-emitbothskylayers-surface-src-miniquake-render-world-ml-1479596611"></a>
### EmitBothSkyLayers

```ml
function EmitBothSkyLayers(surface)
```

Add both sky layers to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `EmitBothSkyLayers`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4333)

<a id="function-function-miniquake-render-world-emitskypolys-function-emitskypolys-surface-src-miniquake-render-world-ml-251159965"></a>
### EmitSkyPolys

```ml
function EmitSkyPolys(surface)
```

Add sky polys to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `EmitSkyPolys`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4300)

<a id="function-function-miniquake-render-world-emitwaterpolys-function-emitwaterpolys-surface-src-miniquake-render-world-ml-960102369"></a>
### EmitWaterPolys

```ml
function EmitWaterPolys(surface)
```

Add water polys to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `EmitWaterPolys`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4262)

<a id="function-function-miniquake-render-world-facevertex-function-facevertex-map-face-edgenumber-src-miniquake-render-world-ml-711779425"></a>
### faceVertex

```ml
function faceVertex(map, face, edgeNumber)
```

Implements the `faceVertex` operation for `miniquake.render.world` (face vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `faceVertex`. |
| `face` | `dynamic` | — | The face input consumed by `faceVertex`. |
| `edgeNumber` | `dynamic` | — | The edge number input consumed by `faceVertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L84)

<a id="function-function-miniquake-render-world-floorvalue-function-floorvalue-value-src-miniquake-render-world-ml-1925498987"></a>
### floorValue

```ml
function floorValue(value)
```

Implements the `floorValue` operation for `miniquake.render.world` (floor value).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floorValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L66)

<a id="function-function-miniquake-render-world-gl-buildlightmaps-function-gl-buildlightmaps-src-miniquake-render-world-ml-1064822400"></a>
### GL_BuildLightmaps

```ml
function GL_BuildLightmaps()
```

Mirror Quake's GL_BuildLightmaps routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4147)

<a id="function-function-miniquake-render-world-gl-createsurfacelightmap-function-gl-createsurfacelightmap-surface-src-miniquake-render-world-ml-1211624553"></a>
### GL_CreateSurfaceLightmap

```ml
function GL_CreateSurfaceLightmap(surface)
```

Mirror Quake's GL_CreateSurfaceLightmap routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `GL_CreateSurfaceLightmap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4088)

<a id="function-function-miniquake-render-world-gl-disablemultitexture-function-gl-disablemultitexture-src-miniquake-render-world-ml-1081287498"></a>
### GL_DisableMultitexture

```ml
function GL_DisableMultitexture()
```

Mirror Quake's GL_DisableMultitexture routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3043)

<a id="function-function-miniquake-render-world-gl-enablemultitexture-function-gl-enablemultitexture-src-miniquake-render-world-ml-552221136"></a>
### GL_EnableMultitexture

```ml
function GL_EnableMultitexture()
```

Mirror Quake's GL_EnableMultitexture routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3057)

<a id="function-function-miniquake-render-world-gl-subdividesurface-function-gl-subdividesurface-surface-src-miniquake-render-world-ml-365576789"></a>
### GL_SubdivideSurface

```ml
function GL_SubdivideSurface(surface)
```

Mirror Quake's GL_SubdivideSurface routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `GL_SubdivideSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4244)

<a id="constant-constant-miniquake-render-world-glquake-backface-epsilon-const-glquake-backface-epsilon-1-e-002-src-miniquake-render-world-ml-89563220"></a>
### GLQUAKE_BACKFACE_EPSILON

```ml
const GLQUAKE_BACKFACE_EPSILON = 1.e-002
```

Defines the glquake backface epsilon value used by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1466)

<a id="constant-constant-miniquake-render-world-glquake-block-height-const-glquake-block-height-128-src-miniquake-render-world-ml-1037500588"></a>
### GLQUAKE_BLOCK_HEIGHT

```ml
const GLQUAKE_BLOCK_HEIGHT = 128
```

Defines the glquake block height value used by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1456)

<a id="constant-constant-miniquake-render-world-glquake-block-width-const-glquake-block-width-128-src-miniquake-render-world-ml-967325186"></a>
### GLQUAKE_BLOCK_WIDTH

```ml
const GLQUAKE_BLOCK_WIDTH = 128
```

============================================================================= Canonical MiniQuake 1.09 renderer surface/light/warp entry points.

The C renderer stores the active world, view vectors, light styles and
dynamic lights in translation-unit globals. MiniLang keeps the same state
explicitly in package globals and refreshes it from Host_Frame through
R_ConfigureWorldCompatibility. Lightmaps retain MiniQuake's 128x128 atlas,
allocation and dirty-rectangle semantics; surface-local arrays below replace
only C pointer fields, not observable allocation or upload behavior.
=============================================================================


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1454)

<a id="constant-constant-miniquake-render-world-glquake-max-lightmaps-const-glquake-max-lightmaps-64-src-miniquake-render-world-ml-1915695059"></a>
### GLQUAKE_MAX_LIGHTMAPS

```ml
const GLQUAKE_MAX_LIGHTMAPS = 64
```

Defines the glquake max lightmaps value used by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1458)

<a id="constant-constant-miniquake-render-world-glquake-plane-anyz-const-glquake-plane-anyz-5-src-miniquake-render-world-ml-111104142"></a>
### GLQUAKE_PLANE_ANYZ

```ml
const GLQUAKE_PLANE_ANYZ = 5
```

Defines the glquake plane anyz value used by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1462)

<a id="constant-constant-miniquake-render-world-glquake-surf-underwater-const-glquake-surf-underwater-128-src-miniquake-render-world-ml-778470086"></a>
### GLQUAKE_SURF_UNDERWATER

```ml
const GLQUAKE_SURF_UNDERWATER = 128
```

Defines the glquake surf underwater value used by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1460)

<a id="constant-constant-miniquake-render-world-glquake-turbscale-const-glquake-turbscale-40-7436654315252-src-miniquake-render-world-ml-581940782"></a>
### GLQUAKE_TURBSCALE

```ml
const GLQUAKE_TURBSCALE = 40.7436654315252
```

Defines the glquake turbscale value used by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1464)

<a id="function-function-miniquake-render-world-indexedtorgba-function-indexedtorgba-indexed-palette-transparent-src-miniquake-render-world-ml-2131125466"></a>
### indexedToRgba

```ml
function indexedToRgba(indexed, palette, transparent)
```

Implements the `indexedToRgba` operation for `miniquake.render.world` (indexed to rgba).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `indexed` | `dynamic` | — | The indexed input consumed by `indexedToRgba`. |
| `palette` | `dynamic` | — | The palette input consumed by `indexedToRgba`. |
| `transparent` | `dynamic` | — | The transparent input consumed by `indexedToRgba`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L102)

<a id="global-global-miniquake-render-world-lightmap-bytes-lightmap-bytes-src-miniquake-render-world-ml-851370066"></a>
### lightmap_bytes

```ml
lightmap_bytes
```

Tracks the module-level lightmap bytes state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1582)

<a id="global-global-miniquake-render-world-lightmap-modified-lightmap-modified-src-miniquake-render-world-ml-2082704674"></a>
### lightmap_modified

```ml
lightmap_modified
```

Tracks the module-level lightmap modified state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1592)

<a id="global-global-miniquake-render-world-lightmap-polys-lightmap-polys-src-miniquake-render-world-ml-313125282"></a>
### lightmap_polys

```ml
lightmap_polys
```

Tracks the module-level lightmap polys state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1590)

<a id="global-global-miniquake-render-world-lightmap-rectchange-lightmap-rectchange-src-miniquake-render-world-ml-2137077790"></a>
### lightmap_rectchange

```ml
lightmap_rectchange
```

Tracks the module-level lightmap rectchange state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1594)

<a id="global-global-miniquake-render-world-lightmap-textures-lightmap-textures-src-miniquake-render-world-ml-824027726"></a>
### lightmap_textures

```ml
lightmap_textures
```

Tracks the module-level lightmap textures state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1584)

<a id="global-global-miniquake-render-world-lightmaps-lightmaps-src-miniquake-render-world-ml-53428550"></a>
### lightmaps

```ml
lightmaps
```

Tracks the module-level lightmaps state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1598)

<a id="global-global-miniquake-render-world-lightplane-lightplane-src-miniquake-render-world-ml-156766146"></a>
### lightplane

```ml
lightplane
```

Tracks the module-level lightplane state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1640)

<a id="global-global-miniquake-render-world-lightspot-lightspot-src-miniquake-render-world-ml-1764584358"></a>
### lightspot

```ml
lightspot
```

Tracks the module-level lightspot state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1638)

<a id="function-function-miniquake-render-world-markallvisible-function-markallvisible-renderer-src-miniquake-render-world-ml-141702167"></a>
### markAllVisible

```ml
function markAllVisible(renderer)
```

Report whether mark all visible holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L852)

<a id="function-function-miniquake-render-world-markvisible-function-markvisible-renderer-vieworigin-src-miniquake-render-world-ml-2130296736"></a>
### markVisible

```ml
function markVisible(renderer, viewOrigin)
```

Report whether mark visible holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `markVisible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L947)

<a id="function-function-miniquake-render-world-markvisiblenodesubtree-function-markvisiblenodesubtree-map-visibility-currentleaf-rowbytes-visiblenodes-nodenumber-src-miniquake-render-world-ml-258345500"></a>
### markVisibleNodeSubtree

```ml
function markVisibleNodeSubtree(map, visibility, currentLeaf, rowBytes, visibleNodes, nodeNumber)
```

Mark the exact node path to each PVS-visible leaf.  GLQuake propagates node->visframe from visible leaves rather than from faces: a leaf with no marksurfaces may still contain efrags/static entities and must keep every ancestor visible.  The temporary value two guards malformed cyclic data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `markVisibleNodeSubtree`. |
| `visibility` | `dynamic` | — | The visibility input consumed by `markVisibleNodeSubtree`. |
| `currentLeaf` | `dynamic` | — | The current leaf input consumed by `markVisibleNodeSubtree`. |
| `rowBytes` | `dynamic` | — | Byte data consumed by the operation. |
| `visibleNodes` | `dynamic` | — | The visible nodes input consumed by `markVisibleNodeSubtree`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `markVisibleNodeSubtree`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L876)

<a id="global-global-miniquake-render-world-mirror-mirror-src-miniquake-render-world-ml-1084333760"></a>
### mirror

```ml
mirror
```

Tracks the module-level mirror state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1656)

<a id="global-global-miniquake-render-world-mirror-plane-mirror-plane-src-miniquake-render-world-ml-725255730"></a>
### mirror_plane

```ml
mirror_plane
```

Tracks the module-level mirror plane state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1658)

<a id="function-function-miniquake-render-world-missingtexturepixels-function-missingtexturepixels-src-miniquake-render-world-ml-1172016994"></a>
### missingTexturePixels

```ml
function missingTexturePixels()
```

Implements the `missingTexturePixels` operation for `miniquake.render.world` (missing texture pixels).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L120)

<a id="global-global-miniquake-render-world-mtexenabled-mtexenabled-src-miniquake-render-world-ml-756217986"></a>
### mtexenabled

```ml
mtexenabled
```

Tracks the module-level mtexenabled state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1632)

<a id="global-global-miniquake-render-world-ncolinelim-ncolinelim-src-miniquake-render-world-ml-1399547494"></a>
### nColinElim

```ml
nColinElim
```

Tracks the module-level n colin elim state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1654)

<a id="function-function-miniquake-render-world-precachestaticgeometry-function-precachestaticgeometry-renderer-src-miniquake-render-world-ml-255495243"></a>
### precacheStaticGeometry

```ml
function precacheStaticGeometry(renderer)
```

Preload and register the static geometry asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3187)

<a id="function-function-miniquake-render-world-r-activedynamiclights-function-r-activedynamiclights-src-miniquake-render-world-ml-2082508200"></a>
### R_ActiveDynamicLights

```ml
function R_ActiveDynamicLights()
```

Apply the Quake-compatible r active dynamic lights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3010)

<a id="function-function-miniquake-render-world-r-adddynamiclights-function-r-adddynamiclights-surface-src-miniquake-render-world-ml-1914358209"></a>
### R_AddDynamicLights

```ml
function R_AddDynamicLights(surface)
```

Apply the Quake-compatible r add dynamic lights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_AddDynamicLights`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2779)

<a id="function-function-miniquake-render-world-r-advanceframecounters-function-r-advanceframecounters-src-miniquake-render-world-ml-547659942"></a>
### R_AdvanceFrameCounters

```ml
function R_AdvanceFrameCounters()
```

Internal package-state adapters used by gl_rmain.c/gl_rmisc.c compatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4417)

<a id="function-function-miniquake-render-world-r-animatelight-function-r-animatelight-src-miniquake-render-world-ml-1691848026"></a>
### R_AnimateLight

```ml
function R_AnimateLight()
```

----------------------------------------------------------------------------- gl_rlight.c -----------------------------------------------------------------------------


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2570)

<a id="function-function-miniquake-render-world-r-beginworldframe-function-r-beginworldframe-src-miniquake-render-world-ml-657378624"></a>
### R_BeginWorldFrame

```ml
function R_BeginWorldFrame()
```

Apply the Quake-compatible r begin world frame behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2743)

<a id="function-function-miniquake-render-world-r-blendlightmaps-function-r-blendlightmaps-src-miniquake-render-world-ml-414238478"></a>
### R_BlendLightmaps

```ml
function R_BlendLightmaps()
```

Apply the Quake-compatible r blend lightmaps behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3404)

<a id="function-function-miniquake-render-world-r-brushsurfacefacesviewer-function-r-brushsurfacefacesviewer-surface-planedistance-src-miniquake-render-world-ml-458467734"></a>
### R_BrushSurfaceFacesViewer

```ml
function R_BrushSurfaceFacesViewer(surface, planeDistance)
```

Brush models use BACKFACE_EPSILON and the opposite-facing test from R_DrawBrushModel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_BrushSurfaceFacesViewer`. |
| `planeDistance` | `dynamic` | — | The plane distance input consumed by `R_BrushSurfaceFacesViewer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2135)

<a id="function-function-miniquake-render-world-r-buildlightmap-function-r-buildlightmap-surface-destination-stride-src-miniquake-render-world-ml-672398712"></a>
### R_BuildLightMap

```ml
function R_BuildLightMap(surface, destination, stride)
```

Apply the Quake-compatible r build light map behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_BuildLightMap`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `stride` | `dynamic` | — | The stride input consumed by `R_BuildLightMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2855)

<a id="function-function-miniquake-render-world-r-chainsurface-function-r-chainsurface-surface-src-miniquake-render-world-ml-1732963665"></a>
### R_ChainSurface

```ml
function R_ChainSurface(surface)
```

Apply the Quake-compatible r chain surface behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_ChainSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2070)

<a id="function-function-miniquake-render-world-r-clearlightmapchains-function-r-clearlightmapchains-src-miniquake-render-world-ml-1947724586"></a>
### R_ClearLightmapChains

```ml
function R_ClearLightmapChains()
```

Apply the Quake-compatible r clear lightmap chains behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3694)

<a id="function-function-miniquake-render-world-r-clearproduction-function-r-clearproduction-src-miniquake-render-world-ml-339827536"></a>
### R_ClearProduction

```ml
function R_ClearProduction()
```

Apply the Quake-compatible r clear production behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1193)

<a id="function-function-miniquake-render-world-r-collectlightmaptextureids-function-r-collectlightmaptextureids-renderer-src-miniquake-render-world-ml-1019412135"></a>
### R_CollectLightmapTextureIds

```ml
function R_CollectLightmapTextureIds(renderer)
```

Apply the Quake-compatible r collect lightmap texture ids behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L838)

<a id="function-function-miniquake-render-world-r-configurecoloredlightmaps-function-r-configurecoloredlightmaps-enabled-src-miniquake-render-world-ml-1393907383"></a>
### R_ConfigureColoredLightmaps

```ml
function R_ConfigureColoredLightmaps(enabled)
```

Select whether optional QLIT sidecars may replace the scalar lightmap samples when the next world atlas is built. The Classic renderer calls this with false, preserving byte-for-byte GLQuake lightmap behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2378)

<a id="function-function-miniquake-render-world-r-configureenhancedlighting-function-r-configureenhancedlighting-requestedenabled-requestedshadows-shadowquality-src-miniquake-render-world-ml-1866934061"></a>
### R_ConfigureEnhancedLighting

```ml
function R_ConfigureEnhancedLighting(requestedEnabled, requestedShadows, shadowQuality)
```

Configure the optional renderer extension.  This never mutates Quake world state: an unavailable backend simply leaves the exact Classic path active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestedEnabled` | `dynamic` | — | The requested enabled input consumed by `R_ConfigureEnhancedLighting`. |
| `requestedShadows` | `dynamic` | — | The requested shadows input consumed by `R_ConfigureEnhancedLighting`. |
| `shadowQuality` | `dynamic` | — | The shadow quality input consumed by `R_ConfigureEnhancedLighting`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2389)

<a id="function-function-miniquake-render-world-r-configurespecialcompatibility-function-r-configurespecialcompatibility-mirroralpha-clearcolor-ztrick-finishbeforerender-norefresh-src-miniquake-render-world-ml-1106925904"></a>
### R_ConfigureSpecialCompatibility

```ml
function R_ConfigureSpecialCompatibility(mirrorAlpha, clearColor, zTrick, finishBeforeRender, noRefresh)
```

Configure MiniQuake's frame-clear and special-render cvars without changing the public renderViewport signature used by older compatibility fixtures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mirrorAlpha` | `dynamic` | — | The mirror alpha input consumed by `R_ConfigureSpecialCompatibility`. |
| `clearColor` | `dynamic` | — | The clear color input consumed by `R_ConfigureSpecialCompatibility`. |
| `zTrick` | `dynamic` | — | The z trick input consumed by `R_ConfigureSpecialCompatibility`. |
| `finishBeforeRender` | `dynamic` | — | The finish before render input consumed by `R_ConfigureSpecialCompatibility`. |
| `noRefresh` | `dynamic` | — | The no refresh input consumed by `R_ConfigureSpecialCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1132)

<a id="function-function-miniquake-render-world-r-configureworldcompatibility-function-r-configureworldcompatibility-renderer-vieworigin-viewangles-viewforward-viewright-viewup-dynamiclights-lightstyles-blend-currenttime-realtime-frametime-flashblend-dynamicenabled-novis-src-miniquake-render-world-ml-1774471174"></a>
### R_ConfigureWorldCompatibility

```ml
function R_ConfigureWorldCompatibility(renderer, viewOrigin, viewAngles, viewForward, viewRight, viewUp, dynamicLights, lightStyles, blend, currentTime, realtime, frameTime, flashBlend, dynamicEnabled, noVis)
```

Apply the Quake-compatible r configure world compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_ConfigureWorldCompatibility`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `R_ConfigureWorldCompatibility`. |
| `viewForward` | `dynamic` | — | The view forward input consumed by `R_ConfigureWorldCompatibility`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `R_ConfigureWorldCompatibility`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `R_ConfigureWorldCompatibility`. |
| `dynamicLights` | `dynamic` | — | The dynamic lights input consumed by `R_ConfigureWorldCompatibility`. |
| `lightStyles` | `dynamic` | — | The light styles input consumed by `R_ConfigureWorldCompatibility`. |
| `blend` | `dynamic` | — | The blend input consumed by `R_ConfigureWorldCompatibility`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `flashBlend` | `dynamic` | — | The flash blend input consumed by `R_ConfigureWorldCompatibility`. |
| `dynamicEnabled` | `dynamic` | — | The dynamic enabled input consumed by `R_ConfigureWorldCompatibility`. |
| `noVis` | `dynamic` | — | The no vis input consumed by `R_ConfigureWorldCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2328)

<a id="function-function-miniquake-render-world-r-currentdepthfunction-function-r-currentdepthfunction-src-miniquake-render-world-ml-568551658"></a>
### R_CurrentDepthFunction

```ml
function R_CurrentDepthFunction()
```

Return the depth comparison selected by R_ClearProduction for this frame. gl_ztrick reverses the depth range every other frame and therefore requires every later overlay (lighting, shadows and the view model) to retain GEQUAL on those frames instead of silently restoring the usual LEQUAL mode.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1171)

<a id="function-function-miniquake-render-world-r-currentdepthmaximum-function-r-currentdepthmaximum-src-miniquake-render-world-ml-334307668"></a>
### R_CurrentDepthMaximum

```ml
function R_CurrentDepthMaximum()
```

Mirror Quake's R_CurrentDepthMaximum routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1163)

<a id="function-function-miniquake-render-world-r-currentdepthminimum-function-r-currentdepthminimum-src-miniquake-render-world-ml-2133450928"></a>
### R_CurrentDepthMinimum

```ml
function R_CurrentDepthMinimum()
```

Mirror Quake's R_CurrentDepthMinimum routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1158)

<a id="function-function-miniquake-render-world-r-currentdepthrange-function-r-currentdepthrange-src-miniquake-render-world-ml-790351062"></a>
### R_CurrentDepthRange

```ml
function R_CurrentDepthRange()
```

Apply the Quake-compatible r current depth range behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1153)

<a id="function-function-miniquake-render-world-r-currentvieworigin-function-r-currentvieworigin-src-miniquake-render-world-ml-130165024"></a>
### R_CurrentViewOrigin

```ml
function R_CurrentViewOrigin()
```

Apply the Quake-compatible r current view origin behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1176)

<a id="function-function-miniquake-render-world-r-currentworldmap-function-r-currentworldmap-src-miniquake-render-world-ml-181508510"></a>
### R_CurrentWorldMap

```ml
function R_CurrentWorldMap()
```

Return the active main BSP map used by entity shadow-ray projection.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1181)

<a id="function-function-miniquake-render-world-r-currentworldsurfaces-function-r-currentworldsurfaces-src-miniquake-render-world-ml-334047326"></a>
### R_CurrentWorldSurfaces

```ml
function R_CurrentWorldSurfaces()
```

Return the active render-surface graph used by arbitrary BSP shadow rays.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1187)

<a id="global-global-miniquake-render-world-r-dlightframecount-r-dlightframecount-src-miniquake-render-world-ml-919410272"></a>
### r_dlightframecount

```ml
r_dlightframecount
```

Tracks the module-level r dlightframecount state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1634)

<a id="function-function-miniquake-render-world-r-drawbrushmodel-function-r-drawbrushmodel-entity-src-miniquake-render-world-ml-1753932311"></a>
### R_DrawBrushModel

```ml
function R_DrawBrushModel(entity)
```

Apply the Quake-compatible r draw brush model behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3857)

<a id="function-function-miniquake-render-world-r-drawbrushmodelenhancedforsubmodel-function-r-drawbrushmodelenhancedforsubmodel-entity-submodelindex-src-miniquake-render-world-ml-1405747484"></a>
### R_DrawBrushModelEnhancedForSubmodel

```ml
function R_DrawBrushModelEnhancedForSubmodel(entity, submodelIndex)
```

Draw only the textured faces of one inline BSP model for the enhanced additive pass; classic lightmap chains and dynamic-light marks are not touched by this second draw.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `submodelIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3762)

<a id="function-function-miniquake-render-world-r-drawbrushmodelforsubmodel-function-r-drawbrushmodelforsubmodel-entity-submodelindex-src-miniquake-render-world-ml-1201834000"></a>
### R_DrawBrushModelForSubmodel

```ml
function R_DrawBrushModelForSubmodel(entity, submodelIndex)
```

Apply the Quake-compatible r draw brush model for submodel behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `submodelIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3711)

<a id="function-function-miniquake-render-world-r-drawbrushmodelshadowforsubmodel-function-r-drawbrushmodelshadowforsubmodel-entity-submodelindex-floorworldz-offsetx-offsety-contactonly-pointlightactive-lightx-lighty-lightz-src-miniquake-render-world-ml-1991733448"></a>
### R_DrawBrushModelShadowForSubmodel

```ml
function R_DrawBrushModelShadowForSubmodel(entity, submodelIndex, floorWorldZ, offsetX, offsetY, contactOnly, pointLightActive, lightX, lightY, lightZ)
```

Ray-project an inline BSP object's complete silhouette onto arbitrary world polygons. Each fan triangle is emitted only when all three rays reach a compatible receiver, preventing interpolation through a BSP corner.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `submodelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `floorWorldZ` | `dynamic` | — | The floor world z input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `contactOnly` | `dynamic` | — | The contact only input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `pointLightActive` | `dynamic` | — | The point light active input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `lightX` | `dynamic` | — | The light x input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `lightY` | `dynamic` | — | The light y input consumed by `R_DrawBrushModelShadowForSubmodel`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `R_DrawBrushModelShadowForSubmodel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3811)

<a id="function-function-miniquake-render-world-r-drawenhancedworldlighting-function-r-drawenhancedworldlighting-src-miniquake-render-world-ml-81359652"></a>
### R_DrawEnhancedWorldLighting

```ml
function R_DrawEnhancedWorldLighting()
```

Render an additive, per-pixel dynamic-light layer over the already complete classic base/lightmap world.  Static lightmaps remain untouched; therefore disabling this pass produces byte-for-byte Classic draw ordering again.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2432)

<a id="function-function-miniquake-render-world-r-drawmirroroverlay-function-r-drawmirroroverlay-width-height-viewrect-origin-angles-src-miniquake-render-world-ml-89121154"></a>
### R_DrawMirrorOverlay

```ml
function R_DrawMirrorOverlay(width, height, viewRect, origin, angles)
```

Apply the Quake-compatible r draw mirror overlay behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `viewRect` | `dynamic` | — | The view rect input consumed by `R_DrawMirrorOverlay`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1247)

<a id="function-function-miniquake-render-world-r-drawmultitexturebatch-function-r-drawmultitexturebatch-surfaces-surfacecount-src-miniquake-render-world-ml-128455922"></a>
### R_DrawMultitextureBatch

```ml
function R_DrawMultitextureBatch(surfaces, surfaceCount)
```

Apply the Quake-compatible r draw multitexture batch behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `R_DrawMultitextureBatch`. |
| `surfaceCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3345)

<a id="function-function-miniquake-render-world-r-drawsequentialpoly-function-r-drawsequentialpoly-surface-src-miniquake-render-world-ml-1797618105"></a>
### R_DrawSequentialPoly

```ml
function R_DrawSequentialPoly(surface)
```

Apply the Quake-compatible r draw sequential poly behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_DrawSequentialPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3070)

<a id="function-function-miniquake-render-world-r-drawskychain-function-r-drawskychain-chain-src-miniquake-render-world-ml-903022059"></a>
### R_DrawSkyChain

```ml
function R_DrawSkyChain(chain)
```

Apply the Quake-compatible r draw sky chain behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chain` | `dynamic` | — | The chain input consumed by `R_DrawSkyChain`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4355)

<a id="function-function-miniquake-render-world-r-drawwatersurfaces-function-r-drawwatersurfaces-src-miniquake-render-world-ml-1983743954"></a>
### R_DrawWaterSurfaces

```ml
function R_DrawWaterSurfaces()
```

Apply the Quake-compatible r draw water surfaces behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3563)

<a id="function-function-miniquake-render-world-r-drawworld-function-r-drawworld-src-miniquake-render-world-ml-333004708"></a>
### R_DrawWorld

```ml
function R_DrawWorld()
```

Apply the Quake-compatible r draw world behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3940)

<a id="function-function-miniquake-render-world-r-dynamiclightisactive-inline-function-r-dynamiclightisactive-light-currenttime-src-miniquake-render-world-ml-657683913"></a>
### R_DynamicLightIsActive

```ml
inline function R_DynamicLightIsActive(light, currentTime)
```

Apply the Quake-compatible r dynamic light is active behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `R_DynamicLightIsActive`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2209)

<a id="global-global-miniquake-render-world-r-framecount-r-framecount-src-miniquake-render-world-ml-362967772"></a>
### r_framecount

```ml
r_framecount
```

Tracks the module-level r framecount state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1648)

<a id="function-function-miniquake-render-world-r-getallocationcompatibilitystate-function-r-getallocationcompatibilitystate-page-src-miniquake-render-world-ml-314626779"></a>
### R_GetAllocationCompatibilityState

```ml
function R_GetAllocationCompatibilityState(page)
```

Apply the Quake-compatible r get allocation compatibility state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `R_GetAllocationCompatibilityState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2185)

<a id="function-function-miniquake-render-world-r-getblocklights-function-r-getblocklights-src-miniquake-render-world-ml-1441747526"></a>
### R_GetBlocklights

```ml
function R_GetBlocklights()
```

Apply the Quake-compatible r get blocklights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2150)

<a id="function-function-miniquake-render-world-r-getdynamiclightcompatibilitystate-function-r-getdynamiclightcompatibilitystate-index-src-miniquake-render-world-ml-1928554678"></a>
### R_GetDynamicLightCompatibilityState

```ml
function R_GetDynamicLightCompatibilityState(index)
```

Apply the Quake-compatible r get dynamic light compatibility state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2201)

<a id="function-function-miniquake-render-world-r-getframecompatibility-function-r-getframecompatibility-src-miniquake-render-world-ml-1341935770"></a>
### R_GetFrameCompatibility

```ml
function R_GetFrameCompatibility()
```

Apply the Quake-compatible r get frame compatibility behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2195)

<a id="function-function-miniquake-render-world-r-getlightmapbytes-function-r-getlightmapbytes-src-miniquake-render-world-ml-28439074"></a>
### R_GetLightmapBytes

```ml
function R_GetLightmapBytes()
```

Apply the Quake-compatible r get lightmap bytes behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2155)

<a id="function-function-miniquake-render-world-r-getlightmapcompatibilitystate-function-r-getlightmapcompatibilitystate-page-src-miniquake-render-world-ml-55390271"></a>
### R_GetLightmapCompatibilityState

```ml
function R_GetLightmapCompatibilityState(page)
```

Apply the Quake-compatible r get lightmap compatibility state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `R_GetLightmapCompatibilityState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2173)

<a id="function-function-miniquake-render-world-r-getmirrorcompatibilitystate-function-r-getmirrorcompatibilitystate-src-miniquake-render-world-ml-1781795500"></a>
### R_GetMirrorCompatibilityState

```ml
function R_GetMirrorCompatibilityState()
```

Apply the Quake-compatible r get mirror compatibility state behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2190)

<a id="function-function-miniquake-render-world-r-getsurfacecompatibilitystate-function-r-getsurfacecompatibilitystate-index-src-miniquake-render-world-ml-1399428960"></a>
### R_GetSurfaceCompatibilityState

```ml
function R_GetSurfaceCompatibilityState(index)
```

Apply the Quake-compatible r get surface compatibility state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2161)

<a id="function-function-miniquake-render-world-r-gettexturechains-function-r-gettexturechains-src-miniquake-render-world-ml-633685578"></a>
### R_GetTextureChains

```ml
function R_GetTextureChains()
```

Apply the Quake-compatible r get texture chains behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2048)

<a id="function-function-miniquake-render-world-r-initsky-function-r-initsky-texture-src-miniquake-render-world-ml-385650517"></a>
### R_InitSky

```ml
function R_InitSky(texture)
```

Apply the Quake-compatible r init sky behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4383)

<a id="function-function-miniquake-render-world-r-lightmaprequiredbytes-function-r-lightmaprequiredbytes-width-height-stride-bytespersample-src-miniquake-render-world-ml-1809100008"></a>
### R_LightmapRequiredBytes

```ml
function R_LightmapRequiredBytes(width, height, stride, bytesPerSample)
```

Apply the Quake-compatible r lightmap required bytes behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `stride` | `dynamic` | — | The stride input consumed by `R_LightmapRequiredBytes`. |
| `bytesPerSample` | `dynamic` | — | The bytes per sample input consumed by `R_LightmapRequiredBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2843)

<a id="function-function-miniquake-render-world-r-lightpoint-function-r-lightpoint-point-src-miniquake-render-world-ml-1379295134"></a>
### R_LightPoint

```ml
function R_LightPoint(point)
```

Apply the Quake-compatible r light point behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `R_LightPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2977)

<a id="function-function-miniquake-render-world-r-lightpointhit-function-r-lightpointhit-src-miniquake-render-world-ml-1414498542"></a>
### R_LightPointHit

```ml
function R_LightPointHit()
```

Report whether the most recent vertical light/receiver trace actually hit a world surface.  lightspot intentionally retains its storage object for allocation-free alias lighting, so callers must not infer validity merely from that object's non-void state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3005)

<a id="function-function-miniquake-render-world-r-mainrenderstageorder-function-r-mainrenderstageorder-src-miniquake-render-world-ml-1536612914"></a>
### R_MainRenderStageOrder

```ml
function R_MainRenderStageOrder()
```

Apply the Quake-compatible r main render stage order behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1276)

<a id="function-function-miniquake-render-world-r-markbrushmodellights-function-r-markbrushmodellights-entity-src-miniquake-render-world-ml-1461316059"></a>
### R_MarkBrushModelLights

```ml
function R_MarkBrushModelLights(entity)
```

Apply the Quake-compatible r mark brush model lights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2772)

<a id="function-function-miniquake-render-world-r-markbrushmodellightsforsubmodel-function-r-markbrushmodellightsforsubmodel-entity-submodelindex-src-miniquake-render-world-ml-1363709696"></a>
### R_MarkBrushModelLightsForSubmodel

```ml
function R_MarkBrushModelLightsForSubmodel(entity, submodelIndex)
```

Apply the Quake-compatible r mark brush model lights for submodel behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `submodelIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2753)

<a id="function-function-miniquake-render-world-r-markleaves-function-r-markleaves-src-miniquake-render-world-ml-1125507458"></a>
### R_MarkLeaves

```ml
function R_MarkLeaves()
```

Apply the Quake-compatible r mark leaves behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3977)

<a id="function-function-miniquake-render-world-r-marklights-function-r-marklights-light-bit-nodenumber-src-miniquake-render-world-ml-210918692"></a>
### R_MarkLights

```ml
function R_MarkLights(light, bit, nodeNumber)
```

Apply the Quake-compatible r mark lights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `R_MarkLights`. |
| `bit` | `dynamic` | — | The bit input consumed by `R_MarkLights`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `R_MarkLights`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2709)

<a id="function-function-miniquake-render-world-r-mirrorchain-function-r-mirrorchain-surface-src-miniquake-render-world-ml-50387383"></a>
### R_MirrorChain

```ml
function R_MirrorChain(surface)
```

Apply the Quake-compatible r mirror chain behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_MirrorChain`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3554)

<a id="function-function-miniquake-render-world-r-mirrorchaincount-function-r-mirrorchaincount-src-miniquake-render-world-ml-186523018"></a>
### R_MirrorChainCount

```ml
function R_MirrorChainCount()
```

Apply the Quake-compatible r mirror chain count behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1237)

<a id="function-function-miniquake-render-world-r-mirrorprojectionscale-function-r-mirrorprojectionscale-src-miniquake-render-world-ml-781656952"></a>
### R_MirrorProjectionScale

```ml
function R_MirrorProjectionScale()
```

Apply the Quake-compatible r mirror projection scale behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1232)

<a id="function-function-miniquake-render-world-r-mirrorready-inline-function-r-mirrorready-src-miniquake-render-world-ml-976735335"></a>
### R_MirrorReady

```ml
inline function R_MirrorReady()
```

Apply the Quake-compatible r mirror ready behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1219)

<a id="function-function-miniquake-render-world-r-mirrorview-function-r-mirrorview-origin-angles-src-miniquake-render-world-ml-2139202968"></a>
### R_MirrorView

```ml
function R_MirrorView(origin, angles)
```

Apply the Quake-compatible r mirror view behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1226)

<a id="function-function-miniquake-render-world-r-polyblendproduction-function-r-polyblendproduction-blend-enabled-src-miniquake-render-world-ml-281024384"></a>
### R_PolyBlendProduction

```ml
function R_PolyBlendProduction(blend, enabled)
```

Production MiniQuake R_PolyBlend.  Host invokes this after entities, viewmodel and particles, while the 3-D viewport/projection from R_SetupGL is still active and before gl_screen switches to its full-screen 2-D projection.  Drawing this as a 2-D quad would incorrectly tint the HUD and console outside r_refdef.vrect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `blend` | `dynamic` | — | The blend input consumed by `R_PolyBlendProduction`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2670)

<a id="function-function-miniquake-render-world-r-pushdlights-function-r-pushdlights-src-miniquake-render-world-ml-1465777786"></a>
### R_PushDlights

```ml
function R_PushDlights()
```

Apply the Quake-compatible r push dlights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2724)

<a id="function-function-miniquake-render-world-r-recursiveworldnode-function-r-recursiveworldnode-nodenumber-src-miniquake-render-world-ml-1602504665"></a>
### R_RecursiveWorldNode

```ml
function R_RecursiveWorldNode(nodeNumber)
```

Apply the Quake-compatible r recursive world node behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `R_RecursiveWorldNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3930)

<a id="function-function-miniquake-render-world-r-renderbrushpoly-function-r-renderbrushpoly-surface-src-miniquake-render-world-ml-586580055"></a>
### R_RenderBrushPoly

```ml
function R_RenderBrushPoly(surface)
```

Apply the Quake-compatible r render brush poly behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_RenderBrushPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3519)

<a id="function-function-miniquake-render-world-r-renderdlight-function-r-renderdlight-light-src-miniquake-render-world-ml-1949392856"></a>
### R_RenderDlight

```ml
function R_RenderDlight(light)
```

Apply the Quake-compatible r render dlight behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `R_RenderDlight`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2606)

<a id="function-function-miniquake-render-world-r-renderdlights-function-r-renderdlights-src-miniquake-render-world-ml-785800842"></a>
### R_RenderDlights

```ml
function R_RenderDlights()
```

Apply the Quake-compatible r render dlights behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2637)

<a id="function-function-miniquake-render-world-r-renderdynamiclightmaps-function-r-renderdynamiclightmaps-surface-src-miniquake-render-world-ml-67739665"></a>
### R_RenderDynamicLightmaps

```ml
function R_RenderDynamicLightmaps(surface)
```

Apply the Quake-compatible r render dynamic lightmaps behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_RenderDynamicLightmaps`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3513)

<a id="function-function-miniquake-render-world-r-resetlightmapcompatibility-function-r-resetlightmapcompatibility-src-miniquake-render-world-ml-746871814"></a>
### R_ResetLightmapCompatibility

```ml
function R_ResetLightmapCompatibility()
```

Apply the Quake-compatible r reset lightmap compatibility behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2214)

<a id="function-function-miniquake-render-world-r-resetlightstyles-function-r-resetlightstyles-value-src-miniquake-render-world-ml-1179483827"></a>
### R_ResetLightStyles

```ml
function R_ResetLightStyles(value)
```

Apply the Quake-compatible r reset light styles behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `R_ResetLightStyles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4425)

<a id="function-function-miniquake-render-world-r-resetmirrorcompatibility-function-r-resetmirrorcompatibility-src-miniquake-render-world-ml-1185130234"></a>
### R_ResetMirrorCompatibility

```ml
function R_ResetMirrorCompatibility()
```

Apply the Quake-compatible r reset mirror compatibility behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1208)

<a id="function-function-miniquake-render-world-r-resettexturechains-function-r-resettexturechains-src-miniquake-render-world-ml-1761787606"></a>
### R_ResetTextureChains

```ml
function R_ResetTextureChains()
```

gl_rsurf.c stores one linked surface chain on every texture. Arrays preserve the same head-insertion order without exposing C pointers.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2031)

<a id="function-function-miniquake-render-world-r-resetworldcompatibility-function-r-resetworldcompatibility-src-miniquake-render-world-ml-672779482"></a>
### R_ResetWorldCompatibility

```ml
function R_ResetWorldCompatibility()
```

Apply the Quake-compatible r reset world compatibility behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1661)

<a id="function-function-miniquake-render-world-r-setabstractsurfacecalls-function-r-setabstractsurfacecalls-enabled-src-miniquake-render-world-ml-348485621"></a>
### R_SetAbstractSurfaceCalls

```ml
function R_SetAbstractSurfaceCalls(enabled)
```

Apply the Quake-compatible r set abstract surface calls behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2010)

<a id="function-function-miniquake-render-world-r-setcullcompatibility-function-r-setcullcompatibility-enabled-src-miniquake-render-world-ml-789833947"></a>
### R_SetCullCompatibility

```ml
function R_SetCullCompatibility(enabled)
```

Apply the Quake-compatible r set cull compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1119)

<a id="function-function-miniquake-render-world-r-setframecompatibility-function-r-setframecompatibility-frame-visframe-src-miniquake-render-world-ml-2046984758"></a>
### R_SetFrameCompatibility

```ml
function R_SetFrameCompatibility(frame, visFrame)
```

Apply the Quake-compatible r set frame compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `R_SetFrameCompatibility`. |
| `visFrame` | `dynamic` | — | The vis frame input consumed by `R_SetFrameCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1909)

<a id="function-function-miniquake-render-world-r-setlightmapchaincompatibility-function-r-setlightmapchaincompatibility-page-surfaces-src-miniquake-render-world-ml-333657103"></a>
### R_SetLightmapChainCompatibility

```ml
function R_SetLightmapChainCompatibility(page, surfaces)
```

Apply the Quake-compatible r set lightmap chain compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `R_SetLightmapChainCompatibility`. |
| `surfaces` | `dynamic` | — | The surfaces input consumed by `R_SetLightmapChainCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1959)

<a id="function-function-miniquake-render-world-r-setlightmapcompatibility-function-r-setlightmapcompatibility-texturebase-bytespersample-src-miniquake-render-world-ml-1979840310"></a>
### R_SetLightmapCompatibility

```ml
function R_SetLightmapCompatibility(textureBase, bytesPerSample)
```

Apply the Quake-compatible r set lightmap compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textureBase` | `dynamic` | — | The texture base input consumed by `R_SetLightmapCompatibility`. |
| `bytesPerSample` | `dynamic` | — | The bytes per sample input consumed by `R_SetLightmapCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1927)

<a id="function-function-miniquake-render-world-r-setlightmapdirtycompatibility-function-r-setlightmapdirtycompatibility-page-rectangle-modified-src-miniquake-render-world-ml-1981505167"></a>
### R_SetLightmapDirtyCompatibility

```ml
function R_SetLightmapDirtyCompatibility(page, rectangle, modified)
```

Apply the Quake-compatible r set lightmap dirty compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `R_SetLightmapDirtyCompatibility`. |
| `rectangle` | `dynamic` | — | The rectangle input consumed by `R_SetLightmapDirtyCompatibility`. |
| `modified` | `dynamic` | — | The modified input consumed by `R_SetLightmapDirtyCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1938)

<a id="function-function-miniquake-render-world-r-setlightstylecompatibility-function-r-setlightstylecompatibility-values-src-miniquake-render-world-ml-552460848"></a>
### R_SetLightStyleCompatibility

```ml
function R_SetLightStyleCompatibility(values)
```

Apply the Quake-compatible r set light style compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `R_SetLightStyleCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1918)

<a id="function-function-miniquake-render-world-r-setmultitexturecompatibility-function-r-setmultitexturecompatibility-available-enabled-src-miniquake-render-world-ml-2116751486"></a>
### R_SetMultitextureCompatibility

```ml
function R_SetMultitextureCompatibility(available, enabled)
```

Apply the Quake-compatible r set multitexture compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `available` | `dynamic` | — | The available input consumed by `R_SetMultitextureCompatibility`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1886)

<a id="function-function-miniquake-render-world-r-setsubdividesize-function-r-setsubdividesize-value-src-miniquake-render-world-ml-1457459491"></a>
### R_SetSubdivideSize

```ml
function R_SetSubdivideSize(value)
```

Apply the Quake-compatible r set subdivide size behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `R_SetSubdivideSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2499)

<a id="function-function-miniquake-render-world-r-setsurfacechaincompatibility-function-r-setsurfacechaincompatibility-texturesort-skysurfaces-watersurfaces-src-miniquake-render-world-ml-1482512089"></a>
### R_SetSurfaceChainCompatibility

```ml
function R_SetSurfaceChainCompatibility(textureSort, skySurfaces, waterSurfaces)
```

Apply the Quake-compatible r set surface chain compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textureSort` | `dynamic` | — | The texture sort input consumed by `R_SetSurfaceChainCompatibility`. |
| `skySurfaces` | `dynamic` | — | The sky surfaces input consumed by `R_SetSurfaceChainCompatibility`. |
| `waterSurfaces` | `dynamic` | — | The water surfaces input consumed by `R_SetSurfaceChainCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2020)

<a id="function-function-miniquake-render-world-r-setsurfacecompatibilitystate-function-r-setsurfacecompatibilitystate-index-bitsvalue-dlightframe-cachedvalues-cacheddlight-page-lights-lightt-src-miniquake-render-world-ml-1969854418"></a>
### R_SetSurfaceCompatibilityState

```ml
function R_SetSurfaceCompatibilityState(index, bitsValue, dlightFrame, cachedValues, cachedDlight, page, lightS, lightT)
```

Private compatibility-state adapters used by deterministic renderer oracles and by the higher-level MiniQuake host integration.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `bitsValue` | `dynamic` | — | The bits value input consumed by `R_SetSurfaceCompatibilityState`. |
| `dlightFrame` | `dynamic` | — | The dlight frame input consumed by `R_SetSurfaceCompatibilityState`. |
| `cachedValues` | `dynamic` | — | The cached values input consumed by `R_SetSurfaceCompatibilityState`. |
| `cachedDlight` | `dynamic` | — | The cached dlight input consumed by `R_SetSurfaceCompatibilityState`. |
| `page` | `dynamic` | — | The page input consumed by `R_SetSurfaceCompatibilityState`. |
| `lightS` | `dynamic` | — | The light s input consumed by `R_SetSurfaceCompatibilityState`. |
| `lightT` | `dynamic` | — | The light t input consumed by `R_SetSurfaceCompatibilityState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1867)

<a id="function-function-miniquake-render-world-r-settextureanimationframe-function-r-settextureanimationframe-frame-src-miniquake-render-world-ml-2131344927"></a>
### R_SetTextureAnimationFrame

```ml
function R_SetTextureAnimationFrame(frame)
```

Apply the Quake-compatible r set texture animation frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `R_SetTextureAnimationFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1900)

<a id="function-function-miniquake-render-world-r-specialcompatibilitystate-function-r-specialcompatibilitystate-src-miniquake-render-world-ml-1173491896"></a>
### R_SpecialCompatibilityState

```ml
function R_SpecialCompatibilityState()
```

Apply the Quake-compatible r special compatibility state behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1144)

<a id="function-function-miniquake-render-world-r-surfacefacesviewer-function-r-surfacefacesviewer-surface-planedistance-src-miniquake-render-world-ml-618819382"></a>
### R_SurfaceFacesViewer

```ml
function R_SurfaceFacesViewer(surface, planeDistance)
```

World surfaces use the exact dot-sign rule from R_RecursiveWorldNode. Underwater polygons bypass back-face rejection because their warped vertices may cross the original plane.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `R_SurfaceFacesViewer`. |
| `planeDistance` | `dynamic` | — | The plane distance input consumed by `R_SurfaceFacesViewer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2123)

<a id="function-function-miniquake-render-world-r-textureanimation-function-r-textureanimation-base-src-miniquake-render-world-ml-540970809"></a>
### R_TextureAnimation

```ml
function R_TextureAnimation(base)
```

----------------------------------------------------------------------------- gl_rsurf.c -----------------------------------------------------------------------------

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `dynamic` | — | The base input consumed by `R_TextureAnimation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L3019)

<a id="function-function-miniquake-render-world-r-viewportrect-function-r-viewportrect-viewx-viewy-width-height-screenwidth-screenheight-src-miniquake-render-world-ml-1066756675"></a>
### R_ViewportRect

```ml
function R_ViewportRect(viewX, viewY, width, height, screenWidth, screenHeight)
```

Apply the Quake-compatible r viewport rect behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewX` | `dynamic` | — | The view x input consumed by `R_ViewportRect`. |
| `viewY` | `dynamic` | — | The view y input consumed by `R_ViewportRect`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `screenWidth` | `dynamic` | — | The screen width input consumed by `R_ViewportRect`. |
| `screenHeight` | `dynamic` | — | The screen height input consumed by `R_ViewportRect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1100)

<a id="global-global-miniquake-render-world-r-visframecount-r-visframecount-src-miniquake-render-world-ml-1528923638"></a>
### r_visframecount

```ml
r_visframecount
```

Tracks the module-level r visframecount state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1650)

<a id="function-function-miniquake-render-world-r-waterpassdeferred-inline-function-r-waterpassdeferred-texturesort-wateralpha-src-miniquake-render-world-ml-561526241"></a>
### R_WaterPassDeferred

```ml
inline function R_WaterPassDeferred(textureSort, waterAlpha)
```

Apply the Quake-compatible r water pass deferred behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textureSort` | `dynamic` | — | The texture sort input consumed by `R_WaterPassDeferred`. |
| `waterAlpha` | `dynamic` | — | The water alpha input consumed by `R_WaterPassDeferred`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2145)

<a id="global-global-miniquake-render-world-rcompatabstractsurfacecalls-rcompatabstractsurfacecalls-src-miniquake-render-world-ml-1772126570"></a>
### rCompatAbstractSurfaceCalls

```ml
rCompatAbstractSurfaceCalls
```

Tracks the module-level r compat abstract surface calls state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1555)

<a id="global-global-miniquake-render-world-rcompatalphaskytexture-rcompatalphaskytexture-src-miniquake-render-world-ml-2009220470"></a>
### rCompatAlphaSkyTexture

```ml
rCompatAlphaSkyTexture
```

Tracks the module-level r compat alpha sky texture state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1529)

<a id="global-global-miniquake-render-world-rcompatblend-rcompatblend-src-miniquake-render-world-ml-219558584"></a>
### rCompatBlend

```ml
rCompatBlend
```

Tracks the module-level r compat blend state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1485)

<a id="global-global-miniquake-render-world-rcompatclearcolor-rcompatclearcolor-src-miniquake-render-world-ml-1232903598"></a>
### rCompatClearColor

```ml
rCompatClearColor
```

Tracks the module-level r compat clear color state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1563)

<a id="global-global-miniquake-render-world-rcompatcollectsequential-rcompatcollectsequential-src-miniquake-render-world-ml-1809087196"></a>
### rCompatCollectSequential

```ml
rCompatCollectSequential
```

Tracks the module-level r compat collect sequential state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1616)

<a id="global-global-miniquake-render-world-rcompatcoloredlighting-rcompatcoloredlighting-src-miniquake-render-world-ml-255042330"></a>
### rCompatColoredLighting

```ml
rCompatColoredLighting
```

Tracks the module-level r compat colored lighting state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1602)

<a id="global-global-miniquake-render-world-rcompatcull-rcompatcull-src-miniquake-render-world-ml-1446567698"></a>
### rCompatCull

```ml
rCompatCull
```

Tracks the module-level r compat cull state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1559)

<a id="global-global-miniquake-render-world-rcompatdepthfunc-rcompatdepthfunc-src-miniquake-render-world-ml-1761257320"></a>
### rCompatDepthFunc

```ml
rCompatDepthFunc
```

Tracks the module-level r compat depth func state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1549)

<a id="global-global-miniquake-render-world-rcompatdepthmax-rcompatdepthmax-src-miniquake-render-world-ml-735601322"></a>
### rCompatDepthMax

```ml
rCompatDepthMax
```

Tracks the module-level r compat depth max state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1547)

<a id="global-global-miniquake-render-world-rcompatdepthmin-rcompatdepthmin-src-miniquake-render-world-ml-1681648474"></a>
### rCompatDepthMin

```ml
rCompatDepthMin
```

Tracks the module-level r compat depth min state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1545)

<a id="global-global-miniquake-render-world-rcompatdlights-rcompatdlights-src-miniquake-render-world-ml-629536132"></a>
### rCompatDlights

```ml
rCompatDlights
```

Tracks the module-level r compat dlights state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1481)

<a id="global-global-miniquake-render-world-rcompatdynamic-rcompatdynamic-src-miniquake-render-world-ml-1315709696"></a>
### rCompatDynamic

```ml
rCompatDynamic
```

Tracks the module-level r compat dynamic state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1495)

<a id="global-global-miniquake-render-world-rcompatenhancedbatchkeys-rcompatenhancedbatchkeys-src-miniquake-render-world-ml-1699323826"></a>
### rCompatEnhancedBatchKeys

```ml
rCompatEnhancedBatchKeys
```

Tracks the module-level r compat enhanced batch keys state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1503)

<a id="global-global-miniquake-render-world-rcompatenhancedtexturebuilders-rcompatenhancedtexturebuilders-src-miniquake-render-world-ml-2012700228"></a>
### rCompatEnhancedTextureBuilders

```ml
rCompatEnhancedTextureBuilders
```

Tracks the module-level r compat enhanced texture builders state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1501)

<a id="global-global-miniquake-render-world-rcompatfinish-rcompatfinish-src-miniquake-render-world-ml-1310608942"></a>
### rCompatFinish

```ml
rCompatFinish
```

Tracks the module-level r compat finish state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1567)

<a id="global-global-miniquake-render-world-rcompatflashblend-rcompatflashblend-src-miniquake-render-world-ml-2010287474"></a>
### rCompatFlashBlend

```ml
rCompatFlashBlend
```

Tracks the module-level r compat flash blend state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1493)

<a id="global-global-miniquake-render-world-rcompatframetime-rcompatframetime-src-miniquake-render-world-ml-1920668554"></a>
### rCompatFrameTime

```ml
rCompatFrameTime
```

Tracks the module-level r compat frame time state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1491)

<a id="global-global-miniquake-render-world-rcompatlastclearplan-rcompatlastclearplan-src-miniquake-render-world-ml-701989722"></a>
### rCompatLastClearPlan

```ml
rCompatLastClearPlan
```

Tracks the module-level r compat last clear plan state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1577)

<a id="global-global-miniquake-render-world-rcompatlightmapallocated-rcompatlightmapallocated-src-miniquake-render-world-ml-144178436"></a>
### rCompatLightmapAllocated

```ml
rCompatLightmapAllocated
```

Tracks the module-level r compat lightmap allocated state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1517)

<a id="global-global-miniquake-render-world-rcompatlightmapbuilders-rcompatlightmapbuilders-src-miniquake-render-world-ml-842221138"></a>
### rCompatLightmapBuilders

```ml
rCompatLightmapBuilders
```

Tracks the module-level r compat lightmap builders state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1610)

<a id="global-global-miniquake-render-world-rcompatlightmapmodified-rcompatlightmapmodified-src-miniquake-render-world-ml-1931057870"></a>
### rCompatLightmapModified

```ml
rCompatLightmapModified
```

Tracks the module-level r compat lightmap modified state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1519)

<a id="global-global-miniquake-render-world-rcompatlightmaprectchange-rcompatlightmaprectchange-src-miniquake-render-world-ml-1938251086"></a>
### rCompatLightmapRectChange

```ml
rCompatLightmapRectChange
```

Tracks the module-level r compat lightmap rect change state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1521)

<a id="global-global-miniquake-render-world-rcompatlightmapscratch-rcompatlightmapscratch-src-miniquake-render-world-ml-1145244158"></a>
### rCompatLightmapScratch

```ml
rCompatLightmapScratch
```

Tracks the module-level r compat lightmap scratch state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1600)

<a id="global-global-miniquake-render-world-rcompatlightplane-rcompatlightplane-src-miniquake-render-world-ml-967374034"></a>
### rCompatLightPlane

```ml
rCompatLightPlane
```

Tracks the module-level r compat light plane state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1553)

<a id="global-global-miniquake-render-world-rcompatlightspot-rcompatlightspot-src-miniquake-render-world-ml-311292126"></a>
### rCompatLightSpot

```ml
rCompatLightSpot
```

Tracks the module-level r compat light spot state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1551)

<a id="global-global-miniquake-render-world-rcompatlightstyles-rcompatlightstyles-src-miniquake-render-world-ml-248469754"></a>
### rCompatLightStyles

```ml
rCompatLightStyles
```

Tracks the module-level r compat light styles state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1483)

<a id="global-global-miniquake-render-world-rcompatmirroralpha-rcompatmirroralpha-src-miniquake-render-world-ml-2113082736"></a>
### rCompatMirrorAlpha

```ml
rCompatMirrorAlpha
```

Tracks the module-level r compat mirror alpha state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1561)

<a id="global-global-miniquake-render-world-rcompatmirrorchain-rcompatmirrorchain-src-miniquake-render-world-ml-189458074"></a>
### rCompatMirrorChain

```ml
rCompatMirrorChain
```

Tracks the module-level r compat mirror chain state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1575)

<a id="global-global-miniquake-render-world-rcompatmirrortexture-rcompatmirrortexture-src-miniquake-render-world-ml-1506068898"></a>
### rCompatMirrorTexture

```ml
rCompatMirrorTexture
```

Tracks the module-level r compat mirror texture state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1573)

<a id="global-global-miniquake-render-world-rcompatmtexrecordcount-rcompatmtexrecordcount-src-miniquake-render-world-ml-1201873550"></a>
### rCompatMtexRecordCount

```ml
rCompatMtexRecordCount
```

Tracks the module-level r compat mtex record count state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1622)

<a id="global-global-miniquake-render-world-rcompatmtexrecordfaces-rcompatmtexrecordfaces-src-miniquake-render-world-ml-950362156"></a>
### rCompatMtexRecordFaces

```ml
rCompatMtexRecordFaces
```

Tracks the module-level r compat mtex record faces state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1618)

<a id="global-global-miniquake-render-world-rcompatmtexrecords-rcompatmtexrecords-src-miniquake-render-world-ml-1064243930"></a>
### rCompatMtexRecords

```ml
rCompatMtexRecords
```

Tracks the module-level r compat mtex records state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1620)

<a id="global-global-miniquake-render-world-rcompatmtexrecordstamp-rcompatmtexrecordstamp-src-miniquake-render-world-ml-1188385174"></a>
### rCompatMtexRecordStamp

```ml
rCompatMtexRecordStamp
```

Tracks the module-level r compat mtex record stamp state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1624)

<a id="global-global-miniquake-render-world-rcompatmtextexturechecked-rcompatmtextexturechecked-src-miniquake-render-world-ml-1511725238"></a>
### rCompatMtexTextureChecked

```ml
rCompatMtexTextureChecked
```

Tracks the module-level r compat mtex texture checked state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1628)

<a id="global-global-miniquake-render-world-rcompatmtextextureids-rcompatmtextextureids-src-miniquake-render-world-ml-732237290"></a>
### rCompatMtexTextureIds

```ml
rCompatMtexTextureIds
```

Tracks the module-level r compat mtex texture ids state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1626)

<a id="global-global-miniquake-render-world-rcompatmultitextureavailable-rcompatmultitextureavailable-src-miniquake-render-world-ml-762206444"></a>
### rCompatMultiTextureAvailable

```ml
rCompatMultiTextureAvailable
```

Tracks the module-level r compat multi texture available state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1541)

<a id="global-global-miniquake-render-world-rcompatmultitextureenabled-rcompatmultitextureenabled-src-miniquake-render-world-ml-1381633816"></a>
### rCompatMultiTextureEnabled

```ml
rCompatMultiTextureEnabled
```

Tracks the module-level r compat multi texture enabled state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1539)

<a id="global-global-miniquake-render-world-rcompatnorefresh-rcompatnorefresh-src-miniquake-render-world-ml-947607538"></a>
### rCompatNoRefresh

```ml
rCompatNoRefresh
```

Tracks the module-level r compat no refresh state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1569)

<a id="global-global-miniquake-render-world-rcompatnovis-rcompatnovis-src-miniquake-render-world-ml-182883304"></a>
### rCompatNoVis

```ml
rCompatNoVis
```

Tracks the module-level r compat no vis state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1497)

<a id="global-global-miniquake-render-world-rcompatrealtime-rcompatrealtime-src-miniquake-render-world-ml-943735818"></a>
### rCompatRealtime

```ml
rCompatRealtime
```

Tracks the module-level r compat realtime state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1489)

<a id="global-global-miniquake-render-world-rcompatrenderer-rcompatrenderer-src-miniquake-render-world-ml-494174730"></a>
### rCompatRenderer

```ml
rCompatRenderer
```

Tracks the module-level r compat renderer state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1469)

<a id="global-global-miniquake-render-world-rcompatsequentialbuilder-rcompatsequentialbuilder-src-miniquake-render-world-ml-663429978"></a>
### rCompatSequentialBuilder

```ml
rCompatSequentialBuilder
```

Tracks the module-level r compat sequential builder state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1614)

<a id="global-global-miniquake-render-world-rcompatsequentialsurfaces-rcompatsequentialsurfaces-src-miniquake-render-world-ml-1900703702"></a>
### rCompatSequentialSurfaces

```ml
rCompatSequentialSurfaces
```

Tracks the module-level r compat sequential surfaces state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1612)

<a id="global-global-miniquake-render-world-rcompatskychain-rcompatskychain-src-miniquake-render-world-ml-176018058"></a>
### rCompatSkyChain

```ml
rCompatSkyChain
```

Tracks the module-level r compat sky chain state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1531)

<a id="global-global-miniquake-render-world-rcompatskytexture-rcompatskytexture-src-miniquake-render-world-ml-1646492466"></a>
### rCompatSkyTexture

```ml
rCompatSkyTexture
```

Tracks the module-level r compat sky texture state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1527)

<a id="global-global-miniquake-render-world-rcompatsurfacebatchkeys-rcompatsurfacebatchkeys-src-miniquake-render-world-ml-692786834"></a>
### rCompatSurfaceBatchKeys

```ml
rCompatSurfaceBatchKeys
```

Tracks the module-level r compat surface batch keys state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1630)

<a id="global-global-miniquake-render-world-rcompatsurfacecacheddlight-rcompatsurfacecacheddlight-src-miniquake-render-world-ml-1981216000"></a>
### rCompatSurfaceCachedDlight

```ml
rCompatSurfaceCachedDlight
```

Tracks the module-level r compat surface cached dlight state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1509)

<a id="global-global-miniquake-render-world-rcompatsurfacecachedlight-rcompatsurfacecachedlight-src-miniquake-render-world-ml-1924607826"></a>
### rCompatSurfaceCachedLight

```ml
rCompatSurfaceCachedLight
```

Tracks the module-level r compat surface cached light state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1507)

<a id="global-global-miniquake-render-world-rcompatsurfacedlightbits-rcompatsurfacedlightbits-src-miniquake-render-world-ml-2027330012"></a>
### rCompatSurfaceDlightBits

```ml
rCompatSurfaceDlightBits
```

Tracks the module-level r compat surface dlight bits state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1499)

<a id="global-global-miniquake-render-world-rcompatsurfacedlightframe-rcompatsurfacedlightframe-src-miniquake-render-world-ml-914627834"></a>
### rCompatSurfaceDlightFrame

```ml
rCompatSurfaceDlightFrame
```

Tracks the module-level r compat surface dlight frame state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1505)

<a id="global-global-miniquake-render-world-rcompatsurfacelightmappage-rcompatsurfacelightmappage-src-miniquake-render-world-ml-1512663090"></a>
### rCompatSurfaceLightmapPage

```ml
rCompatSurfaceLightmapPage
```

Tracks the module-level r compat surface lightmap page state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1511)

<a id="global-global-miniquake-render-world-rcompatsurfacelights-rcompatsurfacelights-src-miniquake-render-world-ml-1867682650"></a>
### rCompatSurfaceLightS

```ml
rCompatSurfaceLightS
```

Tracks the module-level r compat surface light s state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1513)

<a id="global-global-miniquake-render-world-rcompatsurfacelightt-rcompatsurfacelightt-src-miniquake-render-world-ml-1405662324"></a>
### rCompatSurfaceLightT

```ml
rCompatSurfaceLightT
```

Tracks the module-level r compat surface light t state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1515)

<a id="global-global-miniquake-render-world-rcompatsurfacewarppolys-rcompatsurfacewarppolys-src-miniquake-render-world-ml-1491100166"></a>
### rCompatSurfaceWarpPolys

```ml
rCompatSurfaceWarpPolys
```

Tracks the module-level r compat surface warp polys state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1525)

<a id="global-global-miniquake-render-world-rcompattexturechainbuilders-rcompattexturechainbuilders-src-miniquake-render-world-ml-463164278"></a>
### rCompatTextureChainBuilders

```ml
rCompatTextureChainBuilders
```

Tracks the module-level r compat texture chain builders state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1537)

<a id="global-global-miniquake-render-world-rcompattexturechains-rcompattexturechains-src-miniquake-render-world-ml-503700148"></a>
### rCompatTextureChains

```ml
rCompatTextureChains
```

Tracks the module-level r compat texture chains state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1535)

<a id="global-global-miniquake-render-world-rcompattexturesort-rcompattexturesort-src-miniquake-render-world-ml-1126078672"></a>
### rCompatTextureSort

```ml
rCompatTextureSort
```

Tracks the module-level r compat texture sort state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1557)

<a id="global-global-miniquake-render-world-rcompattime-rcompattime-src-miniquake-render-world-ml-522351266"></a>
### rCompatTime

```ml
rCompatTime
```

Tracks the module-level r compat time state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1487)

<a id="global-global-miniquake-render-world-rcompattrickframe-rcompattrickframe-src-miniquake-render-world-ml-32769954"></a>
### rCompatTrickFrame

```ml
rCompatTrickFrame
```

Tracks the module-level r compat trick frame state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1571)

<a id="global-global-miniquake-render-world-rcompatusemultitexture-rcompatusemultitexture-src-miniquake-render-world-ml-1452220380"></a>
### rCompatUseMultitexture

```ml
rCompatUseMultitexture
```

Tracks the module-level r compat use multitexture state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1543)

<a id="global-global-miniquake-render-world-rcompatviewangles-rcompatviewangles-src-miniquake-render-world-ml-2126288462"></a>
### rCompatViewAngles

```ml
rCompatViewAngles
```

Tracks the module-level r compat view angles state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1473)

<a id="global-global-miniquake-render-world-rcompatviewforward-rcompatviewforward-src-miniquake-render-world-ml-1797425682"></a>
### rCompatViewForward

```ml
rCompatViewForward
```

Tracks the module-level r compat view forward state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1475)

<a id="global-global-miniquake-render-world-rcompatvieworigin-rcompatvieworigin-src-miniquake-render-world-ml-837799994"></a>
### rCompatViewOrigin

```ml
rCompatViewOrigin
```

Tracks the module-level r compat view origin state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1471)

<a id="global-global-miniquake-render-world-rcompatviewright-rcompatviewright-src-miniquake-render-world-ml-1405836892"></a>
### rCompatViewRight

```ml
rCompatViewRight
```

Tracks the module-level r compat view right state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1477)

<a id="global-global-miniquake-render-world-rcompatviewup-rcompatviewup-src-miniquake-render-world-ml-153545166"></a>
### rCompatViewUp

```ml
rCompatViewUp
```

Tracks the module-level r compat view up state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1479)

<a id="global-global-miniquake-render-world-rcompatvisiblenoderenderer-rcompatvisiblenoderenderer-src-miniquake-render-world-ml-2032383340"></a>
### rCompatVisibleNodeRenderer

```ml
rCompatVisibleNodeRenderer
```

R_RecursiveWorldNode must not visit BSP branches which contain no PVS surfaces.  GLQuake stores this as node->visframe; MiniQuake keeps the same derived state in a renderer-local byte mask so an unchanged view leaf does not force a complete BSP walk on every displayed frame.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L45)

<a id="global-global-miniquake-render-world-rcompatvisiblenodes-rcompatvisiblenodes-src-miniquake-render-world-ml-1355599122"></a>
### rCompatVisibleNodes

```ml
rCompatVisibleNodes
```

Tracks the module-level r compat visible nodes state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L47)

<a id="global-global-miniquake-render-world-rcompatwarppolys-rcompatwarppolys-src-miniquake-render-world-ml-335858932"></a>
### rCompatWarpPolys

```ml
rCompatWarpPolys
```

Tracks the module-level r compat warp polys state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1523)

<a id="global-global-miniquake-render-world-rcompatwaterchain-rcompatwaterchain-src-miniquake-render-world-ml-317849486"></a>
### rCompatWaterChain

```ml
rCompatWaterChain
```

Tracks the module-level r compat water chain state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1533)

<a id="global-global-miniquake-render-world-rcompatztrick-rcompatztrick-src-miniquake-render-world-ml-1179480782"></a>
### rCompatZTrick

```ml
rCompatZTrick
```

Tracks the module-level r compat z trick state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1565)

<a id="function-function-miniquake-render-world-rebuildvisiblenodes-function-rebuildvisiblenodes-renderer-src-miniquake-render-world-ml-803791287"></a>
### rebuildVisibleNodes

```ml
function rebuildVisibleNodes(renderer)
```

Rebuild the GLQuake-compatible node visibility mask only when the PVS face mask changes.  This moves the complete tree scan from every render frame to the much rarer event of entering a different BSP leaf.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L899)

<a id="function-function-miniquake-render-world-recursivelightpoint-function-recursivelightpoint-nodenumber-start-finish-src-miniquake-render-world-ml-1825117212"></a>
### RecursiveLightPoint

```ml
function RecursiveLightPoint(nodeNumber, start, finish)
```

Implements the `RecursiveLightPoint` operation for `miniquake.render.world` (recursive light point).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `RecursiveLightPoint`. |
| `start` | `dynamic` | — | The start input consumed by `RecursiveLightPoint`. |
| `finish` | `dynamic` | — | The finish input consumed by `RecursiveLightPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L2955)

<a id="function-function-miniquake-render-world-render-function-render-renderer-width-height-origin-angles-src-miniquake-render-world-ml-343576596"></a>
### render

```ml
function render(renderer, width, height, origin, angles)
```

Implements the `render` operation for `miniquake.render.world` (render).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1323)

<a id="function-function-miniquake-render-world-rendermirrorviewport-function-rendermirrorviewport-renderer-width-height-viewrect-origin-angles-dynamiclights-lightstyles-currenttime-realtime-frametime-blend-src-miniquake-render-world-ml-1298453237"></a>
### renderMirrorViewport

```ml
function renderMirrorViewport(renderer, width, height, viewRect, origin, angles, dynamicLights, lightStyles, currentTime, realtime, frameTime, blend)
```

Mirror R_RenderScene pass.  The caller submits reflected entities and particles around this world pass, matching gl_rmain.c's host-owned order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `viewRect` | `dynamic` | — | The view rect input consumed by `renderMirrorViewport`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `dynamicLights` | `dynamic` | — | The dynamic lights input consumed by `renderMirrorViewport`. |
| `lightStyles` | `dynamic` | — | The light styles input consumed by `renderMirrorViewport`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `blend` | `dynamic` | — | The blend input consumed by `renderMirrorViewport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1408)

<a id="function-function-miniquake-render-world-renderviewport-function-renderviewport-renderer-width-height-viewrect-origin-angles-dynamiclights-lightstyles-currenttime-realtime-frametime-blend-src-miniquake-render-world-ml-1912645613"></a>
### renderViewport

```ml
function renderViewport(renderer, width, height, viewRect, origin, angles, dynamicLights, lightStyles, currentTime, realtime, frameTime, blend)
```

Render viewport.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `viewRect` | `dynamic` | — | The view rect input consumed by `renderViewport`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `dynamicLights` | `dynamic` | — | The dynamic lights input consumed by `renderViewport`. |
| `lightStyles` | `dynamic` | — | The light styles input consumed by `renderViewport`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `blend` | `dynamic` | — | The blend input consumed by `renderViewport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1345)

<a id="function-function-miniquake-render-world-setupview-function-setupview-width-height-origin-angles-src-miniquake-render-world-ml-506659419"></a>
### setupView

```ml
function setupView(width, height, origin, angles)
```

Update module state for up view.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1086)

<a id="function-function-miniquake-render-world-setupviewrect-function-setupviewrect-viewx-viewy-width-height-screenwidth-screenheight-fovx-fovy-origin-angles-src-miniquake-render-world-ml-138837780"></a>
### setupViewRect

```ml
function setupViewRect(viewX, viewY, width, height, screenWidth, screenHeight, fovX, fovY, origin, angles)
```

Update module state for up view rect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewX` | `dynamic` | — | The view x input consumed by `setupViewRect`. |
| `viewY` | `dynamic` | — | The view y input consumed by `setupViewRect`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `screenWidth` | `dynamic` | — | The screen width input consumed by `setupViewRect`. |
| `screenHeight` | `dynamic` | — | The screen height input consumed by `setupViewRect`. |
| `fovX` | `dynamic` | — | The fov x input consumed by `setupViewRect`. |
| `fovY` | `dynamic` | — | The fov y input consumed by `setupViewRect`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1292)

<a id="global-global-miniquake-render-world-skychain-skychain-src-miniquake-render-world-ml-728980602"></a>
### skychain

```ml
skychain
```

Tracks the module-level skychain state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1606)

<a id="global-global-miniquake-render-world-skytexturenum-skytexturenum-src-miniquake-render-world-ml-446584722"></a>
### skytexturenum

```ml
skytexturenum
```

Original MiniQuake globals retained under their public names.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1580)

<a id="global-global-miniquake-render-world-solidskytexture-solidskytexture-src-miniquake-render-world-ml-534917674"></a>
### solidskytexture

```ml
solidskytexture
```

Tracks the module-level solidskytexture state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1644)

<a id="global-global-miniquake-render-world-speedscale-speedscale-src-miniquake-render-world-ml-89774012"></a>
### speedscale

```ml
speedscale
```

Tracks the module-level speedscale state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1642)

<a id="function-function-miniquake-render-world-standalonemodelorigin-function-standalonemodelorigin-vieworigin-entity-src-miniquake-render-world-ml-1930374398"></a>
### standaloneModelOrigin

```ml
function standaloneModelOrigin(viewOrigin, entity)
```

Return standalone model origin derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `standaloneModelOrigin`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L559)

<a id="function-function-miniquake-render-world-standalonesurfacefacesviewer-function-standalonesurfacefacesviewer-surface-distance-src-miniquake-render-world-ml-1069834844"></a>
### standaloneSurfaceFacesViewer

```ml
function standaloneSurfaceFacesViewer(surface, distance)
```

Implements the `standaloneSurfaceFacesViewer` operation for `miniquake.render.world` (standalone surface faces viewer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surface` | `dynamic` | — | The surface input consumed by `standaloneSurfaceFacesViewer`. |
| `distance` | `dynamic` | — | The distance input consumed by `standaloneSurfaceFacesViewer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L573)

<a id="function-function-miniquake-render-world-standalonetextureid-function-standalonetextureid-renderer-surface-currenttime-alternate-src-miniquake-render-world-ml-1820297158"></a>
### standaloneTextureId

```ml
function standaloneTextureId(renderer, surface, currentTime, alternate)
```

Implements the `standaloneTextureId` operation for `miniquake.render.world` (standalone texture id).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `surface` | `dynamic` | — | The surface input consumed by `standaloneTextureId`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `alternate` | `dynamic` | — | The alternate input consumed by `standaloneTextureId`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L541)

<a id="function-function-miniquake-render-world-startswith-function-startswith-text-prefix-src-miniquake-render-world-ml-1131259483"></a>
### startsWith

```ml
function startsWith(text, prefix)
```

Starts s with for `miniquake.render.world`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `prefix` | `dynamic` | — | The prefix input consumed by `startsWith`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L52)

<a id="function-function-miniquake-render-world-subdividepolygon-function-subdividepolygon-numverts-vertices-src-miniquake-render-world-ml-642456211"></a>
### SubdividePolygon

```ml
function SubdividePolygon(numverts, vertices)
```

Implements the `SubdividePolygon` operation for `miniquake.render.world` (subdivide polygon).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numverts` | `dynamic` | — | The numverts input consumed by `SubdividePolygon`. |
| `vertices` | `dynamic` | — | The vertices input consumed by `SubdividePolygon`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L4234)

<a id="function-function-miniquake-render-world-textureflags-function-textureflags-texturename-faceside-src-miniquake-render-world-ml-387929134"></a>
### textureFlags

```ml
function textureFlags(textureName, faceSide)
```

Implements the `textureFlags` operation for `miniquake.render.world` (texture flags).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textureName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `faceSide` | `dynamic` | — | The face side input consumed by `textureFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L166)

<a id="function-function-miniquake-render-world-textureidforsurface-function-textureidforsurface-renderer-surface-src-miniquake-render-world-ml-289132318"></a>
### textureIdForSurface

```ml
function textureIdForSurface(renderer, surface)
```

Implements the `textureIdForSurface` operation for `miniquake.render.world` (texture id for surface).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `surface` | `dynamic` | — | The surface input consumed by `textureIdForSurface`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1024)

<a id="function-function-miniquake-render-world-upload-function-upload-renderer-src-miniquake-render-world-ml-556830775"></a>
### upload

```ml
function upload(renderer)
```

Upload the requested value to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L400)

<a id="function-function-miniquake-render-world-uploadpixels-function-uploadpixels-width-height-rgba-nearest-src-miniquake-render-world-ml-1731485389"></a>
### uploadPixels

```ml
function uploadPixels(width, height, rgba, nearest)
```

Upload pixels to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `rgba` | `dynamic` | — | The rgba input consumed by `uploadPixels`. |
| `nearest` | `dynamic` | — | The nearest input consumed by `uploadPixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L150)

<a id="function-function-miniquake-render-world-uploadstandalonebrush-function-uploadstandalonebrush-renderer-src-miniquake-render-world-ml-674515519"></a>
### uploadStandaloneBrush

```ml
function uploadStandaloneBrush(renderer)
```

Upload standalone brush to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L502)

<a id="function-function-miniquake-render-world-viewcontents-function-viewcontents-renderer-vieworigin-src-miniquake-render-world-ml-2000064474"></a>
### ViewContents

```ml
function ViewContents(renderer, viewOrigin)
```

R_SetupFrame assigns r_viewleaf from the final (possibly chase-adjusted) r_refdef.vieworg before it selects the contents cshift.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `ViewContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1014)

<a id="global-global-miniquake-render-world-visiblefacecountleaf-visiblefacecountleaf-src-miniquake-render-world-ml-885885234"></a>
### visibleFaceCountLeaf

```ml
visibleFaceCountLeaf
```

Tracks the module-level visible face count leaf state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L38)

<a id="global-global-miniquake-render-world-visiblefacecountrenderer-visiblefacecountrenderer-src-miniquake-render-world-ml-918954468"></a>
### visibleFaceCountRenderer

```ml
visibleFaceCountRenderer
```

Tracks the module-level visible face count renderer state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L36)

<a id="global-global-miniquake-render-world-visiblefacecountvalue-visiblefacecountvalue-src-miniquake-render-world-ml-1725903458"></a>
### visibleFaceCountValue

```ml
visibleFaceCountValue
```

Tracks the module-level visible face count value state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L40)

<a id="global-global-miniquake-render-world-waterchain-waterchain-src-miniquake-render-world-ml-315707110"></a>
### waterchain

```ml
waterchain
```

Tracks the module-level waterchain state owned by `miniquake.render.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L1608)

<a id="global-global-miniquake-render-world-worldsurfaceroots-worldsurfaceroots-src-miniquake-render-world-ml-1830170598"></a>
### worldSurfaceRoots

```ml
worldSurfaceRoots
```

The generated collector scans package globals directly.  Keep the active surface graph in such a root because reaching it only through GameSession -> WorldRenderer -> surfaces is not reliable across allocations performed while the entity renderer is built.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/world.ml#L32)
