# `src/miniquake/server_collision.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.server_collision`](Package-miniquake-server-collision-778320851.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)
- `miniquake/world_hull.ml` as `boxhull` → [src/miniquake/world_hull.ml](File-src-miniquake-world-hull-ml-1085637404.md)

## Declarations

<a id="constant-constant-miniquake-server-collision-area-depth-const-area-depth-4-src-miniquake-server-collision-ml-796592628"></a>
### AREA_DEPTH

```ml
const AREA_DEPTH = 4
```

WinQuake's AREA_DEPTH=4 tree contains at most 31 nodes. Edicts are linked into exactly one solid or trigger list at the deepest node that fully contains their expanded bounds.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L173)

<a id="constant-constant-miniquake-server-collision-area-node-capacity-const-area-node-capacity-31-src-miniquake-server-collision-ml-1170225350"></a>
### AREA_NODE_CAPACITY

```ml
const AREA_NODE_CAPACITY = 31
```

Defines the area node capacity value used by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L175)

<a id="global-global-miniquake-server-collision-areaentitynext-areaentitynext-src-miniquake-server-collision-ml-1931200147"></a>
### areaEntityNext

```ml
areaEntityNext
```

Tracks the module-level area entity next state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L193)

<a id="global-global-miniquake-server-collision-areaentitynode-areaentitynode-src-miniquake-server-collision-ml-1144308049"></a>
### areaEntityNode

```ml
areaEntityNode
```

Tracks the module-level area entity node state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L197)

<a id="global-global-miniquake-server-collision-areaentityprevious-areaentityprevious-src-miniquake-server-collision-ml-1183662579"></a>
### areaEntityPrevious

```ml
areaEntityPrevious
```

Tracks the module-level area entity previous state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L195)

<a id="global-global-miniquake-server-collision-areaentitytrigger-areaentitytrigger-src-miniquake-server-collision-ml-1714233537"></a>
### areaEntityTrigger

```ml
areaEntityTrigger
```

Tracks the module-level area entity trigger state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L199)

<a id="global-global-miniquake-server-collision-areamachine-areamachine-src-miniquake-server-collision-ml-1493328209"></a>
### areaMachine

```ml
areaMachine
```

Tracks the module-level area machine state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L177)

<a id="global-global-miniquake-server-collision-areanodeaxis-areanodeaxis-src-miniquake-server-collision-ml-587877373"></a>
### areaNodeAxis

```ml
areaNodeAxis
```

Tracks the module-level area node axis state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L181)

<a id="global-global-miniquake-server-collision-areanodechild0-areanodechild0-src-miniquake-server-collision-ml-348952307"></a>
### areaNodeChild0

```ml
areaNodeChild0
```

Tracks the module-level area node child0 state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L185)

<a id="global-global-miniquake-server-collision-areanodechild1-areanodechild1-src-miniquake-server-collision-ml-1755948029"></a>
### areaNodeChild1

```ml
areaNodeChild1
```

Tracks the module-level area node child1 state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L187)

<a id="global-global-miniquake-server-collision-areanodecount-areanodecount-src-miniquake-server-collision-ml-755878745"></a>
### areaNodeCount

```ml
areaNodeCount
```

Tracks the module-level area node count state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L179)

<a id="global-global-miniquake-server-collision-areanodedist-areanodedist-src-miniquake-server-collision-ml-989112739"></a>
### areaNodeDist

```ml
areaNodeDist
```

Tracks the module-level area node dist state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L183)

<a id="global-global-miniquake-server-collision-areasolidhead-areasolidhead-src-miniquake-server-collision-ml-2138768593"></a>
### areaSolidHead

```ml
areaSolidHead
```

Tracks the module-level area solid head state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L189)

<a id="global-global-miniquake-server-collision-areatriggerhead-areatriggerhead-src-miniquake-server-collision-ml-1537151209"></a>
### areaTriggerHead

```ml
areaTriggerHead
```

Tracks the module-level area trigger head state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L191)

<a id="function-function-miniquake-server-collision-boxesoverlap-function-boxesoverlap-minsa-maxsa-minsb-maxsb-src-miniquake-server-collision-ml-901832907"></a>
### boxesOverlap

```ml
function boxesOverlap(minsA, maxsA, minsB, maxsB)
```

Implements the `boxesOverlap` operation for `miniquake.server_collision` (boxes overlap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `minsA` | `dynamic` | — | The mins a input consumed by `boxesOverlap`. |
| `maxsA` | `dynamic` | — | The maxs a input consumed by `boxesOverlap`. |
| `minsB` | `dynamic` | — | The mins b input consumed by `boxesOverlap`. |
| `maxsB` | `dynamic` | — | The maxs b input consumed by `boxesOverlap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L414)

<a id="function-function-miniquake-server-collision-checkbottom-function-checkbottom-server-entityindex-src-miniquake-server-collision-ml-1739877629"></a>
### checkBottom

```ml
function checkBottom(server, entityIndex)
```

SV_CheckBottom: first accept the common case where all four lower corners are solid, then trace the midpoint and corners down by two step heights.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L878)

<a id="function-function-miniquake-server-collision-choosetrace-function-choosetrace-best-candidate-src-miniquake-server-collision-ml-1826748902"></a>
### chooseTrace

```ml
function chooseTrace(best, candidate)
```

Implements the `chooseTrace` operation for `miniquake.server_collision` (choose trace).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `best` | `dynamic` | — | The best input consumed by `chooseTrace`. |
| `candidate` | `dynamic` | — | The candidate input consumed by `chooseTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L513)

<a id="function-function-miniquake-server-collision-clipareaentity-function-clipareaentity-server-index-start-mins-maxs-finish-movetype-passedentity-passedowner-passedsizex-boxmins-boxmaxs-best-src-miniquake-server-collision-ml-848626015"></a>
### clipAreaEntity

```ml
function clipAreaEntity(server, index, start, mins, maxs, finish, moveType, passedEntity, passedOwner, passedSizeX, boxMins, boxMaxs, best)
```

Apply the stock SV_ClipToLinks filters to one broadphase candidate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `clipAreaEntity`. |
| `mins` | `dynamic` | — | The mins input consumed by `clipAreaEntity`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `clipAreaEntity`. |
| `finish` | `dynamic` | — | The finish input consumed by `clipAreaEntity`. |
| `moveType` | `dynamic` | — | The move type input consumed by `clipAreaEntity`. |
| `passedEntity` | `dynamic` | — | The passed entity input consumed by `clipAreaEntity`. |
| `passedOwner` | `dynamic` | — | The passed owner input consumed by `clipAreaEntity`. |
| `passedSizeX` | `dynamic` | — | The passed size x input consumed by `clipAreaEntity`. |
| `boxMins` | `dynamic` | — | The box mins input consumed by `clipAreaEntity`. |
| `boxMaxs` | `dynamic` | — | The box maxs input consumed by `clipAreaEntity`. |
| `best` | `dynamic` | — | The best input consumed by `clipAreaEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L538)

<a id="function-function-miniquake-server-collision-clipareanode-function-clipareanode-server-node-start-mins-maxs-finish-movetype-passedentity-passedowner-passedsizex-boxmins-boxmaxs-best-src-miniquake-server-collision-ml-1163729179"></a>
### clipAreaNode

```ml
function clipAreaNode(server, node, start, mins, maxs, finish, moveType, passedEntity, passedOwner, passedSizeX, boxMins, boxMaxs, best)
```

Recursively clip only the area nodes intersected by the swept move bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `node` | `dynamic` | — | The node input consumed by `clipAreaNode`. |
| `start` | `dynamic` | — | The start input consumed by `clipAreaNode`. |
| `mins` | `dynamic` | — | The mins input consumed by `clipAreaNode`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `clipAreaNode`. |
| `finish` | `dynamic` | — | The finish input consumed by `clipAreaNode`. |
| `moveType` | `dynamic` | — | The move type input consumed by `clipAreaNode`. |
| `passedEntity` | `dynamic` | — | The passed entity input consumed by `clipAreaNode`. |
| `passedOwner` | `dynamic` | — | The passed owner input consumed by `clipAreaNode`. |
| `passedSizeX` | `dynamic` | — | The passed size x input consumed by `clipAreaNode`. |
| `boxMins` | `dynamic` | — | The box mins input consumed by `clipAreaNode`. |
| `boxMaxs` | `dynamic` | — | The box maxs input consumed by `clipAreaNode`. |
| `best` | `dynamic` | — | The best input consumed by `clipAreaNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L590)

<a id="function-function-miniquake-server-collision-cliptoentity-function-cliptoentity-server-entityindex-start-mins-maxs-finish-src-miniquake-server-collision-ml-1679328550"></a>
### clipToEntity

```ml
function clipToEntity(server, entityIndex, start, mins, maxs, finish)
```

Trace to entity through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `clipToEntity`. |
| `mins` | `dynamic` | — | The mins input consumed by `clipToEntity`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `clipToEntity`. |
| `finish` | `dynamic` | — | The finish input consumed by `clipToEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L504)

<a id="constant-constant-miniquake-server-collision-collision-offset-cache-size-const-collision-offset-cache-size-64-src-miniquake-server-collision-ml-1498001048"></a>
### COLLISION_OFFSET_CACHE_SIZE

```ml
const COLLISION_OFFSET_CACHE_SIZE = 64
```

The C engine resolves entvars_t members at compile time. MiniLang must look them up by name, but collision invokes the same small field set millions of times while monsters chase. Keep a module-local direct cache so those hot reads do not repeatedly enter the generic VM definition lookup machinery.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L22)

<a id="global-global-miniquake-server-collision-collisionoffsetkeys-collisionoffsetkeys-src-miniquake-server-collision-ml-56249589"></a>
### collisionOffsetKeys

```ml
collisionOffsetKeys
```

Tracks the module-level collision offset keys state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L26)

<a id="global-global-miniquake-server-collision-collisionoffsetmachine-collisionoffsetmachine-src-miniquake-server-collision-ml-1986318577"></a>
### collisionOffsetMachine

```ml
collisionOffsetMachine
```

Tracks the module-level collision offset machine state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L24)

<a id="global-global-miniquake-server-collision-collisionoffsetvalues-collisionoffsetvalues-src-miniquake-server-collision-ml-1073056117"></a>
### collisionOffsetValues

```ml
collisionOffsetValues
```

Tracks the module-level collision offset values state owned by `miniquake.server_collision`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L28)

<a id="function-function-miniquake-server-collision-computedentitybounds-function-computedentitybounds-server-entityindex-src-miniquake-server-collision-ml-1473473071"></a>
### computedEntityBounds

```ml
function computedEntityBounds(server, entityIndex)
```

Computes d entity bounds for `miniquake.server_collision`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L346)

<a id="function-function-miniquake-server-collision-createareanode-function-createareanode-depth-minx-miny-maxx-maxy-src-miniquake-server-collision-ml-1305790992"></a>
### createAreaNode

```ml
function createAreaNode(depth, minX, minY, maxX, maxY)
```

Recursively construct the same horizontal binary partition as SV_CreateAreaNode in world.c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `depth` | `dynamic` | — | The depth input consumed by `createAreaNode`. |
| `minX` | `dynamic` | — | The min x input consumed by `createAreaNode`. |
| `minY` | `dynamic` | — | The min y input consumed by `createAreaNode`. |
| `maxX` | `dynamic` | — | The max x input consumed by `createAreaNode`. |
| `maxY` | `dynamic` | — | The max y input consumed by `createAreaNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L208)

<a id="function-function-miniquake-server-collision-emptyplane-function-emptyplane-src-miniquake-server-collision-ml-268442513"></a>
### emptyPlane

```ml
function emptyPlane()
```

Implements the `emptyPlane` operation for `miniquake.server_collision` (empty plane).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L36)

<a id="function-function-miniquake-server-collision-ensureareatree-function-ensureareatree-server-src-miniquake-server-collision-ml-725368292"></a>
### ensureAreaTree

```ml
function ensureAreaTree(server)
```

Initialize the area tree for a new QuakeC edict table and seed it from the currently linked bounds. Subsequent SV_LinkEdict calls maintain it in O(1).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L297)

<a id="function-function-miniquake-server-collision-entityabsmax-function-entityabsmax-server-entityindex-src-miniquake-server-collision-ml-1671511371"></a>
### entityAbsMax

```ml
function entityAbsMax(server, entityIndex)
```

Implements the `entityAbsMax` operation for `miniquake.server_collision` (entity abs max).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L394)

<a id="function-function-miniquake-server-collision-entityabsmin-function-entityabsmin-server-entityindex-src-miniquake-server-collision-ml-1749558871"></a>
### entityAbsMin

```ml
function entityAbsMin(server, entityIndex)
```

Implements the `entityAbsMin` operation for `miniquake.server_collision` (entity abs min).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L387)

<a id="function-function-miniquake-server-collision-entityfloat-function-entityfloat-server-entityindex-name-fallback-src-miniquake-server-collision-ml-2100909286"></a>
### entityFloat

```ml
function entityFloat(server, entityIndex, name, fallback)
```

Implements the `entityFloat` operation for `miniquake.server_collision` (entity float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L66)

<a id="function-function-miniquake-server-collision-entitystring-function-entitystring-server-entityindex-name-fallback-src-miniquake-server-collision-ml-2142546108"></a>
### entityString

```ml
function entityString(server, entityIndex, name, fallback)
```

Implements the `entityString` operation for `miniquake.server_collision` (entity string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L112)

<a id="function-function-miniquake-server-collision-entityvalid-function-entityvalid-server-entityindex-src-miniquake-server-collision-ml-1044885453"></a>
### entityValid

```ml
function entityValid(server, entityIndex)
```

Report whether entity valid holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L153)

<a id="function-function-miniquake-server-collision-entityvector-function-entityvector-server-entityindex-name-fallback-src-miniquake-server-collision-ml-1957420524"></a>
### entityVector

```ml
function entityVector(server, entityIndex, name, fallback)
```

Implements the `entityVector` operation for `miniquake.server_collision` (entity vector).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L88)

<a id="function-function-miniquake-server-collision-entityvectorzero-function-entityvectorzero-server-entityindex-name-src-miniquake-server-collision-ml-2117542842"></a>
### entityVectorZero

```ml
function entityVectorZero(server, entityIndex, name)
```

Read a generated QuakeC vector and allocate the zero fallback only for a genuinely missing field. Stock progs.dat contains all collision vectors; passing zeroVector() eagerly at every call site formerly created more than one million dead Vec3 values in a 300-frame e1m2 sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L101)

<a id="function-function-miniquake-server-collision-entityword-function-entityword-server-entityindex-name-fallback-src-miniquake-server-collision-ml-1501966304"></a>
### entityWord

```ml
function entityWord(server, entityIndex, name, fallback)
```

Implements the `entityWord` operation for `miniquake.server_collision` (entity word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L77)

<a id="function-function-miniquake-server-collision-executetouch-function-executetouch-server-selfindex-otherindex-src-miniquake-server-collision-ml-1067207712"></a>
### executeTouch

```ml
function executeTouch(server, selfIndex, otherIndex)
```

Execute touch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `selfIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `otherIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L696)

<a id="function-function-miniquake-server-collision-fieldoffset-function-fieldoffset-server-name-src-miniquake-server-collision-ml-1820097827"></a>
### fieldOffset

```ml
function fieldOffset(server, name)
```

Implements the `fieldOffset` operation for `miniquake.server_collision` (field offset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L43)

<a id="function-function-miniquake-server-collision-impact-function-impact-server-firstentity-secondentity-src-miniquake-server-collision-ml-1954247154"></a>
### impact

```ml
function impact(server, firstEntity, secondEntity)
```

Implements the `impact` operation for `miniquake.server_collision` (impact).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `firstEntity` | `dynamic` | — | The first entity input consumed by `impact`. |
| `secondEntity` | `dynamic` | — | The second entity input consumed by `impact`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L718)

<a id="function-function-miniquake-server-collision-insertareaentity-function-insertareaentity-entityindex-bounds-solid-src-miniquake-server-collision-ml-1821490724"></a>
### insertAreaEntity

```ml
function insertAreaEntity(entityIndex, bounds, solid)
```

Insert one linked edict into its deepest non-splitting area node.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `bounds` | `dynamic` | — | The bounds input consumed by `insertAreaEntity`. |
| `solid` | `dynamic` | — | Stable identifier of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L263)

<a id="function-function-miniquake-server-collision-linkedentitybounds-function-linkedentitybounds-server-entityindex-src-miniquake-server-collision-ml-69519987"></a>
### linkedEntityBounds

```ml
function linkedEntityBounds(server, entityIndex)
```

Return the abs bounds maintained by SV_LinkEdict. Hand-built unit fixtures may omit the link step and leave both generated vectors zeroed, so retain a computed fallback for that non-production case.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L374)

<a id="function-function-miniquake-server-collision-linkentity-function-linkentity-server-entityindex-touchtriggerlinks-src-miniquake-server-collision-ml-1468246635"></a>
### linkEntity

```ml
function linkEntity(server, entityIndex, touchTriggerLinks)
```

Linear-scan equivalent of world.c SV_LinkEdict. Area nodes only optimize the candidate set; updated abs bounds, SOLID_NOT suppression and touch ordering are observable parts of the engine contract.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `touchTriggerLinks` | `dynamic` | — | The touch trigger links input consumed by `linkEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L843)

<a id="function-function-miniquake-server-collision-modelsubindex-function-modelsubindex-name-src-miniquake-server-collision-ml-1456892786"></a>
### modelSubIndex

```ml
function modelSubIndex(name)
```

Return model sub index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L162)

<a id="function-function-miniquake-server-collision-move-function-move-server-start-mins-maxs-finish-movetype-passedentity-src-miniquake-server-collision-ml-1795990625"></a>
### move

```ml
function move(server, start, mins, maxs, finish, moveType, passedEntity)
```

SV_Move: clip first against the world, then every potentially intersecting solid edict.  Area nodes are an optimization only; a linear scan has the same observable Quake semantics and is suitable for the stock MAX_EDICTS limit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `start` | `dynamic` | — | The start input consumed by `move`. |
| `mins` | `dynamic` | — | The mins input consumed by `move`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `move`. |
| `finish` | `dynamic` | — | The finish input consumed by `move`. |
| `moveType` | `dynamic` | — | The move type input consumed by `move`. |
| `passedEntity` | `dynamic` | — | The passed entity input consumed by `move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L632)

<a id="function-function-miniquake-server-collision-movebounds-function-movebounds-start-mins-maxs-finish-src-miniquake-server-collision-ml-1950931992"></a>
### moveBounds

```ml
function moveBounds(start, mins, maxs, finish)
```

Transfer data for move bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start` | `dynamic` | — | The start input consumed by `moveBounds`. |
| `mins` | `dynamic` | — | The mins input consumed by `moveBounds`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `moveBounds`. |
| `finish` | `dynamic` | — | The finish input consumed by `moveBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L426)

<a id="function-function-miniquake-server-collision-pushentity-function-pushentity-server-entityindex-push-src-miniquake-server-collision-ml-1893107811"></a>
### pushEntity

```ml
function pushEntity(server, entityIndex, push)
```

Add state for push entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `push` | `dynamic` | — | The push input consumed by `pushEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L753)

<a id="function-function-miniquake-server-collision-relinkareaentity-function-relinkareaentity-server-entityindex-bounds-solid-src-miniquake-server-collision-ml-1107503013"></a>
### relinkAreaEntity

```ml
function relinkAreaEntity(server, entityIndex, bounds, solid)
```

Refresh an edict's area-list membership after its abs bounds change.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `bounds` | `dynamic` | — | The bounds input consumed by `relinkAreaEntity`. |
| `solid` | `dynamic` | — | Stable identifier of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L336)

<a id="function-function-miniquake-server-collision-setentityfloat-function-setentityfloat-server-entityindex-name-value-src-miniquake-server-collision-ml-312080989"></a>
### setEntityFloat

```ml
function setEntityFloat(server, entityIndex, name, value)
```

Sets entity float for `miniquake.server_collision`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setEntityFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L125)

<a id="function-function-miniquake-server-collision-setentityvector-function-setentityvector-server-entityindex-name-value-src-miniquake-server-collision-ml-2050765417"></a>
### setEntityVector

```ml
function setEntityVector(server, entityIndex, name, value)
```

Sets entity vector for `miniquake.server_collision`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setEntityVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L145)

<a id="function-function-miniquake-server-collision-setentityword-function-setentityword-server-entityindex-name-value-src-miniquake-server-collision-ml-1481779959"></a>
### setEntityWord

```ml
function setEntityWord(server, entityIndex, name, value)
```

Update module state for entity word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setEntityWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L135)

<a id="function-function-miniquake-server-collision-testentityposition-function-testentityposition-server-entityindex-src-miniquake-server-collision-ml-1073813019"></a>
### testEntityPosition

```ml
function testEntityPosition(server, entityIndex)
```

Verify entity position against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L682)

<a id="function-function-miniquake-server-collision-touchareanode-function-touchareanode-server-node-entityindex-absmin-absmax-src-miniquake-server-collision-ml-1178087913"></a>
### touchAreaNode

```ml
function touchAreaNode(server, node, entityIndex, absMin, absMax)
```

Visit only trigger-area nodes intersected by one linked edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `node` | `dynamic` | — | The node input consumed by `touchAreaNode`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `absMin` | `dynamic` | — | The abs min input consumed by `touchAreaNode`. |
| `absMax` | `dynamic` | — | The abs max input consumed by `touchAreaNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L778)

<a id="function-function-miniquake-server-collision-touchtriggers-function-touchtriggers-server-entityindex-src-miniquake-server-collision-ml-813543947"></a>
### touchTriggers

```ml
function touchTriggers(server, entityIndex)
```

Implements the `touchTriggers` operation for `miniquake.server_collision` (touch triggers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L866)

<a id="function-function-miniquake-server-collision-touchtriggerswithbounds-function-touchtriggerswithbounds-server-entityindex-absmin-absmax-src-miniquake-server-collision-ml-1378255923"></a>
### touchTriggersWithBounds

```ml
function touchTriggersWithBounds(server, entityIndex, absMin, absMax)
```

Implements the `touchTriggersWithBounds` operation for `miniquake.server_collision` (touch triggers with bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `absMin` | `dynamic` | — | The abs min input consumed by `touchTriggersWithBounds`. |
| `absMax` | `dynamic` | — | The abs max input consumed by `touchTriggersWithBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L815)

<a id="function-function-miniquake-server-collision-traceagainstbox-function-traceagainstbox-server-entityindex-start-mins-maxs-finish-src-miniquake-server-collision-ml-1891298588"></a>
### traceAgainstBox

```ml
function traceAgainstBox(server, entityIndex, start, mins, maxs, finish)
```

Trace against box through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `traceAgainstBox`. |
| `mins` | `dynamic` | — | The mins input consumed by `traceAgainstBox`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `traceAgainstBox`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceAgainstBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L460)

<a id="function-function-miniquake-server-collision-traceagainstbrush-function-traceagainstbrush-server-entityindex-start-mins-maxs-finish-src-miniquake-server-collision-ml-579805374"></a>
### traceAgainstBrush

```ml
function traceAgainstBrush(server, entityIndex, start, mins, maxs, finish)
```

Trace against brush through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `traceAgainstBrush`. |
| `mins` | `dynamic` | — | The mins input consumed by `traceAgainstBrush`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `traceAgainstBrush`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceAgainstBrush`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L487)

<a id="function-function-miniquake-server-collision-unlinkareaentity-function-unlinkareaentity-entityindex-src-miniquake-server-collision-ml-687923316"></a>
### unlinkAreaEntity

```ml
function unlinkAreaEntity(entityIndex)
```

Remove one edict from its current O(1) area-list position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L237)

<a id="function-function-miniquake-server-collision-updateentitybounds-function-updateentitybounds-server-entityindex-src-miniquake-server-collision-ml-1971783919"></a>
### updateEntityBounds

```ml
function updateEntityBounds(server, entityIndex)
```

Update module state for entity bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L401)

<a id="function-function-miniquake-server-collision-zerovector-function-zerovector-src-miniquake-server-collision-ml-1067545769"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.server_collision` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_collision.ml#L31)
