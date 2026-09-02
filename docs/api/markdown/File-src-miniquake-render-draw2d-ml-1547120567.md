# `src/miniquake/render/draw2d.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.draw2d`](Package-miniquake-render-draw2d-1044366763.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/console.ml` as `console` → [src/miniquake/console.ml](File-src-miniquake-console-ml-296415787.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/texture_upscale.ml` as `textureUpscale` → [src/miniquake/render/texture_upscale.ml](File-src-miniquake-render-texture-upscale-ml-880792328.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/wad.ml` as `wad` → [src/miniquake/wad.ml](File-src-miniquake-wad-ml-1195240084.md)
- `std/string.ml` as `string` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/string.ml` — external dependency

## Declarations

<a id="function-function-miniquake-render-draw2d-alphabyte-function-alphabyte-alpha-src-miniquake-render-draw2d-ml-962283988"></a>
### alphaByte

```ml
function alphaByte(alpha)
```

Return alpha byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alpha` | `dynamic` | — | The alpha input consumed by `alphaByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1432)

<a id="function-function-miniquake-render-draw2d-begin2d-function-begin2d-width-height-src-miniquake-render-draw2d-ml-281565641"></a>
### begin2d

```ml
function begin2d(width, height)
```

Initialize state for begin2d.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L233)

<a id="function-function-miniquake-render-draw2d-buildtranslatedpicpixels-function-buildtranslatedpicpixels-picture-translation-src-miniquake-render-draw2d-ml-489797763"></a>
### BuildTranslatedPicPixels

```ml
function BuildTranslatedPicPixels(picture, translation)
```

Create and initialize translated pic pixels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `BuildTranslatedPicPixels`. |
| `translation` | `dynamic` | — | The translation input consumed by `BuildTranslatedPicPixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1595)

<a id="function-function-miniquake-render-draw2d-buildupload32levels-function-buildupload32levels-data-width-height-mipmap-src-miniquake-render-draw2d-ml-720722941"></a>
### BuildUpload32Levels

```ml
function BuildUpload32Levels(data, width, height, mipmap)
```

Create and initialize upload32 levels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mipmap` | `dynamic` | — | The mipmap input consumed by `BuildUpload32Levels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L746)

<a id="global-global-miniquake-render-draw2d-char-texture-char-texture-src-miniquake-render-draw2d-ml-2128049560"></a>
### char_texture

```ml
char_texture
```

Tracks the module-level char texture state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L60)

<a id="function-function-miniquake-render-draw2d-character-function-character-texture-x-y-code-scale-alpha-src-miniquake-render-draw2d-ml-345833573"></a>
### character

```ml
function character(texture, x, y, code, scale, alpha)
```

Implements the `character` operation for `miniquake.render.draw2d` (character).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `character`. |
| `y` | `dynamic` | — | The y input consumed by `character`. |
| `code` | `dynamic` | — | The code input consumed by `character`. |
| `scale` | `dynamic` | — | The scale input consumed by `character`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `character`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L309)

<a id="function-function-miniquake-render-draw2d-chartexture-function-chartexture-src-miniquake-render-draw2d-ml-1707519916"></a>
### CharTexture

```ml
function CharTexture()
```

Implements the `CharTexture` operation for `miniquake.render.draw2d` (char texture).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1374)

<a id="global-global-miniquake-render-draw2d-conback-conback-src-miniquake-render-draw2d-ml-1151449348"></a>
### conback

```ml
conback
```

Tracks the module-level conback state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L55)

<a id="function-function-miniquake-render-draw2d-configuredraw-function-configuredraw-filesystem-palette-cvars-src-miniquake-render-draw2d-ml-99830195"></a>
### configureDraw

```ml
function configureDraw(filesystem, palette, cvars)
```

============================================================================= gl_draw.c compatibility surface =============================================================================

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `configureDraw`. |
| `palette` | `dynamic` | — | The palette input consumed by `configureDraw`. |
| `cvars` | `dynamic` | — | The cvars input consumed by `configureDraw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L401)

<a id="global-global-miniquake-render-draw2d-currenttexture-currenttexture-src-miniquake-render-draw2d-ml-1167049756"></a>
### currenttexture

```ml
currenttexture
```

Tracks the module-level currenttexture state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L64)

<a id="global-global-miniquake-render-draw2d-currenttextureslots-currenttextureslots-src-miniquake-render-draw2d-ml-190622556"></a>
### currentTextureSlots

```ml
currentTextureSlots
```

Tracks the module-level current texture slots state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L134)

<a id="function-function-miniquake-render-draw2d-draw-alphapic-function-draw-alphapic-x-y-picture-alpha-src-miniquake-render-draw2d-ml-214615577"></a>
### Draw_AlphaPic

```ml
function Draw_AlphaPic(x, y, picture, alpha)
```

Render alpha pic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_AlphaPic`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_AlphaPic`. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_AlphaPic`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `Draw_AlphaPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1483)

<a id="function-function-miniquake-render-draw2d-draw-alphapicsized-function-draw-alphapicsized-x-y-picture-width-height-alpha-src-miniquake-render-draw2d-ml-1309163850"></a>
### Draw_AlphaPicSized

```ml
function Draw_AlphaPicSized(x, y, picture, width, height, alpha)
```

Render alpha pic sized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_AlphaPicSized`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_AlphaPicSized`. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_AlphaPicSized`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `alpha` | `dynamic` | — | The alpha input consumed by `Draw_AlphaPicSized`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1494)

<a id="function-function-miniquake-render-draw2d-draw-applyanisotropy-function-draw-applyanisotropy-src-miniquake-render-draw2d-ml-1527302054"></a>
### Draw_ApplyAnisotropy

```ml
function Draw_ApplyAnisotropy()
```

Apply the archived anisotropy level to every resident mipmapped texture. This makes the Video Mode selection effective immediately without a costly renderer or map restart.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1208)

<a id="global-global-miniquake-render-draw2d-draw-backtile-draw-backtile-src-miniquake-render-draw2d-ml-1973375916"></a>
### draw_backtile

```ml
draw_backtile
```

Tracks the module-level draw backtile state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L53)

<a id="function-function-miniquake-render-draw2d-draw-begindisc-function-draw-begindisc-src-miniquake-render-draw2d-ml-1839319058"></a>
### Draw_BeginDisc

```ml
function Draw_BeginDisc()
```

Render begin disc.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1903)

<a id="function-function-miniquake-render-draw2d-draw-cachepic-function-draw-cachepic-path-src-miniquake-render-draw2d-ml-583812955"></a>
### Draw_CachePic

```ml
function Draw_CachePic(path)
```

Render cache pic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1106)

<a id="function-function-miniquake-render-draw2d-draw-character-function-draw-character-x-y-num-src-miniquake-render-draw2d-ml-756579853"></a>
### Draw_Character

```ml
function Draw_Character(x, y, num)
```

Render character.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_Character`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_Character`. |
| `num` | `dynamic` | — | The num input consumed by `Draw_Character`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1392)

<a id="global-global-miniquake-render-draw2d-draw-chars-draw-chars-src-miniquake-render-draw2d-ml-1206309184"></a>
### draw_chars

```ml
draw_chars
```

Tracks the module-level draw chars state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L49)

<a id="function-function-miniquake-render-draw2d-draw-chartoconback-function-draw-chartoconback-num-destination-destinationoffset-src-miniquake-render-draw2d-ml-1732181655"></a>
### Draw_CharToConback

```ml
function Draw_CharToConback(num, destination, destinationOffset)
```

C's dest pointer is represented by an explicit destination byte offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `num` | `dynamic` | — | The num input consumed by `Draw_CharToConback`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `destinationOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1142)

<a id="function-function-miniquake-render-draw2d-draw-consolebackground-function-draw-consolebackground-lines-src-miniquake-render-draw2d-ml-1507037939"></a>
### Draw_ConsoleBackground

```ml
function Draw_ConsoleBackground(lines)
```

Render console background.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lines` | `dynamic` | — | The lines input consumed by `Draw_ConsoleBackground`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1664)

<a id="function-function-miniquake-render-draw2d-draw-debugchar-function-draw-debugchar-num-src-miniquake-render-draw2d-ml-746969564"></a>
### Draw_DebugChar

```ml
function Draw_DebugChar(num)
```

Render debug char.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `num` | `dynamic` | — | The num input consumed by `Draw_DebugChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1426)

<a id="function-function-miniquake-render-draw2d-draw-differentialreset-function-draw-differentialreset-palette-src-miniquake-render-draw2d-ml-2097247375"></a>
### Draw_DifferentialReset

```ml
function Draw_DifferentialReset(palette)
```

Deterministic state injection used only by the pinned-source differential. It keeps the actual production functions under test and avoids requiring an OpenGL context merely to arrange their original global inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `palette` | `dynamic` | — | The palette input consumed by `Draw_DifferentialReset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1703)

<a id="function-function-miniquake-render-draw2d-draw-differentialresetpicturecaches-function-draw-differentialresetpicturecaches-src-miniquake-render-draw2d-ml-753923478"></a>
### Draw_DifferentialResetPictureCaches

```ml
function Draw_DifferentialResetPictureCaches()
```

Render differential reset picture caches.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1785)

<a id="function-function-miniquake-render-draw2d-draw-differentialsetcaches-function-draw-differentialsetcaches-wadpictures-menupictures-consolepicture-src-miniquake-render-draw2d-ml-1896568954"></a>
### Draw_DifferentialSetCaches

```ml
function Draw_DifferentialSetCaches(wadPictures, menuPictures, consolePicture)
```

Render differential set caches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wadPictures` | `dynamic` | — | The wad pictures input consumed by `Draw_DifferentialSetCaches`. |
| `menuPictures` | `dynamic` | — | The menu pictures input consumed by `Draw_DifferentialSetCaches`. |
| `consolePicture` | `dynamic` | — | The console picture input consumed by `Draw_DifferentialSetCaches`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1812)

<a id="function-function-miniquake-render-draw2d-draw-differentialsetglobals-function-draw-differentialsetglobals-charactertexture-translatedtexture-nobind-characters-menupixels-src-miniquake-render-draw2d-ml-861168513"></a>
### Draw_DifferentialSetGlobals

```ml
function Draw_DifferentialSetGlobals(characterTexture, translatedTexture, noBind, characters, menuPixels)
```

Render differential set globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `characterTexture` | `dynamic` | — | The character texture input consumed by `Draw_DifferentialSetGlobals`. |
| `translatedTexture` | `dynamic` | — | The translated texture input consumed by `Draw_DifferentialSetGlobals`. |
| `noBind` | `dynamic` | — | The no bind input consumed by `Draw_DifferentialSetGlobals`. |
| `characters` | `dynamic` | — | The characters input consumed by `Draw_DifferentialSetGlobals`. |
| `menuPixels` | `dynamic` | — | The menu pixels input consumed by `Draw_DifferentialSetGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1763)

<a id="function-function-miniquake-render-draw2d-draw-differentialsetmultitexture-function-draw-differentialsetmultitexture-available-current-slot0-slot1-src-miniquake-render-draw2d-ml-2033273505"></a>
### Draw_DifferentialSetMultitexture

```ml
function Draw_DifferentialSetMultitexture(available, current, slot0, slot1)
```

Render differential set multitexture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `available` | `dynamic` | — | The available input consumed by `Draw_DifferentialSetMultitexture`. |
| `current` | `dynamic` | — | The current input consumed by `Draw_DifferentialSetMultitexture`. |
| `slot0` | `dynamic` | — | The slot0 input consumed by `Draw_DifferentialSetMultitexture`. |
| `slot1` | `dynamic` | — | The slot1 input consumed by `Draw_DifferentialSetMultitexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1848)

<a id="function-function-miniquake-render-draw2d-draw-differentialsetpictures-function-draw-differentialsetpictures-disc-backtile-consolepicture-src-miniquake-render-draw2d-ml-1945845425"></a>
### Draw_DifferentialSetPictures

```ml
function Draw_DifferentialSetPictures(disc, backtile, consolePicture)
```

Render differential set pictures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `disc` | `dynamic` | — | The disc input consumed by `Draw_DifferentialSetPictures`. |
| `backtile` | `dynamic` | — | The backtile input consumed by `Draw_DifferentialSetPictures`. |
| `consolePicture` | `dynamic` | — | The console picture input consumed by `Draw_DifferentialSetPictures`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1799)

<a id="function-function-miniquake-render-draw2d-draw-differentialsettexturestate-function-draw-differentialsettexturestate-nexttexture-current-names-ids-widths-heights-mipmaps-src-miniquake-render-draw2d-ml-1508733261"></a>
### Draw_DifferentialSetTextureState

```ml
function Draw_DifferentialSetTextureState(nextTexture, current, names, ids, widths, heights, mipmaps)
```

Render differential set texture state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nextTexture` | `dynamic` | — | The next texture input consumed by `Draw_DifferentialSetTextureState`. |
| `current` | `dynamic` | — | The current input consumed by `Draw_DifferentialSetTextureState`. |
| `names` | `dynamic` | — | The names input consumed by `Draw_DifferentialSetTextureState`. |
| `ids` | `dynamic` | — | The ids input consumed by `Draw_DifferentialSetTextureState`. |
| `widths` | `dynamic` | — | The widths input consumed by `Draw_DifferentialSetTextureState`. |
| `heights` | `dynamic` | — | The heights input consumed by `Draw_DifferentialSetTextureState`. |
| `mipmaps` | `dynamic` | — | The mipmaps input consumed by `Draw_DifferentialSetTextureState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1828)

<a id="function-function-miniquake-render-draw2d-draw-differentialstate-function-draw-differentialstate-src-miniquake-render-draw2d-ml-1806306178"></a>
### Draw_DifferentialState

```ml
function Draw_DifferentialState()
```

Render differential state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1858)

<a id="function-function-miniquake-render-draw2d-draw-differentialuseassets-function-draw-differentialuseassets-filesystem-wadarchive-src-miniquake-render-draw2d-ml-2029206067"></a>
### Draw_DifferentialUseAssets

```ml
function Draw_DifferentialUseAssets(filesystem, wadArchive)
```

Render differential use assets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `Draw_DifferentialUseAssets`. |
| `wadArchive` | `dynamic` | — | The wad archive input consumed by `Draw_DifferentialUseAssets`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1777)

<a id="global-global-miniquake-render-draw2d-draw-disc-draw-disc-src-miniquake-render-draw2d-ml-111531876"></a>
### draw_disc

```ml
draw_disc
```

Tracks the module-level draw disc state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L51)

<a id="function-function-miniquake-render-draw2d-draw-enddisc-function-draw-enddisc-src-miniquake-render-draw2d-ml-1311866542"></a>
### Draw_EndDisc

```ml
function Draw_EndDisc()
```

Render end disc.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1912)

<a id="function-function-miniquake-render-draw2d-draw-fadescreen-function-draw-fadescreen-src-miniquake-render-draw2d-ml-1537908940"></a>
### Draw_FadeScreen

```ml
function Draw_FadeScreen()
```

Render fade screen.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1884)

<a id="function-function-miniquake-render-draw2d-draw-fill-function-draw-fill-x-y-width-height-colorindex-src-miniquake-render-draw2d-ml-1180114639"></a>
### Draw_Fill

```ml
function Draw_Fill(x, y, width, height, colorIndex)
```

Render fill.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_Fill`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_Fill`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `colorIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1875)

<a id="function-function-miniquake-render-draw2d-draw-init-function-draw-init-filesystem-palette-width-height-cvars-src-miniquake-render-draw2d-ml-1490458574"></a>
### Draw_Init

```ml
function Draw_Init(filesystem, palette, width, height, cvars)
```

Render init.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `Draw_Init`. |
| `palette` | `dynamic` | — | The palette input consumed by `Draw_Init`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `cvars` | `dynamic` | — | The cvars input consumed by `Draw_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1231)

<a id="function-function-miniquake-render-draw2d-draw-pic-function-draw-pic-x-y-picture-src-miniquake-render-draw2d-ml-517094175"></a>
### Draw_Pic

```ml
function Draw_Pic(x, y, picture)
```

Render pic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_Pic`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_Pic`. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_Pic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1520)

<a id="function-function-miniquake-render-draw2d-draw-picfromwad-function-draw-picfromwad-name-src-miniquake-render-draw2d-ml-583977319"></a>
### Draw_PicFromWad

```ml
function Draw_PicFromWad(name)
```

Render pic from wad.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1051)

<a id="function-function-miniquake-render-draw2d-draw-picscaled-function-draw-picscaled-picture-x-y-scale-alpha-src-miniquake-render-draw2d-ml-978801699"></a>
### Draw_PicScaled

```ml
function Draw_PicScaled(picture, x, y, scale, alpha)
```

Render pic scaled.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_PicScaled`. |
| `x` | `dynamic` | — | The x input consumed by `Draw_PicScaled`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_PicScaled`. |
| `scale` | `dynamic` | — | The scale input consumed by `Draw_PicScaled`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `Draw_PicScaled`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1534)

<a id="function-function-miniquake-render-draw2d-draw-picsized-function-draw-picsized-picture-x-y-width-height-alpha-src-miniquake-render-draw2d-ml-337902992"></a>
### Draw_PicSized

```ml
function Draw_PicSized(picture, x, y, width, height, alpha)
```

Render pic sized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_PicSized`. |
| `x` | `dynamic` | — | The x input consumed by `Draw_PicSized`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_PicSized`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `alpha` | `dynamic` | — | The alpha input consumed by `Draw_PicSized`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1549)

<a id="function-function-miniquake-render-draw2d-draw-picsizednearest-function-draw-picsizednearest-picture-x-y-width-height-alpha-src-miniquake-render-draw2d-ml-514036976"></a>
### Draw_PicSizedNearest

```ml
function Draw_PicSizedNearest(picture, x, y, width, height, alpha)
```

Render pic sized nearest.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_PicSizedNearest`. |
| `x` | `dynamic` | — | The x input consumed by `Draw_PicSizedNearest`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_PicSizedNearest`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `alpha` | `dynamic` | — | The alpha input consumed by `Draw_PicSizedNearest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1564)

<a id="function-function-miniquake-render-draw2d-draw-pictrace-function-draw-pictrace-x-y-picture-width-height-alpha-src-miniquake-render-draw2d-ml-1041230146"></a>
### Draw_PicTrace

```ml
function Draw_PicTrace(x, y, picture, width, height, alpha)
```

Render pic trace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_PicTrace`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_PicTrace`. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_PicTrace`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `alpha` | `dynamic` | — | The alpha input consumed by `Draw_PicTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1466)

<a id="function-function-miniquake-render-draw2d-draw-setpalette-function-draw-setpalette-palette-src-miniquake-render-draw2d-ml-269609439"></a>
### Draw_SetPalette

```ml
function Draw_SetPalette(palette)
```

gl_draw.c owns the process-wide indexed-texture upload palette. Model and world loading use the same GL_LoadTexture path after VID_SetPalette.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `palette` | `dynamic` | — | The palette input consumed by `Draw_SetPalette`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L412)

<a id="function-function-miniquake-render-draw2d-draw-shutdown-function-draw-shutdown-src-miniquake-render-draw2d-ml-1757794188"></a>
### Draw_Shutdown

```ml
function Draw_Shutdown()
```

Render shutdown.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1308)

<a id="function-function-miniquake-render-draw2d-draw-string-function-draw-string-x-y-text-src-miniquake-render-draw2d-ml-2061041446"></a>
### Draw_String

```ml
function Draw_String(x, y, text)
```

Render string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_String`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_String`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1413)

<a id="function-function-miniquake-render-draw2d-draw-texturemode-f-function-draw-texturemode-f-arguments-src-miniquake-render-draw2d-ml-2091426564"></a>
### Draw_TextureMode_f

```ml
function Draw_TextureMode_f(arguments)
```

Render texture mode f.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1176)

<a id="function-function-miniquake-render-draw2d-draw-tileclear-function-draw-tileclear-x-y-width-height-src-miniquake-render-draw2d-ml-405295198"></a>
### Draw_TileClear

```ml
function Draw_TileClear(x, y, width, height)
```

Render tile clear.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_TileClear`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_TileClear`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1677)

<a id="function-function-miniquake-render-draw2d-draw-tracesetbacktile-function-draw-tracesetbacktile-picture-src-miniquake-render-draw2d-ml-258448352"></a>
### Draw_TraceSetBacktile

```ml
function Draw_TraceSetBacktile(picture)
```

Render trace set backtile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_TraceSetBacktile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1692)

<a id="function-function-miniquake-render-draw2d-draw-transpic-function-draw-transpic-x-y-picture-src-miniquake-render-draw2d-ml-1156787925"></a>
### Draw_TransPic

```ml
function Draw_TransPic(x, y, picture)
```

Render trans pic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_TransPic`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_TransPic`. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_TransPic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1585)

<a id="function-function-miniquake-render-draw2d-draw-transpictranslate-function-draw-transpictranslate-x-y-picture-translation-src-miniquake-render-draw2d-ml-47144280"></a>
### Draw_TransPicTranslate

```ml
function Draw_TransPicTranslate(x, y, picture, translation)
```

Render trans pic translate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_TransPicTranslate`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_TransPicTranslate`. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_TransPicTranslate`. |
| `translation` | `dynamic` | — | The translation input consumed by `Draw_TransPicTranslate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1658)

<a id="function-function-miniquake-render-draw2d-draw-transpictranslatesized-function-draw-transpictranslatesized-x-y-width-height-picture-translation-src-miniquake-render-draw2d-ml-51633559"></a>
### Draw_TransPicTranslateSized

```ml
function Draw_TransPicTranslateSized(x, y, width, height, picture, translation)
```

Render trans pic translate sized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `Draw_TransPicTranslateSized`. |
| `y` | `dynamic` | — | The y input consumed by `Draw_TransPicTranslateSized`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `picture` | `dynamic` | — | The picture input consumed by `Draw_TransPicTranslateSized`. |
| `translation` | `dynamic` | — | The translation input consumed by `Draw_TransPicTranslateSized`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1636)

<a id="function-function-miniquake-render-draw2d-drawconsole-function-drawconsole-state-width-height-scale-src-miniquake-render-draw2d-ml-1283814648"></a>
### drawConsole

```ml
function drawConsole(state, width, height, scale)
```

Render console.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.render.draw2d` state used by `drawConsole`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `scale` | `dynamic` | — | The scale input consumed by `drawConsole`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L351)

<a id="global-global-miniquake-render-draw2d-drawcvars-drawcvars-src-miniquake-render-draw2d-ml-199295660"></a>
### drawCvars

```ml
drawCvars
```

Tracks the module-level draw cvars state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L41)

<a id="global-global-miniquake-render-draw2d-drawfilesystem-drawfilesystem-src-miniquake-render-draw2d-ml-1079659434"></a>
### drawFilesystem

```ml
drawFilesystem
```

Tracks the module-level draw filesystem state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L35)

<a id="global-global-miniquake-render-draw2d-drawpalette-drawpalette-src-miniquake-render-draw2d-ml-1748404060"></a>
### drawPalette

```ml
drawPalette
```

Tracks the module-level draw palette state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L37)

<a id="global-global-miniquake-render-draw2d-drawpicturecoordinates-drawpicturecoordinates-src-miniquake-render-draw2d-ml-1761258962"></a>
### drawPictureCoordinates

```ml
drawPictureCoordinates
```

Tracks the module-level draw picture coordinates state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L112)

<a id="global-global-miniquake-render-draw2d-drawpictureobjects-drawpictureobjects-src-miniquake-render-draw2d-ml-2092371460"></a>
### drawPictureObjects

```ml
drawPictureObjects
```

Tracks the module-level draw picture objects state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L110)

<a id="global-global-miniquake-render-draw2d-drawpicturepixels-drawpicturepixels-src-miniquake-render-draw2d-ml-365890188"></a>
### drawPicturePixels

```ml
drawPicturePixels
```

Tracks the module-level draw picture pixels state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L114)

<a id="function-function-miniquake-render-draw2d-drawpicturequad-function-drawpicturequad-picture-x-y-width-height-alpha-src-miniquake-render-draw2d-ml-631520686"></a>
### drawPictureQuad

```ml
function drawPictureQuad(picture, x, y, width, height, alpha)
```

Render picture quad.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `drawPictureQuad`. |
| `x` | `dynamic` | — | The x input consumed by `drawPictureQuad`. |
| `y` | `dynamic` | — | The y input consumed by `drawPictureQuad`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `alpha` | `dynamic` | — | The alpha input consumed by `drawPictureQuad`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1446)

<a id="global-global-miniquake-render-draw2d-drawsbarchanges-drawsbarchanges-src-miniquake-render-draw2d-ml-492173684"></a>
### drawSbarChanges

```ml
drawSbarChanges
```

Tracks the module-level draw sbar changes state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L103)

<a id="function-function-miniquake-render-draw2d-drawstatus-function-drawstatus-texture-width-height-text-src-miniquake-render-draw2d-ml-1777867075"></a>
### drawStatus

```ml
function drawStatus(texture, width, height, text)
```

Render status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L385)

<a id="global-global-miniquake-render-draw2d-drawvideoheight-drawvideoheight-src-miniquake-render-draw2d-ml-1528758076"></a>
### drawVideoHeight

```ml
drawVideoHeight
```

Tracks the module-level draw video height state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L45)

<a id="global-global-miniquake-render-draw2d-drawvideowidth-drawvideowidth-src-miniquake-render-draw2d-ml-1483776930"></a>
### drawVideoWidth

```ml
drawVideoWidth
```

Tracks the module-level draw video width state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L43)

<a id="global-global-miniquake-render-draw2d-drawviewport-drawviewport-src-miniquake-render-draw2d-ml-876148768"></a>
### drawViewport

```ml
drawViewport
```

Tracks the module-level draw viewport state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L47)

<a id="global-global-miniquake-render-draw2d-drawwad-drawwad-src-miniquake-render-draw2d-ml-1429158876"></a>
### drawWad

```ml
drawWad
```

Tracks the module-level draw wad state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L39)

<a id="function-function-miniquake-render-draw2d-effectivetexturemaximum-function-effectivetexturemaximum-src-miniquake-render-draw2d-ml-880666754"></a>
### effectiveTextureMaximum

```ml
function effectiveTextureMaximum()
```

Return the effective upload limit. Opt-in high-resolution scaling raises the historical 1024 default to 2048 while still respecting a larger explicit gl_max_size selected by a mod or advanced configuration.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L718)

<a id="function-function-miniquake-render-draw2d-end2d-function-end2d-src-miniquake-render-draw2d-ml-1974780332"></a>
### end2d

```ml
function end2d()
```

Finalize state for end2d.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L249)

<a id="function-function-miniquake-render-draw2d-ensurescrapstate-function-ensurescrapstate-src-miniquake-render-draw2d-ml-2004760446"></a>
### ensureScrapState

```ml
function ensureScrapState()
```

Ensure sufficient storage or state for scrap state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L963)

<a id="function-function-miniquake-render-draw2d-filtermodes-function-filtermodes-src-miniquake-render-draw2d-ml-1385939214"></a>
### filterModes

```ml
function filterModes()
```

Implements the `filterModes` operation for `miniquake.render.draw2d` (filter modes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1163)

<a id="global-global-miniquake-render-draw2d-gl-alpha-format-gl-alpha-format-src-miniquake-render-draw2d-ml-1139219788"></a>
### gl_alpha_format

```ml
gl_alpha_format
```

Tracks the module-level gl alpha format state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L84)

<a id="global-global-miniquake-render-draw2d-gl-anisotropy-gl-anisotropy-src-miniquake-render-draw2d-ml-303877848"></a>
### gl_anisotropy

```ml
gl_anisotropy
```

Tracks the module-level gl anisotropy state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L74)

<a id="function-function-miniquake-render-draw2d-gl-bind-function-gl-bind-texnum-src-miniquake-render-draw2d-ml-988016975"></a>
### GL_Bind

```ml
function GL_Bind(texnum)
```

Mirror Quake's GL_Bind routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texnum` | `dynamic` | — | The texnum input consumed by `GL_Bind`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L516)

<a id="global-global-miniquake-render-draw2d-gl-filter-max-gl-filter-max-src-miniquake-render-draw2d-ml-1582553976"></a>
### gl_filter_max

```ml
gl_filter_max
```

Tracks the module-level gl filter max state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L78)

<a id="global-global-miniquake-render-draw2d-gl-filter-min-gl-filter-min-src-miniquake-render-draw2d-ml-398378308"></a>
### gl_filter_min

```ml
gl_filter_min
```

Tracks the module-level gl filter min state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L76)

<a id="function-function-miniquake-render-draw2d-gl-findtexture-function-gl-findtexture-identifier-src-miniquake-render-draw2d-ml-1459579805"></a>
### GL_FindTexture

```ml
function GL_FindTexture(identifier)
```

Mirror Quake's GL_FindTexture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `identifier` | `dynamic` | — | The identifier input consumed by `GL_FindTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L532)

<a id="global-global-miniquake-render-draw2d-gl-lightmap-format-gl-lightmap-format-src-miniquake-render-draw2d-ml-912692388"></a>
### gl_lightmap_format

```ml
gl_lightmap_format
```

Tracks the module-level gl lightmap format state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L80)

<a id="function-function-miniquake-render-draw2d-gl-loadpictexture-function-gl-loadpictexture-pic-src-miniquake-render-draw2d-ml-2096995610"></a>
### GL_LoadPicTexture

```ml
function GL_LoadPicTexture(pic)
```

Mirror Quake's GL_LoadPicTexture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pic` | `dynamic` | — | The pic input consumed by `GL_LoadPicTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L923)

<a id="function-function-miniquake-render-draw2d-gl-loadtexture-function-gl-loadtexture-identifier-width-height-data-mipmap-alpha-src-miniquake-render-draw2d-ml-7211556"></a>
### GL_LoadTexture

```ml
function GL_LoadTexture(identifier, width, height, data, mipmap, alpha)
```

Mirror Quake's GL_LoadTexture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `identifier` | `dynamic` | — | The identifier input consumed by `GL_LoadTexture`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `mipmap` | `dynamic` | — | The mipmap input consumed by `GL_LoadTexture`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `GL_LoadTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L890)

<a id="global-global-miniquake-render-draw2d-gl-max-size-gl-max-size-src-miniquake-render-draw2d-ml-1755694516"></a>
### gl_max_size

```ml
gl_max_size
```

Tracks the module-level gl max size state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L68)

<a id="function-function-miniquake-render-draw2d-gl-mipmap-function-gl-mipmap-input-width-height-src-miniquake-render-draw2d-ml-1765881"></a>
### GL_MipMap

```ml
function GL_MipMap(input, width, height)
```

Mirror Quake's GL_MipMap routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `GL_MipMap`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L603)

<a id="function-function-miniquake-render-draw2d-gl-mipmap8bit-function-gl-mipmap8bit-input-width-height-src-miniquake-render-draw2d-ml-550874803"></a>
### GL_MipMap8Bit

```ml
function GL_MipMap8Bit(input, width, height)
```

Mirror Quake's GL_MipMap8Bit routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `GL_MipMap8Bit`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L663)

<a id="global-global-miniquake-render-draw2d-gl-nobind-gl-nobind-src-miniquake-render-draw2d-ml-1530809796"></a>
### gl_nobind

```ml
gl_nobind
```

Tracks the module-level gl nobind state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L66)

<a id="global-global-miniquake-render-draw2d-gl-picmip-gl-picmip-src-miniquake-render-draw2d-ml-1067580188"></a>
### gl_picmip

```ml
gl_picmip
```

Tracks the module-level gl picmip state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L70)

<a id="function-function-miniquake-render-draw2d-gl-resample8bittexture-function-gl-resample8bittexture-input-inputwidth-inputheight-outputwidth-outputheight-src-miniquake-render-draw2d-ml-1479621328"></a>
### GL_Resample8BitTexture

```ml
function GL_Resample8BitTexture(input, inputWidth, inputHeight, outputWidth, outputHeight)
```

Mirror Quake's GL_Resample8BitTexture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `GL_Resample8BitTexture`. |
| `inputWidth` | `dynamic` | — | The input width input consumed by `GL_Resample8BitTexture`. |
| `inputHeight` | `dynamic` | — | The input height input consumed by `GL_Resample8BitTexture`. |
| `outputWidth` | `dynamic` | — | The output width input consumed by `GL_Resample8BitTexture`. |
| `outputHeight` | `dynamic` | — | The output height input consumed by `GL_Resample8BitTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L579)

<a id="function-function-miniquake-render-draw2d-gl-resampletexture-function-gl-resampletexture-input-inputwidth-inputheight-outputwidth-outputheight-src-miniquake-render-draw2d-ml-1199188844"></a>
### GL_ResampleTexture

```ml
function GL_ResampleTexture(input, inputWidth, inputHeight, outputWidth, outputHeight)
```

Mirror Quake's GL_ResampleTexture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `GL_ResampleTexture`. |
| `inputWidth` | `dynamic` | — | The input width input consumed by `GL_ResampleTexture`. |
| `inputHeight` | `dynamic` | — | The input height input consumed by `GL_ResampleTexture`. |
| `outputWidth` | `dynamic` | — | The output width input consumed by `GL_ResampleTexture`. |
| `outputHeight` | `dynamic` | — | The output height input consumed by `GL_ResampleTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L547)

<a id="function-function-miniquake-render-draw2d-gl-selecttexture-function-gl-selecttexture-target-src-miniquake-render-draw2d-ml-1644192499"></a>
### GL_SelectTexture

```ml
function GL_SelectTexture(target)
```

Mirror Quake's GL_SelectTexture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | The target input consumed by `GL_SelectTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L931)

<a id="function-function-miniquake-render-draw2d-gl-set2d-function-gl-set2d-src-miniquake-render-draw2d-ml-1499327726"></a>
### GL_Set2D

```ml
function GL_Set2D()
```

Mirror Quake's GL_Set2D routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1917)

<a id="global-global-miniquake-render-draw2d-gl-solid-format-gl-solid-format-src-miniquake-render-draw2d-ml-109625276"></a>
### gl_solid_format

```ml
gl_solid_format
```

Tracks the module-level gl solid format state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L82)

<a id="global-global-miniquake-render-draw2d-gl-textureupscale-gl-textureupscale-src-miniquake-render-draw2d-ml-697948816"></a>
### gl_textureupscale

```ml
gl_textureupscale
```

Tracks the module-level gl textureupscale state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L72)

<a id="function-function-miniquake-render-draw2d-gl-textureupscalemode-function-gl-textureupscalemode-src-miniquake-render-draw2d-ml-501674968"></a>
### GL_TextureUpscaleMode

```ml
function GL_TextureUpscaleMode()
```

Return the active backend-neutral texture-upscale selection.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L710)

<a id="function-function-miniquake-render-draw2d-gl-upload32-function-gl-upload32-data-width-height-mipmap-alpha-src-miniquake-render-draw2d-ml-1283692991"></a>
### GL_Upload32

```ml
function GL_Upload32(data, width, height, mipmap, alpha)
```

Mirror Quake's GL_Upload32 routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mipmap` | `dynamic` | — | The mipmap input consumed by `GL_Upload32`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `GL_Upload32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L794)

<a id="function-function-miniquake-render-draw2d-gl-upload8-function-gl-upload8-data-width-height-mipmap-alpha-src-miniquake-render-draw2d-ml-1326810879"></a>
### GL_Upload8

```ml
function GL_Upload8(data, width, height, mipmap, alpha)
```

Mirror Quake's GL_Upload8 routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mipmap` | `dynamic` | — | The mipmap input consumed by `GL_Upload8`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `GL_Upload8`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L873)

<a id="function-function-miniquake-render-draw2d-gl-upload8-ext-function-gl-upload8-ext-data-width-height-mipmap-alpha-src-miniquake-render-draw2d-ml-213014195"></a>
### GL_Upload8_EXT

```ml
function GL_Upload8_EXT(data, width, height, mipmap, alpha)
```

Mirror Quake's GL_Upload8_EXT routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `mipmap` | `dynamic` | — | The mipmap input consumed by `GL_Upload8_EXT`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `GL_Upload8_EXT`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L855)

<a id="function-function-miniquake-render-draw2d-gl-upscaletexturergba-function-gl-upscaletexturergba-data-width-height-src-miniquake-render-draw2d-ml-1066389911"></a>
### GL_UpscaleTextureRgba

```ml
function GL_UpscaleTextureRgba(data, width, height)
```

Upscale one non-UI RGBA texture before the ordinary power-of-two and mip processing. Textures which cannot gain resolution within the configured upload limit remain unchanged instead of allocating a throwaway image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L732)

<a id="global-global-miniquake-render-draw2d-glmultitextureavailable-glmultitextureavailable-src-miniquake-render-draw2d-ml-1297971068"></a>
### glMultiTextureAvailable

```ml
glMultiTextureAvailable
```

Tracks the module-level gl multi texture available state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L130)

<a id="global-global-miniquake-render-draw2d-gltextureheights-gltextureheights-src-miniquake-render-draw2d-ml-11091868"></a>
### glTextureHeights

```ml
glTextureHeights
```

Tracks the module-level gl texture heights state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L123)

<a id="global-global-miniquake-render-draw2d-gltextureids-gltextureids-src-miniquake-render-draw2d-ml-1642661428"></a>
### glTextureIds

```ml
glTextureIds
```

Tracks the module-level gl texture ids state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L119)

<a id="global-global-miniquake-render-draw2d-gltexturemipmaps-gltexturemipmaps-src-miniquake-render-draw2d-ml-229042254"></a>
### glTextureMipmaps

```ml
glTextureMipmaps
```

Tracks the module-level gl texture mipmaps state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L125)

<a id="global-global-miniquake-render-draw2d-gltexturenames-gltexturenames-src-miniquake-render-draw2d-ml-477540284"></a>
### glTextureNames

```ml
glTextureNames
```

Tracks the module-level gl texture names state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L117)

<a id="global-global-miniquake-render-draw2d-gltexturewidths-gltexturewidths-src-miniquake-render-draw2d-ml-1252149392"></a>
### glTextureWidths

```ml
glTextureWidths
```

Tracks the module-level gl texture widths state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L121)

<a id="function-function-miniquake-render-draw2d-indexedfontrgba-function-indexedfontrgba-pixels-palette-src-miniquake-render-draw2d-ml-1434417092"></a>
### indexedFontRgba

```ml
function indexedFontRgba(pixels, palette)
```

Implements the `indexedFontRgba` operation for `miniquake.render.draw2d` (indexed font rgba).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `indexedFontRgba`. |
| `palette` | `dynamic` | — | The palette input consumed by `indexedFontRgba`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L139)

<a id="function-function-miniquake-render-draw2d-indexedpicturergba-function-indexedpicturergba-pixels-palette-transparent-src-miniquake-render-draw2d-ml-1613447296"></a>
### indexedPictureRgba

```ml
function indexedPictureRgba(pixels, palette, transparent)
```

Implements the `indexedPictureRgba` operation for `miniquake.render.draw2d` (indexed picture rgba).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pixels` | `dynamic` | — | The pixels input consumed by `indexedPictureRgba`. |
| `palette` | `dynamic` | — | The palette input consumed by `indexedPictureRgba`. |
| `transparent` | `dynamic` | — | The transparent input consumed by `indexedPictureRgba`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L184)

<a id="function-function-miniquake-render-draw2d-indexedtouploadrgba-function-indexedtouploadrgba-data-width-height-alpha-src-miniquake-render-draw2d-ml-460869445"></a>
### indexedToUploadRgba

```ml
function indexedToUploadRgba(data, width, height, alpha)
```

Implements the `indexedToUploadRgba` operation for `miniquake.render.draw2d` (indexed to upload rgba).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `alpha` | `dynamic` | — | The alpha input consumed by `indexedToUploadRgba`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L828)

<a id="constant-constant-miniquake-render-draw2d-max-cached-pics-const-max-cached-pics-128-src-miniquake-render-draw2d-ml-902139394"></a>
### MAX_CACHED_PICS

```ml
const MAX_CACHED_PICS = 128
```

Defines the max cached pics value used by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L32)

<a id="constant-constant-miniquake-render-draw2d-max-gltextures-const-max-gltextures-1024-src-miniquake-render-draw2d-ml-471618868"></a>
### MAX_GLTEXTURES

```ml
const MAX_GLTEXTURES = 1024
```

Defines the max gltextures value used by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L30)

<a id="constant-constant-miniquake-render-draw2d-max-scraps-const-max-scraps-2-src-miniquake-render-draw2d-ml-2024728407"></a>
### MAX_SCRAPS

```ml
const MAX_SCRAPS = 2
```

Defines the max scraps value used by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L24)

<a id="global-global-miniquake-render-draw2d-menu-cachepics-menu-cachepics-src-miniquake-render-draw2d-ml-1498091162"></a>
### menu_cachepics

```ml
menu_cachepics
```

Tracks the module-level menu cachepics state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L106)

<a id="global-global-miniquake-render-draw2d-menuplyr-pixels-menuplyr-pixels-src-miniquake-render-draw2d-ml-989144356"></a>
### menuplyr_pixels

```ml
menuplyr_pixels
```

Tracks the module-level menuplyr pixels state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L57)

<a id="function-function-miniquake-render-draw2d-nearestpaletteindex-function-nearestpaletteindex-red-green-blue-src-miniquake-render-draw2d-ml-14697566"></a>
### nearestPaletteIndex

```ml
function nearestPaletteIndex(red, green, blue)
```

Return nearest palette index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `red` | `dynamic` | — | The red input consumed by `nearestPaletteIndex`. |
| `green` | `dynamic` | — | The green input consumed by `nearestPaletteIndex`. |
| `blue` | `dynamic` | — | The blue input consumed by `nearestPaletteIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L642)

<a id="function-function-miniquake-render-draw2d-nextpoweroftwo-function-nextpoweroftwo-value-src-miniquake-render-draw2d-ml-60131485"></a>
### nextPowerOfTwo

```ml
function nextPowerOfTwo(value)
```

Return next power of two for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `nextPowerOfTwo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L701)

<a id="global-global-miniquake-render-draw2d-oldtexturetarget-oldtexturetarget-src-miniquake-render-draw2d-ml-345939770"></a>
### oldTextureTarget

```ml
oldTextureTarget
```

Tracks the module-level old texture target state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L132)

<a id="function-function-miniquake-render-draw2d-parseqpic-function-parseqpic-data-name-src-miniquake-render-draw2d-ml-262574341"></a>
### parseQpic

```ml
function parseQpic(data, name)
```

Read and validate qpic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L504)

<a id="global-global-miniquake-render-draw2d-pic-count-pic-count-src-miniquake-render-draw2d-ml-33400392"></a>
### pic_count

```ml
pic_count
```

Tracks the module-level pic count state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L101)

<a id="global-global-miniquake-render-draw2d-pic-texels-pic-texels-src-miniquake-render-draw2d-ml-309918980"></a>
### pic_texels

```ml
pic_texels
```

Tracks the module-level pic texels state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L99)

<a id="function-function-miniquake-render-draw2d-picturecoordinates-function-picturecoordinates-picture-src-miniquake-render-draw2d-ml-997107182"></a>
### pictureCoordinates

```ml
function pictureCoordinates(picture)
```

Implements the `pictureCoordinates` operation for `miniquake.render.draw2d` (picture coordinates).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `pictureCoordinates`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L487)

<a id="function-function-miniquake-render-draw2d-picturefrompixels-function-picturefrompixels-name-width-height-pixels-texture-coordinates-src-miniquake-render-draw2d-ml-1929152667"></a>
### pictureFromPixels

```ml
function pictureFromPixels(name, width, height, pixels, texture, coordinates)
```

Implements the `pictureFromPixels` operation for `miniquake.render.draw2d` (picture from pixels).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `pictureFromPixels`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `coordinates` | `dynamic` | — | The coordinates input consumed by `pictureFromPixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1043)

<a id="function-function-miniquake-render-draw2d-picturemetadataindex-function-picturemetadataindex-picture-src-miniquake-render-draw2d-ml-538087350"></a>
### pictureMetadataIndex

```ml
function pictureMetadataIndex(picture)
```

Return picture metadata index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `pictureMetadataIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L476)

<a id="function-function-miniquake-render-draw2d-picturepixels-function-picturepixels-picture-src-miniquake-render-draw2d-ml-13376484"></a>
### picturePixels

```ml
function picturePixels(picture)
```

Implements the `picturePixels` operation for `miniquake.render.draw2d` (picture pixels).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `picturePixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L495)

<a id="function-function-miniquake-render-draw2d-pictureusesscrap-function-pictureusesscrap-picture-src-miniquake-render-draw2d-ml-1399639610"></a>
### PictureUsesScrap

```ml
function PictureUsesScrap(picture)
```

Implements the `PictureUsesScrap` operation for `miniquake.render.draw2d` (picture uses scrap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `PictureUsesScrap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1380)

<a id="function-function-miniquake-render-draw2d-registerdrawpicture-function-registerdrawpicture-picture-coordinates-pixels-src-miniquake-render-draw2d-ml-491565604"></a>
### registerDrawPicture

```ml
function registerDrawPicture(picture, coordinates, pixels)
```

Update subsystem configuration for register draw picture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `picture` | `dynamic` | — | The picture input consumed by `registerDrawPicture`. |
| `coordinates` | `dynamic` | — | The coordinates input consumed by `registerDrawPicture`. |
| `pixels` | `dynamic` | — | The pixels input consumed by `registerDrawPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L457)

<a id="function-function-miniquake-render-draw2d-resetscrap-function-resetscrap-textureids-src-miniquake-render-draw2d-ml-1449809217"></a>
### ResetScrap

```ml
function ResetScrap(textureIds)
```

Update module state for scrap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textureIds` | `dynamic` | — | The texture ids input consumed by `ResetScrap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L946)

<a id="global-global-miniquake-render-draw2d-scrap-allocated-scrap-allocated-src-miniquake-render-draw2d-ml-865357252"></a>
### scrap_allocated

```ml
scrap_allocated
```

Tracks the module-level scrap allocated state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L89)

<a id="function-function-miniquake-render-draw2d-scrap-allocblock-function-scrap-allocblock-width-height-src-miniquake-render-draw2d-ml-149912631"></a>
### Scrap_AllocBlock

```ml
function Scrap_AllocBlock(width, height)
```

C returns the scrap number and writes x/y through pointer arguments.  The MiniLang port returns the three values as [scrap, x, y].

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L977)

<a id="global-global-miniquake-render-draw2d-scrap-dirty-scrap-dirty-src-miniquake-render-draw2d-ml-566001516"></a>
### scrap_dirty

```ml
scrap_dirty
```

Tracks the module-level scrap dirty state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L95)

<a id="constant-constant-miniquake-render-draw2d-scrap-height-const-scrap-height-256-src-miniquake-render-draw2d-ml-1167286454"></a>
### SCRAP_HEIGHT

```ml
const SCRAP_HEIGHT = 256
```

Defines the scrap height value used by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L28)

<a id="global-global-miniquake-render-draw2d-scrap-texels-scrap-texels-src-miniquake-render-draw2d-ml-2067707418"></a>
### scrap_texels

```ml
scrap_texels
```

Tracks the module-level scrap texels state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L91)

<a id="global-global-miniquake-render-draw2d-scrap-textures-scrap-textures-src-miniquake-render-draw2d-ml-517373948"></a>
### scrap_textures

```ml
scrap_textures
```

Tracks the module-level scrap textures state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L93)

<a id="function-function-miniquake-render-draw2d-scrap-upload-function-scrap-upload-src-miniquake-render-draw2d-ml-2046079778"></a>
### Scrap_Upload

```ml
function Scrap_Upload()
```

Mirror Quake's Scrap_Upload routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L1021)

<a id="global-global-miniquake-render-draw2d-scrap-uploads-scrap-uploads-src-miniquake-render-draw2d-ml-1260686860"></a>
### scrap_uploads

```ml
scrap_uploads
```

Tracks the module-level scrap uploads state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L97)

<a id="constant-constant-miniquake-render-draw2d-scrap-width-const-scrap-width-256-src-miniquake-render-draw2d-ml-398564394"></a>
### SCRAP_WIDTH

```ml
const SCRAP_WIDTH = 256
```

Defines the scrap width value used by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L26)

<a id="function-function-miniquake-render-draw2d-setvideosize-function-setvideosize-width-height-src-miniquake-render-draw2d-ml-1423961331"></a>
### SetVideoSize

```ml
function SetVideoSize(width, height)
```

Update module state for video size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L443)

<a id="function-function-miniquake-render-draw2d-solidquad-function-solidquad-x-y-width-height-red-green-blue-alpha-src-miniquake-render-draw2d-ml-1703779630"></a>
### solidQuad

```ml
function solidQuad(x, y, width, height, red, green, blue, alpha)
```

Implements the `solidQuad` operation for `miniquake.render.draw2d` (solid quad).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | The x input consumed by `solidQuad`. |
| `y` | `dynamic` | — | The y input consumed by `solidQuad`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `red` | `dynamic` | — | The red input consumed by `solidQuad`. |
| `green` | `dynamic` | — | The green input consumed by `solidQuad`. |
| `blue` | `dynamic` | — | The blue input consumed by `solidQuad`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `solidQuad`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L264)

<a id="function-function-miniquake-render-draw2d-string-function-string-texture-x-y-text-scale-alpha-src-miniquake-render-draw2d-ml-907723801"></a>
### string

```ml
function string(texture, x, y, text, scale, alpha)
```

Implements the `string` operation for `miniquake.render.draw2d` (string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `string`. |
| `y` | `dynamic` | — | The y input consumed by `string`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `scale` | `dynamic` | — | The scale input consumed by `string`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `string`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L327)

<a id="function-function-miniquake-render-draw2d-syncdrawcvars-function-syncdrawcvars-src-miniquake-render-draw2d-ml-1908203054"></a>
### syncDrawCvars

```ml
function syncDrawCvars()
```

Update module state for draw cvars.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L420)

<a id="global-global-miniquake-render-draw2d-texels-texels-src-miniquake-render-draw2d-ml-414558342"></a>
### texels

```ml
texels
```

Tracks the module-level texels state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L86)

<a id="global-global-miniquake-render-draw2d-texture-extension-number-texture-extension-number-src-miniquake-render-draw2d-ml-1435512042"></a>
### texture_extension_number

```ml
texture_extension_number
```

Tracks the module-level texture extension number state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L127)

<a id="function-function-miniquake-render-draw2d-texturedquad-function-texturedquad-texture-x-y-width-height-s0-t0-s1-t1-red-green-blue-alpha-src-miniquake-render-draw2d-ml-1220736483"></a>
### texturedQuad

```ml
function texturedQuad(texture, x, y, width, height, s0, t0, s1, t1, red, green, blue, alpha)
```

Implements the `texturedQuad` operation for `miniquake.render.draw2d` (textured quad).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |
| `x` | `dynamic` | — | The x input consumed by `texturedQuad`. |
| `y` | `dynamic` | — | The y input consumed by `texturedQuad`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `s0` | `dynamic` | — | The s0 input consumed by `texturedQuad`. |
| `t0` | `dynamic` | — | The t0 input consumed by `texturedQuad`. |
| `s1` | `dynamic` | — | The s1 input consumed by `texturedQuad`. |
| `t1` | `dynamic` | — | The t1 input consumed by `texturedQuad`. |
| `red` | `dynamic` | — | The red input consumed by `texturedQuad`. |
| `green` | `dynamic` | — | The green input consumed by `texturedQuad`. |
| `blue` | `dynamic` | — | The blue input consumed by `texturedQuad`. |
| `alpha` | `dynamic` | — | The alpha input consumed by `texturedQuad`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L290)

<a id="global-global-miniquake-render-draw2d-translate-texture-translate-texture-src-miniquake-render-draw2d-ml-1358016764"></a>
### translate_texture

```ml
translate_texture
```

Tracks the module-level translate texture state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L62)

<a id="function-function-miniquake-render-draw2d-uploadfont-function-uploadfont-conchars-palette-src-miniquake-render-draw2d-ml-1945020764"></a>
### uploadFont

```ml
function uploadFont(conchars, palette)
```

Upload font to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `conchars` | `dynamic` | — | The conchars input consumed by `uploadFont`. |
| `palette` | `dynamic` | — | The palette input consumed by `uploadFont`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L166)

<a id="function-function-miniquake-render-draw2d-uploadpicture-function-uploadpicture-data-palette-name-transparent-src-miniquake-render-draw2d-ml-690989266"></a>
### uploadPicture

```ml
function uploadPicture(data, palette, name, transparent)
```

Quake qpic_t files store little-endian width/height followed by indexed pixels.  Menu artwork uses palette index 255 as transparent.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `palette` | `dynamic` | — | The palette input consumed by `uploadPicture`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `transparent` | `dynamic` | — | The transparent input consumed by `uploadPicture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L209)

<a id="global-global-miniquake-render-draw2d-wad-cachepics-wad-cachepics-src-miniquake-render-draw2d-ml-1859276404"></a>
### wad_cachepics

```ml
wad_cachepics
```

Tracks the module-level wad cachepics state owned by `miniquake.render.draw2d`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/draw2d.ml#L108)
