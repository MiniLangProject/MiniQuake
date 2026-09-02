# `src/miniquake/render/gl_rmain.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl_rmain`](Package-miniquake-render-gl-rmain-1638545588.md)

Reachable from entry: **no**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-render-gl-rmain-add-function-add-left-right-src-miniquake-render-gl-rmain-ml-273534779"></a>
### Add

```ml
function Add(left, right)
```

Add state for add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `Add`. |
| `right` | `dynamic` | — | The right input consumed by `Add`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L278)

<a id="function-function-miniquake-render-gl-rmain-bind-function-bind-texture-src-miniquake-render-gl-rmain-ml-562424363"></a>
### Bind

```ml
function Bind(texture)
```

Implements the `Bind` operation for `miniquake.render.gl_rmain` (bind).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L212)

<a id="global-global-miniquake-render-gl-rmain-blendcolor-blendcolor-src-miniquake-render-gl-rmain-ml-1498786688"></a>
### blendColor

```ml
blendColor
```

Tracks the module-level blend color state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L135)

<a id="function-function-miniquake-render-gl-rmain-boxonplaneside-function-boxonplaneside-mins-maxs-plane-src-miniquake-render-gl-rmain-ml-807114500"></a>
### BoxOnPlaneSide

```ml
function BoxOnPlaneSide(mins, maxs, plane)
```

Implements the `BoxOnPlaneSide` operation for `miniquake.render.gl_rmain` (box on plane side).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `BoxOnPlaneSide`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `BoxOnPlaneSide`. |
| `plane` | `dynamic` | — | The plane input consumed by `BoxOnPlaneSide`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L305)

<a id="global-global-miniquake-render-gl-rmain-c-alias-polys-c-alias-polys-src-miniquake-render-gl-rmain-ml-138964500"></a>
### c_alias_polys

```ml
c_alias_polys
```

Tracks the module-level c alias polys state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L111)

<a id="global-global-miniquake-render-gl-rmain-c-brush-polys-c-brush-polys-src-miniquake-render-gl-rmain-ml-540171876"></a>
### c_brush_polys

```ml
c_brush_polys
```

Tracks the module-level c brush polys state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L109)

<a id="function-function-miniquake-render-gl-rmain-clear-function-clear-mask-src-miniquake-render-gl-rmain-ml-826086322"></a>
### Clear

```ml
function Clear(mask)
```

Implements the `Clear` operation for `miniquake.render.gl_rmain` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mask` | `dynamic` | — | The mask input consumed by `Clear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L248)

<a id="global-global-miniquake-render-gl-rmain-clearcolor-clearcolor-src-miniquake-render-gl-rmain-ml-1025286164"></a>
### clearColor

```ml
clearColor
```

Tracks the module-level clear color state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L129)

<a id="function-function-miniquake-render-gl-rmain-depthfunc-function-depthfunc-value-src-miniquake-render-gl-rmain-ml-827688443"></a>
### DepthFunc

```ml
function DepthFunc(value)
```

Implements the `DepthFunc` operation for `miniquake.render.gl_rmain` (depth func).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `DepthFunc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L240)

<a id="function-function-miniquake-render-gl-rmain-depthrange-function-depthrange-minimum-maximum-src-miniquake-render-gl-rmain-ml-139590906"></a>
### DepthRange

```ml
function DepthRange(minimum, maximum)
```

Implements the `DepthRange` operation for `miniquake.render.gl_rmain` (depth range).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L231)

<a id="function-function-miniquake-render-gl-rmain-dot-inline-function-dot-left-right-src-miniquake-render-gl-rmain-ml-1049485438"></a>
### Dot

```ml
inline function Dot(left, right)
```

Implements the `Dot` operation for `miniquake.render.gl_rmain` (dot).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `Dot`. |
| `right` | `dynamic` | — | The right input consumed by `Dot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L265)

<a id="function-function-miniquake-render-gl-rmain-f32-function-f32-value-src-miniquake-render-gl-rmain-ml-970029167"></a>
### F32

```ml
function F32(value)
```

Implements the `F32` operation for `miniquake.render.gl_rmain` (f32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `F32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L271)

<a id="global-global-miniquake-render-gl-rmain-frustum-frustum-src-miniquake-render-gl-rmain-ml-1065470548"></a>
### frustum

```ml
frustum
```

Tracks the module-level frustum state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L89)

<a id="function-function-miniquake-render-gl-rmain-getframestate-function-getframestate-src-miniquake-render-gl-rmain-ml-762771288"></a>
### GetFrameState

```ml
function GetFrameState()
```

Return frame state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L844)

<a id="function-function-miniquake-render-gl-rmain-getsinkstate-function-getsinkstate-src-miniquake-render-gl-rmain-ml-1966690824"></a>
### GetSinkState

```ml
function GetSinkState()
```

Return sink state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L255)

<a id="global-global-miniquake-render-gl-rmain-gl-alpha-test-gl-alpha-test-src-miniquake-render-gl-rmain-ml-1614511032"></a>
### GL_ALPHA_TEST

```ml
GL_ALPHA_TEST
```

Direct MiniLang pendant of WinQuake/gl_rmain.c.  Renderer-owned objects are represented as compact arrays here so the complete original control flow can be executed headlessly by the differential oracle.  The live renderer keeps its richer model/entity objects in render/original.ml and render/entities.ml.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L17)

<a id="global-global-miniquake-render-gl-rmain-gl-back-gl-back-src-miniquake-render-gl-rmain-ml-614953744"></a>
### GL_BACK

```ml
GL_BACK
```

Tracks the module-level gl back state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L55)

<a id="global-global-miniquake-render-gl-rmain-gl-blend-gl-blend-src-miniquake-render-gl-rmain-ml-2144460430"></a>
### GL_BLEND

```ml
GL_BLEND
```

Tracks the module-level gl blend state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L19)

<a id="global-global-miniquake-render-gl-rmain-gl-color-buffer-bit-gl-color-buffer-bit-src-miniquake-render-gl-rmain-ml-1508895236"></a>
### GL_COLOR_BUFFER_BIT

```ml
GL_COLOR_BUFFER_BIT
```

Tracks the module-level gl color buffer bit state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L59)

<a id="global-global-miniquake-render-gl-rmain-gl-cull-face-gl-cull-face-src-miniquake-render-gl-rmain-ml-1902492684"></a>
### GL_CULL_FACE

```ml
GL_CULL_FACE
```

Tracks the module-level gl cull face state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L21)

<a id="global-global-miniquake-render-gl-rmain-gl-depth-buffer-bit-gl-depth-buffer-bit-src-miniquake-render-gl-rmain-ml-1162313392"></a>
### GL_DEPTH_BUFFER_BIT

```ml
GL_DEPTH_BUFFER_BIT
```

Tracks the module-level gl depth buffer bit state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L61)

<a id="global-global-miniquake-render-gl-rmain-gl-depth-test-gl-depth-test-src-miniquake-render-gl-rmain-ml-221236516"></a>
### GL_DEPTH_TEST

```ml
GL_DEPTH_TEST
```

Tracks the module-level gl depth test state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L23)

<a id="function-function-miniquake-render-gl-rmain-gl-drawaliasframe-function-gl-drawaliasframe-header-posenum-light-src-miniquake-render-gl-rmain-ml-2120195926"></a>
### GL_DrawAliasFrame

```ml
function GL_DrawAliasFrame(header, posenum, light)
```

Mirror Quake's GL_DrawAliasFrame routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasFrame`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasFrame`. |
| `light` | `dynamic` | — | The light input consumed by `GL_DrawAliasFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L396)

<a id="function-function-miniquake-render-gl-rmain-gl-drawaliasshadow-function-gl-drawaliasshadow-header-posenum-entityorigin-lightspot-vector-src-miniquake-render-gl-rmain-ml-74800264"></a>
### GL_DrawAliasShadow

```ml
function GL_DrawAliasShadow(header, posenum, entityOrigin, lightSpot, vector)
```

Mirror Quake's GL_DrawAliasShadow routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasShadow`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasShadow`. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `GL_DrawAliasShadow`. |
| `lightSpot` | `dynamic` | — | The light spot input consumed by `GL_DrawAliasShadow`. |
| `vector` | `dynamic` | — | The vector input consumed by `GL_DrawAliasShadow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L420)

<a id="global-global-miniquake-render-gl-rmain-gl-fastest-gl-fastest-src-miniquake-render-gl-rmain-ml-529266892"></a>
### GL_FASTEST

```ml
GL_FASTEST
```

Tracks the module-level gl fastest state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L45)

<a id="global-global-miniquake-render-gl-rmain-gl-flat-gl-flat-src-miniquake-render-gl-rmain-ml-2089108564"></a>
### GL_FLAT

```ml
GL_FLAT
```

Tracks the module-level gl flat state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L33)

<a id="global-global-miniquake-render-gl-rmain-gl-front-gl-front-src-miniquake-render-gl-rmain-ml-919563354"></a>
### GL_FRONT

```ml
GL_FRONT
```

Tracks the module-level gl front state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L53)

<a id="global-global-miniquake-render-gl-rmain-gl-gequal-gl-gequal-src-miniquake-render-gl-rmain-ml-453612492"></a>
### GL_GEQUAL

```ml
GL_GEQUAL
```

Tracks the module-level gl gequal state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L65)

<a id="global-global-miniquake-render-gl-rmain-gl-lequal-gl-lequal-src-miniquake-render-gl-rmain-ml-512112868"></a>
### GL_LEQUAL

```ml
GL_LEQUAL
```

Tracks the module-level gl lequal state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L63)

<a id="global-global-miniquake-render-gl-rmain-gl-modelview-gl-modelview-src-miniquake-render-gl-rmain-ml-86322852"></a>
### GL_MODELVIEW

```ml
GL_MODELVIEW
```

Tracks the module-level gl modelview state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L51)

<a id="global-global-miniquake-render-gl-rmain-gl-modelview-matrix-gl-modelview-matrix-src-miniquake-render-gl-rmain-ml-714247128"></a>
### GL_MODELVIEW_MATRIX

```ml
GL_MODELVIEW_MATRIX
```

Tracks the module-level gl modelview matrix state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L57)

<a id="global-global-miniquake-render-gl-rmain-gl-modulate-gl-modulate-src-miniquake-render-gl-rmain-ml-1691211688"></a>
### GL_MODULATE

```ml
GL_MODULATE
```

Tracks the module-level gl modulate state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L39)

<a id="global-global-miniquake-render-gl-rmain-gl-nicest-gl-nicest-src-miniquake-render-gl-rmain-ml-1211703428"></a>
### GL_NICEST

```ml
GL_NICEST
```

Tracks the module-level gl nicest state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L47)

<a id="global-global-miniquake-render-gl-rmain-gl-perspective-correction-hint-gl-perspective-correction-hint-src-miniquake-render-gl-rmain-ml-1136387866"></a>
### GL_PERSPECTIVE_CORRECTION_HINT

```ml
GL_PERSPECTIVE_CORRECTION_HINT
```

Tracks the module-level gl perspective correction hint state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L43)

<a id="global-global-miniquake-render-gl-rmain-gl-projection-gl-projection-src-miniquake-render-gl-rmain-ml-1555344332"></a>
### GL_PROJECTION

```ml
GL_PROJECTION
```

Tracks the module-level gl projection state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L49)

<a id="global-global-miniquake-render-gl-rmain-gl-quads-gl-quads-src-miniquake-render-gl-rmain-ml-1586869036"></a>
### GL_QUADS

```ml
GL_QUADS
```

Tracks the module-level gl quads state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L27)

<a id="global-global-miniquake-render-gl-rmain-gl-replace-gl-replace-src-miniquake-render-gl-rmain-ml-1871456996"></a>
### GL_REPLACE

```ml
GL_REPLACE
```

Tracks the module-level gl replace state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L41)

<a id="global-global-miniquake-render-gl-rmain-gl-smooth-gl-smooth-src-miniquake-render-gl-rmain-ml-1943881572"></a>
### GL_SMOOTH

```ml
GL_SMOOTH
```

Tracks the module-level gl smooth state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L31)

<a id="global-global-miniquake-render-gl-rmain-gl-texture-2d-gl-texture-2d-src-miniquake-render-gl-rmain-ml-1281656252"></a>
### GL_TEXTURE_2D

```ml
GL_TEXTURE_2D
```

Tracks the module-level gl texture 2 d state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L25)

<a id="global-global-miniquake-render-gl-rmain-gl-texture-env-gl-texture-env-src-miniquake-render-gl-rmain-ml-1302375830"></a>
### GL_TEXTURE_ENV

```ml
GL_TEXTURE_ENV
```

Tracks the module-level gl texture env state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L35)

<a id="global-global-miniquake-render-gl-rmain-gl-texture-env-mode-gl-texture-env-mode-src-miniquake-render-gl-rmain-ml-1132587964"></a>
### GL_TEXTURE_ENV_MODE

```ml
GL_TEXTURE_ENV_MODE
```

Tracks the module-level gl texture env mode state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L37)

<a id="global-global-miniquake-render-gl-rmain-gl-triangle-strip-gl-triangle-strip-src-miniquake-render-gl-rmain-ml-102290276"></a>
### GL_TRIANGLE_STRIP

```ml
GL_TRIANGLE_STRIP
```

Tracks the module-level gl triangle strip state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L29)

<a id="global-global-miniquake-render-gl-rmain-gldepthmax-gldepthmax-src-miniquake-render-gl-rmain-ml-2096417596"></a>
### gldepthmax

```ml
gldepthmax
```

Tracks the module-level gldepthmax state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L117)

<a id="global-global-miniquake-render-gl-rmain-gldepthmin-gldepthmin-src-miniquake-render-gl-rmain-ml-1860037676"></a>
### gldepthmin

```ml
gldepthmin
```

Tracks the module-level gldepthmin state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L115)

<a id="global-global-miniquake-render-gl-rmain-lastposenum-lastposenum-src-miniquake-render-gl-rmain-ml-1780649060"></a>
### lastposenum

```ml
lastposenum
```

Tracks the module-level lastposenum state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L113)

<a id="function-function-miniquake-render-gl-rmain-makealiasheader-function-makealiasheader-src-miniquake-render-gl-rmain-ml-690094098"></a>
### MakeAliasHeader

```ml
function MakeAliasHeader()
```

Create and initialize alias header.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L383)

<a id="global-global-miniquake-render-gl-rmain-mirror-mirror-src-miniquake-render-gl-rmain-ml-809175698"></a>
### mirror

```ml
mirror
```

Tracks the module-level mirror state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L123)

<a id="global-global-miniquake-render-gl-rmain-mirroralpha-mirroralpha-src-miniquake-render-gl-rmain-ml-125845564"></a>
### mirrorAlpha

```ml
mirrorAlpha
```

Tracks the module-level mirror alpha state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L127)

<a id="global-global-miniquake-render-gl-rmain-mirrorplane-mirrorplane-src-miniquake-render-gl-rmain-ml-18799164"></a>
### mirrorPlane

```ml
mirrorPlane
```

Tracks the module-level mirror plane state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L125)

<a id="function-function-miniquake-render-gl-rmain-multiplyadd-function-multiplyadd-origin-scale-direction-src-miniquake-render-gl-rmain-ml-535005871"></a>
### MultiplyAdd

```ml
function MultiplyAdd(origin, scale, direction)
```

Implements the `MultiplyAdd` operation for `miniquake.render.gl_rmain` (multiply add).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `scale` | `dynamic` | — | The scale input consumed by `MultiplyAdd`. |
| `direction` | `dynamic` | — | The direction input consumed by `MultiplyAdd`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L293)

<a id="function-function-miniquake-render-gl-rmain-mygluperspective-function-mygluperspective-fovy-aspect-znear-zfar-src-miniquake-render-gl-rmain-ml-1614892257"></a>
### MYgluPerspective

```ml
function MYgluPerspective(fovy, aspect, zNear, zFar)
```

Implements the `MYgluPerspective` operation for `miniquake.render.gl_rmain` (m yglu perspective).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fovy` | `dynamic` | — | The fovy input consumed by `MYgluPerspective`. |
| `aspect` | `dynamic` | — | The aspect input consumed by `MYgluPerspective`. |
| `zNear` | `dynamic` | — | The z near input consumed by `MYgluPerspective`. |
| `zFar` | `dynamic` | — | The z far input consumed by `MYgluPerspective`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L618)

<a id="function-function-miniquake-render-gl-rmain-note-function-note-operation-a-b-c-d-src-miniquake-render-gl-rmain-ml-1233847317"></a>
### Note

```ml
function Note(operation, a, b, c, d)
```

Implements the `Note` operation for `miniquake.render.gl_rmain` (note).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | The operation input consumed by `Note`. |
| `a` | `dynamic` | — | The a input consumed by `Note`. |
| `b` | `dynamic` | — | The b input consumed by `Note`. |
| `c` | `dynamic` | — | The c input consumed by `Note`. |
| `d` | `dynamic` | — | The d input consumed by `Note`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L202)

<a id="function-function-miniquake-render-gl-rmain-prepareworld-function-prepareworld-src-miniquake-render-gl-rmain-ml-487357284"></a>
### PrepareWorld

```ml
function PrepareWorld()
```

Implements the `PrepareWorld` operation for `miniquake.render.gl_rmain` (prepare world).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L831)

<a id="function-function-miniquake-render-gl-rmain-r-clear-function-r-clear-src-miniquake-render-gl-rmain-ml-1048457808"></a>
### R_Clear

```ml
function R_Clear()
```

Apply the Quake-compatible r clear behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L672)

<a id="function-function-miniquake-render-gl-rmain-r-cullbox-function-r-cullbox-mins-maxs-src-miniquake-render-gl-rmain-ml-1076392314"></a>
### R_CullBox

```ml
function R_CullBox(mins, maxs)
```

Apply the Quake-compatible r cull box behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `R_CullBox`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `R_CullBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L317)

<a id="function-function-miniquake-render-gl-rmain-r-drawaliasmodel-function-r-drawaliasmodel-entity-header-time-shadows-src-miniquake-render-gl-rmain-ml-415314552"></a>
### R_DrawAliasModel

```ml
function R_DrawAliasModel(entity, header, time, shadows)
```

Apply the Quake-compatible r draw alias model behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `header` | `dynamic` | — | The header input consumed by `R_DrawAliasModel`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `shadows` | `dynamic` | — | The shadows input consumed by `R_DrawAliasModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L463)

<a id="global-global-miniquake-render-gl-rmain-r-drawentities-r-drawentities-src-miniquake-render-gl-rmain-ml-1392329088"></a>
### r_drawentities

```ml
r_drawentities
```

Tracks the module-level r drawentities state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L119)

<a id="function-function-miniquake-render-gl-rmain-r-drawentitiesonlist-function-r-drawentitiesonlist-brushcount-sprites-src-miniquake-render-gl-rmain-ml-1157125343"></a>
### R_DrawEntitiesOnList

```ml
function R_DrawEntitiesOnList(brushCount, sprites)
```

Apply the Quake-compatible r draw entities on list behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `brushCount` | `dynamic` | — | Number of entries or units to process. |
| `sprites` | `dynamic` | — | The sprites input consumed by `R_DrawEntitiesOnList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L508)

<a id="function-function-miniquake-render-gl-rmain-r-drawspritemodel-function-r-drawspritemodel-entity-frame-src-miniquake-render-gl-rmain-ml-1478779670"></a>
### R_DrawSpriteModel

```ml
function R_DrawSpriteModel(entity, frame)
```

Apply the Quake-compatible r draw sprite model behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `frame` | `dynamic` | — | The frame input consumed by `R_DrawSpriteModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L360)

<a id="function-function-miniquake-render-gl-rmain-r-drawviewmodel-function-r-drawviewmodel-entity-header-time-shadows-src-miniquake-render-gl-rmain-ml-2132910910"></a>
### R_DrawViewModel

```ml
function R_DrawViewModel(entity, header, time, shadows)
```

Apply the Quake-compatible r draw view model behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `header` | `dynamic` | — | The header input consumed by `R_DrawViewModel`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `shadows` | `dynamic` | — | The shadows input consumed by `R_DrawViewModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L526)

<a id="global-global-miniquake-render-gl-rmain-r-drawviewmodel-r-drawviewmodel-src-miniquake-render-gl-rmain-ml-347175916"></a>
### r_drawviewmodel

```ml
r_drawviewmodel
```

Tracks the module-level r drawviewmodel state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L121)

<a id="global-global-miniquake-render-gl-rmain-r-fov-x-r-fov-x-src-miniquake-render-gl-rmain-ml-1750229328"></a>
### r_fov_x

```ml
r_fov_x
```

Tracks the module-level r fov x state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L103)

<a id="global-global-miniquake-render-gl-rmain-r-fov-y-r-fov-y-src-miniquake-render-gl-rmain-ml-326047748"></a>
### r_fov_y

```ml
r_fov_y
```

Tracks the module-level r fov y state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L105)

<a id="global-global-miniquake-render-gl-rmain-r-framecount-r-framecount-src-miniquake-render-gl-rmain-ml-798630482"></a>
### r_framecount

```ml
r_framecount
```

Tracks the module-level r framecount state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L107)

<a id="function-function-miniquake-render-gl-rmain-r-getspriteframe-function-r-getspriteframe-frametype-textures-intervals-time-syncbase-src-miniquake-render-gl-rmain-ml-1897133374"></a>
### R_GetSpriteFrame

```ml
function R_GetSpriteFrame(frameType, textures, intervals, time, syncbase)
```

Apply the Quake-compatible r get sprite frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameType` | `dynamic` | — | The frame type input consumed by `R_GetSpriteFrame`. |
| `textures` | `dynamic` | — | The textures input consumed by `R_GetSpriteFrame`. |
| `intervals` | `dynamic` | — | The intervals input consumed by `R_GetSpriteFrame`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `syncbase` | `dynamic` | — | The syncbase input consumed by `R_GetSpriteFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L344)

<a id="function-function-miniquake-render-gl-rmain-r-mirror-function-r-mirror-src-miniquake-render-gl-rmain-ml-868358100"></a>
### R_Mirror

```ml
function R_Mirror()
```

Apply the Quake-compatible r mirror behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L702)

<a id="global-global-miniquake-render-gl-rmain-r-origin-r-origin-src-miniquake-render-gl-rmain-ml-156963634"></a>
### r_origin

```ml
r_origin
```

Tracks the module-level r origin state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L97)

<a id="function-function-miniquake-render-gl-rmain-r-polyblend-function-r-polyblend-src-miniquake-render-gl-rmain-ml-1548157764"></a>
### R_PolyBlend

```ml
function R_PolyBlend()
```

Apply the Quake-compatible r poly blend behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L536)

<a id="function-function-miniquake-render-gl-rmain-r-renderscene-function-r-renderscene-src-miniquake-render-gl-rmain-ml-1496185890"></a>
### R_RenderScene

```ml
function R_RenderScene()
```

Apply the Quake-compatible r render scene behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L657)

<a id="function-function-miniquake-render-gl-rmain-r-renderview-function-r-renderview-src-miniquake-render-gl-rmain-ml-614891976"></a>
### R_RenderView

```ml
function R_RenderView()
```

Apply the Quake-compatible r render view behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L741)

<a id="function-function-miniquake-render-gl-rmain-r-rotateforentity-function-r-rotateforentity-entity-src-miniquake-render-gl-rmain-ml-589817767"></a>
### R_RotateForEntity

```ml
function R_RotateForEntity(entity)
```

Apply the Quake-compatible r rotate for entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L328)

<a id="function-function-miniquake-render-gl-rmain-r-setfrustum-function-r-setfrustum-src-miniquake-render-gl-rmain-ml-1933347596"></a>
### R_SetFrustum

```ml
function R_SetFrustum()
```

Apply the Quake-compatible r set frustum behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L570)

<a id="function-function-miniquake-render-gl-rmain-r-setupaliasframe-function-r-setupaliasframe-frame-header-time-light-src-miniquake-render-gl-rmain-ml-915318601"></a>
### R_SetupAliasFrame

```ml
function R_SetupAliasFrame(frame, header, time, light)
```

Apply the Quake-compatible r setup alias frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `R_SetupAliasFrame`. |
| `header` | `dynamic` | — | The header input consumed by `R_SetupAliasFrame`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `light` | `dynamic` | — | The light input consumed by `R_SetupAliasFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L450)

<a id="function-function-miniquake-render-gl-rmain-r-setupframe-function-r-setupframe-src-miniquake-render-gl-rmain-ml-585299052"></a>
### R_SetupFrame

```ml
function R_SetupFrame()
```

Apply the Quake-compatible r setup frame behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L596)

<a id="function-function-miniquake-render-gl-rmain-r-setupgl-function-r-setupgl-src-miniquake-render-gl-rmain-ml-504286742"></a>
### R_SetupGL

```ml
function R_SetupGL()
```

Apply the Quake-compatible r setup gl behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L629)

<a id="global-global-miniquake-render-gl-rmain-r-viewangles-r-viewangles-src-miniquake-render-gl-rmain-ml-671358348"></a>
### r_viewangles

```ml
r_viewangles
```

Tracks the module-level r viewangles state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L101)

<a id="global-global-miniquake-render-gl-rmain-r-vieworg-r-vieworg-src-miniquake-render-gl-rmain-ml-351887744"></a>
### r_vieworg

```ml
r_vieworg
```

Tracks the module-level r vieworg state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L99)

<a id="function-function-miniquake-render-gl-rmain-resetcompatibility-function-resetcompatibility-src-miniquake-render-gl-rmain-ml-1793584552"></a>
### ResetCompatibility

```ml
function ResetCompatibility()
```

Update module state for compatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L156)

<a id="function-function-miniquake-render-gl-rmain-resetsink-function-resetsink-src-miniquake-render-gl-rmain-ml-1738495460"></a>
### ResetSink

```ml
function ResetSink()
```

Update module state for sink.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L138)

<a id="function-function-miniquake-render-gl-rmain-setblend-function-setblend-value-src-miniquake-render-gl-rmain-ml-979618533"></a>
### SetBlend

```ml
function SetBlend(value)
```

Update module state for blend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SetBlend`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L761)

<a id="function-function-miniquake-render-gl-rmain-setclearflags-function-setclearflags-alpha-clearvalue-zvalue-src-miniquake-render-gl-rmain-ml-1001703549"></a>
### SetClearFlags

```ml
function SetClearFlags(alpha, clearValue, zValue)
```

Update module state for clear flags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alpha` | `dynamic` | — | The alpha input consumed by `SetClearFlags`. |
| `clearValue` | `dynamic` | — | The clear value input consumed by `SetClearFlags`. |
| `zValue` | `dynamic` | — | The z value input consumed by `SetClearFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L779)

<a id="function-function-miniquake-render-gl-rmain-setcullplanes-function-setcullplanes-planes-src-miniquake-render-gl-rmain-ml-1434012073"></a>
### SetCullPlanes

```ml
function SetCullPlanes(planes)
```

Update module state for cull planes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `planes` | `dynamic` | — | The planes input consumed by `SetCullPlanes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L754)

<a id="function-function-miniquake-render-gl-rmain-setdepthcompatibility-function-setdepthcompatibility-minimum-maximum-src-miniquake-render-gl-rmain-ml-1124713628"></a>
### SetDepthCompatibility

```ml
function SetDepthCompatibility(minimum, maximum)
```

Update module state for depth compatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L823)

<a id="function-function-miniquake-render-gl-rmain-setdrawflags-function-setdrawflags-entities-viewmodel-src-miniquake-render-gl-rmain-ml-1867058855"></a>
### SetDrawFlags

```ml
function SetDrawFlags(entities, viewModel)
```

Update module state for draw flags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entities` | `dynamic` | — | The entities input consumed by `SetDrawFlags`. |
| `viewModel` | `dynamic` | — | The view model input consumed by `SetDrawFlags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L769)

<a id="function-function-miniquake-render-gl-rmain-setframestate-function-setframestate-frame-brushpolys-aliaspolys-src-miniquake-render-gl-rmain-ml-559212925"></a>
### SetFrameState

```ml
function SetFrameState(frame, brushPolys, aliasPolys)
```

Update module state for frame state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `SetFrameState`. |
| `brushPolys` | `dynamic` | — | The brush polys input consumed by `SetFrameState`. |
| `aliasPolys` | `dynamic` | — | The alias polys input consumed by `SetFrameState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L813)

<a id="function-function-miniquake-render-gl-rmain-setmirror-function-setmirror-value-plane-src-miniquake-render-gl-rmain-ml-575104991"></a>
### SetMirror

```ml
function SetMirror(value, plane)
```

Update module state for mirror.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SetMirror`. |
| `plane` | `dynamic` | — | The plane input consumed by `SetMirror`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L789)

<a id="function-function-miniquake-render-gl-rmain-setviewbasis-function-setviewbasis-origin-forward-right-up-src-miniquake-render-gl-rmain-ml-333905554"></a>
### SetViewBasis

```ml
function SetViewBasis(origin, forward, right, up)
```

Update module state for view basis.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `forward` | `dynamic` | — | The forward input consumed by `SetViewBasis`. |
| `right` | `dynamic` | — | The right input consumed by `SetViewBasis`. |
| `up` | `dynamic` | — | The up input consumed by `SetViewBasis`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L800)

<a id="function-function-miniquake-render-gl-rmain-signbitsforplane-function-signbitsforplane-plane-src-miniquake-render-gl-rmain-ml-1899361990"></a>
### SignbitsForPlane

```ml
function SignbitsForPlane(plane)
```

Implements the `SignbitsForPlane` operation for `miniquake.render.gl_rmain` (signbits for plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `SignbitsForPlane`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L561)

<a id="global-global-miniquake-render-gl-rmain-sinkbinds-sinkbinds-src-miniquake-render-gl-rmain-ml-54663984"></a>
### sinkBinds

```ml
sinkBinds
```

Tracks the module-level sink binds state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L76)

<a id="global-global-miniquake-render-gl-rmain-sinkcalls-sinkcalls-src-miniquake-render-gl-rmain-ml-1652480440"></a>
### sinkCalls

```ml
sinkCalls
```

Tracks the module-level sink calls state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L70)

<a id="global-global-miniquake-render-gl-rmain-sinkclearmask-sinkclearmask-src-miniquake-render-gl-rmain-ml-264575672"></a>
### sinkClearMask

```ml
sinkClearMask
```

Tracks the module-level sink clear mask state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L80)

<a id="global-global-miniquake-render-gl-rmain-sinkdepthfunc-sinkdepthfunc-src-miniquake-render-gl-rmain-ml-2053515428"></a>
### sinkDepthFunc

```ml
sinkDepthFunc
```

Tracks the module-level sink depth func state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L82)

<a id="global-global-miniquake-render-gl-rmain-sinkdepthmax-sinkdepthmax-src-miniquake-render-gl-rmain-ml-199178148"></a>
### sinkDepthMax

```ml
sinkDepthMax
```

Tracks the module-level sink depth max state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L86)

<a id="global-global-miniquake-render-gl-rmain-sinkdepthmin-sinkdepthmin-src-miniquake-render-gl-rmain-ml-302154084"></a>
### sinkDepthMin

```ml
sinkDepthMin
```

Tracks the module-level sink depth min state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L84)

<a id="global-global-miniquake-render-gl-rmain-sinkhash-sinkhash-src-miniquake-render-gl-rmain-ml-1696162894"></a>
### sinkHash

```ml
sinkHash
```

Tracks the module-level sink hash state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L68)

<a id="global-global-miniquake-render-gl-rmain-sinklasttexture-sinklasttexture-src-miniquake-render-gl-rmain-ml-1098992508"></a>
### sinkLastTexture

```ml
sinkLastTexture
```

Tracks the module-level sink last texture state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L78)

<a id="global-global-miniquake-render-gl-rmain-sinkscalar-sinkscalar-src-miniquake-render-gl-rmain-ml-1161437502"></a>
### sinkScalar

```ml
sinkScalar
```

Tracks the module-level sink scalar state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L72)

<a id="global-global-miniquake-render-gl-rmain-sinkvertices-sinkvertices-src-miniquake-render-gl-rmain-ml-55655588"></a>
### sinkVertices

```ml
sinkVertices
```

Tracks the module-level sink vertices state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L74)

<a id="function-function-miniquake-render-gl-rmain-subtract-function-subtract-left-right-src-miniquake-render-gl-rmain-ml-807746521"></a>
### Subtract

```ml
function Subtract(left, right)
```

Implements the `Subtract` operation for `miniquake.render.gl_rmain` (subtract).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `Subtract`. |
| `right` | `dynamic` | — | The right input consumed by `Subtract`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L285)

<a id="global-global-miniquake-render-gl-rmain-trickframe-trickframe-src-miniquake-render-gl-rmain-ml-2019156644"></a>
### trickFrame

```ml
trickFrame
```

Tracks the module-level trick frame state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L133)

<a id="function-function-miniquake-render-gl-rmain-vertex-function-vertex-operation-point-src-miniquake-render-gl-rmain-ml-1532922089"></a>
### Vertex

```ml
function Vertex(operation, point)
```

Implements the `Vertex` operation for `miniquake.render.gl_rmain` (vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | The operation input consumed by `Vertex`. |
| `point` | `dynamic` | — | The point input consumed by `Vertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L222)

<a id="global-global-miniquake-render-gl-rmain-vpn-vpn-src-miniquake-render-gl-rmain-ml-1436548052"></a>
### vpn

```ml
vpn
```

Tracks the module-level vpn state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L91)

<a id="global-global-miniquake-render-gl-rmain-vright-vright-src-miniquake-render-gl-rmain-ml-1982486436"></a>
### vright

```ml
vright
```

Tracks the module-level vright state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L93)

<a id="global-global-miniquake-render-gl-rmain-vup-vup-src-miniquake-render-gl-rmain-ml-645838312"></a>
### vup

```ml
vup
```

Tracks the module-level vup state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L95)

<a id="global-global-miniquake-render-gl-rmain-ztrick-ztrick-src-miniquake-render-gl-rmain-ml-1076649262"></a>
### zTrick

```ml
zTrick
```

Tracks the module-level z trick state owned by `miniquake.render.gl_rmain`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmain.ml#L131)
