# `src/miniquake/render/texture_upscale.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.texture_upscale`](Package-miniquake-render-texture-upscale-2089492308.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-render-texture-upscale-absoluteinteger-function-absoluteinteger-value-src-miniquake-render-texture-upscale-ml-1414281695"></a>
### absoluteInteger

```ml
function absoluteInteger(value)
```

Return an absolute integer without converting the hot scaler path to float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absoluteInteger`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L82)

<a id="function-function-miniquake-render-texture-upscale-apply-function-apply-pixels-width-height-mode-src-miniquake-render-texture-upscale-ml-341496519"></a>
### apply

```ml
function apply(pixels, width, height, mode)
```

Apply one selected load-time upscaler and return [pixels, width, height].

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `apply`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mode` | `dynamic` | — | The mode input consumed by `apply`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L396)

<a id="function-function-miniquake-render-texture-upscale-blendcorner-function-blendcorner-destination-destinationoffset-source-center-first-second-centerweight-neighborweight-src-miniquake-render-texture-upscale-ml-1145598250"></a>
### blendCorner

```ml
function blendCorner(destination, destinationOffset, source, center, first, second, centerWeight, neighborWeight)
```

Blend a center pixel with two edge neighbors in premultiplied-alpha space. This prevents the hidden RGB value of Quake palette index 255 from forming colored fringes around sprite and alias-model cutouts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `destinationOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `center` | `dynamic` | — | The center input consumed by `blendCorner`. |
| `first` | `dynamic` | — | The first input consumed by `blendCorner`. |
| `second` | `dynamic` | — | The second input consumed by `blendCorner`. |
| `centerWeight` | `dynamic` | — | The center weight input consumed by `blendCorner`. |
| `neighborWeight` | `dynamic` | — | The neighbor weight input consumed by `blendCorner`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L132)

<a id="function-function-miniquake-render-texture-upscale-clampmode-function-clampmode-mode-src-miniquake-render-texture-upscale-ml-1694939279"></a>
### clampMode

```ml
function clampMode(mode)
```

Clamp a persisted or console-provided mode to the supported range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `clampMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L33)

<a id="function-function-miniquake-render-texture-upscale-copypixel-function-copypixel-destination-destinationoffset-source-sourceoffset-src-miniquake-render-texture-upscale-ml-1141059360"></a>
### copyPixel

```ml
function copyPixel(destination, destinationOffset, source, sourceOffset)
```

Copy one complete pixel into an already allocated destination image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `destinationOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `sourceOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L113)

<a id="function-function-miniquake-render-texture-upscale-edgeaware2x-function-edgeaware2x-pixels-width-height-xbr-src-miniquake-render-texture-upscale-ml-2037993332"></a>
### edgeAware2x

```ml
function edgeAware2x(pixels, width, height, xbr)
```

Apply HQ2x or xBR2x edge-directed smoothing without touching flat regions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `edgeAware2x`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `xbr` | `dynamic` | — | The xbr input consumed by `edgeAware2x`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L337)

<a id="function-function-miniquake-render-texture-upscale-hqcorner-function-hqcorner-output-destination-pixels-center-first-second-src-miniquake-render-texture-upscale-ml-678466859"></a>
### hqCorner

```ml
function hqCorner(output, destination, pixels, center, first, second)
```

Blend one HQ2x corner when its two adjoining colors form a coherent edge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `dynamic` | — | Destination buffer updated with the HQ-filtered corner. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `pixels` | `dynamic` | — | The pixels input consumed by `hqCorner`. |
| `center` | `dynamic` | — | The center input consumed by `hqCorner`. |
| `first` | `dynamic` | — | The first input consumed by `hqCorner`. |
| `second` | `dynamic` | — | The second input consumed by `hqCorner`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L299)

<a id="function-function-miniquake-render-texture-upscale-modename-function-modename-mode-src-miniquake-render-texture-upscale-ml-570053731"></a>
### modeName

```ml
function modeName(mode)
```

Return the stable English display name for one texture-upscale mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `modeName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L42)

<a id="function-function-miniquake-render-texture-upscale-nearest-function-nearest-pixels-width-height-factor-src-miniquake-render-texture-upscale-ml-354216287"></a>
### nearest

```ml
function nearest(pixels, width, height, factor)
```

Enlarge an RGBA image with exact nearest-neighbor replication.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `nearest`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `factor` | `dynamic` | — | The factor input consumed by `nearest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L160)

<a id="function-function-miniquake-render-texture-upscale-pixeldistance-function-pixeldistance-pixels-first-second-src-miniquake-render-texture-upscale-ml-1173206827"></a>
### pixelDistance

```ml
function pixelDistance(pixels, first, second)
```

Measure perceptual RGBA distance with extra weight on green and alpha.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `pixelDistance`. |
| `first` | `dynamic` | — | The first input consumed by `pixelDistance`. |
| `second` | `dynamic` | — | The second input consumed by `pixelDistance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L91)

<a id="function-function-miniquake-render-texture-upscale-pixelsequal-function-pixelsequal-pixels-first-second-src-miniquake-render-texture-upscale-ml-1977934623"></a>
### pixelsEqual

```ml
function pixelsEqual(pixels, first, second)
```

Report exact equality for two RGBA pixels in the same byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `pixelsEqual`. |
| `first` | `dynamic` | — | The first input consumed by `pixelsEqual`. |
| `second` | `dynamic` | — | The second input consumed by `pixelsEqual`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L73)

<a id="function-function-miniquake-render-texture-upscale-pixelssimilar-function-pixelssimilar-pixels-first-second-threshold-src-miniquake-render-texture-upscale-ml-763757314"></a>
### pixelsSimilar

```ml
function pixelsSimilar(pixels, first, second, threshold)
```

Report perceptual similarity at the supplied HQ/xBR edge threshold.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `pixelsSimilar`. |
| `first` | `dynamic` | — | The first input consumed by `pixelsSimilar`. |
| `second` | `dynamic` | — | The second input consumed by `pixelsSimilar`. |
| `threshold` | `dynamic` | — | The threshold input consumed by `pixelsSimilar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L104)

<a id="function-function-miniquake-render-texture-upscale-scale2x-function-scale2x-pixels-width-height-src-miniquake-render-texture-upscale-ml-1508359918"></a>
### scale2x

```ml
function scale2x(pixels, width, height)
```

Apply the canonical Scale2x neighborhood rules to an RGBA image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `scale2x`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L185)

<a id="function-function-miniquake-render-texture-upscale-scale3x-function-scale3x-pixels-width-height-src-miniquake-render-texture-upscale-ml-1526681808"></a>
### scale3x

```ml
function scale3x(pixels, width, height)
```

Apply the canonical Scale3x 3x3 neighborhood rules to an RGBA image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `scale3x`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L238)

<a id="function-function-miniquake-render-texture-upscale-scalefactor-function-scalefactor-mode-src-miniquake-render-texture-upscale-ml-1692891369"></a>
### scaleFactor

```ml
function scaleFactor(mode)
```

Return the integer enlargement factor associated with a mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `scaleFactor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L49)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-hq2x-const-upscale-hq2x-4-src-miniquake-render-texture-upscale-ml-27563529"></a>
### UPSCALE_HQ2X

```ml
const UPSCALE_HQ2X = 4
```

Defines the upscale hq2 x value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L23)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-mode-count-const-upscale-mode-count-7-src-miniquake-render-texture-upscale-ml-1289682360"></a>
### UPSCALE_MODE_COUNT

```ml
const UPSCALE_MODE_COUNT = 7
```

Defines the upscale mode count value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L29)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-nearest-2x-const-upscale-nearest-2x-1-src-miniquake-render-texture-upscale-ml-1863306558"></a>
### UPSCALE_NEAREST_2X

```ml
const UPSCALE_NEAREST_2X = 1
```

Defines the upscale nearest 2 x value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L17)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-off-const-upscale-off-0-src-miniquake-render-texture-upscale-ml-1434285945"></a>
### UPSCALE_OFF

```ml
const UPSCALE_OFF = 0
```

Defines the upscale off value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L15)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-scale2x-const-upscale-scale2x-2-src-miniquake-render-texture-upscale-ml-1180012171"></a>
### UPSCALE_SCALE2X

```ml
const UPSCALE_SCALE2X = 2
```

Defines the upscale scale2 x value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L19)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-scale3x-const-upscale-scale3x-3-src-miniquake-render-texture-upscale-ml-714991644"></a>
### UPSCALE_SCALE3X

```ml
const UPSCALE_SCALE3X = 3
```

Defines the upscale scale3 x value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L21)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-xbr2x-const-upscale-xbr2x-5-src-miniquake-render-texture-upscale-ml-840782802"></a>
### UPSCALE_XBR2X

```ml
const UPSCALE_XBR2X = 5
```

Defines the upscale xbr2 x value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L25)

<a id="constant-constant-miniquake-render-texture-upscale-upscale-xbr4x-const-upscale-xbr4x-6-src-miniquake-render-texture-upscale-ml-562860255"></a>
### UPSCALE_XBR4X

```ml
const UPSCALE_XBR4X = 6
```

Defines the upscale xbr4 x value used by `miniquake.render.texture_upscale`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L27)

<a id="function-function-miniquake-render-texture-upscale-validatesource-function-validatesource-pixels-width-height-src-miniquake-render-texture-upscale-ml-1244018938"></a>
### validateSource

```ml
function validateSource(pixels, width, height)
```

Validate dimensions and the complete RGBA source span before scaling.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `validateSource`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L61)

<a id="function-function-miniquake-render-texture-upscale-xbrcorner-function-xbrcorner-output-destination-pixels-center-first-second-diagonal-farfirst-farsecond-src-miniquake-render-texture-upscale-ml-901007338"></a>
### xbrCorner

```ml
function xbrCorner(output, destination, pixels, center, first, second, diagonal, farFirst, farSecond)
```

Blend one xBR corner after comparing the two competing diagonal gradients.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `dynamic` | — | Destination buffer updated with the xBR-filtered corner. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `pixels` | `dynamic` | — | The pixels input consumed by `xbrCorner`. |
| `center` | `dynamic` | — | The center input consumed by `xbrCorner`. |
| `first` | `dynamic` | — | The first input consumed by `xbrCorner`. |
| `second` | `dynamic` | — | The second input consumed by `xbrCorner`. |
| `diagonal` | `dynamic` | — | The diagonal input consumed by `xbrCorner`. |
| `farFirst` | `dynamic` | — | The far first input consumed by `xbrCorner`. |
| `farSecond` | `dynamic` | — | The far second input consumed by `xbrCorner`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/texture_upscale.ml#L316)
