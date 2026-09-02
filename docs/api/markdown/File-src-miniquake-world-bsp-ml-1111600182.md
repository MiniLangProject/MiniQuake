# `src/miniquake/world_bsp.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.world_bsp`](Package-miniquake-world-bsp-1396420223.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-world-bsp-absolutevalue-function-absolutevalue-value-src-miniquake-world-bsp-ml-2068720860"></a>
### absoluteValue

```ml
function absoluteValue(value)
```

Return absolute value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absoluteValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L739)

<a id="function-function-miniquake-world-bsp-addtofatpvs-function-addtofatpvs-map-origin-nodenumber-destination-src-miniquake-world-bsp-ml-1065465752"></a>
### addToFatPvs

```ml
function addToFatPvs(map, origin, nodeNumber, destination)
```

Add state for add to fat pvs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `addToFatPvs`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `addToFatPvs`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L537)

<a id="function-function-miniquake-world-bsp-anyleafvisible-function-anyleafvisible-pvs-leaves-src-miniquake-world-bsp-ml-2106350010"></a>
### anyLeafVisible

```ml
function anyLeafVisible(pvs, leaves)
```

Report whether any leaf visible holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pvs` | `dynamic` | — | The pvs input consumed by `anyLeafVisible`. |
| `leaves` | `dynamic` | — | The leaves input consumed by `anyLeafVisible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L511)

<a id="function-function-miniquake-world-bsp-appendtouchedleaves-function-appendtouchedleaves-map-nodenumber-mins-maxs-limit-result-src-miniquake-world-bsp-ml-1634686126"></a>
### appendTouchedLeaves

```ml
function appendTouchedLeaves(map, nodeNumber, mins, maxs, limit, result)
```

Add state for append touched leaves.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `appendTouchedLeaves`. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `appendTouchedLeaves`. |
| `mins` | `dynamic` | — | The mins input consumed by `appendTouchedLeaves`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `appendTouchedLeaves`. |
| `limit` | `dynamic` | — | The limit input consumed by `appendTouchedLeaves`. |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L481)

<a id="function-function-miniquake-world-bsp-boxonbspplaneside-function-boxonbspplaneside-mins-maxs-plane-src-miniquake-world-bsp-ml-1228988657"></a>
### boxOnBspPlaneSide

```ml
function boxOnBspPlaneSide(mins, maxs, plane)
```

SV_FindTouchedLeafs stores every non-solid world leaf intersected by an entity's linked abs bounds (up to MAX_ENT_LEAFS).  Large doors and moving walls often have their origin in a different PVS from the face seen by the player, so testing only Mod_PointInLeaf(origin) makes a physically present brush model disappear.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `boxOnBspPlaneSide`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `boxOnBspPlaneSide`. |
| `plane` | `dynamic` | — | The plane input consumed by `boxOnBspPlaneSide`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L447)

<a id="function-function-miniquake-world-bsp-child-function-child-node-side-src-miniquake-world-bsp-ml-1012257396"></a>
### child

```ml
function child(node, side)
```

Implements the `child` operation for `miniquake.world_bsp` (child).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | The node input consumed by `child`. |
| `side` | `dynamic` | — | The side input consumed by `child`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L159)

<a id="global-global-miniquake-world-bsp-collisionhullcache-collisionhullcache-src-miniquake-world-bsp-ml-372683167"></a>
### collisionHullCache

```ml
collisionHullCache
```

Tracks the module-level collision hull cache state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L30)

<a id="global-global-miniquake-world-bsp-collisionhullcachemapkey-collisionhullcachemapkey-src-miniquake-world-bsp-ml-1394241701"></a>
### collisionHullCacheMapKey

```ml
collisionHullCacheMapKey
```

Tracks the module-level collision hull cache map key state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L28)

<a id="function-function-miniquake-world-bsp-createhull-function-createhull-map-hullindex-src-miniquake-world-bsp-ml-794574160"></a>
### createHull

```ml
function createHull(map, hullIndex)
```

Create and initialize hull.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `createHull`. |
| `hullIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L78)

<a id="function-function-miniquake-world-bsp-createmodelhull-function-createmodelhull-map-modelindex-hullindex-src-miniquake-world-bsp-ml-1770469681"></a>
### createModelHull

```ml
function createModelHull(map, modelIndex, hullIndex)
```

Create and initialize model hull.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `createModelHull`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `hullIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L681)

<a id="function-function-miniquake-world-bsp-decompressleafpvs-function-decompressleafpvs-map-leafindex-src-miniquake-world-bsp-ml-1754212501"></a>
### decompressLeafPvs

```ml
function decompressLeafPvs(map, leafIndex)
```

Decompress one leaf visibility row without consulting the level cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `decompressLeafPvs`. |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L373)

<a id="function-function-miniquake-world-bsp-drawingclipnodes-function-drawingclipnodes-map-src-miniquake-world-bsp-ml-770568455"></a>
### drawingClipNodes

```ml
function drawingClipNodes(map)
```

Draws ing clip nodes for `miniquake.world_bsp`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `drawingClipNodes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L48)

<a id="function-function-miniquake-world-bsp-emptyplane-function-emptyplane-src-miniquake-world-bsp-ml-2096626199"></a>
### emptyPlane

```ml
function emptyPlane()
```

Implements the `emptyPlane` operation for `miniquake.world_bsp` (empty plane).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L42)

<a id="function-function-miniquake-world-bsp-fatpvs-function-fatpvs-map-origin-src-miniquake-world-bsp-ml-2048412877"></a>
### fatPvs

```ml
function fatPvs(map, origin)
```

SV_FatPVS merges the PVS on both sides of planes within eight units of the view point.  This prevents entities on a doorway/portal boundary from blinking out as the camera crosses it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `fatPvs`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L567)

<a id="global-global-miniquake-world-bsp-fatpvsscratch-fatpvsscratch-src-miniquake-world-bsp-ml-1467055409"></a>
### fatPvsScratch

```ml
fatPvsScratch
```

Tracks the module-level fat pvs scratch state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L26)

<a id="global-global-miniquake-world-bsp-fatpvsscratchmapkey-fatpvsscratchmapkey-src-miniquake-world-bsp-ml-1446185977"></a>
### fatPvsScratchMapKey

```ml
fatPvsScratchMapKey
```

Tracks the module-level fat pvs scratch map key state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L24)

<a id="function-function-miniquake-world-bsp-findplayerstart-function-findplayerstart-map-src-miniquake-world-bsp-ml-595836655"></a>
### findPlayerStart

```ml
function findPlayerStart(map)
```

Return player start.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `findPlayerStart`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L597)

<a id="function-function-miniquake-world-bsp-hullforbounds-function-hullforbounds-map-mins-maxs-src-miniquake-world-bsp-ml-260986723"></a>
### hullForBounds

```ml
function hullForBounds(map, mins, maxs)
```

Implements the `hullForBounds` operation for `miniquake.world_bsp` (hull for bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `hullForBounds`. |
| `mins` | `dynamic` | — | The mins input consumed by `hullForBounds`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `hullForBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L276)

<a id="function-function-miniquake-world-bsp-hullindexforbounds-function-hullindexforbounds-mins-maxs-src-miniquake-world-bsp-ml-1950002817"></a>
### hullIndexForBounds

```ml
function hullIndexForBounds(mins, maxs)
```

----------------------------------------------------------------------------- Server brush-model collision. WinQuake selects the hull from the moving object's width, then uses the headnode of the addressed BSP submodel.  This is what makes func_door, func_plat, func_train and other SOLID_BSP entities participate in the same exact collision path as the world. -----------------------------------------------------------------------------

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `hullIndexForBounds`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `hullIndexForBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L670)

<a id="function-function-miniquake-world-bsp-leafforpoint-function-leafforpoint-map-point-src-miniquake-world-bsp-ml-1850364571"></a>
### leafForPoint

```ml
function leafForPoint(map, point)
```

Implements the `leafForPoint` operation for `miniquake.world_bsp` (leaf for point).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `leafForPoint`. |
| `point` | `dynamic` | — | The point input consumed by `leafForPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L348)

<a id="function-function-miniquake-world-bsp-leafpvs-function-leafpvs-map-leafindex-src-miniquake-world-bsp-ml-586341487"></a>
### leafPvs

```ml
function leafPvs(map, leafIndex)
```

Implements the `leafPvs` operation for `miniquake.world_bsp` (leaf pvs).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `leafPvs`. |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L411)

<a id="global-global-miniquake-world-bsp-leafpvscache-leafpvscache-src-miniquake-world-bsp-ml-1316062547"></a>
### leafPvsCache

```ml
leafPvsCache
```

Tracks the module-level leaf pvs cache state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L22)

<a id="global-global-miniquake-world-bsp-leafpvscachemapkey-leafpvscachemapkey-src-miniquake-world-bsp-ml-725857053"></a>
### leafPvsCacheMapKey

```ml
leafPvsCacheMapKey
```

The original engine keeps one decompression buffer, but MiniQuake's immutable protocol/render consumers otherwise allocate and expand the same leaf row on every server frame and whenever the camera enters a new leaf.  Populate this map-local table while the loading plaque is visible.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L20)

<a id="function-function-miniquake-world-bsp-leafvisible-function-leafvisible-pvs-leafindex-src-miniquake-world-bsp-ml-144405414"></a>
### leafVisible

```ml
function leafVisible(pvs, leafIndex)
```

Return the pre-expanded world-face visibility mask for one view leaf. Report whether leaf visible holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pvs` | `dynamic` | — | The pvs input consumed by `leafVisible`. |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L431)

<a id="function-function-miniquake-world-bsp-mod-leafpvs-function-mod-leafpvs-leafindex-map-src-miniquake-world-bsp-ml-1703439961"></a>
### Mod_LeafPVS

```ml
function Mod_LeafPVS(leafIndex, map)
```

Mirror Quake's Mod_LeafPVS routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `map` | `dynamic` | — | The map input consumed by `Mod_LeafPVS`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L423)

<a id="function-function-miniquake-world-bsp-mod-makehull0-function-mod-makehull0-map-src-miniquake-world-bsp-ml-1266435539"></a>
### Mod_MakeHull0

```ml
function Mod_MakeHull0(map)
```

Mirror Quake's Mod_MakeHull0 routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `Mod_MakeHull0`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L759)

<a id="function-function-miniquake-world-bsp-mod-pointinleaf-function-mod-pointinleaf-point-map-src-miniquake-world-bsp-ml-1309689935"></a>
### Mod_PointInLeaf

```ml
function Mod_PointInLeaf(point, map)
```

Mirror Quake's Mod_PointInLeaf routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `point` | `dynamic` | — | The point input consumed by `Mod_PointInLeaf`. |
| `map` | `dynamic` | — | The map input consumed by `Mod_PointInLeaf`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L366)

<a id="global-global-miniquake-world-bsp-modelhullcache-modelhullcache-src-miniquake-world-bsp-ml-607705805"></a>
### modelHullCache

```ml
modelHullCache
```

Tracks the module-level model hull cache state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L34)

<a id="global-global-miniquake-world-bsp-modelhullcachemapkey-modelhullcachemapkey-src-miniquake-world-bsp-ml-61230019"></a>
### modelHullCacheMapKey

```ml
modelHullCacheMapKey
```

Tracks the module-level model hull cache map key state owned by `miniquake.world_bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L32)

<a id="function-function-miniquake-world-bsp-orvisibility-function-orvisibility-destination-source-src-miniquake-world-bsp-ml-1089882564"></a>
### orVisibility

```ml
function orVisibility(destination, source)
```

Implements the `orVisibility` operation for `miniquake.world_bsp` (or visibility).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L521)

<a id="function-function-miniquake-world-bsp-planedistance-function-planedistance-plane-point-src-miniquake-world-bsp-ml-1281433485"></a>
### planeDistance

```ml
function planeDistance(plane, point)
```

Implements the `planeDistance` operation for `miniquake.world_bsp` (plane distance).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `planeDistance`. |
| `point` | `dynamic` | — | The point input consumed by `planeDistance`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L149)

<a id="function-function-miniquake-world-bsp-playerhull-function-playerhull-map-src-miniquake-world-bsp-ml-702377827"></a>
### playerHull

```ml
function playerHull(map)
```

Original WinQuake naming aliases used by the host, QuakeC builtins and GL renderer.  Keeping these at the world boundary avoids duplicating hull rules.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `playerHull`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L621)

<a id="function-function-miniquake-world-bsp-pointcontents-function-pointcontents-hull-point-src-miniquake-world-bsp-ml-1852234246"></a>
### pointContents

```ml
function pointContents(hull, point)
```

Implements the `pointContents` operation for `miniquake.world_bsp` (point contents).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `pointContents`. |
| `point` | `dynamic` | — | The point input consumed by `pointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L183)

<a id="function-function-miniquake-world-bsp-pointcontentsfromnode-function-pointcontentsfromnode-hull-number-point-src-miniquake-world-bsp-ml-1890433453"></a>
### pointContentsFromNode

```ml
function pointContentsFromNode(hull, number, point)
```

Implements the `pointContentsFromNode` operation for `miniquake.world_bsp` (point contents from node).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `pointContentsFromNode`. |
| `number` | `dynamic` | — | The number input consumed by `pointContentsFromNode`. |
| `point` | `dynamic` | — | The point input consumed by `pointContentsFromNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L168)

<a id="function-function-miniquake-world-bsp-pointcontentsworld-function-pointcontentsworld-map-point-src-miniquake-world-bsp-ml-1920086723"></a>
### pointContentsWorld

```ml
function pointContentsWorld(map, point)
```

Implements the `pointContentsWorld` operation for `miniquake.world_bsp` (point contents world).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `pointContentsWorld`. |
| `point` | `dynamic` | — | The point input consumed by `pointContentsWorld`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L339)

<a id="function-function-miniquake-world-bsp-pointleaf-function-pointleaf-map-point-src-miniquake-world-bsp-ml-1409426443"></a>
### pointLeaf

```ml
function pointLeaf(map, point)
```

Implements the `pointLeaf` operation for `miniquake.world_bsp` (point leaf).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `pointLeaf`. |
| `point` | `dynamic` | — | The point input consumed by `pointLeaf`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L657)

<a id="function-function-miniquake-world-bsp-precachecollisionhulls-function-precachecollisionhulls-map-src-miniquake-world-bsp-ml-564986523"></a>
### precacheCollisionHulls

```ml
function precacheCollisionHulls(map)
```

Build the three immutable world hull descriptors while the loading plaque is active. Hull zero includes Mod_MakeHull0's expanded drawing nodes and was previously rebuilt for every point trace, producing hundreds of kilobytes of short-lived objects per gameplay frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `precacheCollisionHulls`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L108)

<a id="function-function-miniquake-world-bsp-precacheleafpvs-function-precacheleafpvs-map-src-miniquake-world-bsp-ml-1351571731"></a>
### precacheLeafPvs

```ml
function precacheLeafPvs(map)
```

Pre-expand all visibility rows before gameplay starts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `precacheLeafPvs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L393)

<a id="function-function-miniquake-world-bsp-radiusfrombounds-function-radiusfrombounds-mins-maxs-src-miniquake-world-bsp-ml-1374482257"></a>
### RadiusFromBounds

```ml
function RadiusFromBounds(mins, maxs)
```

Implements the `RadiusFromBounds` operation for `miniquake.world_bsp` (radius from bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `RadiusFromBounds`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `RadiusFromBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L747)

<a id="function-function-miniquake-world-bsp-recursivehullcheck-function-recursivehullcheck-hull-number-p1fraction-p2fraction-p1-p2-trace-src-miniquake-world-bsp-ml-558948890"></a>
### recursiveHullCheck

```ml
function recursiveHullCheck(hull, number, p1Fraction, p2Fraction, p1, p2, trace)
```

Implements the `recursiveHullCheck` operation for `miniquake.world_bsp` (recursive hull check).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `recursiveHullCheck`. |
| `number` | `dynamic` | — | The number input consumed by `recursiveHullCheck`. |
| `p1Fraction` | `dynamic` | — | The p1 fraction input consumed by `recursiveHullCheck`. |
| `p2Fraction` | `dynamic` | — | The p2 fraction input consumed by `recursiveHullCheck`. |
| `p1` | `dynamic` | — | The p1 input consumed by `recursiveHullCheck`. |
| `p2` | `dynamic` | — | The p2 input consumed by `recursiveHullCheck`. |
| `trace` | `dynamic` | — | The trace input consumed by `recursiveHullCheck`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L195)

<a id="function-function-miniquake-world-bsp-touchedleaves-function-touchedleaves-map-mins-maxs-limit-src-miniquake-world-bsp-ml-2053191476"></a>
### touchedLeaves

```ml
function touchedLeaves(map, mins, maxs, limit)
```

Implements the `touchedLeaves` operation for `miniquake.world_bsp` (touched leaves).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `touchedLeaves`. |
| `mins` | `dynamic` | — | The mins input consumed by `touchedLeaves`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `touchedLeaves`. |
| `limit` | `dynamic` | — | The limit input consumed by `touchedLeaves`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L503)

<a id="function-function-miniquake-world-bsp-trace-function-trace-map-start-mins-maxs-finish-src-miniquake-world-bsp-ml-1739276578"></a>
### trace

```ml
function trace(map, start, mins, maxs, finish)
```

Trace the requested value through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `trace`. |
| `start` | `dynamic` | — | The start input consumed by `trace`. |
| `mins` | `dynamic` | — | The mins input consumed by `trace`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `trace`. |
| `finish` | `dynamic` | — | The finish input consumed by `trace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L289)

<a id="function-function-miniquake-world-bsp-tracebrushmodel-function-tracebrushmodel-map-modelindex-entityorigin-start-mins-maxs-finish-src-miniquake-world-bsp-ml-2020775282"></a>
### traceBrushModel

```ml
function traceBrushModel(map, modelIndex, entityOrigin, start, mins, maxs, finish)
```

Trace brush model through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `traceBrushModel`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `traceBrushModel`. |
| `start` | `dynamic` | — | The start input consumed by `traceBrushModel`. |
| `mins` | `dynamic` | — | The mins input consumed by `traceBrushModel`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `traceBrushModel`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceBrushModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L721)

<a id="function-function-miniquake-world-bsp-traceinhull-function-traceinhull-hull-start-finish-src-miniquake-world-bsp-ml-2080955689"></a>
### traceInHull

```ml
function traceInHull(hull, start, finish)
```

Trace in hull through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `traceInHull`. |
| `start` | `dynamic` | — | The start input consumed by `traceInHull`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceInHull`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L266)

<a id="function-function-miniquake-world-bsp-traceline-function-traceline-map-start-finish-src-miniquake-world-bsp-ml-1380149312"></a>
### traceLine

```ml
function traceLine(map, start, finish)
```

Implements the `traceLine` operation for `miniquake.world_bsp` (trace line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `traceLine`. |
| `start` | `dynamic` | — | The start input consumed by `traceLine`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L303)

<a id="function-function-miniquake-world-bsp-traceplayer-function-traceplayer-map-start-finish-src-miniquake-world-bsp-ml-932554046"></a>
### tracePlayer

```ml
function tracePlayer(map, start, finish)
```

Trace player through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `tracePlayer`. |
| `start` | `dynamic` | — | The start input consumed by `tracePlayer`. |
| `finish` | `dynamic` | — | The finish input consumed by `tracePlayer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L637)

<a id="function-function-miniquake-world-bsp-tracepoint-function-tracepoint-map-start-finish-src-miniquake-world-bsp-ml-692725890"></a>
### tracePoint

```ml
function tracePoint(map, start, finish)
```

Trace point through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `tracePoint`. |
| `start` | `dynamic` | — | The start input consumed by `tracePoint`. |
| `finish` | `dynamic` | — | The finish input consumed by `tracePoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L629)

<a id="function-function-miniquake-world-bsp-truepointcontents-function-truepointcontents-map-point-src-miniquake-world-bsp-ml-1869749727"></a>
### truePointContents

```ml
function truePointContents(map, point)
```

Implements the `truePointContents` operation for `miniquake.world_bsp` (true point contents).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `truePointContents`. |
| `point` | `dynamic` | — | The point input consumed by `truePointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L311)

<a id="function-function-miniquake-world-bsp-worldpointcontents-function-worldpointcontents-map-point-src-miniquake-world-bsp-ml-1399867307"></a>
### worldPointContents

```ml
function worldPointContents(map, point)
```

Implements the `worldPointContents` operation for `miniquake.world_bsp` (world point contents).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `worldPointContents`. |
| `point` | `dynamic` | — | The point input consumed by `worldPointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L650)

<a id="function-function-miniquake-world-bsp-zerovector-function-zerovector-src-miniquake-world-bsp-ml-1418613103"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.world_bsp` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_bsp.ml#L37)
