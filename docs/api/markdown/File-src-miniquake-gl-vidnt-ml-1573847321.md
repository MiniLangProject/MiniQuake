# `src/miniquake/gl_vidnt.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.gl_vidnt`](Package-miniquake-gl-vidnt-1356711002.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/input.ml` as `input` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/keys.ml` as `keys` → [src/miniquake/keys.ml](File-src-miniquake-keys-ml-299795526.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/texture_upscale.ml` as `textureUpscale` → [src/miniquake/render/texture_upscale.ml](File-src-miniquake-render-texture-upscale-ml-880792328.md)
- `miniquake/sound/mixer.ml` as `sound` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)
- `std/math.ml` as `stdmath` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/math.ml` — external dependency
- `std/string.ml` as `string` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/string.ml` — external dependency

## Declarations

<a id="function-function-miniquake-gl-vidnt-appactivate-function-appactivate-active-minimized-src-miniquake-gl-vidnt-ml-1388200827"></a>
### AppActivate

```ml
function AppActivate(active, minimized)
```

Implements the `AppActivate` operation for `miniquake.gl_vidnt` (app activate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — | The active input consumed by `AppActivate`. |
| `minimized` | `dynamic` | — | The minimized input consumed by `AppActivate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L905)

<a id="function-function-miniquake-gl-vidnt-bsetuppixelformat-function-bsetuppixelformat-src-miniquake-gl-vidnt-ml-153158617"></a>
### bSetupPixelFormat

```ml
function bSetupPixelFormat()
```

Implements the `bSetupPixelFormat` operation for `miniquake.gl_vidnt` (b setup pixel format).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L876)

<a id="function-function-miniquake-gl-vidnt-centerwindow-function-centerwindow-width-height-screenwidth-screenheight-lefttopjustify-src-miniquake-gl-vidnt-ml-707714219"></a>
### CenterWindow

```ml
function CenterWindow(width, height, screenWidth, screenHeight, leftTopJustify)
```

Implements the `CenterWindow` operation for `miniquake.gl_vidnt` (center window).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `screenWidth` | `dynamic` | — | The screen width input consumed by `CenterWindow`. |
| `screenHeight` | `dynamic` | — | The screen height input consumed by `CenterWindow`. |
| `leftTopJustify` | `dynamic` | — | The left top justify input consumed by `CenterWindow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L510)

<a id="function-function-miniquake-gl-vidnt-check-gamma-function-check-gamma-palette-src-miniquake-gl-vidnt-ml-905200036"></a>
### Check_Gamma

```ml
function Check_Gamma(palette)
```

Validate gamma and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `palette` | `dynamic` | — | The palette input consumed by `Check_Gamma`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1153)

<a id="function-function-miniquake-gl-vidnt-checkarrayextensions-function-checkarrayextensions-src-miniquake-gl-vidnt-ml-268452457"></a>
### CheckArrayExtensions

```ml
function CheckArrayExtensions()
```

Validate array extensions and report any incompatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L688)

<a id="function-function-miniquake-gl-vidnt-checkmultitextureextensions-function-checkmultitextureextensions-src-miniquake-gl-vidnt-ml-2033279265"></a>
### CheckMultiTextureExtensions

```ml
function CheckMultiTextureExtensions()
```

Validate multi texture extensions and report any incompatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L696)

<a id="function-function-miniquake-gl-vidnt-checkmultitextureextensions-nonwindows-function-checkmultitextureextensions-nonwindows-src-miniquake-gl-vidnt-ml-223797405"></a>
### CheckMultiTextureExtensions_NonWindows

```ml
function CheckMultiTextureExtensions_NonWindows()
```

Validate multi texture extensions non windows and report any incompatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L707)

<a id="function-function-miniquake-gl-vidnt-checktextureextensions-function-checktextureextensions-src-miniquake-gl-vidnt-ml-141185245"></a>
### CheckTextureExtensions

```ml
function CheckTextureExtensions()
```

Validate texture extensions and report any incompatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L679)

<a id="function-function-miniquake-gl-vidnt-clearallstates-function-clearallstates-src-miniquake-gl-vidnt-ml-1158059457"></a>
### ClearAllStates

```ml
function ClearAllStates()
```

Update module state for all states.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L890)

<a id="function-function-miniquake-gl-vidnt-createvideostate-function-createvideostate-src-miniquake-gl-vidnt-ml-822544377"></a>
### createVideoState

```ml
function createVideoState()
```

Create and initialize video state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L286)

<a id="global-global-miniquake-gl-vidnt-currentvideostate-currentvideostate-src-miniquake-gl-vidnt-ml-1616705759"></a>
### currentVideoState

```ml
currentVideoState
```

Tracks the current module-level video state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L199)

<a id="function-function-miniquake-gl-vidnt-d-begindirectrect-function-d-begindirectrect-x-y-bitmap-width-height-src-miniquake-gl-vidnt-ml-47892746"></a>
### D_BeginDirectRect

```ml
function D_BeginDirectRect(x, y, bitmap, width, height)
```

Mirror Quake's D_BeginDirectRect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `D_BeginDirectRect`. |
| `y` | `dynamic` | — | The y input consumed by `D_BeginDirectRect`. |
| `bitmap` | `dynamic` | — | The bitmap input consumed by `D_BeginDirectRect`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L491)

<a id="function-function-miniquake-gl-vidnt-d-enddirectrect-function-d-enddirectrect-x-y-width-height-src-miniquake-gl-vidnt-ml-1011882197"></a>
### D_EndDirectRect

```ml
function D_EndDirectRect(x, y, width, height)
```

Mirror Quake's D_EndDirectRect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `D_EndDirectRect`. |
| `y` | `dynamic` | — | The y input consumed by `D_EndDirectRect`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L500)

<a id="function-function-miniquake-gl-vidnt-gl-beginrendering-function-gl-beginrendering-src-miniquake-gl-vidnt-ml-1755440263"></a>
### GL_BeginRendering

```ml
function GL_BeginRendering()
```

Mirror Quake's GL_BeginRendering routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L745)

<a id="function-function-miniquake-gl-vidnt-gl-endrendering-function-gl-endrendering-src-miniquake-gl-vidnt-ml-814172955"></a>
### GL_EndRendering

```ml
function GL_EndRendering()
```

Mirror Quake's GL_EndRendering routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L754)

<a id="function-function-miniquake-gl-vidnt-gl-init-function-gl-init-src-miniquake-gl-vidnt-ml-1655950777"></a>
### GL_Init

```ml
function GL_Init()
```

Mirror Quake's GL_Init routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L714)

<a id="function-function-miniquake-gl-vidnt-hastext-function-hastext-value-needle-src-miniquake-gl-vidnt-ml-1527108417"></a>
### hasText

```ml
function hasText(value, needle)
```

Report whether text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `hasText`. |
| `needle` | `dynamic` | — | The needle input consumed by `hasText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L430)

<a id="function-function-miniquake-gl-vidnt-mainwndproc-function-mainwndproc-message-wparam-lparam-src-miniquake-gl-vidnt-ml-390980937"></a>
### MainWndProc

```ml
function MainWndProc(message, wParam, lParam)
```

Implements the `MainWndProc` operation for `miniquake.gl_vidnt` (main wnd proc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |
| `wParam` | `dynamic` | — | The w param input consumed by `MainWndProc`. |
| `lParam` | `dynamic` | — | The l param input consumed by `MainWndProc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L960)

<a id="function-function-miniquake-gl-vidnt-makemode-function-makemode-type-width-height-bpp-frequency-halfscreen-src-miniquake-gl-vidnt-ml-32275407"></a>
### makeMode

```ml
function makeMode(type, width, height, bpp, frequency, halfscreen)
```

Create and initialize mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `makeMode`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `bpp` | `dynamic` | — | The bpp input consumed by `makeMode`. |
| `frequency` | `dynamic` | — | The frequency input consumed by `makeMode`. |
| `halfscreen` | `dynamic` | — | The halfscreen input consumed by `makeMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L279)

<a id="function-function-miniquake-gl-vidnt-mapkey-function-mapkey-key-src-miniquake-gl-vidnt-ml-2063641400"></a>
### MapKey

```ml
function MapKey(key)
```

Implements the `MapKey` operation for `miniquake.gl_vidnt` (map key).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L884)

<a id="constant-constant-miniquake-gl-vidnt-max-mode-list-const-max-mode-list-30-src-miniquake-gl-vidnt-ml-2101711741"></a>
### MAX_MODE_LIST

```ml
const MAX_MODE_LIST = 30
```

Defines the max mode list value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L26)

<a id="constant-constant-miniquake-gl-vidnt-max-modedescs-const-max-modedescs-27-src-miniquake-gl-vidnt-ml-1888863521"></a>
### MAX_MODEDESCS

```ml
const MAX_MODEDESCS = 27
```

Defines the max modedescs value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L28)

<a id="constant-constant-miniquake-gl-vidnt-mode-fullscreen-default-const-mode-fullscreen-default-1-src-miniquake-gl-vidnt-ml-379469881"></a>
### MODE_FULLSCREEN_DEFAULT

```ml
const MODE_FULLSCREEN_DEFAULT = 1
```

Defines the mode fullscreen default value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L40)

<a id="constant-constant-miniquake-gl-vidnt-mode-windowed-const-mode-windowed-0-src-miniquake-gl-vidnt-ml-440865590"></a>
### MODE_WINDOWED

```ml
const MODE_WINDOWED = 0
```

Defines the mode windowed value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L36)

<a id="constant-constant-miniquake-gl-vidnt-ms-fulldib-const-ms-fulldib-2-src-miniquake-gl-vidnt-ml-1524558984"></a>
### MS_FULLDIB

```ml
const MS_FULLDIB = 2
```

Defines the ms fulldib value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L44)

<a id="constant-constant-miniquake-gl-vidnt-ms-uninit-const-ms-uninit-3-src-miniquake-gl-vidnt-ml-578273579"></a>
### MS_UNINIT

```ml
const MS_UNINIT = 3
```

Defines the ms uninit value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L46)

<a id="constant-constant-miniquake-gl-vidnt-ms-windowed-const-ms-windowed-0-src-miniquake-gl-vidnt-ml-2129706234"></a>
### MS_WINDOWED

```ml
const MS_WINDOWED = 0
```

Defines the ms windowed value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L42)

<a id="constant-constant-miniquake-gl-vidnt-no-mode-const-no-mode-1-src-miniquake-gl-vidnt-ml-155973544"></a>
### NO_MODE

```ml
const NO_MODE = -1
```

Defines the no mode value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L38)

<a id="global-global-miniquake-gl-vidnt-rendererselectionoverride-rendererselectionoverride-src-miniquake-gl-vidnt-ml-1556620595"></a>
### rendererSelectionOverride

```ml
rendererSelectionOverride
```

Tracks the module-level renderer selection override state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L219)

<a id="function-function-miniquake-gl-vidnt-signedword-function-signedword-value-src-miniquake-gl-vidnt-ml-706268310"></a>
### signedWord

```ml
function signedWord(value)
```

Implements the `signedWord` operation for `miniquake.gl_vidnt` (signed word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `signedWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L950)

<a id="function-function-miniquake-gl-vidnt-startswithignorecase-function-startswithignorecase-value-prefix-src-miniquake-gl-vidnt-ml-252027318"></a>
### startsWithIgnoreCase

```ml
function startsWithIgnoreCase(value, prefix)
```

Initialize state for starts with ignore case.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `startsWithIgnoreCase`. |
| `prefix` | `dynamic` | — | The prefix input consumed by `startsWithIgnoreCase`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L438)

<a id="function-function-miniquake-gl-vidnt-vid-adjustanisotropy-function-vid-adjustanisotropy-direction-src-miniquake-gl-vidnt-ml-284266894"></a>
### VID_AdjustAnisotropy

```ml
function VID_AdjustAnisotropy(direction)
```

Cycle the archived cross-backend anisotropic filtering level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `VID_AdjustAnisotropy`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1584)

<a id="function-function-miniquake-gl-vidnt-vid-adjustenhancedshadowquality-function-vid-adjustenhancedshadowquality-direction-src-miniquake-gl-vidnt-ml-42706750"></a>
### VID_AdjustEnhancedShadowQuality

```ml
function VID_AdjustEnhancedShadowQuality(direction)
```

Cycle the archived soft-shadow sampling level in the requested direction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `VID_AdjustEnhancedShadowQuality`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1541)

<a id="function-function-miniquake-gl-vidnt-vid-adjusttextureupscale-function-vid-adjusttextureupscale-direction-src-miniquake-gl-vidnt-ml-1261506602"></a>
### VID_AdjustTextureUpscale

```ml
function VID_AdjustTextureUpscale(direction)
```

Cycle the archived load-time texture-upscaling algorithm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `direction` | `dynamic` | — | The direction input consumed by `VID_AdjustTextureUpscale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1569)

<a id="function-function-miniquake-gl-vidnt-vid-applyconfiguredrenderer-function-vid-applyconfiguredrenderer-src-miniquake-gl-vidnt-ml-513199103"></a>
### VID_ApplyConfiguredRenderer

```ml
function VID_ApplyConfiguredRenderer()
```

Apply the Quake-compatible vid apply configured renderer behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1378)

<a id="function-function-miniquake-gl-vidnt-vid-applyconfiguredresolution-function-vid-applyconfiguredresolution-src-miniquake-gl-vidnt-ml-1509731841"></a>
### VID_ApplyConfiguredResolution

```ml
function VID_ApplyConfiguredResolution()
```

config.cfg is executed after VID_Init.  Apply a resolution previously chosen in the menu once the archived cvars have been read, unless command-line video arguments explicitly override it.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1742)

<a id="function-function-miniquake-gl-vidnt-vid-applydisplaymode-function-vid-applydisplaymode-modenumber-fullscreen-src-miniquake-gl-vidnt-ml-1093917248"></a>
### VID_ApplyDisplayMode

```ml
function VID_ApplyDisplayMode(modeNumber, fullscreen)
```

Change resolution and presentation style on the existing HWND/HDC/WGL context.  Keeping the context alive is essential: all map textures, display lists and renderer caches remain valid across the menu operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_ApplyDisplayMode`. |
| `fullscreen` | `dynamic` | — | The fullscreen input consumed by `VID_ApplyDisplayMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1663)

<a id="function-function-miniquake-gl-vidnt-vid-applygammaramp-function-vid-applygammaramp-gamma-src-miniquake-gl-vidnt-ml-1286311678"></a>
### VID_ApplyGammaRamp

```ml
function VID_ApplyGammaRamp(gamma)
```

Apply the Quake-compatible vid apply gamma ramp behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `gamma` | `dynamic` | — | The gamma input consumed by `VID_ApplyGammaRamp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1199)

<a id="function-function-miniquake-gl-vidnt-vid-applyresolution-function-vid-applyresolution-modenumber-src-miniquake-gl-vidnt-ml-248702611"></a>
### VID_ApplyResolution

```ml
function VID_ApplyResolution(modeNumber)
```

Apply the Quake-compatible vid apply resolution behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_ApplyResolution`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1728)

<a id="function-function-miniquake-gl-vidnt-vid-build15to8-function-vid-build15to8-state-src-miniquake-gl-vidnt-ml-1434843926"></a>
### VID_Build15To8

```ml
function VID_Build15To8(state)
```

Apply the Quake-compatible vid build15 to8 behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.gl_vidnt` state used by `VID_Build15To8`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L779)

<a id="function-function-miniquake-gl-vidnt-vid-buildgammaramp-function-vid-buildgammaramp-gamma-src-miniquake-gl-vidnt-ml-1354551534"></a>
### VID_BuildGammaRamp

```ml
function VID_BuildGammaRamp(gamma)
```

Apply the Quake-compatible vid build gamma ramp behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `gamma` | `dynamic` | — | The gamma input consumed by `VID_BuildGammaRamp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1177)

<a id="function-function-miniquake-gl-vidnt-vid-commandlinerenderer-function-vid-commandlinerenderer-arguments-src-miniquake-gl-vidnt-ml-1876227169"></a>
### VID_CommandLineRenderer

```ml
function VID_CommandLineRenderer(arguments)
```

Apply the Quake-compatible vid command line renderer behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L248)

<a id="function-function-miniquake-gl-vidnt-vid-describecurrentmode-f-function-vid-describecurrentmode-f-src-miniquake-gl-vidnt-ml-351926405"></a>
### VID_DescribeCurrentMode_f

```ml
function VID_DescribeCurrentMode_f()
```

Apply the Quake-compatible vid describe current mode f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1035)

<a id="function-function-miniquake-gl-vidnt-vid-describemode-f-function-vid-describemode-f-arguments-src-miniquake-gl-vidnt-ml-1585289145"></a>
### VID_DescribeMode_f

```ml
function VID_DescribeMode_f(arguments)
```

Apply the Quake-compatible vid describe mode f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1049)

<a id="function-function-miniquake-gl-vidnt-vid-describemodes-f-function-vid-describemodes-f-src-miniquake-gl-vidnt-ml-928804897"></a>
### VID_DescribeModes_f

```ml
function VID_DescribeModes_f()
```

Apply the Quake-compatible vid describe modes f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1060)

<a id="function-function-miniquake-gl-vidnt-vid-findrequestedmode-function-vid-findrequestedmode-arguments-src-miniquake-gl-vidnt-ml-184248001"></a>
### VID_FindRequestedMode

```ml
function VID_FindRequestedMode(arguments)
```

Apply the Quake-compatible vid find requested mode behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1225)

<a id="function-function-miniquake-gl-vidnt-vid-forcelockstate-function-vid-forcelockstate-lockstate-src-miniquake-gl-vidnt-ml-1484377045"></a>
### VID_ForceLockState

```ml
function VID_ForceLockState(lockState)
```

Apply the Quake-compatible vid force lock state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lockState` | `dynamic` | — | Mutable state used by `VID_ForceLockState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L464)

<a id="function-function-miniquake-gl-vidnt-vid-forceunlockedandreturnstate-function-vid-forceunlockedandreturnstate-src-miniquake-gl-vidnt-ml-1449820545"></a>
### VID_ForceUnlockedAndReturnState

```ml
function VID_ForceUnlockedAndReturnState()
```

Apply the Quake-compatible vid force unlocked and return state behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L481)

<a id="function-function-miniquake-gl-vidnt-vid-fullscreenrequested-function-vid-fullscreenrequested-arguments-src-miniquake-gl-vidnt-ml-2056240299"></a>
### VID_FullscreenRequested

```ml
function VID_FullscreenRequested(arguments)
```

Apply the Quake-compatible vid fullscreen requested behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1215)

<a id="function-function-miniquake-gl-vidnt-vid-getextmodedescription-function-vid-getextmodedescription-modenumber-src-miniquake-gl-vidnt-ml-1255000715"></a>
### VID_GetExtModeDescription

```ml
function VID_GetExtModeDescription(modeNumber)
```

Apply the Quake-compatible vid get ext mode description behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_GetExtModeDescription`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1022)

<a id="function-function-miniquake-gl-vidnt-vid-getmodedescription-function-vid-getmodedescription-modenumber-src-miniquake-gl-vidnt-ml-1995049483"></a>
### VID_GetModeDescription

```ml
function VID_GetModeDescription(modeNumber)
```

Apply the Quake-compatible vid get mode description behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_GetModeDescription`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1010)

<a id="function-function-miniquake-gl-vidnt-vid-getmodeptr-function-vid-getmodeptr-modenumber-src-miniquake-gl-vidnt-ml-1139099875"></a>
### VID_GetModePtr

```ml
function VID_GetModePtr(modeNumber)
```

Apply the Quake-compatible vid get mode ptr behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_GetModePtr`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1002)

<a id="function-function-miniquake-gl-vidnt-vid-handlepause-function-vid-handlepause-pause-src-miniquake-gl-vidnt-ml-1692329635"></a>
### VID_HandlePause

```ml
function VID_HandlePause(pause)
```

Apply the Quake-compatible vid handle pause behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pause` | `dynamic` | — | The pause input consumed by `VID_HandlePause`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L456)

<a id="function-function-miniquake-gl-vidnt-vid-init-function-vid-init-arguments-registry-palette-createnative-src-miniquake-gl-vidnt-ml-611527366"></a>
### VID_Init

```ml
function VID_Init(arguments, registry, palette, createNative)
```

Apply the Quake-compatible vid init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `registry` | `dynamic` | — | The registry input consumed by `VID_Init`. |
| `palette` | `dynamic` | — | The palette input consumed by `VID_Init`. |
| `createNative` | `dynamic` | — | The create native input consumed by `VID_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1280)

<a id="function-function-miniquake-gl-vidnt-vid-init8bitpalette-function-vid-init8bitpalette-src-miniquake-gl-vidnt-ml-1110491665"></a>
### VID_Init8bitPalette

```ml
function VID_Init8bitPalette()
```

Apply the Quake-compatible vid init8bit palette behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1141)

<a id="function-function-miniquake-gl-vidnt-vid-initdib-function-vid-initdib-arguments-src-miniquake-gl-vidnt-ml-1902820627"></a>
### VID_InitDIB

```ml
function VID_InitDIB(arguments)
```

Apply the Quake-compatible vid init dib behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1078)

<a id="function-function-miniquake-gl-vidnt-vid-initfulldib-function-vid-initfulldib-enumeratedmodes-testnative-noadjustaspect-src-miniquake-gl-vidnt-ml-989803946"></a>
### VID_InitFullDIB

```ml
function VID_InitFullDIB(enumeratedModes, testNative, noAdjustAspect)
```

Apply the Quake-compatible vid init full dib behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enumeratedModes` | `dynamic` | — | The enumerated modes input consumed by `VID_InitFullDIB`. |
| `testNative` | `dynamic` | — | The test native input consumed by `VID_InitFullDIB`. |
| `noAdjustAspect` | `dynamic` | — | The no adjust aspect input consumed by `VID_InitFullDIB`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1095)

<a id="function-function-miniquake-gl-vidnt-vid-is8bit-function-vid-is8bit-src-miniquake-gl-vidnt-ml-952084753"></a>
### VID_Is8bit

```ml
function VID_Is8bit()
```

Apply the Quake-compatible vid is8bit behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1136)

<a id="function-function-miniquake-gl-vidnt-vid-lockbuffer-function-vid-lockbuffer-src-miniquake-gl-vidnt-ml-501889"></a>
### VID_LockBuffer

```ml
function VID_LockBuffer()
```

Apply the Quake-compatible vid lock buffer behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L471)

<a id="function-function-miniquake-gl-vidnt-vid-menuanisotropyfocused-function-vid-menuanisotropyfocused-src-miniquake-gl-vidnt-ml-881757849"></a>
### VID_MenuAnisotropyFocused

```ml
function VID_MenuAnisotropyFocused()
```

Report whether the anisotropic texture-filter row owns keyboard focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1504)

<a id="function-function-miniquake-gl-vidnt-vid-menudisplayfocused-function-vid-menudisplayfocused-src-miniquake-gl-vidnt-ml-1679792149"></a>
### VID_MenuDisplayFocused

```ml
function VID_MenuDisplayFocused()
```

Apply the Quake-compatible vid menu display focused behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1462)

<a id="function-function-miniquake-gl-vidnt-vid-menudraw-function-vid-menudraw-src-miniquake-gl-vidnt-ml-781640265"></a>
### VID_MenuDraw

```ml
function VID_MenuDraw()
```

Apply the Quake-compatible vid menu draw behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1793)

<a id="function-function-miniquake-gl-vidnt-vid-menudrawcallback-function-vid-menudrawcallback-src-miniquake-gl-vidnt-ml-148603345"></a>
### VID_MenuDrawCallback

```ml
function VID_MenuDrawCallback()
```

Apply the Quake-compatible vid menu draw callback behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1971)

<a id="function-function-miniquake-gl-vidnt-vid-menukey-function-vid-menukey-key-src-miniquake-gl-vidnt-ml-944458984"></a>
### VID_MenuKey

```ml
function VID_MenuKey(key)
```

Apply the Quake-compatible vid menu key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1855)

<a id="function-function-miniquake-gl-vidnt-vid-menukeycallback-function-vid-menukeycallback-key-src-miniquake-gl-vidnt-ml-2119719006"></a>
### VID_MenuKeyCallback

```ml
function VID_MenuKeyCallback(key)
```

Apply the Quake-compatible vid menu key callback behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1977)

<a id="function-function-miniquake-gl-vidnt-vid-menulightingfocused-function-vid-menulightingfocused-src-miniquake-gl-vidnt-ml-1787483289"></a>
### VID_MenuLightingFocused

```ml
function VID_MenuLightingFocused()
```

Report whether the enhanced-lighting row owns keyboard focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1474)

<a id="function-function-miniquake-gl-vidnt-vid-menumodecount-function-vid-menumodecount-src-miniquake-gl-vidnt-ml-1499183263"></a>
### VID_MenuModeCount

```ml
function VID_MenuModeCount()
```

Apply the Quake-compatible vid menu mode count behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1390)

<a id="function-function-miniquake-gl-vidnt-vid-menumodelinterpolationfocused-function-vid-menumodelinterpolationfocused-src-miniquake-gl-vidnt-ml-745165991"></a>
### VID_MenuModelInterpolationFocused

```ml
function VID_MenuModelInterpolationFocused()
```

Report whether the alias-pose interpolation row owns keyboard focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1492)

<a id="function-function-miniquake-gl-vidnt-vid-menumove-function-vid-menumove-delta-src-miniquake-gl-vidnt-ml-2114828867"></a>
### VID_MenuMove

```ml
function VID_MenuMove(delta)
```

Apply the Quake-compatible vid menu move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `delta` | `dynamic` | — | The delta input consumed by `VID_MenuMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1446)

<a id="function-function-miniquake-gl-vidnt-vid-menurendererfocused-function-vid-menurendererfocused-src-miniquake-gl-vidnt-ml-1628853927"></a>
### VID_MenuRendererFocused

```ml
function VID_MenuRendererFocused()
```

Apply the Quake-compatible vid menu renderer focused behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1468)

<a id="function-function-miniquake-gl-vidnt-vid-menureset-function-vid-menureset-src-miniquake-gl-vidnt-ml-1554966881"></a>
### VID_MenuReset

```ml
function VID_MenuReset()
```

Apply the Quake-compatible vid menu reset behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1398)

<a id="function-function-miniquake-gl-vidnt-vid-menuselection-function-vid-menuselection-src-miniquake-gl-vidnt-ml-850965463"></a>
### VID_MenuSelection

```ml
function VID_MenuSelection()
```

Apply the Quake-compatible vid menu selection behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1436)

<a id="function-function-miniquake-gl-vidnt-vid-menushadowfocused-function-vid-menushadowfocused-src-miniquake-gl-vidnt-ml-1612005329"></a>
### VID_MenuShadowFocused

```ml
function VID_MenuShadowFocused()
```

Report whether the shadow row owns keyboard focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1480)

<a id="function-function-miniquake-gl-vidnt-vid-menushadowqualityfocused-function-vid-menushadowqualityfocused-src-miniquake-gl-vidnt-ml-1689185185"></a>
### VID_MenuShadowQualityFocused

```ml
function VID_MenuShadowQualityFocused()
```

Report whether the shadow-quality row owns keyboard focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1486)

<a id="function-function-miniquake-gl-vidnt-vid-menutextureupscalefocused-function-vid-menutextureupscalefocused-src-miniquake-gl-vidnt-ml-22812113"></a>
### VID_MenuTextureUpscaleFocused

```ml
function VID_MenuTextureUpscaleFocused()
```

Report whether the load-time texture-upscaling row owns keyboard focus.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1498)

<a id="function-function-miniquake-gl-vidnt-vid-modeexists-function-vid-modeexists-modes-candidate-src-miniquake-gl-vidnt-ml-1028329730"></a>
### VID_ModeExists

```ml
function VID_ModeExists(modes, candidate)
```

Apply the Quake-compatible vid mode exists behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modes` | `dynamic` | — | The modes input consumed by `VID_ModeExists`. |
| `candidate` | `dynamic` | — | The candidate input consumed by `VID_ModeExists`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L552)

<a id="function-function-miniquake-gl-vidnt-vid-modeless-function-vid-modeless-left-right-src-miniquake-gl-vidnt-ml-921939094"></a>
### VID_ModeLess

```ml
function VID_ModeLess(left, right)
```

Apply the Quake-compatible vid mode less behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `VID_ModeLess`. |
| `right` | `dynamic` | — | The right input consumed by `VID_ModeLess`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L522)

<a id="function-function-miniquake-gl-vidnt-vid-nummodes-function-vid-nummodes-src-miniquake-gl-vidnt-ml-312336257"></a>
### VID_NumModes

```ml
function VID_NumModes()
```

Apply the Quake-compatible vid num modes behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L996)

<a id="function-function-miniquake-gl-vidnt-vid-nummodes-f-function-vid-nummodes-f-src-miniquake-gl-vidnt-ml-693510529"></a>
### VID_NumModes_f

```ml
function VID_NumModes_f()
```

Apply the Quake-compatible vid num modes f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1041)

<a id="function-function-miniquake-gl-vidnt-vid-palettematches-function-vid-palettematches-state-palette-src-miniquake-gl-vidnt-ml-791471525"></a>
### VID_PaletteMatches

```ml
function VID_PaletteMatches(state, palette)
```

Report whether the complete lookup-table palette is already installed. SCR_BringDownConsole restores the base palette during every level change; rebuilding the 8.4-million-comparison 15-to-8 table for identical bytes is observable only as a loading hitch, never as a changed rendering result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.gl_vidnt` state used by `VID_PaletteMatches`. |
| `palette` | `dynamic` | — | The palette input consumed by `VID_PaletteMatches`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L809)

<a id="function-function-miniquake-gl-vidnt-vid-rendererconfigname-function-vid-rendererconfigname-backend-src-miniquake-gl-vidnt-ml-1402172029"></a>
### VID_RendererConfigName

```ml
function VID_RendererConfigName(backend)
```

Return the stable token written to config.cfg for a renderer backend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `dynamic` | — | The backend input consumed by `VID_RendererConfigName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L240)

<a id="function-function-miniquake-gl-vidnt-vid-rendererfromname-function-vid-rendererfromname-name-src-miniquake-gl-vidnt-ml-1587564980"></a>
### VID_RendererFromName

```ml
function VID_RendererFromName(name)
```

Apply the Quake-compatible vid renderer from name behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L223)

<a id="function-function-miniquake-gl-vidnt-vid-renderername-function-vid-renderername-backend-src-miniquake-gl-vidnt-ml-1426932613"></a>
### VID_RendererName

```ml
function VID_RendererName(backend)
```

Apply the Quake-compatible vid renderer name behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `dynamic` | — | The backend input consumed by `VID_RendererName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L232)

<a id="function-function-miniquake-gl-vidnt-vid-restartrenderer-function-vid-restartrenderer-backend-src-miniquake-gl-vidnt-ml-879211961"></a>
### VID_RestartRenderer

```ml
function VID_RestartRenderer(backend)
```

Apply the Quake-compatible vid restart renderer behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `dynamic` | — | The backend input consumed by `VID_RestartRenderer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1325)

<a id="function-function-miniquake-gl-vidnt-vid-restorenativemode-function-vid-restorenativemode-state-wasfullscreen-previouswidth-previousheight-previousbpp-previousfrequency-previoushalfscreen-src-miniquake-gl-vidnt-ml-2097468411"></a>
### VID_RestoreNativeMode

```ml
function VID_RestoreNativeMode(state, wasFullscreen, previousWidth, previousHeight, previousBpp, previousFrequency, previousHalfscreen)
```

Apply the Quake-compatible vid restore native mode behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.gl_vidnt` state used by `VID_RestoreNativeMode`. |
| `wasFullscreen` | `dynamic` | — | The was fullscreen input consumed by `VID_RestoreNativeMode`. |
| `previousWidth` | `dynamic` | — | The previous width input consumed by `VID_RestoreNativeMode`. |
| `previousHeight` | `dynamic` | — | The previous height input consumed by `VID_RestoreNativeMode`. |
| `previousBpp` | `dynamic` | — | The previous bpp input consumed by `VID_RestoreNativeMode`. |
| `previousFrequency` | `dynamic` | — | The previous frequency input consumed by `VID_RestoreNativeMode`. |
| `previousHalfscreen` | `dynamic` | — | The previous halfscreen input consumed by `VID_RestoreNativeMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1648)

<a id="constant-constant-miniquake-gl-vidnt-vid-row-size-const-vid-row-size-3-src-miniquake-gl-vidnt-ml-460690045"></a>
### VID_ROW_SIZE

```ml
const VID_ROW_SIZE = 3
```

Defines the vid row size value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L30)

<a id="function-function-miniquake-gl-vidnt-vid-savecurrentconfigurationcvars-function-vid-savecurrentconfigurationcvars-src-miniquake-gl-vidnt-ml-1174736699"></a>
### VID_SaveCurrentConfigurationCvars

```ml
function VID_SaveCurrentConfigurationCvars()
```

Synchronize the live window, fullscreen and renderer state into archived cvars immediately before config.cfg is written.  This also captures a window resized by dragging its frame rather than only changes made in the menu.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1627)

<a id="function-function-miniquake-gl-vidnt-vid-saveresolutioncvars-function-vid-saveresolutioncvars-state-width-height-bpp-src-miniquake-gl-vidnt-ml-1333428687"></a>
### VID_SaveResolutionCvars

```ml
function VID_SaveResolutionCvars(state, width, height, bpp)
```

Apply the Quake-compatible vid save resolution cvars behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.gl_vidnt` state used by `VID_SaveResolutionCvars`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `bpp` | `dynamic` | — | The bpp input consumed by `VID_SaveResolutionCvars`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1610)

<a id="function-function-miniquake-gl-vidnt-vid-selectconfiguredrenderer-function-vid-selectconfiguredrenderer-arguments-registry-src-miniquake-gl-vidnt-ml-1578663692"></a>
### VID_SelectConfiguredRenderer

```ml
function VID_SelectConfiguredRenderer(arguments, registry)
```

Apply the Quake-compatible vid select configured renderer behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `registry` | `dynamic` | — | The registry input consumed by `VID_SelectConfiguredRenderer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L260)

<a id="function-function-miniquake-gl-vidnt-vid-setdefaultmode-function-vid-setdefaultmode-src-miniquake-gl-vidnt-ml-1807837297"></a>
### VID_SetDefaultMode

```ml
function VID_SetDefaultMode()
```

Apply the Quake-compatible vid set default mode behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L855)

<a id="function-function-miniquake-gl-vidnt-vid-setfulldibmode-function-vid-setfulldibmode-modenumber-createnative-src-miniquake-gl-vidnt-ml-972692170"></a>
### VID_SetFullDIBMode

```ml
function VID_SetFullDIBMode(modeNumber, createNative)
```

Apply the Quake-compatible vid set full dibmode behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_SetFullDIBMode`. |
| `createNative` | `dynamic` | — | The create native input consumed by `VID_SetFullDIBMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L593)

<a id="function-function-miniquake-gl-vidnt-vid-setmode-function-vid-setmode-modenumber-palette-createnative-src-miniquake-gl-vidnt-ml-492806569"></a>
### VID_SetMode

```ml
function VID_SetMode(modeNumber, palette, createNative)
```

Apply the Quake-compatible vid set mode behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_SetMode`. |
| `palette` | `dynamic` | — | The palette input consumed by `VID_SetMode`. |
| `createNative` | `dynamic` | — | The create native input consumed by `VID_SetMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L627)

<a id="function-function-miniquake-gl-vidnt-vid-setpalette-function-vid-setpalette-palette-src-miniquake-gl-vidnt-ml-1904768912"></a>
### VID_SetPalette

```ml
function VID_SetPalette(palette)
```

Apply the Quake-compatible vid set palette behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `palette` | `dynamic` | — | The palette input consumed by `VID_SetPalette`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L821)

<a id="function-function-miniquake-gl-vidnt-vid-setsoundmixer-function-vid-setsoundmixer-mixerstate-src-miniquake-gl-vidnt-ml-1538223607"></a>
### VID_SetSoundMixer

```ml
function VID_SetSoundMixer(mixerState)
```

Apply the Quake-compatible vid set sound mixer behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixerState` | `dynamic` | — | Mutable state used by `VID_SetSoundMixer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L380)

<a id="function-function-miniquake-gl-vidnt-vid-setwindowedmode-function-vid-setwindowedmode-modenumber-createnative-src-miniquake-gl-vidnt-ml-225432814"></a>
### VID_SetWindowedMode

```ml
function VID_SetWindowedMode(modeNumber, createNative)
```

Apply the Quake-compatible vid set windowed mode behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modeNumber` | `dynamic` | — | The mode number input consumed by `VID_SetWindowedMode`. |
| `createNative` | `dynamic` | — | The create native input consumed by `VID_SetWindowedMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L565)

<a id="function-function-miniquake-gl-vidnt-vid-shiftpalette-function-vid-shiftpalette-palette-src-miniquake-gl-vidnt-ml-508217560"></a>
### VID_ShiftPalette

```ml
function VID_ShiftPalette(palette)
```

Apply the Quake-compatible vid shift palette behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `palette` | `dynamic` | — | The palette input consumed by `VID_ShiftPalette`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L849)

<a id="function-function-miniquake-gl-vidnt-vid-shutdown-function-vid-shutdown-src-miniquake-gl-vidnt-ml-2092879249"></a>
### VID_Shutdown

```ml
function VID_Shutdown()
```

Apply the Quake-compatible vid shutdown behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L861)

<a id="function-function-miniquake-gl-vidnt-vid-sortmodes-function-vid-sortmodes-modes-src-miniquake-gl-vidnt-ml-1764177425"></a>
### VID_SortModes

```ml
function VID_SortModes(modes)
```

Apply the Quake-compatible vid sort modes behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modes` | `dynamic` | — | The modes input consumed by `VID_SortModes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L531)

<a id="function-function-miniquake-gl-vidnt-vid-state-function-vid-state-src-miniquake-gl-vidnt-ml-253688859"></a>
### VID_State

```ml
function VID_State()
```

Apply the Quake-compatible vid state behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L372)

<a id="function-function-miniquake-gl-vidnt-vid-synchronizesoundfocus-function-vid-synchronizesoundfocus-src-miniquake-gl-vidnt-ml-1887075351"></a>
### VID_SynchronizeSoundFocus

```ml
function VID_SynchronizeSoundFocus()
```

Reconcile focus only after the sound device has been attached.  The video window is created before waveOut during Host_Init; if it loses focus during that interval, AppActivate records soundBlocked but cannot yet increment the mixer's block depth.  Attaching the mixer without this reconciliation leaves the state flag and the actual depth out of sync until another focus edge.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L391)

<a id="function-function-miniquake-gl-vidnt-vid-synchronizesoundfocusifneeded-function-vid-synchronizesoundfocusifneeded-src-miniquake-gl-vidnt-ml-321478383"></a>
### VID_SynchronizeSoundFocusIfNeeded

```ml
function VID_SynchronizeSoundFocusIfNeeded()
```

Reconcile focus before every paint as well.  This deliberately compares the desired focus state with the mixer's real nesting depth rather than trusting soundBlocked: video starts before waveOut and renderer/display restarts also replace VideoState, so the two pieces of state can otherwise diverge.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L414)

<a id="function-function-miniquake-gl-vidnt-vid-toggleenhancedlighting-function-vid-toggleenhancedlighting-src-miniquake-gl-vidnt-ml-44720353"></a>
### VID_ToggleEnhancedLighting

```ml
function VID_ToggleEnhancedLighting()
```

Toggle the archived classic/enhanced renderer policy without changing maps.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1510)

<a id="function-function-miniquake-gl-vidnt-vid-toggleenhancedshadows-function-vid-toggleenhancedshadows-src-miniquake-gl-vidnt-ml-968354947"></a>
### VID_ToggleEnhancedShadows

```ml
function VID_ToggleEnhancedShadows()
```

Toggle archived dynamic entity shadows used by enhanced rendering.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1527)

<a id="function-function-miniquake-gl-vidnt-vid-togglefullscreen-function-vid-togglefullscreen-src-miniquake-gl-vidnt-ml-448395833"></a>
### VID_ToggleFullscreen

```ml
function VID_ToggleFullscreen()
```

Apply the Quake-compatible vid toggle fullscreen behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1733)

<a id="function-function-miniquake-gl-vidnt-vid-togglemodelinterpolation-function-vid-togglemodelinterpolation-src-miniquake-gl-vidnt-ml-1063403425"></a>
### VID_ToggleModelInterpolation

```ml
function VID_ToggleModelInterpolation()
```

Toggle archived interpolation between consecutive MDL animation poses.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1555)

<a id="function-function-miniquake-gl-vidnt-vid-unlockbuffer-function-vid-unlockbuffer-src-miniquake-gl-vidnt-ml-1289165233"></a>
### VID_UnlockBuffer

```ml
function VID_UnlockBuffer()
```

Apply the Quake-compatible vid unlock buffer behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L476)

<a id="function-function-miniquake-gl-vidnt-vid-updatewindowstatus-function-vid-updatewindowstatus-src-miniquake-gl-vidnt-ml-1292796753"></a>
### VID_UpdateWindowStatus

```ml
function VID_UpdateWindowStatus()
```

Apply the Quake-compatible vid update window status behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L664)

<a id="function-function-miniquake-gl-vidnt-vid-usestate-function-vid-usestate-state-src-miniquake-gl-vidnt-ml-268400450"></a>
### VID_UseState

```ml
function VID_UseState(state)
```

Apply the Quake-compatible vid use state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.gl_vidnt` state used by `VID_UseState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L365)

<a id="function-function-miniquake-gl-vidnt-vid-windowedrequested-function-vid-windowedrequested-arguments-src-miniquake-gl-vidnt-ml-1065757819"></a>
### VID_WindowedRequested

```ml
function VID_WindowedRequested(arguments)
```

Apply the Quake-compatible vid windowed requested behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L1207)

<a id="function-function-miniquake-gl-vidnt-vid-windowtitleforfps-inline-function-vid-windowtitleforfps-fps-src-miniquake-gl-vidnt-ml-180981609"></a>
### VID_WindowTitleForFps

```ml
inline function VID_WindowTitleForFps(fps)
```

Apply the Quake-compatible vid window title for fps behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fps` | `dynamic` | — | The fps input consumed by `VID_WindowTitleForFps`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L356)

<a id="global-global-miniquake-gl-vidnt-videomenuanisotropyfocus-videomenuanisotropyfocus-src-miniquake-gl-vidnt-ml-2011825675"></a>
### videoMenuAnisotropyFocus

```ml
videoMenuAnisotropyFocus
```

Tracks the module-level video menu anisotropy focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L217)

<a id="global-global-miniquake-gl-vidnt-videomenudisplayfocus-videomenudisplayfocus-src-miniquake-gl-vidnt-ml-360639731"></a>
### videoMenuDisplayFocus

```ml
videoMenuDisplayFocus
```

Tracks the module-level video menu display focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L203)

<a id="global-global-miniquake-gl-vidnt-videomenulightingfocus-videomenulightingfocus-src-miniquake-gl-vidnt-ml-927970019"></a>
### videoMenuLightingFocus

```ml
videoMenuLightingFocus
```

Tracks the module-level video menu lighting focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L207)

<a id="global-global-miniquake-gl-vidnt-videomenumodelinterpolationfocus-videomenumodelinterpolationfocus-src-miniquake-gl-vidnt-ml-2133313337"></a>
### videoMenuModelInterpolationFocus

```ml
videoMenuModelInterpolationFocus
```

Tracks the module-level video menu model interpolation focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L213)

<a id="global-global-miniquake-gl-vidnt-videomenurendererfocus-videomenurendererfocus-src-miniquake-gl-vidnt-ml-1496236541"></a>
### videoMenuRendererFocus

```ml
videoMenuRendererFocus
```

Tracks the module-level video menu renderer focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L205)

<a id="global-global-miniquake-gl-vidnt-videomenuselection-videomenuselection-src-miniquake-gl-vidnt-ml-1120351395"></a>
### videoMenuSelection

```ml
videoMenuSelection
```

Tracks the module-level video menu selection state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L201)

<a id="global-global-miniquake-gl-vidnt-videomenushadowfocus-videomenushadowfocus-src-miniquake-gl-vidnt-ml-1225829347"></a>
### videoMenuShadowFocus

```ml
videoMenuShadowFocus
```

Tracks the module-level video menu shadow focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L209)

<a id="global-global-miniquake-gl-vidnt-videomenushadowqualityfocus-videomenushadowqualityfocus-src-miniquake-gl-vidnt-ml-245925319"></a>
### videoMenuShadowQualityFocus

```ml
videoMenuShadowQualityFocus
```

Tracks the module-level video menu shadow quality focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L211)

<a id="global-global-miniquake-gl-vidnt-videomenutextureupscalefocus-videomenutextureupscalefocus-src-miniquake-gl-vidnt-ml-245452843"></a>
### videoMenuTextureUpscaleFocus

```ml
videoMenuTextureUpscaleFocus
```

Tracks the module-level video menu texture upscale focus state owned by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L215)

- [miniquake.gl_vidnt.VideoMode](Type-miniquake-gl-vidnt-videomode-463073728.md) — struct
- [miniquake.gl_vidnt.VideoState](Type-miniquake-gl-vidnt-videostate-1099498728.md) — struct
<a id="constant-constant-miniquake-gl-vidnt-warp-height-const-warp-height-200-src-miniquake-gl-vidnt-ml-1728162368"></a>
### WARP_HEIGHT

```ml
const WARP_HEIGHT = 200
```

Defines the warp height value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L34)

<a id="constant-constant-miniquake-gl-vidnt-warp-width-const-warp-width-320-src-miniquake-gl-vidnt-ml-104257061"></a>
### WARP_WIDTH

```ml
const WARP_WIDTH = 320
```

Defines the warp width value used by `miniquake.gl_vidnt`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_vidnt.ml#L32)
