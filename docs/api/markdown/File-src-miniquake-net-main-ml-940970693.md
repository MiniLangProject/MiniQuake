# `src/miniquake/net_main.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.net_main`](Package-miniquake-net-main-1514481342.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/net_datagram.ml` as `datagram` → [src/miniquake/net_datagram.ml](File-src-miniquake-net-datagram-ml-84886599.md)
- `miniquake/net_loop.ml` as `netloop` → [src/miniquake/net_loop.ml](File-src-miniquake-net-loop-ml-170267060.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)

## Declarations

<a id="function-function-miniquake-net-main-appenduniquesocket-function-appenduniquesocket-values-socket-src-miniquake-net-main-ml-425957416"></a>
### appendUniqueSocket

```ml
function appendUniqueSocket(values, socket)
```

Add one socket identity at most once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `appendUniqueSocket`. |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L121)

<a id="function-function-miniquake-net-main-arraytail-function-arraytail-values-src-miniquake-net-main-ml-917959565"></a>
### arrayTail

```ml
function arrayTail(values)
```

Implements the `arrayTail` operation for `miniquake.net_main` (array tail).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `arrayTail`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L85)

<a id="function-function-miniquake-net-main-cachedaddress-function-cachedaddress-state-host-src-miniquake-net-main-ml-1159332248"></a>
### cachedAddress

```ml
function cachedAddress(state, host)
```

Implements the `cachedAddress` operation for `miniquake.net_main` (cached address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `cachedAddress`. |
| `host` | `dynamic` | — | The host input consumed by `cachedAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L624)

<a id="function-function-miniquake-net-main-compactactivesockets-function-compactactivesockets-src-miniquake-net-main-ml-1460229117"></a>
### compactActiveSockets

```ml
function compactActiveSockets()
```

Compact the active list and reclaim externally disconnected qsocket slots. Driver code may mark a socket disconnected before NET_Close observes it. The C engine still returns that fixed qsocket_t to net_freeSockets; dropping the MiniLang object here permanently shrank the pool on every reconnect.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L130)

<a id="global-global-miniquake-net-main-defaultnet-hostport-defaultnet-hostport-src-miniquake-net-main-ml-1155238427"></a>
### DEFAULTnet_hostport

```ml
DEFAULTnet_hostport
```

Tracks the module-level defaul tnet hostport state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L21)

<a id="function-function-miniquake-net-main-ensuresocketpool-function-ensuresocketpool-src-miniquake-net-main-ml-1323436613"></a>
### ensureSocketPool

```ml
function ensureSocketPool()
```

Ensure sufficient storage or state for socket pool.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L196)

<a id="function-function-miniquake-net-main-ensuresocketpoolcapacity-function-ensuresocketpoolcapacity-clientcount-src-miniquake-net-main-ml-1185401863"></a>
### ensureSocketPoolCapacity

```ml
function ensureSocketPoolCapacity(clientCount)
```

Grow the fixed qsocket arena when maxplayers is raised before a server starts. Host_FindMaxClients reserves at least four client slots in Quake; MiniQuake resizes its server dynamically, so the network arena must mirror that growth instead of retaining the two sockets from a single-player boot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clientCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L215)

<a id="global-global-miniquake-net-main-hostcache-hostcache-src-miniquake-net-main-ml-1685426599"></a>
### hostcache

```ml
hostcache
```

Tracks the module-level hostcache state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L63)

<a id="global-global-miniquake-net-main-hostcachecount-hostcachecount-src-miniquake-net-main-ml-1411233353"></a>
### hostCacheCount

```ml
hostCacheCount
```

Tracks the module-level host cache count state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L61)

<a id="function-function-miniquake-net-main-isid-function-isid-address-idgodsenabled-src-miniquake-net-main-ml-417852904"></a>
### IsID

```ml
function IsID(address, idgodsEnabled)
```

Report whether is id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |
| `idgodsEnabled` | `dynamic` | — | The idgods enabled input consumed by `IsID`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L910)

<a id="global-global-miniquake-net-main-listening-listening-src-miniquake-net-main-ml-1246331479"></a>
### listening

```ml
listening
```

Tracks the module-level listening state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L49)

<a id="global-global-miniquake-net-main-maximumclients-maximumclients-src-miniquake-net-main-ml-1925030775"></a>
### maximumClients

```ml
maximumClients
```

Tracks the module-level maximum clients state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L70)

<a id="function-function-miniquake-net-main-maxplayers-f-function-maxplayers-f-currentplayers-maximumlimit-serveractive-requested-src-miniquake-net-main-ml-284408312"></a>
### MaxPlayers_f

```ml
function MaxPlayers_f(currentPlayers, maximumLimit, serverActive, requested)
```

Mirror Quake's MaxPlayers_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentPlayers` | `dynamic` | — | The current players input consumed by `MaxPlayers_f`. |
| `maximumLimit` | `dynamic` | — | The maximum limit input consumed by `MaxPlayers_f`. |
| `serverActive` | `dynamic` | — | The server active input consumed by `MaxPlayers_f`. |
| `requested` | `dynamic` | — | The requested input consumed by `MaxPlayers_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L338)

<a id="global-global-miniquake-net-main-messagesreceived-messagesreceived-src-miniquake-net-main-ml-2116850361"></a>
### messagesReceived

```ml
messagesReceived
```

Tracks the module-level messages received state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L42)

<a id="global-global-miniquake-net-main-messagessent-messagessent-src-miniquake-net-main-ml-1484057259"></a>
### messagesSent

```ml
messagesSent
```

Tracks the module-level messages sent state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L40)

<a id="global-global-miniquake-net-main-net-activeconnections-net-activeconnections-src-miniquake-net-main-ml-571150347"></a>
### net_activeconnections

```ml
net_activeconnections
```

Tracks the module-level net activeconnections state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L33)

<a id="global-global-miniquake-net-main-net-activesockets-net-activesockets-src-miniquake-net-main-ml-979393515"></a>
### net_activeSockets

```ml
net_activeSockets
```

Tracks the module-level net active sockets state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L35)

<a id="function-function-miniquake-net-main-net-cansendmessage-function-net-cansendmessage-socket-src-miniquake-net-main-ml-121484074"></a>
### NET_CanSendMessage

```ml
function NET_CanSendMessage(socket)
```

Mirror Quake's NET_CanSendMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L782)

<a id="function-function-miniquake-net-main-net-cansendunreliablemessage-function-net-cansendunreliablemessage-socket-src-miniquake-net-main-ml-2008039286"></a>
### NET_CanSendUnreliableMessage

```ml
function NET_CanSendUnreliableMessage(socket)
```

Mirror Quake's NET_CanSendUnreliableMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L790)

<a id="function-function-miniquake-net-main-net-checknewconnections-function-net-checknewconnections-state-src-miniquake-net-main-ml-595811296"></a>
### NET_CheckNewConnections

```ml
function NET_CheckNewConnections(state)
```

Mirror Quake's NET_CheckNewConnections routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_CheckNewConnections`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L689)

<a id="function-function-miniquake-net-main-net-clearpollprocedures-function-net-clearpollprocedures-src-miniquake-net-main-ml-996940385"></a>
### NET_ClearPollProcedures

```ml
function NET_ClearPollProcedures()
```

Mirror Quake's NET_ClearPollProcedures routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L410)

<a id="function-function-miniquake-net-main-net-close-function-net-close-socket-src-miniquake-net-main-ml-638241022"></a>
### NET_Close

```ml
function NET_Close(socket)
```

Mirror Quake's NET_Close routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L701)

<a id="function-function-miniquake-net-main-net-connect-function-net-connect-state-host-timeoutmilliseconds-src-miniquake-net-main-ml-506225425"></a>
### NET_Connect

```ml
function NET_Connect(state, host, timeoutMilliseconds)
```

Mirror Quake's NET_Connect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_Connect`. |
| `host` | `dynamic` | — | The host input consumed by `NET_Connect`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `NET_Connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L636)

<a id="function-function-miniquake-net-main-net-connectinterop-function-net-connectinterop-state-host-timeoutmilliseconds-resendmilliseconds-src-miniquake-net-main-ml-529714634"></a>
### NET_ConnectInterop

```ml
function NET_ConnectInterop(state, host, timeoutMilliseconds, resendMilliseconds)
```

Strict external-reference connection path.  Unlike the regular Quake menu connection, this keeps one UDP source endpoint alive and resends the Protocol-3 request at a short interval until the original server accepts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_ConnectInterop`. |
| `host` | `dynamic` | — | The host input consumed by `NET_ConnectInterop`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `NET_ConnectInterop`. |
| `resendMilliseconds` | `dynamic` | — | The resend milliseconds input consumed by `NET_ConnectInterop`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L675)

<a id="function-function-miniquake-net-main-net-connectionaccepted-function-net-connectionaccepted-src-miniquake-net-main-ml-718315685"></a>
### NET_ConnectionAccepted

```ml
function NET_ConnectionAccepted()
```

Mirror Quake's NET_ConnectionAccepted routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L296)

<a id="function-function-miniquake-net-main-net-connectionclosed-function-net-connectionclosed-src-miniquake-net-main-ml-1219193629"></a>
### NET_ConnectionClosed

```ml
function NET_ConnectionClosed()
```

Mirror Quake's NET_ConnectionClosed routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L303)

<a id="global-global-miniquake-net-main-net-driverlevel-net-driverlevel-src-miniquake-net-main-ml-771617095"></a>
### net_driverlevel

```ml
net_driverlevel
```

Tracks the module-level net driverlevel state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L27)

<a id="function-function-miniquake-net-main-net-freeqsocket-function-net-freeqsocket-socket-src-miniquake-net-main-ml-390492818"></a>
### NET_FreeQSocket

```ml
function NET_FreeQSocket(socket)
```

Mirror Quake's NET_FreeQSocket routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L256)

<a id="global-global-miniquake-net-main-net-freesockets-net-freesockets-src-miniquake-net-main-ml-908710227"></a>
### net_freeSockets

```ml
net_freeSockets
```

Tracks the module-level net free sockets state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L37)

<a id="function-function-miniquake-net-main-net-getmessage-function-net-getmessage-socket-destination-timeoutseconds-src-miniquake-net-main-ml-1882933048"></a>
### NET_GetMessage

```ml
function NET_GetMessage(socket, destination, timeoutSeconds)
```

Mirror Quake's NET_GetMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `timeoutSeconds` | `dynamic` | — | The timeout seconds input consumed by `NET_GetMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L746)

<a id="global-global-miniquake-net-main-net-hostport-net-hostport-src-miniquake-net-main-ml-1218728081"></a>
### net_hostport

```ml
net_hostport
```

Tracks the module-level net hostport state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L23)

<a id="function-function-miniquake-net-main-net-init-function-net-init-state-maxclients-dedicated-listenrequested-requestedport-nolan-src-miniquake-net-main-ml-1249084899"></a>
### NET_Init

```ml
function NET_Init(state, maxClients, dedicated, listenRequested, requestedPort, noLan)
```

Mirror Quake's NET_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_Init`. |
| `maxClients` | `dynamic` | — | The max clients input consumed by `NET_Init`. |
| `dedicated` | `dynamic` | — | The dedicated input consumed by `NET_Init`. |
| `listenRequested` | `dynamic` | — | The listen requested input consumed by `NET_Init`. |
| `requestedPort` | `dynamic` | — | The requested port input consumed by `NET_Init`. |
| `noLan` | `dynamic` | — | The no lan input consumed by `NET_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L859)

<a id="function-function-miniquake-net-main-net-islistening-function-net-islistening-src-miniquake-net-main-ml-664017795"></a>
### NET_IsListening

```ml
function NET_IsListening()
```

Mirror Quake's NET_IsListening routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L491)

<a id="function-function-miniquake-net-main-net-listen-f-function-net-listen-f-state-enabled-port-src-miniquake-net-main-ml-1211298710"></a>
### NET_Listen_f

```ml
function NET_Listen_f(state, enabled, port)
```

Mirror Quake's NET_Listen_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_Listen_f`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `port` | `dynamic` | — | The port input consumed by `NET_Listen_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L323)

<a id="function-function-miniquake-net-main-net-messagecounters-function-net-messagecounters-src-miniquake-net-main-ml-909875569"></a>
### NET_MessageCounters

```ml
function NET_MessageCounters()
```

Mirror Quake's NET_MessageCounters routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L496)

<a id="global-global-miniquake-net-main-net-messagetimeout-net-messagetimeout-src-miniquake-net-main-ml-262089347"></a>
### net_messagetimeout

```ml
net_messagetimeout
```

Tracks the module-level net messagetimeout state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L74)

<a id="function-function-miniquake-net-main-net-newqsocket-function-net-newqsocket-src-miniquake-net-main-ml-650578181"></a>
### NET_NewQSocket

```ml
function NET_NewQSocket()
```

Mirror Quake's NET_NewQSocket routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L183)

<a id="global-global-miniquake-net-main-net-numsockets-net-numsockets-src-miniquake-net-main-ml-285135787"></a>
### net_numsockets

```ml
net_numsockets
```

Tracks the module-level net numsockets state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L29)

<a id="function-function-miniquake-net-main-net-poll-function-net-poll-src-miniquake-net-main-ml-1673810709"></a>
### NET_Poll

```ml
function NET_Poll()
```

Mirror Quake's NET_Poll routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L607)

<a id="function-function-miniquake-net-main-net-pollproceduresnapshot-inline-function-net-pollproceduresnapshot-src-miniquake-net-main-ml-423685574"></a>
### NET_PollProcedureSnapshot

```ml
inline function NET_PollProcedureSnapshot()
```

Mirror Quake's NET_PollProcedureSnapshot routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L430)

<a id="function-function-miniquake-net-main-net-port-f-function-net-port-f-state-requested-src-miniquake-net-main-ml-1868363992"></a>
### NET_Port_f

```ml
function NET_Port_f(state, requested)
```

Mirror Quake's NET_Port_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_Port_f`. |
| `requested` | `dynamic` | — | The requested input consumed by `NET_Port_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L354)

<a id="function-function-miniquake-net-main-net-portstate-inline-function-net-portstate-src-miniquake-net-main-ml-1771651570"></a>
### NET_PortState

```ml
inline function NET_PortState()
```

Mirror Quake's NET_PortState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L486)

<a id="function-function-miniquake-net-main-net-queuesnapshot-function-net-queuesnapshot-src-miniquake-net-main-ml-862642567"></a>
### NET_QueueSnapshot

```ml
function NET_QueueSnapshot()
```

QSocket counts alone cannot reveal a reliable fragment permanently waiting for an ACK.  Include completed queues and in-progress channel bytes so soak tests can prove that network work is bounded.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L466)

<a id="function-function-miniquake-net-main-net-replacehostcache-function-net-replacehostcache-items-src-miniquake-net-main-ml-1671482857"></a>
### NET_ReplaceHostCache

```ml
function NET_ReplaceHostCache(items)
```

Mirror Quake's NET_ReplaceHostCache routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | The items input consumed by `NET_ReplaceHostCache`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L402)

<a id="function-function-miniquake-net-main-net-sendmessage-function-net-sendmessage-socket-data-src-miniquake-net-main-ml-940822612"></a>
### NET_SendMessage

```ml
function NET_SendMessage(socket, data)
```

Mirror Quake's NET_SendMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L761)

<a id="function-function-miniquake-net-main-net-sendtoall-function-net-sendtoall-clients-data-blocktime-src-miniquake-net-main-ml-1584119673"></a>
### NET_SendToAll

```ml
function NET_SendToAll(clients, data, blocktime)
```

Mirror Quake's NET_SendToAll routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `clients` | `dynamic` | — | The clients input consumed by `NET_SendToAll`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `blocktime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L799)

<a id="function-function-miniquake-net-main-net-sendunreliablemessage-function-net-sendunreliablemessage-socket-data-src-miniquake-net-main-ml-1482914950"></a>
### NET_SendUnreliableMessage

```ml
function NET_SendUnreliableMessage(socket, data)
```

Mirror Quake's NET_SendUnreliableMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L772)

<a id="function-function-miniquake-net-main-net-setmaximumclients-function-net-setmaximumclients-count-src-miniquake-net-main-ml-1858623764"></a>
### NET_SetMaximumClients

```ml
function NET_SetMaximumClients(count)
```

Mirror Quake's NET_SetMaximumClients routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L311)

<a id="function-function-miniquake-net-main-net-setmessagetimeout-function-net-setmessagetimeout-timeoutseconds-src-miniquake-net-main-ml-794094281"></a>
### NET_SetMessageTimeout

```ml
function NET_SetMessageTimeout(timeoutSeconds)
```

Mirror Quake's NET_SetMessageTimeout routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `timeoutSeconds` | `dynamic` | — | The timeout seconds input consumed by `NET_SetMessageTimeout`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L729)

<a id="function-function-miniquake-net-main-net-setsliststarttime-function-net-setsliststarttime-value-src-miniquake-net-main-ml-1332625634"></a>
### NET_SetSlistStartTime

```ml
function NET_SetSlistStartTime(value)
```

Mirror Quake's NET_SetSlistStartTime routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `NET_SetSlistStartTime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L418)

<a id="function-function-miniquake-net-main-net-shutdown-function-net-shutdown-state-src-miniquake-net-main-ml-234144406"></a>
### NET_Shutdown

```ml
function NET_Shutdown(state)
```

Mirror Quake's NET_Shutdown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L892)

<a id="function-function-miniquake-net-main-net-slist-f-function-net-slist-f-state-silent-localonly-port-src-miniquake-net-main-ml-1660608711"></a>
### NET_Slist_f

```ml
function NET_Slist_f(state, silent, localOnly, port)
```

Mirror Quake's NET_Slist_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_main` state used by `NET_Slist_f`. |
| `silent` | `dynamic` | — | The silent input consumed by `NET_Slist_f`. |
| `localOnly` | `dynamic` | — | The local only input consumed by `NET_Slist_f`. |
| `port` | `dynamic` | — | The port input consumed by `NET_Slist_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L531)

<a id="function-function-miniquake-net-main-net-slistflags-function-net-slistflags-src-miniquake-net-main-ml-70607969"></a>
### NET_SlistFlags

```ml
function NET_SlistFlags()
```

Mirror Quake's NET_SlistFlags routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L425)

<a id="function-function-miniquake-net-main-net-socketcounts-function-net-socketcounts-src-miniquake-net-main-ml-546870917"></a>
### NET_SocketCounts

```ml
function NET_SocketCounts()
```

Mirror Quake's NET_SocketCounts routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L435)

<a id="global-global-miniquake-net-main-net-socketreserve-net-socketreserve-src-miniquake-net-main-ml-1543101299"></a>
### net_socketReserve

```ml
net_socketReserve
```

Tracks the module-level net socket reserve state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L31)

<a id="function-function-miniquake-net-main-net-sockettimedout-function-net-sockettimedout-socket-timeoutseconds-src-miniquake-net-main-ml-822497982"></a>
### NET_SocketTimedOut

```ml
function NET_SocketTimedOut(socket, timeoutSeconds)
```

Mirror Quake's NET_SocketTimedOut routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `timeoutSeconds` | `dynamic` | — | The timeout seconds input consumed by `NET_SocketTimedOut`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L738)

<a id="global-global-miniquake-net-main-net-time-net-time-src-miniquake-net-main-ml-370295209"></a>
### net_time

```ml
net_time
```

Tracks the module-level net time state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L25)

<a id="function-function-miniquake-net-main-net-tracksocket-function-net-tracksocket-socket-src-miniquake-net-main-ml-215385746"></a>
### NET_TrackSocket

```ml
function NET_TrackSocket(socket)
```

Mirror Quake's NET_TrackSocket routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L230)

<a id="global-global-miniquake-net-main-networkstate-networkstate-src-miniquake-net-main-ml-1601669801"></a>
### networkState

```ml
networkState
```

Tracks the module-level network state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L68)

<a id="global-global-miniquake-net-main-pollprocedurelist-pollprocedurelist-src-miniquake-net-main-ml-208253759"></a>
### pollProcedureList

```ml
pollProcedureList
```

Tracks the module-level poll procedure list state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L65)

<a id="function-function-miniquake-net-main-printslist-function-printslist-src-miniquake-net-main-ml-889962285"></a>
### PrintSlist

```ml
function PrintSlist()
```

Format and emit slist.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L377)

<a id="function-function-miniquake-net-main-printslistheader-function-printslistheader-src-miniquake-net-main-ml-152259557"></a>
### PrintSlistHeader

```ml
function PrintSlistHeader()
```

Format and emit slist header.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L370)

<a id="function-function-miniquake-net-main-printslisttrailer-function-printslisttrailer-src-miniquake-net-main-ml-148058335"></a>
### PrintSlistTrailer

```ml
function PrintSlistTrailer()
```

Format and emit slist trailer.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L395)

<a id="function-function-miniquake-net-main-resetqsocket-function-resetqsocket-socket-src-miniquake-net-main-ml-1938938350"></a>
### resetQSocket

```ml
function resetQSocket(socket)
```

Update module state for qsocket.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L162)

<a id="function-function-miniquake-net-main-schedulepollprocedure-function-schedulepollprocedure-procedurename-timeoffset-argument-src-miniquake-net-main-ml-338619558"></a>
### SchedulePollProcedure

```ml
function SchedulePollProcedure(procedureName, timeOffset, argument)
```

Implements the `SchedulePollProcedure` operation for `miniquake.net_main` (schedule poll procedure).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `procedureName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `timeOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `argument` | `dynamic` | — | The argument input consumed by `SchedulePollProcedure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L505)

<a id="function-function-miniquake-net-main-setnettime-function-setnettime-src-miniquake-net-main-ml-937012945"></a>
### SetNetTime

```ml
function SetNetTime()
```

Update module state for net time.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L77)

<a id="function-function-miniquake-net-main-slist-poll-function-slist-poll-src-miniquake-net-main-ml-1240676713"></a>
### Slist_Poll

```ml
function Slist_Poll()
```

Mirror Quake's Slist_Poll routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L583)

<a id="function-function-miniquake-net-main-slist-send-function-slist-send-src-miniquake-net-main-ml-1788075497"></a>
### Slist_Send

```ml
function Slist_Send()
```

Mirror Quake's Slist_Send routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L552)

<a id="global-global-miniquake-net-main-slistinprogress-slistinprogress-src-miniquake-net-main-ml-1637518275"></a>
### slistInProgress

```ml
slistInProgress
```

Tracks the module-level slist in progress state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L51)

<a id="global-global-miniquake-net-main-slistlastshown-slistlastshown-src-miniquake-net-main-ml-1006824271"></a>
### slistLastShown

```ml
slistLastShown
```

Tracks the module-level slist last shown state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L59)

<a id="global-global-miniquake-net-main-slistlocal-slistlocal-src-miniquake-net-main-ml-1403799551"></a>
### slistLocal

```ml
slistLocal
```

Tracks the module-level slist local state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L55)

<a id="global-global-miniquake-net-main-slistport-slistport-src-miniquake-net-main-ml-894904207"></a>
### slistPort

```ml
slistPort
```

Tracks the module-level slist port state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L72)

<a id="global-global-miniquake-net-main-slistsilent-slistsilent-src-miniquake-net-main-ml-1270412983"></a>
### slistSilent

```ml
slistSilent
```

Tracks the module-level slist silent state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L53)

<a id="global-global-miniquake-net-main-sliststarttime-sliststarttime-src-miniquake-net-main-ml-2102698619"></a>
### slistStartTime

```ml
slistStartTime
```

Tracks the module-level slist start time state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L57)

<a id="function-function-miniquake-net-main-socketarraycontains-function-socketarraycontains-values-wanted-src-miniquake-net-main-ml-969932028"></a>
### socketArrayContains

```ml
function socketArrayContains(values, wanted)
```

Report whether the requested socket identity is present in an array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `socketArrayContains`. |
| `wanted` | `dynamic` | — | The wanted input consumed by `socketArrayContains`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L98)

<a id="function-function-miniquake-net-main-socketarraywithout-function-socketarraywithout-values-unwanted-src-miniquake-net-main-ml-1706960963"></a>
### socketArrayWithout

```ml
function socketArrayWithout(values, unwanted)
```

Return a socket array with every occurrence of one identity removed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `socketArrayWithout`. |
| `unwanted` | `dynamic` | — | The unwanted input consumed by `socketArrayWithout`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L108)

<a id="function-function-miniquake-net-main-socketqueuedstate-function-socketqueuedstate-socket-src-miniquake-net-main-ml-281937372"></a>
### socketQueuedState

```ml
function socketQueuedState(socket)
```

Return socket queued state derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L442)

<a id="function-function-miniquake-net-main-synchronizecounters-function-synchronizecounters-src-miniquake-net-main-ml-429747351"></a>
### synchronizeCounters

```ml
function synchronizeCounters()
```

Update module state for counters.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L718)

<a id="global-global-miniquake-net-main-unreliablemessagesreceived-unreliablemessagesreceived-src-miniquake-net-main-ml-2070270579"></a>
### unreliableMessagesReceived

```ml
unreliableMessagesReceived
```

Tracks the module-level unreliable messages received state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L46)

<a id="global-global-miniquake-net-main-unreliablemessagessent-unreliablemessagessent-src-miniquake-net-main-ml-94001597"></a>
### unreliableMessagesSent

```ml
unreliableMessagesSent
```

Tracks the module-level unreliable messages sent state owned by `miniquake.net_main`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_main.ml#L44)
