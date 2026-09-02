# `src/miniquake/screen.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.screen`](Package-miniquake-screen-130918523.md)

Reachable from entry: **yes**

## Imports

- `miniquake/console.ml` as `console` → [src/miniquake/console.ml](File-src-miniquake-console-ml-296415787.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/gl_vidnt.ml` as `glvid` → [src/miniquake/gl_vidnt.ml](File-src-miniquake-gl-vidnt-ml-1573847321.md)
- `miniquake/keys.ml` as `keys` → [src/miniquake/keys.ml](File-src-miniquake-keys-ml-299795526.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/menu.ml` as `menu` → [src/miniquake/menu.ml](File-src-miniquake-menu-ml-537231111.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/draw2d.ml` as `draw` → [src/miniquake/render/draw2d.ml](File-src-miniquake-render-draw2d-ml-1547120567.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render_ui_contract.ml` as `renderUiContract` → [src/miniquake/render_ui_contract.ml](File-src-miniquake-render-ui-contract-ml-1308372980.md)
- `miniquake/statusbar.ml` as `statusbar` → [src/miniquake/statusbar.ml](File-src-miniquake-statusbar-ml-945138613.md)
- `miniquake/view.ml` as `view` → [src/miniquake/view.ml](File-src-miniquake-view-ml-709264737.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="global-global-miniquake-screen-block-drawing-block-drawing-src-miniquake-screen-ml-1342643941"></a>
### block_drawing

```ml
block_drawing
```

Tracks the module-level block drawing state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L73)

<a id="function-function-miniquake-screen-buildtga-function-buildtga-width-height-rgba-src-miniquake-screen-ml-2021943760"></a>
### BuildTga

```ml
function BuildTga(width, height, rgba)
```

Create and initialize tga.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `rgba` | `dynamic` | — | The rgba input consumed by `BuildTga`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L729)

<a id="function-function-miniquake-screen-calcfov-function-calcfov-fov-x-width-height-src-miniquake-screen-ml-155068680"></a>
### CalcFov

```ml
function CalcFov(fov_x, width, height)
```

Implements the `CalcFov` operation for `miniquake.screen` (calc fov).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fov_x` | `dynamic` | — | The fov x input consumed by `CalcFov`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L433)

<a id="function-function-miniquake-screen-centerstringtrace-function-centerstringtrace-text-width-height-linecount-remaining-src-miniquake-screen-ml-944149702"></a>
### CenterStringTrace

```ml
function CenterStringTrace(text, width, height, lineCount, remaining)
```

Implements the `CenterStringTrace` operation for `miniquake.screen` (center string trace).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `lineCount` | `dynamic` | — | Number of entries or units to process. |
| `remaining` | `dynamic` | — | The remaining input consumed by `CenterStringTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L343)

<a id="global-global-miniquake-screen-clearconsole-clearconsole-src-miniquake-screen-ml-1260572689"></a>
### clearconsole

```ml
clearconsole
```

Tracks the module-level clearconsole state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L55)

<a id="global-global-miniquake-screen-clearnotify-clearnotify-src-miniquake-screen-ml-1712934917"></a>
### clearnotify

```ml
clearnotify
```

Tracks the module-level clearnotify state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L57)

<a id="function-function-miniquake-screen-drawblend-function-drawblend-viewstate-width-height-src-miniquake-screen-ml-1311686732"></a>
### drawBlend

```ml
function drawBlend(viewState, width, height)
```

Render blend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewState` | `dynamic` | — | Mutable state used by `drawBlend`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L204)

<a id="function-function-miniquake-screen-drawcenter-function-drawcenter-consolestate-width-height-src-miniquake-screen-ml-2062213932"></a>
### drawCenter

```ml
function drawCenter(consoleState, width, height)
```

Render center.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `drawCenter`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L272)

<a id="function-function-miniquake-screen-drawconsoleheight-function-drawconsoleheight-consolestate-width-height-visibleheight-src-miniquake-screen-ml-1934424423"></a>
### drawConsoleHeight

```ml
function drawConsoleHeight(consoleState, width, height, visibleHeight)
```

Render console height.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `drawConsoleHeight`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `visibleHeight` | `dynamic` | — | The visible height input consumed by `drawConsoleHeight`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L665)

<a id="function-function-miniquake-screen-drawcrosshair-function-drawcrosshair-width-height-src-miniquake-screen-ml-976748286"></a>
### drawCrosshair

```ml
function drawCrosshair(width, height)
```

Render crosshair.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L194)

<a id="function-function-miniquake-screen-drawhud-function-drawhud-consolestate-menustate-player-width-height-registry-src-miniquake-screen-ml-2072561128"></a>
### drawHud

```ml
function drawHud(consoleState, menuState, player, width, height, registry)
```

Render hud.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `drawHud`. |
| `menuState` | `dynamic` | — | Mutable state used by `drawHud`. |
| `player` | `dynamic` | — | The player input consumed by `drawHud`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `registry` | `dynamic` | — | The registry input consumed by `drawHud`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L221)

<a id="function-function-miniquake-screen-drawnotify-function-drawnotify-consolestate-width-height-src-miniquake-screen-ml-170756964"></a>
### drawNotify

```ml
function drawNotify(consoleState, width, height)
```

Render notify.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `drawNotify`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L235)

<a id="function-function-miniquake-screen-initialize-function-initialize-consolestate-menustate-filesystem-palette-width-height-registry-src-miniquake-screen-ml-1432374079"></a>
### initialize

```ml
function initialize(consoleState, menuState, filesystem, palette, width, height, registry)
```

Initializes ialize for `miniquake.screen`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `initialize`. |
| `menuState` | `dynamic` | — | Mutable state used by `initialize`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `initialize`. |
| `palette` | `dynamic` | — | The palette input consumed by `initialize`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `registry` | `dynamic` | — | The registry input consumed by `initialize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L125)

<a id="global-global-miniquake-screen-lastscreencommands-lastscreencommands-src-miniquake-screen-ml-602401889"></a>
### lastScreenCommands

```ml
lastScreenCommands
```

Tracks the module-level last screen commands state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L109)

<a id="global-global-miniquake-screen-oldfov-oldfov-src-miniquake-screen-ml-346870293"></a>
### oldfov

```ml
oldfov
```

Tracks the module-level oldfov state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L37)

<a id="global-global-miniquake-screen-oldrefdefheight-oldrefdefheight-src-miniquake-screen-ml-1371372609"></a>
### oldRefdefHeight

```ml
oldRefdefHeight
```

Tracks the module-level old refdef height state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L41)

<a id="global-global-miniquake-screen-oldrefdefintermission-oldrefdefintermission-src-miniquake-screen-ml-264220677"></a>
### oldRefdefIntermission

```ml
oldRefdefIntermission
```

Tracks the module-level old refdef intermission state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L43)

<a id="global-global-miniquake-screen-oldrefdefwidth-oldrefdefwidth-src-miniquake-screen-ml-1304379199"></a>
### oldRefdefWidth

```ml
oldRefdefWidth
```

Tracks the module-level old refdef width state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L39)

<a id="global-global-miniquake-screen-oldscreensize-oldscreensize-src-miniquake-screen-ml-91437381"></a>
### oldscreensize

```ml
oldscreensize
```

Tracks the module-level oldscreensize state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L35)

<a id="function-function-miniquake-screen-render-function-render-consolestate-menustate-viewstate-player-width-height-mapname-showcrosshair-realtime-registry-src-miniquake-screen-ml-1173258369"></a>
### render

```ml
function render(consoleState, menuState, viewState, player, width, height, mapName, showCrosshair, realtime, registry)
```

Implements the `render` operation for `miniquake.screen` (render).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `render`. |
| `menuState` | `dynamic` | — | Mutable state used by `render`. |
| `viewState` | `dynamic` | — | Mutable state used by `render`. |
| `player` | `dynamic` | — | The player input consumed by `render`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `showCrosshair` | `dynamic` | — | The show crosshair input consumed by `render`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `render`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1268)

<a id="global-global-miniquake-screen-sb-lines-sb-lines-src-miniquake-screen-ml-745106219"></a>
### sb_lines

```ml
sb_lines
```

Tracks the module-level sb lines state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L59)

<a id="function-function-miniquake-screen-scr-beginloadingplaque-function-scr-beginloadingplaque-consolestate-realtime-connected-signon-src-miniquake-screen-ml-1432773173"></a>
### SCR_BeginLoadingPlaque

```ml
function SCR_BeginLoadingPlaque(consoleState, realtime, connected, signon)
```

Mirror Quake's SCR_BeginLoadingPlaque routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_BeginLoadingPlaque`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `connected` | `dynamic` | — | The connected input consumed by `SCR_BeginLoadingPlaque`. |
| `signon` | `dynamic` | — | The signon input consumed by `SCR_BeginLoadingPlaque`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L792)

<a id="function-function-miniquake-screen-scr-bringdownconsole-function-scr-bringdownconsole-consolestate-height-frametime-registry-viewstate-src-miniquake-screen-ml-1797394831"></a>
### SCR_BringDownConsole

```ml
function SCR_BringDownConsole(consoleState, height, frameTime, registry, viewState)
```

Mirror Quake's SCR_BringDownConsole routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_BringDownConsole`. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_BringDownConsole`. |
| `viewState` | `dynamic` | — | Mutable state used by `SCR_BringDownConsole`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L893)

<a id="function-function-miniquake-screen-scr-calcrefdef-function-scr-calcrefdef-width-height-registry-intermission-src-miniquake-screen-ml-328755431"></a>
### SCR_CalcRefdef

```ml
function SCR_CalcRefdef(width, height, registry, intermission)
```

Mirror Quake's SCR_CalcRefdef routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_CalcRefdef`. |
| `intermission` | `dynamic` | — | The intermission input consumed by `SCR_CalcRefdef`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L446)

<a id="global-global-miniquake-screen-scr-center-lines-scr-center-lines-src-miniquake-screen-ml-1912515757"></a>
### scr_center_lines

```ml
scr_center_lines
```

Tracks the module-level scr center lines state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L83)

<a id="function-function-miniquake-screen-scr-centerprint-function-scr-centerprint-consolestate-text-currenttime-src-miniquake-screen-ml-1780138020"></a>
### SCR_CenterPrint

```ml
function SCR_CenterPrint(consoleState, text, currentTime)
```

Mirror Quake's SCR_CenterPrint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_CenterPrint`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L316)

<a id="global-global-miniquake-screen-scr-centerstring-scr-centerstring-src-miniquake-screen-ml-1646548271"></a>
### scr_centerstring

```ml
scr_centerstring
```

Tracks the module-level scr centerstring state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L77)

<a id="global-global-miniquake-screen-scr-centertime-off-scr-centertime-off-src-miniquake-screen-ml-1136558999"></a>
### scr_centertime_off

```ml
scr_centertime_off
```

Tracks the module-level scr centertime off state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L81)

<a id="global-global-miniquake-screen-scr-centertime-start-scr-centertime-start-src-miniquake-screen-ml-154430737"></a>
### scr_centertime_start

```ml
scr_centertime_start
```

Tracks the module-level scr centertime start state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L79)

<a id="function-function-miniquake-screen-scr-checkdrawcenterstring-function-scr-checkdrawcenterstring-width-height-currenttime-frametime-gameinput-src-miniquake-screen-ml-1464117958"></a>
### SCR_CheckDrawCenterString

```ml
function SCR_CheckDrawCenterString(width, height, currentTime, frameTime, gameInput)
```

Mirror Quake's SCR_CheckDrawCenterString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gameInput` | `dynamic` | — | The game input input consumed by `SCR_CheckDrawCenterString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L419)

<a id="global-global-miniquake-screen-scr-con-current-scr-con-current-src-miniquake-screen-ml-1065368177"></a>
### scr_con_current

```ml
scr_con_current
```

Tracks the module-level scr con current state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L31)

<a id="function-function-miniquake-screen-scr-configureclient-function-scr-configureclient-clientstate-src-miniquake-screen-ml-1092681835"></a>
### SCR_ConfigureClient

```ml
function SCR_ConfigureClient(clientState)
```

Mirror Quake's SCR_ConfigureClient routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientState` | `dynamic` | — | Mutable state used by `SCR_ConfigureClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L163)

<a id="global-global-miniquake-screen-scr-conlines-scr-conlines-src-miniquake-screen-ml-352608161"></a>
### scr_conlines

```ml
scr_conlines
```

Tracks the module-level scr conlines state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L33)

<a id="function-function-miniquake-screen-scr-consoleslidepixels-function-scr-consoleslidepixels-width-height-frametime-registry-src-miniquake-screen-ml-66822527"></a>
### SCR_ConsoleSlidePixels

```ml
function SCR_ConsoleSlidePixels(width, height, frameTime, registry)
```

scr_conspeed is expressed in the original UI's logical pixels per second. The console itself is enlarged by an integral factor on high-resolution displays, so its physical travel must use that same factor. Otherwise a 1080p/4K console takes two to four times as long to open or close.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_ConsoleSlidePixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L550)

<a id="function-function-miniquake-screen-scr-consumetransitionclear-function-scr-consumetransitionclear-src-miniquake-screen-ml-1663352493"></a>
### SCR_ConsumeTransitionClear

```ml
function SCR_ConsumeTransitionClear()
```

Refdef and overlay transitions can expose pixels that belonged to a smaller viewport or an older status bar on another swap-chain page. Clear each buffered page once; steady-state frames retain GLQuake's gl_clear behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L954)

<a id="global-global-miniquake-screen-scr-copyeverything-scr-copyeverything-src-miniquake-screen-ml-432070099"></a>
### scr_copyeverything

```ml
scr_copyeverything
```

Tracks the module-level scr copyeverything state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L29)

<a id="global-global-miniquake-screen-scr-copytop-scr-copytop-src-miniquake-screen-ml-1459277525"></a>
### scr_copytop

```ml
scr_copytop
```

Tracks the module-level scr copytop state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L27)

<a id="function-function-miniquake-screen-scr-differentialsetblocked-function-scr-differentialsetblocked-value-src-miniquake-screen-ml-409655952"></a>
### SCR_DifferentialSetBlocked

```ml
function SCR_DifferentialSetBlocked(value)
```

Mirror Quake's SCR_DifferentialSetBlocked routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SCR_DifferentialSetBlocked`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1021)

<a id="function-function-miniquake-screen-scr-differentialsetconsole-function-scr-differentialsetconsole-current-lines-src-miniquake-screen-ml-803189977"></a>
### SCR_DifferentialSetConsole

```ml
function SCR_DifferentialSetConsole(current, lines)
```

Mirror Quake's SCR_DifferentialSetConsole routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `current` | `dynamic` | — | The current input consumed by `SCR_DifferentialSetConsole`. |
| `lines` | `dynamic` | — | The lines input consumed by `SCR_DifferentialSetConsole`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L994)

<a id="function-function-miniquake-screen-scr-differentialsetdrawloading-function-scr-differentialsetdrawloading-value-src-miniquake-screen-ml-787487880"></a>
### SCR_DifferentialSetDrawLoading

```ml
function SCR_DifferentialSetDrawLoading(value)
```

Mirror Quake's SCR_DifferentialSetDrawLoading routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SCR_DifferentialSetDrawLoading`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L985)

<a id="function-function-miniquake-screen-scr-differentialseteraselines-function-scr-differentialseteraselines-value-src-miniquake-screen-ml-369543610"></a>
### SCR_DifferentialSetEraseLines

```ml
function SCR_DifferentialSetEraseLines(value)
```

Deterministic differential hooks. They expose logical C globals without putting renderer or platform behavior into the native bridge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SCR_DifferentialSetEraseLines`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L969)

<a id="function-function-miniquake-screen-scr-differentialsetinitialized-function-scr-differentialsetinitialized-value-src-miniquake-screen-ml-128998776"></a>
### SCR_DifferentialSetInitialized

```ml
function SCR_DifferentialSetInitialized(value)
```

Set the initialized flag for deterministic guard-order fixtures. Production startup continues to own this state through SCR_Init and shutdown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SCR_DifferentialSetInitialized`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1030)

<a id="function-function-miniquake-screen-scr-differentialsetnotify-function-scr-differentialsetnotify-text-src-miniquake-screen-ml-1360120842"></a>
### SCR_DifferentialSetNotify

```ml
function SCR_DifferentialSetNotify(text)
```

Mirror Quake's SCR_DifferentialSetNotify routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1003)

<a id="function-function-miniquake-screen-scr-differentialsettile-function-scr-differentialsettile-viewrectangle-statuslines-src-miniquake-screen-ml-1541879388"></a>
### SCR_DifferentialSetTile

```ml
function SCR_DifferentialSetTile(viewRectangle, statusLines)
```

Mirror Quake's SCR_DifferentialSetTile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewRectangle` | `dynamic` | — | The view rectangle input consumed by `SCR_DifferentialSetTile`. |
| `statusLines` | `dynamic` | — | The status lines input consumed by `SCR_DifferentialSetTile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1012)

<a id="function-function-miniquake-screen-scr-differentialsetturtlecount-function-scr-differentialsetturtlecount-value-src-miniquake-screen-ml-887033336"></a>
### SCR_DifferentialSetTurtleCount

```ml
function SCR_DifferentialSetTurtleCount(value)
```

Mirror Quake's SCR_DifferentialSetTurtleCount routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SCR_DifferentialSetTurtleCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L977)

<a id="function-function-miniquake-screen-scr-differentialstate-function-scr-differentialstate-src-miniquake-screen-ml-1016787479"></a>
### SCR_DifferentialState

```ml
function SCR_DifferentialState()
```

Mirror Quake's SCR_DifferentialState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1037)

<a id="global-global-miniquake-screen-scr-disabled-for-loading-scr-disabled-for-loading-src-miniquake-screen-ml-64603121"></a>
### scr_disabled_for_loading

```ml
scr_disabled_for_loading
```

Tracks the module-level scr disabled for loading state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L63)

<a id="global-global-miniquake-screen-scr-disabled-time-scr-disabled-time-src-miniquake-screen-ml-981880045"></a>
### scr_disabled_time

```ml
scr_disabled_time
```

Tracks the module-level scr disabled time state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L67)

<a id="function-function-miniquake-screen-scr-drawcenterstring-function-scr-drawcenterstring-width-height-currenttime-src-miniquake-screen-ml-2074778850"></a>
### SCR_DrawCenterString

```ml
function SCR_DrawCenterString(width, height, currentTime)
```

Mirror Quake's SCR_DrawCenterString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L375)

<a id="function-function-miniquake-screen-scr-drawconsole-function-scr-drawconsole-consolestate-width-height-gameormessageinput-src-miniquake-screen-ml-1437156502"></a>
### SCR_DrawConsole

```ml
function SCR_DrawConsole(consoleState, width, height, gameOrMessageInput)
```

Mirror Quake's SCR_DrawConsole routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_DrawConsole`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `gameOrMessageInput` | `dynamic` | — | The game or message input input consumed by `SCR_DrawConsole`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L713)

<a id="global-global-miniquake-screen-scr-drawdialog-scr-drawdialog-src-miniquake-screen-ml-819120847"></a>
### scr_drawdialog

```ml
scr_drawdialog
```

Tracks the module-level scr drawdialog state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L91)

<a id="function-function-miniquake-screen-scr-drawloading-function-scr-drawloading-width-height-src-miniquake-screen-ml-500452776"></a>
### SCR_DrawLoading

```ml
function SCR_DrawLoading(width, height)
```

Mirror Quake's SCR_DrawLoading routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L614)

<a id="global-global-miniquake-screen-scr-drawloading-scr-drawloading-src-miniquake-screen-ml-1186077925"></a>
### scr_drawloading

```ml
scr_drawloading
```

Tracks the module-level scr drawloading state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L65)

<a id="function-function-miniquake-screen-scr-drawnet-function-scr-drawnet-realtime-lastmessagetime-demoplayback-connected-localserveractive-src-miniquake-screen-ml-418897119"></a>
### SCR_DrawNet

```ml
function SCR_DrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive)
```

Mirror Quake's SCR_DrawNet routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `lastMessageTime` | `dynamic` | — | Time value used by the operation. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `SCR_DrawNet`. |
| `connected` | `dynamic` | — | The connected input consumed by `SCR_DrawNet`. |
| `localServerActive` | `dynamic` | — | The local server active input consumed by `SCR_DrawNet`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L594)

<a id="function-function-miniquake-screen-scr-drawnotifystring-function-scr-drawnotifystring-width-height-src-miniquake-screen-ml-1725961534"></a>
### SCR_DrawNotifyString

```ml
function SCR_DrawNotifyString(width, height)
```

Mirror Quake's SCR_DrawNotifyString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L839)

<a id="function-function-miniquake-screen-scr-drawpause-function-scr-drawpause-paused-width-height-src-miniquake-screen-ml-1028983018"></a>
### SCR_DrawPause

```ml
function SCR_DrawPause(paused, width, height)
```

Mirror Quake's SCR_DrawPause routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `paused` | `dynamic` | — | The paused input consumed by `SCR_DrawPause`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L604)

<a id="function-function-miniquake-screen-scr-drawram-function-scr-drawram-cachethrash-src-miniquake-screen-ml-1112227441"></a>
### SCR_DrawRam

```ml
function SCR_DrawRam(cacheThrash)
```

Mirror Quake's SCR_DrawRam routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cacheThrash` | `dynamic` | — | The cache thrash input consumed by `SCR_DrawRam`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L560)

<a id="function-function-miniquake-screen-scr-drawturtle-function-scr-drawturtle-frametime-src-miniquake-screen-ml-1225660055"></a>
### SCR_DrawTurtle

```ml
function SCR_DrawTurtle(frameTime)
```

Mirror Quake's SCR_DrawTurtle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L567)

<a id="function-function-miniquake-screen-scr-endloadingplaque-function-scr-endloadingplaque-consolestate-src-miniquake-screen-ml-1272754295"></a>
### SCR_EndLoadingPlaque

```ml
function SCR_EndLoadingPlaque(consoleState)
```

Mirror Quake's SCR_EndLoadingPlaque routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_EndLoadingPlaque`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L810)

<a id="global-global-miniquake-screen-scr-erase-center-scr-erase-center-src-miniquake-screen-ml-1115740235"></a>
### scr_erase_center

```ml
scr_erase_center
```

Tracks the module-level scr erase center state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L87)

<a id="global-global-miniquake-screen-scr-erase-lines-scr-erase-lines-src-miniquake-screen-ml-685022393"></a>
### scr_erase_lines

```ml
scr_erase_lines
```

Tracks the module-level scr erase lines state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L85)

<a id="function-function-miniquake-screen-scr-finishloadingafterupdates-function-scr-finishloadingafterupdates-count-src-miniquake-screen-ml-1636073494"></a>
### SCR_FinishLoadingAfterUpdates

```ml
function SCR_FinishLoadingAfterUpdates(count)
```

Keep the plaque over a small number of ordinary Host_Frame updates. These frames perform the unavoidable first QuakeC/server and GPU-driver work in normal order, but their final swap still shows LOADING instead of a hitch in playable output. No extra frames are simulated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L826)

<a id="global-global-miniquake-screen-scr-fullupdate-scr-fullupdate-src-miniquake-screen-ml-496675343"></a>
### scr_fullupdate

```ml
scr_fullupdate
```

Tracks the module-level scr fullupdate state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L53)

<a id="function-function-miniquake-screen-scr-init-function-scr-init-filesystem-registry-width-height-src-miniquake-screen-ml-999540730"></a>
### SCR_Init

```ml
function SCR_Init(filesystem, registry, width, height)
```

Mirror Quake's SCR_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `SCR_Init`. |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_Init`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L524)

<a id="global-global-miniquake-screen-scr-initialized-scr-initialized-src-miniquake-screen-ml-1439980541"></a>
### scr_initialized

```ml
scr_initialized
```

Tracks the module-level scr initialized state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L45)

<a id="global-global-miniquake-screen-scr-intermission-scr-intermission-src-miniquake-screen-ml-1377740327"></a>
### scr_intermission

```ml
scr_intermission
```

Tracks the module-level scr intermission state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L95)

<a id="function-function-miniquake-screen-scr-intermissionmode-inline-function-scr-intermissionmode-src-miniquake-screen-ml-1059928674"></a>
### SCR_IntermissionMode

```ml
inline function SCR_IntermissionMode()
```

Mirror Quake's SCR_IntermissionMode routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L962)

<a id="global-global-miniquake-screen-scr-loading-pending-scr-loading-pending-src-miniquake-screen-ml-2007998605"></a>
### scr_loading_pending

```ml
scr_loading_pending
```

Tracks the module-level scr loading pending state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L69)

<a id="global-global-miniquake-screen-scr-loading-warmup-updates-scr-loading-warmup-updates-src-miniquake-screen-ml-1190070163"></a>
### scr_loading_warmup_updates

```ml
scr_loading_warmup_updates
```

Tracks the module-level scr loading warmup updates state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L71)

<a id="function-function-miniquake-screen-scr-modalmessage-function-scr-modalmessage-text-keycode-dedicated-src-miniquake-screen-ml-2081210753"></a>
### SCR_ModalMessage

```ml
function SCR_ModalMessage(text, keyCode, dedicated)
```

The original blocks in a platform event loop.  MiniLang's host owns that loop, so a key code is supplied when available; void means "still pending".

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `keyCode` | `dynamic` | — | The key code input consumed by `SCR_ModalMessage`. |
| `dedicated` | `dynamic` | — | The dedicated input consumed by `SCR_ModalMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L875)

<a id="global-global-miniquake-screen-scr-net-scr-net-src-miniquake-screen-ml-1302461741"></a>
### scr_net

```ml
scr_net
```

Tracks the module-level scr net state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L49)

<a id="global-global-miniquake-screen-scr-notifystring-scr-notifystring-src-miniquake-screen-ml-229677879"></a>
### scr_notifystring

```ml
scr_notifystring
```

Tracks the module-level scr notifystring state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L89)

<a id="function-function-miniquake-screen-scr-precachepictures-function-scr-precachepictures-src-miniquake-screen-ml-2058349365"></a>
### SCR_PrecachePictures

```ml
function SCR_PrecachePictures()
```

Cache screen/status-bar pictures whose first appearance may be much later than Draw_Init (pause, intermission, scoreboard and finale screens).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L149)

<a id="global-global-miniquake-screen-scr-ram-scr-ram-src-miniquake-screen-ml-396220221"></a>
### scr_ram

```ml
scr_ram
```

Tracks the module-level scr ram state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L47)

<a id="function-function-miniquake-screen-scr-screenshot-f-function-scr-screenshot-f-filesystem-x-y-width-height-src-miniquake-screen-ml-1474071938"></a>
### SCR_ScreenShot_f

```ml
function SCR_ScreenShot_f(filesystem, x, y, width, height)
```

Mirror Quake's SCR_ScreenShot_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `SCR_ScreenShot_f`. |
| `x` | `dynamic` | — | The x input consumed by `SCR_ScreenShot_f`. |
| `y` | `dynamic` | — | The y input consumed by `SCR_ScreenShot_f`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L776)

<a id="function-function-miniquake-screen-scr-screenshotfailure-function-scr-screenshotfailure-src-miniquake-screen-ml-589411987"></a>
### SCR_ScreenshotFailure

```ml
function SCR_ScreenshotFailure()
```

Mirror Quake's SCR_ScreenshotFailure routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L765)

<a id="function-function-miniquake-screen-scr-setcommandtraceenabled-function-scr-setcommandtraceenabled-enabled-src-miniquake-screen-ml-1900687656"></a>
### SCR_SetCommandTraceEnabled

```ml
function SCR_SetCommandTraceEnabled(enabled)
```

Enable command recording for differential fixtures. The production host disables this diagnostic-only allocation stream after creating a session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1086)

<a id="function-function-miniquake-screen-scr-setintermission-function-scr-setintermission-mode-text-consolestate-currenttime-src-miniquake-screen-ml-1450679579"></a>
### SCR_SetIntermission

```ml
function SCR_SetIntermission(mode, text, consoleState, currentTime)
```

Mirror Quake's SCR_SetIntermission routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `SCR_SetIntermission`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_SetIntermission`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L939)

<a id="function-function-miniquake-screen-scr-setuptodrawconsole-function-scr-setuptodrawconsole-consolestate-height-frametime-registry-forcedup-consoleinput-numpages-src-miniquake-screen-ml-274235598"></a>
### SCR_SetUpToDrawConsole

```ml
function SCR_SetUpToDrawConsole(consoleState, height, frameTime, registry, forcedUp, consoleInput, numPages)
```

Mirror Quake's SCR_SetUpToDrawConsole routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_SetUpToDrawConsole`. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_SetUpToDrawConsole`. |
| `forcedUp` | `dynamic` | — | The forced up input consumed by `SCR_SetUpToDrawConsole`. |
| `consoleInput` | `dynamic` | — | The console input input consumed by `SCR_SetUpToDrawConsole`. |
| `numPages` | `dynamic` | — | The num pages input consumed by `SCR_SetUpToDrawConsole`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L629)

<a id="function-function-miniquake-screen-scr-shoulddrawnet-inline-function-scr-shoulddrawnet-realtime-lastmessagetime-demoplayback-connected-localserveractive-src-miniquake-screen-ml-606678728"></a>
### SCR_ShouldDrawNet

```ml
inline function SCR_ShouldDrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive)
```

Mirror Quake's SCR_ShouldDrawNet routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `lastMessageTime` | `dynamic` | — | Time value used by the operation. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `SCR_ShouldDrawNet`. |
| `connected` | `dynamic` | — | The connected input consumed by `SCR_ShouldDrawNet`. |
| `localServerActive` | `dynamic` | — | The local server active input consumed by `SCR_ShouldDrawNet`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L582)

<a id="function-function-miniquake-screen-scr-shouldskipupdate-function-scr-shouldskipupdate-realtime-src-miniquake-screen-ml-1740282674"></a>
### SCR_ShouldSkipUpdate

```ml
function SCR_ShouldSkipUpdate(realtime)
```

Mirror Quake's SCR_ShouldSkipUpdate routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1061)

<a id="function-function-miniquake-screen-scr-sizedown-function-scr-sizedown-src-miniquake-screen-ml-1419603085"></a>
### SCR_SizeDown

```ml
function SCR_SizeDown()
```

Mirror Quake's SCR_SizeDown routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L515)

<a id="function-function-miniquake-screen-scr-sizedown-f-function-scr-sizedown-f-registry-src-miniquake-screen-ml-1817114636"></a>
### SCR_SizeDown_f

```ml
function SCR_SizeDown_f(registry)
```

Mirror Quake's SCR_SizeDown_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_SizeDown_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L504)

<a id="function-function-miniquake-screen-scr-sizeup-function-scr-sizeup-src-miniquake-screen-ml-1395832929"></a>
### SCR_SizeUp

```ml
function SCR_SizeUp()
```

Mirror Quake's SCR_SizeUp routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L510)

<a id="function-function-miniquake-screen-scr-sizeup-f-function-scr-sizeup-f-registry-src-miniquake-screen-ml-451161728"></a>
### SCR_SizeUp_f

```ml
function SCR_SizeUp_f(registry)
```

Mirror Quake's SCR_SizeUp_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_SizeUp_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L497)

<a id="global-global-miniquake-screen-scr-skipupdate-scr-skipupdate-src-miniquake-screen-ml-821081271"></a>
### scr_skipupdate

```ml
scr_skipupdate
```

Tracks the module-level scr skipupdate state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L75)

<a id="function-function-miniquake-screen-scr-tileclear-function-scr-tileclear-width-height-src-miniquake-screen-ml-889752486"></a>
### SCR_TileClear

```ml
function SCR_TileClear(width, height)
```

Mirror Quake's SCR_TileClear routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L909)

<a id="global-global-miniquake-screen-scr-transition-clear-frames-scr-transition-clear-frames-src-miniquake-screen-ml-1979831133"></a>
### scr_transition_clear_frames

```ml
scr_transition_clear_frames
```

Tracks the module-level scr transition clear frames state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L97)

<a id="global-global-miniquake-screen-scr-turtle-scr-turtle-src-miniquake-screen-ml-2102987923"></a>
### scr_turtle

```ml
scr_turtle
```

Tracks the module-level scr turtle state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L51)

<a id="global-global-miniquake-screen-scr-turtle-count-scr-turtle-count-src-miniquake-screen-ml-1165361703"></a>
### scr_turtle_count

```ml
scr_turtle_count
```

Tracks the module-level scr turtle count state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L93)

<a id="function-function-miniquake-screen-scr-updatescreen-function-scr-updatescreen-consolestate-menustate-viewstate-player-width-height-mapname-showcrosshair-realtime-frametime-registry-connected-localserveractive-signon-paused-lastmessagetime-demoplayback-cachethrash-gameinput-consoleinput-src-miniquake-screen-ml-1424653509"></a>
### SCR_UpdateScreen

```ml
function SCR_UpdateScreen(consoleState, menuState, viewState, player, width, height, mapName, showCrosshair, realtime, frameTime, registry, connected, localServerActive, signon, paused, lastMessageTime, demoPlayback, cacheThrash, gameInput, consoleInput)
```

Mirror Quake's SCR_UpdateScreen routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `SCR_UpdateScreen`. |
| `menuState` | `dynamic` | — | Mutable state used by `SCR_UpdateScreen`. |
| `viewState` | `dynamic` | — | Mutable state used by `SCR_UpdateScreen`. |
| `player` | `dynamic` | — | The player input consumed by `SCR_UpdateScreen`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `showCrosshair` | `dynamic` | — | The show crosshair input consumed by `SCR_UpdateScreen`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `SCR_UpdateScreen`. |
| `connected` | `dynamic` | — | The connected input consumed by `SCR_UpdateScreen`. |
| `localServerActive` | `dynamic` | — | The local server active input consumed by `SCR_UpdateScreen`. |
| `signon` | `dynamic` | — | The signon input consumed by `SCR_UpdateScreen`. |
| `paused` | `dynamic` | — | The paused input consumed by `SCR_UpdateScreen`. |
| `lastMessageTime` | `dynamic` | — | Time value used by the operation. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `SCR_UpdateScreen`. |
| `cacheThrash` | `dynamic` | — | The cache thrash input consumed by `SCR_UpdateScreen`. |
| `gameInput` | `dynamic` | — | The game input input consumed by `SCR_UpdateScreen`. |
| `consoleInput` | `dynamic` | — | The console input input consumed by `SCR_UpdateScreen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1130)

<a id="function-function-miniquake-screen-scr-updatewholescreen-function-scr-updatewholescreen-src-miniquake-screen-ml-1379659235"></a>
### SCR_UpdateWholeScreen

```ml
function SCR_UpdateWholeScreen()
```

Mirror Quake's SCR_UpdateWholeScreen routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1094)

<a id="global-global-miniquake-screen-scr-vrect-scr-vrect-src-miniquake-screen-ml-539522597"></a>
### scr_vrect

```ml
scr_vrect
```

Tracks the module-level scr vrect state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L61)

<a id="global-global-miniquake-screen-screenbasepalette-screenbasepalette-src-miniquake-screen-ml-1144399169"></a>
### screenBasePalette

```ml
screenBasePalette
```

Tracks the module-level screen base palette state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L107)

<a id="global-global-miniquake-screen-screenclient-screenclient-src-miniquake-screen-ml-447945731"></a>
### screenClient

```ml
screenClient
```

Tracks the module-level screen client state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L103)

<a id="function-function-miniquake-screen-screencommandtrace-function-screencommandtrace-src-miniquake-screen-ml-1875570013"></a>
### ScreenCommandTrace

```ml
function ScreenCommandTrace()
```

Implements the `ScreenCommandTrace` operation for `miniquake.screen` (screen command trace).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1079)

<a id="global-global-miniquake-screen-screencommandtraceenabled-screencommandtraceenabled-src-miniquake-screen-ml-142211461"></a>
### screenCommandTraceEnabled

```ml
screenCommandTraceEnabled
```

Tracks the module-level screen command trace enabled state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L111)

<a id="global-global-miniquake-screen-screenconsole-screenconsole-src-miniquake-screen-ml-377333901"></a>
### screenConsole

```ml
screenConsole
```

Tracks the module-level screen console state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L105)

<a id="function-function-miniquake-screen-screencvar-function-screencvar-name-fallback-src-miniquake-screen-ml-1113188850"></a>
### screenCvar

```ml
function screenCvar(name, fallback)
```

============================================================================= gl_screen.c compatibility surface =============================================================================

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L305)

<a id="global-global-miniquake-screen-screenfilesystem-screenfilesystem-src-miniquake-screen-ml-193633659"></a>
### screenFilesystem

```ml
screenFilesystem
```

Tracks the module-level screen filesystem state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L99)

<a id="function-function-miniquake-screen-screenoverlayorder-function-screenoverlayorder-dialog-loading-intermission-gameinput-src-miniquake-screen-ml-1161371611"></a>
### ScreenOverlayOrder

```ml
function ScreenOverlayOrder(dialog, loading, intermission, gameInput)
```

Implements the `ScreenOverlayOrder` operation for `miniquake.screen` (screen overlay order).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dialog` | `dynamic` | — | The dialog input consumed by `ScreenOverlayOrder`. |
| `loading` | `dynamic` | — | The loading input consumed by `ScreenOverlayOrder`. |
| `intermission` | `dynamic` | — | The intermission input consumed by `ScreenOverlayOrder`. |
| `gameInput` | `dynamic` | — | The game input input consumed by `ScreenOverlayOrder`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L1105)

<a id="global-global-miniquake-screen-screenrealtime-screenrealtime-src-miniquake-screen-ml-274445663"></a>
### screenRealtime

```ml
screenRealtime
```

Tracks the module-level screen realtime state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L113)

<a id="global-global-miniquake-screen-screenregistry-screenregistry-src-miniquake-screen-ml-1181081563"></a>
### screenRegistry

```ml
screenRegistry
```

Tracks the module-level screen registry state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L101)

<a id="function-function-miniquake-screen-screenshotname-function-screenshotname-filesystem-src-miniquake-screen-ml-551126748"></a>
### screenshotName

```ml
function screenshotName(filesystem)
```

Return screenshot name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `screenshotName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L752)

<a id="global-global-miniquake-screen-screenvideowidth-screenvideowidth-src-miniquake-screen-ml-1412220595"></a>
### screenVideoWidth

```ml
screenVideoWidth
```

Tracks the module-level screen video width state owned by `miniquake.screen`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L115)

<a id="function-function-miniquake-screen-shutdown-function-shutdown-consolestate-menustate-src-miniquake-screen-ml-534164509"></a>
### shutdown

```ml
function shutdown(consoleState, menuState)
```

Implements the `shutdown` operation for `miniquake.screen` (shutdown).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleState` | `dynamic` | — | Mutable state used by `shutdown`. |
| `menuState` | `dynamic` | — | Mutable state used by `shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/screen.ml#L172)
