# `src/miniquake/render/enhanced.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.enhanced`](Package-miniquake-render-enhanced-5990661.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `byteio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)

## Declarations

<a id="global-global-miniquake-render-enhanced-activelightcount-activelightcount-src-miniquake-render-enhanced-ml-115911082"></a>
### activeLightCount

```ml
activeLightCount
```

Tracks the module-level active light count state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L38)

<a id="function-function-miniquake-render-enhanced-beginframe-function-beginframe-dynamiclights-currenttime-vieworigin-src-miniquake-render-enhanced-ml-1395021553"></a>
### beginFrame

```ml
function beginFrame(dynamicLights, currentTime, viewOrigin)
```

Select the strongest active lights, pack them into the reusable bridge buffer, and capture the current view matrix in the native backend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dynamicLights` | `dynamic` | — | The dynamic lights input consumed by `beginFrame`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `beginFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L116)

<a id="function-function-miniquake-render-enhanced-beginoverlay-function-beginoverlay-src-miniquake-render-enhanced-ml-1592076654"></a>
### beginOverlay

```ml
function beginOverlay()
```

Select the additive per-pixel draw program for following 3-D geometry.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L168)

<a id="function-function-miniquake-render-enhanced-clampshadowquality-function-clampshadowquality-value-src-miniquake-render-enhanced-ml-1366137901"></a>
### clampShadowQuality

```ml
function clampShadowQuality(value)
```

Clamp a requested shadow quality to the stable menu/config range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `clampShadowQuality`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L42)

<a id="function-function-miniquake-render-enhanced-configure-function-configure-requestedenabled-requestedshadows-requestedshadowquality-src-miniquake-render-enhanced-ml-1060113775"></a>
### configure

```ml
function configure(requestedEnabled, requestedShadows, requestedShadowQuality)
```

Configure the shared native enhanced renderer while preserving Classic as the safe fallback if the active backend cannot create its GPU program.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requestedEnabled` | `dynamic` | — | The requested enabled input consumed by `configure`. |
| `requestedShadows` | `dynamic` | — | The requested shadows input consumed by `configure`. |
| `requestedShadowQuality` | `dynamic` | — | The requested shadow quality input consumed by `configure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L54)

<a id="global-global-miniquake-render-enhanced-enabled-enabled-src-miniquake-render-enhanced-ml-1691562808"></a>
### enabled

```ml
enabled
```

Tracks the module-level enabled state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L26)

<a id="function-function-miniquake-render-enhanced-endframe-function-endframe-src-miniquake-render-enhanced-ml-1168537294"></a>
### endFrame

```ml
function endFrame()
```

Finalize the enhanced portion of the frame before 2-D rendering begins.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L181)

<a id="function-function-miniquake-render-enhanced-endoverlay-function-endoverlay-src-miniquake-render-enhanced-ml-1655873322"></a>
### endOverlay

```ml
function endOverlay()
```

Restore compatibility drawing after an enhanced geometry batch.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L175)

<a id="function-function-miniquake-render-enhanced-hasactivelights-function-hasactivelights-src-miniquake-render-enhanced-ml-1010713676"></a>
### hasActiveLights

```ml
function hasActiveLights()
```

Report whether this frame contains at least one live dynamic light.  The world/entity renderers use this to avoid a black additive replay.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L81)

<a id="function-function-miniquake-render-enhanced-isenabled-function-isenabled-src-miniquake-render-enhanced-ml-89814744"></a>
### isEnabled

```ml
function isEnabled()
```

Report whether the enhanced path is active for the current frame.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L65)

<a id="constant-constant-miniquake-render-enhanced-light-bytes-const-light-bytes-light-floats-4-src-miniquake-render-enhanced-ml-33353175"></a>
### LIGHT_BYTES

```ml
const LIGHT_BYTES = LIGHT_FLOATS * 4
```

Defines the light bytes value used by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L23)

<a id="constant-constant-miniquake-render-enhanced-light-floats-const-light-floats-4-src-miniquake-render-enhanced-ml-1254465615"></a>
### LIGHT_FLOATS

```ml
const LIGHT_FLOATS = 4
```

Defines the light floats value used by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L21)

<a id="global-global-miniquake-render-enhanced-lightpacket-lightpacket-src-miniquake-render-enhanced-ml-915117228"></a>
### lightPacket

```ml
lightPacket
```

Tracks the module-level light packet state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L32)

<a id="constant-constant-miniquake-render-enhanced-max-enhanced-lights-const-max-enhanced-lights-16-src-miniquake-render-enhanced-ml-1884673638"></a>
### MAX_ENHANCED_LIGHTS

```ml
const MAX_ENHANCED_LIGHTS = 16
```

Keep a bounded dynamic-light packet for the native raster backends without changing Quake's authoritative game state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L19)

<a id="function-function-miniquake-render-enhanced-putlightfloat-function-putlightfloat-offset-value-src-miniquake-render-enhanced-ml-1772619770"></a>
### putLightFloat

```ml
function putLightFloat(offset, value)
```

Write one IEEE-754 light component without allocating a temporary byte array.  Native receives {world x,y,z,radius} records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putLightFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L89)

<a id="global-global-miniquake-render-enhanced-selectedlightindexes-selectedlightindexes-src-miniquake-render-enhanced-ml-1115793554"></a>
### selectedLightIndexes

```ml
selectedLightIndexes
```

Tracks the module-level selected light indexes state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L34)

<a id="global-global-miniquake-render-enhanced-selectedlightscores-selectedlightscores-src-miniquake-render-enhanced-ml-148282104"></a>
### selectedLightScores

```ml
selectedLightScores
```

Tracks the module-level selected light scores state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L36)

<a id="function-function-miniquake-render-enhanced-shadowquality-function-shadowquality-src-miniquake-render-enhanced-ml-1999273784"></a>
### shadowQuality

```ml
function shadowQuality()
```

Return the clamped enhanced shadow-quality level.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L75)

<a id="global-global-miniquake-render-enhanced-shadowqualityvalue-shadowqualityvalue-src-miniquake-render-enhanced-ml-1204087432"></a>
### shadowQualityValue

```ml
shadowQualityValue
```

Tracks the module-level shadow quality value state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L30)

<a id="function-function-miniquake-render-enhanced-shadowsactive-function-shadowsactive-src-miniquake-render-enhanced-ml-357640980"></a>
### shadowsActive

```ml
function shadowsActive()
```

Report whether enhanced entity/world shadows were requested.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L70)

<a id="global-global-miniquake-render-enhanced-shadowsenabled-shadowsenabled-src-miniquake-render-enhanced-ml-399170984"></a>
### shadowsEnabled

```ml
shadowsEnabled
```

Tracks the module-level shadows enabled state owned by `miniquake.render.enhanced`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L28)

<a id="function-function-miniquake-render-enhanced-worldlighteligible-function-worldlighteligible-light-currenttime-vieworigin-src-miniquake-render-enhanced-ml-3680897"></a>
### worldLightEligible

```ml
function worldLightEligible(light, currentTime, viewOrigin)
```

Decide whether a dynamic light belongs in the per-pixel world pass. GLQuake treats a camera contained by the inner 35 percent of a flashblend light as a screen tint rather than world geometry. Feeding that same light to the enhanced shader made the local player's randomly sized Quad/EF_DIMLIGHT alternate between an orange world light and the blue powerup cshift.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `light` | `dynamic` | — | The light input consumed by `worldLightEligible`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `worldLightEligible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/enhanced.ml#L101)
