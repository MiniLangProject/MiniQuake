# `src/miniquake/render/special_paths.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.special_paths`](Package-miniquake-render-special-paths-1299604773.md)

Reachable from entry: **yes**

## Imports

- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-render-special-paths-clearplan-function-clearplan-mirroralpha-clearcolor-ztrick-trickframe-src-miniquake-render-special-paths-ml-230940064"></a>
### clearPlan

```ml
function clearPlan(mirrorAlpha, clearColor, zTrick, trickFrame)
```

Update module state for plan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mirrorAlpha` | `dynamic` | — | The mirror alpha input consumed by `clearPlan`. |
| `clearColor` | `dynamic` | — | The clear color input consumed by `clearPlan`. |
| `zTrick` | `dynamic` | — | The z trick input consumed by `clearPlan`. |
| `trickFrame` | `dynamic` | — | The trick frame input consumed by `clearPlan`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L129)

<a id="function-function-miniquake-render-special-paths-directionangles-function-directionangles-direction-sourceroll-src-miniquake-render-special-paths-ml-1821557147"></a>
### directionAngles

```ml
function directionAngles(direction, sourceRoll)
```

Return direction angles derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `directionAngles`. |
| `sourceRoll` | `dynamic` | — | The source roll input consumed by `directionAngles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L95)

<a id="constant-constant-miniquake-render-special-paths-envmap-faces-const-envmap-faces-6-src-miniquake-render-special-paths-ml-1515359399"></a>
### ENVMAP_FACES

```ml
const ENVMAP_FACES = 6
```

Defines the envmap faces value used by `miniquake.render.special_paths`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L23)

<a id="constant-constant-miniquake-render-special-paths-envmap-size-const-envmap-size-256-src-miniquake-render-special-paths-ml-1448205278"></a>
### ENVMAP_SIZE

```ml
const ENVMAP_SIZE = 256
```

Defines the envmap size value used by `miniquake.render.special_paths`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L21)

<a id="function-function-miniquake-render-special-paths-envmapbytecount-function-envmapbytecount-src-miniquake-render-special-paths-ml-660406150"></a>
### envmapByteCount

```ml
function envmapByteCount()
```

Return envmap byte count derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L160)

<a id="function-function-miniquake-render-special-paths-envmapdirections-function-envmapdirections-src-miniquake-render-special-paths-ml-1240609558"></a>
### envmapDirections

```ml
function envmapDirections()
```

Implements the `envmapDirections` operation for `miniquake.render.special_paths` (envmap directions).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L148)

<a id="function-function-miniquake-render-special-paths-envmapfilename-function-envmapfilename-index-src-miniquake-render-special-paths-ml-854500396"></a>
### envmapFileName

```ml
function envmapFileName(index)
```

Return envmap file name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L166)

<a id="function-function-miniquake-render-special-paths-f32-function-f32-value-src-miniquake-render-special-paths-ml-70100489"></a>
### f32

```ml
function f32(value)
```

Read an IEEE-754 single-precision value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `f32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L29)

<a id="function-function-miniquake-render-special-paths-findmirrortexture-function-findmirrortexture-textures-src-miniquake-render-special-paths-ml-1171251040"></a>
### findMirrorTexture

```ml
function findMirrorTexture(textures)
```

Return mirror texture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textures` | `dynamic` | — | The textures input consumed by `findMirrorTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L49)

<a id="constant-constant-miniquake-render-special-paths-mirror-texture-prefix-const-mirror-texture-prefix-window02-1-src-miniquake-render-special-paths-ml-889134963"></a>
### MIRROR_TEXTURE_PREFIX

```ml
const MIRROR_TEXTURE_PREFIX = "window02_1"
```

Defines the mirror texture prefix value used by `miniquake.render.special_paths`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L19)

<a id="function-function-miniquake-render-special-paths-mirrordistance-function-mirrordistance-point-normal-distance-src-miniquake-render-special-paths-ml-372349230"></a>
### mirrorDistance

```ml
function mirrorDistance(point, normal, distance)
```

Implements the `mirrorDistance` operation for `miniquake.render.special_paths` (mirror distance).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `mirrorDistance`. |
| `normal` | `dynamic` | — | The normal input consumed by `mirrorDistance`. |
| `distance` | `dynamic` | — | The distance input consumed by `mirrorDistance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L63)

<a id="function-function-miniquake-render-special-paths-mirrorprojectionscale-function-mirrorprojectionscale-plane-src-miniquake-render-special-paths-ml-1434445862"></a>
### mirrorProjectionScale

```ml
function mirrorProjectionScale(plane)
```

Implements the `mirrorProjectionScale` operation for `miniquake.render.special_paths` (mirror projection scale).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `mirrorProjectionScale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L118)

<a id="function-function-miniquake-render-special-paths-mirrortexturename-function-mirrortexturename-name-src-miniquake-render-special-paths-ml-1818204785"></a>
### mirrorTextureName

```ml
function mirrorTextureName(name)
```

Return mirror texture name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L35)

<a id="function-function-miniquake-render-special-paths-reflectpoint-function-reflectpoint-point-normal-distance-src-miniquake-render-special-paths-ml-156249758"></a>
### reflectPoint

```ml
function reflectPoint(point, normal, distance)
```

Implements the `reflectPoint` operation for `miniquake.render.special_paths` (reflect point).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `reflectPoint`. |
| `normal` | `dynamic` | — | The normal input consumed by `reflectPoint`. |
| `distance` | `dynamic` | — | The distance input consumed by `reflectPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L71)

<a id="function-function-miniquake-render-special-paths-reflectvector-function-reflectvector-direction-normal-src-miniquake-render-special-paths-ml-1699106354"></a>
### reflectVector

```ml
function reflectVector(direction, normal)
```

Return reflect vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `reflectVector`. |
| `normal` | `dynamic` | — | The normal input consumed by `reflectVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L83)

<a id="function-function-miniquake-render-special-paths-reflectview-function-reflectview-origin-angles-plane-src-miniquake-render-special-paths-ml-293943760"></a>
### reflectView

```ml
function reflectView(origin, angles, plane)
```

Implements the `reflectView` operation for `miniquake.render.special_paths` (reflect view).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `plane` | `dynamic` | — | The plane input consumed by `reflectView`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L107)

<a id="function-function-miniquake-render-special-paths-specialrenderstageorder-function-specialrenderstageorder-src-miniquake-render-special-paths-ml-74190268"></a>
### specialRenderStageOrder

```ml
function specialRenderStageOrder()
```

Implements the `specialRenderStageOrder` operation for `miniquake.render.special_paths` (special render stage order).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L198)

<a id="constant-constant-miniquake-render-special-paths-timerefresh-steps-const-timerefresh-steps-128-src-miniquake-render-special-paths-ml-668941398"></a>
### TIMEREFRESH_STEPS

```ml
const TIMEREFRESH_STEPS = 128
```

Defines the timerefresh steps value used by `miniquake.render.special_paths`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L25)

<a id="function-function-miniquake-render-special-paths-timerefreshangles-function-timerefreshangles-sourceangles-src-miniquake-render-special-paths-ml-1712140261"></a>
### timeRefreshAngles

```ml
function timeRefreshAngles(sourceAngles)
```

Return time refresh angles derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sourceAngles` | `dynamic` | — | The source angles input consumed by `timeRefreshAngles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L186)

<a id="function-function-miniquake-render-special-paths-timerefreshresult-function-timerefreshresult-seconds-src-miniquake-render-special-paths-ml-1864753785"></a>
### timeRefreshResult

```ml
function timeRefreshResult(seconds)
```

Implements the `timeRefreshResult` operation for `miniquake.render.special_paths` (time refresh result).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `seconds` | `dynamic` | — | The seconds input consumed by `timeRefreshResult`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L178)

<a id="function-function-miniquake-render-special-paths-timerefreshyaw-function-timerefreshyaw-index-src-miniquake-render-special-paths-ml-1026578336"></a>
### timeRefreshYaw

```ml
function timeRefreshYaw(index)
```

Implements the `timeRefreshYaw` operation for `miniquake.render.special_paths` (time refresh yaw).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/special_paths.ml#L172)
