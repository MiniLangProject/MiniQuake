# `src/miniquake/render/entities.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.entities`](Package-miniquake-render-entities-1613753804.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/model_registry.ml` as `modelRegistry` → [src/miniquake/model_registry.ml](File-src-miniquake-model-registry-ml-363800801.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/optimization_baseline.ml` as `optBaseline` → [src/miniquake/optimization_baseline.ml](File-src-miniquake-optimization-baseline-ml-636998107.md)
- `miniquake/render/alias_mesh.ml` as `aliasMesh` → [src/miniquake/render/alias_mesh.ml](File-src-miniquake-render-alias-mesh-ml-1136390123.md)
- `miniquake/render/draw2d.ml` as `draw2d` → [src/miniquake/render/draw2d.ml](File-src-miniquake-render-draw2d-ml-1547120567.md)
- `miniquake/render/enhanced.ml` as `enhanced` → [src/miniquake/render/enhanced.ml](File-src-miniquake-render-enhanced-ml-802793533.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/ray_shadow.ml` as `rayShadow` → [src/miniquake/render/ray_shadow.ml](File-src-miniquake-render-ray-shadow-ml-233970536.md)
- `miniquake/render/world.ml` as `worldRenderer` → [src/miniquake/render/world.ml](File-src-miniquake-render-world-ml-1647521183.md)
- `miniquake/render_ui_contract.ml` as `renderUiContract` → [src/miniquake/render_ui_contract.ml](File-src-miniquake-render-ui-contract-ml-1308372980.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="global-global-miniquake-render-entities-aliasaffinemodels-aliasaffinemodels-src-miniquake-render-entities-ml-1600953740"></a>
### aliasAffineModels

```ml
aliasAffineModels
```

Tracks the module-level alias affine models state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L45)

<a id="global-global-miniquake-render-entities-aliasdoubleeyes-aliasdoubleeyes-src-miniquake-render-entities-ml-538561264"></a>
### aliasDoubleEyes

```ml
aliasDoubleEyes
```

Tracks the module-level alias double eyes state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L53)

<a id="function-function-miniquake-render-entities-aliasframe-function-aliasframe-source-framenumber-time-src-miniquake-render-entities-ml-116289158"></a>
### aliasFrame

```ml
function aliasFrame(source, frameNumber, time)
```

Implements the `aliasFrame` operation for `miniquake.render.entities` (alias frame).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `frameNumber` | `dynamic` | — | The frame number input consumed by `aliasFrame`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L523)

<a id="global-global-miniquake-render-entities-aliaslightingscratch-aliaslightingscratch-src-miniquake-render-entities-ml-1325110896"></a>
### aliasLightingScratch

```ml
aliasLightingScratch
```

Tracks the module-level alias lighting scratch state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L89)

<a id="function-function-miniquake-render-entities-aliasmodelcastsshadow-function-aliasmodelcastsshadow-model-src-miniquake-render-entities-ml-1046170163"></a>
### aliasModelCastsShadow

```ml
function aliasModelCastsShadow(model)
```

Return whether an alias model represents opaque physical geometry. Flames and beam/light effects are alias MDLs in retail Quake rather than sprites; projecting them created bright duplicate torches and energy streaks on the receiver floor on backends that defer fixed-function texture state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L750)

<a id="global-global-miniquake-render-entities-aliasnocolors-aliasnocolors-src-miniquake-render-entities-ml-1497494388"></a>
### aliasNoColors

```ml
aliasNoColors
```

Tracks the module-level alias no colors state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L51)

<a id="function-function-miniquake-render-entities-aliasposeblend-function-aliasposeblend-source-entity-currentframe-time-viewmodel-src-miniquake-render-entities-ml-318922025"></a>
### aliasPoseBlend

```ml
function aliasPoseBlend(source, entity, currentFrame, time, viewModel)
```

Return [previous pose, current pose, blend fraction] for one render entity. Networked Quake changes MDL frame numbers at the 10 Hz server cadence; this short history removes visible pose stepping without changing simulation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `currentFrame` | `dynamic` | — | The current frame input consumed by `aliasPoseBlend`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `viewModel` | `dynamic` | — | The view model input consumed by `aliasPoseBlend`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L547)

<a id="global-global-miniquake-render-entities-aliasposechangetimes-aliasposechangetimes-src-miniquake-render-entities-ml-1545685226"></a>
### aliasPoseChangeTimes

```ml
aliasPoseChangeTimes
```

Tracks the module-level alias pose change times state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L63)

<a id="global-global-miniquake-render-entities-aliasposecurrent-aliasposecurrent-src-miniquake-render-entities-ml-1142184460"></a>
### aliasPoseCurrent

```ml
aliasPoseCurrent
```

Tracks the module-level alias pose current state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L59)

<a id="global-global-miniquake-render-entities-aliasposeinterpolation-aliasposeinterpolation-src-miniquake-render-entities-ml-890997930"></a>
### aliasPoseInterpolation

```ml
aliasPoseInterpolation
```

Tracks the module-level alias pose interpolation state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L55)

<a id="global-global-miniquake-render-entities-aliasposemodels-aliasposemodels-src-miniquake-render-entities-ml-1545313020"></a>
### aliasPoseModels

```ml
aliasPoseModels
```

Tracks the module-level alias pose models state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L61)

<a id="global-global-miniquake-render-entities-aliasposeprevious-aliasposeprevious-src-miniquake-render-entities-ml-886188200"></a>
### aliasPosePrevious

```ml
aliasPosePrevious
```

Tracks the module-level alias pose previous state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L57)

<a id="function-function-miniquake-render-entities-aliasrenderingconfiguration-function-aliasrenderingconfiguration-src-miniquake-render-entities-ml-862701768"></a>
### AliasRenderingConfiguration

```ml
function AliasRenderingConfiguration()
```

Implements the `AliasRenderingConfiguration` operation for `miniquake.render.entities` (alias rendering configuration).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L163)

<a id="function-function-miniquake-render-entities-aliasshade-function-aliasshade-model-entity-time-viewmodel-src-miniquake-render-entities-ml-1532725363"></a>
### aliasShade

```ml
function aliasShade(model, entity, time, viewModel)
```

Implements the `aliasShade` operation for `miniquake.render.entities` (alias shade).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `viewModel` | `dynamic` | — | The view model input consumed by `aliasShade`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L626)

<a id="global-global-miniquake-render-entities-aliasshadecacheambient-aliasshadecacheambient-src-miniquake-render-entities-ml-1045814674"></a>
### aliasShadeCacheAmbient

```ml
aliasShadeCacheAmbient
```

Tracks the module-level alias shade cache ambient state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L83)

<a id="global-global-miniquake-render-entities-aliasshadecachecolormap-aliasshadecachecolormap-src-miniquake-render-entities-ml-875612564"></a>
### aliasShadeCacheColormap

```ml
aliasShadeCacheColormap
```

Tracks the module-level alias shade cache colormap state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L71)

<a id="global-global-miniquake-render-entities-aliasshadecachemodel-aliasshadecachemodel-src-miniquake-render-entities-ml-2139185116"></a>
### aliasShadeCacheModel

```ml
aliasShadeCacheModel
```

Tracks the module-level alias shade cache model state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L69)

<a id="global-global-miniquake-render-entities-aliasshadecacheoriginx-aliasshadecacheoriginx-src-miniquake-render-entities-ml-884954898"></a>
### aliasShadeCacheOriginX

```ml
aliasShadeCacheOriginX
```

Tracks the module-level alias shade cache origin x state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L75)

<a id="global-global-miniquake-render-entities-aliasshadecacheoriginy-aliasshadecacheoriginy-src-miniquake-render-entities-ml-1671969272"></a>
### aliasShadeCacheOriginY

```ml
aliasShadeCacheOriginY
```

Tracks the module-level alias shade cache origin y state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L77)

<a id="global-global-miniquake-render-entities-aliasshadecacheoriginz-aliasshadecacheoriginz-src-miniquake-render-entities-ml-573962386"></a>
### aliasShadeCacheOriginZ

```ml
aliasShadeCacheOriginZ
```

Tracks the module-level alias shade cache origin z state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L79)

<a id="global-global-miniquake-render-entities-aliasshadecachereceiverhit-aliasshadecachereceiverhit-src-miniquake-render-entities-ml-765620694"></a>
### aliasShadeCacheReceiverHit

```ml
aliasShadeCacheReceiverHit
```

Tracks the module-level alias shade cache receiver hit state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L87)

<a id="global-global-miniquake-render-entities-aliasshadecacheshade-aliasshadecacheshade-src-miniquake-render-entities-ml-677486660"></a>
### aliasShadeCacheShade

```ml
aliasShadeCacheShade
```

Tracks the module-level alias shade cache shade state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L81)

<a id="global-global-miniquake-render-entities-aliasshadecachespot-aliasshadecachespot-src-miniquake-render-entities-ml-773839496"></a>
### aliasShadeCacheSpot

```ml
aliasShadeCacheSpot
```

Tracks the module-level alias shade cache spot state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L85)

<a id="global-global-miniquake-render-entities-aliasshadecachestamp-aliasshadecachestamp-src-miniquake-render-entities-ml-1344687196"></a>
### aliasShadeCacheStamp

```ml
aliasShadeCacheStamp
```

Tracks the module-level alias shade cache stamp state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L67)

<a id="global-global-miniquake-render-entities-aliasshadecachevalid-aliasshadecachevalid-src-miniquake-render-entities-ml-568682962"></a>
### aliasShadeCacheValid

```ml
aliasShadeCacheValid
```

Tracks the module-level alias shade cache valid state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L65)

<a id="global-global-miniquake-render-entities-aliasshadecacheviewmodel-aliasshadecacheviewmodel-src-miniquake-render-entities-ml-1497716002"></a>
### aliasShadeCacheViewModel

```ml
aliasShadeCacheViewModel
```

Tracks the module-level alias shade cache view model state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L73)

<a id="global-global-miniquake-render-entities-aliasshadowquality-aliasshadowquality-src-miniquake-render-entities-ml-1191527290"></a>
### aliasShadowQuality

```ml
aliasShadowQuality
```

Tracks the module-level alias shadow quality state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L49)

<a id="global-global-miniquake-render-entities-aliasshadows-aliasshadows-src-miniquake-render-entities-ml-1901464718"></a>
### aliasShadows

```ml
aliasShadows
```

Tracks the module-level alias shadows state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L47)

<a id="global-global-miniquake-render-entities-aliassmoothmodels-aliassmoothmodels-src-miniquake-render-entities-ml-73197332"></a>
### aliasSmoothModels

```ml
aliasSmoothModels
```

Tracks the module-level alias smooth models state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L43)

<a id="function-function-miniquake-render-entities-aliasvertex-function-aliasvertex-source-packed-src-miniquake-render-entities-ml-423820981"></a>
### aliasVertex

```ml
function aliasVertex(source, packed)
```

Implements the `aliasVertex` operation for `miniquake.render.entities` (alias vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `packed` | `dynamic` | — | The packed input consumed by `aliasVertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L613)

<a id="function-function-miniquake-render-entities-brushmodelindex-function-brushmodelindex-name-src-miniquake-render-entities-ml-1853638361"></a>
### brushModelIndex

```ml
function brushModelIndex(name)
```

Return brush model index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L963)

<a id="function-function-miniquake-render-entities-brushrendererformodel-function-brushrendererformodel-model-src-miniquake-render-entities-ml-2061354315"></a>
### brushRendererForModel

```ml
function brushRendererForModel(model)
```

Implements the `brushRendererForModel` operation for `miniquake.render.entities` (brush renderer for model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L231)

<a id="function-function-miniquake-render-entities-brushshadowsource-function-brushshadowsource-entity-time-src-miniquake-render-entities-ml-1737256712"></a>
### brushShadowSource

```ml
function brushShadowSource(entity, time)
```

Select the dynamic light with the strongest local contribution and retain its world-space source for BSP ray projection. When no live point light reaches the object, the projector uses a stable directional fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1047)

<a id="global-global-miniquake-render-entities-brushshadowsourcescratch-brushshadowsourcescratch-src-miniquake-render-entities-ml-530698442"></a>
### brushShadowSourceScratch

```ml
brushShadowSourceScratch
```

Tracks the module-level brush shadow source scratch state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L91)

<a id="function-function-miniquake-render-entities-configurealiasrendering-function-configurealiasrendering-smoothmodels-affinemodels-shadows-nocolors-doubleeyes-src-miniquake-render-entities-ml-1194596042"></a>
### ConfigureAliasRendering

```ml
function ConfigureAliasRendering(smoothModels, affineModels, shadows, noColors, doubleEyes)
```

Update subsystem configuration for configure alias rendering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `smoothModels` | `dynamic` | — | The smooth models input consumed by `ConfigureAliasRendering`. |
| `affineModels` | `dynamic` | — | The affine models input consumed by `ConfigureAliasRendering`. |
| `shadows` | `dynamic` | — | The shadows input consumed by `ConfigureAliasRendering`. |
| `noColors` | `dynamic` | — | The no colors input consumed by `ConfigureAliasRendering`. |
| `doubleEyes` | `dynamic` | — | The double eyes input consumed by `ConfigureAliasRendering`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L140)

<a id="function-function-miniquake-render-entities-configurealiasshadowsource-function-configurealiasshadowsource-entity-enabled-lightx-lighty-lightz-src-miniquake-render-entities-ml-1998418873"></a>
### configureAliasShadowSource

```ml
function configureAliasShadowSource(entity, enabled, lightX, lightY, lightZ)
```

Transform the strongest world-space point light into the alias model's yaw-local coordinates used by the projected silhouette routine.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `lightX` | `dynamic` | — | The light x input consumed by `configureAliasShadowSource`. |
| `lightY` | `dynamic` | — | The light y input consumed by `configureAliasShadowSource`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `configureAliasShadowSource`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L732)

<a id="function-function-miniquake-render-entities-configureenhancedshadowquality-function-configureenhancedshadowquality-value-src-miniquake-render-entities-ml-425460065"></a>
### ConfigureEnhancedShadowQuality

```ml
function ConfigureEnhancedShadowQuality(value)
```

Configure the backend-neutral projected-shadow sampling level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ConfigureEnhancedShadowQuality`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L172)

<a id="function-function-miniquake-render-entities-configuremodelinterpolation-function-configuremodelinterpolation-enabled-src-miniquake-render-entities-ml-461729311"></a>
### ConfigureModelInterpolation

```ml
function ConfigureModelInterpolation(enabled)
```

Enable or disable temporal interpolation between consecutive MDL poses.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L155)

<a id="function-function-miniquake-render-entities-create-function-create-filesystem-palette-modelprecache-src-miniquake-render-entities-ml-1196645758"></a>
### create

```ml
function create(filesystem, palette, modelPrecache)
```

Implements the `create` operation for `miniquake.render.entities` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `create`. |
| `palette` | `dynamic` | — | The palette input consumed by `create`. |
| `modelPrecache` | `dynamic` | — | The model precache input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L290)

<a id="function-function-miniquake-render-entities-cycleindex-function-cycleindex-intervals-time-count-src-miniquake-render-entities-ml-65370226"></a>
### cycleIndex

```ml
function cycleIndex(intervals, time, count)
```

Return cycle index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `intervals` | `dynamic` | — | The intervals input consumed by `cycleIndex`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L506)

<a id="function-function-miniquake-render-entities-destroy-function-destroy-renderer-src-miniquake-render-entities-ml-998539563"></a>
### destroy

```ml
function destroy(renderer)
```

Implements the `destroy` operation for `miniquake.render.entities` (destroy).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1360)

<a id="function-function-miniquake-render-entities-drawalias-function-drawalias-renderer-model-entity-time-viewmodel-enhancedoverlay-src-miniquake-render-entities-ml-1607952230"></a>
### drawAlias

```ml
function drawAlias(renderer, model, entity, time, viewModel, enhancedOverlay)
```

Render alias.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `viewModel` | `dynamic` | — | The view model input consumed by `drawAlias`. |
| `enhancedOverlay` | `dynamic` | — | The enhanced overlay input consumed by `drawAlias`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L766)

<a id="function-function-miniquake-render-entities-drawbrush-function-drawbrush-worldrenderervalue-model-entity-time-src-miniquake-render-entities-ml-749389931"></a>
### drawBrush

```ml
function drawBrush(worldRendererValue, model, entity, time)
```

Render brush.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `drawBrush`. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L976)

<a id="function-function-miniquake-render-entities-drawbrushenhanced-function-drawbrushenhanced-worldrenderervalue-model-entity-time-src-miniquake-render-entities-ml-534452371"></a>
### drawBrushEnhanced

```ml
function drawBrushEnhanced(worldRendererValue, model, entity, time)
```

Render one brush entity without its classic lightmap pass so the optional additive GPU program can light the geometry exactly once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `drawBrushEnhanced`. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1003)

<a id="function-function-miniquake-render-entities-drawbrushshadow-function-drawbrushshadow-worldrenderervalue-model-entity-time-src-miniquake-render-entities-ml-2138289851"></a>
### drawBrushShadow

```ml
function drawBrushShadow(worldRendererValue, model, entity, time)
```

Render a backend-neutral soft footprint for BSP pickups, crates, doors and platforms. Sprite effects stay emissive and intentionally cast no shadow.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `drawBrushShadow`. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1101)

<a id="function-function-miniquake-render-entities-drawbrushshadowsample-function-drawbrushshadowsample-worldrenderervalue-model-entity-floorworldz-source-offsetx-offsety-contactonly-src-miniquake-render-entities-ml-2109886144"></a>
### drawBrushShadowSample

```ml
function drawBrushShadowSample(worldRendererValue, model, entity, floorWorldZ, source, offsetX, offsetY, contactOnly)
```

Draw one projected footprint sample for either an external pickup BSP or an inline moving brush model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `drawBrushShadowSample`. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `floorWorldZ` | `dynamic` | — | The floor world z input consumed by `drawBrushShadowSample`. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `drawBrushShadowSample`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `drawBrushShadowSample`. |
| `contactOnly` | `dynamic` | — | The contact only input consumed by `drawBrushShadowSample`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1078)

<a id="function-function-miniquake-render-entities-drawsprite-function-drawsprite-renderer-model-entity-viewright-viewup-time-src-miniquake-render-entities-ml-1240268413"></a>
### drawSprite

```ml
function drawSprite(renderer, model, entity, viewRight, viewUp, time)
```

Render sprite.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `viewRight` | `dynamic` | — | The view right input consumed by `drawSprite`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `drawSprite`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L907)

<a id="function-function-miniquake-render-entities-emptymodel-function-emptymodel-name-kind-src-miniquake-render-entities-ml-903149109"></a>
### emptyModel

```ml
function emptyModel(name, kind)
```

Implements the `emptyModel` operation for `miniquake.render.entities` (empty model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `kind` | `dynamic` | — | The kind input consumed by `emptyModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L214)

<a id="function-function-miniquake-render-entities-endswithinsensitive-function-endswithinsensitive-text-suffix-src-miniquake-render-entities-ml-1755173352"></a>
### endsWithInsensitive

```ml
function endsWithInsensitive(text, suffix)
```

Finalize state for ends with insensitive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `suffix` | `dynamic` | — | The suffix input consumed by `endsWithInsensitive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L198)

<a id="function-function-miniquake-render-entities-externalbrushforname-function-externalbrushforname-name-src-miniquake-render-entities-ml-1069749283"></a>
### externalBrushForName

```ml
function externalBrushForName(name)
```

Return external brush for name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L220)

<a id="global-global-miniquake-render-entities-externalbrushrenderernames-externalbrushrenderernames-src-miniquake-render-entities-ml-1809352204"></a>
### externalBrushRendererNames

```ml
externalBrushRendererNames
```

Tracks the module-level external brush renderer names state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L99)

<a id="global-global-miniquake-render-entities-externalbrushrendererroots-externalbrushrendererroots-src-miniquake-render-entities-ml-253022078"></a>
### externalBrushRendererRoots

```ml
externalBrushRendererRoots
```

Root complete external renderers (map, textures, surfaces and lightmaps) for the lifetime of the entity renderer.  These are independent BSP models and therefore are not owned by the active WorldRenderer.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L97)

<a id="function-function-miniquake-render-entities-finishenhancedentityoverlay-function-finishenhancedentityoverlay-src-miniquake-render-entities-ml-1660529984"></a>
### finishEnhancedEntityOverlay

```ml
function finishEnhancedEntityOverlay()
```

Restore compatibility blend/depth state after any enhanced entity replay, including error exits from malformed external models.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1150)

<a id="function-function-miniquake-render-entities-loadmodel-function-loadmodel-renderer-name-src-miniquake-render-entities-ml-1563714502"></a>
### loadModel

```ml
function loadModel(renderer, name)
```

Read and validate model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L240)

<a id="function-function-miniquake-render-entities-loadworldmodel-function-loadworldmodel-renderer-name-src-miniquake-render-entities-ml-1461132076"></a>
### loadWorldModel

```ml
function loadWorldModel(renderer, name)
```

Read and validate world model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L274)

<a id="constant-constant-miniquake-render-entities-model-alias-const-model-alias-2-src-miniquake-render-entities-ml-1259892623"></a>
### MODEL_ALIAS

```ml
const MODEL_ALIAS = 2
```

Defines the model alias value used by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L31)

<a id="constant-constant-miniquake-render-entities-model-brush-const-model-brush-1-src-miniquake-render-entities-ml-820274768"></a>
### MODEL_BRUSH

```ml
const MODEL_BRUSH = 1
```

Defines the model brush value used by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L29)

<a id="constant-constant-miniquake-render-entities-model-none-const-model-none-0-src-miniquake-render-entities-ml-1521453071"></a>
### MODEL_NONE

```ml
const MODEL_NONE = 0
```

Defines the model none value used by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L27)

<a id="constant-constant-miniquake-render-entities-model-sprite-const-model-sprite-3-src-miniquake-render-entities-ml-1971540958"></a>
### MODEL_SPRITE

```ml
const MODEL_SPRITE = 3
```

Defines the model sprite value used by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L33)

<a id="function-function-miniquake-render-entities-objectshadowfloorz-function-objectshadowfloorz-worldrenderervalue-entity-src-miniquake-render-entities-ml-353160047"></a>
### objectShadowFloorZ

```ml
function objectShadowFloorZ(worldRendererValue, entity)
```

Resolve a stable receiver height from the main BSP beneath an object.  A production miss must suppress the shadow: lightspot retains reusable storage and may still contain another entity's receiver from an earlier trace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `objectShadowFloorZ`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1024)

<a id="function-function-miniquake-render-entities-precache-function-precache-renderer-src-miniquake-render-entities-ml-1270980891"></a>
### precache

```ml
function precache(renderer)
```

Preload and register the the requested value asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L468)

<a id="function-function-miniquake-render-entities-render-function-render-renderer-worldrenderervalue-entities-viewentity-viewright-viewup-time-src-miniquake-render-entities-ml-1417702970"></a>
### render

```ml
function render(renderer, worldRendererValue, entities, viewEntity, viewRight, viewUp, time)
```

Implements the `render` operation for `miniquake.render.entities` (render).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `render`. |
| `entities` | `dynamic` | — | The entities input consumed by `render`. |
| `viewEntity` | `dynamic` | — | The view entity input consumed by `render`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `render`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `render`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1258)

<a id="function-function-miniquake-render-entities-renderenhancedsubmitted-function-renderenhancedsubmitted-renderer-worldrenderervalue-entities-hiddenentitynumber-time-src-miniquake-render-entities-ml-322988141"></a>
### renderEnhancedSubmitted

```ml
function renderEnhancedSubmitted(renderer, worldRendererValue, entities, hiddenEntityNumber, time)
```

Draw the entity portion of the optional additive per-pixel light layer. Sprites remain emissive/alpha-tested and intentionally do not receive it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `renderEnhancedSubmitted`. |
| `entities` | `dynamic` | — | The entities input consumed by `renderEnhancedSubmitted`. |
| `hiddenEntityNumber` | `dynamic` | — | The hidden entity number input consumed by `renderEnhancedSubmitted`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1217)

<a id="global-global-miniquake-render-entities-rendermodelregistry-rendermodelregistry-src-miniquake-render-entities-ml-1919498668"></a>
### renderModelRegistry

```ml
renderModelRegistry
```

Tracks the module-level render model registry state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L41)

<a id="function-function-miniquake-render-entities-rendersubmitted-function-rendersubmitted-renderer-worldrenderervalue-entities-hiddenentitynumber-viewright-viewup-time-src-miniquake-render-entities-ml-1011654136"></a>
### renderSubmitted

```ml
function renderSubmitted(renderer, worldRendererValue, entities, hiddenEntityNumber, viewRight, viewUp, time)
```

Render submitted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `worldRendererValue` | `dynamic` | — | The world renderer value input consumed by `renderSubmitted`. |
| `entities` | `dynamic` | — | The entities input consumed by `renderSubmitted`. |
| `hiddenEntityNumber` | `dynamic` | — | The hidden entity number input consumed by `renderSubmitted`. |
| `viewRight` | `dynamic` | — | The view right input consumed by `renderSubmitted`. |
| `viewUp` | `dynamic` | — | The view up input consumed by `renderSubmitted`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1168)

<a id="function-function-miniquake-render-entities-renderviewmodel-function-renderviewmodel-renderer-player-view-time-src-miniquake-render-entities-ml-153686046"></a>
### renderViewModel

```ml
function renderViewModel(renderer, player, view, time)
```

Render view model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `player` | `dynamic` | — | The player input consumed by `renderViewModel`. |
| `view` | `dynamic` | — | The view input consumed by `renderViewModel`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1277)

<a id="function-function-miniquake-render-entities-renderviewmodelenhanced-function-renderviewmodelenhanced-renderer-player-view-time-src-miniquake-render-entities-ml-1047207970"></a>
### renderViewModelEnhanced

```ml
function renderViewModelEnhanced(renderer, player, view, time)
```

Add per-pixel dynamic light to the first-person weapon using the same compressed depth range as the classic viewmodel draw.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `player` | `dynamic` | — | The player input consumed by `renderViewModelEnhanced`. |
| `view` | `dynamic` | — | The view input consumed by `renderViewModelEnhanced`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1335)

<a id="function-function-miniquake-render-entities-resetaliasposecache-function-resetaliasposecache-src-miniquake-render-entities-ml-1350449272"></a>
### resetAliasPoseCache

```ml
function resetAliasPoseCache()
```

Reset per-entity MDL pose history at every map/renderer transition.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L124)

<a id="function-function-miniquake-render-entities-resetaliasshadecache-function-resetaliasshadecache-src-miniquake-render-entities-ml-80601300"></a>
### resetAliasShadeCache

```ml
function resetAliasShadeCache()
```

Update module state for alias shade cache.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L102)

<a id="function-function-miniquake-render-entities-settranslatedplayertexture-function-settranslatedplayertexture-entitynumber-texture-src-miniquake-render-entities-ml-2005674529"></a>
### setTranslatedPlayerTexture

```ml
function setTranslatedPlayerTexture(entityNumber, texture)
```

Update module state for translated player texture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `setTranslatedPlayerTexture`. |
| `texture` | `dynamic` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L337)

<a id="constant-constant-miniquake-render-entities-spr-oriented-const-spr-oriented-3-src-miniquake-render-entities-ml-1471967444"></a>
### SPR_ORIENTED

```ml
const SPR_ORIENTED = 3
```

Defines the spr oriented value used by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L36)

<a id="function-function-miniquake-render-entities-spriteframeandtexture-function-spriteframeandtexture-model-entity-time-src-miniquake-render-entities-ml-1302258735"></a>
### spriteFrameAndTexture

```ml
function spriteFrameAndTexture(model, entity, time)
```

Implements the `spriteFrameAndTexture` operation for `miniquake.render.entities` (sprite frame and texture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L587)

<a id="function-function-miniquake-render-entities-startswith-function-startswith-text-prefix-src-miniquake-render-entities-ml-1348137327"></a>
### startsWith

```ml
function startsWith(text, prefix)
```

Starts s with for `miniquake.render.entities`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `prefix` | `dynamic` | — | The prefix input consumed by `startsWith`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L183)

<a id="function-function-miniquake-render-entities-synchronize-function-synchronize-renderer-modelprecache-src-miniquake-render-entities-ml-1738753001"></a>
### synchronize

```ml
function synchronize(renderer, modelPrecache)
```

Update module state for the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `modelPrecache` | `dynamic` | — | The model precache input consumed by `synchronize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L352)

<a id="function-function-miniquake-render-entities-translatedplayertexture-inline-function-translatedplayertexture-entitynumber-src-miniquake-render-entities-ml-1439982567"></a>
### translatedPlayerTexture

```ml
inline function translatedPlayerTexture(entityNumber)
```

Implements the `translatedPlayerTexture` operation for `miniquake.render.entities` (translated player texture).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `translatedPlayerTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L329)

<a id="global-global-miniquake-render-entities-translatedplayertextures-translatedplayertextures-src-miniquake-render-entities-ml-126769654"></a>
### translatedPlayerTextures

```ml
translatedPlayerTextures
```

Tracks the module-level translated player textures state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L39)

<a id="function-function-miniquake-render-entities-upload-function-upload-renderer-model-src-miniquake-render-entities-ml-756874776"></a>
### upload

```ml
function upload(renderer, model)
```

Upload the requested value to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L453)

<a id="function-function-miniquake-render-entities-uploadalias-function-uploadalias-renderer-model-src-miniquake-render-entities-ml-1747240082"></a>
### uploadAlias

```ml
function uploadAlias(renderer, model)
```

Upload alias to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L376)

<a id="function-function-miniquake-render-entities-uploadindexedtexture-function-uploadindexedtexture-width-height-pixels-palette-transparent-src-miniquake-render-entities-ml-1612458621"></a>
### uploadIndexedTexture

```ml
function uploadIndexedTexture(width, height, pixels, palette, transparent)
```

Upload indexed texture to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |
| `pixels` | `dynamic` | — | The pixels input consumed by `uploadIndexedTexture`. |
| `palette` | `dynamic` | — | The palette input consumed by `uploadIndexedTexture`. |
| `transparent` | `dynamic` | — | The transparent input consumed by `uploadIndexedTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L310)

<a id="function-function-miniquake-render-entities-uploadsprite-function-uploadsprite-renderer-model-src-miniquake-render-entities-ml-1991018592"></a>
### uploadSprite

```ml
function uploadSprite(renderer, model)
```

Upload sprite to the active renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L416)

<a id="function-function-miniquake-render-entities-viewmodeldepthrange-function-viewmodeldepthrange-depthmin-depthmax-src-miniquake-render-entities-ml-1889560870"></a>
### viewModelDepthRange

```ml
function viewModelDepthRange(depthMin, depthMax)
```

R_DrawViewModel / V_CalcRefdef. The gun is a normal alias model drawn from the view entity, with a compressed depth range so it cannot poke through nearby world surfaces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `depthMin` | `dynamic` | — | The depth min input consumed by `viewModelDepthRange`. |
| `depthMax` | `dynamic` | — | The depth max input consumed by `viewModelDepthRange`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L1267)

<a id="global-global-miniquake-render-entities-viewmodelscratch-viewmodelscratch-src-miniquake-render-entities-ml-1717391380"></a>
### viewModelScratch

```ml
viewModelScratch
```

Tracks the module-level view model scratch state owned by `miniquake.render.entities`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/entities.ml#L93)
