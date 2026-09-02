# `src/miniquake/render/ray_shadow.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.ray_shadow`](Package-miniquake-render-ray-shadow-378296642.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `byteio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/render/gl_rlight.ml` as `glRlight` → [src/miniquake/render/gl_rlight.ml](File-src-miniquake-render-gl-rlight-ml-1917075617.md)

## Declarations

<a id="function-function-miniquake-render-ray-shadow-acceptprojection-function-acceptprojection-index-hit-receiversurface-fraction-hitx-hity-hitz-normalx-normaly-normalz-src-miniquake-render-ray-shadow-ml-56444913"></a>
### acceptProjection

```ml
function acceptProjection(index, hit, receiverSurface, fraction, hitX, hitY, hitZ, normalX, normalY, normalZ)
```

Validate and store one native or scalar ray result with a receiver-normal bias that prevents depth fighting on the actual world polygon.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `hit` | `dynamic` | — | The hit input consumed by `acceptProjection`. |
| `receiverSurface` | `dynamic` | — | The receiver surface input consumed by `acceptProjection`. |
| `fraction` | `dynamic` | — | The fraction input consumed by `acceptProjection`. |
| `hitX` | `dynamic` | — | The hit x input consumed by `acceptProjection`. |
| `hitY` | `dynamic` | — | The hit y input consumed by `acceptProjection`. |
| `hitZ` | `dynamic` | — | The hit z input consumed by `acceptProjection`. |
| `normalX` | `dynamic` | — | The normal x input consumed by `acceptProjection`. |
| `normalY` | `dynamic` | — | The normal y input consumed by `acceptProjection`. |
| `normalZ` | `dynamic` | — | The normal z input consumed by `acceptProjection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L430)

<a id="global-global-miniquake-render-ray-shadow-activemap-activemap-src-miniquake-render-ray-shadow-ml-583441152"></a>
### activeMap

```ml
activeMap
```

Tracks the module-level active map state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L25)

<a id="global-global-miniquake-render-ray-shadow-activerootnode-activerootnode-src-miniquake-render-ray-shadow-ml-520032592"></a>
### activeRootNode

```ml
activeRootNode
```

Tracks the module-level active root node state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L29)

<a id="global-global-miniquake-render-ray-shadow-activesurfaces-activesurfaces-src-miniquake-render-ray-shadow-ml-1485759944"></a>
### activeSurfaces

```ml
activeSurfaces
```

Tracks the module-level active surfaces state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L27)

<a id="function-function-miniquake-render-ray-shadow-beginprimitive-function-beginprimitive-src-miniquake-render-ray-shadow-ml-1266581024"></a>
### beginPrimitive

```ml
function beginPrimitive()
```

Start an independently indexed brush polygon while retaining the current light sample. Alias triangles deliberately share one generation so repeated MDL vertex indexes are traced only once.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L331)

<a id="function-function-miniquake-render-ray-shadow-beginprojectionsample-function-beginprojectionsample-offsetx-offsety-src-miniquake-render-ray-shadow-ml-1497661117"></a>
### beginProjectionSample

```ml
function beginProjectionSample(offsetX, offsetY)
```

Begin one hard-shadow or area-light sample and invalidate cached projected vertices by advancing a generation counter instead of clearing large arrays.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offsetX` | `dynamic` | — | The offset x input consumed by `beginProjectionSample`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `beginProjectionSample`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L316)

<a id="function-function-miniquake-render-ray-shadow-configurealias-function-configurealias-worldmap-worldsurfaces-entity-model-doubleeyes-lightactive-lightx-lighty-lightz-src-miniquake-render-ray-shadow-ml-1411083048"></a>
### configureAlias

```ml
function configureAlias(worldMap, worldSurfaces, entity, model, doubleEyes, lightActive, lightX, lightY, lightZ)
```

Configure an MDL caster using the exact GLQuake alias transform, including the doubled-eyes compatibility special case.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldMap` | `dynamic` | — | The world map input consumed by `configureAlias`. |
| `worldSurfaces` | `dynamic` | — | The world surfaces input consumed by `configureAlias`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `doubleEyes` | `dynamic` | — | The double eyes input consumed by `configureAlias`. |
| `lightActive` | `dynamic` | — | The light active input consumed by `configureAlias`. |
| `lightX` | `dynamic` | — | The light x input consumed by `configureAlias`. |
| `lightY` | `dynamic` | — | The light y input consumed by `configureAlias`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `configureAlias`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L274)

<a id="function-function-miniquake-render-ray-shadow-configurebrush-function-configurebrush-worldmap-worldsurfaces-entity-lightactive-lightx-lighty-lightz-src-miniquake-render-ray-shadow-ml-1659596448"></a>
### configureBrush

```ml
function configureBrush(worldMap, worldSurfaces, entity, lightActive, lightX, lightY, lightZ)
```

Configure an inline or external BSP caster. Brush model vertices are already expressed in model-local world units and use the positive pitch transform.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldMap` | `dynamic` | — | The world map input consumed by `configureBrush`. |
| `worldSurfaces` | `dynamic` | — | The world surfaces input consumed by `configureBrush`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `lightActive` | `dynamic` | — | The light active input consumed by `configureBrush`. |
| `lightX` | `dynamic` | — | The light x input consumed by `configureBrush`. |
| `lightY` | `dynamic` | — | The light y input consumed by `configureBrush`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `configureBrush`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L304)

<a id="function-function-miniquake-render-ray-shadow-configurecaster-function-configurecaster-worldmap-worldsurfaces-entity-scalex-scaley-scalez-offsetx-offsety-offsetz-pitchsign-lightactive-lightx-lighty-lightz-src-miniquake-render-ray-shadow-ml-7218636"></a>
### configureCaster

```ml
function configureCaster(worldMap, worldSurfaces, entity, scaleX, scaleY, scaleZ, offsetX, offsetY, offsetZ, pitchSign, lightActive, lightX, lightY, lightZ)
```

Configure common world, entity transform and light state for one caster.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldMap` | `dynamic` | — | The world map input consumed by `configureCaster`. |
| `worldSurfaces` | `dynamic` | — | The world surfaces input consumed by `configureCaster`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `scaleX` | `dynamic` | — | The scale x input consumed by `configureCaster`. |
| `scaleY` | `dynamic` | — | The scale y input consumed by `configureCaster`. |
| `scaleZ` | `dynamic` | — | The scale z input consumed by `configureCaster`. |
| `offsetX` | `dynamic` | — | The offset x input consumed by `configureCaster`. |
| `offsetY` | `dynamic` | — | The offset y input consumed by `configureCaster`. |
| `offsetZ` | `dynamic` | — | The offset z input consumed by `configureCaster`. |
| `pitchSign` | `dynamic` | — | The pitch sign input consumed by `configureCaster`. |
| `lightActive` | `dynamic` | — | The light active input consumed by `configureCaster`. |
| `lightX` | `dynamic` | — | The light x input consumed by `configureCaster`. |
| `lightY` | `dynamic` | — | The light y input consumed by `configureCaster`. |
| `lightZ` | `dynamic` | — | The light z input consumed by `configureCaster`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L224)

<a id="function-function-miniquake-render-ray-shadow-ensurenativeworld-function-ensurenativeworld-worldmap-worldsurfaces-src-miniquake-render-ray-shadow-ml-2015390792"></a>
### ensureNativeWorld

```ml
function ensureNativeWorld(worldMap, worldSurfaces)
```

Upload a triangulated copy of the render BSP once per map. The native bridge builds a CPU BVH; MiniLang retains ownership of caster/light policy and all emitted shadow geometry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldMap` | `dynamic` | — | The world map input consumed by `ensureNativeWorld`. |
| `worldSurfaces` | `dynamic` | — | The world surfaces input consumed by `ensureNativeWorld`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L159)

<a id="function-function-miniquake-render-ray-shadow-ensurevertexcapacity-function-ensurevertexcapacity-index-src-miniquake-render-ray-shadow-ml-1897639556"></a>
### ensureVertexCapacity

```ml
function ensureVertexCapacity(index)
```

Grow every parallel vertex cache together so a model vertex index remains a stable key throughout one shadow sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L122)

<a id="global-global-miniquake-render-ray-shadow-hitpacket-hitpacket-src-miniquake-render-ray-shadow-ml-221204052"></a>
### hitPacket

```ml
hitPacket
```

Tracks the module-level hit packet state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L109)

<a id="constant-constant-miniquake-render-ray-shadow-initial-vertex-cache-const-initial-vertex-cache-1024-src-miniquake-render-ray-shadow-ml-554651270"></a>
### INITIAL_VERTEX_CACHE

```ml
const INITIAL_VERTEX_CACHE = 1024
```

Defines the initial vertex cache value used by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L18)

<a id="function-function-miniquake-render-ray-shadow-isready-inline-function-isready-src-miniquake-render-ray-shadow-ml-2011239877"></a>
### isReady

```ml
inline function isReady()
```

Report whether the current caster has a valid render-BSP context.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L632)

<a id="constant-constant-miniquake-render-ray-shadow-max-receiver-distance-const-max-receiver-distance-768-src-miniquake-render-ray-shadow-ml-1428128336"></a>
### MAX_RECEIVER_DISTANCE

```ml
const MAX_RECEIVER_DISTANCE = 768.
```

Defines the max receiver distance value used by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L20)

<a id="global-global-miniquake-render-ray-shadow-minimumhitfraction-minimumhitfraction-src-miniquake-render-ray-shadow-ml-725079414"></a>
### minimumHitFraction

```ml
minimumHitFraction
```

Tracks the module-level minimum hit fraction state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L103)

<a id="global-global-miniquake-render-ray-shadow-modeloffsetx-modeloffsetx-src-miniquake-render-ray-shadow-ml-214380304"></a>
### modelOffsetX

```ml
modelOffsetX
```

Tracks the module-level model offset x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L45)

<a id="global-global-miniquake-render-ray-shadow-modeloffsety-modeloffsety-src-miniquake-render-ray-shadow-ml-1906420742"></a>
### modelOffsetY

```ml
modelOffsetY
```

Tracks the module-level model offset y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L47)

<a id="global-global-miniquake-render-ray-shadow-modeloffsetz-modeloffsetz-src-miniquake-render-ray-shadow-ml-2093961200"></a>
### modelOffsetZ

```ml
modelOffsetZ
```

Tracks the module-level model offset z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L49)

<a id="global-global-miniquake-render-ray-shadow-modelscalex-modelscalex-src-miniquake-render-ray-shadow-ml-153615780"></a>
### modelScaleX

```ml
modelScaleX
```

Tracks the module-level model scale x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L39)

<a id="global-global-miniquake-render-ray-shadow-modelscaley-modelscaley-src-miniquake-render-ray-shadow-ml-1558847740"></a>
### modelScaleY

```ml
modelScaleY
```

Tracks the module-level model scale y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L41)

<a id="global-global-miniquake-render-ray-shadow-modelscalez-modelscalez-src-miniquake-render-ray-shadow-ml-566836488"></a>
### modelScaleZ

```ml
modelScaleZ
```

Tracks the module-level model scale z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L43)

<a id="global-global-miniquake-render-ray-shadow-nativeworldready-nativeworldready-src-miniquake-render-ray-shadow-ml-1869401872"></a>
### nativeWorldReady

```ml
nativeWorldReady
```

Tracks the module-level native world ready state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L115)

<a id="global-global-miniquake-render-ray-shadow-originx-originx-src-miniquake-render-ray-shadow-ml-1804316256"></a>
### originX

```ml
originX
```

Tracks the module-level origin x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L33)

<a id="global-global-miniquake-render-ray-shadow-originy-originy-src-miniquake-render-ray-shadow-ml-202005700"></a>
### originY

```ml
originY
```

Tracks the module-level origin y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L35)

<a id="global-global-miniquake-render-ray-shadow-originz-originz-src-miniquake-render-ray-shadow-ml-1208227452"></a>
### originZ

```ml
originZ
```

Tracks the module-level origin z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L37)

<a id="global-global-miniquake-render-ray-shadow-pitchcos-pitchcos-src-miniquake-render-ray-shadow-ml-953172694"></a>
### pitchCos

```ml
pitchCos
```

Tracks the module-level pitch cos state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L55)

<a id="global-global-miniquake-render-ray-shadow-pitchsin-pitchsin-src-miniquake-render-ray-shadow-ml-1404138448"></a>
### pitchSin

```ml
pitchSin
```

Tracks the module-level pitch sin state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L57)

<a id="global-global-miniquake-render-ray-shadow-pointlightactive-pointlightactive-src-miniquake-render-ray-shadow-ml-1199054192"></a>
### pointLightActive

```ml
pointLightActive
```

Tracks the module-level point light active state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L63)

<a id="global-global-miniquake-render-ray-shadow-pointlightx-pointlightx-src-miniquake-render-ray-shadow-ml-1112658520"></a>
### pointLightX

```ml
pointLightX
```

Tracks the module-level point light x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L65)

<a id="global-global-miniquake-render-ray-shadow-pointlighty-pointlighty-src-miniquake-render-ray-shadow-ml-1620557544"></a>
### pointLightY

```ml
pointLightY
```

Tracks the module-level point light y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L67)

<a id="global-global-miniquake-render-ray-shadow-pointlightz-pointlightz-src-miniquake-render-ray-shadow-ml-1404105656"></a>
### pointLightZ

```ml
pointLightZ
```

Tracks the module-level point light z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L69)

<a id="function-function-miniquake-render-ray-shadow-preparevertexray-function-preparevertexray-index-packedx-packedy-packedz-src-miniquake-render-ray-shadow-ml-1250163983"></a>
### prepareVertexRay

```ml
function prepareVertexRay(index, packedX, packedY, packedZ)
```

Transform one model vertex and pack its finite light segment for either the native BVH batch or the scalar MiniLang fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `packedX` | `dynamic` | — | The packed x input consumed by `prepareVertexRay`. |
| `packedY` | `dynamic` | — | The packed y input consumed by `prepareVertexRay`. |
| `packedZ` | `dynamic` | — | The packed z input consumed by `prepareVertexRay`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L341)

<a id="function-function-miniquake-render-ray-shadow-projectaliasvertices-function-projectaliasvertices-vertices-src-miniquake-render-ray-shadow-ml-2011771979"></a>
### projectAliasVertices

```ml
function projectAliasVertices(vertices)
```

Trace every MDL frame vertex through one native call for the current sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `projectAliasVertices`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L505)

<a id="function-function-miniquake-render-ray-shadow-projectbrushvertices-function-projectbrushvertices-vertices-src-miniquake-render-ray-shadow-ml-1721003147"></a>
### projectBrushVertices

```ml
function projectBrushVertices(vertices)
```

Trace every vertex of one BSP caster polygon through one native call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vertices` | `dynamic` | — | The vertices input consumed by `projectBrushVertices`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L519)

<a id="function-function-miniquake-render-ray-shadow-projectedpointsurface-inline-function-projectedpointsurface-index-src-miniquake-render-ray-shadow-ml-328771871"></a>
### projectedPointSurface

```ml
inline function projectedPointSurface(index)
```

Return the render-BSP surface reached by one cached native ray.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L621)

<a id="function-function-miniquake-render-ray-shadow-projectedpointvalid-inline-function-projectedpointvalid-index-src-miniquake-render-ray-shadow-ml-585812887"></a>
### projectedPointValid

```ml
inline function projectedPointValid(index)
```

Report whether one vertex reached a compatible receiver in this sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L627)

<a id="function-function-miniquake-render-ray-shadow-projectedpointx-inline-function-projectedpointx-index-src-miniquake-render-ray-shadow-ml-1639098487"></a>
### projectedPointX

```ml
inline function projectedPointX(index)
```

Return one cached projected x coordinate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L603)

<a id="function-function-miniquake-render-ray-shadow-projectedpointy-inline-function-projectedpointy-index-src-miniquake-render-ray-shadow-ml-385797999"></a>
### projectedPointY

```ml
inline function projectedPointY(index)
```

Return one cached projected y coordinate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L609)

<a id="function-function-miniquake-render-ray-shadow-projectedpointz-inline-function-projectedpointz-index-src-miniquake-render-ray-shadow-ml-628228743"></a>
### projectedPointZ

```ml
inline function projectedPointZ(index)
```

Return one cached projected z coordinate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L615)

<a id="global-global-miniquake-render-ray-shadow-projectiongeneration-projectiongeneration-src-miniquake-render-ray-shadow-ml-2005901434"></a>
### projectionGeneration

```ml
projectionGeneration
```

Tracks the module-level projection generation state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L75)

<a id="global-global-miniquake-render-ray-shadow-projectionnormalx-projectionnormalx-src-miniquake-render-ray-shadow-ml-1926050880"></a>
### projectionNormalX

```ml
projectionNormalX
```

Tracks the module-level projection normal x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L87)

<a id="global-global-miniquake-render-ray-shadow-projectionnormaly-projectionnormaly-src-miniquake-render-ray-shadow-ml-1646342072"></a>
### projectionNormalY

```ml
projectionNormalY
```

Tracks the module-level projection normal y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L89)

<a id="global-global-miniquake-render-ray-shadow-projectionnormalz-projectionnormalz-src-miniquake-render-ray-shadow-ml-704558432"></a>
### projectionNormalZ

```ml
projectionNormalZ
```

Tracks the module-level projection normal z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L91)

<a id="global-global-miniquake-render-ray-shadow-projectionstamp-projectionstamp-src-miniquake-render-ray-shadow-ml-590779972"></a>
### projectionStamp

```ml
projectionStamp
```

Tracks the module-level projection stamp state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L77)

<a id="global-global-miniquake-render-ray-shadow-projectionsurface-projectionsurface-src-miniquake-render-ray-shadow-ml-419789304"></a>
### projectionSurface

```ml
projectionSurface
```

Tracks the module-level projection surface state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L93)

<a id="global-global-miniquake-render-ray-shadow-projectiontravel-projectiontravel-src-miniquake-render-ray-shadow-ml-1296882026"></a>
### projectionTravel

```ml
projectionTravel
```

Tracks the module-level projection travel state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L95)

<a id="global-global-miniquake-render-ray-shadow-projectionvalid-projectionvalid-src-miniquake-render-ray-shadow-ml-224517356"></a>
### projectionValid

```ml
projectionValid
```

Tracks the module-level projection valid state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L79)

<a id="global-global-miniquake-render-ray-shadow-projectionx-projectionx-src-miniquake-render-ray-shadow-ml-894373180"></a>
### projectionX

```ml
projectionX
```

Tracks the module-level projection x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L81)

<a id="global-global-miniquake-render-ray-shadow-projectiony-projectiony-src-miniquake-render-ray-shadow-ml-704115984"></a>
### projectionY

```ml
projectionY
```

Tracks the module-level projection y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L83)

<a id="global-global-miniquake-render-ray-shadow-projectionz-projectionz-src-miniquake-render-ray-shadow-ml-1472214156"></a>
### projectionZ

```ml
projectionZ
```

Tracks the module-level projection z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L85)

<a id="function-function-miniquake-render-ray-shadow-projectvertex-function-projectvertex-index-packedx-packedy-packedz-src-miniquake-render-ray-shadow-ml-1233281929"></a>
### projectVertex

```ml
function projectVertex(index, packedX, packedY, packedZ)
```

Project an individual vertex for diagnostics and compatibility callers. The production alias/brush paths use the two batch entry points above.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `packedX` | `dynamic` | — | The packed x input consumed by `projectVertex`. |
| `packedY` | `dynamic` | — | The packed y input consumed by `projectVertex`. |
| `packedZ` | `dynamic` | — | The packed z input consumed by `projectVertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L537)

<a id="global-global-miniquake-render-ray-shadow-raypacket-raypacket-src-miniquake-render-ray-shadow-ml-190235924"></a>
### rayPacket

```ml
rayPacket
```

Tracks the module-level ray packet state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L107)

<a id="global-global-miniquake-render-ray-shadow-raypreparedvalid-raypreparedvalid-src-miniquake-render-ray-shadow-ml-1082117462"></a>
### rayPreparedValid

```ml
rayPreparedValid
```

Tracks the module-level ray prepared valid state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L105)

<a id="global-global-miniquake-render-ray-shadow-ready-ready-src-miniquake-render-ray-shadow-ml-1143616492"></a>
### ready

```ml
ready
```

Tracks the module-level ready state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L31)

<a id="constant-constant-miniquake-render-ray-shadow-receiver-bias-const-receiver-bias-0-65-src-miniquake-render-ray-shadow-ml-1752583164"></a>
### RECEIVER_BIAS

```ml
const RECEIVER_BIAS = 0.65
```

Defines the receiver bias value used by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L22)

<a id="function-function-miniquake-render-ray-shadow-receiveredgecompatible-function-receiveredgecompatible-left-right-src-miniquake-render-ray-shadow-ml-1347250105"></a>
### receiverEdgeCompatible

```ml
function receiverEdgeCompatible(left, right)
```

Test one projected edge for a compatible receiver plane and bounded stretch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `receiverEdgeCompatible`. |
| `right` | `dynamic` | — | The right input consumed by `receiverEdgeCompatible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L571)

<a id="function-function-miniquake-render-ray-shadow-receiveredgecontinuity-inline-function-receiveredgecontinuity-sourcelength-projectedlength-traveldifference-src-miniquake-render-ray-shadow-ml-1198650753"></a>
### receiverEdgeContinuity

```ml
inline function receiverEdgeContinuity(sourceLength, projectedLength, travelDifference)
```

Reject receiver discontinuities before the rasterizer interpolates a source edge across empty space.  The allowance scales with the caster edge so a normal slope remains intact, while an adjacent ledge/floor pair cannot form the long translucent triangles previously visible around crate corners.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sourceLength` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |
| `projectedLength` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |
| `travelDifference` | `dynamic` | — | The travel difference input consumed by `receiverEdgeContinuity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L553)

<a id="function-function-miniquake-render-ray-shadow-receiversurfacecontinuity-inline-function-receiversurfacecontinuity-leftsurface-rightsurface-src-miniquake-render-ray-shadow-ml-179027482"></a>
### receiverSurfaceContinuity

```ml
inline function receiverSurfaceContinuity(leftSurface, rightSurface)
```

Require native ray hits to remain on one concrete BSP receiver polygon. The scalar fallback cannot expose a surface id and retains the geometric normal/stretch checks below, represented by its negative sentinel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftSurface` | `dynamic` | — | The left surface input consumed by `receiverSurfaceContinuity`. |
| `rightSurface` | `dynamic` | — | The right surface input consumed by `receiverSurfaceContinuity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L563)

<a id="function-function-miniquake-render-ray-shadow-receivertrianglecompatible-function-receivertrianglecompatible-first-second-third-src-miniquake-render-ray-shadow-ml-875839187"></a>
### receiverTriangleCompatible

```ml
function receiverTriangleCompatible(first, second, third)
```

Reject a triangle whose rays land across an abrupt BSP corner or stretch far beyond its source edge. Skipping that triangle prevents geometry from being interpolated through a wall between otherwise individually valid hits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `receiverTriangleCompatible`. |
| `second` | `dynamic` | — | The second input consumed by `receiverTriangleCompatible`. |
| `third` | `dynamic` | — | The third input consumed by `receiverTriangleCompatible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L594)

<a id="global-global-miniquake-render-ray-shadow-rollcos-rollcos-src-miniquake-render-ray-shadow-ml-113858696"></a>
### rollCos

```ml
rollCos
```

Tracks the module-level roll cos state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L59)

<a id="global-global-miniquake-render-ray-shadow-rollsin-rollsin-src-miniquake-render-ray-shadow-ml-720004584"></a>
### rollSin

```ml
rollSin
```

Tracks the module-level roll sin state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L61)

<a id="global-global-miniquake-render-ray-shadow-sampleoffsetx-sampleoffsetx-src-miniquake-render-ray-shadow-ml-1176722980"></a>
### sampleOffsetX

```ml
sampleOffsetX
```

Tracks the module-level sample offset x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L71)

<a id="global-global-miniquake-render-ray-shadow-sampleoffsety-sampleoffsety-src-miniquake-render-ray-shadow-ml-230609404"></a>
### sampleOffsetY

```ml
sampleOffsetY
```

Tracks the module-level sample offset y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L73)

<a id="global-global-miniquake-render-ray-shadow-sourcex-sourcex-src-miniquake-render-ray-shadow-ml-979443996"></a>
### sourceX

```ml
sourceX
```

Tracks the module-level source x state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L97)

<a id="global-global-miniquake-render-ray-shadow-sourcey-sourcey-src-miniquake-render-ray-shadow-ml-1706629096"></a>
### sourceY

```ml
sourceY
```

Tracks the module-level source y state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L99)

<a id="global-global-miniquake-render-ray-shadow-sourcez-sourcez-src-miniquake-render-ray-shadow-ml-720422796"></a>
### sourceZ

```ml
sourceZ
```

Tracks the module-level source z state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L101)

<a id="function-function-miniquake-render-ray-shadow-tracepreparedvertices-function-tracepreparedvertices-count-src-miniquake-render-ray-shadow-ml-625651349"></a>
### tracePreparedVertices

```ml
function tracePreparedVertices(count)
```

Trace the prepared prefix as one native BVH batch, falling back to the allocation-free render-BSP walker if the native acceleration is unavailable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L458)

<a id="global-global-miniquake-render-ray-shadow-uploadedmapname-uploadedmapname-src-miniquake-render-ray-shadow-ml-948272648"></a>
### uploadedMapName

```ml
uploadedMapName
```

Tracks the module-level uploaded map name state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L111)

<a id="global-global-miniquake-render-ray-shadow-uploadedsurfacecount-uploadedsurfacecount-src-miniquake-render-ray-shadow-ml-1028149604"></a>
### uploadedSurfaceCount

```ml
uploadedSurfaceCount
```

Tracks the module-level uploaded surface count state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L113)

<a id="global-global-miniquake-render-ray-shadow-worldtrianglepacket-worldtrianglepacket-src-miniquake-render-ray-shadow-ml-2092503152"></a>
### worldTrianglePacket

```ml
worldTrianglePacket
```

Tracks the module-level world triangle packet state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L117)

<a id="global-global-miniquake-render-ray-shadow-yawcos-yawcos-src-miniquake-render-ray-shadow-ml-37041740"></a>
### yawCos

```ml
yawCos
```

Tracks the module-level yaw cos state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L51)

<a id="global-global-miniquake-render-ray-shadow-yawsin-yawsin-src-miniquake-render-ray-shadow-ml-2045194046"></a>
### yawSin

```ml
yawSin
```

Tracks the module-level yaw sin state owned by `miniquake.render.ray_shadow`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/ray_shadow.ml#L53)
