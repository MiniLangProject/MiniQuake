# `src/miniquake/sv_user.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sv_user`](Package-miniquake-sv-user-1659385056.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/input.ml` as `input` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_main.ml` as `netmain` → [src/miniquake/net_main.ml](File-src-miniquake-net-main-ml-940970693.md)
- `miniquake/physics.ml` as `physics` → [src/miniquake/physics.ml](File-src-miniquake-physics-ml-1999958331.md)
- `miniquake/server.ml` as `runtime` → [src/miniquake/server.ml](File-src-miniquake-server-ml-699591299.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/view.ml` as `view` → [src/miniquake/view.ml](File-src-miniquake-view-ml-709264737.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-sv-user-droppunchangle-function-droppunchangle-state-player-src-miniquake-sv-user-ml-1284106189"></a>
### DropPunchAngle

```ml
function DropPunchAngle(state, player)
```

DropPunchAngle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `DropPunchAngle`. |
| `player` | `dynamic` | — | The player input consumed by `DropPunchAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L245)

<a id="function-function-miniquake-sv-user-quakefloat-function-quakefloat-value-src-miniquake-sv-user-ml-1885793996"></a>
### quakeFloat

```ml
function quakeFloat(value)
```

Implements the `quakeFloat` operation for `miniquake.sv_user` (quake float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `quakeFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L63)

<a id="function-function-miniquake-sv-user-sv-accelerate-function-sv-accelerate-state-player-wishdirection-wishspeed-src-miniquake-sv-user-ml-1115840581"></a>
### SV_Accelerate

```ml
function SV_Accelerate(state, player, wishDirection, wishSpeed)
```

SV_Accelerate.  One MiniLang entry represents both the disabled experimental #if 0 definition and the active no-argument definition in the source file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_Accelerate`. |
| `player` | `dynamic` | — | The player input consumed by `SV_Accelerate`. |
| `wishDirection` | `dynamic` | — | The wish direction input consumed by `SV_Accelerate`. |
| `wishSpeed` | `dynamic` | — | The wish speed input consumed by `SV_Accelerate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L227)

<a id="function-function-miniquake-sv-user-sv-airaccelerate-function-sv-airaccelerate-state-player-wishvelocity-wishspeed-src-miniquake-sv-user-ml-5457667"></a>
### SV_AirAccelerate

```ml
function SV_AirAccelerate(state, player, wishVelocity, wishSpeed)
```

SV_AirAccelerate

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_AirAccelerate`. |
| `player` | `dynamic` | — | The player input consumed by `SV_AirAccelerate`. |
| `wishVelocity` | `dynamic` | — | The wish velocity input consumed by `SV_AirAccelerate`. |
| `wishSpeed` | `dynamic` | — | The wish speed input consumed by `SV_AirAccelerate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L237)

<a id="function-function-miniquake-sv-user-sv-airmove-function-sv-airmove-state-player-command-map-entityindex-src-miniquake-sv-user-ml-1126936367"></a>
### SV_AirMove

```ml
function SV_AirMove(state, player, command, map, entityIndex)
```

SV_AirMove

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_AirMove`. |
| `player` | `dynamic` | — | The player input consumed by `SV_AirMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `map` | `dynamic` | — | The map input consumed by `SV_AirMove`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L280)

<a id="function-function-miniquake-sv-user-sv-clientthink-function-sv-clientthink-state-clientvalue-player-map-src-miniquake-sv-user-ml-499010125"></a>
### SV_ClientThink

```ml
function SV_ClientThink(state, clientValue, player, map)
```

SV_ClientThink

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_ClientThink`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_ClientThink`. |
| `player` | `dynamic` | — | The player input consumed by `SV_ClientThink`. |
| `map` | `dynamic` | — | The map input consumed by `SV_ClientThink`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L302)

<a id="function-function-miniquake-sv-user-sv-idealpitchfromheights-function-sv-idealpitchfromheights-state-heights-clientindex-src-miniquake-sv-user-ml-2090130473"></a>
### SV_IdealPitchFromHeights

```ml
function SV_IdealPitchFromHeights(state, heights, clientIndex)
```

Apply the Quake-compatible sv ideal pitch from heights behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_IdealPitchFromHeights`. |
| `heights` | `dynamic` | — | The heights input consumed by `SV_IdealPitchFromHeights`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L138)

<a id="function-function-miniquake-sv-user-sv-readclientmessage-function-sv-readclientmessage-state-clientvalue-data-player-src-miniquake-sv-user-ml-1360980091"></a>
### SV_ReadClientMessage

```ml
function SV_ReadClientMessage(state, clientValue, data, player)
```

SV_ReadClientMessage.  The original outer NET_GetMessage loop lives in SV_RunClients; this entry consumes one already-framed reliable/unreliable payload and preserves the exact clc_* command ordering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_ReadClientMessage`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_ReadClientMessage`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `player` | `dynamic` | — | The player input consumed by `SV_ReadClientMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L422)

<a id="function-function-miniquake-sv-user-sv-readclientmove-function-sv-readclientmove-state-reader-clientvalue-player-src-miniquake-sv-user-ml-1342642802"></a>
### SV_ReadClientMove

```ml
function SV_ReadClientMove(state, reader, clientValue, player)
```

SV_ReadClientMove

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_ReadClientMove`. |
| `reader` | `dynamic` | — | The reader input consumed by `SV_ReadClientMove`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_ReadClientMove`. |
| `player` | `dynamic` | — | The player input consumed by `SV_ReadClientMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L332)

<a id="function-function-miniquake-sv-user-sv-runclients-function-sv-runclients-state-player-src-miniquake-sv-user-ml-858939035"></a>
### SV_RunClients

```ml
function SV_RunClients(state, player)
```

SV_RunClients

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_RunClients`. |
| `player` | `dynamic` | — | The player input consumed by `SV_RunClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L467)

<a id="function-function-miniquake-sv-user-sv-setidealpitch-function-sv-setidealpitch-state-player-map-clientindex-src-miniquake-sv-user-ml-1447622194"></a>
### SV_SetIdealPitch

```ml
function SV_SetIdealPitch(state, player, map, clientIndex)
```

SV_SetIdealPitch

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_SetIdealPitch`. |
| `player` | `dynamic` | — | The player input consumed by `SV_SetIdealPitch`. |
| `map` | `dynamic` | — | The map input consumed by `SV_SetIdealPitch`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L198)

<a id="function-function-miniquake-sv-user-sv-userfriction-function-sv-userfriction-state-player-map-entityindex-src-miniquake-sv-user-ml-1027390004"></a>
### SV_UserFriction

```ml
function SV_UserFriction(state, player, map, entityIndex)
```

SV_UserFriction

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_UserFriction`. |
| `player` | `dynamic` | — | The player input consumed by `SV_UserFriction`. |
| `map` | `dynamic` | — | The map input consumed by `SV_UserFriction`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L207)

<a id="function-function-miniquake-sv-user-sv-userinit-function-sv-userinit-server-src-miniquake-sv-user-ml-1389718748"></a>
### SV_UserInit

```ml
function SV_UserInit(server)
```

Apply the Quake-compatible sv user init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L69)

<a id="function-function-miniquake-sv-user-sv-usersetframetime-function-sv-usersetframetime-state-frametime-src-miniquake-sv-user-ml-373335084"></a>
### SV_UserSetFrameTime

```ml
function SV_UserSetFrameTime(state, frameTime)
```

Apply the Quake-compatible sv user set frame time behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_UserSetFrameTime`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L93)

<a id="function-function-miniquake-sv-user-sv-usersetfrozen-function-sv-usersetfrozen-state-frozen-src-miniquake-sv-user-ml-1143228786"></a>
### SV_UserSetFrozen

```ml
function SV_UserSetFrozen(state, frozen)
```

Apply the Quake-compatible sv user set frozen behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_UserSetFrozen`. |
| `frozen` | `dynamic` | — | The frozen input consumed by `SV_UserSetFrozen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L129)

<a id="function-function-miniquake-sv-user-sv-usersetmovement-function-sv-usersetmovement-state-maxspeed-acceleration-friction-edgefriction-stopspeed-src-miniquake-sv-user-ml-1063682789"></a>
### SV_UserSetMovement

```ml
function SV_UserSetMovement(state, maxSpeed, acceleration, friction, edgeFriction, stopSpeed)
```

Apply the Quake-compatible sv user set movement behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_UserSetMovement`. |
| `maxSpeed` | `dynamic` | — | The max speed input consumed by `SV_UserSetMovement`. |
| `acceleration` | `dynamic` | — | The acceleration input consumed by `SV_UserSetMovement`. |
| `friction` | `dynamic` | — | The friction input consumed by `SV_UserSetMovement`. |
| `edgeFriction` | `dynamic` | — | The edge friction input consumed by `SV_UserSetMovement`. |
| `stopSpeed` | `dynamic` | — | The stop speed input consumed by `SV_UserSetMovement`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L107)

<a id="function-function-miniquake-sv-user-sv-usersetpaused-function-sv-usersetpaused-state-paused-keydestination-src-miniquake-sv-user-ml-1868218743"></a>
### SV_UserSetPaused

```ml
function SV_UserSetPaused(state, paused, keyDestination)
```

Apply the Quake-compatible sv user set paused behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_UserSetPaused`. |
| `paused` | `dynamic` | — | The paused input consumed by `SV_UserSetPaused`. |
| `keyDestination` | `dynamic` | — | The key destination input consumed by `SV_UserSetPaused`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L120)

<a id="function-function-miniquake-sv-user-sv-waterjump-function-sv-waterjump-state-player-src-miniquake-sv-user-ml-721995101"></a>
### SV_WaterJump

```ml
function SV_WaterJump(state, player)
```

SV_WaterJump

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_WaterJump`. |
| `player` | `dynamic` | — | The player input consumed by `SV_WaterJump`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L262)

<a id="function-function-miniquake-sv-user-sv-watermove-function-sv-watermove-state-player-command-src-miniquake-sv-user-ml-1488283780"></a>
### SV_WaterMove

```ml
function SV_WaterMove(state, player, command)
```

SV_WaterMove

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `SV_WaterMove`. |
| `player` | `dynamic` | — | The player input consumed by `SV_WaterMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L254)

<a id="function-function-miniquake-sv-user-svuallowedcommand-function-svuallowedcommand-text-src-miniquake-sv-user-ml-1708941248"></a>
### svuAllowedCommand

```ml
function svuAllowedCommand(text)
```

Implements the `svuAllowedCommand` operation for `miniquake.sv_user` (svu allowed command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L377)

<a id="function-function-miniquake-sv-user-svuexecutestring-function-svuexecutestring-state-clientvalue-player-text-src-miniquake-sv-user-ml-246505044"></a>
### svuExecuteString

```ml
function svuExecuteString(state, clientValue, player, text)
```

Implements the `svuExecuteString` operation for `miniquake.sv_user` (svu execute string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `svuExecuteString`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svuExecuteString`. |
| `player` | `dynamic` | — | The player input consumed by `svuExecuteString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L394)

<a id="function-function-miniquake-sv-user-svureadnetworkmessages-function-svureadnetworkmessages-state-clientvalue-player-src-miniquake-sv-user-ml-1504936439"></a>
### svuReadNetworkMessages

```ml
function svuReadNetworkMessages(state, clientValue, player)
```

Implements the `svuReadNetworkMessages` operation for `miniquake.sv_user` (svu read network messages).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `svuReadNetworkMessages`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svuReadNetworkMessages`. |
| `player` | `dynamic` | — | The player input consumed by `svuReadNetworkMessages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L452)

- [miniquake.sv_user.SvUserState](Type-miniquake-sv-user-svuserstate-1496461433.md) — struct
<a id="function-function-miniquake-sv-user-svustartswith-function-svustartswith-text-prefix-src-miniquake-sv-user-ml-653131612"></a>
### svuStartsWith

```ml
function svuStartsWith(text, prefix)
```

Implements the `svuStartsWith` operation for `miniquake.sv_user` (svu starts with).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `prefix` | `dynamic` | — | The prefix input consumed by `svuStartsWith`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L363)

<a id="function-function-miniquake-sv-user-svutraceidealpitch-function-svutraceidealpitch-state-player-map-clientindex-src-miniquake-sv-user-ml-249302978"></a>
### svuTraceIdealPitch

```ml
function svuTraceIdealPitch(state, player, map, clientIndex)
```

Implements the `svuTraceIdealPitch` operation for `miniquake.sv_user` (svu trace ideal pitch).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_user` state used by `svuTraceIdealPitch`. |
| `player` | `dynamic` | — | The player input consumed by `svuTraceIdealPitch`. |
| `map` | `dynamic` | — | The map input consumed by `svuTraceIdealPitch`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_user.ml#L170)
