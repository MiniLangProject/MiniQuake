# `src/miniquake/render/gl_test.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl_test`](Package-miniquake-render-gl-test-746726417.md)

Reachable from entry: **no**

## Imports

- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-render-gl-test-createstate-function-createstate-src-miniquake-render-gl-test-ml-1974201368"></a>
### createState

```ml
function createState()
```

Creates state for `miniquake.render.gl_test`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L73)

<a id="function-function-miniquake-render-gl-test-drawpuff-function-drawpuff-puff-src-miniquake-render-gl-test-ml-1699429611"></a>
### DrawPuff

```ml
function DrawPuff(puff)
```

Render puff.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `puff` | `dynamic` | — | The puff input consumed by `DrawPuff`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L193)

<a id="function-function-miniquake-render-gl-test-emitvertex-function-emitvertex-point-drawnative-src-miniquake-render-gl-test-ml-2111161865"></a>
### emitVertex

```ml
function emitVertex(point, drawNative)
```

Add vertex to the destination state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `emitVertex`. |
| `drawNative` | `dynamic` | — | The draw native input consumed by `emitVertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L186)

<a id="function-function-miniquake-render-gl-test-emptyplane-function-emptyplane-src-miniquake-render-gl-test-ml-1581221214"></a>
### emptyPlane

```ml
function emptyPlane()
```

Implements the `emptyPlane` operation for `miniquake.render.gl_test` (empty plane).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L63)

<a id="function-function-miniquake-render-gl-test-emptypuff-function-emptypuff-src-miniquake-render-gl-test-ml-1368472386"></a>
### emptyPuff

```ml
function emptyPuff()
```

Implements the `emptyPuff` operation for `miniquake.render.gl_test` (empty puff).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L68)

- [miniquake.render.gl_test.GlTestState](Type-miniquake-render-gl-test-glteststate-1896572099.md) — struct
<a id="function-function-miniquake-render-gl-test-hitplane-function-hitplane-start-finish-src-miniquake-render-gl-test-ml-1982950485"></a>
### HitPlane

```ml
function HitPlane(start, finish)
```

Implements the `HitPlane` operation for `miniquake.render.gl_test` (hit plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start` | `dynamic` | — | The start input consumed by `HitPlane`. |
| `finish` | `dynamic` | — | The finish input consumed by `HitPlane`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L127)

<a id="constant-constant-miniquake-render-gl-test-max-puffs-const-max-puffs-64-src-miniquake-render-gl-test-ml-1191606395"></a>
### MAX_PUFFS

```ml
const MAX_PUFFS = 64
```

Defines the max puffs value used by `miniquake.render.gl_test`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L16)

<a id="function-function-miniquake-render-gl-test-puffpoints-function-puffpoints-puff-src-miniquake-render-gl-test-ml-190590187"></a>
### puffPoints

```ml
function puffPoints(puff)
```

Implements the `puffPoints` operation for `miniquake.render.gl_test` (puff points).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `puff` | `dynamic` | — | The puff input consumed by `puffPoints`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L167)

<a id="function-function-miniquake-render-gl-test-test-commandtrace-function-test-commandtrace-src-miniquake-render-gl-test-ml-1034618176"></a>
### Test_CommandTrace

```ml
function Test_CommandTrace()
```

Verify command trace against the expected Quake behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L235)

<a id="function-function-miniquake-render-gl-test-test-configure-function-test-configure-worldmap-vieworigin-frametime-drawnative-src-miniquake-render-gl-test-ml-1854229142"></a>
### Test_Configure

```ml
function Test_Configure(worldMap, viewOrigin, frameTime, drawNative)
```

Verify configure against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldMap` | `dynamic` | — | The world map input consumed by `Test_Configure`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `Test_Configure`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `drawNative` | `dynamic` | — | The draw native input consumed by `Test_Configure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L103)

<a id="function-function-miniquake-render-gl-test-test-draw-function-test-draw-src-miniquake-render-gl-test-ml-581556340"></a>
### Test_Draw

```ml
function Test_Draw()
```

Verify draw against the expected Quake behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L222)

<a id="function-function-miniquake-render-gl-test-test-init-function-test-init-src-miniquake-render-gl-test-ml-1905265620"></a>
### Test_Init

```ml
function Test_Init()
```

Verify init against the expected Quake behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L113)

<a id="function-function-miniquake-render-gl-test-test-spawn-function-test-spawn-origin-src-miniquake-render-gl-test-ml-354209840"></a>
### Test_Spawn

```ml
function Test_Spawn(origin)
```

Verify spawn against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L138)

<a id="function-function-miniquake-render-gl-test-test-state-function-test-state-src-miniquake-render-gl-test-ml-560853266"></a>
### Test_State

```ml
function Test_State()
```

Verify state against the expected Quake behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L92)

<a id="function-function-miniquake-render-gl-test-test-usestate-function-test-usestate-state-src-miniquake-render-gl-test-ml-1799081957"></a>
### Test_UseState

```ml
function Test_UseState(state)
```

Verify use state against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.render.gl_test` state used by `Test_UseState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L85)

- [miniquake.render.gl_test.TestPuff](Type-miniquake-render-gl-test-testpuff-2080932482.md) — struct
<a id="global-global-miniquake-render-gl-test-teststate-teststate-src-miniquake-render-gl-test-ml-1670139754"></a>
### testState

```ml
testState
```

Tracks the module-level renderer test state owned by `miniquake.render.gl_test`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L55)

<a id="function-function-miniquake-render-gl-test-zerovector-function-zerovector-src-miniquake-render-gl-test-ml-1735678670"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.render.gl_test` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_test.ml#L58)
