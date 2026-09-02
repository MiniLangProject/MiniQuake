# `src/miniquake/player_move.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.player_move`](Package-miniquake-player-move-830928850.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-player-move-accelerate-function-accelerate-player-wishdirection-wishspeed-frametime-acceleration-src-miniquake-player-move-ml-1246764436"></a>
### accelerate

```ml
function accelerate(player, wishDirection, wishSpeed, frameTime, acceleration)
```

Implements the `accelerate` operation for `miniquake.player_move` (accelerate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `accelerate`. |
| `wishDirection` | `dynamic` | — | The wish direction input consumed by `accelerate`. |
| `wishSpeed` | `dynamic` | — | The wish speed input consumed by `accelerate`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `accelerate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L151)

<a id="function-function-miniquake-player-move-airaccelerate-function-airaccelerate-player-wishvelocity-wishspeed-frametime-acceleration-src-miniquake-player-move-ml-2061920244"></a>
### airAccelerate

```ml
function airAccelerate(player, wishVelocity, wishSpeed, frameTime, acceleration)
```

Implements the `airAccelerate` operation for `miniquake.player_move` (air accelerate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `airAccelerate`. |
| `wishVelocity` | `dynamic` | — | The wish velocity input consumed by `airAccelerate`. |
| `wishSpeed` | `dynamic` | — | The wish speed input consumed by `airAccelerate`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `airAccelerate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L167)

<a id="function-function-miniquake-player-move-applycommand-function-applycommand-player-map-command-frametime-src-miniquake-player-move-ml-2001675843"></a>
### applyCommand

```ml
function applyCommand(player, map, command, frameTime)
```

Apply command to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `applyCommand`. |
| `map` | `dynamic` | — | The map input consumed by `applyCommand`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L383)

<a id="function-function-miniquake-player-move-cameraorigin-function-cameraorigin-player-src-miniquake-player-move-ml-1185152384"></a>
### cameraOrigin

```ml
function cameraOrigin(player)
```

Return camera origin derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `cameraOrigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L418)

<a id="function-function-miniquake-player-move-checkground-function-checkground-player-map-src-miniquake-player-move-ml-2011604574"></a>
### checkGround

```ml
function checkGround(player, map)
```

Validate ground and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `checkGround`. |
| `map` | `dynamic` | — | The map input consumed by `checkGround`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L105)

<a id="function-function-miniquake-player-move-checkwater-function-checkwater-player-map-src-miniquake-player-move-ml-840284160"></a>
### checkWater

```ml
function checkWater(player, map)
```

Validate water and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `checkWater`. |
| `map` | `dynamic` | — | The map input consumed by `checkWater`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L86)

<a id="function-function-miniquake-player-move-clipvelocity-function-clipvelocity-input-normal-overbounce-src-miniquake-player-move-ml-1776373244"></a>
### clipVelocity

```ml
function clipVelocity(input, normal, overbounce)
```

Implements the `clipVelocity` operation for `miniquake.player_move` (clip velocity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `clipVelocity`. |
| `normal` | `dynamic` | — | The normal input consumed by `clipVelocity`. |
| `overbounce` | `dynamic` | — | The overbounce input consumed by `clipVelocity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L64)

<a id="function-function-miniquake-player-move-create-function-create-origin-angles-src-miniquake-player-move-ml-850230687"></a>
### create

```ml
function create(origin, angles)
```

Implements the `create` operation for `miniquake.player_move` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L23)

<a id="function-function-miniquake-player-move-createplayer-function-createplayer-origin-angles-src-miniquake-player-move-ml-233744879"></a>
### createPlayer

```ml
function createPlayer(origin, angles)
```

Create and initialize player.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L425)

<a id="function-function-miniquake-player-move-horizontalspeed-function-horizontalspeed-velocity-src-miniquake-player-move-ml-1673519972"></a>
### horizontalSpeed

```ml
function horizontalSpeed(velocity)
```

Implements the `horizontalSpeed` operation for `miniquake.player_move` (horizontal speed).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L79)

<a id="function-function-miniquake-player-move-move-function-move-player-map-command-frametime-registry-src-miniquake-player-move-ml-1849333432"></a>
### move

```ml
function move(player, map, command, frameTime, registry)
```

Transfer data for move.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `move`. |
| `map` | `dynamic` | — | The map input consumed by `move`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L435)

<a id="function-function-miniquake-player-move-slidemove-function-slidemove-player-map-frametime-src-miniquake-player-move-ml-100880430"></a>
### slideMove

```ml
function slideMove(player, map, frameTime)
```

Implements the `slideMove` operation for `miniquake.player_move` (slide move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `slideMove`. |
| `map` | `dynamic` | — | The map input consumed by `slideMove`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L261)

<a id="function-function-miniquake-player-move-userfriction-function-userfriction-player-map-frametime-friction-edgefriction-stopspeed-src-miniquake-player-move-ml-1929382964"></a>
### userFriction

```ml
function userFriction(player, map, frameTime, friction, edgeFriction, stopSpeed)
```

Implements the `userFriction` operation for `miniquake.player_move` (user friction).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `userFriction`. |
| `map` | `dynamic` | — | The map input consumed by `userFriction`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `friction` | `dynamic` | — | The friction input consumed by `userFriction`. |
| `edgeFriction` | `dynamic` | — | The edge friction input consumed by `userFriction`. |
| `stopSpeed` | `dynamic` | — | The stop speed input consumed by `userFriction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L120)

<a id="function-function-miniquake-player-move-walkmove-function-walkmove-player-map-frametime-src-miniquake-player-move-ml-2000012782"></a>
### walkMove

```ml
function walkMove(player, map, frameTime)
```

Implements the `walkMove` operation for `miniquake.player_move` (walk move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `walkMove`. |
| `map` | `dynamic` | — | The map input consumed by `walkMove`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L339)

<a id="function-function-miniquake-player-move-watermove-function-watermove-player-command-frametime-src-miniquake-player-move-ml-282340671"></a>
### waterMove

```ml
function waterMove(player, command, frameTime)
```

Implements the `waterMove` operation for `miniquake.player_move` (water move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `waterMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L184)

<a id="function-function-miniquake-player-move-wishmove-function-wishmove-player-command-frametime-map-src-miniquake-player-move-ml-1794202741"></a>
### wishMove

```ml
function wishMove(player, command, frameTime, map)
```

Implements the `wishMove` operation for `miniquake.player_move` (wish move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `wishMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `map` | `dynamic` | — | The map input consumed by `wishMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L228)

<a id="function-function-miniquake-player-move-zerovector-function-zerovector-src-miniquake-player-move-ml-1432254925"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.player_move` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/player_move.ml#L16)
