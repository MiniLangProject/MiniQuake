# `src/miniquake/render/original.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.original`](Package-miniquake-render-original-235973380.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `compatRmainArrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/client.ml` as `compatRmainClient` → [src/miniquake/client.ml](File-src-miniquake-client-ml-1164576599.md)
- `miniquake/constants.ml` as `compatRmainConstants` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `compatRmainCvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/mathlib.ml` as `compatRmainMath` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `compatRmainNative` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `compatRmainWin` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/render/alias_mesh.ml` as `compatRmainAlias` → [src/miniquake/render/alias_mesh.ml](File-src-miniquake-render-alias-mesh-ml-1136390123.md)
- `miniquake/render/entities.ml` as `compatRmainEntities` → [src/miniquake/render/entities.ml](File-src-miniquake-render-entities-ml-1187973086.md)
- `miniquake/render/gl11.ml` as `compatRmainGl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/particles.ml` as `compatRmainParticles` → [src/miniquake/render/particles.ml](File-src-miniquake-render-particles-ml-1835375214.md)
- `miniquake/render/world.ml` as `compatRmainWorld` → [src/miniquake/render/world.ml](File-src-miniquake-render-world-ml-1647521183.md)
- `miniquake/types.ml` as `compatRmainTypes` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `compatRmainBsp` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)
- `std/fs.ml` as `compatRmainFs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="global-global-miniquake-render-original-c-alias-polys-c-alias-polys-src-miniquake-render-original-ml-1803211244"></a>
### c_alias_polys

```ml
c_alias_polys
```

Tracks the module-level c alias polys state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L58)

<a id="global-global-miniquake-render-original-c-brush-polys-c-brush-polys-src-miniquake-render-original-ml-1689887804"></a>
### c_brush_polys

```ml
c_brush_polys
```

Tracks the module-level c brush polys state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L56)

<a id="global-global-miniquake-render-original-cl-numvisedicts-cl-numvisedicts-src-miniquake-render-original-ml-93215932"></a>
### cl_numvisedicts

```ml
cl_numvisedicts
```

Tracks the module-level cl numvisedicts state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L160)

<a id="global-global-miniquake-render-original-cl-visedicts-cl-visedicts-src-miniquake-render-original-ml-1432521824"></a>
### cl_visedicts

```ml
cl_visedicts
```

Tracks the module-level cl visedicts state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L158)

<a id="global-global-miniquake-render-original-cnttextures-cnttextures-src-miniquake-render-original-ml-447325524"></a>
### cnttextures

```ml
cnttextures
```

Tracks the module-level cnttextures state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L64)

<a id="function-function-miniquake-render-original-compatappendefrag-function-compatappendefrag-leafindex-src-miniquake-render-original-ml-1580191222"></a>
### compatAppendEfrag

```ml
function compatAppendEfrag(leafIndex)
```

Implements the `compatAppendEfrag` operation for `miniquake.render.original` (compat append efrag).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L347)

<a id="function-function-miniquake-render-original-compatboolcvar-function-compatboolcvar-name-fallback-src-miniquake-render-original-ml-1563614305"></a>
### compatBoolCvar

```ml
function compatBoolCvar(name, fallback)
```

Implements the `compatBoolCvar` operation for `miniquake.render.original` (compat bool cvar).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L175)

<a id="function-function-miniquake-render-original-compatcollectvisibleefrags-function-compatcollectvisibleefrags-src-miniquake-render-original-ml-108252684"></a>
### compatCollectVisibleEfrags

```ml
function compatCollectVisibleEfrags()
```

Report whether compat collect visible efrags holds for the active state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L465)

<a id="function-function-miniquake-render-original-compatcvarvalue-function-compatcvarvalue-name-fallback-src-miniquake-render-original-ml-1341382095"></a>
### compatCvarValue

```ml
function compatCvarValue(name, fallback)
```

Return compat cvar value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L165)

<a id="function-function-miniquake-render-original-compatensureefragstate-function-compatensureefragstate-src-miniquake-render-original-ml-1428482588"></a>
### compatEnsureEfragState

```ml
function compatEnsureEfragState()
```

----------------------------------------------------------------------------- gl_refrag.c -----------------------------------------------------------------------------


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L281)

<a id="function-function-miniquake-render-original-compatenvmappath-function-compatenvmappath-index-src-miniquake-render-original-ml-311642912"></a>
### compatEnvmapPath

```ml
function compatEnvmapPath(index)
```

Return compat envmap path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L938)

<a id="function-function-miniquake-render-original-compatmodelbounds-function-compatmodelbounds-ent-src-miniquake-render-original-ml-1461555893"></a>
### compatModelBounds

```ml
function compatModelBounds(ent)
```

Implements the `compatModelBounds` operation for `miniquake.render.original` (compat model bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ent` | `dynamic` | — | The ent input consumed by `compatModelBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L387)

<a id="function-function-miniquake-render-original-compatstorereference-function-compatstorereference-reference-output-src-miniquake-render-original-ml-1099961752"></a>
### compatStoreReference

```ml
function compatStoreReference(reference, output)
```

Implements the `compatStoreReference` operation for `miniquake.render.original` (compat store reference).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reference` | `dynamic` | — | The reference input consumed by `compatStoreReference`. |
| `output` | `dynamic` | — | Destination that receives the compatibility reference. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L425)

<a id="function-function-miniquake-render-original-compattranslaterange-function-compattranslaterange-table-destination-source-src-miniquake-render-original-ml-1084543593"></a>
### compatTranslateRange

```ml
function compatTranslateRange(table, destination, source)
```

Implements the `compatTranslateRange` operation for `miniquake.render.original` (compat translate range).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | The table input consumed by `compatTranslateRange`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L993)

<a id="function-function-miniquake-render-original-compatvector-function-compatvector-value-src-miniquake-render-original-ml-576374501"></a>
### compatVector

```ml
function compatVector(value)
```

Return compat vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `compatVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L181)

<a id="global-global-miniquake-render-original-currententity-currententity-src-miniquake-render-original-ml-1763117124"></a>
### currententity

```ml
currententity
```

Tracks the module-level currententity state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L47)

<a id="global-global-miniquake-render-original-currenttexture-currenttexture-src-miniquake-render-original-ml-1300211060"></a>
### currenttexture

```ml
currenttexture
```

Tracks the module-level currenttexture state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L62)

<a id="function-function-miniquake-render-original-d-flushcaches-function-d-flushcaches-src-miniquake-render-original-ml-439781540"></a>
### D_FlushCaches

```ml
function D_FlushCaches()
```

Mirror Quake's D_FlushCaches routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L1107)

- [miniquake.render.original.EfragRef](Type-miniquake-render-original-efragref-983215654.md) — struct
<a id="global-global-miniquake-render-original-envmap-envmap-src-miniquake-render-original-ml-1356253774"></a>
### envmap

```ml
envmap
```

Tracks the module-level envmap state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L60)

<a id="global-global-miniquake-render-original-frustum-frustum-src-miniquake-render-original-ml-1431408764"></a>
### frustum

```ml
frustum
```

Tracks the module-level frustum state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L49)

<a id="global-global-miniquake-render-original-mirror-mirror-src-miniquake-render-original-ml-1060522634"></a>
### mirror

```ml
mirror
```

Tracks the module-level mirror state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L72)

<a id="global-global-miniquake-render-original-mirror-plane-mirror-plane-src-miniquake-render-original-ml-370008232"></a>
### mirror_plane

```ml
mirror_plane
```

Tracks the module-level mirror plane state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L74)

<a id="global-global-miniquake-render-original-mirrortexturenum-mirrortexturenum-src-miniquake-render-original-ml-518610576"></a>
### mirrortexturenum

```ml
mirrortexturenum
```

Tracks the module-level mirrortexturenum state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L70)

<a id="global-global-miniquake-render-original-modelorg-modelorg-src-miniquake-render-original-ml-700567718"></a>
### modelorg

```ml
modelorg
```

Tracks the module-level modelorg state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L43)

<a id="function-function-miniquake-render-original-mygluperspective-function-mygluperspective-fovy-aspect-znear-zfar-src-miniquake-render-original-ml-401523361"></a>
### MYgluPerspective

```ml
function MYgluPerspective(fovy, aspect, zNear, zFar)
```

Implements the `MYgluPerspective` operation for `miniquake.render.original` (m yglu perspective).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fovy` | `dynamic` | — | The fovy input consumed by `MYgluPerspective`. |
| `aspect` | `dynamic` | — | The aspect input consumed by `MYgluPerspective`. |
| `zNear` | `dynamic` | — | The z near input consumed by `MYgluPerspective`. |
| `zFar` | `dynamic` | — | The z far input consumed by `MYgluPerspective`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L726)

<a id="global-global-miniquake-render-original-particletexture-particletexture-src-miniquake-render-original-ml-1533119184"></a>
### particletexture

```ml
particletexture
```

Tracks the module-level particletexture state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L66)

<a id="global-global-miniquake-render-original-playertextures-playertextures-src-miniquake-render-original-ml-2012982622"></a>
### playertextures

```ml
playertextures
```

Tracks the module-level playertextures state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L68)

<a id="function-function-miniquake-render-original-r-addefrags-function-r-addefrags-ent-src-miniquake-render-original-ml-1789842581"></a>
### R_AddEfrags

```ml
function R_AddEfrags(ent)
```

Apply the Quake-compatible r add efrags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ent` | `dynamic` | — | The ent input consumed by `R_AddEfrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L406)

<a id="global-global-miniquake-render-original-r-cache-thrash-r-cache-thrash-src-miniquake-render-original-ml-82535964"></a>
### r_cache_thrash

```ml
r_cache_thrash
```

Tracks the module-level r cache thrash state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L41)

<a id="function-function-miniquake-render-original-r-clear-function-r-clear-src-miniquake-render-original-ml-1251777252"></a>
### R_Clear

```ml
function R_Clear()
```

Apply the Quake-compatible r clear behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L790)

<a id="function-function-miniquake-render-original-r-configurecompatibility-function-r-configurecompatibility-renderer-entityrenderer-viewstate-player-client-server-particles-temporaryentities-cvars-gamedirectory-width-height-currenttime-realtime-frametime-src-miniquake-render-original-ml-1163597785"></a>
### R_ConfigureCompatibility

```ml
function R_ConfigureCompatibility(renderer, entityRenderer, viewState, player, client, server, particles, temporaryEntities, cvars, gameDirectory, width, height, currentTime, realtime, frameTime)
```

Apply the Quake-compatible r configure compatibility behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `entityRenderer` | `dynamic` | — | The entity renderer input consumed by `R_ConfigureCompatibility`. |
| `viewState` | `dynamic` | — | Mutable state used by `R_ConfigureCompatibility`. |
| `player` | `dynamic` | — | The player input consumed by `R_ConfigureCompatibility`. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `particles` | `dynamic` | — | The particles input consumed by `R_ConfigureCompatibility`. |
| `temporaryEntities` | `dynamic` | — | The temporary entities input consumed by `R_ConfigureCompatibility`. |
| `cvars` | `dynamic` | — | The cvars input consumed by `R_ConfigureCompatibility`. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L202)

<a id="function-function-miniquake-render-original-r-cullbox-function-r-cullbox-mins-maxs-src-miniquake-render-original-ml-909575958"></a>
### R_CullBox

```ml
function R_CullBox(mins, maxs)
```

----------------------------------------------------------------------------- gl_rmain.c -----------------------------------------------------------------------------

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `R_CullBox`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `R_CullBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L528)

<a id="function-function-miniquake-render-original-r-drawaliasmodel-function-r-drawaliasmodel-entity-src-miniquake-render-original-ml-931431331"></a>
### R_DrawAliasModel

```ml
function R_DrawAliasModel(entity)
```

Apply the Quake-compatible r draw alias model behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L574)

<a id="function-function-miniquake-render-original-r-drawentitiesonlist-function-r-drawentitiesonlist-src-miniquake-render-original-ml-110110852"></a>
### R_DrawEntitiesOnList

```ml
function R_DrawEntitiesOnList()
```

Apply the Quake-compatible r draw entities on list behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L594)

<a id="function-function-miniquake-render-original-r-drawspritemodel-function-r-drawspritemodel-entity-src-miniquake-render-original-ml-1095716549"></a>
### R_DrawSpriteModel

```ml
function R_DrawSpriteModel(entity)
```

Apply the Quake-compatible r draw sprite model behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L562)

<a id="function-function-miniquake-render-original-r-drawviewmodel-function-r-drawviewmodel-src-miniquake-render-original-ml-1644640050"></a>
### R_DrawViewModel

```ml
function R_DrawViewModel()
```

Apply the Quake-compatible r draw view model behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L617)

<a id="global-global-miniquake-render-original-r-entorigin-r-entorigin-src-miniquake-render-original-ml-388291228"></a>
### r_entorigin

```ml
r_entorigin
```

Tracks the module-level r entorigin state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L45)

<a id="function-function-miniquake-render-original-r-envmap-f-function-r-envmap-f-src-miniquake-render-original-ml-1713779836"></a>
### R_Envmap_f

```ml
function R_Envmap_f()
```

Apply the Quake-compatible r envmap f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L945)

<a id="function-function-miniquake-render-original-r-getspriteframe-function-r-getspriteframe-entity-src-miniquake-render-original-ml-862359587"></a>
### R_GetSpriteFrame

```ml
function R_GetSpriteFrame(entity)
```

Apply the Quake-compatible r get sprite frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L550)

<a id="function-function-miniquake-render-original-r-init-function-r-init-src-miniquake-render-original-ml-460424256"></a>
### R_Init

```ml
function R_Init()
```

Apply the Quake-compatible r init behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L983)

<a id="function-function-miniquake-render-original-r-initparticletexture-function-r-initparticletexture-src-miniquake-render-original-ml-1564584180"></a>
### R_InitParticleTexture

```ml
function R_InitParticleTexture()
```

Implements the `R_InitParticleTexture` operation for `miniquake.render.original` (r init particle texture).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L900)

<a id="function-function-miniquake-render-original-r-inittextures-function-r-inittextures-src-miniquake-render-original-ml-1301250216"></a>
### R_InitTextures

```ml
function R_InitTextures()
```

----------------------------------------------------------------------------- gl_rmisc.c -----------------------------------------------------------------------------


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L868)

<a id="function-function-miniquake-render-original-r-mirror-function-r-mirror-src-miniquake-render-original-ml-807341568"></a>
### R_Mirror

```ml
function R_Mirror()
```

Apply the Quake-compatible r mirror behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L823)

<a id="function-function-miniquake-render-original-r-newmap-function-r-newmap-src-miniquake-render-original-ml-1974479748"></a>
### R_NewMap

```ml
function R_NewMap()
```

Apply the Quake-compatible r new map behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L1047)

<a id="global-global-miniquake-render-original-r-notexture-mip-r-notexture-mip-src-miniquake-render-original-ml-1706967300"></a>
### r_notexture_mip

```ml
r_notexture_mip
```

Tracks the module-level r notexture mip state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L88)

<a id="global-global-miniquake-render-original-r-notexture-mips-r-notexture-mips-src-miniquake-render-original-ml-1568230570"></a>
### r_notexture_mips

```ml
r_notexture_mips
```

Tracks the module-level r notexture mips state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L90)

<a id="global-global-miniquake-render-original-r-oldviewleaf-r-oldviewleaf-src-miniquake-render-original-ml-537987196"></a>
### r_oldviewleaf

```ml
r_oldviewleaf
```

Tracks the module-level r oldviewleaf state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L86)

<a id="global-global-miniquake-render-original-r-origin-r-origin-src-miniquake-render-original-ml-1005239802"></a>
### r_origin

```ml
r_origin
```

Tracks the module-level r origin state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L82)

<a id="function-function-miniquake-render-original-r-polyblend-function-r-polyblend-src-miniquake-render-original-ml-394932048"></a>
### R_PolyBlend

```ml
function R_PolyBlend()
```

Apply the Quake-compatible r poly blend behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L625)

<a id="function-function-miniquake-render-original-r-removeefrags-function-r-removeefrags-ent-src-miniquake-render-original-ml-1106987749"></a>
### R_RemoveEfrags

```ml
function R_RemoveEfrags(ent)
```

Apply the Quake-compatible r remove efrags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ent` | `dynamic` | — | The ent input consumed by `R_RemoveEfrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L324)

<a id="function-function-miniquake-render-original-r-renderscene-function-r-renderscene-src-miniquake-render-original-ml-729884606"></a>
### R_RenderScene

```ml
function R_RenderScene()
```

Apply the Quake-compatible r render scene behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L771)

<a id="function-function-miniquake-render-original-r-renderview-function-r-renderview-src-miniquake-render-original-ml-565563676"></a>
### R_RenderView

```ml
function R_RenderView()
```

Apply the Quake-compatible r render view behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L849)

<a id="function-function-miniquake-render-original-r-rotateforentity-function-r-rotateforentity-entity-src-miniquake-render-original-ml-956439999"></a>
### R_RotateForEntity

```ml
function R_RotateForEntity(entity)
```

Apply the Quake-compatible r rotate for entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L539)

<a id="function-function-miniquake-render-original-r-setfrustum-function-r-setfrustum-src-miniquake-render-original-ml-696595064"></a>
### R_SetFrustum

```ml
function R_SetFrustum()
```

Apply the Quake-compatible r set frustum behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L668)

<a id="function-function-miniquake-render-original-r-setupframe-function-r-setupframe-src-miniquake-render-original-ml-601306264"></a>
### R_SetupFrame

```ml
function R_SetupFrame()
```

Apply the Quake-compatible r setup frame behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L700)

<a id="function-function-miniquake-render-original-r-setupgl-function-r-setupgl-src-miniquake-render-original-ml-1987242826"></a>
### R_SetupGL

```ml
function R_SetupGL()
```

Apply the Quake-compatible r setup gl behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L739)

<a id="function-function-miniquake-render-original-r-splitentityonnode-function-r-splitentityonnode-node-src-miniquake-render-original-ml-2137772994"></a>
### R_SplitEntityOnNode

```ml
function R_SplitEntityOnNode(node)
```

Apply the Quake-compatible r split entity on node behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | The node input consumed by `R_SplitEntityOnNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L363)

<a id="function-function-miniquake-render-original-r-storeefrags-function-r-storeefrags-ppefrag-src-miniquake-render-original-ml-764549459"></a>
### R_StoreEfrags

```ml
function R_StoreEfrags(ppefrag)
```

Apply the Quake-compatible r store efrags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ppefrag` | `dynamic` | — | The ppefrag input consumed by `R_StoreEfrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L442)

<a id="function-function-miniquake-render-original-r-timerefresh-f-function-r-timerefresh-f-src-miniquake-render-original-ml-1830642492"></a>
### R_TimeRefresh_f

```ml
function R_TimeRefresh_f()
```

Apply the Quake-compatible r time refresh f behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L1085)

<a id="function-function-miniquake-render-original-r-translateplayerskin-function-r-translateplayerskin-playernum-src-miniquake-render-original-ml-1186782941"></a>
### R_TranslatePlayerSkin

```ml
function R_TranslatePlayerSkin(playernum)
```

Apply the Quake-compatible r translate player skin behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playernum` | `dynamic` | — | The playernum input consumed by `R_TranslatePlayerSkin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L1006)

<a id="global-global-miniquake-render-original-r-viewleaf-r-viewleaf-src-miniquake-render-original-ml-1740850844"></a>
### r_viewleaf

```ml
r_viewleaf
```

Tracks the module-level r viewleaf state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L84)

<a id="global-global-miniquake-render-original-r-worldentity-r-worldentity-src-miniquake-render-original-ml-1127907132"></a>
### r_worldentity

```ml
r_worldentity
```

Tracks the module-level r worldentity state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L39)

<a id="global-global-miniquake-render-original-rcompataddentity-rcompataddentity-src-miniquake-render-original-ml-1570978308"></a>
### rCompatAddEntity

```ml
rCompatAddEntity
```

Tracks the module-level r compat add entity state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L152)

<a id="global-global-miniquake-render-original-rcompatclient-rcompatclient-src-miniquake-render-original-ml-865316836"></a>
### rCompatClient

```ml
rCompatClient
```

Tracks the module-level r compat client state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L102)

<a id="global-global-miniquake-render-original-rcompatcvars-rcompatcvars-src-miniquake-render-original-ml-1727390722"></a>
### rCompatCvars

```ml
rCompatCvars
```

Tracks the module-level r compat cvars state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L110)

<a id="global-global-miniquake-render-original-rcompatdepthmax-rcompatdepthmax-src-miniquake-render-original-ml-1035040612"></a>
### rCompatDepthMax

```ml
rCompatDepthMax
```

Tracks the module-level r compat depth max state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L132)

<a id="global-global-miniquake-render-original-rcompatdepthmin-rcompatdepthmin-src-miniquake-render-original-ml-783495092"></a>
### rCompatDepthMin

```ml
rCompatDepthMin
```

Tracks the module-level r compat depth min state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L130)

<a id="global-global-miniquake-render-original-rcompatdrawentities-rcompatdrawentities-src-miniquake-render-original-ml-1290785468"></a>
### rCompatDrawEntities

```ml
rCompatDrawEntities
```

Tracks the module-level r compat draw entities state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L126)

<a id="global-global-miniquake-render-original-rcompatdrawviewmodel-rcompatdrawviewmodel-src-miniquake-render-original-ml-2039635788"></a>
### rCompatDrawViewModel

```ml
rCompatDrawViewModel
```

Tracks the module-level r compat draw view model state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L128)

<a id="global-global-miniquake-render-original-rcompatefragmodel-rcompatefragmodel-src-miniquake-render-original-ml-941282696"></a>
### rCompatEfragModel

```ml
rCompatEfragModel
```

Tracks the module-level r compat efrag model state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L142)

<a id="global-global-miniquake-render-original-rcompatefragoriginx-rcompatefragoriginx-src-miniquake-render-original-ml-1376672232"></a>
### rCompatEfragOriginX

```ml
rCompatEfragOriginX
```

Tracks the module-level r compat efrag origin x state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L144)

<a id="global-global-miniquake-render-original-rcompatefragoriginy-rcompatefragoriginy-src-miniquake-render-original-ml-1133694868"></a>
### rCompatEfragOriginY

```ml
rCompatEfragOriginY
```

Tracks the module-level r compat efrag origin y state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L146)

<a id="global-global-miniquake-render-original-rcompatefragoriginz-rcompatefragoriginz-src-miniquake-render-original-ml-1124190944"></a>
### rCompatEfragOriginZ

```ml
rCompatEfragOriginZ
```

Tracks the module-level r compat efrag origin z state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L148)

<a id="global-global-miniquake-render-original-rcompatefragtopnode-rcompatefragtopnode-src-miniquake-render-original-ml-1437397876"></a>
### rCompatEfragTopNode

```ml
rCompatEfragTopNode
```

Tracks the module-level r compat efrag top node state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L150)

<a id="global-global-miniquake-render-original-rcompatefragvalid-rcompatefragvalid-src-miniquake-render-original-ml-2145816396"></a>
### rCompatEfragValid

```ml
rCompatEfragValid
```

Tracks the module-level r compat efrag valid state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L140)

<a id="global-global-miniquake-render-original-rcompatentityefrags-rcompatentityefrags-src-miniquake-render-original-ml-1590610916"></a>
### rCompatEntityEfrags

```ml
rCompatEntityEfrags
```

Tracks the module-level r compat entity efrags state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L138)

<a id="global-global-miniquake-render-original-rcompatentitymaxs-rcompatentitymaxs-src-miniquake-render-original-ml-1241666984"></a>
### rCompatEntityMaxs

```ml
rCompatEntityMaxs
```

Tracks the module-level r compat entity maxs state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L156)

<a id="global-global-miniquake-render-original-rcompatentitymins-rcompatentitymins-src-miniquake-render-original-ml-294071836"></a>
### rCompatEntityMins

```ml
rCompatEntityMins
```

Tracks the module-level r compat entity mins state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L154)

<a id="global-global-miniquake-render-original-rcompatentityrenderer-rcompatentityrenderer-src-miniquake-render-original-ml-1129528748"></a>
### rCompatEntityRenderer

```ml
rCompatEntityRenderer
```

Tracks the module-level r compat entity renderer state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L96)

<a id="global-global-miniquake-render-original-rcompatframetime-rcompatframetime-src-miniquake-render-original-ml-1621069476"></a>
### rCompatFrameTime

```ml
rCompatFrameTime
```

Tracks the module-level r compat frame time state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L122)

<a id="global-global-miniquake-render-original-rcompatgamedirectory-rcompatgamedirectory-src-miniquake-render-original-ml-1985718774"></a>
### rCompatGameDirectory

```ml
rCompatGameDirectory
```

Tracks the module-level r compat game directory state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L112)

<a id="global-global-miniquake-render-original-rcompatheight-rcompatheight-src-miniquake-render-original-ml-314106748"></a>
### rCompatHeight

```ml
rCompatHeight
```

Tracks the module-level r compat height state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L116)

<a id="global-global-miniquake-render-original-rcompatleafefrags-rcompatleafefrags-src-miniquake-render-original-ml-1885293036"></a>
### rCompatLeafEfrags

```ml
rCompatLeafEfrags
```

Tracks the module-level r compat leaf efrags state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L136)

<a id="global-global-miniquake-render-original-rcompatparticles-rcompatparticles-src-miniquake-render-original-ml-271929638"></a>
### rCompatParticles

```ml
rCompatParticles
```

Tracks the module-level r compat particles state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L106)

<a id="global-global-miniquake-render-original-rcompatparticletexture-rcompatparticletexture-src-miniquake-render-original-ml-1093860066"></a>
### rCompatParticleTexture

```ml
rCompatParticleTexture
```

Tracks the module-level r compat particle texture state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L92)

<a id="global-global-miniquake-render-original-rcompatplayer-rcompatplayer-src-miniquake-render-original-ml-906572752"></a>
### rCompatPlayer

```ml
rCompatPlayer
```

Tracks the module-level r compat player state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L100)

<a id="global-global-miniquake-render-original-rcompatrealtime-rcompatrealtime-src-miniquake-render-original-ml-254008756"></a>
### rCompatRealtime

```ml
rCompatRealtime
```

Tracks the module-level r compat realtime state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L120)

<a id="global-global-miniquake-render-original-rcompatrenderer-rcompatrenderer-src-miniquake-render-original-ml-303605796"></a>
### rCompatRenderer

```ml
rCompatRenderer
```

Tracks the module-level r compat renderer state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L94)

<a id="global-global-miniquake-render-original-rcompatserver-rcompatserver-src-miniquake-render-original-ml-1059344668"></a>
### rCompatServer

```ml
rCompatServer
```

Tracks the module-level r compat server state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L104)

<a id="global-global-miniquake-render-original-rcompattemporary-rcompattemporary-src-miniquake-render-original-ml-1775961810"></a>
### rCompatTemporary

```ml
rCompatTemporary
```

Tracks the module-level r compat temporary state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L108)

<a id="global-global-miniquake-render-original-rcompattime-rcompattime-src-miniquake-render-original-ml-611232572"></a>
### rCompatTime

```ml
rCompatTime
```

Tracks the module-level r compat time state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L118)

<a id="global-global-miniquake-render-original-rcompattrickframe-rcompattrickframe-src-miniquake-render-original-ml-1816276996"></a>
### rCompatTrickFrame

```ml
rCompatTrickFrame
```

Tracks the module-level r compat trick frame state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L134)

<a id="global-global-miniquake-render-original-rcompatview-rcompatview-src-miniquake-render-original-ml-1344428144"></a>
### rCompatView

```ml
rCompatView
```

Tracks the module-level r compat view state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L98)

<a id="global-global-miniquake-render-original-rcompatviewentity-rcompatviewentity-src-miniquake-render-original-ml-1879666876"></a>
### rCompatViewEntity

```ml
rCompatViewEntity
```

Tracks the module-level r compat view entity state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L124)

<a id="global-global-miniquake-render-original-rcompatwidth-rcompatwidth-src-miniquake-render-original-ml-977477660"></a>
### rCompatWidth

```ml
rCompatWidth
```

Tracks the module-level r compat width state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L114)

<a id="function-function-miniquake-render-original-signbitsforplane-function-signbitsforplane-plane-src-miniquake-render-original-ml-528951818"></a>
### SignbitsForPlane

```ml
function SignbitsForPlane(plane)
```

Implements the `SignbitsForPlane` operation for `miniquake.render.original` (signbits for plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `SignbitsForPlane`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L659)

<a id="global-global-miniquake-render-original-vpn-vpn-src-miniquake-render-original-ml-945809676"></a>
### vpn

```ml
vpn
```

Tracks the module-level vpn state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L78)

<a id="global-global-miniquake-render-original-vright-vright-src-miniquake-render-original-ml-20938236"></a>
### vright

```ml
vright
```

Tracks the module-level vright state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L80)

<a id="global-global-miniquake-render-original-vup-vup-src-miniquake-render-original-ml-175436632"></a>
### vup

```ml
vup
```

Tracks the module-level vup state owned by `miniquake.render.original`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L76)
