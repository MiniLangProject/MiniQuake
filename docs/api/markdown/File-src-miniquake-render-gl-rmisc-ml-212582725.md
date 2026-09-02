# `src/miniquake/render/gl_rmisc.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl_rmisc`](Package-miniquake-render-gl-rmisc-1433882125.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)

## Declarations

<a id="function-function-miniquake-render-gl-rmisc-d-flushcaches-function-d-flushcaches-src-miniquake-render-gl-rmisc-ml-509203510"></a>
### D_FlushCaches

```ml
function D_FlushCaches()
```

Mirror Quake's D_FlushCaches routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L380)

<a id="global-global-miniquake-render-gl-rmisc-envmap-envmap-src-miniquake-render-gl-rmisc-ml-595092926"></a>
### envmap

```ml
envmap
```

Tracks the module-level envmap state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L31)

<a id="function-function-miniquake-render-gl-rmisc-getinitstate-function-getinitstate-src-miniquake-render-gl-rmisc-ml-300808034"></a>
### GetInitState

```ml
function GetInitState()
```

Return init state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L395)

<a id="function-function-miniquake-render-gl-rmisc-getnewmapstate-function-getnewmapstate-src-miniquake-render-gl-rmisc-ml-743678006"></a>
### GetNewMapState

```ml
function GetNewMapState()
```

Return new map state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L405)

<a id="function-function-miniquake-render-gl-rmisc-getparticlestate-function-getparticlestate-src-miniquake-render-gl-rmisc-ml-2039571354"></a>
### GetParticleState

```ml
function GetParticleState()
```

Return particle state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L390)

<a id="function-function-miniquake-render-gl-rmisc-getrefreshstate-inline-function-getrefreshstate-src-miniquake-render-gl-rmisc-ml-1713251353"></a>
### GetRefreshState

```ml
inline function GetRefreshState()
```

Return refresh state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L410)

<a id="function-function-miniquake-render-gl-rmisc-getskinstate-function-getskinstate-src-miniquake-render-gl-rmisc-ml-1602324142"></a>
### GetSkinState

```ml
function GetSkinState()
```

Return skin state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L400)

<a id="function-function-miniquake-render-gl-rmisc-gettexturestate-function-gettexturestate-src-miniquake-render-gl-rmisc-ml-1747188406"></a>
### GetTextureState

```ml
function GetTextureState()
```

Return texture state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L385)

<a id="global-global-miniquake-render-gl-rmisc-particletexture-particletexture-src-miniquake-render-gl-rmisc-ml-9446492"></a>
### particletexture

```ml
particletexture
```

Tracks the module-level particletexture state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L25)

<a id="global-global-miniquake-render-gl-rmisc-playertextures-playertextures-src-miniquake-render-gl-rmisc-ml-353045162"></a>
### playertextures

```ml
playertextures
```

Tracks the module-level playertextures state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L29)

<a id="function-function-miniquake-render-gl-rmisc-r-envmap-f-function-r-envmap-f-src-miniquake-render-gl-rmisc-ml-1358359542"></a>
### R_Envmap_f

```ml
function R_Envmap_f()
```

Apply the Quake-compatible r envmap f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L205)

<a id="function-function-miniquake-render-gl-rmisc-r-init-function-r-init-multitexture-src-miniquake-render-gl-rmisc-ml-686401050"></a>
### R_Init

```ml
function R_Init(multitexture)
```

Apply the Quake-compatible r init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `multitexture` | `dynamic` | — | The multitexture input consumed by `R_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L222)

<a id="function-function-miniquake-render-gl-rmisc-r-initparticletexture-function-r-initparticletexture-src-miniquake-render-gl-rmisc-ml-21775070"></a>
### R_InitParticleTexture

```ml
function R_InitParticleTexture()
```

Implements the `R_InitParticleTexture` operation for `miniquake.render.gl_rmisc` (r init particle texture).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L168)

<a id="function-function-miniquake-render-gl-rmisc-r-inittextures-function-r-inittextures-src-miniquake-render-gl-rmisc-ml-512196834"></a>
### R_InitTextures

```ml
function R_InitTextures()
```

Apply the Quake-compatible r init textures behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L134)

<a id="function-function-miniquake-render-gl-rmisc-r-newmap-function-r-newmap-src-miniquake-render-gl-rmisc-ml-2134804006"></a>
### R_NewMap

```ml
function R_NewMap()
```

Apply the Quake-compatible r new map behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L350)

<a id="global-global-miniquake-render-gl-rmisc-r-notexture-mip-r-notexture-mip-src-miniquake-render-gl-rmisc-ml-1414051184"></a>
### r_notexture_mip

```ml
r_notexture_mip
```

Direct MiniLang pendant of WinQuake/gl_rmisc.c. The host-facing renderer keeps platform I/O in its existing bridges; this module owns the original texture-generation, palette-translation and renderer-reset semantics so they can also be executed without an OpenGL context by the differential oracle.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L19)

<a id="global-global-miniquake-render-gl-rmisc-r-notexture-mips-r-notexture-mips-src-miniquake-render-gl-rmisc-ml-1688644054"></a>
### r_notexture_mips

```ml
r_notexture_mips
```

Tracks the module-level r notexture mips state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L21)

<a id="global-global-miniquake-render-gl-rmisc-r-notexture-offsets-r-notexture-offsets-src-miniquake-render-gl-rmisc-ml-1315896828"></a>
### r_notexture_offsets

```ml
r_notexture_offsets
```

Tracks the module-level r notexture offsets state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L23)

<a id="function-function-miniquake-render-gl-rmisc-r-timerefresh-f-function-r-timerefresh-f-src-miniquake-render-gl-rmisc-ml-196602822"></a>
### R_TimeRefresh_f

```ml
function R_TimeRefresh_f()
```

Apply the Quake-compatible r time refresh f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L369)

<a id="function-function-miniquake-render-gl-rmisc-r-translateplayerskin-function-r-translateplayerskin-playernum-src-miniquake-render-gl-rmisc-ml-1708492353"></a>
### R_TranslatePlayerSkin

```ml
function R_TranslatePlayerSkin(playernum)
```

Apply the Quake-compatible r translate player skin behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playernum` | `dynamic` | — | The playernum input consumed by `R_TranslatePlayerSkin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L283)

<a id="function-function-miniquake-render-gl-rmisc-resetcompatibility-function-resetcompatibility-src-miniquake-render-gl-rmisc-ml-781788758"></a>
### ResetCompatibility

```ml
function ResetCompatibility()
```

Update module state for compatibility.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L86)

<a id="global-global-miniquake-render-gl-rmisc-rmiscboundtexture-rmiscboundtexture-src-miniquake-render-gl-rmisc-ml-1406032304"></a>
### rmiscBoundTexture

```ml
rmiscBoundTexture
```

Tracks the module-level rmisc bound texture state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L47)

<a id="global-global-miniquake-render-gl-rmisc-rmiscbuildlightmaps-rmiscbuildlightmaps-src-miniquake-render-gl-rmisc-ml-1552920640"></a>
### rmiscBuildLightmaps

```ml
rmiscBuildLightmaps
```

Tracks the module-level rmisc build lightmaps state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L41)

<a id="global-global-miniquake-render-gl-rmisc-rmiscclearparticles-rmiscclearparticles-src-miniquake-render-gl-rmisc-ml-1874554328"></a>
### rmiscClearParticles

```ml
rmiscClearParticles
```

Tracks the module-level rmisc clear particles state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L39)

<a id="global-global-miniquake-render-gl-rmisc-rmisccolors-rmisccolors-src-miniquake-render-gl-rmisc-ml-576891320"></a>
### rmiscColors

```ml
rmiscColors
```

Tracks the module-level rmisc colors state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L79)

<a id="global-global-miniquake-render-gl-rmisc-rmisccommands-rmisccommands-src-miniquake-render-gl-rmisc-ml-3345380"></a>
### rmiscCommands

```ml
rmiscCommands
```

Tracks the module-level rmisc commands state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L33)

<a id="global-global-miniquake-render-gl-rmisc-rmisccvars-rmisccvars-src-miniquake-render-gl-rmisc-ml-2104453226"></a>
### rmiscCvars

```ml
rmiscCvars
```

Tracks the module-level rmisc cvars state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L35)

<a id="global-global-miniquake-render-gl-rmisc-rmiscendrendering-rmiscendrendering-src-miniquake-render-gl-rmisc-ml-1323477128"></a>
### rmiscEndRendering

```ml
rmiscEndRendering
```

Tracks the module-level rmisc end rendering state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L71)

<a id="global-global-miniquake-render-gl-rmisc-rmiscenvdirections-rmiscenvdirections-src-miniquake-render-gl-rmisc-ml-678462250"></a>
### rmiscEnvDirections

```ml
rmiscEnvDirections
```

Tracks the module-level rmisc env directions state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L53)

<a id="global-global-miniquake-render-gl-rmisc-rmiscinitparticles-rmiscinitparticles-src-miniquake-render-gl-rmisc-ml-291959046"></a>
### rmiscInitParticles

```ml
rmiscInitParticles
```

Tracks the module-level rmisc init particles state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L37)

<a id="global-global-miniquake-render-gl-rmisc-rmisclastdrawbuffer-rmisclastdrawbuffer-src-miniquake-render-gl-rmisc-ml-1476233184"></a>
### rmiscLastDrawBuffer

```ml
rmiscLastDrawBuffer
```

Tracks the module-level rmisc last draw buffer state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L69)

<a id="global-global-miniquake-render-gl-rmisc-rmisclastyaw-rmisclastyaw-src-miniquake-render-gl-rmisc-ml-1298495738"></a>
### rmiscLastYaw

```ml
rmiscLastYaw
```

Tracks the module-level rmisc last yaw state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L67)

<a id="global-global-miniquake-render-gl-rmisc-rmiscleafcount-rmiscleafcount-src-miniquake-render-gl-rmisc-ml-682553694"></a>
### rmiscLeafCount

```ml
rmiscLeafCount
```

Tracks the module-level rmisc leaf count state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L57)

<a id="global-global-miniquake-render-gl-rmisc-rmisclightstyles-rmisclightstyles-src-miniquake-render-gl-rmisc-ml-1976714956"></a>
### rmiscLightStyles

```ml
rmiscLightStyles
```

Tracks the module-level rmisc light styles state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L59)

<a id="global-global-miniquake-render-gl-rmisc-rmiscmaxsize-rmiscmaxsize-src-miniquake-render-gl-rmisc-ml-1342211370"></a>
### rmiscMaxSize

```ml
rmiscMaxSize
```

Tracks the module-level rmisc max size state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L81)

<a id="global-global-miniquake-render-gl-rmisc-rmiscmirrortexture-rmiscmirrortexture-src-miniquake-render-gl-rmisc-ml-107985532"></a>
### rmiscMirrorTexture

```ml
rmiscMirrorTexture
```

Tracks the module-level rmisc mirror texture state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L63)

<a id="global-global-miniquake-render-gl-rmisc-rmiscparticlepixels-rmiscparticlepixels-src-miniquake-render-gl-rmisc-ml-771388272"></a>
### rmiscParticlePixels

```ml
rmiscParticlePixels
```

Tracks the module-level rmisc particle pixels state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L43)

<a id="global-global-miniquake-render-gl-rmisc-rmiscplayermip-rmiscplayermip-src-miniquake-render-gl-rmisc-ml-191723374"></a>
### rmiscPlayerMip

```ml
rmiscPlayerMip
```

Tracks the module-level rmisc player mip state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L83)

<a id="global-global-miniquake-render-gl-rmisc-rmiscrenderviews-rmiscrenderviews-src-miniquake-render-gl-rmisc-ml-1829934096"></a>
### rmiscRenderViews

```ml
rmiscRenderViews
```

Tracks the module-level rmisc render views state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L65)

<a id="global-global-miniquake-render-gl-rmisc-rmiscskin-rmiscskin-src-miniquake-render-gl-rmisc-ml-529597028"></a>
### rmiscSkin

```ml
rmiscSkin
```

Tracks the module-level rmisc skin state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L73)

<a id="global-global-miniquake-render-gl-rmisc-rmiscskinheight-rmiscskinheight-src-miniquake-render-gl-rmisc-ml-239271268"></a>
### rmiscSkinHeight

```ml
rmiscSkinHeight
```

Tracks the module-level rmisc skin height state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L77)

<a id="global-global-miniquake-render-gl-rmisc-rmiscskinpixels-rmiscskinpixels-src-miniquake-render-gl-rmisc-ml-1300514440"></a>
### rmiscSkinPixels

```ml
rmiscSkinPixels
```

Tracks the module-level rmisc skin pixels state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L45)

<a id="global-global-miniquake-render-gl-rmisc-rmiscskinwidth-rmiscskinwidth-src-miniquake-render-gl-rmisc-ml-298909362"></a>
### rmiscSkinWidth

```ml
rmiscSkinWidth
```

Tracks the module-level rmisc skin width state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L75)

<a id="global-global-miniquake-render-gl-rmisc-rmiscskytexture-rmiscskytexture-src-miniquake-render-gl-rmisc-ml-701315944"></a>
### rmiscSkyTexture

```ml
rmiscSkyTexture
```

Tracks the module-level rmisc sky texture state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L61)

<a id="global-global-miniquake-render-gl-rmisc-rmisctexturenames-rmisctexturenames-src-miniquake-render-gl-rmisc-ml-1529810240"></a>
### rmiscTextureNames

```ml
rmiscTextureNames
```

Tracks the module-level rmisc texture names state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L55)

<a id="global-global-miniquake-render-gl-rmisc-rmiscuploadheight-rmiscuploadheight-src-miniquake-render-gl-rmisc-ml-597643668"></a>
### rmiscUploadHeight

```ml
rmiscUploadHeight
```

Tracks the module-level rmisc upload height state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L51)

<a id="global-global-miniquake-render-gl-rmisc-rmiscuploadwidth-rmiscuploadwidth-src-miniquake-render-gl-rmisc-ml-110457598"></a>
### rmiscUploadWidth

```ml
rmiscUploadWidth
```

Tracks the module-level rmisc upload width state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L49)

<a id="function-function-miniquake-render-gl-rmisc-setnewmapcompatibility-function-setnewmapcompatibility-texturenames-leafcount-src-miniquake-render-gl-rmisc-ml-461006780"></a>
### SetNewMapCompatibility

```ml
function SetNewMapCompatibility(textureNames, leafCount)
```

Update module state for new map compatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textureNames` | `dynamic` | — | The texture names input consumed by `SetNewMapCompatibility`. |
| `leafCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L327)

<a id="function-function-miniquake-render-gl-rmisc-setplayerskincompatibility-function-setplayerskincompatibility-width-height-pixels-colors-maxsize-playermip-src-miniquake-render-gl-rmisc-ml-1222988778"></a>
### SetPlayerSkinCompatibility

```ml
function SetPlayerSkinCompatibility(width, height, pixels, colors, maxSize, playerMip)
```

Update module state for player skin compatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `SetPlayerSkinCompatibility`. |
| `colors` | `dynamic` | — | The colors input consumed by `SetPlayerSkinCompatibility`. |
| `maxSize` | `dynamic` | — | Size of the requested data or resource. |
| `playerMip` | `dynamic` | — | The player mip input consumed by `SetPlayerSkinCompatibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L243)

<a id="function-function-miniquake-render-gl-rmisc-setplayertexturebase-function-setplayertexturebase-value-src-miniquake-render-gl-rmisc-ml-2065097021"></a>
### SetPlayerTextureBase

```ml
function SetPlayerTextureBase(value)
```

Update module state for player texture base.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `SetPlayerTextureBase`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L257)

<a id="function-function-miniquake-render-gl-rmisc-startswith-function-startswith-value-prefix-src-miniquake-render-gl-rmisc-ml-207366341"></a>
### startsWith

```ml
function startsWith(value, prefix)
```

Starts s with for `miniquake.render.gl_rmisc`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `startsWith`. |
| `prefix` | `dynamic` | — | The prefix input consumed by `startsWith`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L337)

<a id="global-global-miniquake-render-gl-rmisc-texture-extension-number-texture-extension-number-src-miniquake-render-gl-rmisc-ml-187747062"></a>
### texture_extension_number

```ml
texture_extension_number
```

Tracks the module-level texture extension number state owned by `miniquake.render.gl_rmisc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L27)

<a id="function-function-miniquake-render-gl-rmisc-translatedindex-function-translatedindex-value-top-bottom-src-miniquake-render-gl-rmisc-ml-205934265"></a>
### translatedIndex

```ml
function translatedIndex(value, top, bottom)
```

Return translated index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `translatedIndex`. |
| `top` | `dynamic` | — | The top input consumed by `translatedIndex`. |
| `bottom` | `dynamic` | — | The bottom input consumed by `translatedIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_rmisc.ml#L267)
