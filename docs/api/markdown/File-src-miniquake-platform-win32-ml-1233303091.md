# `src/miniquake/platform/win32.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.platform.win32`](Package-miniquake-platform-win32-1224102725.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-platform-win32-activate-function-activate-active-minimizedvalue-src-miniquake-platform-win32-ml-283367103"></a>
### activate

```ml
function activate(active, minimizedValue)
```

Implements the `activate` operation for `miniquake.platform.win32` (activate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `activate`. |
| `minimizedValue` | `dynamic` | — | The minimized value input consumed by `activate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L217)

<a id="function-function-miniquake-platform-win32-capturemouse-function-capturemouse-enabled-src-miniquake-platform-win32-ml-1087839043"></a>
### captureMouse

```ml
function captureMouse(enabled)
```

Implements the `captureMouse` operation for `miniquake.platform.win32` (capture mouse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L234)

<a id="function-function-miniquake-platform-win32-centercursor-function-centercursor-src-miniquake-platform-win32-ml-1045877866"></a>
### centerCursor

```ml
function centerCursor()
```

Implements the `centerCursor` operation for `miniquake.platform.win32` (center cursor).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L273)

<a id="function-function-miniquake-platform-win32-configuredisplaymode-function-configuredisplaymode-widthvalue-heightvalue-bpp-frequency-fullscreen-usecurrent-src-miniquake-platform-win32-ml-1650017046"></a>
### configureDisplayMode

```ml
function configureDisplayMode(widthValue, heightValue, bpp, frequency, fullscreen, useCurrent)
```

Update subsystem configuration for configure display mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `widthValue` | `dynamic` | — | The width value input consumed by `configureDisplayMode`. |
| `heightValue` | `dynamic` | — | The height value input consumed by `configureDisplayMode`. |
| `bpp` | `dynamic` | — | The bpp input consumed by `configureDisplayMode`. |
| `frequency` | `dynamic` | — | The frequency input consumed by `configureDisplayMode`. |
| `fullscreen` | `dynamic` | — | The fullscreen input consumed by `configureDisplayMode`. |
| `useCurrent` | `dynamic` | — | The use current input consumed by `configureDisplayMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L176)

<a id="function-function-miniquake-platform-win32-contextready-function-contextready-src-miniquake-platform-win32-ml-1988767514"></a>
### contextReady

```ml
function contextReady()
```

Implements the `contextReady` operation for `miniquake.platform.win32` (context ready).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L205)

<a id="function-function-miniquake-platform-win32-create-function-create-title-width-height-fullscreen-src-miniquake-platform-win32-ml-121730594"></a>
### create

```ml
function create(title, width, height, fullscreen)
```

Implements the `create` operation for `miniquake.platform.win32` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `dynamic` | — | The title input consumed by `create`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `fullscreen` | `dynamic` | — | The fullscreen input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L41)

<a id="function-function-miniquake-platform-win32-desktopheight-function-desktopheight-src-miniquake-platform-win32-ml-863759912"></a>
### desktopHeight

```ml
function desktopHeight()
```

Implements the `desktopHeight` operation for `miniquake.platform.win32` (desktop height).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L139)

<a id="function-function-miniquake-platform-win32-desktopwidth-function-desktopwidth-src-miniquake-platform-win32-ml-561382934"></a>
### desktopWidth

```ml
function desktopWidth()
```

Implements the `desktopWidth` operation for `miniquake.platform.win32` (desktop width).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L134)

<a id="function-function-miniquake-platform-win32-destroy-function-destroy-src-miniquake-platform-win32-ml-79587894"></a>
### destroy

```ml
function destroy()
```

Implements the `destroy` operation for `miniquake.platform.win32` (destroy).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L54)

<a id="function-function-miniquake-platform-win32-displaymodes-function-displaymodes-src-miniquake-platform-win32-ml-1145575122"></a>
### displayModes

```ml
function displayModes()
```

Implements the `displayModes` operation for `miniquake.platform.win32` (display modes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L144)

<a id="function-function-miniquake-platform-win32-getgammaramp-function-getgammaramp-src-miniquake-platform-win32-ml-436053186"></a>
### getGammaRamp

```ml
function getGammaRamp()
```

Return gamma ramp.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L191)

<a id="function-function-miniquake-platform-win32-hasfocus-function-hasfocus-src-miniquake-platform-win32-ml-2051211002"></a>
### hasFocus

```ml
function hasFocus()
```

Report whether focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L97)

<a id="function-function-miniquake-platform-win32-height-function-height-src-miniquake-platform-win32-ml-1423187078"></a>
### height

```ml
function height()
```

Implements the `height` operation for `miniquake.platform.win32` (height).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L107)

<a id="function-function-miniquake-platform-win32-inputeventpop-function-inputeventpop-src-miniquake-platform-win32-ml-2145880960"></a>
### inputEventPop

```ml
function inputEventPop()
```

Implements the `inputEventPop` operation for `miniquake.platform.win32` (input event pop).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L254)

<a id="function-function-miniquake-platform-win32-inputtestpush-function-inputtestpush-eventtype-code-value-src-miniquake-platform-win32-ml-328255508"></a>
### inputTestPush

```ml
function inputTestPush(eventType, code, value)
```

Implements the `inputTestPush` operation for `miniquake.platform.win32` (input test push).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `eventType` | `dynamic` | — | The event type input consumed by `inputTestPush`. |
| `code` | `dynamic` | — | The code input consumed by `inputTestPush`. |
| `value` | `dynamic` | — | Value consumed by `inputTestPush`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L262)

<a id="function-function-miniquake-platform-win32-joyaxis-function-joyaxis-axis-src-miniquake-platform-win32-ml-1338208295"></a>
### joyAxis

```ml
function joyAxis(axis)
```

Implements the `joyAxis` operation for `miniquake.platform.win32` (joy axis).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axis` | `dynamic` | — | The axis input consumed by `joyAxis`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L294)

<a id="function-function-miniquake-platform-win32-joybuttoncount-function-joybuttoncount-src-miniquake-platform-win32-ml-267708910"></a>
### joyButtonCount

```ml
function joyButtonCount()
```

Return joy button count derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L309)

<a id="function-function-miniquake-platform-win32-joybuttons-function-joybuttons-src-miniquake-platform-win32-ml-989601934"></a>
### joyButtons

```ml
function joyButtons()
```

Implements the `joyButtons` operation for `miniquake.platform.win32` (joy buttons).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L299)

<a id="function-function-miniquake-platform-win32-joyhaspov-function-joyhaspov-src-miniquake-platform-win32-ml-1756045588"></a>
### joyHasPov

```ml
function joyHasPov()
```

Implements the `joyHasPov` operation for `miniquake.platform.win32` (joy has pov).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L314)

<a id="function-function-miniquake-platform-win32-joypov-function-joypov-src-miniquake-platform-win32-ml-1587090782"></a>
### joyPov

```ml
function joyPov()
```

Implements the `joyPov` operation for `miniquake.platform.win32` (joy pov).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L304)

<a id="function-function-miniquake-platform-win32-joyread-function-joyread-src-miniquake-platform-win32-ml-780149686"></a>
### joyRead

```ml
function joyRead()
```

Implements the `joyRead` operation for `miniquake.platform.win32` (joy read).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L288)

<a id="function-function-miniquake-platform-win32-joystartup-function-joystartup-src-miniquake-platform-win32-ml-1234181950"></a>
### joyStartup

```ml
function joyStartup()
```

Implements the `joyStartup` operation for `miniquake.platform.win32` (joy startup).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L283)

<a id="function-function-miniquake-platform-win32-joywarriorcurve-function-joywarriorcurve-rawvalue-src-miniquake-platform-win32-ml-953377137"></a>
### joyWarriorCurve

```ml
function joyWarriorCurve(rawValue)
```

Implements the `joyWarriorCurve` operation for `miniquake.platform.win32` (joy warrior curve).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rawValue` | `dynamic` | — | The raw value input consumed by `joyWarriorCurve`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L320)

<a id="function-function-miniquake-platform-win32-keydown-function-keydown-virtualkey-src-miniquake-platform-win32-ml-948371334"></a>
### keyDown

```ml
function keyDown(virtualKey)
```

Implements the `keyDown` operation for `miniquake.platform.win32` (key down).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `virtualKey` | `dynamic` | — | The virtual key input consumed by `keyDown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L70)

<a id="function-function-miniquake-platform-win32-keypressed-function-keypressed-virtualkey-src-miniquake-platform-win32-ml-466700976"></a>
### keyPressed

```ml
function keyPressed(virtualKey)
```

Implements the `keyPressed` operation for `miniquake.platform.win32` (key pressed).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `virtualKey` | `dynamic` | — | The virtual key input consumed by `keyPressed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L76)

<a id="function-function-miniquake-platform-win32-keysnapshot-function-keysnapshot-downstates-pressedstates-querymask-src-miniquake-platform-win32-ml-1365063718"></a>
### keySnapshot

```ml
function keySnapshot(downStates, pressedStates, queryMask)
```

Capture the requested keyboard levels and complete edge table in one call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `downStates` | `dynamic` | — | The down states input consumed by `keySnapshot`. |
| `pressedStates` | `dynamic` | — | The pressed states input consumed by `keySnapshot`. |
| `queryMask` | `dynamic` | — | The query mask input consumed by `keySnapshot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L84)

<a id="function-function-miniquake-platform-win32-makecurrent-function-makecurrent-src-miniquake-platform-win32-ml-1138827120"></a>
### makeCurrent

```ml
function makeCurrent()
```

Create and initialize current.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L210)

<a id="function-function-miniquake-platform-win32-minimized-function-minimized-src-miniquake-platform-win32-ml-1837252258"></a>
### minimized

```ml
function minimized()
```

Implements the `minimized` operation for `miniquake.platform.win32` (minimized).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L129)

<a id="function-function-miniquake-platform-win32-mousebuttons-function-mousebuttons-src-miniquake-platform-win32-ml-584849878"></a>
### mouseButtons

```ml
function mouseButtons()
```

Implements the `mouseButtons` operation for `miniquake.platform.win32` (mouse buttons).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L244)

<a id="function-function-miniquake-platform-win32-mousedelta-function-mousedelta-src-miniquake-platform-win32-ml-942191030"></a>
### mouseDelta

```ml
function mouseDelta()
```

Implements the `mouseDelta` operation for `miniquake.platform.win32` (mouse delta).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L239)

<a id="function-function-miniquake-platform-win32-mousewheel-function-mousewheel-src-miniquake-platform-win32-ml-1446298978"></a>
### mouseWheel

```ml
function mouseWheel()
```

Implements the `mouseWheel` operation for `miniquake.platform.win32` (mouse wheel).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L249)

<a id="function-function-miniquake-platform-win32-poll-function-poll-src-miniquake-platform-win32-ml-1120154434"></a>
### poll

```ml
function poll()
```

Implements the `poll` operation for `miniquake.platform.win32` (poll).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L59)

<a id="constant-constant-miniquake-platform-win32-render-direct3d9-const-render-direct3d9-1-src-miniquake-platform-win32-ml-646012746"></a>
### RENDER_DIRECT3D9

```ml
const RENDER_DIRECT3D9 = 1
```

Defines the render direct3 d9 value used by `miniquake.platform.win32`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L15)

<a id="constant-constant-miniquake-platform-win32-render-opengl-const-render-opengl-0-src-miniquake-platform-win32-ml-1694518135"></a>
### RENDER_OPENGL

```ml
const RENDER_OPENGL = 0
```

Defines the render opengl value used by `miniquake.platform.win32`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L13)

<a id="constant-constant-miniquake-platform-win32-render-vulkan-const-render-vulkan-2-src-miniquake-platform-win32-ml-1684152633"></a>
### RENDER_VULKAN

```ml
const RENDER_VULKAN = 2
```

Defines the render vulkan value used by `miniquake.platform.win32`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L17)

<a id="function-function-miniquake-platform-win32-renderer-function-renderer-src-miniquake-platform-win32-ml-1459216790"></a>
### renderer

```ml
function renderer()
```

Renders er for `miniquake.platform.win32`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L26)

<a id="function-function-miniquake-platform-win32-rendereravailable-function-rendereravailable-backend-src-miniquake-platform-win32-ml-2022744956"></a>
### rendererAvailable

```ml
function rendererAvailable(backend)
```

Report whether renderer available holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `dynamic` | — | The backend input consumed by `rendererAvailable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L32)

<a id="function-function-miniquake-platform-win32-resizeclient-function-resizeclient-widthvalue-heightvalue-src-miniquake-platform-win32-ml-515244525"></a>
### resizeClient

```ml
function resizeClient(widthValue, heightValue)
```

Implements the `resizeClient` operation for `miniquake.platform.win32` (resize client).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `widthValue` | `dynamic` | — | The width value input consumed by `resizeClient`. |
| `heightValue` | `dynamic` | — | The height value input consumed by `resizeClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L114)

<a id="function-function-miniquake-platform-win32-restoredisplaymode-function-restoredisplaymode-src-miniquake-platform-win32-ml-551213314"></a>
### restoreDisplayMode

```ml
function restoreDisplayMode()
```

Return restore display mode derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L185)

<a id="function-function-miniquake-platform-win32-selectrenderer-function-selectrenderer-backend-src-miniquake-platform-win32-ml-1544266576"></a>
### selectRenderer

```ml
function selectRenderer(backend)
```

Update subsystem configuration for select renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `dynamic` | — | The backend input consumed by `selectRenderer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L21)

<a id="function-function-miniquake-platform-win32-setgammaramp-function-setgammaramp-ramp-src-miniquake-platform-win32-ml-1944613894"></a>
### setGammaRamp

```ml
function setGammaRamp(ramp)
```

Update module state for gamma ramp.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ramp` | `dynamic` | — | The ramp input consumed by `setGammaRamp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L199)

<a id="function-function-miniquake-platform-win32-settitle-function-settitle-title-src-miniquake-platform-win32-ml-2119673846"></a>
### setTitle

```ml
function setTitle(title)
```

Update module state for title.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `dynamic` | — | The title input consumed by `setTitle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L228)

<a id="function-function-miniquake-platform-win32-showcursor-function-showcursor-show-src-miniquake-platform-win32-ml-490093881"></a>
### showCursor

```ml
function showCursor(show)
```

Implements the `showCursor` operation for `miniquake.platform.win32` (show cursor).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `show` | `dynamic` | — | The show input consumed by `showCursor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L268)

<a id="function-function-miniquake-platform-win32-sleep-function-sleep-milliseconds-src-miniquake-platform-win32-ml-151109554"></a>
### sleep

```ml
function sleep(milliseconds)
```

Implements the `sleep` operation for `miniquake.platform.win32` (sleep).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `dynamic` | — | The milliseconds input consumed by `sleep`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L331)

<a id="function-function-miniquake-platform-win32-swap-function-swap-src-miniquake-platform-win32-ml-113557754"></a>
### swap

```ml
function swap()
```

Convert data for swap.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L64)

<a id="function-function-miniquake-platform-win32-testdisplaymode-function-testdisplaymode-widthvalue-heightvalue-bpp-frequency-src-miniquake-platform-win32-ml-1377109635"></a>
### testDisplayMode

```ml
function testDisplayMode(widthValue, heightValue, bpp, frequency)
```

Verify display mode against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `widthValue` | `dynamic` | — | The width value input consumed by `testDisplayMode`. |
| `heightValue` | `dynamic` | — | The height value input consumed by `testDisplayMode`. |
| `bpp` | `dynamic` | — | The bpp input consumed by `testDisplayMode`. |
| `frequency` | `dynamic` | — | The frequency input consumed by `testDisplayMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L165)

<a id="function-function-miniquake-platform-win32-textpop-function-textpop-src-miniquake-platform-win32-ml-2026602462"></a>
### textPop

```ml
function textPop()
```

Implements the `textPop` operation for `miniquake.platform.win32` (text pop).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L92)

<a id="function-function-miniquake-platform-win32-ticks-function-ticks-src-miniquake-platform-win32-ml-590065846"></a>
### ticks

```ml
function ticks()
```

Implements the `ticks` operation for `miniquake.platform.win32` (ticks).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L325)

<a id="function-function-miniquake-platform-win32-updateclipcursor-function-updateclipcursor-src-miniquake-platform-win32-ml-151336574"></a>
### updateClipCursor

```ml
function updateClipCursor()
```

Update module state for clip cursor.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L278)

<a id="function-function-miniquake-platform-win32-width-function-width-src-miniquake-platform-win32-ml-590993210"></a>
### width

```ml
function width()
```

Implements the `width` operation for `miniquake.platform.win32` (width).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L102)

<a id="function-function-miniquake-platform-win32-windowx-function-windowx-src-miniquake-platform-win32-ml-1023290458"></a>
### windowX

```ml
function windowX()
```

Implements the `windowX` operation for `miniquake.platform.win32` (window x).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L119)

<a id="function-function-miniquake-platform-win32-windowy-function-windowy-src-miniquake-platform-win32-ml-1867283892"></a>
### windowY

```ml
function windowY()
```

Implements the `windowY` operation for `miniquake.platform.win32` (window y).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/platform/win32.ml#L124)
