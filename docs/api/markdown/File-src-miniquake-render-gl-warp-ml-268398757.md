# `src/miniquake/render/gl_warp.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl_warp`](Package-miniquake-render-gl-warp-411429483.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-render-gl-warp-boundpoly-function-boundpoly-vertices-src-miniquake-render-gl-warp-ml-1246382263"></a>
### BoundPoly

```ml
function BoundPoly(vertices)
```

Implements the `BoundPoly` operation for `miniquake.render.gl_warp` (bound poly).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `BoundPoly`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L100)

<a id="function-function-miniquake-render-gl-warp-currentsubdividesize-function-currentsubdividesize-src-miniquake-render-gl-warp-ml-609408242"></a>
### CurrentSubdivideSize

```ml
function CurrentSubdivideSize()
```

Return subdivide size.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L49)

<a id="constant-constant-miniquake-render-gl-warp-default-subdivide-size-const-default-subdivide-size-128-src-miniquake-render-gl-warp-ml-1657487176"></a>
### DEFAULT_SUBDIVIDE_SIZE

```ml
const DEFAULT_SUBDIVIDE_SIZE = 128.
```

Defines the default subdivide size value used by `miniquake.render.gl_warp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L22)

<a id="function-function-miniquake-render-gl-warp-emitbothskylayers-function-emitbothskylayers-polygons-vieworigin-realtime-src-miniquake-render-gl-warp-ml-131719435"></a>
### EmitBothSkyLayers

```ml
function EmitBothSkyLayers(polygons, viewOrigin, realtime)
```

Add both sky layers to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `polygons` | `dynamic` | — | The polygons input consumed by `EmitBothSkyLayers`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `EmitBothSkyLayers`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L365)

<a id="function-function-miniquake-render-gl-warp-emitskypolys-function-emitskypolys-polygons-vieworigin-currentspeedscale-src-miniquake-render-gl-warp-ml-716726238"></a>
### EmitSkyPolys

```ml
function EmitSkyPolys(polygons, viewOrigin, currentSpeedScale)
```

Add sky polys to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `polygons` | `dynamic` | — | The polygons input consumed by `EmitSkyPolys`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `EmitSkyPolys`. |
| `currentSpeedScale` | `dynamic` | — | The current speed scale input consumed by `EmitSkyPolys`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L338)

<a id="function-function-miniquake-render-gl-warp-emitwaterpolys-function-emitwaterpolys-polygons-realtime-src-miniquake-render-gl-warp-ml-701081724"></a>
### EmitWaterPolys

```ml
function EmitWaterPolys(polygons, realtime)
```

Add water polys to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `polygons` | `dynamic` | — | The polygons input consumed by `EmitWaterPolys`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L282)

<a id="function-function-miniquake-render-gl-warp-floorvalue-function-floorvalue-value-src-miniquake-render-gl-warp-ml-1910674011"></a>
### floorValue

```ml
function floorValue(value)
```

Implements the `floorValue` operation for `miniquake.render.gl_warp` (floor value).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floorValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L92)

<a id="global-global-miniquake-render-gl-warp-gl-subdivide-size-gl-subdivide-size-src-miniquake-render-gl-warp-ml-1064150758"></a>
### gl_subdivide_size

```ml
gl_subdivide_size
```

gl_model.c owns this archived cvar in MiniQuake.  Keep its current numeric value at the warp boundary so every subdivision path observes changes made through the console instead of baking the default into generated polygons.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L29)

<a id="function-function-miniquake-render-gl-warp-gl-subdividesurface-function-gl-subdividesurface-vertices-svector-tvector-subdividesize-src-miniquake-render-gl-warp-ml-1613937096"></a>
### GL_SubdivideSurface

```ml
function GL_SubdivideSurface(vertices, sVector, tVector, subdivideSize)
```

Mirror Quake's GL_SubdivideSurface routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `GL_SubdivideSurface`. |
| `sVector` | `dynamic` | — | The s vector input consumed by `GL_SubdivideSurface`. |
| `tVector` | `dynamic` | — | The t vector input consumed by `GL_SubdivideSurface`. |
| `subdivideSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L234)

<a id="function-function-miniquake-render-gl-warp-interpolatedturb-function-interpolatedturb-indexvalue-src-miniquake-render-gl-warp-ml-1559969473"></a>
### InterpolatedTurb

```ml
function InterpolatedTurb(indexValue)
```

Interpolate adjacent entries in GLQuake's canonical turbulence table. This preserves the original wave shape while removing visible 256-step texture coordinate jumps in the optional Enhanced presentation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `indexValue` | `dynamic` | — | The index value input consumed by `InterpolatedTurb`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L256)

<a id="function-function-miniquake-render-gl-warp-interpolatevertex-function-interpolatevertex-first-second-fraction-src-miniquake-render-gl-warp-ml-1536849874"></a>
### interpolateVertex

```ml
function interpolateVertex(first, second, fraction)
```

Implements the `interpolateVertex` operation for `miniquake.render.gl_warp` (interpolate vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `interpolateVertex`. |
| `second` | `dynamic` | — | The second input consumed by `interpolateVertex`. |
| `fraction` | `dynamic` | — | The fraction input consumed by `interpolateVertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L119)

<a id="function-function-miniquake-render-gl-warp-r-drawskychain-function-r-drawskychain-surfacepolygons-vieworigin-realtime-src-miniquake-render-gl-warp-ml-1645983286"></a>
### R_DrawSkyChain

```ml
function R_DrawSkyChain(surfacePolygons, viewOrigin, realtime)
```

Apply the Quake-compatible r draw sky chain behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `surfacePolygons` | `dynamic` | — | The surface polygons input consumed by `R_DrawSkyChain`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `R_DrawSkyChain`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L380)

<a id="function-function-miniquake-render-gl-warp-r-initsky-function-r-initsky-texture-palette-src-miniquake-render-gl-warp-ml-1331374872"></a>
### R_InitSky

```ml
function R_InitSky(texture, palette)
```

Apply the Quake-compatible r init sky behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `palette` | `dynamic` | — | The palette input consumed by `R_InitSky`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L457)

<a id="function-function-miniquake-render-gl-warp-r-initskypixels-function-r-initskypixels-texture-palette-src-miniquake-render-gl-warp-ml-1108737130"></a>
### R_InitSkyPixels

```ml
function R_InitSkyPixels(texture, palette)
```

Apply the Quake-compatible r init sky pixels behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `palette` | `dynamic` | — | The palette input consumed by `R_InitSkyPixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L397)

<a id="function-function-miniquake-render-gl-warp-setsubdividesize-function-setsubdividesize-value-src-miniquake-render-gl-warp-ml-1227442659"></a>
### SetSubdivideSize

```ml
function SetSubdivideSize(value)
```

Update module state for subdivide size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SetSubdivideSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L41)

<a id="function-function-miniquake-render-gl-warp-skytexcoords-function-skytexcoords-position-vieworigin-currentspeedscale-src-miniquake-render-gl-warp-ml-374608730"></a>
### SkyTexCoords

```ml
function SkyTexCoords(position, viewOrigin, currentSpeedScale)
```

Implements the `SkyTexCoords` operation for `miniquake.render.gl_warp` (sky tex coords).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `position` | `dynamic` | — | Position used by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `SkyTexCoords`. |
| `currentSpeedScale` | `dynamic` | — | The current speed scale input consumed by `SkyTexCoords`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L317)

<a id="function-function-miniquake-render-gl-warp-smoothwatertexcoords-function-smoothwatertexcoords-originals-originalt-realtime-src-miniquake-render-gl-warp-ml-641198038"></a>
### SmoothWaterTexCoords

```ml
function SmoothWaterTexCoords(originalS, originalT, realtime)
```

Return smoothly interpolated water coordinates for the Enhanced profile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `originalS` | `dynamic` | — | The original s input consumed by `SmoothWaterTexCoords`. |
| `originalT` | `dynamic` | — | The original t input consumed by `SmoothWaterTexCoords`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L269)

<a id="function-function-miniquake-render-gl-warp-subdividepolygon-function-subdividepolygon-vertices-subdividesize-src-miniquake-render-gl-warp-ml-265026429"></a>
### SubdividePolygon

```ml
function SubdividePolygon(vertices, subdivideSize)
```

Implements the `SubdividePolygon` operation for `miniquake.render.gl_warp` (subdivide polygon).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `SubdividePolygon`. |
| `subdivideSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L195)

<a id="function-function-miniquake-render-gl-warp-subdividerecursive-function-subdividerecursive-vertices-output-subdividesize-src-miniquake-render-gl-warp-ml-1794895460"></a>
### subdivideRecursive

```ml
function subdivideRecursive(vertices, output, subdivideSize)
```

Implements the `subdivideRecursive` operation for `miniquake.render.gl_warp` (subdivide recursive).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `subdivideRecursive`. |
| `output` | `dynamic` | — | Destination collection that receives subdivided polygons. |
| `subdivideSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L139)

<a id="function-function-miniquake-render-gl-warp-surfacewarpvertices-function-surfacewarpvertices-vertices-svector-tvector-src-miniquake-render-gl-warp-ml-82158900"></a>
### SurfaceWarpVertices

```ml
function SurfaceWarpVertices(vertices, sVector, tVector)
```

Implements the `SurfaceWarpVertices` operation for `miniquake.render.gl_warp` (surface warp vertices).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `SurfaceWarpVertices`. |
| `sVector` | `dynamic` | — | The s vector input consumed by `SurfaceWarpVertices`. |
| `tVector` | `dynamic` | — | The t vector input consumed by `SurfaceWarpVertices`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L215)

<a id="constant-constant-miniquake-render-gl-warp-turbscale-const-turbscale-40-7436654315252-src-miniquake-render-gl-warp-ml-1611955946"></a>
### TURBSCALE

```ml
const TURBSCALE = 40.7436654315252
```

Defines the turbscale value used by `miniquake.render.gl_warp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L24)

<a id="global-global-miniquake-render-gl-warp-turbsin-turbsin-src-miniquake-render-gl-warp-ml-1757843670"></a>
### turbsin

```ml
turbsin
```

Exact table from gl_warp_sin.h.  Looking up this table, rather than calling sin at render time, is observable in texture-coordinate command traces.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L55)

<a id="function-function-miniquake-render-gl-warp-warpfloat-function-warpfloat-value-src-miniquake-render-gl-warp-ml-158788755"></a>
### warpFloat

```ml
function warpFloat(value)
```

gl_warp.c stores all polygon, direction, and texture-coordinate values in float fields. Explicitly cross the IEEE-754 binary32 boundary at the same assignments so the MiniLang backend cannot retain additional precision.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `warpFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L35)

<a id="function-function-miniquake-render-gl-warp-watertexcoords-function-watertexcoords-originals-originalt-realtime-src-miniquake-render-gl-warp-ml-471264666"></a>
### WaterTexCoords

```ml
function WaterTexCoords(originalS, originalT, realtime)
```

Implements the `WaterTexCoords` operation for `miniquake.render.gl_warp` (water tex coords).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `originalS` | `dynamic` | — | The original s input consumed by `WaterTexCoords`. |
| `originalT` | `dynamic` | — | The original t input consumed by `WaterTexCoords`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L242)

<a id="function-function-miniquake-render-gl-warp-wrappedspeedscale-function-wrappedspeedscale-realtime-speed-src-miniquake-render-gl-warp-ml-155018532"></a>
### WrappedSpeedScale

```ml
function WrappedSpeedScale(realtime, speed)
```

Implements the `WrappedSpeedScale` operation for `miniquake.render.gl_warp` (wrapped speed scale).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `speed` | `dynamic` | — | The speed input consumed by `WrappedSpeedScale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_warp.ml#L308)
