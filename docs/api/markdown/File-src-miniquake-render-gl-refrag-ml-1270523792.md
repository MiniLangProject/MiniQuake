# `src/miniquake/render/gl_refrag.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.gl_refrag`](Package-miniquake-render-gl-refrag-213316152.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/render/entities.ml` as `entities` → [src/miniquake/render/entities.ml](File-src-miniquake-render-entities-ml-1187973086.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-render-gl-refrag-appendefrag-function-appendefrag-leafindex-src-miniquake-render-gl-refrag-ml-773691592"></a>
### appendEfrag

```ml
function appendEfrag(leafIndex)
```

Add state for append efrag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L154)

<a id="global-global-miniquake-render-gl-refrag-cl-numvisedicts-cl-numvisedicts-src-miniquake-render-gl-refrag-ml-1176336168"></a>
### cl_numvisedicts

```ml
cl_numvisedicts
```

Tracks the module-level cl numvisedicts state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L56)

<a id="global-global-miniquake-render-gl-refrag-cl-visedicts-cl-visedicts-src-miniquake-render-gl-refrag-ml-272922492"></a>
### cl_visedicts

```ml
cl_visedicts
```

Tracks the module-level cl visedicts state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L54)

<a id="function-function-miniquake-render-gl-refrag-configure-function-configure-renderer-entityrenderer-entitystates-src-miniquake-render-gl-refrag-ml-872909508"></a>
### Configure

```ml
function Configure(renderer, entityRenderer, entityStates)
```

Implements the `Configure` operation for `miniquake.render.gl_refrag` (configure).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `entityRenderer` | `dynamic` | — | The entity renderer input consumed by `Configure`. |
| `entityStates` | `dynamic` | — | The entity states input consumed by `Configure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L74)

<a id="function-function-miniquake-render-gl-refrag-configurestaticentities-function-configurestaticentities-renderer-entityrenderer-entitystates-src-miniquake-render-gl-refrag-ml-996035806"></a>
### ConfigureStaticEntities

```ml
function ConfigureStaticEntities(renderer, entityRenderer, entityStates)
```

Rebuild the immutable signon-time static-entity efrag index only when its map, model table or source array changes. Static renderer-local numbers sit outside Protocol 15's edict range, but their shared EfragRef objects remain fully linked from the BSP leaves used for frame visibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |
| `entityRenderer` | `dynamic` | — | The entity renderer input consumed by `ConfigureStaticEntities`. |
| `entityStates` | `dynamic` | — | The entity states input consumed by `ConfigureStaticEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L113)

- [miniquake.render.gl_refrag.EfragRef](Type-miniquake-render-gl-refrag-efragref-948667698.md) — struct
<a id="function-function-miniquake-render-gl-refrag-getstate-function-getstate-entitynumber-src-miniquake-render-gl-refrag-ml-88750988"></a>
### GetState

```ml
function GetState(entityNumber)
```

Return state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `GetState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L346)

<a id="function-function-miniquake-render-gl-refrag-modelbounds-function-modelbounds-ent-src-miniquake-render-gl-refrag-ml-1484971117"></a>
### modelBounds

```ml
function modelBounds(ent)
```

Implements the `modelBounds` operation for `miniquake.render.gl_refrag` (model bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ent` | `dynamic` | — | The ent input consumed by `modelBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L196)

<a id="function-function-miniquake-render-gl-refrag-r-addefrags-function-r-addefrags-ent-src-miniquake-render-gl-refrag-ml-352848209"></a>
### R_AddEfrags

```ml
function R_AddEfrags(ent)
```

Apply the Quake-compatible r add efrags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ent` | `dynamic` | — | The ent input consumed by `R_AddEfrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L215)

<a id="global-global-miniquake-render-gl-refrag-r-addent-r-addent-src-miniquake-render-gl-refrag-ml-1636059898"></a>
### r_addent

```ml
r_addent
```

Tracks the module-level r addent state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L48)

<a id="function-function-miniquake-render-gl-refrag-r-appendvisiblepvs-function-r-appendvisiblepvs-dynamicentities-pvs-src-miniquake-render-gl-refrag-ml-1135967861"></a>
### R_AppendVisiblePvs

```ml
function R_AppendVisiblePvs(dynamicEntities, pvs)
```

Append efrag-linked statics from exactly the leaves in the current view PVS. Dynamic entities are supplied first, matching CL_RelinkEntities ordering and preserving their priority at MAX_VISEDICTS. One builder replaces the old per-leaf copy loop and avoids frame-time allocation bursts in large maps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dynamicEntities` | `dynamic` | — | The dynamic entities input consumed by `R_AppendVisiblePvs`. |
| `pvs` | `dynamic` | — | The pvs input consumed by `R_AppendVisiblePvs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L276)

<a id="function-function-miniquake-render-gl-refrag-r-beginvisibleframe-function-r-beginvisibleframe-src-miniquake-render-gl-refrag-ml-4589440"></a>
### R_BeginVisibleFrame

```ml
function R_BeginVisibleFrame()
```

Apply the Quake-compatible r begin visible frame behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L231)

<a id="global-global-miniquake-render-gl-refrag-r-emaxs-r-emaxs-src-miniquake-render-gl-refrag-ml-1738313088"></a>
### r_emaxs

```ml
r_emaxs
```

Tracks the module-level r emaxs state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L52)

<a id="global-global-miniquake-render-gl-refrag-r-emins-r-emins-src-miniquake-render-gl-refrag-ml-1093531916"></a>
### r_emins

```ml
r_emins
```

Tracks the module-level r emins state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L50)

<a id="global-global-miniquake-render-gl-refrag-r-pefragtopnode-r-pefragtopnode-src-miniquake-render-gl-refrag-ml-515470568"></a>
### r_pefragtopnode

```ml
r_pefragtopnode
```

Tracks the module-level r pefragtopnode state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L46)

<a id="function-function-miniquake-render-gl-refrag-r-removeefrags-function-r-removeefrags-ent-src-miniquake-render-gl-refrag-ml-1074497489"></a>
### R_RemoveEfrags

```ml
function R_RemoveEfrags(ent)
```

Apply the Quake-compatible r remove efrags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ent` | `dynamic` | — | The ent input consumed by `R_RemoveEfrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L134)

<a id="function-function-miniquake-render-gl-refrag-r-splitentityonnode-function-r-splitentityonnode-nodenumber-src-miniquake-render-gl-refrag-ml-1035258195"></a>
### R_SplitEntityOnNode

```ml
function R_SplitEntityOnNode(nodeNumber)
```

Apply the Quake-compatible r split entity on node behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `R_SplitEntityOnNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L170)

<a id="function-function-miniquake-render-gl-refrag-r-storeefrags-function-r-storeefrags-leafindex-src-miniquake-render-gl-refrag-ml-588479634"></a>
### R_StoreEfrags

```ml
function R_StoreEfrags(leafIndex)
```

Apply the Quake-compatible r store efrags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L240)

<a id="function-function-miniquake-render-gl-refrag-r-visibleentities-function-r-visibleentities-src-miniquake-render-gl-refrag-ml-2065497254"></a>
### R_VisibleEntities

```ml
function R_VisibleEntities()
```

Apply the Quake-compatible r visible entities behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L327)

<a id="global-global-miniquake-render-gl-refrag-refragbspmodels-refragbspmodels-src-miniquake-render-gl-refrag-ml-1506830368"></a>
### refragBspModels

```ml
refragBspModels
```

Tracks the module-level refrag bsp models state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L36)

<a id="global-global-miniquake-render-gl-refrag-refragentities-refragentities-src-miniquake-render-gl-refrag-ml-420601204"></a>
### refragEntities

```ml
refragEntities
```

Tracks the module-level refrag entities state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L40)

<a id="global-global-miniquake-render-gl-refrag-refragentityefrags-refragentityefrags-src-miniquake-render-gl-refrag-ml-1298978728"></a>
### refragEntityEfrags

```ml
refragEntityEfrags
```

Tracks the module-level refrag entity efrags state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L44)

<a id="global-global-miniquake-render-gl-refrag-refragleafefrags-refragleafefrags-src-miniquake-render-gl-refrag-ml-511667270"></a>
### refragLeafEfrags

```ml
refragLeafEfrags
```

Tracks the module-level refrag leaf efrags state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L42)

<a id="global-global-miniquake-render-gl-refrag-refragleafs-refragleafs-src-miniquake-render-gl-refrag-ml-55561944"></a>
### refragLeafs

```ml
refragLeafs
```

Tracks the module-level refrag leafs state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L30)

<a id="global-global-miniquake-render-gl-refrag-refragmodels-refragmodels-src-miniquake-render-gl-refrag-ml-1988222218"></a>
### refragModels

```ml
refragModels
```

Tracks the module-level refrag models state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L38)

<a id="global-global-miniquake-render-gl-refrag-refragnodes-refragnodes-src-miniquake-render-gl-refrag-ml-1562553816"></a>
### refragNodes

```ml
refragNodes
```

Tracks the module-level refrag nodes state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L32)

<a id="global-global-miniquake-render-gl-refrag-refragplanes-refragplanes-src-miniquake-render-gl-refrag-ml-1025956564"></a>
### refragPlanes

```ml
refragPlanes
```

Tracks the module-level refrag planes state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L34)

<a id="function-function-miniquake-render-gl-refrag-setsplitstate-function-setsplitstate-entity-mins-maxs-src-miniquake-render-gl-refrag-ml-1806386755"></a>
### SetSplitState

```ml
function SetSplitState(entity, mins, maxs)
```

Update module state for split state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `mins` | `dynamic` | — | The mins input consumed by `SetSplitState`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SetSplitState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L335)

<a id="global-global-miniquake-render-gl-refrag-staticentityarraykey-staticentityarraykey-src-miniquake-render-gl-refrag-ml-1386776362"></a>
### staticEntityArrayKey

```ml
staticEntityArrayKey
```

Tracks the module-level static entity array key state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L62)

<a id="global-global-miniquake-render-gl-refrag-staticentitycount-staticentitycount-src-miniquake-render-gl-refrag-ml-955669048"></a>
### staticEntityCount

```ml
staticEntityCount
```

Tracks the module-level static entity count state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L64)

<a id="global-global-miniquake-render-gl-refrag-staticmodelrendererkey-staticmodelrendererkey-src-miniquake-render-gl-refrag-ml-1791608782"></a>
### staticModelRendererKey

```ml
staticModelRendererKey
```

Tracks the module-level static model renderer key state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L60)

<a id="global-global-miniquake-render-gl-refrag-staticrendererkey-staticrendererkey-src-miniquake-render-gl-refrag-ml-436869636"></a>
### staticRendererKey

```ml
staticRendererKey
```

Tracks the module-level static renderer key state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L58)

<a id="global-global-miniquake-render-gl-refrag-visibleentitygeneration-visibleentitygeneration-src-miniquake-render-gl-refrag-ml-248908220"></a>
### visibleEntityGeneration

```ml
visibleEntityGeneration
```

Tracks the module-level visible entity generation state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L66)

<a id="global-global-miniquake-render-gl-refrag-visibleentitystamp-visibleentitystamp-src-miniquake-render-gl-refrag-ml-1820068520"></a>
### visibleEntityStamp

```ml
visibleEntityStamp
```

Tracks the module-level visible entity stamp state owned by `miniquake.render.gl_refrag`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L68)
