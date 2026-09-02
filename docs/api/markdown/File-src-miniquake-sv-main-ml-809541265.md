# `src/miniquake/sv_main.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sv_main`](Package-miniquake-sv-main-1396615058.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/edict.ml` as `edict` → [src/miniquake/edict.ml](File-src-miniquake-edict-ml-279284209.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/net_loop.ml` as `netloop` → [src/miniquake/net_loop.ml](File-src-miniquake-net-loop-ml-170267060.md)
- `miniquake/net_main.ml` as `netmain` → [src/miniquake/net_main.ml](File-src-miniquake-net-main-ml-940970693.md)
- `miniquake/physics.ml` as `physics` → [src/miniquake/physics.ml](File-src-miniquake-physics-ml-1999958331.md)
- `miniquake/protocol_events.ml` as `protocolEvents` → [src/miniquake/protocol_events.ml](File-src-miniquake-protocol-events-ml-1275855860.md)
- `miniquake/protocol_serverdata.ml` as `serverData` → [src/miniquake/protocol_serverdata.ml](File-src-miniquake-protocol-serverdata-ml-1434825110.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/protocol_update.ml` as `protocolUpdate` → [src/miniquake/protocol_update.ml](File-src-miniquake-protocol-update-ml-1546315700.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/server.ml` as `runtime` → [src/miniquake/server.ml](File-src-miniquake-server-ml-699591299.md)
- `miniquake/server_move.ml` as `serverMove` → [src/miniquake/server_move.ml](File-src-miniquake-server-move-ml-1725461935.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="constant-constant-miniquake-sv-main-multicast-all-const-multicast-all-0-src-miniquake-sv-main-ml-1078142128"></a>
### MULTICAST_ALL

```ml
const MULTICAST_ALL = 0
```

Defines the multicast all value used by `miniquake.sv_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L37)

<a id="constant-constant-miniquake-sv-main-multicast-phs-const-multicast-phs-2-src-miniquake-sv-main-ml-1320195610"></a>
### MULTICAST_PHS

```ml
const MULTICAST_PHS = 2
```

Defines the multicast phs value used by `miniquake.sv_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L41)

<a id="constant-constant-miniquake-sv-main-multicast-pvs-const-multicast-pvs-1-src-miniquake-sv-main-ml-1729643553"></a>
### MULTICAST_PVS

```ml
const MULTICAST_PVS = 1
```

Defines the multicast pvs value used by `miniquake.sv_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L39)

<a id="function-function-miniquake-sv-main-sv-addclienttoserver-function-sv-addclienttoserver-state-socket-src-miniquake-sv-main-ml-417761669"></a>
### SV_AddClientToServer

```ml
function SV_AddClientToServer(state, socket)
```

Public server.h spelling retained for callers that already own a socket.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_AddClientToServer`. |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L329)

<a id="function-function-miniquake-sv-main-sv-addtofatpvs-function-sv-addtofatpvs-state-origin-nodeindex-src-miniquake-sv-main-ml-184427568"></a>
### SV_AddToFatPVS

```ml
function SV_AddToFatPVS(state, origin, nodeIndex)
```

SV_AddToFatPVS

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_AddToFatPVS`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `nodeIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L362)

<a id="function-function-miniquake-sv-main-sv-addupdates-function-sv-addupdates-state-src-miniquake-sv-main-ml-1424349462"></a>
### SV_AddUpdates

```ml
function SV_AddUpdates(state)
```

Apply the Quake-compatible sv add updates behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_AddUpdates`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1206)

<a id="function-function-miniquake-sv-main-sv-broadcastprintf-function-sv-broadcastprintf-state-text-src-miniquake-sv-main-ml-2056829911"></a>
### SV_BroadcastPrintf

```ml
function SV_BroadcastPrintf(state, text)
```

Apply the Quake-compatible sv broadcast printf behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_BroadcastPrintf`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1193)

<a id="function-function-miniquake-sv-main-sv-checkbottom-function-sv-checkbottom-state-entityindex-src-miniquake-sv-main-ml-733961735"></a>
### SV_CheckBottom

```ml
function SV_CheckBottom(state, entityIndex)
```

Apply the Quake-compatible sv check bottom behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_CheckBottom`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1213)

<a id="function-function-miniquake-sv-main-sv-checkfornewclients-function-sv-checkfornewclients-state-src-miniquake-sv-main-ml-191447470"></a>
### SV_CheckForNewClients

```ml
function SV_CheckForNewClients(state)
```

SV_CheckForNewClients

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_CheckForNewClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L306)

<a id="function-function-miniquake-sv-main-sv-cleanupents-function-sv-cleanupents-state-src-miniquake-sv-main-ml-1308373576"></a>
### SV_CleanupEnts

```ml
function SV_CleanupEnts(state)
```

SV_CleanupEnts

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_CleanupEnts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L610)

<a id="function-function-miniquake-sv-main-sv-cleardatagram-function-sv-cleardatagram-state-src-miniquake-sv-main-ml-1500979184"></a>
### SV_ClearDatagram

```ml
function SV_ClearDatagram(state)
```

SV_ClearDatagram

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_ClearDatagram`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L337)

<a id="function-function-miniquake-sv-main-sv-clientprintf-function-sv-clientprintf-state-clientvalue-text-src-miniquake-sv-main-ml-143669289"></a>
### SV_ClientPrintf

```ml
function SV_ClientPrintf(state, clientValue, text)
```

Apply the Quake-compatible sv client printf behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_ClientPrintf`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_ClientPrintf`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1183)

<a id="function-function-miniquake-sv-main-sv-clientthink-function-sv-clientthink-state-player-frametime-registry-src-miniquake-sv-main-ml-98561182"></a>
### SV_ClientThink

```ml
function SV_ClientThink(state, player, frameTime, registry)
```

Apply the Quake-compatible sv client think behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_ClientThink`. |
| `player` | `dynamic` | — | The player input consumed by `SV_ClientThink`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `SV_ClientThink`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1246)

<a id="function-function-miniquake-sv-main-sv-connectclient-function-sv-connectclient-state-clientindex-socket-src-miniquake-sv-main-ml-1928826802"></a>
### SV_ConnectClient

```ml
function SV_ConnectClient(state, clientIndex, socket)
```

SV_ConnectClient

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_ConnectClient`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L281)

<a id="function-function-miniquake-sv-main-sv-createbaseline-function-sv-createbaseline-state-src-miniquake-sv-main-ml-30672086"></a>
### SV_CreateBaseline

```ml
function SV_CreateBaseline(state)
```

SV_CreateBaseline

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_CreateBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1073)

<a id="function-function-miniquake-sv-main-sv-dropclient-function-sv-dropclient-state-clientvalue-crashed-src-miniquake-sv-main-ml-297344926"></a>
### SV_DropClient

```ml
function SV_DropClient(state, clientValue, crashed)
```

SV_DropClient is declared by server.h and implemented by host.c in the original tree; it lives here because all message lifecycle decisions call it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_DropClient`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_DropClient`. |
| `crashed` | `dynamic` | — | The crashed input consumed by `SV_DropClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L936)

<a id="function-function-miniquake-sv-main-sv-fatpvs-function-sv-fatpvs-state-origin-src-miniquake-sv-main-ml-1267286970"></a>
### SV_FatPVS

```ml
function SV_FatPVS(state, origin)
```

SV_FatPVS

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_FatPVS`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L392)

<a id="function-function-miniquake-sv-main-sv-init-function-sv-init-maxclients-src-miniquake-sv-main-ml-19052011"></a>
### SV_Init

```ml
function SV_Init(maxClients)
```

SV_Init

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxClients` | `dynamic` | — | The max clients input consumed by `SV_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L87)

<a id="function-function-miniquake-sv-main-sv-modelindex-function-sv-modelindex-state-name-src-miniquake-sv-main-ml-639574137"></a>
### SV_ModelIndex

```ml
function SV_ModelIndex(state, name)
```

SV_ModelIndex

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_ModelIndex`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1052)

<a id="function-function-miniquake-sv-main-sv-movestep-function-sv-movestep-state-entityindex-movement-relink-src-miniquake-sv-main-ml-508400765"></a>
### SV_movestep

```ml
function SV_movestep(state, entityIndex, movement, relink)
```

Apply the Quake-compatible sv movestep behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_movestep`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `movement` | `dynamic` | — | The movement input consumed by `SV_movestep`. |
| `relink` | `dynamic` | — | The relink input consumed by `SV_movestep`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1222)

<a id="function-function-miniquake-sv-main-sv-movetogoal-function-sv-movetogoal-state-entityindex-distance-src-miniquake-sv-main-ml-696757502"></a>
### SV_MoveToGoal

```ml
function SV_MoveToGoal(state, entityIndex, distance)
```

Apply the Quake-compatible sv move to goal behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_MoveToGoal`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `distance` | `dynamic` | — | The distance input consumed by `SV_MoveToGoal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1230)

<a id="function-function-miniquake-sv-main-sv-multicast-function-sv-multicast-state-origin-source-mode-src-miniquake-sv-main-ml-1658047924"></a>
### SV_Multicast

```ml
function SV_Multicast(state, origin, source, mode)
```

Protocol-15 has no QuakeWorld multicast opcode.  The stock MiniQuake server routes transient events through datagram/reliable_datagram.  This helper exposes equivalent target selection for private engine producers: ALL is a reliable broadcast, PVS/PHS append only to active clients in the selected visibility set.  PHS falls back to PVS because MiniQuake 1.09 does not build a separate hearability table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_Multicast`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `mode` | `dynamic` | — | The mode input consumed by `SV_Multicast`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1156)

<a id="function-function-miniquake-sv-main-sv-physics-function-sv-physics-state-frametime-gravity-maxvelocity-src-miniquake-sv-main-ml-945206709"></a>
### SV_Physics

```ml
function SV_Physics(state, frameTime, gravity, maxVelocity)
```

Apply the Quake-compatible sv physics behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_Physics`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `gravity` | `dynamic` | — | The gravity input consumed by `SV_Physics`. |
| `maxVelocity` | `dynamic` | — | The max velocity input consumed by `SV_Physics`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1255)

<a id="function-function-miniquake-sv-main-sv-runclients-function-sv-runclients-state-player-src-miniquake-sv-main-ml-77187163"></a>
### SV_RunClients

```ml
function SV_RunClients(state, player)
```

Apply the Quake-compatible sv run clients behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_RunClients`. |
| `player` | `dynamic` | — | The player input consumed by `SV_RunClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1237)

<a id="function-function-miniquake-sv-main-sv-savespawnparms-function-sv-savespawnparms-state-src-miniquake-sv-main-ml-173726918"></a>
### SV_SaveSpawnparms

```ml
function SV_SaveSpawnparms(state)
```

SV_SaveSpawnparms

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SaveSpawnparms`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1118)

<a id="function-function-miniquake-sv-main-sv-sendclientdatagram-function-sv-sendclientdatagram-state-clientvalue-player-src-miniquake-sv-main-ml-1775933147"></a>
### SV_SendClientDatagram

```ml
function SV_SendClientDatagram(state, clientValue, player)
```

SV_SendClientDatagram

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SendClientDatagram`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_SendClientDatagram`. |
| `player` | `dynamic` | — | The player input consumed by `SV_SendClientDatagram`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L852)

<a id="function-function-miniquake-sv-main-sv-sendclientmessages-function-sv-sendclientmessages-state-player-src-miniquake-sv-main-ml-489419063"></a>
### SV_SendClientMessages

```ml
function SV_SendClientMessages(state, player)
```

SV_SendClientMessages

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SendClientMessages`. |
| `player` | `dynamic` | — | The player input consumed by `SV_SendClientMessages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L981)

<a id="function-function-miniquake-sv-main-sv-sendnop-function-sv-sendnop-state-clientvalue-src-miniquake-sv-main-ml-1427531782"></a>
### SV_SendNop

```ml
function SV_SendNop(state, clientValue)
```

SV_SendNop

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SendNop`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_SendNop`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L920)

<a id="function-function-miniquake-sv-main-sv-sendreconnect-function-sv-sendreconnect-state-src-miniquake-sv-main-ml-1450970612"></a>
### SV_SendReconnect

```ml
function SV_SendReconnect(state)
```

SV_SendReconnect

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SendReconnect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1110)

<a id="function-function-miniquake-sv-main-sv-sendserverinfo-function-sv-sendserverinfo-state-clientvalue-src-miniquake-sv-main-ml-1622420392"></a>
### SV_SendServerinfo

```ml
function SV_SendServerinfo(state, clientValue)
```

SV_SendServerinfo

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SendServerinfo`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_SendServerinfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L242)

<a id="function-function-miniquake-sv-main-sv-setclientfrags-function-sv-setclientfrags-state-clientindex-frags-src-miniquake-sv-main-ml-432179398"></a>
### SV_SetClientFrags

```ml
function SV_SetClientFrags(state, clientIndex, frags)
```

Apply the Quake-compatible sv set client frags behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SetClientFrags`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frags` | `dynamic` | — | The frags input consumed by `SV_SetClientFrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L141)

<a id="function-function-miniquake-sv-main-sv-setdropasap-function-sv-setdropasap-state-clientindex-enabled-src-miniquake-sv-main-ml-2096880698"></a>
### SV_SetDropAsap

```ml
function SV_SetDropAsap(state, clientIndex, enabled)
```

Apply the Quake-compatible sv set drop asap behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SetDropAsap`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L971)

<a id="function-function-miniquake-sv-main-sv-setidealpitch-function-sv-setidealpitch-state-clientindex-player-pitchscale-src-miniquake-sv-main-ml-1417366082"></a>
### SV_SetIdealPitch

```ml
function SV_SetIdealPitch(state, clientIndex, player, pitchScale)
```

SV_SetIdealPitch.  The result is cached per client for hosts that keep their player state outside QuakeC and is also written to the edict field when a VM is active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SetIdealPitch`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `player` | `dynamic` | — | The player input consumed by `SV_SetIdealPitch`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `SV_SetIdealPitch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L679)

<a id="function-function-miniquake-sv-main-sv-setnetworkstate-function-sv-setnetworkstate-state-network-src-miniquake-sv-main-ml-1056791988"></a>
### SV_SetNetworkState

```ml
function SV_SetNetworkState(state, network)
```

Apply the Quake-compatible sv set network state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SetNetworkState`. |
| `network` | `dynamic` | — | The network input consumed by `SV_SetNetworkState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L115)

<a id="function-function-miniquake-sv-main-sv-setrealtime-function-sv-setrealtime-state-value-src-miniquake-sv-main-ml-1074602691"></a>
### SV_SetRealtime

```ml
function SV_SetRealtime(state, value)
```

Apply the Quake-compatible sv set realtime behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SetRealtime`. |
| `value` | `dynamic` | — | Value consumed by `SV_SetRealtime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L123)

<a id="function-function-miniquake-sv-main-sv-setstandardquake-function-sv-setstandardquake-state-enabled-src-miniquake-sv-main-ml-1057060371"></a>
### SV_SetStandardQuake

```ml
function SV_SetStandardQuake(state, enabled)
```

Apply the Quake-compatible sv set standard quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SetStandardQuake`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L131)

<a id="function-function-miniquake-sv-main-sv-spawnserver-function-sv-spawnserver-state-filesystem-mapname-skill-registry-commandsystem-src-miniquake-sv-main-ml-1024122064"></a>
### SV_SpawnServer

```ml
function SV_SpawnServer(state, filesystem, mapName, skill, registry, commandSystem)
```

SV_SpawnServer is intentionally present even though the inventory's C parser drops the preprocessor-split definition.  It preserves sockets/spawn parms, loads and settles QuakeC through the shared low-level runtime, then restarts the four-stage signon on the new map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_SpawnServer`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `SV_SpawnServer`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `skill` | `dynamic` | — | The skill input consumed by `SV_SpawnServer`. |
| `registry` | `dynamic` | — | The registry input consumed by `SV_SpawnServer`. |
| `commandSystem` | `dynamic` | — | The command system input consumed by `SV_SpawnServer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1132)

<a id="function-function-miniquake-sv-main-sv-startparticle-function-sv-startparticle-state-origin-direction-color-count-src-miniquake-sv-main-ml-1855293275"></a>
### SV_StartParticle

```ml
function SV_StartParticle(state, origin, direction, color, count)
```

SV_StartParticle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_StartParticle`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `direction` | `dynamic` | — | The direction input consumed by `SV_StartParticle`. |
| `color` | `dynamic` | — | Color value used by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L171)

<a id="function-function-miniquake-sv-main-sv-startsound-function-sv-startsound-state-entityindex-channel-sample-volume-attenuation-src-miniquake-sv-main-ml-1344171260"></a>
### SV_StartSound

```ml
function SV_StartSound(state, entityIndex, channel, sample, volume, attenuation)
```

SV_StartSound

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_StartSound`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `channel` | `dynamic` | — | The channel input consumed by `SV_StartSound`. |
| `sample` | `dynamic` | — | The sample input consumed by `SV_StartSound`. |
| `volume` | `dynamic` | — | The volume input consumed by `SV_StartSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `SV_StartSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L185)

<a id="function-function-miniquake-sv-main-sv-updatetoreliablemessages-function-sv-updatetoreliablemessages-state-src-miniquake-sv-main-ml-663019384"></a>
### SV_UpdateToReliableMessages

```ml
function SV_UpdateToReliableMessages(state)
```

SV_UpdateToReliableMessages

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_UpdateToReliableMessages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L888)

<a id="function-function-miniquake-sv-main-sv-writeclientdatatomessage-function-sv-writeclientdatatomessage-state-clientvalue-player-buffer-src-miniquake-sv-main-ml-775629321"></a>
### SV_WriteClientdataToMessage

```ml
function SV_WriteClientdataToMessage(state, clientValue, player, buffer)
```

SV_WriteClientdataToMessage

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_WriteClientdataToMessage`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `SV_WriteClientdataToMessage`. |
| `player` | `dynamic` | — | The player input consumed by `SV_WriteClientdataToMessage`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `SV_WriteClientdataToMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L790)

<a id="function-function-miniquake-sv-main-sv-writeentitiestoclient-function-sv-writeentitiestoclient-state-cliententity-buffer-src-miniquake-sv-main-ml-1377655250"></a>
### SV_WriteEntitiesToClient

```ml
function SV_WriteEntitiesToClient(state, clientEntity, buffer)
```

Apply the Quake-compatible sv write entities to client behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_WriteEntitiesToClient`. |
| `clientEntity` | `dynamic` | — | The client entity input consumed by `SV_WriteEntitiesToClient`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `SV_WriteEntitiesToClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L604)

<a id="function-function-miniquake-sv-main-sv-writeentitiestoclientreserved-function-sv-writeentitiestoclientreserved-state-cliententity-buffer-reservedbytes-src-miniquake-sv-main-ml-1095289203"></a>
### SV_WriteEntitiesToClientReserved

```ml
function SV_WriteEntitiesToClientReserved(state, clientEntity, buffer, reservedBytes)
```

SV_WriteEntitiesToClient with an optional tail budget supplied by SV_SendClientDatagram for frame-local sounds and temporary entities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_WriteEntitiesToClientReserved`. |
| `clientEntity` | `dynamic` | — | The client entity input consumed by `SV_WriteEntitiesToClientReserved`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `SV_WriteEntitiesToClientReserved`. |
| `reservedBytes` | `dynamic` | — | Byte data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L533)

<a id="function-function-miniquake-sv-main-sv-writeentitydelta-function-sv-writeentitydelta-state-buffer-item-src-miniquake-sv-main-ml-648376877"></a>
### SV_WriteEntityDelta

```ml
function SV_WriteEntityDelta(state, buffer, item)
```

Exact Protocol-15 fast-update encoder used by SV_WriteEntitiesToClient.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `SV_WriteEntityDelta`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `SV_WriteEntityDelta`. |
| `item` | `dynamic` | — | The item input consumed by `SV_WriteEntityDelta`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L519)

<a id="function-function-miniquake-sv-main-svmabsolute-function-svmabsolute-value-src-miniquake-sv-main-ml-936260654"></a>
### svmAbsolute

```ml
function svmAbsolute(value)
```

Apply server-side absolute semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `svmAbsolute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L501)

- [miniquake.sv_main.SvMainState](Type-miniquake-sv-main-svmainstate-899777601.md) — struct
<a id="function-function-miniquake-sv-main-svmappenddatagram-function-svmappenddatagram-destination-source-src-miniquake-sv-main-ml-135783554"></a>
### svmAppendDatagram

```ml
function svmAppendDatagram(destination, source)
```

Apply server-side append datagram semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L844)

<a id="function-function-miniquake-sv-main-svmappendserverinfo-function-svmappendserverinfo-server-clientvalue-src-miniquake-sv-main-ml-1750508326"></a>
### svmAppendServerInfo

```ml
function svmAppendServerInfo(server, clientValue)
```

Apply server-side append server info semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svmAppendServerInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L219)

<a id="function-function-miniquake-sv-main-svmboxplanesides-function-svmboxplanesides-mins-maxs-plane-src-miniquake-sv-main-ml-1587965201"></a>
### svmBoxPlaneSides

```ml
function svmBoxPlaneSides(mins, maxs, plane)
```

Apply server-side box plane sides semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `svmBoxPlaneSides`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `svmBoxPlaneSides`. |
| `plane` | `dynamic` | — | The plane input consumed by `svmBoxPlaneSides`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L417)

<a id="function-function-miniquake-sv-main-svmclampbyte-function-svmclampbyte-value-src-miniquake-sv-main-ml-2065677416"></a>
### svmClampByte

```ml
function svmClampByte(value)
```

Apply server-side clamp byte semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `svmClampByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L724)

<a id="function-function-miniquake-sv-main-svmclientitems-function-svmclientitems-state-clientvalue-player-src-miniquake-sv-main-ml-1761002467"></a>
### svmClientItems

```ml
function svmClientItems(state, clientValue, player)
```

Apply server-side client items semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmClientItems`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svmClientItems`. |
| `player` | `dynamic` | — | The player input consumed by `svmClientItems`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L649)

<a id="function-function-miniquake-sv-main-svmcurrentfrags-function-svmcurrentfrags-state-clientindex-src-miniquake-sv-main-ml-947565883"></a>
### svmCurrentFrags

```ml
function svmCurrentFrags(state, clientIndex)
```

Apply server-side current frags semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmCurrentFrags`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L878)

<a id="function-function-miniquake-sv-main-svmentitybits-function-svmentitybits-item-src-miniquake-sv-main-ml-1769660720"></a>
### svmEntityBits

```ml
function svmEntityBits(item)
```

Apply server-side entity bits semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `svmEntityBits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L508)

<a id="function-function-miniquake-sv-main-svmentitycenter-function-svmentitycenter-item-src-miniquake-sv-main-ml-1212575054"></a>
### svmEntityCenter

```ml
function svmEntityCenter(item)
```

Apply server-side entity center semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `svmEntityCenter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L161)

<a id="function-function-miniquake-sv-main-svmentityvisible-function-svmentityvisible-state-item-clientedict-pvs-src-miniquake-sv-main-ml-935039206"></a>
### svmEntityVisible

```ml
function svmEntityVisible(state, item, clientEdict, pvs)
```

Apply server-side entity visible semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmEntityVisible`. |
| `item` | `dynamic` | — | The item input consumed by `svmEntityVisible`. |
| `clientEdict` | `dynamic` | — | The client edict input consumed by `svmEntityVisible`. |
| `pvs` | `dynamic` | — | The pvs input consumed by `svmEntityVisible`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L485)

<a id="function-function-miniquake-sv-main-svmfreeclientindex-function-svmfreeclientindex-state-src-miniquake-sv-main-ml-968544056"></a>
### svmFreeClientIndex

```ml
function svmFreeClientIndex(state)
```

Apply server-side free client index semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmFreeClientIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L295)

<a id="function-function-miniquake-sv-main-svmleafbitvisible-function-svmleafbitvisible-pvs-leafindex-src-miniquake-sv-main-ml-1429345622"></a>
### svmLeafBitVisible

```ml
function svmLeafBitVisible(pvs, leafIndex)
```

Apply server-side leaf bit visible semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pvs` | `dynamic` | — | The pvs input consumed by `svmLeafBitVisible`. |
| `leafIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L472)

<a id="function-function-miniquake-sv-main-svmlocalmodels-function-svmlocalmodels-src-miniquake-sv-main-ml-341303317"></a>
### svmLocalModels

```ml
function svmLocalModels()
```

Apply server-side local models semantics.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L75)

<a id="function-function-miniquake-sv-main-svmorbytes-function-svmorbytes-destination-source-count-src-miniquake-sv-main-ml-33872973"></a>
### svmOrBytes

```ml
function svmOrBytes(destination, source, count)
```

Apply server-side or bytes semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L346)

<a id="function-function-miniquake-sv-main-svmprogscrc-function-svmprogscrc-server-src-miniquake-sv-main-ml-738078812"></a>
### svmProgsCrc

```ml
function svmProgsCrc(server)
```

Apply server-side progs crc semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L210)

<a id="function-function-miniquake-sv-main-svmqcfloat-function-svmqcfloat-state-entityindex-fieldname-fallback-src-miniquake-sv-main-ml-123296834"></a>
### svmQcFloat

```ml
function svmQcFloat(state, entityIndex, fieldName, fallback)
```

Apply server-side qc float semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmQcFloat`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L630)

<a id="function-function-miniquake-sv-main-svmqcvector-function-svmqcvector-state-entityindex-fieldname-fallback-src-miniquake-sv-main-ml-355256996"></a>
### svmQcVector

```ml
function svmQcVector(state, entityIndex, fieldName, fallback)
```

Apply server-side qc vector semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmQcVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L640)

<a id="function-function-miniquake-sv-main-svmresetclient-function-svmresetclient-state-clientindex-socket-src-miniquake-sv-main-ml-1471060494"></a>
### svmResetClient

```ml
function svmResetClient(state, clientIndex, socket)
```

Apply server-side reset client semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmResetClient`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L250)

<a id="function-function-miniquake-sv-main-svmsoundindex-function-svmsoundindex-server-sample-src-miniquake-sv-main-ml-1531055758"></a>
### svmSoundIndex

```ml
function svmSoundIndex(server, sample)
```

Apply server-side sound index semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `sample` | `dynamic` | — | The sample input consumed by `svmSoundIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L150)

<a id="function-function-miniquake-sv-main-svmtouchedleaves-function-svmtouchedleaves-map-nodeindex-mins-maxs-result-src-miniquake-sv-main-ml-1820187308"></a>
### svmTouchedLeaves

```ml
function svmTouchedLeaves(map, nodeIndex, mins, maxs, result)
```

Apply server-side touched leaves semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `svmTouchedLeaves`. |
| `nodeIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `mins` | `dynamic` | — | The mins input consumed by `svmTouchedLeaves`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `svmTouchedLeaves`. |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L450)

<a id="function-function-miniquake-sv-main-svmweaponmodelindex-function-svmweaponmodelindex-state-entityindex-fallback-src-miniquake-sv-main-ml-312160671"></a>
### svmWeaponModelIndex

```ml
function svmWeaponModelIndex(state, entityIndex, fallback)
```

Apply server-side weapon model index semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmWeaponModelIndex`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L665)

<a id="function-function-miniquake-sv-main-svmwritebaseline-function-svmwritebaseline-buffer-entitynumber-baseline-src-miniquake-sv-main-ml-1906914678"></a>
### svmWriteBaseline

```ml
function svmWriteBaseline(buffer, entityNumber, baseline)
```

Apply server-side write baseline semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `svmWriteBaseline`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `svmWriteBaseline`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `svmWriteBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L1066)

<a id="function-function-miniquake-sv-main-svmwritedamage-function-svmwritedamage-state-clientvalue-buffer-src-miniquake-sv-main-ml-1397780616"></a>
### svmWriteDamage

```ml
function svmWriteDamage(state, clientValue, buffer)
```

Apply server-side write damage semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmWriteDamage`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svmWriteDamage`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `svmWriteDamage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L735)

<a id="function-function-miniquake-sv-main-svmwritedamageandangle-function-svmwritedamageandangle-state-clientvalue-player-buffer-src-miniquake-sv-main-ml-715656241"></a>
### svmWriteDamageAndAngle

```ml
function svmWriteDamageAndAngle(state, clientValue, player, buffer)
```

Apply server-side write damage and angle semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmWriteDamageAndAngle`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svmWriteDamageAndAngle`. |
| `player` | `dynamic` | — | The player input consumed by `svmWriteDamageAndAngle`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `svmWriteDamageAndAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L779)

<a id="function-function-miniquake-sv-main-svmwritefixangle-function-svmwritefixangle-state-clientvalue-player-buffer-src-miniquake-sv-main-ml-802651897"></a>
### svmWriteFixAngle

```ml
function svmWriteFixAngle(state, clientValue, player, buffer)
```

Apply server-side write fix angle semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sv_main` state used by `svmWriteFixAngle`. |
| `clientValue` | `dynamic` | — | The client value input consumed by `svmWriteFixAngle`. |
| `player` | `dynamic` | — | The player input consumed by `svmWriteFixAngle`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `svmWriteFixAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L759)

<a id="function-function-miniquake-sv-main-svmzerospawnparms-function-svmzerospawnparms-src-miniquake-sv-main-ml-1815707793"></a>
### svmZeroSpawnParms

```ml
function svmZeroSpawnParms()
```

Apply server-side zero spawn parms semantics.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sv_main.ml#L70)
