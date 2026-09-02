# `src/miniquake/render/gl11.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl11`](Package-miniquake-render-gl11-1231055122.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-render-gl11-activetexture-function-activetexture-unit-src-miniquake-render-gl11-ml-256586516"></a>
### activeTexture

```ml
function activeTexture(unit)
```

Report whether active texture holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `unit` | `dynamic` | — | The unit input consumed by `activeTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L725)

<a id="function-function-miniquake-render-gl11-alphafunc-function-alphafunc-functionname-reference-src-miniquake-render-gl11-ml-1556219500"></a>
### alphaFunc

```ml
function alphaFunc(functionName, reference)
```

Implements the `alphaFunc` operation for `miniquake.render.gl11` (alpha func).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `functionName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `reference` | `dynamic` | — | The reference input consumed by `alphaFunc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L511)

<a id="function-function-miniquake-render-gl11-backendname-function-backendname-src-miniquake-render-gl11-ml-1637478290"></a>
### backendName

```ml
function backendName()
```

Return backend name derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L47)

<a id="function-function-miniquake-render-gl11-begin-function-begin-mode-src-miniquake-render-gl11-ml-521394741"></a>
### begin

```ml
function begin(mode)
```

Initialize state for begin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `begin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L197)

<a id="function-function-miniquake-render-gl11-bindtexture-function-bindtexture-texture-src-miniquake-render-gl11-ml-652886607"></a>
### bindTexture

```ml
function bindTexture(texture)
```

Implements the `bindTexture` operation for `miniquake.render.gl11` (bind texture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L524)

<a id="function-function-miniquake-render-gl11-bits-function-bits-value-src-miniquake-render-gl11-ml-2136650201"></a>
### bits

```ml
function bits(value)
```

Return bits derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `bits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L191)

<a id="function-function-miniquake-render-gl11-blendfunc-function-blendfunc-source-destination-src-miniquake-render-gl11-ml-1066437889"></a>
### blendFunc

```ml
function blendFunc(source, destination)
```

Implements the `blendFunc` operation for `miniquake.render.gl11` (blend func).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L292)

<a id="global-global-miniquake-render-gl11-boundtexturename-boundtexturename-src-miniquake-render-gl11-ml-326139184"></a>
### boundTextureName

```ml
boundTextureName
```

Tracks the module-level bound texture name state owned by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L19)

<a id="function-function-miniquake-render-gl11-clear-function-clear-mask-src-miniquake-render-gl11-ml-1407469750"></a>
### clear

```ml
function clear(mask)
```

Implements the `clear` operation for `miniquake.render.gl11` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mask` | `dynamic` | — | The mask input consumed by `clear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L270)

<a id="function-function-miniquake-render-gl11-clearcolor-function-clearcolor-red-green-blue-alpha-src-miniquake-render-gl11-ml-2030528910"></a>
### clearColor

```ml
function clearColor(red, green, blue, alpha)
```

Update module state for color.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `red` | `dynamic` | — | The red input consumed by `clearColor`. |
| `green` | `dynamic` | — | The green input consumed by `clearColor`. |
| `blue` | `dynamic` | — | The blue input consumed by `clearColor`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `clearColor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L263)

<a id="function-function-miniquake-render-gl11-clearstaticgeometrycache-function-clearstaticgeometrycache-src-miniquake-render-gl11-ml-471849704"></a>
### clearStaticGeometryCache

```ml
function clearStaticGeometryCache()
```

Update module state for static geometry cache.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L782)

<a id="function-function-miniquake-render-gl11-color-function-color-red-green-blue-alpha-src-miniquake-render-gl11-ml-1881436796"></a>
### color

```ml
function color(red, green, blue, alpha)
```

Implements the `color` operation for `miniquake.render.gl11` (color).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `red` | `dynamic` | — | The red input consumed by `color`. |
| `green` | `dynamic` | — | The green input consumed by `color`. |
| `blue` | `dynamic` | — | The blue input consumed by `color`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `color`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L238)

<a id="function-function-miniquake-render-gl11-colorfloat-function-colorfloat-red-green-blue-alpha-src-miniquake-render-gl11-ml-1313678798"></a>
### colorFloat

```ml
function colorFloat(red, green, blue, alpha)
```

Implements the `colorFloat` operation for `miniquake.render.gl11` (color float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `red` | `dynamic` | — | The red input consumed by `colorFloat`. |
| `green` | `dynamic` | — | The green input consumed by `colorFloat`. |
| `blue` | `dynamic` | — | The blue input consumed by `colorFloat`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `colorFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L248)

<a id="function-function-miniquake-render-gl11-cullface-function-cullface-mode-src-miniquake-render-gl11-ml-85778703"></a>
### cullFace

```ml
function cullFace(mode)
```

Implements the `cullFace` operation for `miniquake.render.gl11` (cull face).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `cullFace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L517)

<a id="function-function-miniquake-render-gl11-currentboundtexture-function-currentboundtexture-src-miniquake-render-gl11-ml-1659543080"></a>
### currentBoundTexture

```ml
function currentBoundTexture()
```

Return bound texture.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L92)

<a id="function-function-miniquake-render-gl11-deletetexture-function-deletetexture-texture-src-miniquake-render-gl11-ml-225279095"></a>
### deleteTexture

```ml
function deleteTexture(texture)
```

Release or remove state for texture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L539)

<a id="function-function-miniquake-render-gl11-depthfunc-function-depthfunc-value-src-miniquake-render-gl11-ml-674164955"></a>
### depthFunc

```ml
function depthFunc(value)
```

Implements the `depthFunc` operation for `miniquake.render.gl11` (depth func).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `depthFunc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L299)

<a id="function-function-miniquake-render-gl11-depthmask-function-depthmask-enabled-src-miniquake-render-gl11-ml-322416663"></a>
### depthMask

```ml
function depthMask(enabled)
```

Implements the `depthMask` operation for `miniquake.render.gl11` (depth mask).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L306)

<a id="function-function-miniquake-render-gl11-depthrange-function-depthrange-nearvalue-farvalue-src-miniquake-render-gl11-ml-1932240533"></a>
### depthRange

```ml
function depthRange(nearValue, farValue)
```

Implements the `depthRange` operation for `miniquake.render.gl11` (depth range).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nearValue` | `dynamic` | — | The near value input consumed by `depthRange`. |
| `farValue` | `dynamic` | — | The far value input consumed by `depthRange`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L315)

<a id="global-global-miniquake-render-gl11-diagnostictrace-diagnostictrace-src-miniquake-render-gl11-ml-270648156"></a>
### diagnosticTrace

```ml
diagnosticTrace
```

Tracks the module-level diagnostic trace state owned by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L15)

<a id="global-global-miniquake-render-gl11-diagnostictraceenabled-diagnostictraceenabled-src-miniquake-render-gl11-ml-2084746982"></a>
### diagnosticTraceEnabled

```ml
diagnosticTraceEnabled
```

Tracks the module-level diagnostic trace enabled state owned by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L13)

<a id="function-function-miniquake-render-gl11-disable-function-disable-capability-src-miniquake-render-gl11-ml-510725502"></a>
### disable

```ml
function disable(capability)
```

Implements the `disable` operation for `miniquake.render.gl11` (disable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capability` | `dynamic` | — | The capability input consumed by `disable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L284)

<a id="function-function-miniquake-render-gl11-drawbuffer-function-drawbuffer-mode-src-miniquake-render-gl11-ml-720622343"></a>
### drawBuffer

```ml
function drawBuffer(mode)
```

Render buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `drawBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L662)

<a id="function-function-miniquake-render-gl11-enable-function-enable-capability-src-miniquake-render-gl11-ml-280382578"></a>
### enable

```ml
function enable(capability)
```

Implements the `enable` operation for `miniquake.render.gl11` (enable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capability` | `dynamic` | — | The capability input consumed by `enable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L277)

<a id="constant-constant-miniquake-render-gl11-enhanced-draw-none-const-enhanced-draw-none-0-src-miniquake-render-gl11-ml-1398158155"></a>
### ENHANCED_DRAW_NONE

```ml
const ENHANCED_DRAW_NONE = 0
```

Native enhanced-lighting draw classifications.  The classic path always uses NONE; the optional renderer uses OVERLAY only for its additive 3-D light pass, so console/HUD/menu rendering cannot inherit a shader.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L504)

<a id="constant-constant-miniquake-render-gl11-enhanced-draw-overlay-const-enhanced-draw-overlay-1-src-miniquake-render-gl11-ml-1681835784"></a>
### ENHANCED_DRAW_OVERLAY

```ml
const ENHANCED_DRAW_OVERLAY = 1
```

Defines the enhanced draw overlay value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L506)

<a id="function-function-miniquake-render-gl11-enhancedavailable-function-enhancedavailable-src-miniquake-render-gl11-ml-1829611258"></a>
### enhancedAvailable

```ml
function enhancedAvailable()
```

Report whether the active backend can execute the optional per-pixel light pass.  Availability is capability based and is deliberately independent of the selected Classic/Enhanced user setting.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L688)

<a id="function-function-miniquake-render-gl11-enhancedbeginframe-function-enhancedbeginframe-lightpacket-bytecount-src-miniquake-render-gl11-ml-1621997685"></a>
### enhancedBeginFrame

```ml
function enhancedBeginFrame(lightPacket, byteCount)
```

Upload the compact world-space dynamic-light packet for the current view.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lightPacket` | `dynamic` | — | The light packet input consumed by `enhancedBeginFrame`. |
| `byteCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L708)

<a id="function-function-miniquake-render-gl11-enhancedconfigure-function-enhancedconfigure-enabled-shadows-shadowquality-src-miniquake-render-gl11-ml-922796027"></a>
### enhancedConfigure

```ml
function enhancedConfigure(enabled, shadows, shadowQuality)
```

Configure optional enhanced rendering without changing the selected native backend.  Classic remains a zero-cost path when enabled is false.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `shadows` | `dynamic` | — | The shadows input consumed by `enhancedConfigure`. |
| `shadowQuality` | `dynamic` | — | The shadow quality input consumed by `enhancedConfigure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L697)

<a id="function-function-miniquake-render-gl11-enhanceddrawkind-function-enhanceddrawkind-kind-src-miniquake-render-gl11-ml-163277618"></a>
### enhancedDrawKind

```ml
function enhancedDrawKind(kind)
```

Select which following geometry is part of the enhanced additive pass.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | The kind input consumed by `enhancedDrawKind`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L714)

<a id="function-function-miniquake-render-gl11-enhancedendframe-function-enhancedendframe-src-miniquake-render-gl11-ml-416890548"></a>
### enhancedEndFrame

```ml
function enhancedEndFrame()
```

End enhanced 3-D rendering and force the compatibility program/state back.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L719)

<a id="function-function-miniquake-render-gl11-errorcode-function-errorcode-src-miniquake-render-gl11-ml-1567556382"></a>
### errorCode

```ml
function errorCode()
```

Report code and return the corresponding failure status.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L429)

<a id="function-function-miniquake-render-gl11-finish-function-finish-src-miniquake-render-gl11-ml-1999818784"></a>
### finish

```ml
function finish()
```

Finalize state for finish.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L655)

<a id="function-function-miniquake-render-gl11-finishprimitive-function-finishprimitive-src-miniquake-render-gl11-ml-645618884"></a>
### finishPrimitive

```ml
function finishPrimitive()
```

Finalize state for finish primitive.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L203)

<a id="function-function-miniquake-render-gl11-flush-function-flush-src-miniquake-render-gl11-ml-1690486640"></a>
### flush

```ml
function flush()
```

Implements the `flush` operation for `miniquake.render.gl11` (flush).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L434)

<a id="function-function-miniquake-render-gl11-frustum-function-frustum-left-right-bottom-top-nearvalue-farvalue-src-miniquake-render-gl11-ml-87314322"></a>
### frustum

```ml
function frustum(left, right, bottom, top, nearValue, farValue)
```

Implements the `frustum` operation for `miniquake.render.gl11` (frustum).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `frustum`. |
| `right` | `dynamic` | — | The right input consumed by `frustum`. |
| `bottom` | `dynamic` | — | The bottom input consumed by `frustum`. |
| `top` | `dynamic` | — | The top input consumed by `frustum`. |
| `nearValue` | `dynamic` | — | The near value input consumed by `frustum`. |
| `farValue` | `dynamic` | — | The far value input consumed by `frustum`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L401)

<a id="function-function-miniquake-render-gl11-generatetexture-function-generatetexture-src-miniquake-render-gl11-ml-1134584368"></a>
### generateTexture

```ml
function generateTexture()
```

Implements the `generateTexture` operation for `miniquake.render.gl11` (generate texture).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L533)

<a id="function-function-miniquake-render-gl11-getstring-function-getstring-name-src-miniquake-render-gl11-ml-940203521"></a>
### getString

```ml
function getString(name)
```

Return string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L422)

<a id="constant-constant-miniquake-render-gl11-gl-alpha-test-const-gl-alpha-test-3008-src-miniquake-render-gl11-ml-997051980"></a>
### GL_ALPHA_TEST

```ml
const GL_ALPHA_TEST = 3008
```

Defines the gl alpha test value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L451)

<a id="constant-constant-miniquake-render-gl11-gl-back-const-gl-back-1029-src-miniquake-render-gl11-ml-1504555677"></a>
### GL_BACK

```ml
const GL_BACK = 1029
```

Defines the gl back value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L455)

<a id="constant-constant-miniquake-render-gl11-gl-blend-const-gl-blend-3042-src-miniquake-render-gl11-ml-362598754"></a>
### GL_BLEND

```ml
const GL_BLEND = 3042
```

Defines the gl blend value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L129)

<a id="constant-constant-miniquake-render-gl11-gl-clamp-const-gl-clamp-10496-src-miniquake-render-gl11-ml-668778857"></a>
### GL_CLAMP

```ml
const GL_CLAMP = 10496
```

Defines the gl clamp value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L475)

<a id="constant-constant-miniquake-render-gl11-gl-color-buffer-bit-const-gl-color-buffer-bit-16384-src-miniquake-render-gl11-ml-2126570777"></a>
### GL_COLOR_BUFFER_BIT

```ml
const GL_COLOR_BUFFER_BIT = 16384
```

Defines the gl color buffer bit value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L125)

<a id="constant-constant-miniquake-render-gl11-gl-color-index-const-gl-color-index-6400-src-miniquake-render-gl11-ml-303886593"></a>
### GL_COLOR_INDEX

```ml
const GL_COLOR_INDEX = 6400
```

Defines the gl color index value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L457)

<a id="constant-constant-miniquake-render-gl11-gl-color-index8-ext-const-gl-color-index8-ext-32997-src-miniquake-render-gl11-ml-1282600769"></a>
### GL_COLOR_INDEX8_EXT

```ml
const GL_COLOR_INDEX8_EXT = 32997
```

Defines the gl color index8 ext value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L459)

<a id="constant-constant-miniquake-render-gl11-gl-combine-const-gl-combine-34160-src-miniquake-render-gl11-ml-1810771981"></a>
### GL_COMBINE

```ml
const GL_COMBINE = 34160
```

Defines the gl combine value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L483)

<a id="constant-constant-miniquake-render-gl11-gl-combine-rgb-const-gl-combine-rgb-34161-src-miniquake-render-gl11-ml-1406311368"></a>
### GL_COMBINE_RGB

```ml
const GL_COMBINE_RGB = 34161
```

Defines the gl combine rgb value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L485)

<a id="constant-constant-miniquake-render-gl11-gl-cull-face-const-gl-cull-face-2884-src-miniquake-render-gl11-ml-1038754469"></a>
### GL_CULL_FACE

```ml
const GL_CULL_FACE = 2884
```

Defines the gl cull face value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L133)

<a id="constant-constant-miniquake-render-gl11-gl-depth-buffer-bit-const-gl-depth-buffer-bit-256-src-miniquake-render-gl11-ml-591011218"></a>
### GL_DEPTH_BUFFER_BIT

```ml
const GL_DEPTH_BUFFER_BIT = 256
```

Defines the gl depth buffer bit value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L123)

<a id="constant-constant-miniquake-render-gl11-gl-depth-test-const-gl-depth-test-2929-src-miniquake-render-gl11-ml-2002727909"></a>
### GL_DEPTH_TEST

```ml
const GL_DEPTH_TEST = 2929
```

Defines the gl depth test value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L127)

<a id="constant-constant-miniquake-render-gl11-gl-dst-color-const-gl-dst-color-774-src-miniquake-render-gl11-ml-428686215"></a>
### GL_DST_COLOR

```ml
const GL_DST_COLOR = 774
```

Defines the gl dst color value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L447)

<a id="constant-constant-miniquake-render-gl11-gl-extensions-const-gl-extensions-7939-src-miniquake-render-gl11-ml-1864353325"></a>
### GL_EXTENSIONS

```ml
const GL_EXTENSIONS = 7939
```

Defines the gl extensions value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L187)

<a id="constant-constant-miniquake-render-gl11-gl-fill-const-gl-fill-6914-src-miniquake-render-gl11-ml-612702333"></a>
### GL_FILL

```ml
const GL_FILL = 6914
```

Defines the gl fill value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L153)

<a id="constant-constant-miniquake-render-gl11-gl-flat-const-gl-flat-7424-src-miniquake-render-gl11-ml-542664418"></a>
### GL_FLAT

```ml
const GL_FLAT = 7424
```

Defines the gl flat value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L145)

<a id="constant-constant-miniquake-render-gl11-gl-front-const-gl-front-1028-src-miniquake-render-gl11-ml-1862327248"></a>
### GL_FRONT

```ml
const GL_FRONT = 1028
```

Defines the gl front value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L147)

<a id="constant-constant-miniquake-render-gl11-gl-front-and-back-const-gl-front-and-back-1032-src-miniquake-render-gl11-ml-1130587089"></a>
### GL_FRONT_AND_BACK

```ml
const GL_FRONT_AND_BACK = 1032
```

Defines the gl front and back value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L149)

<a id="constant-constant-miniquake-render-gl11-gl-gequal-const-gl-gequal-518-src-miniquake-render-gl11-ml-1183001903"></a>
### GL_GEQUAL

```ml
const GL_GEQUAL = 518
```

Defines the gl gequal value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L141)

<a id="constant-constant-miniquake-render-gl11-gl-greater-const-gl-greater-516-src-miniquake-render-gl11-ml-786460395"></a>
### GL_GREATER

```ml
const GL_GREATER = 516
```

Defines the gl greater value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L453)

<a id="constant-constant-miniquake-render-gl11-gl-lequal-const-gl-lequal-515-src-miniquake-render-gl11-ml-522117094"></a>
### GL_LEQUAL

```ml
const GL_LEQUAL = 515
```

Defines the gl lequal value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L139)

<a id="constant-constant-miniquake-render-gl11-gl-line-const-gl-line-6913-src-miniquake-render-gl11-ml-1798406970"></a>
### GL_LINE

```ml
const GL_LINE = 6913
```

Defines the gl line value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L151)

<a id="constant-constant-miniquake-render-gl11-gl-line-loop-const-gl-line-loop-2-src-miniquake-render-gl11-ml-450536695"></a>
### GL_LINE_LOOP

```ml
const GL_LINE_LOOP = 2
```

Defines the gl line loop value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L109)

<a id="constant-constant-miniquake-render-gl11-gl-line-strip-const-gl-line-strip-3-src-miniquake-render-gl11-ml-979966962"></a>
### GL_LINE_STRIP

```ml
const GL_LINE_STRIP = 3
```

Defines the gl line strip value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L111)

<a id="constant-constant-miniquake-render-gl11-gl-linear-const-gl-linear-9729-src-miniquake-render-gl11-ml-445926458"></a>
### GL_LINEAR

```ml
const GL_LINEAR = 9729
```

Defines the gl linear value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L171)

<a id="constant-constant-miniquake-render-gl11-gl-linear-mipmap-linear-const-gl-linear-mipmap-linear-9987-src-miniquake-render-gl11-ml-1843806804"></a>
### GL_LINEAR_MIPMAP_LINEAR

```ml
const GL_LINEAR_MIPMAP_LINEAR = 9987
```

Defines the gl linear mipmap linear value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L179)

<a id="constant-constant-miniquake-render-gl11-gl-linear-mipmap-nearest-const-gl-linear-mipmap-nearest-9985-src-miniquake-render-gl11-ml-885741118"></a>
### GL_LINEAR_MIPMAP_NEAREST

```ml
const GL_LINEAR_MIPMAP_NEAREST = 9985
```

Defines the gl linear mipmap nearest value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L175)

<a id="constant-constant-miniquake-render-gl11-gl-lines-const-gl-lines-1-src-miniquake-render-gl11-ml-1333171368"></a>
### GL_LINES

```ml
const GL_LINES = 1
```

Defines the gl lines value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L107)

<a id="constant-constant-miniquake-render-gl11-gl-luminance-const-gl-luminance-6409-src-miniquake-render-gl11-ml-1847241072"></a>
### GL_LUMINANCE

```ml
const GL_LUMINANCE = 6409
```

Defines the gl luminance value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L465)

<a id="constant-constant-miniquake-render-gl11-gl-modelview-const-gl-modelview-5888-src-miniquake-render-gl11-ml-2063453688"></a>
### GL_MODELVIEW

```ml
const GL_MODELVIEW = 5888
```

Defines the gl modelview value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L137)

<a id="constant-constant-miniquake-render-gl11-gl-modulate-const-gl-modulate-8448-src-miniquake-render-gl11-ml-1054883673"></a>
### GL_MODULATE

```ml
const GL_MODULATE = 8448
```

Defines the gl modulate value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L499)

<a id="constant-constant-miniquake-render-gl11-gl-nearest-const-gl-nearest-9728-src-miniquake-render-gl11-ml-296931381"></a>
### GL_NEAREST

```ml
const GL_NEAREST = 9728
```

Defines the gl nearest value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L169)

<a id="constant-constant-miniquake-render-gl11-gl-nearest-mipmap-linear-const-gl-nearest-mipmap-linear-9986-src-miniquake-render-gl11-ml-308433597"></a>
### GL_NEAREST_MIPMAP_LINEAR

```ml
const GL_NEAREST_MIPMAP_LINEAR = 9986
```

Defines the gl nearest mipmap linear value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L177)

<a id="constant-constant-miniquake-render-gl11-gl-nearest-mipmap-nearest-const-gl-nearest-mipmap-nearest-9984-src-miniquake-render-gl11-ml-1365504067"></a>
### GL_NEAREST_MIPMAP_NEAREST

```ml
const GL_NEAREST_MIPMAP_NEAREST = 9984
```

Defines the gl nearest mipmap nearest value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L173)

<a id="constant-constant-miniquake-render-gl11-gl-one-const-gl-one-1-src-miniquake-render-gl11-ml-2078202266"></a>
### GL_ONE

```ml
const GL_ONE = 1
```

Defines the gl one value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L441)

<a id="constant-constant-miniquake-render-gl11-gl-one-minus-dst-color-const-gl-one-minus-dst-color-775-src-miniquake-render-gl11-ml-337710418"></a>
### GL_ONE_MINUS_DST_COLOR

```ml
const GL_ONE_MINUS_DST_COLOR = 775
```

Defines the gl one minus dst color value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L449)

<a id="constant-constant-miniquake-render-gl11-gl-one-minus-src-alpha-const-gl-one-minus-src-alpha-771-src-miniquake-render-gl11-ml-1502332186"></a>
### GL_ONE_MINUS_SRC_ALPHA

```ml
const GL_ONE_MINUS_SRC_ALPHA = 771
```

Defines the gl one minus src alpha value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L157)

<a id="constant-constant-miniquake-render-gl11-gl-one-minus-src-color-const-gl-one-minus-src-color-769-src-miniquake-render-gl11-ml-485416031"></a>
### GL_ONE_MINUS_SRC_COLOR

```ml
const GL_ONE_MINUS_SRC_COLOR = 769
```

Defines the gl one minus src color value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L445)

<a id="constant-constant-miniquake-render-gl11-gl-operand0-rgb-const-gl-operand0-rgb-34192-src-miniquake-render-gl11-ml-1352234370"></a>
### GL_OPERAND0_RGB

```ml
const GL_OPERAND0_RGB = 34192
```

Defines the gl operand0 rgb value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L491)

<a id="constant-constant-miniquake-render-gl11-gl-operand1-rgb-const-gl-operand1-rgb-34193-src-miniquake-render-gl11-ml-1829383427"></a>
### GL_OPERAND1_RGB

```ml
const GL_OPERAND1_RGB = 34193
```

Defines the gl operand1 rgb value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L493)

<a id="constant-constant-miniquake-render-gl11-gl-points-const-gl-points-0-src-miniquake-render-gl11-ml-1563543605"></a>
### GL_POINTS

```ml
const GL_POINTS = 0
```

Defines the gl points value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L105)

<a id="constant-constant-miniquake-render-gl11-gl-polygon-const-gl-polygon-9-src-miniquake-render-gl11-ml-600020174"></a>
### GL_POLYGON

```ml
const GL_POLYGON = 9
```

Defines the gl polygon value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L121)

<a id="constant-constant-miniquake-render-gl11-gl-previous-const-gl-previous-34168-src-miniquake-render-gl11-ml-778384069"></a>
### GL_PREVIOUS

```ml
const GL_PREVIOUS = 34168
```

Defines the gl previous value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L495)

<a id="constant-constant-miniquake-render-gl11-gl-projection-const-gl-projection-5889-src-miniquake-render-gl11-ml-1200538443"></a>
### GL_PROJECTION

```ml
const GL_PROJECTION = 5889
```

Defines the gl projection value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L135)

<a id="constant-constant-miniquake-render-gl11-gl-quads-const-gl-quads-7-src-miniquake-render-gl11-ml-442028712"></a>
### GL_QUADS

```ml
const GL_QUADS = 7
```

Defines the gl quads value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L119)

<a id="constant-constant-miniquake-render-gl11-gl-renderer-const-gl-renderer-7937-src-miniquake-render-gl11-ml-417961427"></a>
### GL_RENDERER

```ml
const GL_RENDERER = 7937
```

Defines the gl renderer value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L183)

<a id="constant-constant-miniquake-render-gl11-gl-repeat-const-gl-repeat-10497-src-miniquake-render-gl11-ml-1452212688"></a>
### GL_REPEAT

```ml
const GL_REPEAT = 10497
```

Defines the gl repeat value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L473)

<a id="constant-constant-miniquake-render-gl11-gl-replace-const-gl-replace-7681-src-miniquake-render-gl11-ml-576711297"></a>
### GL_REPLACE

```ml
const GL_REPLACE = 7681
```

Defines the gl replace value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L497)

<a id="constant-constant-miniquake-render-gl11-gl-rgb-const-gl-rgb-6407-src-miniquake-render-gl11-ml-464570904"></a>
### GL_RGB

```ml
const GL_RGB = 6407
```

Defines the gl rgb value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L161)

<a id="constant-constant-miniquake-render-gl11-gl-rgba-const-gl-rgba-6408-src-miniquake-render-gl11-ml-1544467307"></a>
### GL_RGBA

```ml
const GL_RGBA = 6408
```

Defines the gl rgba value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L159)

<a id="constant-constant-miniquake-render-gl11-gl-smooth-const-gl-smooth-7425-src-miniquake-render-gl11-ml-1100274199"></a>
### GL_SMOOTH

```ml
const GL_SMOOTH = 7425
```

Defines the gl smooth value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L143)

<a id="constant-constant-miniquake-render-gl11-gl-source0-rgb-const-gl-source0-rgb-34176-src-miniquake-render-gl11-ml-1100669404"></a>
### GL_SOURCE0_RGB

```ml
const GL_SOURCE0_RGB = 34176
```

Defines the gl source0 rgb value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L487)

<a id="constant-constant-miniquake-render-gl11-gl-source1-rgb-const-gl-source1-rgb-34177-src-miniquake-render-gl11-ml-1823101627"></a>
### GL_SOURCE1_RGB

```ml
const GL_SOURCE1_RGB = 34177
```

Defines the gl source1 rgb value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L489)

<a id="constant-constant-miniquake-render-gl11-gl-src-alpha-const-gl-src-alpha-770-src-miniquake-render-gl11-ml-1556627359"></a>
### GL_SRC_ALPHA

```ml
const GL_SRC_ALPHA = 770
```

Defines the gl src alpha value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L155)

<a id="constant-constant-miniquake-render-gl11-gl-src-color-const-gl-src-color-768-src-miniquake-render-gl11-ml-1429946566"></a>
### GL_SRC_COLOR

```ml
const GL_SRC_COLOR = 768
```

Defines the gl src color value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L443)

<a id="constant-constant-miniquake-render-gl11-gl-texture-const-gl-texture-5890-src-miniquake-render-gl11-ml-284222273"></a>
### GL_TEXTURE

```ml
const GL_TEXTURE = 5890
```

Defines the gl texture value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L481)

<a id="constant-constant-miniquake-render-gl11-gl-texture0-sgis-const-gl-texture0-sgis-33630-src-miniquake-render-gl11-ml-922368338"></a>
### GL_TEXTURE0_SGIS

```ml
const GL_TEXTURE0_SGIS = 33630
```

Defines the gl texture0 sgis value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L461)

<a id="constant-constant-miniquake-render-gl11-gl-texture1-sgis-const-gl-texture1-sgis-33631-src-miniquake-render-gl11-ml-374113089"></a>
### GL_TEXTURE1_SGIS

```ml
const GL_TEXTURE1_SGIS = 33631
```

Defines the gl texture1 sgis value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L463)

<a id="constant-constant-miniquake-render-gl11-gl-texture-2d-const-gl-texture-2d-3553-src-miniquake-render-gl11-ml-1248411229"></a>
### GL_TEXTURE_2D

```ml
const GL_TEXTURE_2D = 3553
```

Defines the gl texture 2 d value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L131)

<a id="constant-constant-miniquake-render-gl11-gl-texture-env-const-gl-texture-env-8960-src-miniquake-render-gl11-ml-695069038"></a>
### GL_TEXTURE_ENV

```ml
const GL_TEXTURE_ENV = 8960
```

Defines the gl texture env value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L477)

<a id="constant-constant-miniquake-render-gl11-gl-texture-env-mode-const-gl-texture-env-mode-8704-src-miniquake-render-gl11-ml-115230238"></a>
### GL_TEXTURE_ENV_MODE

```ml
const GL_TEXTURE_ENV_MODE = 8704
```

Defines the gl texture env mode value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L479)

<a id="constant-constant-miniquake-render-gl11-gl-texture-mag-filter-const-gl-texture-mag-filter-10240-src-miniquake-render-gl11-ml-1045814918"></a>
### GL_TEXTURE_MAG_FILTER

```ml
const GL_TEXTURE_MAG_FILTER = 10240
```

Defines the gl texture mag filter value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L167)

<a id="constant-constant-miniquake-render-gl11-gl-texture-max-anisotropy-ext-const-gl-texture-max-anisotropy-ext-34046-src-miniquake-render-gl11-ml-1689344628"></a>
### GL_TEXTURE_MAX_ANISOTROPY_EXT

```ml
const GL_TEXTURE_MAX_ANISOTROPY_EXT = 34046
```

Defines the gl texture max anisotropy ext value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L471)

<a id="constant-constant-miniquake-render-gl11-gl-texture-min-filter-const-gl-texture-min-filter-10241-src-miniquake-render-gl11-ml-804541883"></a>
### GL_TEXTURE_MIN_FILTER

```ml
const GL_TEXTURE_MIN_FILTER = 10241
```

Defines the gl texture min filter value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L165)

<a id="constant-constant-miniquake-render-gl11-gl-texture-wrap-s-const-gl-texture-wrap-s-10242-src-miniquake-render-gl11-ml-1902814696"></a>
### GL_TEXTURE_WRAP_S

```ml
const GL_TEXTURE_WRAP_S = 10242
```

Defines the gl texture wrap s value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L467)

<a id="constant-constant-miniquake-render-gl11-gl-texture-wrap-t-const-gl-texture-wrap-t-10243-src-miniquake-render-gl11-ml-1511820817"></a>
### GL_TEXTURE_WRAP_T

```ml
const GL_TEXTURE_WRAP_T = 10243
```

Defines the gl texture wrap t value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L469)

<a id="constant-constant-miniquake-render-gl11-gl-triangle-fan-const-gl-triangle-fan-6-src-miniquake-render-gl11-ml-1743362139"></a>
### GL_TRIANGLE_FAN

```ml
const GL_TRIANGLE_FAN = 6
```

Defines the gl triangle fan value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L117)

<a id="constant-constant-miniquake-render-gl11-gl-triangle-strip-const-gl-triangle-strip-5-src-miniquake-render-gl11-ml-1733897136"></a>
### GL_TRIANGLE_STRIP

```ml
const GL_TRIANGLE_STRIP = 5
```

Defines the gl triangle strip value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L115)

<a id="constant-constant-miniquake-render-gl11-gl-triangles-const-gl-triangles-4-src-miniquake-render-gl11-ml-1093502357"></a>
### GL_TRIANGLES

```ml
const GL_TRIANGLES = 4
```

Defines the gl triangles value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L113)

<a id="constant-constant-miniquake-render-gl11-gl-unsigned-byte-const-gl-unsigned-byte-5121-src-miniquake-render-gl11-ml-2036959458"></a>
### GL_UNSIGNED_BYTE

```ml
const GL_UNSIGNED_BYTE = 5121
```

Defines the gl unsigned byte value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L163)

<a id="constant-constant-miniquake-render-gl11-gl-vendor-const-gl-vendor-7936-src-miniquake-render-gl11-ml-1708227514"></a>
### GL_VENDOR

```ml
const GL_VENDOR = 7936
```

Defines the gl vendor value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L181)

<a id="constant-constant-miniquake-render-gl11-gl-version-const-gl-version-7938-src-miniquake-render-gl11-ml-1259341638"></a>
### GL_VERSION

```ml
const GL_VERSION = 7938
```

Defines the gl version value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L185)

<a id="constant-constant-miniquake-render-gl11-gl-zero-const-gl-zero-0-src-miniquake-render-gl11-ml-324100605"></a>
### GL_ZERO

```ml
const GL_ZERO = 0
```

Defines the gl zero value used by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L439)

<a id="function-function-miniquake-render-gl11-loadidentity-function-loadidentity-src-miniquake-render-gl11-ml-894069792"></a>
### loadIdentity

```ml
function loadIdentity()
```

Read and validate identity.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L338)

<a id="function-function-miniquake-render-gl11-matrixmode-function-matrixmode-mode-src-miniquake-render-gl11-ml-1672535363"></a>
### matrixMode

```ml
function matrixMode(mode)
```

Return matrix mode derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `matrixMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L332)

<a id="function-function-miniquake-render-gl11-multitexcoord2-function-multitexcoord2-unit-s-t-src-miniquake-render-gl11-ml-494600385"></a>
### multiTexCoord2

```ml
function multiTexCoord2(unit, s, t)
```

Implements the `multiTexCoord2` operation for `miniquake.render.gl11` (multi tex coord2).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `unit` | `dynamic` | — | The unit input consumed by `multiTexCoord2`. |
| `s` | `dynamic` | — | The s input consumed by `multiTexCoord2`. |
| `t` | `dynamic` | — | The t input consumed by `multiTexCoord2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L733)

<a id="function-function-miniquake-render-gl11-multitextureavailable-function-multitextureavailable-src-miniquake-render-gl11-ml-1234760466"></a>
### multitextureAvailable

```ml
function multitextureAvailable()
```

Report whether multitexture available holds for the active state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L668)

<a id="function-function-miniquake-render-gl11-nativebatchavailable-inline-function-nativebatchavailable-src-miniquake-render-gl11-ml-426176019"></a>
### nativeBatchAvailable

```ml
inline function nativeBatchAvailable()
```

Report whether native batch available holds for the active state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L42)

<a id="global-global-miniquake-render-gl11-nexttexturename-nexttexturename-src-miniquake-render-gl11-ml-1863819564"></a>
### nextTextureName

```ml
nextTextureName
```

Tracks the module-level next texture name state owned by `miniquake.render.gl11`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L17)

<a id="function-function-miniquake-render-gl11-nexttexturenamevalue-inline-function-nexttexturenamevalue-src-miniquake-render-gl11-ml-1883045431"></a>
### nextTextureNameValue

```ml
inline function nextTextureNameValue()
```

Return next texture name value for the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L78)

<a id="function-function-miniquake-render-gl11-ortho-function-ortho-left-right-bottom-top-nearvalue-farvalue-src-miniquake-render-gl11-ml-1923685194"></a>
### ortho

```ml
function ortho(left, right, bottom, top, nearValue, farValue)
```

Implements the `ortho` operation for `miniquake.render.gl11` (ortho).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `ortho`. |
| `right` | `dynamic` | — | The right input consumed by `ortho`. |
| `bottom` | `dynamic` | — | The bottom input consumed by `ortho`. |
| `top` | `dynamic` | — | The top input consumed by `ortho`. |
| `nearValue` | `dynamic` | — | The near value input consumed by `ortho`. |
| `farValue` | `dynamic` | — | The far value input consumed by `ortho`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L389)

<a id="function-function-miniquake-render-gl11-polygonmode-function-polygonmode-face-mode-src-miniquake-render-gl11-ml-1623991592"></a>
### polygonMode

```ml
function polygonMode(face, mode)
```

Return polygon mode derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `face` | `dynamic` | — | The face input consumed by `polygonMode`. |
| `mode` | `dynamic` | — | The mode input consumed by `polygonMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L409)

<a id="function-function-miniquake-render-gl11-popmatrix-function-popmatrix-src-miniquake-render-gl11-ml-1094437736"></a>
### popMatrix

```ml
function popMatrix()
```

Consume pending state for pop matrix.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L350)

<a id="function-function-miniquake-render-gl11-pushmatrix-function-pushmatrix-src-miniquake-render-gl11-ml-1046071128"></a>
### pushMatrix

```ml
function pushMatrix()
```

Add state for push matrix.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L344)

<a id="function-function-miniquake-render-gl11-readpixelsrgba-function-readpixelsrgba-x-y-width-height-src-miniquake-render-gl11-ml-1817347658"></a>
### readPixelsRgba

```ml
function readPixelsRgba(x, y, width, height)
```

Read and validate pixels rgba.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `readPixelsRgba`. |
| `y` | `dynamic` | — | The y input consumed by `readPixelsRgba`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L647)

<a id="function-function-miniquake-render-gl11-reservetexturenames-function-reservetexturenames-count-src-miniquake-render-gl11-ml-165896813"></a>
### reserveTextureNames

```ml
function reserveTextureNames(count)
```

MiniQuake 1.09 allocates every renderer texture from the single global texture_extension_number namespace.  Keeping that namespace here prevents independently ported world, entity and 2-D upload paths from reusing and overwriting each other's OpenGL object names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L69)

<a id="function-function-miniquake-render-gl11-resettexturenames-function-resettexturenames-first-src-miniquake-render-gl11-ml-1133782526"></a>
### resetTextureNames

```ml
function resetTextureNames(first)
```

Update module state for texture names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `resetTextureNames`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L84)

<a id="function-function-miniquake-render-gl11-rotate-function-rotate-angle-x-y-z-src-miniquake-render-gl11-ml-1590015438"></a>
### rotate

```ml
function rotate(angle, x, y, z)
```

Implements the `rotate` operation for `miniquake.render.gl11` (rotate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angle` | `dynamic` | — | The angle input consumed by `rotate`. |
| `x` | `dynamic` | — | The x input consumed by `rotate`. |
| `y` | `dynamic` | — | The y input consumed by `rotate`. |
| `z` | `dynamic` | — | The z input consumed by `rotate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L369)

<a id="function-function-miniquake-render-gl11-scale-function-scale-x-y-z-src-miniquake-render-gl11-ml-837392967"></a>
### scale

```ml
function scale(x, y, z)
```

Implements the `scale` operation for `miniquake.render.gl11` (scale).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `scale`. |
| `y` | `dynamic` | — | The y input consumed by `scale`. |
| `z` | `dynamic` | — | The z input consumed by `scale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L378)

<a id="function-function-miniquake-render-gl11-setboundtextureforcompatibility-function-setboundtextureforcompatibility-texture-src-miniquake-render-gl11-ml-539406343"></a>
### setBoundTextureForCompatibility

```ml
function setBoundTextureForCompatibility(texture)
```

Update module state for bound texture for compatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L98)

<a id="function-function-miniquake-render-gl11-shademodel-function-shademodel-mode-src-miniquake-render-gl11-ml-487163227"></a>
### shadeModel

```ml
function shadeModel(mode)
```

Implements the `shadeModel` operation for `miniquake.render.gl11` (shade model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `shadeModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L415)

<a id="function-function-miniquake-render-gl11-staticgeometrycall-function-staticgeometrycall-objectvalue-passid-src-miniquake-render-gl11-ml-214561092"></a>
### staticGeometryCall

```ml
function staticGeometryCall(objectValue, passId)
```

Implements the `staticGeometryCall` operation for `miniquake.render.gl11` (static geometry call).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `objectValue` | `dynamic` | — | The object value input consumed by `staticGeometryCall`. |
| `passId` | `dynamic` | — | Stable identifier of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L740)

<a id="function-function-miniquake-render-gl11-staticgeometrycallbatch-function-staticgeometrycallbatch-keys-passid-src-miniquake-render-gl11-ml-1593777468"></a>
### staticGeometryCallBatch

```ml
function staticGeometryCallBatch(keys, passId)
```

Implements the `staticGeometryCallBatch` operation for `miniquake.render.gl11` (static geometry call batch).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `dynamic` | — | The keys input consumed by `staticGeometryCallBatch`. |
| `passId` | `dynamic` | — | Stable identifier of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L747)

<a id="function-function-miniquake-render-gl11-staticgeometrycallbatchcount-function-staticgeometrycallbatchcount-keys-keycount-passid-src-miniquake-render-gl11-ml-1095613886"></a>
### staticGeometryCallBatchCount

```ml
function staticGeometryCallBatchCount(keys, keyCount, passId)
```

Draw only the populated key prefix of a reusable static-geometry buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `dynamic` | — | The keys input consumed by `staticGeometryCallBatchCount`. |
| `keyCount` | `dynamic` | — | Number of entries or units to process. |
| `passId` | `dynamic` | — | Stable identifier of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L755)

<a id="function-function-miniquake-render-gl11-staticgeometrycallmultitexturebatch-function-staticgeometrycallmultitexturebatch-records-src-miniquake-render-gl11-ml-51851754"></a>
### staticGeometryCallMultitextureBatch

```ml
function staticGeometryCallMultitextureBatch(records)
```

Implements the `staticGeometryCallMultitextureBatch` operation for `miniquake.render.gl11` (static geometry call multitexture batch).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `records` | `dynamic` | — | The records input consumed by `staticGeometryCallMultitextureBatch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L762)

<a id="function-function-miniquake-render-gl11-staticgeometrycallmultitexturebatchcount-function-staticgeometrycallmultitexturebatchcount-records-recordcount-src-miniquake-render-gl11-ml-200311626"></a>
### staticGeometryCallMultitextureBatchCount

```ml
function staticGeometryCallMultitextureBatchCount(records, recordCount)
```

Draw only the populated prefix of a reusable multitexture record buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `records` | `dynamic` | — | The records input consumed by `staticGeometryCallMultitextureBatchCount`. |
| `recordCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L769)

<a id="function-function-miniquake-render-gl11-staticgeometryprepare-function-staticgeometryprepare-objectvalue-passid-src-miniquake-render-gl11-ml-850486310"></a>
### staticGeometryPrepare

```ml
function staticGeometryPrepare(objectValue, passId)
```

Implements the `staticGeometryPrepare` operation for `miniquake.render.gl11` (static geometry prepare).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `objectValue` | `dynamic` | — | The object value input consumed by `staticGeometryPrepare`. |
| `passId` | `dynamic` | — | Stable identifier of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L777)

<a id="function-function-miniquake-render-gl11-texcoord2-function-texcoord2-s-t-src-miniquake-render-gl11-ml-1599390399"></a>
### texcoord2

```ml
function texcoord2(s, t)
```

Implements the `texcoord2` operation for `miniquake.render.gl11` (texcoord2).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `dynamic` | — | The s input consumed by `texcoord2`. |
| `t` | `dynamic` | — | The t input consumed by `texcoord2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L228)

<a id="function-function-miniquake-render-gl11-textureenvironment-function-textureenvironment-mode-src-miniquake-render-gl11-ml-1120183691"></a>
### textureEnvironment

```ml
function textureEnvironment(mode)
```

Implements the `textureEnvironment` operation for `miniquake.render.gl11` (texture environment).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `textureEnvironment`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L560)

<a id="function-function-miniquake-render-gl11-textureenvironmentparameter-function-textureenvironmentparameter-name-value-src-miniquake-render-gl11-ml-1821327650"></a>
### textureEnvironmentParameter

```ml
function textureEnvironmentParameter(name, value)
```

Implements the `textureEnvironmentParameter` operation for `miniquake.render.gl11` (texture environment parameter).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `textureEnvironmentParameter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L568)

<a id="function-function-miniquake-render-gl11-textureparameter-function-textureparameter-name-value-src-miniquake-render-gl11-ml-257608720"></a>
### textureParameter

```ml
function textureParameter(name, value)
```

Implements the `textureParameter` operation for `miniquake.render.gl11` (texture parameter).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `textureParameter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L553)

<a id="function-function-miniquake-render-gl11-trace-begin-function-trace-begin-src-miniquake-render-gl11-ml-1509753286"></a>
### Trace_Begin

```ml
function Trace_Begin()
```

Trace begin through the collision world.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L22)

<a id="function-function-miniquake-render-gl11-trace-end-function-trace-end-src-miniquake-render-gl11-ml-1157297170"></a>
### Trace_End

```ml
function Trace_End()
```

Trace end through the collision world.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L30)

<a id="function-function-miniquake-render-gl11-tracecommand-function-tracecommand-name-arguments-src-miniquake-render-gl11-ml-416054633"></a>
### traceCommand

```ml
function traceCommand(name, arguments)
```

Trace command through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L57)

<a id="function-function-miniquake-render-gl11-traceenabled-inline-function-traceenabled-src-miniquake-render-gl11-ml-1304489639"></a>
### traceEnabled

```ml
inline function traceEnabled()
```

Trace enabled through the collision world.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L37)

<a id="function-function-miniquake-render-gl11-translate-function-translate-x-y-z-src-miniquake-render-gl11-ml-1315646367"></a>
### translate

```ml
function translate(x, y, z)
```

Implements the `translate` operation for `miniquake.render.gl11` (translate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `translate`. |
| `y` | `dynamic` | — | The y input consumed by `translate`. |
| `z` | `dynamic` | — | The z input consumed by `translate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L359)

<a id="function-function-miniquake-render-gl11-uploadindexedlevel-function-uploadindexedlevel-level-width-height-pixels-src-miniquake-render-gl11-ml-1471504044"></a>
### uploadIndexedLevel

```ml
function uploadIndexedLevel(level, width, height, pixels)
```

Upload indexed level to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `level` | `dynamic` | — | The level input consumed by `uploadIndexedLevel`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadIndexedLevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L597)

<a id="function-function-miniquake-render-gl11-uploadluminance-function-uploadluminance-width-height-pixels-src-miniquake-render-gl11-ml-1374660024"></a>
### uploadLuminance

```ml
function uploadLuminance(width, height, pixels)
```

Upload luminance to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadLuminance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L614)

<a id="function-function-miniquake-render-gl11-uploadluminancesubimage-function-uploadluminancesubimage-x-y-width-height-pixels-src-miniquake-render-gl11-ml-423569987"></a>
### uploadLuminanceSubImage

```ml
function uploadLuminanceSubImage(x, y, width, height, pixels)
```

Upload luminance sub image to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `uploadLuminanceSubImage`. |
| `y` | `dynamic` | — | The y input consumed by `uploadLuminanceSubImage`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadLuminanceSubImage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L625)

<a id="function-function-miniquake-render-gl11-uploadrgb-function-uploadrgb-width-height-pixels-src-miniquake-render-gl11-ml-1272259402"></a>
### uploadRgb

```ml
function uploadRgb(width, height, pixels)
```

Upload rgb to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadRgb`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L606)

<a id="function-function-miniquake-render-gl11-uploadrgba-function-uploadrgba-width-height-pixels-src-miniquake-render-gl11-ml-1132954966"></a>
### uploadRgba

```ml
function uploadRgba(width, height, pixels)
```

Upload rgba to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadRgba`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L576)

<a id="function-function-miniquake-render-gl11-uploadrgbalevel-function-uploadrgbalevel-level-internalformat-width-height-pixels-src-miniquake-render-gl11-ml-754746468"></a>
### uploadRgbaLevel

```ml
function uploadRgbaLevel(level, internalFormat, width, height, pixels)
```

Upload rgba level to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `level` | `dynamic` | — | The level input consumed by `uploadRgbaLevel`. |
| `internalFormat` | `dynamic` | — | The internal format input consumed by `uploadRgbaLevel`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadRgbaLevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L587)

<a id="function-function-miniquake-render-gl11-uploadrgbasubimage-function-uploadrgbasubimage-x-y-width-height-pixels-src-miniquake-render-gl11-ml-1664649675"></a>
### uploadRgbaSubImage

```ml
function uploadRgbaSubImage(x, y, width, height, pixels)
```

Upload an rgba rectangle into an existing texture. Colored lightmap pages use this path while the original scalar atlas keeps its luminance command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `uploadRgbaSubImage`. |
| `y` | `dynamic` | — | The y input consumed by `uploadRgbaSubImage`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadRgbaSubImage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L637)

<a id="function-function-miniquake-render-gl11-vertex2-function-vertex2-x-y-src-miniquake-render-gl11-ml-965641495"></a>
### vertex2

```ml
function vertex2(x, y)
```

Implements the `vertex2` operation for `miniquake.render.gl11` (vertex2).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `vertex2`. |
| `y` | `dynamic` | — | The y input consumed by `vertex2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L211)

<a id="function-function-miniquake-render-gl11-vertex3-function-vertex3-x-y-z-src-miniquake-render-gl11-ml-219394189"></a>
### vertex3

```ml
function vertex3(x, y, z)
```

Implements the `vertex3` operation for `miniquake.render.gl11` (vertex3).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `vertex3`. |
| `y` | `dynamic` | — | The y input consumed by `vertex3`. |
| `z` | `dynamic` | — | The z input consumed by `vertex3`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L220)

<a id="function-function-miniquake-render-gl11-viewport-function-viewport-x-y-width-height-src-miniquake-render-gl11-ml-412518482"></a>
### viewport

```ml
function viewport(x, y, width, height)
```

Implements the `viewport` operation for `miniquake.render.gl11` (viewport).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `viewport`. |
| `y` | `dynamic` | — | The y input consumed by `viewport`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L325)

<a id="function-function-miniquake-render-gl11-worldprogramavailable-function-worldprogramavailable-src-miniquake-render-gl11-ml-656133950"></a>
### worldProgramAvailable

```ml
function worldProgramAvailable()
```

Report whether world program available holds for the active state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L673)

<a id="function-function-miniquake-render-gl11-worldprogramenable-function-worldprogramenable-enabled-src-miniquake-render-gl11-ml-86505589"></a>
### worldProgramEnable

```ml
function worldProgramEnable(enabled)
```

Implements the `worldProgramEnable` operation for `miniquake.render.gl11` (world program enable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl11.ml#L679)
