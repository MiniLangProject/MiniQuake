# `src/miniquake/server_move.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.server_move`](Package-miniquake-server-move-1103627272.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/server_collision.ml` as `collision` → [src/miniquake/server_collision.ml](File-src-miniquake-server-collision-ml-849122018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-server-move-absolute-function-absolute-value-src-miniquake-server-move-ml-1773946024"></a>
### absolute

```ml
function absolute(value)
```

Implements the `absolute` operation for `miniquake.server_move` (absolute).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absolute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L29)

<a id="function-function-miniquake-server-move-changeyaw-function-changeyaw-server-entityindex-src-miniquake-server-move-ml-282521087"></a>
### changeYaw

```ml
function changeYaw(server, entityIndex)
```

PF_changeyaw / SV_StepDirection share this exact angle update.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L46)

<a id="function-function-miniquake-server-move-closeenough-function-closeenough-server-entityindex-goalindex-distance-src-miniquake-server-move-ml-1734938211"></a>
### closeEnough

```ml
function closeEnough(server, entityIndex, goalIndex, distance)
```

Release state for close enough.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `goalIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `distance` | `dynamic` | — | The distance input consumed by `closeEnough`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L240)

<a id="constant-constant-miniquake-server-move-di-nodir-const-di-nodir-1-src-miniquake-server-move-ml-1770122722"></a>
### DI_NODIR

```ml
const DI_NODIR = -1.
```

Defines the di nodir value used by `miniquake.server_move`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L20)

<a id="function-function-miniquake-server-move-fixcheckbottom-function-fixcheckbottom-server-entityindex-src-miniquake-server-move-ml-66418341"></a>
### fixCheckBottom

```ml
function fixCheckBottom(server, entityIndex)
```

Implements the `fixCheckBottom` operation for `miniquake.server_move` (fix check bottom).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L173)

<a id="function-function-miniquake-server-move-movestep-function-movestep-server-entityindex-movement-relink-src-miniquake-server-move-ml-2138951849"></a>
### moveStep

```ml
function moveStep(server, entityIndex, movement, relink)
```

SV_movestep: QuakeC monster movement, including stair/drop checks and flying/swimming pursuit height adjustment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `movement` | `dynamic` | — | The movement input consumed by `moveStep`. |
| `relink` | `dynamic` | — | The relink input consumed by `moveStep`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L71)

<a id="function-function-miniquake-server-move-movetogoal-function-movetogoal-server-entityindex-distance-src-miniquake-server-move-ml-74346770"></a>
### moveToGoal

```ml
function moveToGoal(server, entityIndex, distance)
```

Transfer data for move to goal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `distance` | `dynamic` | — | The distance input consumed by `moveToGoal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L255)

<a id="function-function-miniquake-server-move-newchasedirection-function-newchasedirection-server-actor-enemy-distance-src-miniquake-server-move-ml-475303568"></a>
### newChaseDirection

```ml
function newChaseDirection(server, actor, enemy, distance)
```

Create and initialize chase direction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `actor` | `dynamic` | — | The actor input consumed by `newChaseDirection`. |
| `enemy` | `dynamic` | — | The enemy input consumed by `newChaseDirection`. |
| `distance` | `dynamic` | — | The distance input consumed by `newChaseDirection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L183)

<a id="function-function-miniquake-server-move-randomword-function-randomword-server-src-miniquake-server-move-ml-1114923470"></a>
### randomWord

```ml
function randomWord(server)
```

Implements the `randomWord` operation for `miniquake.server_move` (random word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L36)

<a id="constant-constant-miniquake-server-move-step-size-const-step-size-18-src-miniquake-server-move-ml-1711491787"></a>
### STEP_SIZE

```ml
const STEP_SIZE = 18.
```

Defines the step size value used by `miniquake.server_move`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L18)

<a id="function-function-miniquake-server-move-stepdirection-function-stepdirection-server-entityindex-yaw-distance-src-miniquake-server-move-ml-622543811"></a>
### stepDirection

```ml
function stepDirection(server, entityIndex, yaw, distance)
```

Advance direction by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `yaw` | `dynamic` | — | The yaw input consumed by `stepDirection`. |
| `distance` | `dynamic` | — | The distance input consumed by `stepDirection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L152)

<a id="function-function-miniquake-server-move-sv-changeyaw-function-sv-changeyaw-server-entityindex-src-miniquake-server-move-ml-1461031793"></a>
### SV_ChangeYaw

```ml
function SV_ChangeYaw(server, entityIndex)
```

PF_changeyaw is declared in sv_move.c and implemented in pr_cmds.c.  This explicit server hook completes the combined C/header pendant without duplicating the QuakeC builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L337)

<a id="function-function-miniquake-server-move-sv-checkbottom-function-sv-checkbottom-server-entityindex-src-miniquake-server-move-ml-406140433"></a>
### SV_CheckBottom

```ml
function SV_CheckBottom(server, entityIndex)
```

-------------------------------------------------------------------------- sv_move.c public compatibility surface.  Keep these names one-for-one with the original server movement unit; the lower-case spellings above remain convenient internal helpers for existing MiniQuake callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L276)

<a id="function-function-miniquake-server-move-sv-closeenough-function-sv-closeenough-server-entityindex-goalindex-distance-src-miniquake-server-move-ml-1718515139"></a>
### SV_CloseEnough

```ml
function SV_CloseEnough(server, entityIndex, goalIndex, distance)
```

Apply the Quake-compatible sv close enough behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `goalIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `distance` | `dynamic` | — | The distance input consumed by `SV_CloseEnough`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L320)

<a id="function-function-miniquake-server-move-sv-fixcheckbottom-function-sv-fixcheckbottom-server-entityindex-src-miniquake-server-move-ml-703727997"></a>
### SV_FixCheckBottom

```ml
function SV_FixCheckBottom(server, entityIndex)
```

Apply the Quake-compatible sv fix check bottom behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L301)

<a id="function-function-miniquake-server-move-sv-movestep-function-sv-movestep-server-entityindex-movement-relink-src-miniquake-server-move-ml-282211339"></a>
### SV_movestep

```ml
function SV_movestep(server, entityIndex, movement, relink)
```

Apply the Quake-compatible sv movestep behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `movement` | `dynamic` | — | The movement input consumed by `SV_movestep`. |
| `relink` | `dynamic` | — | The relink input consumed by `SV_movestep`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L285)

<a id="function-function-miniquake-server-move-sv-movetogoal-function-sv-movetogoal-server-entityindex-distance-src-miniquake-server-move-ml-865331936"></a>
### SV_MoveToGoal

```ml
function SV_MoveToGoal(server, entityIndex, distance)
```

Apply the Quake-compatible sv move to goal behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `distance` | `dynamic` | — | The distance input consumed by `SV_MoveToGoal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L328)

<a id="function-function-miniquake-server-move-sv-newchasedir-function-sv-newchasedir-server-actor-enemy-distance-src-miniquake-server-move-ml-780642558"></a>
### SV_NewChaseDir

```ml
function SV_NewChaseDir(server, actor, enemy, distance)
```

Apply the Quake-compatible sv new chase dir behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `actor` | `dynamic` | — | The actor input consumed by `SV_NewChaseDir`. |
| `enemy` | `dynamic` | — | The enemy input consumed by `SV_NewChaseDir`. |
| `distance` | `dynamic` | — | The distance input consumed by `SV_NewChaseDir`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L311)

<a id="function-function-miniquake-server-move-sv-stepdirection-function-sv-stepdirection-server-entityindex-yaw-distance-src-miniquake-server-move-ml-2025526953"></a>
### SV_StepDirection

```ml
function SV_StepDirection(server, entityIndex, yaw, distance)
```

Apply the Quake-compatible sv step direction behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `yaw` | `dynamic` | — | The yaw input consumed by `SV_StepDirection`. |
| `distance` | `dynamic` | — | The distance input consumed by `SV_StepDirection`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L294)

<a id="function-function-miniquake-server-move-zerovector-function-zerovector-src-miniquake-server-move-ml-771143253"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.server_move` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_move.ml#L23)
