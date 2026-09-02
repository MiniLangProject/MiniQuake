# `src/miniquake/render_evidence.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render_evidence`](Package-miniquake-render-evidence-558897473.md)

Reachable from entry: **yes**

## Imports

- `miniquake/build_info.ml` as `buildInfo` → [src/miniquake/build_info.ml](File-src-miniquake-build-info-ml-1156326101.md)
- `miniquake/compat_diagnostics.ml` as `diagnostics` → [src/miniquake/compat_diagnostics.ml](File-src-miniquake-compat-diagnostics-ml-1440740289.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/screen.ml` as `screen` → [src/miniquake/screen.ml](File-src-miniquake-screen-ml-587247802.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-render-evidence-booltext-function-booltext-value-src-miniquake-render-evidence-ml-1256081932"></a>
### boolText

```ml
function boolText(value)
```

Implements the `boolText` operation for `miniquake.render_evidence` (bool text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `boolText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L167)

<a id="function-function-miniquake-render-evidence-captured-function-captured-src-miniquake-render-evidence-ml-1492832911"></a>
### captured

```ml
function captured()
```

Implements the `captured` operation for `miniquake.render_evidence` (captured).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L156)

<a id="global-global-miniquake-render-evidence-capturedone-capturedone-src-miniquake-render-evidence-ml-389780921"></a>
### captureDone

```ml
captureDone
```

Tracks the module-level capture done state owned by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L35)

<a id="function-function-miniquake-render-evidence-captureifrequested-function-captureifrequested-framenumber-width-height-src-miniquake-render-evidence-ml-1261267672"></a>
### captureIfRequested

```ml
function captureIfRequested(frameNumber, width, height)
```

Implements the `captureIfRequested` operation for `miniquake.render_evidence` (capture if requested).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameNumber` | `dynamic` | — | The frame number input consumed by `captureIfRequested`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L209)

<a id="global-global-miniquake-render-evidence-captureprefix-captureprefix-src-miniquake-render-evidence-ml-1428346377"></a>
### capturePrefix

```ml
capturePrefix
```

Tracks the module-level capture prefix state owned by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L33)

<a id="global-global-miniquake-render-evidence-capturerequested-capturerequested-src-miniquake-render-evidence-ml-592624385"></a>
### captureRequested

```ml
captureRequested
```

Tracks the module-level capture requested state owned by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L29)

<a id="global-global-miniquake-render-evidence-captureresult-captureresult-src-miniquake-render-evidence-ml-86596161"></a>
### captureResult

```ml
captureResult
```

Tracks the module-level capture result state owned by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L37)

<a id="global-global-miniquake-render-evidence-capturetargetframe-capturetargetframe-src-miniquake-render-evidence-ml-978734533"></a>
### captureTargetFrame

```ml
captureTargetFrame
```

Tracks the module-level capture target frame state owned by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L31)

<a id="function-function-miniquake-render-evidence-configure-function-configure-prefix-targetframe-src-miniquake-render-evidence-ml-311517391"></a>
### configure

```ml
function configure(prefix, targetFrame)
```

Implements the `configure` operation for `miniquake.render_evidence` (configure).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — | The prefix input consumed by `configure`. |
| `targetFrame` | `dynamic` | — | The target frame input consumed by `configure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L136)

<a id="constant-constant-miniquake-render-evidence-evidence-schema-const-evidence-schema-1-src-miniquake-render-evidence-ml-1736035277"></a>
### EVIDENCE_SCHEMA

```ml
const EVIDENCE_SCHEMA = 1
```

Defines the evidence schema value used by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L20)

<a id="constant-constant-miniquake-render-evidence-fnv-offset-const-fnv-offset-2166136261-src-miniquake-render-evidence-ml-1615795552"></a>
### FNV_OFFSET

```ml
const FNV_OFFSET = 2166136261
```

Defines the fnv offset value used by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L24)

<a id="constant-constant-miniquake-render-evidence-fnv-prime-const-fnv-prime-16777619-src-miniquake-render-evidence-ml-1021139464"></a>
### FNV_PRIME

```ml
const FNV_PRIME = 16777619
```

Defines the fnv prime value used by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L26)

<a id="function-function-miniquake-render-evidence-hashbyte-inline-function-hashbyte-state-value-src-miniquake-render-evidence-ml-892495148"></a>
### hashByte

```ml
inline function hashByte(state, value)
```

Returns whether `miniquake.render_evidence` has h byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.render_evidence` state used by `hashByte`. |
| `value` | `dynamic` | — | Value consumed by `hashByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L42)

<a id="function-function-miniquake-render-evidence-hashbytes-function-hashbytes-data-src-miniquake-render-evidence-ml-1704977813"></a>
### hashBytes

```ml
function hashBytes(data)
```

Fold bytes into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L48)

<a id="function-function-miniquake-render-evidence-lastresult-function-lastresult-src-miniquake-render-evidence-ml-864440491"></a>
### lastResult

```ml
function lastResult()
```

Return last result for the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L161)

<a id="function-function-miniquake-render-evidence-nonblackpixels-function-nonblackpixels-rgba-src-miniquake-render-evidence-ml-584467081"></a>
### nonBlackPixels

```ml
function nonBlackPixels(rgba)
```

Implements the `nonBlackPixels` operation for `miniquake.render_evidence` (non black pixels).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rgba` | `dynamic` | — | The rgba input consumed by `nonBlackPixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L100)

<a id="function-function-miniquake-render-evidence-reset-function-reset-src-miniquake-render-evidence-ml-1871084997"></a>
### reset

```ml
function reset()
```

Implements the `reset` operation for `miniquake.render_evidence` (reset).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L123)

<a id="constant-constant-miniquake-render-evidence-sample-grid-const-sample-grid-16-src-miniquake-render-evidence-ml-396883155"></a>
### SAMPLE_GRID

```ml
const SAMPLE_GRID = 16
```

Defines the sample grid value used by `miniquake.render_evidence`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L22)

<a id="function-function-miniquake-render-evidence-samplecoordinate-function-samplecoordinate-cell-extent-gridsize-src-miniquake-render-evidence-ml-2141385270"></a>
### sampleCoordinate

```ml
function sampleCoordinate(cell, extent, gridSize)
```

Build deterministic test data for coordinate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cell` | `dynamic` | — | The cell input consumed by `sampleCoordinate`. |
| `extent` | `dynamic` | — | The extent input consumed by `sampleCoordinate`. |
| `gridSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L62)

<a id="function-function-miniquake-render-evidence-samplepixelhash-function-samplepixelhash-rgba-width-height-gridsize-src-miniquake-render-evidence-ml-814971845"></a>
### samplePixelHash

```ml
function samplePixelHash(rgba, width, height, gridSize)
```

Build deterministic test data for pixel hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rgba` | `dynamic` | — | The rgba input consumed by `samplePixelHash`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `gridSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L75)

<a id="function-function-miniquake-render-evidence-shouldcapture-function-shouldcapture-framenumber-src-miniquake-render-evidence-ml-1108953079"></a>
### shouldCapture

```ml
function shouldCapture(frameNumber)
```

Report whether should capture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameNumber` | `dynamic` | — | The frame number input consumed by `shouldCapture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L150)

<a id="function-function-miniquake-render-evidence-summaryjson-function-summaryjson-framenumber-width-height-pixelbytes-tgabytes-pixelhash-tgahash-samplehash-nonblack-imagepath-src-miniquake-render-evidence-ml-2028731134"></a>
### summaryJson

```ml
function summaryJson(frameNumber, width, height, pixelBytes, tgaBytes, pixelHash, tgaHash, sampleHash, nonBlack, imagePath)
```

Implements the `summaryJson` operation for `miniquake.render_evidence` (summary json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameNumber` | `dynamic` | — | The frame number input consumed by `summaryJson`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixelBytes` | `dynamic` | — | Byte data consumed by the operation. |
| `tgaBytes` | `dynamic` | — | Byte data consumed by the operation. |
| `pixelHash` | `dynamic` | — | The pixel hash input consumed by `summaryJson`. |
| `tgaHash` | `dynamic` | — | The tga hash input consumed by `summaryJson`. |
| `sampleHash` | `dynamic` | — | The sample hash input consumed by `summaryJson`. |
| `nonBlack` | `dynamic` | — | The non black input consumed by `summaryJson`. |
| `imagePath` | `dynamic` | — | Filesystem path used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L183)

<a id="function-function-miniquake-render-evidence-summarypath-function-summarypath-prefix-src-miniquake-render-evidence-ml-827601909"></a>
### summaryPath

```ml
function summaryPath(prefix)
```

Return summary path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — | The prefix input consumed by `summaryPath`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L118)

<a id="function-function-miniquake-render-evidence-tgapath-function-tgapath-prefix-src-miniquake-render-evidence-ml-860341285"></a>
### tgaPath

```ml
function tgaPath(prefix)
```

Return tga path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — | The prefix input consumed by `tgaPath`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence.ml#L112)
