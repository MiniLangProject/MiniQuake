# `src/miniquake/statusbar.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.statusbar`](Package-miniquake-statusbar-34608270.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/menu.ml` as `menu` → [src/miniquake/menu.ml](File-src-miniquake-menu-ml-537231111.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/draw2d.ml` as `draw` → [src/miniquake/render/draw2d.ml](File-src-miniquake-render-draw2d-ml-1547120567.md)
- `miniquake/render_ui_contract.ml` as `renderUiContract` → [src/miniquake/render_ui_contract.ml](File-src-miniquake-render-ui-contract-ml-1308372980.md)

## Declarations

<a id="function-function-miniquake-statusbar-ammoname-function-ammoname-items-src-miniquake-statusbar-ml-498562029"></a>
### ammoName

```ml
function ammoName(items)
```

Return ammo name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | The items input consumed by `ammoName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L269)

<a id="function-function-miniquake-statusbar-armorname-function-armorname-items-src-miniquake-statusbar-ml-1363000085"></a>
### armorName

```ml
function armorName(items)
```

Return armor name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | The items input consumed by `armorName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L260)

<a id="function-function-miniquake-statusbar-drawinventory-function-drawinventory-state-fonttexture-player-x-y-scale-src-miniquake-statusbar-ml-1668234348"></a>
### drawInventory

```ml
function drawInventory(state, fontTexture, player, x, y, scale)
```

Render inventory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `drawInventory`. |
| `fontTexture` | `dynamic` | — | The font texture input consumed by `drawInventory`. |
| `player` | `dynamic` | — | The player input consumed by `drawInventory`. |
| `x` | `dynamic` | — | The x input consumed by `drawInventory`. |
| `y` | `dynamic` | — | The y input consumed by `drawInventory`. |
| `scale` | `dynamic` | — | The scale input consumed by `drawInventory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L284)

<a id="function-function-miniquake-statusbar-drawmainbar-function-drawmainbar-state-player-x-y-scale-src-miniquake-statusbar-ml-328593622"></a>
### drawMainBar

```ml
function drawMainBar(state, player, x, y, scale)
```

Render main bar.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `drawMainBar`. |
| `player` | `dynamic` | — | The player input consumed by `drawMainBar`. |
| `x` | `dynamic` | — | The x input consumed by `drawMainBar`. |
| `y` | `dynamic` | — | The y input consumed by `drawMainBar`. |
| `scale` | `dynamic` | — | The scale input consumed by `drawMainBar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L341)

<a id="function-function-miniquake-statusbar-drawnumber-function-drawnumber-state-x-y-number-digits-alternate-scale-src-miniquake-statusbar-ml-477991500"></a>
### drawNumber

```ml
function drawNumber(state, x, y, number, digits, alternate, scale)
```

Render number.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `drawNumber`. |
| `x` | `dynamic` | — | The x input consumed by `drawNumber`. |
| `y` | `dynamic` | — | The y input consumed by `drawNumber`. |
| `number` | `dynamic` | — | The number input consumed by `drawNumber`. |
| `digits` | `dynamic` | — | The digits input consumed by `drawNumber`. |
| `alternate` | `dynamic` | — | The alternate input consumed by `drawNumber`. |
| `scale` | `dynamic` | — | The scale input consumed by `drawNumber`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L183)

<a id="function-function-miniquake-statusbar-drawpicture-function-drawpicture-state-name-x-y-scale-alpha-src-miniquake-statusbar-ml-685678674"></a>
### drawPicture

```ml
function drawPicture(state, name, x, y, scale, alpha)
```

Render picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `drawPicture`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `x` | `dynamic` | — | The x input consumed by `drawPicture`. |
| `y` | `dynamic` | — | The y input consumed by `drawPicture`. |
| `scale` | `dynamic` | — | The scale input consumed by `drawPicture`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `drawPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L154)

<a id="function-function-miniquake-statusbar-drawsmallammo-function-drawsmallammo-texture-x-y-number-scale-src-miniquake-statusbar-ml-1238127622"></a>
### drawSmallAmmo

```ml
function drawSmallAmmo(texture, x, y, number, scale)
```

Render small ammo.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `drawSmallAmmo`. |
| `y` | `dynamic` | — | The y input consumed by `drawSmallAmmo`. |
| `number` | `dynamic` | — | The number input consumed by `drawSmallAmmo`. |
| `scale` | `dynamic` | — | The scale input consumed by `drawSmallAmmo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L224)

<a id="function-function-miniquake-statusbar-facename-function-facename-player-src-miniquake-statusbar-ml-1121360452"></a>
### faceName

```ml
function faceName(player)
```

Return face name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `faceName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L254)

<a id="function-function-miniquake-statusbar-facenamefor-function-facenamefor-items-health-src-miniquake-statusbar-ml-683544689"></a>
### faceNameFor

```ml
function faceNameFor(items, health)
```

Implements the `faceNameFor` operation for `miniquake.statusbar` (face name for).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | The items input consumed by `faceNameFor`. |
| `health` | `dynamic` | — | The health input consumed by `faceNameFor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L240)

<a id="function-function-miniquake-statusbar-flashweaponname-function-flashweaponname-prefix-weapon-flash-src-miniquake-statusbar-ml-115831313"></a>
### flashWeaponName

```ml
function flashWeaponName(prefix, weapon, flash)
```

Return flash weapon name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — | The prefix input consumed by `flashWeaponName`. |
| `weapon` | `dynamic` | — | The weapon input consumed by `flashWeaponName`. |
| `flash` | `dynamic` | — | The flash input consumed by `flashWeaponName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L915)

<a id="function-function-miniquake-statusbar-fragglyphs-function-fragglyphs-value-src-miniquake-statusbar-ml-1249141664"></a>
### fragGlyphs

```ml
function fragGlyphs(value)
```

Implements the `fragGlyphs` operation for `miniquake.statusbar` (frag glyphs).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fragGlyphs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L834)

<a id="global-global-miniquake-statusbar-fragsort-fragsort-src-miniquake-statusbar-ml-92689865"></a>
### fragsort

```ml
fragsort
```

Tracks the module-level fragsort state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L72)

<a id="function-function-miniquake-statusbar-inventoryammocount-inline-function-inventoryammocount-index-src-miniquake-statusbar-ml-326109482"></a>
### inventoryAmmoCount

```ml
inline function inventoryAmmoCount(index)
```

Return one of the four stock ammunition counters without constructing a frame-local aggregate array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L944)

<a id="function-function-miniquake-statusbar-itemneedsrefresh-function-itemneedsrefresh-itemindex-currenttime-src-miniquake-statusbar-ml-1525425510"></a>
### itemNeedsRefresh

```ml
function itemNeedsRefresh(itemIndex, currentTime)
```

Implements the `itemNeedsRefresh` operation for `miniquake.statusbar` (item needs refresh).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L924)

<a id="function-function-miniquake-statusbar-loadedsbarpicture-function-loadedsbarpicture-name-src-miniquake-statusbar-ml-1802881200"></a>
### loadedSbarPicture

```ml
function loadedSbarPicture(name)
```

Loads ed sbar picture for `miniquake.statusbar`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L123)

<a id="function-function-miniquake-statusbar-loadsbarpicture-function-loadsbarpicture-name-src-miniquake-statusbar-ml-473986118"></a>
### loadSbarPicture

```ml
function loadSbarPicture(name)
```

Read and validate sbar picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L107)

<a id="function-function-miniquake-statusbar-numberpicture-function-numberpicture-color-frame-src-miniquake-statusbar-ml-42049887"></a>
### numberPicture

```ml
function numberPicture(color, frame)
```

Implements the `numberPicture` operation for `miniquake.statusbar` (number picture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `dynamic` | — | Color value used by the operation. |
| `frame` | `dynamic` | — | The frame input consumed by `numberPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L757)

<a id="function-function-miniquake-statusbar-padfrag-function-padfrag-value-src-miniquake-statusbar-ml-1907739946"></a>
### padFrag

```ml
function padFrag(value)
```

Implements the `padFrag` operation for `miniquake.statusbar` (pad frag).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `padFrag`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L822)

<a id="function-function-miniquake-statusbar-picture-function-picture-state-name-src-miniquake-statusbar-ml-1012758371"></a>
### picture

```ml
function picture(state, name)
```

Implements the `picture` operation for `miniquake.statusbar` (picture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `picture`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L142)

<a id="function-function-miniquake-statusbar-remembersbarpicture-function-remembersbarpicture-name-value-src-miniquake-statusbar-ml-643214139"></a>
### rememberSbarPicture

```ml
function rememberSbarPicture(name, value)
```

Implements the `rememberSbarPicture` operation for `miniquake.statusbar` (remember sbar picture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `rememberSbarPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L97)

<a id="function-function-miniquake-statusbar-render-function-render-state-fonttexture-player-width-height-viewsize-clientstate-teamplay-src-miniquake-statusbar-ml-875523033"></a>
### render

```ml
function render(state, fontTexture, player, width, height, viewSize, clientState, teamplay)
```

Sbar_Draw for the stock single-player layout. The original 320x24/48 qpics are taken from the user's gfx.wad; no Quake art is embedded in MiniQuake.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `render`. |
| `fontTexture` | `dynamic` | — | The font texture input consumed by `render`. |
| `player` | `dynamic` | — | The player input consumed by `render`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `viewSize` | `dynamic` | — | Size of the requested data or resource. |
| `clientState` | `dynamic` | — | Mutable state used by `render`. |
| `teamplay` | `dynamic` | — | The teamplay input consumed by `render`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L372)

<a id="function-function-miniquake-statusbar-rogueammoname-function-rogueammoname-items-src-miniquake-statusbar-ml-1109363295"></a>
### rogueAmmoName

```ml
function rogueAmmoName(items)
```

Return rogue ammo name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | The items input consumed by `rogueAmmoName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1118)

<a id="function-function-miniquake-statusbar-roguearmorname-function-roguearmorname-items-src-miniquake-statusbar-ml-516826205"></a>
### rogueArmorName

```ml
function rogueArmorName(items)
```

Return rogue armor name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | The items input consumed by `rogueArmorName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1109)

<a id="global-global-miniquake-statusbar-sb-lines-sb-lines-src-miniquake-statusbar-ml-278841187"></a>
### sb_lines

```ml
sb_lines
```

Tracks the module-level sb lines state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L28)

<a id="global-global-miniquake-statusbar-sb-showscores-sb-showscores-src-miniquake-statusbar-ml-717962965"></a>
### sb_showscores

```ml
sb_showscores
```

Tracks the module-level sb showscores state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L26)

<a id="global-global-miniquake-statusbar-sb-updates-sb-updates-src-miniquake-statusbar-ml-2141532537"></a>
### sb_updates

```ml
sb_updates
```

Tracks the module-level sb updates state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L24)

<a id="function-function-miniquake-statusbar-sbar-changed-function-sbar-changed-src-miniquake-statusbar-ml-1475044741"></a>
### Sbar_Changed

```ml
function Sbar_Changed()
```

Mirror Quake's Sbar_Changed routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L401)

<a id="function-function-miniquake-statusbar-sbar-colorformap-inline-function-sbar-colorformap-mapcolor-src-miniquake-statusbar-ml-1055584837"></a>
### Sbar_ColorForMap

```ml
inline function Sbar_ColorForMap(mapColor)
```

Mirror Quake's Sbar_ColorForMap routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapColor` | `dynamic` | — | The map color input consumed by `Sbar_ColorForMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L816)

<a id="function-function-miniquake-statusbar-sbar-commandtrace-function-sbar-commandtrace-src-miniquake-statusbar-ml-884970663"></a>
### Sbar_CommandTrace

```ml
function Sbar_CommandTrace()
```

Mirror Quake's Sbar_CommandTrace routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1451)

<a id="function-function-miniquake-statusbar-sbar-configure-function-sbar-configure-state-fonttexture-player-clientstate-width-height-lines-teamplay-src-miniquake-statusbar-ml-425294362"></a>
### Sbar_Configure

```ml
function Sbar_Configure(state, fontTexture, player, clientState, width, height, lines, teamplay)
```

Mirror Quake's Sbar_Configure routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.statusbar` state used by `Sbar_Configure`. |
| `fontTexture` | `dynamic` | — | The font texture input consumed by `Sbar_Configure`. |
| `player` | `dynamic` | — | The player input consumed by `Sbar_Configure`. |
| `clientState` | `dynamic` | — | Mutable state used by `Sbar_Configure`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `lines` | `dynamic` | — | The lines input consumed by `Sbar_Configure`. |
| `teamplay` | `dynamic` | — | The teamplay input consumed by `Sbar_Configure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L606)

<a id="function-function-miniquake-statusbar-sbar-deathmatchoverlay-function-sbar-deathmatchoverlay-src-miniquake-statusbar-ml-1468300653"></a>
### Sbar_DeathmatchOverlay

```ml
function Sbar_DeathmatchOverlay()
```

Mirror Quake's Sbar_DeathmatchOverlay routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1319)

<a id="function-function-miniquake-statusbar-sbar-differentialcleartrace-function-sbar-differentialcleartrace-src-miniquake-statusbar-ml-663059649"></a>
### Sbar_DifferentialClearTrace

```ml
function Sbar_DifferentialClearTrace()
```

Mirror Quake's Sbar_DifferentialClearTrace routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L590)

<a id="function-function-miniquake-statusbar-sbar-differentialreset-function-sbar-differentialreset-pictures-src-miniquake-statusbar-ml-234279774"></a>
### Sbar_DifferentialReset

```ml
function Sbar_DifferentialReset(pictures)
```

Deterministic state injection for the direct pinned-source differential. Production functions remain the code under test; only their globals/assets are arranged without requiring retail gfx.wad or an OpenGL context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pictures` | `dynamic` | — | The pictures input consumed by `Sbar_DifferentialReset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L524)

<a id="function-function-miniquake-statusbar-sbar-differentialsetstate-function-sbar-differentialsetstate-updates-showscores-hipnoticvalue-roguevalue-teamplayvalue-src-miniquake-statusbar-ml-1931602079"></a>
### Sbar_DifferentialSetState

```ml
function Sbar_DifferentialSetState(updates, showScores, hipnoticValue, rogueValue, teamplayValue)
```

Mirror Quake's Sbar_DifferentialSetState routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `updates` | `dynamic` | — | The updates input consumed by `Sbar_DifferentialSetState`. |
| `showScores` | `dynamic` | — | The show scores input consumed by `Sbar_DifferentialSetState`. |
| `hipnoticValue` | `dynamic` | — | The hipnotic value input consumed by `Sbar_DifferentialSetState`. |
| `rogueValue` | `dynamic` | — | The rogue value input consumed by `Sbar_DifferentialSetState`. |
| `teamplayValue` | `dynamic` | — | The teamplay value input consumed by `Sbar_DifferentialSetState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L579)

<a id="function-function-miniquake-statusbar-sbar-differentialstate-function-sbar-differentialstate-src-miniquake-statusbar-ml-1029055817"></a>
### Sbar_DifferentialState

```ml
function Sbar_DifferentialState()
```

Mirror Quake's Sbar_DifferentialState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L566)

<a id="function-function-miniquake-statusbar-sbar-dontshowscores-function-sbar-dontshowscores-src-miniquake-statusbar-ml-1971980417"></a>
### Sbar_DontShowScores

```ml
function Sbar_DontShowScores()
```

Mirror Quake's Sbar_DontShowScores routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L393)

<a id="function-function-miniquake-statusbar-sbar-draw-function-sbar-draw-src-miniquake-statusbar-ml-1161762635"></a>
### Sbar_Draw

```ml
function Sbar_Draw()
```

Mirror Quake's Sbar_Draw routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1130)

<a id="function-function-miniquake-statusbar-sbar-drawcharacter-function-sbar-drawcharacter-x-y-num-src-miniquake-statusbar-ml-1848521120"></a>
### Sbar_DrawCharacter

```ml
function Sbar_DrawCharacter(x, y, num)
```

Mirror Quake's Sbar_DrawCharacter routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_DrawCharacter`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_DrawCharacter`. |
| `num` | `dynamic` | — | The num input consumed by `Sbar_DrawCharacter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L726)

<a id="function-function-miniquake-statusbar-sbar-drawface-function-sbar-drawface-src-miniquake-statusbar-ml-444536689"></a>
### Sbar_DrawFace

```ml
function Sbar_DrawFace()
```

Mirror Quake's Sbar_DrawFace routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1073)

<a id="function-function-miniquake-statusbar-sbar-drawfrags-function-sbar-drawfrags-src-miniquake-statusbar-ml-1347050241"></a>
### Sbar_DrawFrags

```ml
function Sbar_DrawFrags()
```

Mirror Quake's Sbar_DrawFrags routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1046)

<a id="function-function-miniquake-statusbar-sbar-drawinventory-function-sbar-drawinventory-src-miniquake-statusbar-ml-764517637"></a>
### Sbar_DrawInventory

```ml
function Sbar_DrawInventory()
```

Mirror Quake's Sbar_DrawInventory routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L952)

<a id="function-function-miniquake-statusbar-sbar-drawnum-function-sbar-drawnum-x-y-num-digits-color-src-miniquake-statusbar-ml-171024919"></a>
### Sbar_DrawNum

```ml
function Sbar_DrawNum(x, y, num, digits, color)
```

Mirror Quake's Sbar_DrawNum routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_DrawNum`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_DrawNum`. |
| `num` | `dynamic` | — | The num input consumed by `Sbar_DrawNum`. |
| `digits` | `dynamic` | — | The digits input consumed by `Sbar_DrawNum`. |
| `color` | `dynamic` | — | Color value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L770)

<a id="function-function-miniquake-statusbar-sbar-drawpic-function-sbar-drawpic-x-y-pic-src-miniquake-statusbar-ml-1061629672"></a>
### Sbar_DrawPic

```ml
function Sbar_DrawPic(x, y, pic)
```

Mirror Quake's Sbar_DrawPic routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_DrawPic`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_DrawPic`. |
| `pic` | `dynamic` | — | The pic input consumed by `Sbar_DrawPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L700)

<a id="function-function-miniquake-statusbar-sbar-drawscoreboard-function-sbar-drawscoreboard-src-miniquake-statusbar-ml-116786131"></a>
### Sbar_DrawScoreboard

```ml
function Sbar_DrawScoreboard()
```

Mirror Quake's Sbar_DrawScoreboard routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L887)

<a id="function-function-miniquake-statusbar-sbar-drawstring-function-sbar-drawstring-x-y-text-src-miniquake-statusbar-ml-163317717"></a>
### Sbar_DrawString

```ml
function Sbar_DrawString(x, y, text)
```

Mirror Quake's Sbar_DrawString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_DrawString`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_DrawString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L738)

<a id="function-function-miniquake-statusbar-sbar-drawtranspic-function-sbar-drawtranspic-x-y-pic-src-miniquake-statusbar-ml-196624678"></a>
### Sbar_DrawTransPic

```ml
function Sbar_DrawTransPic(x, y, pic)
```

Mirror Quake's Sbar_DrawTransPic routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_DrawTransPic`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_DrawTransPic`. |
| `pic` | `dynamic` | — | The pic input consumed by `Sbar_DrawTransPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L713)

<a id="function-function-miniquake-statusbar-sbar-finaleoverlay-function-sbar-finaleoverlay-src-miniquake-statusbar-ml-659449281"></a>
### Sbar_FinaleOverlay

```ml
function Sbar_FinaleOverlay()
```

Mirror Quake's Sbar_FinaleOverlay routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1432)

<a id="constant-constant-miniquake-statusbar-sbar-height-const-sbar-height-24-src-miniquake-statusbar-ml-1712214730"></a>
### SBAR_HEIGHT

```ml
const SBAR_HEIGHT = 24
```

Defines the sbar height value used by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L19)

<a id="function-function-miniquake-statusbar-sbar-init-function-sbar-init-gamedirectory-src-miniquake-statusbar-ml-938029070"></a>
### Sbar_Init

```ml
function Sbar_Init(gameDirectory)
```

Mirror Quake's Sbar_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L409)

<a id="function-function-miniquake-statusbar-sbar-intermissionnumber-function-sbar-intermissionnumber-x-y-num-digits-color-src-miniquake-statusbar-ml-1991177835"></a>
### Sbar_IntermissionNumber

```ml
function Sbar_IntermissionNumber(x, y, num, digits, color)
```

Mirror Quake's Sbar_IntermissionNumber routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_IntermissionNumber`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_IntermissionNumber`. |
| `num` | `dynamic` | — | The num input consumed by `Sbar_IntermissionNumber`. |
| `digits` | `dynamic` | — | The digits input consumed by `Sbar_IntermissionNumber`. |
| `color` | `dynamic` | — | Color value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1195)

<a id="function-function-miniquake-statusbar-sbar-intermissionnumberscaled-function-sbar-intermissionnumberscaled-x-y-num-digits-color-transform-src-miniquake-statusbar-ml-1384250199"></a>
### Sbar_IntermissionNumberScaled

```ml
function Sbar_IntermissionNumberScaled(x, y, num, digits, color, transform)
```

Mirror Quake's Sbar_IntermissionNumberScaled routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Sbar_IntermissionNumberScaled`. |
| `y` | `dynamic` | — | The y input consumed by `Sbar_IntermissionNumberScaled`. |
| `num` | `dynamic` | — | The num input consumed by `Sbar_IntermissionNumberScaled`. |
| `digits` | `dynamic` | — | The digits input consumed by `Sbar_IntermissionNumberScaled`. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `Sbar_IntermissionNumberScaled`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1302)

<a id="function-function-miniquake-statusbar-sbar-intermissionoverlay-function-sbar-intermissionoverlay-src-miniquake-statusbar-ml-250476733"></a>
### Sbar_IntermissionOverlay

```ml
function Sbar_IntermissionOverlay()
```

Mirror Quake's Sbar_IntermissionOverlay routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1387)

<a id="function-function-miniquake-statusbar-sbar-itoa-function-sbar-itoa-num-src-miniquake-statusbar-ml-327903217"></a>
### Sbar_itoa

```ml
function Sbar_itoa(num)
```

The C routine fills a caller buffer and returns its length.  MiniLang returns [text, length].

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `num` | `dynamic` | — | The num input consumed by `Sbar_itoa`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L749)

<a id="function-function-miniquake-statusbar-sbar-layouttrace-function-sbar-layouttrace-gamedirectory-player-clientstate-width-height-lines-teamplay-src-miniquake-statusbar-ml-1382874300"></a>
### Sbar_LayoutTrace

```ml
function Sbar_LayoutTrace(gameDirectory, player, clientState, width, height, lines, teamplay)
```

Mirror Quake's Sbar_LayoutTrace routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `player` | `dynamic` | — | The player input consumed by `Sbar_LayoutTrace`. |
| `clientState` | `dynamic` | — | Mutable state used by `Sbar_LayoutTrace`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `lines` | `dynamic` | — | The lines input consumed by `Sbar_LayoutTrace`. |
| `teamplay` | `dynamic` | — | The teamplay input consumed by `Sbar_LayoutTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1463)

<a id="function-function-miniquake-statusbar-sbar-minideathmatchoverlay-function-sbar-minideathmatchoverlay-src-miniquake-statusbar-ml-2068576209"></a>
### Sbar_MiniDeathmatchOverlay

```ml
function Sbar_MiniDeathmatchOverlay()
```

Mirror Quake's Sbar_MiniDeathmatchOverlay routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1349)

<a id="function-function-miniquake-statusbar-sbar-setframestate-function-sbar-setframestate-consolecurrent-numpages-src-miniquake-statusbar-ml-1404455195"></a>
### Sbar_SetFrameState

```ml
function Sbar_SetFrameState(consoleCurrent, numPages)
```

Mirror Quake's Sbar_SetFrameState routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `consoleCurrent` | `dynamic` | — | The console current input consumed by `Sbar_SetFrameState`. |
| `numPages` | `dynamic` | — | The num pages input consumed by `Sbar_SetFrameState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L506)

<a id="function-function-miniquake-statusbar-sbar-showscores-function-sbar-showscores-src-miniquake-statusbar-ml-515790443"></a>
### Sbar_ShowScores

```ml
function Sbar_ShowScores()
```

============================================================================= sbar.c compatibility surface =============================================================================


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L384)

<a id="function-function-miniquake-statusbar-sbar-shutdown-function-sbar-shutdown-src-miniquake-statusbar-ml-671774395"></a>
### Sbar_Shutdown

```ml
function Sbar_Shutdown()
```

Mirror Quake's Sbar_Shutdown routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L490)

<a id="function-function-miniquake-statusbar-sbar-soloscoreboard-function-sbar-soloscoreboard-src-miniquake-statusbar-ml-1260399841"></a>
### Sbar_SoloScoreboard

```ml
function Sbar_SoloScoreboard()
```

Mirror Quake's Sbar_SoloScoreboard routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L869)

<a id="function-function-miniquake-statusbar-sbar-sortfrags-function-sbar-sortfrags-scores-src-miniquake-statusbar-ml-1633871374"></a>
### Sbar_SortFrags

```ml
function Sbar_SortFrags(scores)
```

Mirror Quake's Sbar_SortFrags routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scores` | `dynamic` | — | The scores input consumed by `Sbar_SortFrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L788)

<a id="function-function-miniquake-statusbar-sbar-updatescoreboard-function-sbar-updatescoreboard-src-miniquake-statusbar-ml-1183817221"></a>
### Sbar_UpdateScoreboard

```ml
function Sbar_UpdateScoreboard()
```

Mirror Quake's Sbar_UpdateScoreboard routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L839)

<a id="function-function-miniquake-statusbar-sbaractiveweapon-function-sbaractiveweapon-src-miniquake-statusbar-ml-1007730381"></a>
### sbarActiveWeapon

```ml
function sbarActiveWeapon()
```

Report whether sbar active weapon holds for the active state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L936)

<a id="global-global-miniquake-statusbar-sbarbaseitemnames-sbarbaseitemnames-src-miniquake-statusbar-ml-1025108813"></a>
### sbarBaseItemNames

```ml
sbarBaseItemNames
```

Tracks the module-level sbar base item names state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L92)

<a id="function-function-miniquake-statusbar-sbarcanvascharacter-function-sbarcanvascharacter-x-y-num-transform-src-miniquake-statusbar-ml-1752402740"></a>
### sbarCanvasCharacter

```ml
function sbarCanvasCharacter(x, y, num, transform)
```

Implements the `sbarCanvasCharacter` operation for `miniquake.statusbar` (sbar canvas character).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarCanvasCharacter`. |
| `y` | `dynamic` | — | The y input consumed by `sbarCanvasCharacter`. |
| `num` | `dynamic` | — | The num input consumed by `sbarCanvasCharacter`. |
| `transform` | `dynamic` | — | The transform input consumed by `sbarCanvasCharacter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1256)

<a id="function-function-miniquake-statusbar-sbarcanvasfill-function-sbarcanvasfill-x-y-width-height-color-transform-src-miniquake-statusbar-ml-1204484542"></a>
### sbarCanvasFill

```ml
function sbarCanvasFill(x, y, width, height, color, transform)
```

Implements the `sbarCanvasFill` operation for `miniquake.statusbar` (sbar canvas fill).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarCanvasFill`. |
| `y` | `dynamic` | — | The y input consumed by `sbarCanvasFill`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `transform` | `dynamic` | — | The transform input consumed by `sbarCanvasFill`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1284)

<a id="function-function-miniquake-statusbar-sbarcanvaspic-function-sbarcanvaspic-x-y-pic-transform-src-miniquake-statusbar-ml-1727662878"></a>
### sbarCanvasPic

```ml
function sbarCanvasPic(x, y, pic, transform)
```

Implements the `sbarCanvasPic` operation for `miniquake.statusbar` (sbar canvas pic).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarCanvasPic`. |
| `y` | `dynamic` | — | The y input consumed by `sbarCanvasPic`. |
| `pic` | `dynamic` | — | The pic input consumed by `sbarCanvasPic`. |
| `transform` | `dynamic` | — | The transform input consumed by `sbarCanvasPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1239)

<a id="function-function-miniquake-statusbar-sbarcanvasstring-function-sbarcanvasstring-x-y-text-transform-src-miniquake-statusbar-ml-1229719261"></a>
### sbarCanvasString

```ml
function sbarCanvasString(x, y, text, transform)
```

Implements the `sbarCanvasString` operation for `miniquake.statusbar` (sbar canvas string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarCanvasString`. |
| `y` | `dynamic` | — | The y input consumed by `sbarCanvasString`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `transform` | `dynamic` | — | The transform input consumed by `sbarCanvasString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1269)

<a id="global-global-miniquake-statusbar-sbarclient-sbarclient-src-miniquake-statusbar-ml-1282936391"></a>
### sbarClient

```ml
sbarClient
```

Tracks the module-level sbar client state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L46)

<a id="global-global-miniquake-statusbar-sbarconsolecurrent-sbarconsolecurrent-src-miniquake-statusbar-ml-176722041"></a>
### sbarConsoleCurrent

```ml
sbarConsoleCurrent
```

Tracks the module-level sbar console current state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L56)

<a id="global-global-miniquake-statusbar-sbarcopyeverything-sbarcopyeverything-src-miniquake-statusbar-ml-1360869545"></a>
### sbarCopyEverything

```ml
sbarCopyEverything
```

Tracks the module-level sbar copy everything state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L60)

<a id="function-function-miniquake-statusbar-sbardirectcharacter-function-sbardirectcharacter-x-y-num-src-miniquake-statusbar-ml-1946593572"></a>
### sbarDirectCharacter

```ml
function sbarDirectCharacter(x, y, num)
```

Implements the `sbarDirectCharacter` operation for `miniquake.statusbar` (sbar direct character).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarDirectCharacter`. |
| `y` | `dynamic` | — | The y input consumed by `sbarDirectCharacter`. |
| `num` | `dynamic` | — | The num input consumed by `sbarDirectCharacter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L661)

<a id="function-function-miniquake-statusbar-sbardirectfill-function-sbardirectfill-x-y-width-height-color-src-miniquake-statusbar-ml-655160176"></a>
### sbarDirectFill

```ml
function sbarDirectFill(x, y, width, height, color)
```

Implements the `sbarDirectFill` operation for `miniquake.statusbar` (sbar direct fill).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarDirectFill`. |
| `y` | `dynamic` | — | The y input consumed by `sbarDirectFill`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `color` | `dynamic` | — | Color value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L681)

<a id="function-function-miniquake-statusbar-sbardirectpic-function-sbardirectpic-x-y-pic-src-miniquake-statusbar-ml-518113606"></a>
### sbarDirectPic

```ml
function sbarDirectPic(x, y, pic)
```

Implements the `sbarDirectPic` operation for `miniquake.statusbar` (sbar direct pic).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarDirectPic`. |
| `y` | `dynamic` | — | The y input consumed by `sbarDirectPic`. |
| `pic` | `dynamic` | — | The pic input consumed by `sbarDirectPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L641)

<a id="function-function-miniquake-statusbar-sbardirectstring-function-sbardirectstring-x-y-text-src-miniquake-statusbar-ml-1821282077"></a>
### sbarDirectString

```ml
function sbarDirectString(x, y, text)
```

Implements the `sbarDirectString` operation for `miniquake.statusbar` (sbar direct string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarDirectString`. |
| `y` | `dynamic` | — | The y input consumed by `sbarDirectString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L670)

<a id="function-function-miniquake-statusbar-sbardirecttileclear-function-sbardirecttileclear-x-y-width-height-src-miniquake-statusbar-ml-486351291"></a>
### sbarDirectTileClear

```ml
function sbarDirectTileClear(x, y, width, height)
```

Implements the `sbarDirectTileClear` operation for `miniquake.statusbar` (sbar direct tile clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarDirectTileClear`. |
| `y` | `dynamic` | — | The y input consumed by `sbarDirectTileClear`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L691)

<a id="function-function-miniquake-statusbar-sbardirecttranspic-function-sbardirecttranspic-x-y-pic-src-miniquake-statusbar-ml-723008596"></a>
### sbarDirectTransPic

```ml
function sbarDirectTransPic(x, y, pic)
```

Implements the `sbarDirectTransPic` operation for `miniquake.statusbar` (sbar direct trans pic).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarDirectTransPic`. |
| `y` | `dynamic` | — | The y input consumed by `sbarDirectTransPic`. |
| `pic` | `dynamic` | — | The pic input consumed by `sbarDirectTransPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L651)

<a id="global-global-miniquake-statusbar-sbarfonttexture-sbarfonttexture-src-miniquake-statusbar-ml-1896460489"></a>
### sbarFontTexture

```ml
sbarFontTexture
```

Tracks the module-level sbar font texture state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L42)

<a id="global-global-miniquake-statusbar-sbarfullupdate-sbarfullupdate-src-miniquake-statusbar-ml-1662239941"></a>
### sbarFullUpdate

```ml
sbarFullUpdate
```

Tracks the module-level sbar full update state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L62)

<a id="global-global-miniquake-statusbar-sbargametype-sbargametype-src-miniquake-statusbar-ml-978043537"></a>
### sbarGameType

```ml
sbarGameType
```

Tracks the module-level sbar game type state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L52)

<a id="global-global-miniquake-statusbar-sbarheight-sbarheight-src-miniquake-statusbar-ml-1884822907"></a>
### sbarHeight

```ml
sbarHeight
```

Tracks the module-level sbar height state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L50)

<a id="global-global-miniquake-statusbar-sbarhipnotic-sbarhipnotic-src-miniquake-statusbar-ml-269006577"></a>
### sbarHipnotic

```ml
sbarHipnotic
```

Tracks the module-level sbar hipnotic state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L36)

<a id="global-global-miniquake-statusbar-sbarinitialized-sbarinitialized-src-miniquake-statusbar-ml-1117044533"></a>
### sbarInitialized

```ml
sbarInitialized
```

Tracks the module-level sbar initialized state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L34)

<a id="global-global-miniquake-statusbar-sbarinjectedpictures-sbarinjectedpictures-src-miniquake-statusbar-ml-1127854835"></a>
### sbarInjectedPictures

```ml
sbarInjectedPictures
```

Tracks the module-level sbar injected pictures state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L68)

<a id="function-function-miniquake-statusbar-sbaritems-function-sbaritems-src-miniquake-statusbar-ml-895578417"></a>
### sbarItems

```ml
function sbarItems()
```

Implements the `sbarItems` operation for `miniquake.statusbar` (sbar items).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L514)

<a id="global-global-miniquake-statusbar-sbarloadtrace-sbarloadtrace-src-miniquake-statusbar-ml-798333321"></a>
### sbarLoadTrace

```ml
sbarLoadTrace
```

Tracks the module-level sbar load trace state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L70)

<a id="global-global-miniquake-statusbar-sbarlogicallines-sbarlogicallines-src-miniquake-statusbar-ml-1870537441"></a>
### sbarLogicalLines

```ml
sbarLogicalLines
```

Tracks the module-level sbar logical lines state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L30)

<a id="global-global-miniquake-statusbar-sbarnumpages-sbarnumpages-src-miniquake-statusbar-ml-1613415917"></a>
### sbarNumPages

```ml
sbarNumPages
```

Tracks the module-level sbar num pages state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L58)

<a id="function-function-miniquake-statusbar-sbaroverlaypic-function-sbaroverlaypic-x-y-pic-transform-transparent-src-miniquake-statusbar-ml-1825500582"></a>
### sbarOverlayPic

```ml
function sbarOverlayPic(x, y, pic, transform, transparent)
```

Implements the `sbarOverlayPic` operation for `miniquake.statusbar` (sbar overlay pic).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `sbarOverlayPic`. |
| `y` | `dynamic` | — | The y input consumed by `sbarOverlayPic`. |
| `pic` | `dynamic` | — | The pic input consumed by `sbarOverlayPic`. |
| `transform` | `dynamic` | — | The transform input consumed by `sbarOverlayPic`. |
| `transparent` | `dynamic` | — | The transparent input consumed by `sbarOverlayPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L1217)

<a id="global-global-miniquake-statusbar-sbarpicturenames-sbarpicturenames-src-miniquake-statusbar-ml-1938728889"></a>
### sbarPictureNames

```ml
sbarPictureNames
```

Tracks the module-level sbar picture names state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L66)

<a id="global-global-miniquake-statusbar-sbarpictures-sbarpictures-src-miniquake-statusbar-ml-1851358455"></a>
### sbarPictures

```ml
sbarPictures
```

Tracks the module-level sbar pictures state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L64)

<a id="global-global-miniquake-statusbar-sbarplayer-sbarplayer-src-miniquake-statusbar-ml-1037866915"></a>
### sbarPlayer

```ml
sbarPlayer
```

Tracks the module-level sbar player state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L44)

<a id="global-global-miniquake-statusbar-sbarrogue-sbarrogue-src-miniquake-statusbar-ml-1639554081"></a>
### sbarRogue

```ml
sbarRogue
```

Tracks the module-level sbar rogue state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L38)

<a id="global-global-miniquake-statusbar-sbarrogueweaponnames-sbarrogueweaponnames-src-miniquake-statusbar-ml-2036271425"></a>
### sbarRogueWeaponNames

```ml
sbarRogueWeaponNames
```

Tracks the module-level sbar rogue weapon names state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L90)

<a id="global-global-miniquake-statusbar-sbarscale-sbarscale-src-miniquake-statusbar-ml-1605238005"></a>
### sbarScale

```ml
sbarScale
```

Tracks the module-level sbar scale state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L32)

<a id="global-global-miniquake-statusbar-sbarstate-sbarstate-src-miniquake-statusbar-ml-1412703565"></a>
### sbarState

```ml
sbarState
```

Tracks the module-level status-bar state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L40)

<a id="global-global-miniquake-statusbar-sbarteamplay-sbarteamplay-src-miniquake-statusbar-ml-2079902983"></a>
### sbarTeamplay

```ml
sbarTeamplay
```

Tracks the module-level sbar teamplay state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L54)

<a id="global-global-miniquake-statusbar-sbartrace-sbartrace-src-miniquake-statusbar-ml-637771357"></a>
### sbarTrace

```ml
sbarTrace
```

Tracks the module-level sbar trace state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L82)

<a id="global-global-miniquake-statusbar-sbartraceenabled-sbartraceenabled-src-miniquake-statusbar-ml-1291843393"></a>
### sbarTraceEnabled

```ml
sbarTraceEnabled
```

Tracks the module-level sbar trace enabled state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L84)

<a id="global-global-miniquake-statusbar-sbarweaponnames-sbarweaponnames-src-miniquake-statusbar-ml-1841800041"></a>
### sbarWeaponNames

```ml
sbarWeaponNames
```

Immutable name tables are shared by every HUD frame. Keeping them at module scope avoids rebuilding identical arrays while the inventory bar is drawn.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L88)

<a id="global-global-miniquake-statusbar-sbarwidth-sbarwidth-src-miniquake-statusbar-ml-1861296825"></a>
### sbarWidth

```ml
sbarWidth
```

Tracks the module-level sbar width state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L48)

<a id="function-function-miniquake-statusbar-sbarxoffset-function-sbarxoffset-src-miniquake-statusbar-ml-2025374979"></a>
### sbarXOffset

```ml
function sbarXOffset()
```

Implements the `sbarXOffset` operation for `miniquake.statusbar` (sbar x offset).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L624)

<a id="function-function-miniquake-statusbar-scalefor-function-scalefor-width-height-src-miniquake-statusbar-ml-742013598"></a>
### scaleFor

```ml
function scaleFor(width, height)
```

Implements the `scaleFor` operation for `miniquake.statusbar` (scale for).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L163)

<a id="global-global-miniquake-statusbar-scoreboardbottom-scoreboardbottom-src-miniquake-statusbar-ml-2073947575"></a>
### scoreboardbottom

```ml
scoreboardbottom
```

Tracks the module-level scoreboardbottom state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L78)

<a id="global-global-miniquake-statusbar-scoreboardlines-scoreboardlines-src-miniquake-statusbar-ml-1621166665"></a>
### scoreboardlines

```ml
scoreboardlines
```

Tracks the module-level scoreboardlines state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L80)

<a id="global-global-miniquake-statusbar-scoreboardtext-scoreboardtext-src-miniquake-statusbar-ml-635897867"></a>
### scoreboardtext

```ml
scoreboardtext
```

Tracks the module-level scoreboardtext state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L74)

<a id="global-global-miniquake-statusbar-scoreboardtop-scoreboardtop-src-miniquake-statusbar-ml-1279302537"></a>
### scoreboardtop

```ml
scoreboardtop
```

Tracks the module-level scoreboardtop state owned by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L76)

<a id="function-function-miniquake-statusbar-smallammodigit-function-smallammodigit-texture-x-y-digit-scale-src-miniquake-statusbar-ml-1571178184"></a>
### smallAmmoDigit

```ml
function smallAmmoDigit(texture, x, y, digit, scale)
```

Implements the `smallAmmoDigit` operation for `miniquake.statusbar` (small ammo digit).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `smallAmmoDigit`. |
| `y` | `dynamic` | — | The y input consumed by `smallAmmoDigit`. |
| `digit` | `dynamic` | — | The digit input consumed by `smallAmmoDigit`. |
| `scale` | `dynamic` | — | The scale input consumed by `smallAmmoDigit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L212)

<a id="function-function-miniquake-statusbar-stat-function-stat-index-fallback-src-miniquake-statusbar-ml-1518832723"></a>
### stat

```ml
function stat(index, fallback)
```

Implements the `stat` operation for `miniquake.statusbar` (stat).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L863)

<a id="constant-constant-miniquake-statusbar-stat-minus-const-stat-minus-10-src-miniquake-statusbar-ml-2004667407"></a>
### STAT_MINUS

```ml
const STAT_MINUS = 10
```

Defines the stat minus value used by `miniquake.statusbar`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L21)

<a id="function-function-miniquake-statusbar-tracesbar-function-tracesbar-command-src-miniquake-statusbar-ml-78770194"></a>
### traceSbar

```ml
function traceSbar(command)
```

Trace sbar through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L630)

<a id="function-function-miniquake-statusbar-weaponflash-function-weaponflash-itemindex-activeweapon-currenttime-src-miniquake-statusbar-ml-1055202452"></a>
### weaponFlash

```ml
function weaponFlash(itemIndex, activeWeapon, currentTime)
```

Implements the `weaponFlash` operation for `miniquake.statusbar` (weapon flash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `itemIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `activeWeapon` | `dynamic` | — | The active weapon input consumed by `weaponFlash`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/statusbar.ml#L897)
