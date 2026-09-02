# `src/miniquake/menu.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.menu`](Package-miniquake-menu-1879276712.md)

Reachable from entry: **yes**

## Imports

- `miniquake/cvar.ml` as `menuCvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/filesystem.ml` as `menuFs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/gl_vidnt.ml` as `glvid` → [src/miniquake/gl_vidnt.ml](File-src-miniquake-gl-vidnt-ml-1573847321.md)
- `miniquake/input.ml` as `menuInput` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/keys.ml` as `menuKeys` → [src/miniquake/keys.ml](File-src-miniquake-keys-ml-299795526.md)
- `miniquake/mathlib.ml` as `menuMath` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `menuNative` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_main.ml` as `menuNet` → [src/miniquake/net_main.ml](File-src-miniquake-net-main-ml-940970693.md)
- `miniquake/render/draw2d.ml` as `menuDraw` → [src/miniquake/render/draw2d.ml](File-src-miniquake-render-draw2d-ml-1547120567.md)
- `miniquake/render/gl11.ml` as `menuGl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render_ui_contract.ml` as `menuUiContract` → [src/miniquake/render_ui_contract.ml](File-src-miniquake-render-ui-contract-ml-1308372980.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/wad.ml` as `menuWad` → [src/miniquake/wad.ml](File-src-miniquake-wad-ml-1195240084.md)

## Declarations

<a id="function-function-miniquake-menu-back-function-back-state-src-miniquake-menu-ml-1081864978"></a>
### back

```ml
function back(state)
```

This mirrors the original escape path: submenus return to the main menu; escape from the main menu returns to the game; quit returns to its caller.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `back`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L374)

<a id="function-function-miniquake-menu-baseepisodes-function-baseepisodes-src-miniquake-menu-ml-106550397"></a>
### baseEpisodes

```ml
function baseEpisodes()
```

Implements the `baseEpisodes` operation for `miniquake.menu` (base episodes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1107)

<a id="function-function-miniquake-menu-baselevels-function-baselevels-src-miniquake-menu-ml-1377728381"></a>
### baseLevels

```ml
function baseLevels()
```

Implements the `baseLevels` operation for `miniquake.menu` (base levels).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1120)

<a id="global-global-miniquake-menu-cachedlayout-cachedlayout-src-miniquake-menu-ml-1919341415"></a>
### cachedLayout

```ml
cachedLayout
```

Tracks the module-level cached layout state owned by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L76)

<a id="global-global-miniquake-menu-cachedlayoutheight-cachedlayoutheight-src-miniquake-menu-ml-515108813"></a>
### cachedLayoutHeight

```ml
cachedLayoutHeight
```

Tracks the module-level cached layout height state owned by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L74)

<a id="global-global-miniquake-menu-cachedlayoutwidth-cachedlayoutwidth-src-miniquake-menu-ml-96319255"></a>
### cachedLayoutWidth

```ml
cachedLayoutWidth
```

Tracks the module-level cached layout width state owned by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L72)

<a id="function-function-miniquake-menu-changehelppage-function-changehelppage-state-delta-src-miniquake-menu-ml-529069570"></a>
### changeHelpPage

```ml
function changeHelpPage(state, delta)
```

Update subsystem configuration for change help page.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `changeHelpPage`. |
| `delta` | `dynamic` | — | The delta input consumed by `changeHelpPage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L367)

<a id="function-function-miniquake-menu-create-function-create-src-miniquake-menu-ml-1546673833"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.menu` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L185)

<a id="function-function-miniquake-menu-drawcheckbox-function-drawcheckbox-texture-x-y-enabled-transform-src-miniquake-menu-ml-1443867116"></a>
### drawCheckbox

```ml
function drawCheckbox(texture, x, y, enabled, transform)
```

Render checkbox.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `drawCheckbox`. |
| `y` | `dynamic` | — | The y input consumed by `drawCheckbox`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `transform` | `dynamic` | — | The transform input consumed by `drawCheckbox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L911)

<a id="function-function-miniquake-menu-drawdot-function-drawdot-state-realtime-y-transform-src-miniquake-menu-ml-849204296"></a>
### drawDot

```ml
function drawDot(state, realtime, y, transform)
```

Render dot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawDot`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `y` | `dynamic` | — | The y input consumed by `drawDot`. |
| `transform` | `dynamic` | — | The transform input consumed by `drawDot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L840)

<a id="function-function-miniquake-menu-drawfallbacklist-function-drawfallbacklist-state-texture-transform-src-miniquake-menu-ml-2069807533"></a>
### drawFallbackList

```ml
function drawFallbackList(state, texture, transform)
```

Render fallback list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawFallbackList`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawFallbackList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L822)

<a id="function-function-miniquake-menu-drawgameoptions-function-drawgameoptions-state-texture-transform-realtime-registry-src-miniquake-menu-ml-1369128367"></a>
### drawGameOptions

```ml
function drawGameOptions(state, texture, transform, realtime, registry)
```

Render game options.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawGameOptions`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawGameOptions`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `drawGameOptions`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1294)

<a id="function-function-miniquake-menu-drawhelp-function-drawhelp-state-texture-transform-src-miniquake-menu-ml-238674873"></a>
### drawHelp

```ml
function drawHelp(state, texture, transform)
```

Render help.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawHelp`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawHelp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1498)

<a id="function-function-miniquake-menu-drawkeys-function-drawkeys-state-texture-transform-realtime-src-miniquake-menu-ml-1123860962"></a>
### drawKeys

```ml
function drawKeys(state, texture, transform, realtime)
```

Render keys.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawKeys`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawKeys`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L992)

<a id="function-function-miniquake-menu-drawlanconfig-function-drawlanconfig-state-texture-transform-realtime-src-miniquake-menu-ml-890851520"></a>
### drawLanConfig

```ml
function drawLanConfig(state, texture, transform, realtime)
```

Render lan config.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawLanConfig`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawLanConfig`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1236)

<a id="function-function-miniquake-menu-drawmain-function-drawmain-state-texture-transform-realtime-src-miniquake-menu-ml-222682390"></a>
### drawMain

```ml
function drawMain(state, texture, transform, realtime)
```

Render main.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawMain`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawMain`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L850)

<a id="function-function-miniquake-menu-drawmultiplayer-function-drawmultiplayer-state-texture-transform-realtime-src-miniquake-menu-ml-1748864754"></a>
### drawMultiplayer

```ml
function drawMultiplayer(state, texture, transform, realtime)
```

Render multiplayer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawMultiplayer`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawMultiplayer`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L876)

<a id="function-function-miniquake-menu-drawnetwork-function-drawnetwork-state-texture-transform-realtime-src-miniquake-menu-ml-1642872686"></a>
### drawNetwork

```ml
function drawNetwork(state, texture, transform, realtime)
```

Render network.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawNetwork`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawNetwork`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1214)

<a id="function-function-miniquake-menu-drawoptions-function-drawoptions-state-texture-transform-realtime-registry-src-miniquake-menu-ml-796416903"></a>
### drawOptions

```ml
function drawOptions(state, texture, transform, realtime, registry)
```

Render options.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawOptions`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawOptions`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `drawOptions`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L925)

<a id="function-function-miniquake-menu-drawpage-function-drawpage-state-texture-transform-realtime-registry-page-src-miniquake-menu-ml-531205798"></a>
### drawPage

```ml
function drawPage(state, texture, transform, realtime, registry, page)
```

Render page.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawPage`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawPage`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `drawPage`. |
| `page` | `dynamic` | — | The page input consumed by `drawPage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1542)

<a id="function-function-miniquake-menu-drawquit-function-drawquit-state-texture-transform-src-miniquake-menu-ml-1046271201"></a>
### drawQuit

```ml
function drawQuit(state, texture, transform)
```

Render quit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawQuit`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawQuit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1510)

<a id="function-function-miniquake-menu-drawsaveslots-function-drawsaveslots-state-texture-transform-realtime-page-src-miniquake-menu-ml-2858891"></a>
### drawSaveSlots

```ml
function drawSaveSlots(state, texture, transform, realtime, page)
```

Render save slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawSaveSlots`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawSaveSlots`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `page` | `dynamic` | — | The page input consumed by `drawSaveSlots`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1031)

<a id="function-function-miniquake-menu-drawsearch-function-drawsearch-state-texture-transform-src-miniquake-menu-ml-821114341"></a>
### drawSearch

```ml
function drawSearch(state, texture, transform)
```

Render search.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawSearch`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawSearch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1336)

<a id="function-function-miniquake-menu-drawserverlist-function-drawserverlist-state-texture-transform-realtime-src-miniquake-menu-ml-681454582"></a>
### drawServerList

```ml
function drawServerList(state, texture, transform, realtime)
```

Render server list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawServerList`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawServerList`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1411)

<a id="function-function-miniquake-menu-drawsetup-function-drawsetup-state-texture-transform-realtime-registry-src-miniquake-menu-ml-2103528113"></a>
### drawSetup

```ml
function drawSetup(state, texture, transform, realtime, registry)
```

Render setup.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawSetup`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawSetup`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `drawSetup`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1072)

<a id="function-function-miniquake-menu-drawsingleplayer-function-drawsingleplayer-state-texture-transform-realtime-src-miniquake-menu-ml-1418795574"></a>
### drawSinglePlayer

```ml
function drawSinglePlayer(state, texture, transform, realtime)
```

Render single player.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawSinglePlayer`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawSinglePlayer`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L863)

<a id="function-function-miniquake-menu-drawslider-function-drawslider-texture-x-y-range-transform-src-miniquake-menu-ml-1650644312"></a>
### drawSlider

```ml
function drawSlider(texture, x, y, range, transform)
```

Render slider.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `drawSlider`. |
| `y` | `dynamic` | — | The y input consumed by `drawSlider`. |
| `range` | `dynamic` | — | The range input consumed by `drawSlider`. |
| `transform` | `dynamic` | — | The transform input consumed by `drawSlider`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L891)

<a id="function-function-miniquake-menu-drawtextbox-function-drawtextbox-state-x-y-width-lines-transform-src-miniquake-menu-ml-1105163588"></a>
### drawTextBox

```ml
function drawTextBox(state, x, y, width, lines, transform)
```

M_DrawTextBox from WinQuake/menu.c. Width is measured in characters; every center tile covers two characters (16 pixels).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawTextBox`. |
| `x` | `dynamic` | — | The x input consumed by `drawTextBox`. |
| `y` | `dynamic` | — | The y input consumed by `drawTextBox`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `lines` | `dynamic` | — | The lines input consumed by `drawTextBox`. |
| `transform` | `dynamic` | — | The transform input consumed by `drawTextBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L774)

<a id="function-function-miniquake-menu-drawvideo-function-drawvideo-state-texture-transform-realtime-src-miniquake-menu-ml-845728148"></a>
### drawVideo

```ml
function drawVideo(state, texture, transform, realtime)
```

Render video.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `drawVideo`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `drawVideo`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1433)

<a id="function-function-miniquake-menu-episodetable-function-episodetable-state-src-miniquake-menu-ml-1760859126"></a>
### episodeTable

```ml
function episodeTable(state)
```

Implements the `episodeTable` operation for `miniquake.menu` (episode table).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `episodeTable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1186)

<a id="function-function-miniquake-menu-excludedmenupath-function-excludedmenupath-state-name-src-miniquake-menu-ml-129076347"></a>
### excludedMenuPath

```ml
function excludedMenuPath(state, name)
```

Return excluded menu path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `excludedMenuPath`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1879)

<a id="function-function-miniquake-menu-findpicture-function-findpicture-state-name-src-miniquake-menu-ml-928231785"></a>
### findPicture

```ml
function findPicture(state, name)
```

Return picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `findPicture`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L443)

<a id="function-function-miniquake-menu-findwadpicture-function-findwadpicture-state-lumpname-src-miniquake-menu-ml-1813276789"></a>
### findWadPicture

```ml
function findWadPicture(state, lumpName)
```

Return wad picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `findWadPicture`. |
| `lumpName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L485)

<a id="function-function-miniquake-menu-fixedserverfield-function-fixedserverfield-text-width-src-miniquake-menu-ml-2067939654"></a>
### fixedServerField

```ml
function fixedServerField(text, width)
```

Implements the `fixedServerField` operation for `miniquake.menu` (fixed server field).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1388)

<a id="function-function-miniquake-menu-gametypetext-function-gametypetext-registry-src-miniquake-menu-ml-1703396592"></a>
### gameTypeText

```ml
function gameTypeText(registry)
```

Implements the `gameTypeText` operation for `miniquake.menu` (game type text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `gameTypeText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1267)

<a id="constant-constant-miniquake-menu-help-pages-const-help-pages-6-src-miniquake-menu-ml-1990071354"></a>
### HELP_PAGES

```ml
const HELP_PAGES = 6
```

Defines the help pages value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L65)

<a id="function-function-miniquake-menu-hipnoticepisodes-function-hipnoticepisodes-src-miniquake-menu-ml-15679769"></a>
### hipnoticEpisodes

```ml
function hipnoticEpisodes()
```

Implements the `hipnoticEpisodes` operation for `miniquake.menu` (hipnotic episodes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1138)

<a id="function-function-miniquake-menu-hipnoticlevels-function-hipnoticlevels-src-miniquake-menu-ml-913608725"></a>
### hipnoticLevels

```ml
function hipnoticLevels()
```

Implements the `hipnoticLevels` operation for `miniquake.menu` (hipnotic levels).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1150)

<a id="function-function-miniquake-menu-initialize-function-initialize-state-filesystem-palette-src-miniquake-menu-ml-2038091446"></a>
### initialize

```ml
function initialize(state, filesystem, palette)
```

Initializes ialize for `miniquake.menu`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `initialize`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `initialize`. |
| `palette` | `dynamic` | — | The palette input consumed by `initialize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L546)

<a id="function-function-miniquake-menu-itemsforpage-function-itemsforpage-page-src-miniquake-menu-ml-130235872"></a>
### itemsForPage

```ml
function itemsForPage(page)
```

Implements the `itemsForPage` operation for `miniquake.menu` (items for page).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `itemsForPage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L146)

<a id="function-function-miniquake-menu-keycommandat-function-keycommandat-state-src-miniquake-menu-ml-822376270"></a>
### keyCommandAt

```ml
function keyCommandAt(state)
```

Implements the `keyCommandAt` operation for `miniquake.menu` (key command at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `keyCommandAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L981)

<a id="function-function-miniquake-menu-keycommands-function-keycommands-src-miniquake-menu-ml-785593115"></a>
### keyCommands

```ml
function keyCommands()
```

Implements the `keyCommands` operation for `miniquake.menu` (key commands).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L115)

<a id="function-function-miniquake-menu-keyitems-function-keyitems-src-miniquake-menu-ml-1247662333"></a>
### keyItems

```ml
function keyItems()
```

Implements the `keyItems` operation for `miniquake.menu` (key items).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L125)

<a id="function-function-miniquake-menu-layout-function-layout-width-height-src-miniquake-menu-ml-271447152"></a>
### layout

```ml
function layout(width, height)
```

Implements the `layout` operation for `miniquake.menu` (layout).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L631)

<a id="function-function-miniquake-menu-leveltable-function-leveltable-state-src-miniquake-menu-ml-394486174"></a>
### levelTable

```ml
function levelTable(state)
```

Implements the `levelTable` operation for `miniquake.menu` (level table).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `levelTable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1194)

<a id="function-function-miniquake-menu-loadpicture-function-loadpicture-state-filesystem-palette-path-transparent-src-miniquake-menu-ml-1568947077"></a>
### loadPicture

```ml
function loadPicture(state, filesystem, palette, path, transparent)
```

Read and validate picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `loadPicture`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `loadPicture`. |
| `palette` | `dynamic` | — | The palette input consumed by `loadPicture`. |
| `path` | `dynamic` | — | Filesystem path to process. |
| `transparent` | `dynamic` | — | The transparent input consumed by `loadPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L456)

<a id="function-function-miniquake-menu-loadstatusbarpictures-function-loadstatusbarpictures-state-filesystem-palette-src-miniquake-menu-ml-189448606"></a>
### loadStatusBarPictures

```ml
function loadStatusBarPictures(state, filesystem, palette)
```

Read and validate status bar pictures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `loadStatusBarPictures`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `loadStatusBarPictures`. |
| `palette` | `dynamic` | — | The palette input consumed by `loadStatusBarPictures`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L493)

<a id="function-function-miniquake-menu-loadwadpicture-function-loadwadpicture-state-archive-palette-lumpname-transparent-src-miniquake-menu-ml-1236307970"></a>
### loadWadPicture

```ml
function loadWadPicture(state, archive, palette, lumpName, transparent)
```

Draw_PicFromWad compatibility. Status-bar and common UI pictures live in gfx.wad rather than as loose qpic files. Keep a distinct registry key so a WAD lump can never collide with a similarly named filesystem picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `loadWadPicture`. |
| `archive` | `dynamic` | — | The archive input consumed by `loadWadPicture`. |
| `palette` | `dynamic` | — | The palette input consumed by `loadWadPicture`. |
| `lumpName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `transparent` | `dynamic` | — | The transparent input consumed by `loadWadPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L473)

<a id="function-function-miniquake-menu-m-adjustsliders-function-m-adjustsliders-state-registry-direction-src-miniquake-menu-ml-227258514"></a>
### M_AdjustSliders

```ml
function M_AdjustSliders(state, registry, direction)
```

Apply the Quake-compatible m adjust sliders behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_AdjustSliders`. |
| `registry` | `dynamic` | — | The registry input consumed by `M_AdjustSliders`. |
| `direction` | `dynamic` | — | The direction input consumed by `M_AdjustSliders`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2178)

<a id="function-function-miniquake-menu-m-buildtranslationtable-function-m-buildtranslationtable-top-bottom-src-miniquake-menu-ml-831610495"></a>
### M_BuildTranslationTable

```ml
function M_BuildTranslationTable(top, bottom)
```

Apply the Quake-compatible m build translation table behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `top` | `dynamic` | — | The top input consumed by `M_BuildTranslationTable`. |
| `bottom` | `dynamic` | — | The bottom input consumed by `M_BuildTranslationTable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1688)

<a id="function-function-miniquake-menu-m-commandtrace-function-m-commandtrace-state-src-miniquake-menu-ml-1487797198"></a>
### M_CommandTrace

```ml
function M_CommandTrace(state)
```

Apply the Quake-compatible m command trace behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_CommandTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2695)

<a id="function-function-miniquake-menu-m-configurenetsubsystem-function-m-configurenetsubsystem-state-src-miniquake-menu-ml-530653782"></a>
### M_ConfigureNetSubsystem

```ml
function M_ConfigureNetSubsystem(state)
```

Apply the Quake-compatible m configure net subsystem behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ConfigureNetSubsystem`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2679)

<a id="function-function-miniquake-menu-m-draw-function-m-draw-state-texture-width-height-mapname-realtime-registry-src-miniquake-menu-ml-142360063"></a>
### M_Draw

```ml
function M_Draw(state, texture, width, height, mapName, realtime, registry)
```

Apply the Quake-compatible m draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `M_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1582)

<a id="function-function-miniquake-menu-m-drawcharacter-function-m-drawcharacter-texture-x-y-number-transform-src-miniquake-menu-ml-900163906"></a>
### M_DrawCharacter

```ml
function M_DrawCharacter(texture, x, y, number, transform)
```

Apply the Quake-compatible m draw character behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawCharacter`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawCharacter`. |
| `number` | `dynamic` | — | The number input consumed by `M_DrawCharacter`. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawCharacter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1639)

<a id="function-function-miniquake-menu-m-drawcheckbox-function-m-drawcheckbox-texture-x-y-enabled-transform-src-miniquake-menu-ml-348238092"></a>
### M_DrawCheckbox

```ml
function M_DrawCheckbox(texture, x, y, enabled, transform)
```

Apply the Quake-compatible m draw checkbox behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawCheckbox`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawCheckbox`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawCheckbox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2235)

<a id="function-function-miniquake-menu-m-drawpic-function-m-drawpic-state-name-x-y-transform-src-miniquake-menu-ml-356738708"></a>
### M_DrawPic

```ml
function M_DrawPic(state, name, x, y, transform)
```

Apply the Quake-compatible m draw pic behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_DrawPic`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawPic`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawPic`. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1681)

<a id="function-function-miniquake-menu-m-drawslider-function-m-drawslider-texture-x-y-range-transform-src-miniquake-menu-ml-850434608"></a>
### M_DrawSlider

```ml
function M_DrawSlider(texture, x, y, range, transform)
```

Apply the Quake-compatible m draw slider behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawSlider`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawSlider`. |
| `range` | `dynamic` | — | The range input consumed by `M_DrawSlider`. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawSlider`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2224)

<a id="function-function-miniquake-menu-m-drawtextbox-function-m-drawtextbox-state-x-y-width-lines-transform-src-miniquake-menu-ml-1079682884"></a>
### M_DrawTextBox

```ml
function M_DrawTextBox(state, x, y, width, lines, transform)
```

Apply the Quake-compatible m draw text box behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_DrawTextBox`. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawTextBox`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawTextBox`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `lines` | `dynamic` | — | The lines input consumed by `M_DrawTextBox`. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawTextBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1733)

<a id="function-function-miniquake-menu-m-drawtranspic-function-m-drawtranspic-state-name-x-y-transform-src-miniquake-menu-ml-417298700"></a>
### M_DrawTransPic

```ml
function M_DrawTransPic(state, name, x, y, transform)
```

Apply the Quake-compatible m draw trans pic behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_DrawTransPic`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawTransPic`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawTransPic`. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawTransPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1671)

<a id="function-function-miniquake-menu-m-drawtranspictranslate-function-m-drawtranspictranslate-state-name-x-y-transform-top-bottom-src-miniquake-menu-ml-517005062"></a>
### M_DrawTransPicTranslate

```ml
function M_DrawTransPicTranslate(state, name, x, y, transform, top, bottom)
```

Apply the Quake-compatible m draw trans pic translate behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_DrawTransPicTranslate`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `x` | `dynamic` | — | The x input consumed by `M_DrawTransPicTranslate`. |
| `y` | `dynamic` | — | The y input consumed by `M_DrawTransPicTranslate`. |
| `transform` | `dynamic` | — | The transform input consumed by `M_DrawTransPicTranslate`. |
| `top` | `dynamic` | — | The top input consumed by `M_DrawTransPicTranslate`. |
| `bottom` | `dynamic` | — | The bottom input consumed by `M_DrawTransPicTranslate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1712)

<a id="function-function-miniquake-menu-m-excludedpaths-function-m-excludedpaths-state-src-miniquake-menu-ml-140616646"></a>
### M_ExcludedPaths

```ml
function M_ExcludedPaths(state)
```

Apply the Quake-compatible m excluded paths behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ExcludedPaths`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2701)

<a id="function-function-miniquake-menu-m-findkeysforcommand-function-m-findkeysforcommand-command-src-miniquake-menu-ml-372819290"></a>
### M_FindKeysForCommand

```ml
function M_FindKeysForCommand(command)
```

Apply the Quake-compatible m find keys for command behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2242)

<a id="function-function-miniquake-menu-m-gameoptions-draw-function-m-gameoptions-draw-state-texture-transform-realtime-registry-src-miniquake-menu-ml-1961425499"></a>
### M_GameOptions_Draw

```ml
function M_GameOptions_Draw(state, texture, transform, realtime, registry)
```

Apply the Quake-compatible m game options draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_GameOptions_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_GameOptions_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `M_GameOptions_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2124)

<a id="function-function-miniquake-menu-m-gameoptions-key-function-m-gameoptions-key-state-key-registry-src-miniquake-menu-ml-1136189136"></a>
### M_GameOptions_Key

```ml
function M_GameOptions_Key(state, key, registry)
```

Apply the Quake-compatible m game options key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_GameOptions_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `registry` | `dynamic` | — | The registry input consumed by `M_GameOptions_Key`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2615)

<a id="function-function-miniquake-menu-m-help-draw-function-m-help-draw-state-texture-transform-src-miniquake-menu-ml-2114007445"></a>
### M_Help_Draw

```ml
function M_Help_Draw(state, texture, transform)
```

Apply the Quake-compatible m help draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Help_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Help_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2074)

<a id="function-function-miniquake-menu-m-help-key-function-m-help-key-state-key-src-miniquake-menu-ml-1948002957"></a>
### M_Help_Key

```ml
function M_Help_Key(state, key)
```

Apply the Quake-compatible m help key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Help_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2477)

<a id="function-function-miniquake-menu-m-init-function-m-init-state-src-miniquake-menu-ml-1820612878"></a>
### M_Init

```ml
function M_Init(state)
```

Apply the Quake-compatible m init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2707)

<a id="function-function-miniquake-menu-m-keydown-function-m-keydown-state-key-registry-src-miniquake-menu-ml-1693810738"></a>
### M_Keydown

```ml
function M_Keydown(state, key, registry)
```

Apply the Quake-compatible m keydown behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Keydown`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `registry` | `dynamic` | — | The registry input consumed by `M_Keydown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2655)

<a id="function-function-miniquake-menu-m-keys-draw-function-m-keys-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1154458376"></a>
### M_Keys_Draw

```ml
function M_Keys_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m keys draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Keys_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Keys_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2054)

<a id="function-function-miniquake-menu-m-keys-key-function-m-keys-key-state-key-src-miniquake-menu-ml-837934309"></a>
### M_Keys_Key

```ml
function M_Keys_Key(state, key)
```

Apply the Quake-compatible m keys key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Keys_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2436)

<a id="function-function-miniquake-menu-m-lanconfig-draw-function-m-lanconfig-draw-state-texture-transform-realtime-src-miniquake-menu-ml-286625390"></a>
### M_LanConfig_Draw

```ml
function M_LanConfig_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m lan config draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_LanConfig_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_LanConfig_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2113)

<a id="function-function-miniquake-menu-m-lanconfig-key-function-m-lanconfig-key-state-key-src-miniquake-menu-ml-743554095"></a>
### M_LanConfig_Key

```ml
function M_LanConfig_Key(state, key)
```

Apply the Quake-compatible m lan config key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_LanConfig_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2526)

<a id="function-function-miniquake-menu-m-load-draw-function-m-load-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1291008860"></a>
### M_Load_Draw

```ml
function M_Load_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m load draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Load_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Load_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1992)

<a id="function-function-miniquake-menu-m-load-key-function-m-load-key-state-key-src-miniquake-menu-ml-183481921"></a>
### M_Load_Key

```ml
function M_Load_Key(state, key)
```

Apply the Quake-compatible m load key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Load_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2331)

<a id="function-function-miniquake-menu-m-main-draw-function-m-main-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1464579638"></a>
### M_Main_Draw

```ml
function M_Main_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m main draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Main_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Main_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1972)

<a id="function-function-miniquake-menu-m-main-key-function-m-main-key-state-key-src-miniquake-menu-ml-383814445"></a>
### M_Main_Key

```ml
function M_Main_Key(state, key)
```

Apply the Quake-compatible m main key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Main_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2309)

<a id="function-function-miniquake-menu-m-menu-gameoptions-f-function-m-menu-gameoptions-f-state-maximumclients-missionpack-src-miniquake-menu-ml-168812939"></a>
### M_Menu_GameOptions_f

```ml
function M_Menu_GameOptions_f(state, maximumClients, missionPack)
```

Apply the Quake-compatible m menu game options f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_GameOptions_f`. |
| `maximumClients` | `dynamic` | — | The maximum clients input consumed by `M_Menu_GameOptions_f`. |
| `missionPack` | `dynamic` | — | The mission pack input consumed by `M_Menu_GameOptions_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1921)

<a id="function-function-miniquake-menu-m-menu-help-f-function-m-menu-help-f-state-src-miniquake-menu-ml-708672998"></a>
### M_Menu_Help_f

```ml
function M_Menu_Help_f(state)
```

Apply the Quake-compatible m menu help f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Help_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1857)

<a id="function-function-miniquake-menu-m-menu-keys-f-function-m-menu-keys-f-state-src-miniquake-menu-ml-1699884244"></a>
### M_Menu_Keys_f

```ml
function M_Menu_Keys_f(state)
```

Apply the Quake-compatible m menu keys f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Keys_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1838)

<a id="function-function-miniquake-menu-m-menu-lanconfig-f-function-m-menu-lanconfig-f-state-src-miniquake-menu-ml-2059714326"></a>
### M_Menu_LanConfig_f

```ml
function M_Menu_LanConfig_f(state)
```

Apply the Quake-compatible m menu lan config f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_LanConfig_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1899)

<a id="function-function-miniquake-menu-m-menu-load-f-function-m-menu-load-f-state-src-miniquake-menu-ml-254860216"></a>
### M_Menu_Load_f

```ml
function M_Menu_Load_f(state)
```

Apply the Quake-compatible m menu load f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Load_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1769)

<a id="function-function-miniquake-menu-m-menu-main-f-function-m-menu-main-f-state-src-miniquake-menu-ml-649804734"></a>
### M_Menu_Main_f

```ml
function M_Menu_Main_f(state)
```

Apply the Quake-compatible m menu main f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Main_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1751)

<a id="function-function-miniquake-menu-m-menu-modemconfig-f-function-m-menu-modemconfig-f-state-src-miniquake-menu-ml-928814022"></a>
### M_Menu_ModemConfig_f

```ml
function M_Menu_ModemConfig_f(state)
```

Apply the Quake-compatible m menu modem config f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_ModemConfig_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1893)

<a id="function-function-miniquake-menu-m-menu-multiplayer-f-function-m-menu-multiplayer-f-state-src-miniquake-menu-ml-1299327078"></a>
### M_Menu_MultiPlayer_f

```ml
function M_Menu_MultiPlayer_f(state)
```

Apply the Quake-compatible m menu multi player f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_MultiPlayer_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1791)

<a id="function-function-miniquake-menu-m-menu-net-f-function-m-menu-net-f-state-src-miniquake-menu-ml-1937181030"></a>
### M_Menu_Net_f

```ml
function M_Menu_Net_f(state)
```

Apply the Quake-compatible m menu net f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Net_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1817)

<a id="function-function-miniquake-menu-m-menu-options-f-function-m-menu-options-f-state-src-miniquake-menu-ml-268457426"></a>
### M_Menu_Options_f

```ml
function M_Menu_Options_f(state)
```

Apply the Quake-compatible m menu options f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Options_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1829)

<a id="function-function-miniquake-menu-m-menu-quit-f-function-m-menu-quit-f-state-src-miniquake-menu-ml-490710734"></a>
### M_Menu_Quit_f

```ml
function M_Menu_Quit_f(state)
```

Apply the Quake-compatible m menu quit f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Quit_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1867)

<a id="function-function-miniquake-menu-m-menu-save-f-function-m-menu-save-f-state-serveractive-intermission-maxclients-src-miniquake-menu-ml-717040227"></a>
### M_Menu_Save_f

```ml
function M_Menu_Save_f(state, serverActive, intermission, maxClients)
```

Apply the Quake-compatible m menu save f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Save_f`. |
| `serverActive` | `dynamic` | — | The server active input consumed by `M_Menu_Save_f`. |
| `intermission` | `dynamic` | — | The intermission input consumed by `M_Menu_Save_f`. |
| `maxClients` | `dynamic` | — | The max clients input consumed by `M_Menu_Save_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1781)

<a id="function-function-miniquake-menu-m-menu-search-f-function-m-menu-search-f-state-network-port-realtime-src-miniquake-menu-ml-1660391942"></a>
### M_Menu_Search_f

```ml
function M_Menu_Search_f(state, network, port, realtime)
```

Apply the Quake-compatible m menu search f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Search_f`. |
| `network` | `dynamic` | — | The network input consumed by `M_Menu_Search_f`. |
| `port` | `dynamic` | — | The port input consumed by `M_Menu_Search_f`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1938)

<a id="function-function-miniquake-menu-m-menu-serialconfig-f-function-m-menu-serialconfig-f-state-src-miniquake-menu-ml-1735033564"></a>
### M_Menu_SerialConfig_f

```ml
function M_Menu_SerialConfig_f(state)
```

Apply the Quake-compatible m menu serial config f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_SerialConfig_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1887)

<a id="function-function-miniquake-menu-m-menu-serverlist-f-function-m-menu-serverlist-f-state-servers-src-miniquake-menu-ml-1176456516"></a>
### M_Menu_ServerList_f

```ml
function M_Menu_ServerList_f(state, servers)
```

Apply the Quake-compatible m menu server list f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_ServerList_f`. |
| `servers` | `dynamic` | — | The servers input consumed by `M_Menu_ServerList_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1952)

<a id="function-function-miniquake-menu-m-menu-setup-f-function-m-menu-setup-f-state-registry-src-miniquake-menu-ml-596082431"></a>
### M_Menu_Setup_f

```ml
function M_Menu_Setup_f(state, registry)
```

Apply the Quake-compatible m menu setup f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Setup_f`. |
| `registry` | `dynamic` | — | The registry input consumed by `M_Menu_Setup_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1801)

<a id="function-function-miniquake-menu-m-menu-singleplayer-f-function-m-menu-singleplayer-f-state-src-miniquake-menu-ml-1165065778"></a>
### M_Menu_SinglePlayer_f

```ml
function M_Menu_SinglePlayer_f(state)
```

Apply the Quake-compatible m menu single player f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_SinglePlayer_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1760)

<a id="function-function-miniquake-menu-m-menu-video-f-function-m-menu-video-f-state-src-miniquake-menu-ml-2047072462"></a>
### M_Menu_Video_f

```ml
function M_Menu_Video_f(state)
```

Apply the Quake-compatible m menu video f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Menu_Video_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1847)

<a id="function-function-miniquake-menu-m-modemconfig-draw-function-m-modemconfig-draw-state-texture-transform-src-miniquake-menu-ml-151314821"></a>
### M_ModemConfig_Draw

```ml
function M_ModemConfig_Draw(state, texture, transform)
```

Apply the Quake-compatible m modem config draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ModemConfig_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_ModemConfig_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2102)

<a id="function-function-miniquake-menu-m-modemconfig-key-function-m-modemconfig-key-state-key-src-miniquake-menu-ml-2043126673"></a>
### M_ModemConfig_Key

```ml
function M_ModemConfig_Key(state, key)
```

Apply the Quake-compatible m modem config key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ModemConfig_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2504)

<a id="function-function-miniquake-menu-m-multiplayer-draw-function-m-multiplayer-draw-state-texture-transform-realtime-src-miniquake-menu-ml-539419946"></a>
### M_MultiPlayer_Draw

```ml
function M_MultiPlayer_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m multi player draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_MultiPlayer_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_MultiPlayer_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2012)

<a id="function-function-miniquake-menu-m-multiplayer-key-function-m-multiplayer-key-state-key-src-miniquake-menu-ml-390903709"></a>
### M_MultiPlayer_Key

```ml
function M_MultiPlayer_Key(state, key)
```

Apply the Quake-compatible m multi player key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_MultiPlayer_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2353)

<a id="function-function-miniquake-menu-m-net-draw-function-m-net-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1754210642"></a>
### M_Net_Draw

```ml
function M_Net_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m net draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Net_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Net_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2033)

<a id="function-function-miniquake-menu-m-net-key-function-m-net-key-state-key-src-miniquake-menu-ml-1302636283"></a>
### M_Net_Key

```ml
function M_Net_Key(state, key)
```

Apply the Quake-compatible m net key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Net_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2402)

<a id="function-function-miniquake-menu-m-netstart-change-function-m-netstart-change-state-registry-direction-src-miniquake-menu-ml-1469240120"></a>
### M_NetStart_Change

```ml
function M_NetStart_Change(state, registry, direction)
```

Apply the Quake-compatible m net start change behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_NetStart_Change`. |
| `registry` | `dynamic` | — | The registry input consumed by `M_NetStart_Change`. |
| `direction` | `dynamic` | — | The direction input consumed by `M_NetStart_Change`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2560)

<a id="function-function-miniquake-menu-m-options-draw-function-m-options-draw-state-texture-transform-realtime-registry-src-miniquake-menu-ml-1145808007"></a>
### M_Options_Draw

```ml
function M_Options_Draw(state, texture, transform, realtime, registry)
```

Apply the Quake-compatible m options draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Options_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Options_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `M_Options_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2044)

<a id="function-function-miniquake-menu-m-options-key-function-m-options-key-state-key-registry-src-miniquake-menu-ml-322316600"></a>
### M_Options_Key

```ml
function M_Options_Key(state, key, registry)
```

Apply the Quake-compatible m options key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Options_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `registry` | `dynamic` | — | The registry input consumed by `M_Options_Key`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2413)

<a id="function-function-miniquake-menu-m-print-function-m-print-texture-x-y-text-transform-src-miniquake-menu-ml-669318908"></a>
### M_Print

```ml
function M_Print(texture, x, y, text, transform)
```

Apply the Quake-compatible m print behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `M_Print`. |
| `y` | `dynamic` | — | The y input consumed by `M_Print`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Print`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1651)

<a id="function-function-miniquake-menu-m-printwhite-function-m-printwhite-texture-x-y-text-transform-src-miniquake-menu-ml-2002526526"></a>
### M_PrintWhite

```ml
function M_PrintWhite(texture, x, y, text, transform)
```

Apply the Quake-compatible m print white behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `M_PrintWhite`. |
| `y` | `dynamic` | — | The y input consumed by `M_PrintWhite`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `transform` | `dynamic` | — | The transform input consumed by `M_PrintWhite`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1661)

<a id="function-function-miniquake-menu-m-quit-draw-function-m-quit-draw-state-texture-transform-src-miniquake-menu-ml-722719725"></a>
### M_Quit_Draw

```ml
function M_Quit_Draw(state, texture, transform)
```

Apply the Quake-compatible m quit draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Quit_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Quit_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2083)

<a id="function-function-miniquake-menu-m-quit-key-function-m-quit-key-state-key-src-miniquake-menu-ml-1974403501"></a>
### M_Quit_Key

```ml
function M_Quit_Key(state, key)
```

Apply the Quake-compatible m quit key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Quit_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2487)

<a id="function-function-miniquake-menu-m-save-draw-function-m-save-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1509812466"></a>
### M_Save_Draw

```ml
function M_Save_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m save draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Save_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Save_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2002)

<a id="function-function-miniquake-menu-m-save-key-function-m-save-key-state-key-src-miniquake-menu-ml-826851313"></a>
### M_Save_Key

```ml
function M_Save_Key(state, key)
```

Apply the Quake-compatible m save key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Save_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2342)

<a id="function-function-miniquake-menu-m-scansaves-function-m-scansaves-state-labels-loadable-src-miniquake-menu-ml-1656961405"></a>
### M_ScanSaves

```ml
function M_ScanSaves(state, labels, loadable)
```

Apply the Quake-compatible m scan saves behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ScanSaves`. |
| `labels` | `dynamic` | — | The labels input consumed by `M_ScanSaves`. |
| `loadable` | `dynamic` | — | The loadable input consumed by `M_ScanSaves`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2168)

<a id="function-function-miniquake-menu-m-search-draw-function-m-search-draw-state-texture-transform-realtime-src-miniquake-menu-ml-969274772"></a>
### M_Search_Draw

```ml
function M_Search_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m search draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Search_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Search_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2134)

<a id="function-function-miniquake-menu-m-search-key-function-m-search-key-state-key-src-miniquake-menu-ml-238714097"></a>
### M_Search_Key

```ml
function M_Search_Key(state, key)
```

Apply the Quake-compatible m search key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Search_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2632)

<a id="function-function-miniquake-menu-m-serialconfig-draw-function-m-serialconfig-draw-state-texture-transform-src-miniquake-menu-ml-772244739"></a>
### M_SerialConfig_Draw

```ml
function M_SerialConfig_Draw(state, texture, transform)
```

Apply the Quake-compatible m serial config draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_SerialConfig_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_SerialConfig_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2092)

<a id="function-function-miniquake-menu-m-serialconfig-key-function-m-serialconfig-key-state-key-src-miniquake-menu-ml-258784365"></a>
### M_SerialConfig_Key

```ml
function M_SerialConfig_Key(state, key)
```

Apply the Quake-compatible m serial config key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_SerialConfig_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2496)

<a id="function-function-miniquake-menu-m-serverlist-draw-function-m-serverlist-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1445264482"></a>
### M_ServerList_Draw

```ml
function M_ServerList_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m server list draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ServerList_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_ServerList_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2159)

<a id="function-function-miniquake-menu-m-serverlist-key-function-m-serverlist-key-state-key-src-miniquake-menu-ml-1984467201"></a>
### M_ServerList_Key

```ml
function M_ServerList_Key(state, key)
```

Apply the Quake-compatible m server list key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ServerList_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2639)

<a id="function-function-miniquake-menu-m-setup-draw-function-m-setup-draw-state-texture-transform-realtime-registry-src-miniquake-menu-ml-729176439"></a>
### M_Setup_Draw

```ml
function M_Setup_Draw(state, texture, transform, realtime, registry)
```

Apply the Quake-compatible m setup draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Setup_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Setup_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `M_Setup_Draw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2023)

<a id="function-function-miniquake-menu-m-setup-key-function-m-setup-key-state-key-src-miniquake-menu-ml-334353879"></a>
### M_Setup_Key

```ml
function M_Setup_Key(state, key)
```

Apply the Quake-compatible m setup key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Setup_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2369)

<a id="function-function-miniquake-menu-m-setvideocallbacks-function-m-setvideocallbacks-state-drawcallback-keycallback-src-miniquake-menu-ml-1571543299"></a>
### M_SetVideoCallbacks

```ml
function M_SetVideoCallbacks(state, drawCallback, keyCallback)
```

Apply the Quake-compatible m set video callbacks behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_SetVideoCallbacks`. |
| `drawCallback` | `dynamic` | — | The draw callback input consumed by `M_SetVideoCallbacks`. |
| `keyCallback` | `dynamic` | — | The key callback input consumed by `M_SetVideoCallbacks`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2687)

<a id="function-function-miniquake-menu-m-singleplayer-draw-function-m-singleplayer-draw-state-texture-transform-realtime-src-miniquake-menu-ml-559393098"></a>
### M_SinglePlayer_Draw

```ml
function M_SinglePlayer_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m single player draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_SinglePlayer_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_SinglePlayer_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1982)

<a id="function-function-miniquake-menu-m-singleplayer-key-function-m-singleplayer-key-state-key-src-miniquake-menu-ml-819268017"></a>
### M_SinglePlayer_Key

```ml
function M_SinglePlayer_Key(state, key)
```

Apply the Quake-compatible m single player key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_SinglePlayer_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2320)

<a id="function-function-miniquake-menu-m-togglemenu-f-function-m-togglemenu-f-state-src-miniquake-menu-ml-417969022"></a>
### M_ToggleMenu_f

```ml
function M_ToggleMenu_f(state)
```

Apply the Quake-compatible m toggle menu f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_ToggleMenu_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1739)

<a id="function-function-miniquake-menu-m-unbindcommand-function-m-unbindcommand-command-src-miniquake-menu-ml-607459356"></a>
### M_UnbindCommand

```ml
function M_UnbindCommand(command)
```

Apply the Quake-compatible m unbind command behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2267)

<a id="function-function-miniquake-menu-m-video-draw-function-m-video-draw-state-texture-transform-realtime-src-miniquake-menu-ml-1881624818"></a>
### M_Video_Draw

```ml
function M_Video_Draw(state, texture, transform, realtime)
```

Apply the Quake-compatible m video draw behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Video_Draw`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `M_Video_Draw`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2064)

<a id="function-function-miniquake-menu-m-video-key-function-m-video-key-state-key-src-miniquake-menu-ml-1914344663"></a>
### M_Video_Key

```ml
function M_Video_Key(state, key)
```

Apply the Quake-compatible m video key behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `M_Video_Key`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2459)

<a id="function-function-miniquake-menu-mainitems-function-mainitems-src-miniquake-menu-ml-1092025551"></a>
### mainItems

```ml
function mainItems()
```

Implements the `mainItems` operation for `miniquake.menu` (main items).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L79)

<a id="function-function-miniquake-menu-menustringless-function-menustringless-left-right-src-miniquake-menu-ml-330176926"></a>
### menuStringLess

```ml
function menuStringLess(left, right)
```

Implements the `menuStringLess` operation for `miniquake.menu` (menu string less).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `menuStringLess`. |
| `right` | `dynamic` | — | The right input consumed by `menuStringLess`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1369)

<a id="constant-constant-miniquake-menu-mnet-ipx-const-mnet-ipx-1-src-miniquake-menu-ml-1846346571"></a>
### MNET_IPX

```ml
const MNET_IPX = 1
```

Defines the mnet ipx value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L67)

<a id="constant-constant-miniquake-menu-mnet-tcp-const-mnet-tcp-2-src-miniquake-menu-ml-1893283814"></a>
### MNET_TCP

```ml
const MNET_TCP = 2
```

Defines the mnet tcp value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L69)

<a id="function-function-miniquake-menu-move-function-move-state-delta-src-miniquake-menu-ml-1446915838"></a>
### move

```ml
function move(state, delta)
```

Transfer data for move.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `move`. |
| `delta` | `dynamic` | — | The delta input consumed by `move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L336)

<a id="function-function-miniquake-menu-movehelp-function-movehelp-state-delta-src-miniquake-menu-ml-292058446"></a>
### moveHelp

```ml
function moveHelp(state, delta)
```

Transfer data for move help.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `moveHelp`. |
| `delta` | `dynamic` | — | The delta input consumed by `moveHelp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L353)

<a id="function-function-miniquake-menu-multiplayeritems-function-multiplayeritems-src-miniquake-menu-ml-1914045745"></a>
### multiplayerItems

```ml
function multiplayerItems()
```

Implements the `multiplayerItems` operation for `miniquake.menu` (multiplayer items).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L89)

<a id="function-function-miniquake-menu-normalizelanport-function-normalizelanport-state-src-miniquake-menu-ml-1236110218"></a>
### normalizeLanPort

```ml
function normalizeLanPort(state)
```

Convert lan port into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `normalizeLanPort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2511)

<a id="function-function-miniquake-menu-openmain-function-openmain-state-src-miniquake-menu-ml-603707098"></a>
### openMain

```ml
function openMain(state)
```

Initialize state for open main.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `openMain`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L293)

<a id="function-function-miniquake-menu-openpage-function-openpage-state-page-src-miniquake-menu-ml-1325949295"></a>
### openPage

```ml
function openPage(state, page)
```

Initialize state for open page.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `openPage`. |
| `page` | `dynamic` | — | The page input consumed by `openPage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L265)

<a id="function-function-miniquake-menu-optionsitems-function-optionsitems-src-miniquake-menu-ml-87315053"></a>
### optionsItems

```ml
function optionsItems()
```

Implements the `optionsItems` operation for `miniquake.menu` (options items).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L94)

<a id="constant-constant-miniquake-menu-page-game-options-const-page-game-options-gameoptions-src-miniquake-menu-ml-679937342"></a>
### PAGE_GAME_OPTIONS

```ml
const PAGE_GAME_OPTIONS = "gameoptions"
```

Defines the page game options value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L55)

<a id="constant-constant-miniquake-menu-page-help-const-page-help-help-src-miniquake-menu-ml-1366613031"></a>
### PAGE_HELP

```ml
const PAGE_HELP = "help"
```

Defines the page help value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L47)

<a id="constant-constant-miniquake-menu-page-keys-const-page-keys-keys-src-miniquake-menu-ml-800517598"></a>
### PAGE_KEYS

```ml
const PAGE_KEYS = "keys"
```

Defines the page keys value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L37)

<a id="constant-constant-miniquake-menu-page-lan-const-page-lan-lanconfig-src-miniquake-menu-ml-2133185841"></a>
### PAGE_LAN

```ml
const PAGE_LAN = "lanconfig"
```

Defines the page lan value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L53)

<a id="constant-constant-miniquake-menu-page-load-const-page-load-load-src-miniquake-menu-ml-1898410374"></a>
### PAGE_LOAD

```ml
const PAGE_LOAD = "load"
```

Defines the page load value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L39)

<a id="constant-constant-miniquake-menu-page-main-const-page-main-main-src-miniquake-menu-ml-1782351845"></a>
### PAGE_MAIN

```ml
const PAGE_MAIN = "main"
```

Defines the page main value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L25)

<a id="constant-constant-miniquake-menu-page-modem-const-page-modem-modemconfig-src-miniquake-menu-ml-875318796"></a>
### PAGE_MODEM

```ml
const PAGE_MODEM = "modemconfig"
```

Defines the page modem value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L63)

<a id="constant-constant-miniquake-menu-page-multi-const-page-multi-multiplayer-src-miniquake-menu-ml-2106607210"></a>
### PAGE_MULTI

```ml
const PAGE_MULTI = "multiplayer"
```

Defines the page multi value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L29)

<a id="constant-constant-miniquake-menu-page-multiplayer-const-page-multiplayer-page-multi-src-miniquake-menu-ml-1646777517"></a>
### PAGE_MULTIPLAYER

```ml
const PAGE_MULTIPLAYER = PAGE_MULTI
```

Defines the page multiplayer value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L33)

<a id="constant-constant-miniquake-menu-page-net-const-page-net-net-src-miniquake-menu-ml-116020783"></a>
### PAGE_NET

```ml
const PAGE_NET = "net"
```

Defines the page net value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L51)

<a id="constant-constant-miniquake-menu-page-options-const-page-options-options-src-miniquake-menu-ml-249314958"></a>
### PAGE_OPTIONS

```ml
const PAGE_OPTIONS = "options"
```

Defines the page options value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L35)

<a id="constant-constant-miniquake-menu-page-quit-const-page-quit-quit-src-miniquake-menu-ml-1960560635"></a>
### PAGE_QUIT

```ml
const PAGE_QUIT = "quit"
```

Defines the page quit value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L49)

<a id="constant-constant-miniquake-menu-page-save-const-page-save-save-src-miniquake-menu-ml-492583697"></a>
### PAGE_SAVE

```ml
const PAGE_SAVE = "save"
```

Defines the page save value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L41)

<a id="constant-constant-miniquake-menu-page-search-const-page-search-search-src-miniquake-menu-ml-1417027790"></a>
### PAGE_SEARCH

```ml
const PAGE_SEARCH = "search"
```

Defines the page search value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L57)

<a id="constant-constant-miniquake-menu-page-serial-const-page-serial-serialconfig-src-miniquake-menu-ml-857522476"></a>
### PAGE_SERIAL

```ml
const PAGE_SERIAL = "serialconfig"
```

Defines the page serial value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L61)

<a id="constant-constant-miniquake-menu-page-server-list-const-page-server-list-serverlist-src-miniquake-menu-ml-1823424325"></a>
### PAGE_SERVER_LIST

```ml
const PAGE_SERVER_LIST = "serverlist"
```

Defines the page server list value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L59)

<a id="constant-constant-miniquake-menu-page-setup-const-page-setup-setup-src-miniquake-menu-ml-1389342577"></a>
### PAGE_SETUP

```ml
const PAGE_SETUP = "setup"
```

Defines the page setup value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L43)

<a id="constant-constant-miniquake-menu-page-single-const-page-single-singleplayer-src-miniquake-menu-ml-92555033"></a>
### PAGE_SINGLE

```ml
const PAGE_SINGLE = "singleplayer"
```

Defines the page single value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L27)

<a id="constant-constant-miniquake-menu-page-singleplayer-const-page-singleplayer-page-single-src-miniquake-menu-ml-1508700238"></a>
### PAGE_SINGLEPLAYER

```ml
const PAGE_SINGLEPLAYER = PAGE_SINGLE
```

Descriptive aliases retained for callers that use the long names.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L31)

<a id="constant-constant-miniquake-menu-page-video-const-page-video-video-src-miniquake-menu-ml-1049824231"></a>
### PAGE_VIDEO

```ml
const PAGE_VIDEO = "video"
```

Defines the page video value used by `miniquake.menu`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L45)

<a id="function-function-miniquake-menu-playertranslation-function-playertranslation-registry-src-miniquake-menu-ml-486774532"></a>
### playerTranslation

```ml
function playerTranslation(registry)
```

Implements the `playerTranslation` operation for `miniquake.menu` (player translation).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `playerTranslation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1046)

<a id="function-function-miniquake-menu-rememberselection-function-rememberselection-state-src-miniquake-menu-ml-734151396"></a>
### rememberSelection

```ml
function rememberSelection(state)
```

Implements the `rememberSelection` operation for `miniquake.menu` (remember selection).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `rememberSelection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L245)

<a id="function-function-miniquake-menu-render-function-render-state-texture-width-height-mapname-realtime-registry-src-miniquake-menu-ml-1653372799"></a>
### render

```ml
function render(state, texture, width, height, mapName, realtime, registry)
```

Implements the `render` operation for `miniquake.menu` (render).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `render`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `render`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1619)

<a id="function-function-miniquake-menu-rogueepisodes-function-rogueepisodes-src-miniquake-menu-ml-2008787677"></a>
### rogueEpisodes

```ml
function rogueEpisodes()
```

Implements the `rogueEpisodes` operation for `miniquake.menu` (rogue episodes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1163)

<a id="function-function-miniquake-menu-roguelevels-function-roguelevels-src-miniquake-menu-ml-1693254775"></a>
### rogueLevels

```ml
function rogueLevels()
```

Implements the `rogueLevels` operation for `miniquake.menu` (rogue levels).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1173)

<a id="function-function-miniquake-menu-saveslotitems-function-saveslotitems-src-miniquake-menu-ml-1215295887"></a>
### saveSlotItems

```ml
function saveSlotItems()
```

Encode and write slot items.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L135)

<a id="function-function-miniquake-menu-selectedcommand-function-selectedcommand-state-src-miniquake-menu-ml-425600710"></a>
### selectedCommand

```ml
function selectedCommand(state)
```

Implements the `selectedCommand` operation for `miniquake.menu` (selected command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `selectedCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L403)

<a id="function-function-miniquake-menu-selectedlevel-function-selectedlevel-state-src-miniquake-menu-ml-1973780160"></a>
### selectedLevel

```ml
function selectedLevel(state)
```

Implements the `selectedLevel` operation for `miniquake.menu` (selected level).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `selectedLevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1202)

<a id="function-function-miniquake-menu-setactive-function-setactive-state-active-src-miniquake-menu-ml-677431160"></a>
### setActive

```ml
function setActive(state, active)
```

Update module state for active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `setActive`. |
| `active` | `dynamic` | — | The active input consumed by `setActive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L319)

<a id="function-function-miniquake-menu-setitems-function-setitems-state-items-src-miniquake-menu-ml-698845132"></a>
### setItems

```ml
function setItems(state, items)
```

Update module state for items.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `setItems`. |
| `items` | `dynamic` | — | The items input consumed by `setItems`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L310)

<a id="function-function-miniquake-menu-setpage-function-setpage-state-page-src-miniquake-menu-ml-109656145"></a>
### setPage

```ml
function setPage(state, page)
```

Public spelling used by the host and tests.  Keeping page changes in one function ensures selection/status state is reset exactly once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `setPage`. |
| `page` | `dynamic` | — | The page input consumed by `setPage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L287)

<a id="function-function-miniquake-menu-setstatus-function-setstatus-state-text-src-miniquake-menu-ml-1364985427"></a>
### setStatus

```ml
function setStatus(state, text)
```

Update module state for status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `setStatus`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L302)

<a id="function-function-miniquake-menu-setupappend-function-setupappend-state-key-src-miniquake-menu-ml-375123691"></a>
### setupAppend

```ml
function setupAppend(state, key)
```

Update module state for up append.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `setupAppend`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2291)

<a id="function-function-miniquake-menu-setupbackspace-function-setupbackspace-state-src-miniquake-menu-ml-1802661098"></a>
### setupBackspace

```ml
function setupBackspace(state)
```

Update module state for up backspace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `setupBackspace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L2300)

<a id="function-function-miniquake-menu-shutdown-function-shutdown-state-src-miniquake-menu-ml-1810820766"></a>
### shutdown

```ml
function shutdown(state)
```

Implements the `shutdown` operation for `miniquake.menu` (shutdown).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L608)

<a id="function-function-miniquake-menu-singleplayeritems-function-singleplayeritems-src-miniquake-menu-ml-318625711"></a>
### singlePlayerItems

```ml
function singlePlayerItems()
```

Implements the `singlePlayerItems` operation for `miniquake.menu` (single player items).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L84)

<a id="function-function-miniquake-menu-sortservers-function-sortservers-state-src-miniquake-menu-ml-337943510"></a>
### sortServers

```ml
function sortServers(state)
```

Implements the `sortServers` operation for `miniquake.menu` (sort servers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `sortServers`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1347)

<a id="function-function-miniquake-menu-storedselection-function-storedselection-state-page-fallback-src-miniquake-menu-ml-627915703"></a>
### storedSelection

```ml
function storedSelection(state, page, fallback)
```

Implements the `storedSelection` operation for `miniquake.menu` (stored selection).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `storedSelection`. |
| `page` | `dynamic` | — | The page input consumed by `storedSelection`. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L236)

<a id="function-function-miniquake-menu-teamplaytext-function-teamplaytext-state-registry-src-miniquake-menu-ml-339261519"></a>
### teamplayText

```ml
function teamplayText(state, registry)
```

Implements the `teamplayText` operation for `miniquake.menu` (teamplay text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `teamplayText`. |
| `registry` | `dynamic` | — | The registry input consumed by `teamplayText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1275)

<a id="function-function-miniquake-menu-titleforpage-function-titleforpage-page-src-miniquake-menu-ml-108822616"></a>
### titleForPage

```ml
function titleForPage(page)
```

Implements the `titleForPage` operation for `miniquake.menu` (title for page).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `page` | `dynamic` | — | The page input consumed by `titleForPage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L165)

<a id="function-function-miniquake-menu-toggle-function-toggle-state-src-miniquake-menu-ml-555478790"></a>
### toggle

```ml
function toggle(state)
```

Update subsystem configuration for toggle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `toggle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L328)

<a id="function-function-miniquake-menu-tracedraw-function-tracedraw-state-name-src-miniquake-menu-ml-498363749"></a>
### traceDraw

```ml
function traceDraw(state, name)
```

----------------------------------------------------------------------------- Exact menu.c / menu.h entry points.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `traceDraw`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1628)

<a id="function-function-miniquake-menu-virtualcenteredpicture-function-virtualcenteredpicture-state-name-y-transform-alpha-src-miniquake-menu-ml-896394746"></a>
### virtualCenteredPicture

```ml
function virtualCenteredPicture(state, name, y, transform, alpha)
```

Implements the `virtualCenteredPicture` operation for `miniquake.menu` (virtual centered picture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `virtualCenteredPicture`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `y` | `dynamic` | — | The y input consumed by `virtualCenteredPicture`. |
| `transform` | `dynamic` | — | The transform input consumed by `virtualCenteredPicture`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `virtualCenteredPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L669)

<a id="function-function-miniquake-menu-virtualcenteredstring-function-virtualcenteredstring-texture-y-text-transform-alpha-src-miniquake-menu-ml-178055494"></a>
### virtualCenteredString

```ml
function virtualCenteredString(texture, y, text, transform, alpha)
```

Implements the `virtualCenteredString` operation for `miniquake.menu` (virtual centered string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `y` | `dynamic` | — | The y input consumed by `virtualCenteredString`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `transform` | `dynamic` | — | The transform input consumed by `virtualCenteredString`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `virtualCenteredString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L737)

<a id="function-function-miniquake-menu-virtualpicture-function-virtualpicture-state-name-x-y-transform-alpha-src-miniquake-menu-ml-130454222"></a>
### virtualPicture

```ml
function virtualPicture(state, name, x, y, transform, alpha)
```

Implements the `virtualPicture` operation for `miniquake.menu` (virtual picture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.menu` state used by `virtualPicture`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `x` | `dynamic` | — | The x input consumed by `virtualPicture`. |
| `y` | `dynamic` | — | The y input consumed by `virtualPicture`. |
| `transform` | `dynamic` | — | The transform input consumed by `virtualPicture`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `virtualPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L648)

<a id="function-function-miniquake-menu-virtualsolid-function-virtualsolid-x-y-width-height-transform-red-green-blue-alpha-src-miniquake-menu-ml-1401397053"></a>
### virtualSolid

```ml
function virtualSolid(x, y, width, height, transform, red, green, blue, alpha)
```

Implements the `virtualSolid` operation for `miniquake.menu` (virtual solid).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `virtualSolid`. |
| `y` | `dynamic` | — | The y input consumed by `virtualSolid`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `transform` | `dynamic` | — | The transform input consumed by `virtualSolid`. |
| `red` | `dynamic` | — | The red input consumed by `virtualSolid`. |
| `green` | `dynamic` | — | The green input consumed by `virtualSolid`. |
| `blue` | `dynamic` | — | The blue input consumed by `virtualSolid`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `virtualSolid`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L753)

<a id="function-function-miniquake-menu-virtualstring-function-virtualstring-texture-x-y-text-transform-alpha-src-miniquake-menu-ml-373549736"></a>
### virtualString

```ml
function virtualString(texture, x, y, text, transform, alpha)
```

Implements the `virtualString` operation for `miniquake.menu` (virtual string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `virtualString`. |
| `y` | `dynamic` | — | The y input consumed by `virtualString`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `transform` | `dynamic` | — | The transform input consumed by `virtualString`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `virtualString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L682)

<a id="function-function-miniquake-menu-virtualwhitestring-function-virtualwhitestring-texture-x-y-text-transform-alpha-src-miniquake-menu-ml-1894112532"></a>
### virtualWhiteString

```ml
function virtualWhiteString(texture, x, y, text, transform, alpha)
```

Implements the `virtualWhiteString` operation for `miniquake.menu` (virtual white string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `virtualWhiteString`. |
| `y` | `dynamic` | — | The y input consumed by `virtualWhiteString`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `transform` | `dynamic` | — | The transform input consumed by `virtualWhiteString`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `virtualWhiteString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L717)

<a id="function-function-miniquake-menu-widthtwo-function-widthtwo-number-src-miniquake-menu-ml-958293466"></a>
### widthTwo

```ml
function widthTwo(number)
```

Implements the `widthTwo` operation for `miniquake.menu` (width two).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `number` | `dynamic` | — | The number input consumed by `widthTwo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/menu.ml#L1401)
