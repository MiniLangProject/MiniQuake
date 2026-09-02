# `src/miniquake/render/alias_mesh.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.alias_mesh`](Package-miniquake-render-alias-mesh-140120203.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `compatAliasArrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `compatAliasBytes` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/mathlib.ml` as `compatAliasMath` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `compatAliasNative` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/alias_normals.ml` as `compatAliasNormals` → [src/miniquake/render/alias_normals.ml](File-src-miniquake-render-alias-normals-ml-1036618994.md)
- `miniquake/render/gl11.ml` as `compatAliasGl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `miniquake/render/ray_shadow.ml` as `rayShadow` → [src/miniquake/render/ray_shadow.ml](File-src-miniquake-render-ray-shadow-ml-233970536.md)
- `miniquake/types.ml` as `compatAliasTypes` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="constant-constant-miniquake-render-alias-mesh-alias-batch-cache-size-const-alias-batch-cache-size-4096-src-miniquake-render-alias-mesh-ml-2140775360"></a>
### ALIAS_BATCH_CACHE_SIZE

```ml
const ALIAS_BATCH_CACHE_SIZE = 4096
```

Defines the alias batch cache size value used by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L53)

<a id="constant-constant-miniquake-render-alias-mesh-alias-mesh-cache-size-const-alias-mesh-cache-size-512-src-miniquake-render-alias-mesh-ml-708197137"></a>
### ALIAS_MESH_CACHE_SIZE

```ml
const ALIAS_MESH_CACHE_SIZE = 512
```

Defines the alias mesh cache size value used by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L51)

<a id="function-function-miniquake-render-alias-mesh-aliasbatchdata-function-aliasbatchdata-frame-mesh-src-miniquake-render-alias-mesh-ml-237056172"></a>
### aliasBatchData

```ml
function aliasBatchData(frame, mesh)
```

Return alias batch data derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `aliasBatchData`. |
| `mesh` | `dynamic` | — | The mesh input consumed by `aliasBatchData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L456)

<a id="global-global-miniquake-render-alias-mesh-aliasbatchframekeys-aliasbatchframekeys-src-miniquake-render-alias-mesh-ml-247103424"></a>
### aliasBatchFrameKeys

```ml
aliasBatchFrameKeys
```

Tracks the module-level alias batch frame keys state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L112)

<a id="global-global-miniquake-render-alias-mesh-aliasbatchmeshkeys-aliasbatchmeshkeys-src-miniquake-render-alias-mesh-ml-775324338"></a>
### aliasBatchMeshKeys

```ml
aliasBatchMeshKeys
```

Tracks the module-level alias batch mesh keys state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L114)

<a id="global-global-miniquake-render-alias-mesh-aliasbatchvalues-aliasbatchvalues-src-miniquake-render-alias-mesh-ml-1814589928"></a>
### aliasBatchValues

```ml
aliasBatchValues
```

Tracks the module-level alias batch values state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L116)

- [miniquake.render.alias_mesh.AliasMesh](Type-miniquake-render-alias-mesh-aliasmesh-139030544.md) — struct
- [miniquake.render.alias_mesh.AliasMeshCommand](Type-miniquake-render-alias-mesh-aliasmeshcommand-1592935641.md) — struct
- [miniquake.render.alias_mesh.AliasMeshVertex](Type-miniquake-render-alias-mesh-aliasmeshvertex-798395326.md) — struct
<a id="global-global-miniquake-render-alias-mesh-aliasmodel-aliasmodel-src-miniquake-render-alias-mesh-ml-802382906"></a>
### aliasmodel

```ml
aliasmodel
```

Tracks the module-level aliasmodel state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L56)

<a id="function-function-miniquake-render-alias-mesh-aliasshadedotdata-function-aliasshadedotdata-row-src-miniquake-render-alias-mesh-ml-1615749588"></a>
### aliasShadeDotData

```ml
function aliasShadeDotData(row)
```

Return alias shade dot data derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `row` | `dynamic` | — | The row input consumed by `aliasShadeDotData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L528)

<a id="global-global-miniquake-render-alias-mesh-aliasshadedotrows-aliasshadedotrows-src-miniquake-render-alias-mesh-ml-1355807908"></a>
### aliasShadeDotRows

```ml
aliasShadeDotRows
```

Tracks the module-level alias shade dot rows state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L118)

<a id="function-function-miniquake-render-alias-mesh-aliasshadowprojection-function-aliasshadowprojection-entityoriginz-lightspotz-src-miniquake-render-alias-mesh-ml-529380113"></a>
### aliasShadowProjection

```ml
function aliasShadowProjection(entityOriginZ, lightSpotZ)
```

Implements the `aliasShadowProjection` operation for `miniquake.render.alias_mesh` (alias shadow projection).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityOriginZ` | `dynamic` | — | The entity origin z input consumed by `aliasShadowProjection`. |
| `lightSpotZ` | `dynamic` | — | The light spot z input consumed by `aliasShadowProjection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L713)

<a id="global-global-miniquake-render-alias-mesh-alltris-alltris-src-miniquake-render-alias-mesh-ml-255418648"></a>
### alltris

```ml
alltris
```

Tracks the module-level alltris state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L76)

<a id="global-global-miniquake-render-alias-mesh-allverts-allverts-src-miniquake-render-alias-mesh-ml-1753936178"></a>
### allverts

```ml
allverts
```

Tracks the module-level allverts state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L74)

<a id="global-global-miniquake-render-alias-mesh-ambientlight-ambientlight-src-miniquake-render-alias-mesh-ml-476949192"></a>
### ambientlight

```ml
ambientlight
```

Tracks the module-level ambientlight state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L88)

<a id="function-function-miniquake-render-alias-mesh-buildtris-function-buildtris-src-miniquake-render-alias-mesh-ml-1221995490"></a>
### BuildTris

```ml
function BuildTris()
```

Create and initialize tris.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L317)

<a id="function-function-miniquake-render-alias-mesh-cachedmesh-function-cachedmesh-model-src-miniquake-render-alias-mesh-ml-1064938217"></a>
### cachedMesh

```ml
function cachedMesh(model)
```

Implements the `cachedMesh` operation for `miniquake.render.alias_mesh` (cached mesh).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L393)

<a id="function-function-miniquake-render-alias-mesh-clampbyte-function-clampbyte-value-src-miniquake-render-alias-mesh-ml-587176375"></a>
### clampByte

```ml
function clampByte(value)
```

Return a validated clamp byte value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `clampByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L446)

<a id="function-function-miniquake-render-alias-mesh-clearcaches-function-clearcaches-src-miniquake-render-alias-mesh-ml-1089023194"></a>
### clearCaches

```ml
function clearCaches()
```

Update module state for caches.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L121)

<a id="global-global-miniquake-render-alias-mesh-commands-commands-src-miniquake-render-alias-mesh-ml-1319031968"></a>
### commands

```ml
commands
```

Tracks the module-level commands state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L66)

<a id="function-function-miniquake-render-alias-mesh-configurealiaslighting-function-configurealiaslighting-lightvalue-ambientvalue-yaw-spot-src-miniquake-render-alias-mesh-ml-1690574579"></a>
### configureAliasLighting

```ml
function configureAliasLighting(lightValue, ambientValue, yaw, spot)
```

Update subsystem configuration for configure alias lighting.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lightValue` | `dynamic` | — | The light value input consumed by `configureAliasLighting`. |
| `ambientValue` | `dynamic` | — | The ambient value input consumed by `configureAliasLighting`. |
| `yaw` | `dynamic` | — | The yaw input consumed by `configureAliasLighting`. |
| `spot` | `dynamic` | — | The spot input consumed by `configureAliasLighting`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L165)

<a id="function-function-miniquake-render-alias-mesh-configurealiasmodel-function-configurealiasmodel-model-src-miniquake-render-alias-mesh-ml-1132469795"></a>
### configureAliasModel

```ml
function configureAliasModel(model)
```

Update subsystem configuration for configure alias model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L142)

<a id="function-function-miniquake-render-alias-mesh-configurealiasshadowpointlight-function-configurealiasshadowpointlight-enabled-x-y-z-src-miniquake-render-alias-mesh-ml-1386005138"></a>
### configureAliasShadowPointLight

```ml
function configureAliasShadowPointLight(enabled, x, y, z)
```

Select a model-local point light for physically directed projected shadows. Disabling it retains GLQuake's stable directional fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `x` | `dynamic` | — | The x input consumed by `configureAliasShadowPointLight`. |
| `y` | `dynamic` | — | The y input consumed by `configureAliasShadowPointLight`. |
| `z` | `dynamic` | — | The z input consumed by `configureAliasShadowPointLight`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L197)

<a id="global-global-miniquake-render-alias-mesh-currentaliasframe-currentaliasframe-src-miniquake-render-alias-mesh-ml-881918980"></a>
### currentAliasFrame

```ml
currentAliasFrame
```

Tracks the module-level current alias frame state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L106)

<a id="function-function-miniquake-render-alias-mesh-drawaliasmesh-function-drawaliasmesh-model-frame-mesh-src-miniquake-render-alias-mesh-ml-2050223735"></a>
### drawAliasMesh

```ml
function drawAliasMesh(model, frame, mesh)
```

Render alias mesh.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `frame` | `dynamic` | — | The frame input consumed by `drawAliasMesh`. |
| `mesh` | `dynamic` | — | The mesh input consumed by `drawAliasMesh`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L557)

<a id="function-function-miniquake-render-alias-mesh-drawaliasmeshlerped-function-drawaliasmeshlerped-model-previousframe-currentframe-fraction-mesh-src-miniquake-render-alias-mesh-ml-699463452"></a>
### drawAliasMeshLerped

```ml
function drawAliasMeshLerped(model, previousFrame, currentFrame, fraction, mesh)
```

Render a diagnostic/scalar MDL mesh interpolated between two poses. The production path performs the same blend inside the native batch bridge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `previousFrame` | `dynamic` | — | The previous frame input consumed by `drawAliasMeshLerped`. |
| `currentFrame` | `dynamic` | — | The current frame input consumed by `drawAliasMeshLerped`. |
| `fraction` | `dynamic` | — | The fraction input consumed by `drawAliasMeshLerped`. |
| `mesh` | `dynamic` | — | The mesh input consumed by `drawAliasMeshLerped`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L599)

<a id="function-function-miniquake-render-alias-mesh-drawaliasmodelbatch-function-drawaliasmodelbatch-model-frame-mesh-origin-angles-doubleeyes-smooth-src-miniquake-render-alias-mesh-ml-112553688"></a>
### drawAliasModelBatch

```ml
function drawAliasModelBatch(model, frame, mesh, origin, angles, doubleEyes, smooth)
```

Render alias model batch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `frame` | `dynamic` | — | The frame input consumed by `drawAliasModelBatch`. |
| `mesh` | `dynamic` | — | The mesh input consumed by `drawAliasModelBatch`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `doubleEyes` | `dynamic` | — | The double eyes input consumed by `drawAliasModelBatch`. |
| `smooth` | `dynamic` | — | The smooth input consumed by `drawAliasModelBatch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L647)

<a id="function-function-miniquake-render-alias-mesh-drawaliasmodelbatchlerped-function-drawaliasmodelbatchlerped-model-previousframe-currentframe-fraction-mesh-origin-angles-doubleeyes-smooth-src-miniquake-render-alias-mesh-ml-841009035"></a>
### drawAliasModelBatchLerped

```ml
function drawAliasModelBatchLerped(model, previousFrame, currentFrame, fraction, mesh, origin, angles, doubleEyes, smooth)
```

Render an interpolated alias model with one native call on every backend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `previousFrame` | `dynamic` | — | The previous frame input consumed by `drawAliasModelBatchLerped`. |
| `currentFrame` | `dynamic` | — | The current frame input consumed by `drawAliasModelBatchLerped`. |
| `fraction` | `dynamic` | — | The fraction input consumed by `drawAliasModelBatchLerped`. |
| `mesh` | `dynamic` | — | The mesh input consumed by `drawAliasModelBatchLerped`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `doubleEyes` | `dynamic` | — | The double eyes input consumed by `drawAliasModelBatchLerped`. |
| `smooth` | `dynamic` | — | The smooth input consumed by `drawAliasModelBatchLerped`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L674)

<a id="function-function-miniquake-render-alias-mesh-drawaliasshadowprojectionsampleatorigin-function-drawaliasshadowprojectionsampleatorigin-header-posenum-entityoriginz-offsetx-offsety-contactonly-src-miniquake-render-alias-mesh-ml-1904918550"></a>
### drawAliasShadowProjectionSampleAtOrigin

```ml
function drawAliasShadowProjectionSampleAtOrigin(header, posenum, entityOriginZ, offsetX, offsetY, contactOnly)
```

gl_rmain.c computes the projected height from currententity->origin[2]. The vertex coordinates below are still model-local because the entity transform is already active on the GL matrix stack.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `drawAliasShadowProjectionSampleAtOrigin`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `drawAliasShadowProjectionSampleAtOrigin`. |
| `entityOriginZ` | `dynamic` | — | The entity origin z input consumed by `drawAliasShadowProjectionSampleAtOrigin`. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `drawAliasShadowProjectionSampleAtOrigin`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `drawAliasShadowProjectionSampleAtOrigin`. |
| `contactOnly` | `dynamic` | — | The contact only input consumed by `drawAliasShadowProjectionSampleAtOrigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L727)

<a id="function-function-miniquake-render-alias-mesh-fanlength-function-fanlength-starttri-startv-src-miniquake-render-alias-mesh-ml-135476279"></a>
### FanLength

```ml
function FanLength(starttri, startv)
```

Return fan length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `starttri` | `dynamic` | — | The starttri input consumed by `FanLength`. |
| `startv` | `dynamic` | — | The startv input consumed by `FanLength`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L265)

<a id="function-function-miniquake-render-alias-mesh-framefornumber-function-framefornumber-model-framenumber-time-src-miniquake-render-alias-mesh-ml-1155905308"></a>
### frameForNumber

```ml
function frameForNumber(model, frameNumber, time)
```

Advance for number by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `frameNumber` | `dynamic` | — | The frame number input consumed by `frameForNumber`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L432)

<a id="function-function-miniquake-render-alias-mesh-gl-drawaliascontactshadowatorigin-function-gl-drawaliascontactshadowatorigin-header-posenum-entityoriginz-src-miniquake-render-alias-mesh-ml-732639309"></a>
### GL_DrawAliasContactShadowAtOrigin

```ml
function GL_DrawAliasContactShadowAtOrigin(header, posenum, entityOriginZ)
```

Draw one vertically projected model footprint as the stable contact core of the enhanced shadow.  This is still the model mesh, not a generic blob.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasContactShadowAtOrigin`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasContactShadowAtOrigin`. |
| `entityOriginZ` | `dynamic` | — | The entity origin z input consumed by `GL_DrawAliasContactShadowAtOrigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L794)

<a id="function-function-miniquake-render-alias-mesh-gl-drawaliasframe-function-gl-drawaliasframe-header-posenum-src-miniquake-render-alias-mesh-ml-1302614822"></a>
### GL_DrawAliasFrame

```ml
function GL_DrawAliasFrame(header, posenum)
```

Mirror Quake's GL_DrawAliasFrame routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasFrame`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L696)

<a id="function-function-miniquake-render-alias-mesh-gl-drawaliasrayshadowsample-function-gl-drawaliasrayshadowsample-header-posenum-entity-doubleeyes-pointlightenabled-lightx-lighty-lightz-offsetx-offsety-src-miniquake-render-alias-mesh-ml-1635690257"></a>
### GL_DrawAliasRayShadowSample

```ml
function GL_DrawAliasRayShadowSample(header, posenum, entity, doubleEyes, pointLightEnabled, lightX, lightY, lightZ, offsetX, offsetY)
```

Project every MDL triangle along a real light ray onto the first compatible render-BSP polygon. The caster transform and world context are configured by the entity renderer immediately before this call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasRayShadowSample`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasRayShadowSample`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `doubleEyes` | `dynamic` | — | The double eyes input consumed by `GL_DrawAliasRayShadowSample`. |
| `pointLightEnabled` | `dynamic` | — | The point light enabled input consumed by `GL_DrawAliasRayShadowSample`. |
| `lightX` | `dynamic` | — | The light x input consumed by `GL_DrawAliasRayShadowSample`. |
| `lightY` | `dynamic` | — | The light y input consumed by `GL_DrawAliasRayShadowSample`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `GL_DrawAliasRayShadowSample`. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `GL_DrawAliasRayShadowSample`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `GL_DrawAliasRayShadowSample`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L830)

<a id="function-function-miniquake-render-alias-mesh-gl-drawaliasshadow-function-gl-drawaliasshadow-header-posenum-src-miniquake-render-alias-mesh-ml-925315140"></a>
### GL_DrawAliasShadow

```ml
function GL_DrawAliasShadow(header, posenum)
```

Compatibility entry point retained for the direct differential wrapper.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasShadow`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasShadow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L885)

<a id="function-function-miniquake-render-alias-mesh-gl-drawaliasshadowatorigin-function-gl-drawaliasshadowatorigin-header-posenum-entityoriginz-src-miniquake-render-alias-mesh-ml-1978761595"></a>
### GL_DrawAliasShadowAtOrigin

```ml
function GL_DrawAliasShadowAtOrigin(header, posenum, entityOriginZ)
```

Draw the reference single-tap projected alias silhouette.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasShadowAtOrigin`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasShadowAtOrigin`. |
| `entityOriginZ` | `dynamic` | — | The entity origin z input consumed by `GL_DrawAliasShadowAtOrigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L813)

<a id="function-function-miniquake-render-alias-mesh-gl-drawaliasshadowsampleatorigin-function-gl-drawaliasshadowsampleatorigin-header-posenum-entityoriginz-offsetx-offsety-src-miniquake-render-alias-mesh-ml-1767827102"></a>
### GL_DrawAliasShadowSampleAtOrigin

```ml
function GL_DrawAliasShadowSampleAtOrigin(header, posenum, entityOriginZ, offsetX, offsetY)
```

Draw one directional projected-shadow sample with the requested penumbra offset while retaining the public GLQuake-compatible entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | The header input consumed by `GL_DrawAliasShadowSampleAtOrigin`. |
| `posenum` | `dynamic` | — | The posenum input consumed by `GL_DrawAliasShadowSampleAtOrigin`. |
| `entityOriginZ` | `dynamic` | — | The entity origin z input consumed by `GL_DrawAliasShadowSampleAtOrigin`. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `GL_DrawAliasShadowSampleAtOrigin`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `GL_DrawAliasShadowSampleAtOrigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L805)

<a id="function-function-miniquake-render-alias-mesh-gl-makealiasmodeldisplaylists-function-gl-makealiasmodeldisplaylists-model-header-src-miniquake-render-alias-mesh-ml-498300876"></a>
### GL_MakeAliasModelDisplayLists

```ml
function GL_MakeAliasModelDisplayLists(model, header)
```

Mirror Quake's GL_MakeAliasModelDisplayLists routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `header` | `dynamic` | — | The header input consumed by `GL_MakeAliasModelDisplayLists`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L408)

<a id="global-global-miniquake-render-alias-mesh-lastposenum-lastposenum-src-miniquake-render-alias-mesh-ml-1864132664"></a>
### lastposenum

```ml
lastposenum
```

Tracks the module-level lastposenum state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L84)

<a id="global-global-miniquake-render-alias-mesh-lightspot-lightspot-src-miniquake-render-alias-mesh-ml-1450518340"></a>
### lightspot

```ml
lightspot
```

Tracks the module-level lightspot state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L96)

<a id="global-global-miniquake-render-alias-mesh-meshcachemodelkeys-meshcachemodelkeys-src-miniquake-render-alias-mesh-ml-1848089760"></a>
### meshCacheModelKeys

```ml
meshCacheModelKeys
```

Tracks the module-level mesh cache model keys state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L108)

<a id="global-global-miniquake-render-alias-mesh-meshcachevalues-meshcachevalues-src-miniquake-render-alias-mesh-ml-1561549200"></a>
### meshCacheValues

```ml
meshCacheValues
```

Tracks the module-level mesh cache values state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L110)

<a id="global-global-miniquake-render-alias-mesh-numcommands-numcommands-src-miniquake-render-alias-mesh-ml-353678368"></a>
### numcommands

```ml
numcommands
```

Tracks the module-level numcommands state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L68)

<a id="global-global-miniquake-render-alias-mesh-numorder-numorder-src-miniquake-render-alias-mesh-ml-386183604"></a>
### numorder

```ml
numorder
```

Tracks the module-level numorder state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L72)

<a id="global-global-miniquake-render-alias-mesh-paliashdr-paliashdr-src-miniquake-render-alias-mesh-ml-1198399480"></a>
### paliashdr

```ml
paliashdr
```

Tracks the module-level paliashdr state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L58)

<a id="function-function-miniquake-render-alias-mesh-precachealiaslightingrows-function-precachealiaslightingrows-src-miniquake-render-alias-mesh-ml-1919202138"></a>
### precacheAliasLightingRows

```ml
function precacheAliasLightingRows()
```

Build the sixteen yaw-dependent shadedot tables during level precaching.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L544)

<a id="function-function-miniquake-render-alias-mesh-precachealiasmodel-function-precachealiasmodel-model-src-miniquake-render-alias-mesh-ml-2130363305"></a>
### precacheAliasModel

```ml
function precacheAliasModel(model)
```

Preload and register the alias model asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L512)

<a id="function-function-miniquake-render-alias-mesh-r-setupaliasframe-function-r-setupaliasframe-frame-header-src-miniquake-render-alias-mesh-ml-1392958738"></a>
### R_SetupAliasFrame

```ml
function R_SetupAliasFrame(frame, header)
```

Apply the Quake-compatible r setup alias frame behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `R_SetupAliasFrame`. |
| `header` | `dynamic` | — | The header input consumed by `R_SetupAliasFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L892)

<a id="function-function-miniquake-render-alias-mesh-setupaliasframeattime-function-setupaliasframeattime-frame-header-time-src-miniquake-render-alias-mesh-ml-900298389"></a>
### setupAliasFrameAtTime

```ml
function setupAliasFrameAtTime(frame, header, time)
```

Update module state for up alias frame at time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `setupAliasFrameAtTime`. |
| `header` | `dynamic` | — | The header input consumed by `setupAliasFrameAtTime`. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L908)

<a id="function-function-miniquake-render-alias-mesh-shadedotrow-function-shadedotrow-yaw-src-miniquake-render-alias-mesh-ml-1615853151"></a>
### shadeDotRow

```ml
function shadeDotRow(yaw)
```

Implements the `shadeDotRow` operation for `miniquake.render.alias_mesh` (shade dot row).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `yaw` | `dynamic` | — | The yaw input consumed by `shadeDotRow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L156)

<a id="global-global-miniquake-render-alias-mesh-shadedots-shadedots-src-miniquake-render-alias-mesh-ml-2045177924"></a>
### shadedots

```ml
shadedots
```

Tracks the module-level shadedots state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L92)

<a id="global-global-miniquake-render-alias-mesh-shadelight-shadelight-src-miniquake-render-alias-mesh-ml-450304902"></a>
### shadelight

```ml
shadelight
```

Tracks the module-level shadelight state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L86)

<a id="global-global-miniquake-render-alias-mesh-shaderow-shaderow-src-miniquake-render-alias-mesh-ml-146264186"></a>
### shadeRow

```ml
shadeRow
```

Tracks the module-level shade row state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L94)

<a id="global-global-miniquake-render-alias-mesh-shadevector-shadevector-src-miniquake-render-alias-mesh-ml-419110112"></a>
### shadevector

```ml
shadevector
```

Tracks the module-level shadevector state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L90)

<a id="global-global-miniquake-render-alias-mesh-shadowpointlightactive-shadowpointlightactive-src-miniquake-render-alias-mesh-ml-328946380"></a>
### shadowPointLightActive

```ml
shadowPointLightActive
```

Tracks the module-level shadow point light active state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L98)

<a id="global-global-miniquake-render-alias-mesh-shadowpointlightx-shadowpointlightx-src-miniquake-render-alias-mesh-ml-477807480"></a>
### shadowPointLightX

```ml
shadowPointLightX
```

Tracks the module-level shadow point light x state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L100)

<a id="global-global-miniquake-render-alias-mesh-shadowpointlighty-shadowpointlighty-src-miniquake-render-alias-mesh-ml-808908784"></a>
### shadowPointLightY

```ml
shadowPointLightY
```

Tracks the module-level shadow point light y state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L102)

<a id="global-global-miniquake-render-alias-mesh-shadowpointlightz-shadowpointlightz-src-miniquake-render-alias-mesh-ml-736920284"></a>
### shadowPointLightZ

```ml
shadowPointLightZ
```

Tracks the module-level shadow point light z state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L104)

<a id="global-global-miniquake-render-alias-mesh-stripcount-stripcount-src-miniquake-render-alias-mesh-ml-1210894650"></a>
### stripcount

```ml
stripcount
```

Tracks the module-level stripcount state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L82)

<a id="function-function-miniquake-render-alias-mesh-striplength-function-striplength-starttri-startv-src-miniquake-render-alias-mesh-ml-992573289"></a>
### StripLength

```ml
function StripLength(starttri, startv)
```

Exact gl_mesh.c candidate-strip walk.  Temporary used==2 markers are cleared after each candidate while the starting triangle remains selected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `starttri` | `dynamic` | — | The starttri input consumed by `StripLength`. |
| `startv` | `dynamic` | — | The startv input consumed by `StripLength`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L210)

<a id="global-global-miniquake-render-alias-mesh-striptris-striptris-src-miniquake-render-alias-mesh-ml-1316065368"></a>
### striptris

```ml
striptris
```

Tracks the module-level striptris state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L80)

<a id="global-global-miniquake-render-alias-mesh-stripverts-stripverts-src-miniquake-render-alias-mesh-ml-1628056360"></a>
### stripverts

```ml
stripverts
```

Tracks the module-level stripverts state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L78)

<a id="global-global-miniquake-render-alias-mesh-stverts-stverts-src-miniquake-render-alias-mesh-ml-388269232"></a>
### stverts

```ml
stverts
```

Tracks the module-level stverts state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L62)

<a id="global-global-miniquake-render-alias-mesh-triangles-triangles-src-miniquake-render-alias-mesh-ml-1833864112"></a>
### triangles

```ml
triangles
```

Tracks the module-level triangles state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L60)

<a id="function-function-miniquake-render-alias-mesh-trianglevertex-function-trianglevertex-triangle-index-src-miniquake-render-alias-mesh-ml-1126416612"></a>
### triangleVertex

```ml
function triangleVertex(triangle, index)
```

Implements the `triangleVertex` operation for `miniquake.render.alias_mesh` (triangle vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `triangle` | `dynamic` | — | The triangle input consumed by `triangleVertex`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L134)

<a id="global-global-miniquake-render-alias-mesh-used-used-src-miniquake-render-alias-mesh-ml-1031222434"></a>
### used

```ml
used
```

Tracks the module-level used state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L64)

<a id="global-global-miniquake-render-alias-mesh-vertexorder-vertexorder-src-miniquake-render-alias-mesh-ml-1548415176"></a>
### vertexorder

```ml
vertexorder
```

Tracks the module-level vertexorder state owned by `miniquake.render.alias_mesh`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/alias_mesh.ml#L70)
