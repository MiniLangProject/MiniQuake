# `src/miniquake/world.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.world`](Package-miniquake-world-975572581.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/server_collision.ml` as `collision` → [src/miniquake/server_collision.ml](File-src-miniquake-server-collision-ml-849122018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `bspworld` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)
- `miniquake/world_hull.ml` as `boxworld` → [src/miniquake/world_hull.ml](File-src-miniquake-world-hull-ml-1085637404.md)

## Declarations

<a id="function-function-miniquake-world-absolute-function-absolute-value-src-miniquake-world-ml-465765588"></a>
### absolute

```ml
function absolute(value)
```

Implements the `absolute` operation for `miniquake.world` (absolute).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absolute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L103)

<a id="constant-constant-miniquake-world-area-depth-const-area-depth-4-src-miniquake-world-ml-1193890564"></a>
### AREA_DEPTH

```ml
const AREA_DEPTH = 4
```

Defines the area depth value used by `miniquake.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L22)

<a id="constant-constant-miniquake-world-area-nodes-const-area-nodes-32-src-miniquake-world-ml-188619681"></a>
### AREA_NODES

```ml
const AREA_NODES = 32
```

Defines the area nodes value used by `miniquake.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L24)

- [miniquake.world.AreaNode](Type-miniquake-world-areanode-2027303828.md) — struct
<a id="function-function-miniquake-world-boxesoverlap-function-boxesoverlap-minsa-maxsa-minsb-maxsb-src-miniquake-world-ml-2054416409"></a>
### boxesOverlap

```ml
function boxesOverlap(minsA, maxsA, minsB, maxsB)
```

Implements the `boxesOverlap` operation for `miniquake.world` (boxes overlap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `minsA` | `dynamic` | — | The mins a input consumed by `boxesOverlap`. |
| `maxsA` | `dynamic` | — | The maxs a input consumed by `boxesOverlap`. |
| `minsB` | `dynamic` | — | The mins b input consumed by `boxesOverlap`. |
| `maxsB` | `dynamic` | — | The maxs b input consumed by `boxesOverlap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L367)

<a id="function-function-miniquake-world-boxplane-function-boxplane-state-planeindex-src-miniquake-world-ml-1482002286"></a>
### boxPlane

```ml
function boxPlane(state, planeIndex)
```

Implements the `boxPlane` operation for `miniquake.world` (box plane).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `boxPlane`. |
| `planeIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L303)

<a id="function-function-miniquake-world-choosetrace-function-choosetrace-best-candidate-src-miniquake-world-ml-853935026"></a>
### chooseTrace

```ml
function chooseTrace(best, candidate)
```

Implements the `chooseTrace` operation for `miniquake.world` (choose trace).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `best` | `dynamic` | — | The best input consumed by `chooseTrace`. |
| `candidate` | `dynamic` | — | The candidate input consumed by `chooseTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L646)

<a id="function-function-miniquake-world-entityhastouch-function-entityhastouch-state-entityindex-src-miniquake-world-ml-36556481"></a>
### entityHasTouch

```ml
function entityHasTouch(state, entityIndex)
```

Implements the `entityHasTouch` operation for `miniquake.world` (entity has touch).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `entityHasTouch`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L347)

<a id="function-function-miniquake-world-entitymodel-function-entitymodel-state-entityindex-src-miniquake-world-ml-2024700845"></a>
### entityModel

```ml
function entityModel(state, entityIndex)
```

Implements the `entityModel` operation for `miniquake.world` (entity model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `entityModel`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L178)

<a id="function-function-miniquake-world-entitynumber-function-entitynumber-state-entityindex-name-fallback-src-miniquake-world-ml-1378434040"></a>
### entityNumber

```ml
function entityNumber(state, entityIndex, name, fallback)
```

Return entity number derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `entityNumber`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L151)

<a id="function-function-miniquake-world-entityvalid-function-entityvalid-state-entityindex-src-miniquake-world-ml-1890037347"></a>
### entityValid

```ml
function entityValid(state, entityIndex)
```

Report whether entity valid holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `entityValid`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L125)

<a id="function-function-miniquake-world-entityvector-function-entityvector-state-entityindex-name-src-miniquake-world-ml-1763193422"></a>
### entityVector

```ml
function entityVector(state, entityIndex, name)
```

Implements the `entityVector` operation for `miniquake.world` (entity vector).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `entityVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L135)

<a id="function-function-miniquake-world-executetrigger-function-executetrigger-state-triggerindex-entityindex-src-miniquake-world-ml-78688253"></a>
### executeTrigger

```ml
function executeTrigger(state, triggerIndex, entityIndex)
```

Execute trigger.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `executeTrigger`. |
| `triggerIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L356)

<a id="function-function-miniquake-world-fallbackedict-function-fallbackedict-state-entityindex-src-miniquake-world-ml-188743407"></a>
### fallbackEdict

```ml
function fallbackEdict(state, entityIndex)
```

Implements the `fallbackEdict` operation for `miniquake.world` (fallback edict).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `fallbackEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L111)

<a id="function-function-miniquake-world-hasruntime-inline-function-hasruntime-state-src-miniquake-world-ml-813911675"></a>
### hasRuntime

```ml
inline function hasRuntime(state)
```

Report whether runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `hasRuntime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L118)

<a id="function-function-miniquake-world-hullindex-function-hullindex-mins-maxs-src-miniquake-world-ml-1636560515"></a>
### hullIndex

```ml
function hullIndex(mins, maxs)
```

Return hull index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `hullIndex`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `hullIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L527)

<a id="function-function-miniquake-world-makestate-function-makestate-server-map-src-miniquake-world-ml-1123533824"></a>
### makeState

```ml
function makeState(server, map)
```

Creates state for `miniquake.world`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `map` | `dynamic` | — | The map input consumed by `makeState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L188)

<a id="constant-constant-miniquake-world-max-ent-leafs-const-max-ent-leafs-16-src-miniquake-world-ml-1002838403"></a>
### MAX_ENT_LEAFS

```ml
const MAX_ENT_LEAFS = 16
```

Defines the max ent leafs value used by `miniquake.world`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L26)

- [miniquake.world.MoveClip](Type-miniquake-world-moveclip-1445446358.md) — struct
<a id="function-function-miniquake-world-removeentity-function-removeentity-values-entityindex-src-miniquake-world-ml-1747168718"></a>
### removeEntity

```ml
function removeEntity(values, entityIndex)
```

Release state for remove entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `removeEntity`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L274)

<a id="function-function-miniquake-world-rotatedbounds-function-rotatedbounds-origin-mins-maxs-src-miniquake-world-ml-479189935"></a>
### rotatedBounds

```ml
function rotatedBounds(origin, mins, maxs)
```

Implements the `rotatedBounds` operation for `miniquake.world` (rotated bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `mins` | `dynamic` | — | The mins input consumed by `rotatedBounds`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `rotatedBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L404)

<a id="function-function-miniquake-world-rotatefrommodel-function-rotatefrommodel-value-angles-src-miniquake-world-ml-1975701880"></a>
### rotateFromModel

```ml
function rotateFromModel(value, angles)
```

Implements the `rotateFromModel` operation for `miniquake.world` (rotate from model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `rotateFromModel`. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L575)

<a id="function-function-miniquake-world-rotateintomodel-function-rotateintomodel-value-angles-src-miniquake-world-ml-1103862396"></a>
### rotateIntoModel

```ml
function rotateIntoModel(value, angles)
```

Implements the `rotateIntoModel` operation for `miniquake.world` (rotate into model).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `rotateIntoModel`. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L563)

<a id="function-function-miniquake-world-sv-boxonplaneside-function-sv-boxonplaneside-mins-maxs-plane-src-miniquake-world-ml-2071794423"></a>
### SV_BoxOnPlaneSide

```ml
function SV_BoxOnPlaneSide(mins, maxs, plane)
```

Apply the Quake-compatible sv box on plane side behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `SV_BoxOnPlaneSide`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_BoxOnPlaneSide`. |
| `plane` | `dynamic` | — | The plane input consumed by `SV_BoxOnPlaneSide`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L223)

<a id="function-function-miniquake-world-sv-bsphullpointcontents-function-sv-bsphullpointcontents-hull-number-point-src-miniquake-world-ml-1231122081"></a>
### SV_BspHullPointContents

```ml
function SV_BspHullPointContents(hull, number, point)
```

Apply the Quake-compatible sv bsp hull point contents behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `SV_BspHullPointContents`. |
| `number` | `dynamic` | — | The number input consumed by `SV_BspHullPointContents`. |
| `point` | `dynamic` | — | The point input consumed by `SV_BspHullPointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L504)

<a id="function-function-miniquake-world-sv-clearworld-function-sv-clearworld-server-map-src-miniquake-world-ml-420347972"></a>
### SV_ClearWorld

```ml
function SV_ClearWorld(server, map)
```

Apply the Quake-compatible sv clear world behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `map` | `dynamic` | — | The map input consumed by `SV_ClearWorld`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L263)

<a id="function-function-miniquake-world-sv-clipmovetoentity-function-sv-clipmovetoentity-state-entityindex-start-mins-maxs-finish-src-miniquake-world-ml-350080316"></a>
### SV_ClipMoveToEntity

```ml
function SV_ClipMoveToEntity(state, entityIndex, start, mins, maxs, finish)
```

Apply the Quake-compatible sv clip move to entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_ClipMoveToEntity`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `SV_ClipMoveToEntity`. |
| `mins` | `dynamic` | — | The mins input consumed by `SV_ClipMoveToEntity`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_ClipMoveToEntity`. |
| `finish` | `dynamic` | — | The finish input consumed by `SV_ClipMoveToEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L599)

<a id="function-function-miniquake-world-sv-cliptolinks-function-sv-cliptolinks-state-nodeindex-clip-src-miniquake-world-ml-1436995886"></a>
### SV_ClipToLinks

```ml
function SV_ClipToLinks(state, nodeIndex, clip)
```

Apply the Quake-compatible sv clip to links behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_ClipToLinks`. |
| `nodeIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `clip` | `dynamic` | — | The clip input consumed by `SV_ClipToLinks`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L654)

<a id="function-function-miniquake-world-sv-createareanode-function-sv-createareanode-state-depth-mins-maxs-src-miniquake-world-ml-269706365"></a>
### SV_CreateAreaNode

```ml
function SV_CreateAreaNode(state, depth, mins, maxs)
```

Apply the Quake-compatible sv create area node behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_CreateAreaNode`. |
| `depth` | `dynamic` | — | The depth input consumed by `SV_CreateAreaNode`. |
| `mins` | `dynamic` | — | The mins input consumed by `SV_CreateAreaNode`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_CreateAreaNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L232)

<a id="function-function-miniquake-world-sv-findtouchedleafs-function-sv-findtouchedleafs-state-entityindex-nodenumber-src-miniquake-world-ml-1963694724"></a>
### SV_FindTouchedLeafs

```ml
function SV_FindTouchedLeafs(state, entityIndex, nodeNumber)
```

Apply the Quake-compatible sv find touched leafs behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_FindTouchedLeafs`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `nodeNumber` | `dynamic` | — | The node number input consumed by `SV_FindTouchedLeafs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L316)

<a id="function-function-miniquake-world-sv-hullforbox-function-sv-hullforbox-mins-maxs-src-miniquake-world-ml-798245171"></a>
### SV_HullForBox

```ml
function SV_HullForBox(mins, maxs)
```

Apply the Quake-compatible sv hull for box behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `SV_HullForBox`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_HullForBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L215)

<a id="function-function-miniquake-world-sv-hullforentity-function-sv-hullforentity-state-entityindex-mins-maxs-src-miniquake-world-ml-645109263"></a>
### SV_HullForEntity

```ml
function SV_HullForEntity(state, entityIndex, mins, maxs)
```

Apply the Quake-compatible sv hull for entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_HullForEntity`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `mins` | `dynamic` | — | The mins input consumed by `SV_HullForEntity`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_HullForEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L539)

<a id="function-function-miniquake-world-sv-hullpointcontents-function-sv-hullpointcontents-hull-number-point-src-miniquake-world-ml-392651405"></a>
### SV_HullPointContents

```ml
function SV_HullPointContents(hull, number, point)
```

Apply the Quake-compatible sv hull point contents behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `SV_HullPointContents`. |
| `number` | `dynamic` | — | The number input consumed by `SV_HullPointContents`. |
| `point` | `dynamic` | — | The point input consumed by `SV_HullPointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L496)

<a id="function-function-miniquake-world-sv-initboxhull-function-sv-initboxhull-src-miniquake-world-ml-356378883"></a>
### SV_InitBoxHull

```ml
function SV_InitBoxHull()
```

Apply the Quake-compatible sv init box hull behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L208)

<a id="function-function-miniquake-world-sv-linkedict-function-sv-linkedict-state-entityindex-touchtriggers-src-miniquake-world-ml-923426197"></a>
### SV_LinkEdict

```ml
function SV_LinkEdict(state, entityIndex, touchTriggers)
```

Apply the Quake-compatible sv link edict behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_LinkEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `touchTriggers` | `dynamic` | — | The touch triggers input consumed by `SV_LinkEdict`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L421)

<a id="function-function-miniquake-world-sv-move-function-sv-move-state-start-mins-maxs-finish-movetype-passedentity-src-miniquake-world-ml-1452695721"></a>
### SV_Move

```ml
function SV_Move(state, start, mins, maxs, finish, moveType, passedEntity)
```

Apply the Quake-compatible sv move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_Move`. |
| `start` | `dynamic` | — | The start input consumed by `SV_Move`. |
| `mins` | `dynamic` | — | The mins input consumed by `SV_Move`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_Move`. |
| `finish` | `dynamic` | — | The finish input consumed by `SV_Move`. |
| `moveType` | `dynamic` | — | The move type input consumed by `SV_Move`. |
| `passedEntity` | `dynamic` | — | The passed entity input consumed by `SV_Move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L708)

<a id="function-function-miniquake-world-sv-movebounds-function-sv-movebounds-start-mins-maxs-finish-src-miniquake-world-ml-72938572"></a>
### SV_MoveBounds

```ml
function SV_MoveBounds(start, mins, maxs, finish)
```

Apply the Quake-compatible sv move bounds behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start` | `dynamic` | — | The start input consumed by `SV_MoveBounds`. |
| `mins` | `dynamic` | — | The mins input consumed by `SV_MoveBounds`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SV_MoveBounds`. |
| `finish` | `dynamic` | — | The finish input consumed by `SV_MoveBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L639)

<a id="function-function-miniquake-world-sv-pointcontents-function-sv-pointcontents-state-point-src-miniquake-world-ml-1937882034"></a>
### SV_PointContents

```ml
function SV_PointContents(state, point)
```

Apply the Quake-compatible sv point contents behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_PointContents`. |
| `point` | `dynamic` | — | The point input consumed by `SV_PointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L511)

<a id="function-function-miniquake-world-sv-recursivehullcheck-function-sv-recursivehullcheck-hull-number-p1fraction-p2fraction-p1-p2-trace-src-miniquake-world-ml-15204624"></a>
### SV_RecursiveHullCheck

```ml
function SV_RecursiveHullCheck(hull, number, p1Fraction, p2Fraction, p1, p2, trace)
```

Apply the Quake-compatible sv recursive hull check behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hull` | `dynamic` | — | The hull input consumed by `SV_RecursiveHullCheck`. |
| `number` | `dynamic` | — | The number input consumed by `SV_RecursiveHullCheck`. |
| `p1Fraction` | `dynamic` | — | The p1 fraction input consumed by `SV_RecursiveHullCheck`. |
| `p2Fraction` | `dynamic` | — | The p2 fraction input consumed by `SV_RecursiveHullCheck`. |
| `p1` | `dynamic` | — | The p1 input consumed by `SV_RecursiveHullCheck`. |
| `p2` | `dynamic` | — | The p2 input consumed by `SV_RecursiveHullCheck`. |
| `trace` | `dynamic` | — | The trace input consumed by `SV_RecursiveHullCheck`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L588)

<a id="function-function-miniquake-world-sv-testentityposition-function-sv-testentityposition-state-entityindex-src-miniquake-world-ml-30564201"></a>
### SV_TestEntityPosition

```ml
function SV_TestEntityPosition(state, entityIndex)
```

Apply the Quake-compatible sv test entity position behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_TestEntityPosition`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L726)

<a id="function-function-miniquake-world-sv-touchlinks-function-sv-touchlinks-state-entityindex-nodeindex-src-miniquake-world-ml-1883093175"></a>
### SV_TouchLinks

```ml
function SV_TouchLinks(state, entityIndex, nodeIndex)
```

Apply the Quake-compatible sv touch links behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_TouchLinks`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `nodeIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L375)

<a id="function-function-miniquake-world-sv-truepointcontents-function-sv-truepointcontents-state-point-src-miniquake-world-ml-1448666026"></a>
### SV_TruePointContents

```ml
function SV_TruePointContents(state, point)
```

Apply the Quake-compatible sv true point contents behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_TruePointContents`. |
| `point` | `dynamic` | — | The point input consumed by `SV_TruePointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L520)

<a id="function-function-miniquake-world-sv-unlinkedict-function-sv-unlinkedict-state-entityindex-src-miniquake-world-ml-586684293"></a>
### SV_UnlinkEdict

```ml
function SV_UnlinkEdict(state, entityIndex)
```

Apply the Quake-compatible sv unlink edict behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `SV_UnlinkEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L285)

<a id="function-function-miniquake-world-world-settouchenabled-function-world-settouchenabled-state-entityindex-enabled-src-miniquake-world-ml-905993404"></a>
### World_SetTouchEnabled

```ml
function World_SetTouchEnabled(state, entityIndex, enabled)
```

Report whether world set touch enabled holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.world` state used by `World_SetTouchEnabled`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L338)

- [miniquake.world.WorldAreaState](Type-miniquake-world-worldareastate-2138639567.md) — struct
<a id="function-function-miniquake-world-zerovector-function-zerovector-src-miniquake-world-ml-1351725999"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.world` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world.ml#L97)
