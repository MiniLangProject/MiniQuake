# `src/miniquake/render_ui_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render_ui_contract`](Package-miniquake-render-ui-contract-2094161845.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-render-ui-contract-consolelogicalheight-function-consolelogicalheight-width-height-physicalheight-src-miniquake-render-ui-contract-ml-546289860"></a>
### consoleLogicalHeight

```ml
function consoleLogicalHeight(width, height, physicalHeight)
```

Implements the `consoleLogicalHeight` operation for `miniquake.render_ui_contract` (console logical height).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `physicalHeight` | `dynamic` | — | The physical height input consumed by `consoleLogicalHeight`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L111)

<a id="function-function-miniquake-render-ui-contract-consolelogicalwidth-function-consolelogicalwidth-width-height-src-miniquake-render-ui-contract-ml-137774786"></a>
### consoleLogicalWidth

```ml
function consoleLogicalWidth(width, height)
```

Implements the `consoleLogicalWidth` operation for `miniquake.render_ui_contract` (console logical width).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L103)

<a id="function-function-miniquake-render-ui-contract-consolescale-function-consolescale-width-height-src-miniquake-render-ui-contract-ml-1133796234"></a>
### consoleScale

```ml
function consoleScale(width, height)
```

Console glyphs use the same nearest-neighbour integer enlargement as the other indexed Quake UI art.  Keep the backing text buffer in logical pixels so a resize changes wrapping at the same scale that is actually rendered.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L87)

<a id="constant-constant-miniquake-render-ui-contract-inventory-height-const-inventory-height-24-src-miniquake-render-ui-contract-ml-2123306358"></a>
### INVENTORY_HEIGHT

```ml
const INVENTORY_HEIGHT = 24
```

Defines the inventory height value used by `miniquake.render_ui_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L19)

<a id="function-function-miniquake-render-ui-contract-overlayorder-function-overlayorder-dialog-loading-intermission-gameinput-src-miniquake-render-ui-contract-ml-1548180991"></a>
### overlayOrder

```ml
function overlayOrder(dialog, loading, intermission, gameInput)
```

Implements the `overlayOrder` operation for `miniquake.render_ui_contract` (overlay order).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dialog` | `dynamic` | — | The dialog input consumed by `overlayOrder`. |
| `loading` | `dynamic` | — | The loading input consumed by `overlayOrder`. |
| `intermission` | `dynamic` | — | The intermission input consumed by `overlayOrder`. |
| `gameInput` | `dynamic` | — | The game input input consumed by `overlayOrder`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L47)

<a id="function-function-miniquake-render-ui-contract-set2dstateorder-function-set2dstateorder-src-miniquake-render-ui-contract-ml-1005207467"></a>
### set2dStateOrder

```ml
function set2dStateOrder()
```

Update module state for 2d state order.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L127)

<a id="constant-constant-miniquake-render-ui-contract-statusbar-height-const-statusbar-height-24-src-miniquake-render-ui-contract-ml-1247298852"></a>
### STATUSBAR_HEIGHT

```ml
const STATUSBAR_HEIGHT = 24
```

Defines the statusbar height value used by `miniquake.render_ui_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L17)

<a id="constant-constant-miniquake-render-ui-contract-statusbar-width-const-statusbar-width-320-src-miniquake-render-ui-contract-ml-24697867"></a>
### STATUSBAR_WIDTH

```ml
const STATUSBAR_WIDTH = 320
```

Defines the statusbar width value used by `miniquake.render_ui_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L15)

<a id="function-function-miniquake-render-ui-contract-statusbarlines-function-statusbarlines-viewsize-intermission-src-miniquake-render-ui-contract-ml-857621493"></a>
### statusbarLines

```ml
function statusbarLines(viewSize, intermission)
```

Implements the `statusbarLines` operation for `miniquake.render_ui_contract` (statusbar lines).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewSize` | `dynamic` | — | Size of the requested data or resource. |
| `intermission` | `dynamic` | — | The intermission input consumed by `statusbarLines`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L150)

<a id="function-function-miniquake-render-ui-contract-statusbarphysicallines-function-statusbarphysicallines-width-height-viewsize-intermission-src-miniquake-render-ui-contract-ml-464685846"></a>
### statusbarPhysicalLines

```ml
function statusbarPhysicalLines(width, height, viewSize, intermission)
```

Implements the `statusbarPhysicalLines` operation for `miniquake.render_ui_contract` (statusbar physical lines).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `viewSize` | `dynamic` | — | Size of the requested data or resource. |
| `intermission` | `dynamic` | — | The intermission input consumed by `statusbarPhysicalLines`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L166)

<a id="function-function-miniquake-render-ui-contract-statusbarscale-function-statusbarscale-width-height-src-miniquake-render-ui-contract-ml-221521126"></a>
### statusbarScale

```ml
function statusbarScale(width, height)
```

The status bar, inventory strip and their 8-pixel glyphs are authored for the same 320-pixel Quake canvas as the menus.  Keeping one integral scale avoids a tiny HUD at high resolutions and prevents filtered indexed art.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L96)

<a id="function-function-miniquake-render-ui-contract-statusbarscaledxoffset-function-statusbarscaledxoffset-width-gametype-scale-src-miniquake-render-ui-contract-ml-782273261"></a>
### statusbarScaledXOffset

```ml
function statusbarScaledXOffset(width, gameType, scale)
```

Implements the `statusbarScaledXOffset` operation for `miniquake.render_ui_contract` (statusbar scaled x offset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `gameType` | `dynamic` | — | The game type input consumed by `statusbarScaledXOffset`. |
| `scale` | `dynamic` | — | The scale input consumed by `statusbarScaledXOffset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L37)

<a id="function-function-miniquake-render-ui-contract-statusbarxoffset-function-statusbarxoffset-width-gametype-src-miniquake-render-ui-contract-ml-525126697"></a>
### statusbarXOffset

```ml
function statusbarXOffset(width, gameType)
```

Implements the `statusbarXOffset` operation for `miniquake.render_ui_contract` (statusbar x offset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `gameType` | `dynamic` | — | The game type input consumed by `statusbarXOffset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L28)

<a id="constant-constant-miniquake-render-ui-contract-tga-bytes-per-pixel-const-tga-bytes-per-pixel-3-src-miniquake-render-ui-contract-ml-379647797"></a>
### TGA_BYTES_PER_PIXEL

```ml
const TGA_BYTES_PER_PIXEL = 3
```

Defines the tga bytes per pixel value used by `miniquake.render_ui_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L23)

<a id="constant-constant-miniquake-render-ui-contract-tga-header-bytes-const-tga-header-bytes-18-src-miniquake-render-ui-contract-ml-1230065737"></a>
### TGA_HEADER_BYTES

```ml
const TGA_HEADER_BYTES = 18
```

Defines the tga header bytes value used by `miniquake.render_ui_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L21)

<a id="function-function-miniquake-render-ui-contract-tgabytelength-function-tgabytelength-width-height-src-miniquake-render-ui-contract-ml-1963510842"></a>
### tgaByteLength

```ml
function tgaByteLength(width, height)
```

Return tga byte length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L137)

<a id="function-function-miniquake-render-ui-contract-viewmodeldepthmaximum-function-viewmodeldepthmaximum-src-miniquake-render-ui-contract-ml-2012869899"></a>
### viewModelDepthMaximum

```ml
function viewModelDepthMaximum()
```

Implements the `viewModelDepthMaximum` operation for `miniquake.render_ui_contract` (view model depth maximum).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L143)

<a id="function-function-miniquake-render-ui-contract-virtualcanvaslayout-function-virtualcanvaslayout-width-height-src-miniquake-render-ui-contract-ml-1031176684"></a>
### virtualCanvasLayout

```ml
function virtualCanvasLayout(width, height)
```

Implements the `virtualCanvasLayout` operation for `miniquake.render_ui_contract` (virtual canvas layout).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L118)

<a id="function-function-miniquake-render-ui-contract-virtualcanvasscale-function-virtualcanvasscale-width-height-src-miniquake-render-ui-contract-ml-1891024618"></a>
### virtualCanvasScale

```ml
function virtualCanvasScale(width, height)
```

GLQuake's menu helpers retain a 320-pixel logical canvas and only center it horizontally. Modern high-DPI modes need enlargement, but fractional or unbounded stretching makes the indexed font and qpics visibly uneven. Use a conservative integral scale: original size around 640x480, 2x around 1080p, and at most 4x on very large displays. Some valid widescreen modes (for example 1176x664) fall just below the legacy 1.5x ratio threshold despite having ample room for a 2x 320x200 canvas; promote those explicitly so the original 8-pixel menu font does not become needlessly tiny.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_ui_contract.ml#L66)
