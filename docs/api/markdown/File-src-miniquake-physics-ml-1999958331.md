# `src/miniquake/physics.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.physics`](Package-miniquake-physics-2045770452.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/server_collision.ml` as `collision` → [src/miniquake/server_collision.ml](File-src-miniquake-server-collision-ml-849122018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-physics-accelerate-function-accelerate-player-wishdirection-wishspeed-frametime-acceleration-src-miniquake-physics-ml-2067410684"></a>
### accelerate

```ml
function accelerate(player, wishDirection, wishSpeed, frameTime, acceleration)
```

Implements the `accelerate` operation for `miniquake.physics` (accelerate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `accelerate`. |
| `wishDirection` | `dynamic` | — | The wish direction input consumed by `accelerate`. |
| `wishSpeed` | `dynamic` | — | The wish speed input consumed by `accelerate`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `accelerate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L463)

<a id="function-function-miniquake-physics-airaccelerate-function-airaccelerate-player-wishvelocity-wishspeed-frametime-acceleration-src-miniquake-physics-ml-774228116"></a>
### airAccelerate

```ml
function airAccelerate(player, wishVelocity, wishSpeed, frameTime, acceleration)
```

Implements the `airAccelerate` operation for `miniquake.physics` (air accelerate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `airAccelerate`. |
| `wishVelocity` | `dynamic` | — | The wish velocity input consumed by `airAccelerate`. |
| `wishSpeed` | `dynamic` | — | The wish speed input consumed by `airAccelerate`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `airAccelerate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L478)

<a id="function-function-miniquake-physics-airmove-function-airmove-player-command-frametime-maxspeed-acceleration-friction-edgefriction-stopspeed-map-server-entityindex-src-miniquake-physics-ml-187942020"></a>
### airMove

```ml
function airMove(player, command, frameTime, maxSpeed, acceleration, friction, edgeFriction, stopSpeed, map, server, entityIndex)
```

Implements the `airMove` operation for `miniquake.physics` (air move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `airMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `maxSpeed` | `dynamic` | — | The max speed input consumed by `airMove`. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `airMove`. |
| `friction` | `dynamic` | — | The friction input consumed by `airMove`. |
| `edgeFriction` | `dynamic` | — | The edge friction input consumed by `airMove`. |
| `stopSpeed` | `dynamic` | — | The stop speed input consumed by `airMove`. |
| `map` | `dynamic` | — | The map input consumed by `airMove`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L544)

<a id="function-function-miniquake-physics-applyfriction-function-applyfriction-player-map-server-entityindex-frametime-friction-edgefriction-stopspeed-src-miniquake-physics-ml-788879974"></a>
### applyFriction

```ml
function applyFriction(player, map, server, entityIndex, frameTime, friction, edgeFriction, stopSpeed)
```

Apply friction to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `applyFriction`. |
| `map` | `dynamic` | — | The map input consumed by `applyFriction`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `friction` | `dynamic` | — | The friction input consumed by `applyFriction`. |
| `edgeFriction` | `dynamic` | — | The edge friction input consumed by `applyFriction`. |
| `stopSpeed` | `dynamic` | — | The stop speed input consumed by `applyFriction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L434)

<a id="function-function-miniquake-physics-checkground-function-checkground-player-map-src-miniquake-physics-ml-291841362"></a>
### checkGround

```ml
function checkGround(player, map)
```

A diagnostic ground probe. Runtime physics intentionally does not snap the player down every frame; WinQuake derives FL_ONGROUND from actual movement impacts. The former repeated two-unit snap caused the visible fall/push loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `checkGround`. |
| `map` | `dynamic` | — | The map input consumed by `checkGround`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L390)

<a id="function-function-miniquake-physics-checkstuck-function-checkstuck-player-map-server-entityindex-src-miniquake-physics-ml-2069068954"></a>
### checkStuck

```ml
function checkStuck(player, map, server, entityIndex)
```

Validate stuck and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `checkStuck`. |
| `map` | `dynamic` | — | The map input consumed by `checkStuck`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L659)

<a id="function-function-miniquake-physics-clampvelocity-function-clampvelocity-player-maximum-src-miniquake-physics-ml-754476068"></a>
### clampVelocity

```ml
function clampVelocity(player, maximum)
```

Return a validated clamp velocity value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `clampVelocity`. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L727)

<a id="function-function-miniquake-physics-clearground-function-clearground-player-src-miniquake-physics-ml-164239764"></a>
### clearGround

```ml
function clearGround(player)
```

Update module state for ground.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `clearGround`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L136)

<a id="function-function-miniquake-physics-clientthink-function-clientthink-player-command-frametime-settings-map-server-entityindex-src-miniquake-physics-ml-1158130206"></a>
### clientThink

```ml
function clientThink(player, command, frameTime, settings, map, server, entityIndex)
```

Implements the `clientThink` operation for `miniquake.physics` (client think).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `clientThink`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `settings` | `dynamic` | — | The settings input consumed by `clientThink`. |
| `map` | `dynamic` | — | The map input consumed by `clientThink`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L744)

<a id="function-function-miniquake-physics-clipvelocity-function-clipvelocity-input-normal-overbounce-src-miniquake-physics-ml-888005980"></a>
### ClipVelocity

```ml
function ClipVelocity(input, normal, overbounce)
```

Implements the `ClipVelocity` operation for `miniquake.physics` (clip velocity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `ClipVelocity`. |
| `normal` | `dynamic` | — | The normal input consumed by `ClipVelocity`. |
| `overbounce` | `dynamic` | — | The overbounce input consumed by `ClipVelocity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1079)

<a id="function-function-miniquake-physics-clipvelocity-function-clipvelocity-input-normal-overbounce-src-miniquake-physics-ml-266237212"></a>
### clipVelocity

```ml
function clipVelocity(input, normal, overbounce)
```

Implements the `clipVelocity` operation for `miniquake.physics` (clip velocity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `clipVelocity`. |
| `normal` | `dynamic` | — | The normal input consumed by `clipVelocity`. |
| `overbounce` | `dynamic` | — | The overbounce input consumed by `clipVelocity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L99)

<a id="function-function-miniquake-physics-collapsepushercorpsebounds-function-collapsepushercorpsebounds-mins-src-miniquake-physics-ml-354187840"></a>
### collapsePusherCorpseBounds

```ml
function collapsePusherCorpseBounds(mins)
```

Implements the `collapsePusherCorpseBounds` operation for `miniquake.physics` (collapse pusher corpse bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `collapsePusherCorpseBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L45)

<a id="function-function-miniquake-physics-createplayer-function-createplayer-origin-angles-src-miniquake-physics-ml-1666429415"></a>
### createPlayer

```ml
function createPlayer(origin, angles)
```

Create and initialize player.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L52)

<a id="function-function-miniquake-physics-droppunchangle-function-droppunchangle-player-frametime-src-miniquake-physics-ml-759705194"></a>
### dropPunchAngle

```ml
function dropPunchAngle(player, frameTime)
```

Release state for drop punch angle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `dropPunchAngle`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L523)

<a id="function-function-miniquake-physics-flymove-function-flymove-player-map-frametime-src-miniquake-physics-ml-297201742"></a>
### flyMove

```ml
function flyMove(player, map, frameTime)
```

Implements the `flyMove` operation for `miniquake.physics` (fly move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `flyMove`. |
| `map` | `dynamic` | — | The map input consumed by `flyMove`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L254)

<a id="function-function-miniquake-physics-flymovedetailed-function-flymovedetailed-player-map-server-entityindex-frametime-src-miniquake-physics-ml-851131980"></a>
### flyMoveDetailed

```ml
function flyMoveDetailed(player, map, server, entityIndex, frameTime)
```

SV_FlyMove: the original four-bump, five-plane clipping algorithm.  The detailed form also returns the last vertical wall trace used by SV_WallFriction during step movement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `flyMoveDetailed`. |
| `map` | `dynamic` | — | The map input consumed by `flyMoveDetailed`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L152)

<a id="function-function-miniquake-physics-flymoveinternal-function-flymoveinternal-player-map-server-entityindex-frametime-src-miniquake-physics-ml-263583622"></a>
### flyMoveInternal

```ml
function flyMoveInternal(player, map, server, entityIndex, frameTime)
```

Implements the `flyMoveInternal` operation for `miniquake.physics` (fly move internal).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `flyMoveInternal`. |
| `map` | `dynamic` | — | The map input consumed by `flyMoveInternal`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L238)

<a id="function-function-miniquake-physics-horizontallength-function-horizontallength-value-src-miniquake-physics-ml-1232425592"></a>
### horizontalLength

```ml
function horizontalLength(value)
```

Return horizontal length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `horizontalLength`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L91)

<a id="function-function-miniquake-physics-markground-function-markground-player-entityindex-src-miniquake-physics-ml-53766355"></a>
### markGround

```ml
function markGround(player, entityIndex)
```

Implements the `markGround` operation for `miniquake.physics` (mark ground).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `markGround`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L128)

<a id="constant-constant-miniquake-physics-max-clip-planes-const-max-clip-planes-5-src-miniquake-physics-ml-211417265"></a>
### MAX_CLIP_PLANES

```ml
const MAX_CLIP_PLANES = 5
```

Defines the max clip planes value used by `miniquake.physics`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L24)

<a id="function-function-miniquake-physics-move-function-move-player-map-command-frametime-registry-src-miniquake-physics-ml-1212410188"></a>
### move

```ml
function move(player, map, command, frameTime, registry)
```

World-only compatibility path used by the synthetic tests and diagnostic tools. It mirrors the server path without dynamic edicts or QuakeC impacts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `move`. |
| `map` | `dynamic` | — | The map input consumed by `move`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L838)

<a id="function-function-miniquake-physics-movementsettings-function-movementsettings-registry-src-miniquake-physics-ml-1577120478"></a>
### movementSettings

```ml
function movementSettings(registry)
```

Transfer data for movement settings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `movementSettings`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L706)

<a id="function-function-miniquake-physics-moveserver-function-moveserver-player-server-entityindex-command-frametime-registry-src-miniquake-physics-ml-1219360890"></a>
### moveServer

```ml
function moveServer(player, server, entityIndex, command, frameTime, registry)
```

Transfer data for move server.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `moveServer`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `moveServer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L776)

<a id="constant-constant-miniquake-physics-movetype-bouncemissile-compat-const-movetype-bouncemissile-compat-11-src-miniquake-physics-ml-2047700390"></a>
### MOVETYPE_BOUNCEMISSILE_COMPAT

```ml
const MOVETYPE_BOUNCEMISSILE_COMPAT = 11
```

These two movetypes are present in the QUAKE2-conditioned half of the pinned MiniQuake source.  Keep them private to this pendant so the shared protocol/constants surface remains the stock Quake 1 one.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L28)

<a id="constant-constant-miniquake-physics-movetype-follow-compat-const-movetype-follow-compat-12-src-miniquake-physics-ml-532770883"></a>
### MOVETYPE_FOLLOW_COMPAT

```ml
const MOVETYPE_FOLLOW_COMPAT = 12
```

Defines the movetype follow compat value used by `miniquake.physics`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L30)

<a id="function-function-miniquake-physics-nativesolid-function-nativesolid-server-entityindex-src-miniquake-physics-ml-1022712565"></a>
### nativeSolid

```ml
function nativeSolid(server, entityIndex)
```

Implements the `nativeSolid` operation for `miniquake.physics` (native solid).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L245)

<a id="function-function-miniquake-physics-physicsentitycount-function-physicsentitycount-server-src-miniquake-physics-ml-915479298"></a>
### physicsEntityCount

```ml
function physicsEntityCount(server)
```

-------------------------------------------------------------------------- sv_phys.c compatibility surface

The lower-case helpers above are the convenient PlayerState API used by the
local client.  The functions below are the edict-oriented MiniQuake API.  They
intentionally keep the original names and ordering rules so protocol tests,
QuakeC and server code can use the same behavioral units as sv_phys.c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L865)

<a id="function-function-miniquake-physics-physicsentityfree-function-physicsentityfree-server-entityindex-src-miniquake-physics-ml-2017848381"></a>
### physicsEntityFree

```ml
function physicsEntityFree(server, entityIndex)
```

Apply server-physics entity free semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L873)

<a id="function-function-miniquake-physics-physicsexecuteentityfunction-function-physicsexecuteentityfunction-server-entityindex-otherindex-fieldname-executiontime-src-miniquake-physics-ml-2007101017"></a>
### physicsExecuteEntityFunction

```ml
function physicsExecuteEntityFunction(server, entityIndex, otherIndex, fieldName, executionTime)
```

Apply server-physics execute entity function semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `otherIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `executionTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L976)

<a id="function-function-miniquake-physics-physicsexecutenamedfunction-function-physicsexecutenamedfunction-server-functionname-entityindex-src-miniquake-physics-ml-937864598"></a>
### physicsExecuteNamedFunction

```ml
function physicsExecuteNamedFunction(server, functionName, entityIndex)
```

Apply server-physics execute named function semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `functionName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L990)

<a id="function-function-miniquake-physics-physicshasbasevelocity-function-physicshasbasevelocity-server-src-miniquake-physics-ml-2123977438"></a>
### physicsHasBaseVelocity

```ml
function physicsHasBaseVelocity(server)
```

Apply server-physics has base velocity semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L882)

<a id="function-function-miniquake-physics-physicsplayerfromedict-function-physicsplayerfromedict-server-entityindex-src-miniquake-physics-ml-1378252841"></a>
### physicsPlayerFromEdict

```ml
function physicsPlayerFromEdict(server, entityIndex)
```

Apply server-physics player from edict semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L915)

<a id="function-function-miniquake-physics-physicspusherblocked-function-physicspusherblocked-server-pusherindex-blockedby-src-miniquake-physics-ml-798974972"></a>
### physicsPusherBlocked

```ml
function physicsPusherBlocked(server, pusherIndex, blockedBy)
```

Apply server-physics pusher blocked semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pusherIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `blockedBy` | `dynamic` | — | The blocked by input consumed by `physicsPusherBlocked`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1147)

<a id="function-function-miniquake-physics-physicsqueuesound-function-physicsqueuesound-server-entityindex-sample-src-miniquake-physics-ml-1244320925"></a>
### physicsQueueSound

```ml
function physicsQueueSound(server, entityIndex, sample)
```

Apply server-physics queue sound semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `sample` | `dynamic` | — | The sample input consumed by `physicsQueueSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L963)

<a id="function-function-miniquake-physics-physicsrefreshconveyorvelocity-function-physicsrefreshconveyorvelocity-server-entityindex-src-miniquake-physics-ml-1019884309"></a>
### physicsRefreshConveyorVelocity

```ml
function physicsRefreshConveyorVelocity(server, entityIndex)
```

The QUAKE2-conditioned MiniQuake branches use the presence of the extended entvars layout.  Testing the field is the MiniLang equivalent: stock v6 progs.dat files have no basevelocity and therefore stay on the 1.09 path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L897)

<a id="function-function-miniquake-physics-physicsstrictoverlap-function-physicsstrictoverlap-minsa-maxsa-minsb-maxsb-src-miniquake-physics-ml-450054667"></a>
### physicsStrictOverlap

```ml
function physicsStrictOverlap(minsA, maxsA, minsB, maxsB)
```

Apply server-physics strict overlap semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `minsA` | `dynamic` | — | The mins a input consumed by `physicsStrictOverlap`. |
| `maxsA` | `dynamic` | — | The maxs a input consumed by `physicsStrictOverlap`. |
| `minsB` | `dynamic` | — | The mins b input consumed by `physicsStrictOverlap`. |
| `maxsB` | `dynamic` | — | The maxs b input consumed by `physicsStrictOverlap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1136)

<a id="function-function-miniquake-physics-physicsvectoriszero-function-physicsvectoriszero-value-src-miniquake-physics-ml-1620287236"></a>
### physicsVectorIsZero

```ml
function physicsVectorIsZero(value)
```

Apply server-physics vector is zero semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `physicsVectorIsZero`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L888)

<a id="function-function-miniquake-physics-physicswriteplayeredict-function-physicswriteplayeredict-server-entityindex-player-src-miniquake-physics-ml-154740472"></a>
### physicsWritePlayerEdict

```ml
function physicsWritePlayerEdict(server, entityIndex, player)
```

Apply server-physics write player edict semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `player` | `dynamic` | — | The player input consumed by `physicsWritePlayerEdict`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L942)

<a id="function-function-miniquake-physics-positiondistancesquared-function-positiondistancesquared-a-b-src-miniquake-physics-ml-1973631620"></a>
### positionDistanceSquared

```ml
function positionDistanceSquared(a, b)
```

Implements the `positionDistanceSquared` operation for `miniquake.physics` (position distance squared).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `positionDistanceSquared`. |
| `b` | `dynamic` | — | The b input consumed by `positionDistanceSquared`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L261)

<a id="function-function-miniquake-physics-pushplayer-function-pushplayer-server-map-entityindex-player-move-src-miniquake-physics-ml-693815365"></a>
### pushPlayer

```ml
function pushPlayer(server, map, entityIndex, player, move)
```

Add state for push player.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `map` | `dynamic` | — | The map input consumed by `pushPlayer`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `player` | `dynamic` | — | The player input consumed by `pushPlayer`. |
| `move` | `dynamic` | — | The move input consumed by `pushPlayer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L273)

<a id="function-function-miniquake-physics-relinkrecoveredplayer-function-relinkrecoveredplayer-player-server-entityindex-src-miniquake-physics-ml-684401124"></a>
### relinkRecoveredPlayer

```ml
function relinkRecoveredPlayer(player, server, entityIndex)
```

Relink a recovered client immediately and pull trigger-side physical changes back into its detached PlayerState mirror. In WinQuake these are the same edict; omitting the pull would let a teleport touch be overwritten later in the current movement frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `relinkRecoveredPlayer`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L574)

<a id="function-function-miniquake-physics-separateactoroverlap-function-separateactoroverlap-player-server-entityindex-blockerindex-original-src-miniquake-physics-ml-1363651755"></a>
### separateActorOverlap

```ml
function separateActorOverlap(player, server, entityIndex, blockerIndex, original)
```

Separate a client from a live actor when both full hulls already overlap and neither oldorigin nor Quake's small precision-recovery offsets can escape. Spawn/teleport protection remains the responsibility of stock spawn_tdeath: its teleport_time window suppresses this fallback until QuakeC has had its force_retouch frames and can award the correct telefrag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `separateActorOverlap`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `blockerIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `original` | `dynamic` | — | The original input consumed by `separateActorOverlap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L596)

<a id="constant-constant-miniquake-physics-step-size-const-step-size-18-src-miniquake-physics-ml-1608035347"></a>
### STEP_SIZE

```ml
const STEP_SIZE = 18.
```

Defines the step size value used by `miniquake.physics`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L22)

<a id="function-function-miniquake-physics-stepmove-function-stepmove-player-map-frametime-src-miniquake-physics-ml-714443134"></a>
### stepMove

```ml
function stepMove(player, map, frameTime)
```

Advance move by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `stepMove`. |
| `map` | `dynamic` | — | The map input consumed by `stepMove`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L381)

<a id="constant-constant-miniquake-physics-stop-epsilon-const-stop-epsilon-0-1-src-miniquake-physics-ml-1516968983"></a>
### STOP_EPSILON

```ml
const STOP_EPSILON = 0.1
```

Defines the stop epsilon value used by `miniquake.physics`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L20)

<a id="function-function-miniquake-physics-strictquake109-function-strictquake109-src-miniquake-physics-ml-1066457465"></a>
### strictQuake109

```ml
function strictQuake109()
```

The compatibility profile in this port is the unconditioned WinQuake / MiniQuake 1.09 source, never the optional QUAKE2 preprocessor branch.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L39)

<a id="function-function-miniquake-physics-sv-addgravity-function-sv-addgravity-server-entityindex-gravity-frametime-src-miniquake-physics-ml-2010137029"></a>
### SV_AddGravity

```ml
function SV_AddGravity(server, entityIndex, gravity, frameTime)
```

Apply the Quake-compatible sv add gravity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_AddGravity`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1101)

<a id="function-function-miniquake-physics-sv-checkallents-function-sv-checkallents-server-src-miniquake-physics-ml-369104248"></a>
### SV_CheckAllEnts

```ml
function SV_CheckAllEnts(server)
```

SV_CheckAllEnts is a diagnostic pass in MiniQuake. Return the offending edict indexes as well as appending the original diagnostic text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1002)

<a id="function-function-miniquake-physics-sv-checkstuck-function-sv-checkstuck-server-entityindex-src-miniquake-physics-ml-1954890405"></a>
### SV_CheckStuck

```ml
function SV_CheckStuck(server, entityIndex)
```

Apply the Quake-compatible sv check stuck behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1360)

<a id="function-function-miniquake-physics-sv-checkvelocity-function-sv-checkvelocity-server-entityindex-maxvelocity-src-miniquake-physics-ml-1837430168"></a>
### SV_CheckVelocity

```ml
function SV_CheckVelocity(server, entityIndex, maxVelocity)
```

Apply the Quake-compatible sv check velocity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_CheckVelocity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1024)

<a id="function-function-miniquake-physics-sv-checkwater-function-sv-checkwater-server-entityindex-src-miniquake-physics-ml-384722659"></a>
### SV_CheckWater

```ml
function SV_CheckWater(server, entityIndex)
```

Apply the Quake-compatible sv check water behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1370)

<a id="function-function-miniquake-physics-sv-checkwatertransition-function-sv-checkwatertransition-server-entityindex-src-miniquake-physics-ml-1223026653"></a>
### SV_CheckWaterTransition

```ml
function SV_CheckWaterTransition(server, entityIndex)
```

Apply the Quake-compatible sv check water transition behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1510)

<a id="function-function-miniquake-physics-sv-finishforceretouch-function-sv-finishforceretouch-server-forceretouch-src-miniquake-physics-ml-1648589011"></a>
### SV_FinishForceRetouch

```ml
function SV_FinishForceRetouch(server, forceRetouch)
```

Apply the Quake-compatible sv finish force retouch behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `forceRetouch` | `dynamic` | — | The force retouch input consumed by `SV_FinishForceRetouch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1697)

<a id="function-function-miniquake-physics-sv-flymove-function-sv-flymove-server-entityindex-movetime-src-miniquake-physics-ml-126306157"></a>
### SV_FlyMove

```ml
function SV_FlyMove(server, entityIndex, moveTime)
```

Apply the Quake-compatible sv fly move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `moveTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1087)

<a id="function-function-miniquake-physics-sv-forceretouchentity-function-sv-forceretouchentity-server-entityindex-forceretouch-src-miniquake-physics-ml-388890992"></a>
### SV_ForceRetouchEntity

```ml
function SV_ForceRetouchEntity(server, entityIndex, forceRetouch)
```

Apply the Quake-compatible sv force retouch entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `forceRetouch` | `dynamic` | — | The force retouch input consumed by `SV_ForceRetouchEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1687)

<a id="function-function-miniquake-physics-sv-forceretouchvalue-function-sv-forceretouchvalue-server-src-miniquake-physics-ml-231329306"></a>
### SV_ForceRetouchValue

```ml
function SV_ForceRetouchValue(server)
```

Apply the Quake-compatible sv force retouch value behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1676)

<a id="function-function-miniquake-physics-sv-impact-function-sv-impact-server-firstentity-secondentity-src-miniquake-physics-ml-1321486750"></a>
### SV_Impact

```ml
function SV_Impact(server, firstEntity, secondEntity)
```

Apply the Quake-compatible sv impact behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `firstEntity` | `dynamic` | — | The first entity input consumed by `SV_Impact`. |
| `secondEntity` | `dynamic` | — | The second entity input consumed by `SV_Impact`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1066)

<a id="function-function-miniquake-physics-sv-physics-function-sv-physics-server-frametime-gravity-maxvelocity-src-miniquake-physics-ml-224779115"></a>
### SV_Physics

```ml
function SV_Physics(server, frameTime, gravity, maxVelocity)
```

Apply the Quake-compatible sv physics behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1738)

<a id="function-function-miniquake-physics-sv-physics-client-function-sv-physics-client-server-entityindex-frametime-gravity-maxvelocity-src-miniquake-physics-ml-1355287908"></a>
### SV_Physics_Client

```ml
function SV_Physics_Client(server, entityIndex, frameTime, gravity, maxVelocity)
```

Apply the Quake-compatible sv physics client behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics_Client`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics_Client`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1435)

<a id="function-function-miniquake-physics-sv-physics-follow-function-sv-physics-follow-server-entityindex-frametime-src-miniquake-physics-ml-607746995"></a>
### SV_Physics_Follow

```ml
function SV_Physics_Follow(server, entityIndex, frameTime)
```

Apply the Quake-compatible sv physics follow behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1478)

<a id="function-function-miniquake-physics-sv-physics-noclip-function-sv-physics-noclip-server-entityindex-frametime-src-miniquake-physics-ml-957433195"></a>
### SV_Physics_Noclip

```ml
function SV_Physics_Noclip(server, entityIndex, frameTime)
```

Apply the Quake-compatible sv physics noclip behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1495)

<a id="function-function-miniquake-physics-sv-physics-noncliententity-function-sv-physics-noncliententity-server-entityindex-frametime-gravity-maxvelocity-src-miniquake-physics-ml-2096095522"></a>
### SV_Physics_NonClientEntity

```ml
function SV_Physics_NonClientEntity(server, entityIndex, frameTime, gravity, maxVelocity)
```

Dispatch one non-client edict through the exact unconditioned WinQuake 1.09 SV_Physics switch.  The integrated server frame uses this entry point after it has run client movement, so the production path and the direct sv_main pendant share the same pusher, toss, step, noclip and think semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics_NonClientEntity`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics_NonClientEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1714)

<a id="function-function-miniquake-physics-sv-physics-none-function-sv-physics-none-server-entityindex-frametime-src-miniquake-physics-ml-1499312381"></a>
### SV_Physics_None

```ml
function SV_Physics_None(server, entityIndex, frameTime)
```

Apply the Quake-compatible sv physics none behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1470)

<a id="function-function-miniquake-physics-sv-physics-pusher-function-sv-physics-pusher-server-entityindex-frametime-src-miniquake-physics-ml-650683423"></a>
### SV_Physics_Pusher

```ml
function SV_Physics_Pusher(server, entityIndex, frameTime)
```

Apply the Quake-compatible sv physics pusher behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1336)

<a id="function-function-miniquake-physics-sv-physics-step-function-sv-physics-step-server-entityindex-frametime-gravity-maxvelocity-src-miniquake-physics-ml-1647788438"></a>
### SV_Physics_Step

```ml
function SV_Physics_Step(server, entityIndex, frameTime, gravity, maxVelocity)
```

Apply the Quake-compatible sv physics step behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics_Step`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics_Step`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1572)

<a id="function-function-miniquake-physics-sv-physics-step-quake2-function-sv-physics-step-quake2-server-entityindex-frametime-gravity-maxvelocity-src-miniquake-physics-ml-1297804382"></a>
### SV_Physics_Step_Quake2

```ml
function SV_Physics_Step_Quake2(server, entityIndex, frameTime, gravity, maxVelocity)
```

The alternate QUAKE2 body is retained as a named compatibility entry point; MiniQuake 1.09 dispatches the non-QUAKE2 SV_Physics_Step above.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics_Step_Quake2`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics_Step_Quake2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1596)

<a id="function-function-miniquake-physics-sv-physics-toss-function-sv-physics-toss-server-entityindex-frametime-gravity-maxvelocity-src-miniquake-physics-ml-1575992036"></a>
### SV_Physics_Toss

```ml
function SV_Physics_Toss(server, entityIndex, frameTime, gravity, maxVelocity)
```

Apply the Quake-compatible sv physics toss behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics_Toss`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics_Toss`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1538)

<a id="function-function-miniquake-physics-sv-pushentity-function-sv-pushentity-server-entityindex-push-src-miniquake-physics-ml-355654283"></a>
### SV_PushEntity

```ml
function SV_PushEntity(server, entityIndex, push)
```

Apply the Quake-compatible sv push entity behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `push` | `dynamic` | — | The push input consumed by `SV_PushEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1114)

<a id="function-function-miniquake-physics-sv-pushmove-function-sv-pushmove-server-pusherindex-movetime-src-miniquake-physics-ml-1367683147"></a>
### SV_PushMove

```ml
function SV_PushMove(server, pusherIndex, moveTime)
```

Apply the Quake-compatible sv push move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pusherIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `moveTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1155)

<a id="function-function-miniquake-physics-sv-pushrotate-function-sv-pushrotate-server-pusherindex-movetime-src-miniquake-physics-ml-1299803759"></a>
### SV_PushRotate

```ml
function SV_PushRotate(server, pusherIndex, moveTime)
```

QUAKE2 kept a rotating-pusher sibling in this source file. It is not used by MiniQuake 1.09, but retaining it makes the source-file pendant complete.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `pusherIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `moveTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1246)

<a id="function-function-miniquake-physics-sv-runthink-function-sv-runthink-server-entityindex-frametime-src-miniquake-physics-ml-1184514755"></a>
### SV_RunThink

```ml
function SV_RunThink(server, entityIndex, frameTime)
```

Apply the Quake-compatible sv run think behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1048)

<a id="function-function-miniquake-physics-sv-trace-toss-function-sv-trace-toss-server-entityindex-ignoreentity-gravity-maxvelocity-src-miniquake-physics-ml-1528192281"></a>
### SV_Trace_Toss

```ml
function SV_Trace_Toss(server, entityIndex, ignoreEntity, gravity, maxVelocity)
```

Apply the Quake-compatible sv trace toss behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `ignoreEntity` | `dynamic` | — | The ignore entity input consumed by `SV_Trace_Toss`. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Trace_Toss`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Trace_Toss`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1776)

<a id="function-function-miniquake-physics-sv-tryunstick-function-sv-tryunstick-server-entityindex-oldvelocity-src-miniquake-physics-ml-1729682427"></a>
### SV_TryUnstick

```ml
function SV_TryUnstick(server, entityIndex, oldVelocity)
```

Apply the Quake-compatible sv try unstick behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `oldVelocity` | `dynamic` | — | The old velocity input consumed by `SV_TryUnstick`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1411)

<a id="function-function-miniquake-physics-sv-walkmove-function-sv-walkmove-server-entityindex-frametime-src-miniquake-physics-ml-1888833925"></a>
### SV_WalkMove

```ml
function SV_WalkMove(server, entityIndex, frameTime)
```

Apply the Quake-compatible sv walk move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1422)

<a id="function-function-miniquake-physics-sv-wallfriction-function-sv-wallfriction-server-entityindex-trace-src-miniquake-physics-ml-1387077300"></a>
### SV_WallFriction

```ml
function SV_WallFriction(server, entityIndex, trace)
```

Apply the Quake-compatible sv wall friction behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `trace` | `dynamic` | — | The trace input consumed by `SV_WallFriction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L1400)

<a id="function-function-miniquake-physics-tracemove-function-tracemove-server-map-entityindex-start-mins-maxs-finish-movetype-src-miniquake-physics-ml-1327143097"></a>
### traceMove

```ml
function traceMove(server, map, entityIndex, start, mins, maxs, finish, moveType)
```

Trace move through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `map` | `dynamic` | — | The map input consumed by `traceMove`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `traceMove`. |
| `mins` | `dynamic` | — | The mins input consumed by `traceMove`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `traceMove`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceMove`. |
| `moveType` | `dynamic` | — | The move type input consumed by `traceMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L120)

<a id="function-function-miniquake-physics-tryunstick-function-tryunstick-player-map-server-entityindex-oldvelocity-src-miniquake-physics-ml-1999038270"></a>
### tryUnstick

```ml
function tryUnstick(player, map, server, entityIndex, oldVelocity)
```

Implements the `tryUnstick` operation for `miniquake.physics` (try unstick).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `tryUnstick`. |
| `map` | `dynamic` | — | The map input consumed by `tryUnstick`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `oldVelocity` | `dynamic` | — | The old velocity input consumed by `tryUnstick`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L301)

<a id="function-function-miniquake-physics-updatewaterlevel-function-updatewaterlevel-player-map-src-miniquake-physics-ml-1475813212"></a>
### updateWaterLevel

```ml
function updateWaterLevel(player, map)
```

Update module state for water level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `updateWaterLevel`. |
| `map` | `dynamic` | — | The map input consumed by `updateWaterLevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L405)

<a id="function-function-miniquake-physics-walkmoveinternal-function-walkmoveinternal-player-map-server-entityindex-frametime-src-miniquake-physics-ml-636409804"></a>
### walkMoveInternal

```ml
function walkMoveInternal(player, map, server, entityIndex, frameTime)
```

Implements the `walkMoveInternal` operation for `miniquake.physics` (walk move internal).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `walkMoveInternal`. |
| `map` | `dynamic` | — | The map input consumed by `walkMoveInternal`. |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L332)

<a id="function-function-miniquake-physics-wallfriction-function-wallfriction-player-plane-src-miniquake-physics-ml-367906000"></a>
### wallFriction

```ml
function wallFriction(player, plane)
```

Implements the `wallFriction` operation for `miniquake.physics` (wall friction).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `wallFriction`. |
| `plane` | `dynamic` | — | The plane input consumed by `wallFriction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L284)

<a id="function-function-miniquake-physics-watermove-function-watermove-player-command-frametime-maxspeed-acceleration-friction-src-miniquake-physics-ml-1365985248"></a>
### waterMove

```ml
function waterMove(player, command, frameTime, maxSpeed, acceleration, friction)
```

Implements the `waterMove` operation for `miniquake.physics` (water move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `player` | `dynamic` | — | The player input consumed by `waterMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `maxSpeed` | `dynamic` | — | The max speed input consumed by `waterMove`. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `waterMove`. |
| `friction` | `dynamic` | — | The friction input consumed by `waterMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L497)

<a id="function-function-miniquake-physics-zerovector-function-zerovector-src-miniquake-physics-ml-1512805669"></a>
### zeroVector

```ml
function zeroVector()
```

Implements the `zeroVector` operation for `miniquake.physics` (zero vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/physics.ml#L33)
