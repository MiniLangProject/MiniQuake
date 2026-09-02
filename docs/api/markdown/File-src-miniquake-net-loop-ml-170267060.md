# `src/miniquake/net_loop.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.net_loop`](Package-miniquake-net-loop-1925012645.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/net_control.ml` as `control` → [src/miniquake/net_control.ml](File-src-miniquake-net-control-ml-1677814447.md)
- `miniquake/net_datagram.ml` as `datagram` → [src/miniquake/net_datagram.ml](File-src-miniquake-net-datagram-ml-84886599.md)
- `miniquake/net_udp.ml` as `udp` → [src/miniquake/net_udp.ml](File-src-miniquake-net-udp-ml-1891257481.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-net-loop-datagram-checknewconnections-function-datagram-checknewconnections-state-src-miniquake-net-loop-ml-1898926320"></a>
### _Datagram_CheckNewConnections

```ml
function _Datagram_CheckNewConnections(state)
```

Implements the `_Datagram_CheckNewConnections` operation for `miniquake.net_loop` (datagram check new connections).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `_Datagram_CheckNewConnections`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1012)

<a id="function-function-miniquake-net-loop-datagram-connect-function-datagram-connect-state-host-timeoutmilliseconds-src-miniquake-net-loop-ml-1543696095"></a>
### _Datagram_Connect

```ml
function _Datagram_Connect(state, host, timeoutMilliseconds)
```

Compatibility wrapper for callers that intentionally use the historical default port.  Public NET_Connect passes the active net_hostport instead.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `_Datagram_Connect`. |
| `host` | `dynamic` | — | The host input consumed by `_Datagram_Connect`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `_Datagram_Connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1092)

<a id="function-function-miniquake-net-loop-datagram-connectport-function-datagram-connectport-state-host-timeoutmilliseconds-defaultport-src-miniquake-net-loop-ml-233196889"></a>
### _Datagram_ConnectPort

```ml
function _Datagram_ConnectPort(state, host, timeoutMilliseconds, defaultPort)
```

Implements the `_Datagram_ConnectPort` operation for `miniquake.net_loop` (datagram connect port).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `_Datagram_ConnectPort`. |
| `host` | `dynamic` | — | The host input consumed by `_Datagram_ConnectPort`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `_Datagram_ConnectPort`. |
| `defaultPort` | `dynamic` | — | The default port input consumed by `_Datagram_ConnectPort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1060)

<a id="function-function-miniquake-net-loop-datagram-searchforhosts-function-datagram-searchforhosts-searchsocket-hosts-port-timeoutmilliseconds-xmit-src-miniquake-net-loop-ml-1877280055"></a>
### _Datagram_SearchForHosts

```ml
function _Datagram_SearchForHosts(searchSocket, hosts, port, timeoutMilliseconds, xmit)
```

Implements the `_Datagram_SearchForHosts` operation for `miniquake.net_loop` (datagram search for hosts).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `searchSocket` | `dynamic` | — | The search socket input consumed by `_Datagram_SearchForHosts`. |
| `hosts` | `dynamic` | — | The hosts input consumed by `_Datagram_SearchForHosts`. |
| `port` | `dynamic` | — | The port input consumed by `_Datagram_SearchForHosts`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `_Datagram_SearchForHosts`. |
| `xmit` | `dynamic` | — | The xmit input consumed by `_Datagram_SearchForHosts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L522)

<a id="function-function-miniquake-net-loop-addressisbanned-function-addressisbanned-state-address-src-miniquake-net-loop-ml-518148896"></a>
### addressIsBanned

```ml
function addressIsBanned(state, address)
```

Add state for address is banned.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `addressIsBanned`. |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L222)

<a id="function-function-miniquake-net-loop-arraytail-function-arraytail-values-src-miniquake-net-loop-ml-1872916305"></a>
### arrayTail

```ml
function arrayTail(values)
```

Implements the `arrayTail` operation for `miniquake.net_loop` (array tail).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `arrayTail`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L759)

<a id="function-function-miniquake-net-loop-cansendmessage-function-cansendmessage-socket-src-miniquake-net-loop-ml-533324366"></a>
### canSendMessage

```ml
function canSendMessage(socket)
```

Report whether can send message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L932)

<a id="function-function-miniquake-net-loop-checknewconnections-function-checknewconnections-state-src-miniquake-net-loop-ml-440833350"></a>
### checkNewConnections

```ml
function checkNewConnections(state)
```

Validate new connections and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `checkNewConnections`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L753)

<a id="function-function-miniquake-net-loop-close-function-close-socket-src-miniquake-net-loop-ml-1569685410"></a>
### close

```ml
function close(socket)
```

Implements the `close` operation for `miniquake.net_loop` (close).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L954)

<a id="function-function-miniquake-net-loop-compactremotesockets-function-compactremotesockets-state-src-miniquake-net-loop-ml-530088472"></a>
### compactRemoteSockets

```ml
function compactRemoteSockets(state)
```

Implements the `compactRemoteSockets` operation for `miniquake.net_loop` (compact remote sockets).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `compactRemoteSockets`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L231)

<a id="function-function-miniquake-net-loop-configurequerydata-function-configurequerydata-state-players-rules-src-miniquake-net-loop-ml-1252406183"></a>
### configureQueryData

```ml
function configureQueryData(state, players, rules)
```

Update subsystem configuration for configure query data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `configureQueryData`. |
| `players` | `dynamic` | — | The players input consumed by `configureQueryData`. |
| `rules` | `dynamic` | — | The rules input consumed by `configureQueryData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L454)

<a id="function-function-miniquake-net-loop-configureserver-function-configureserver-state-hostname-mapname-currentplayers-maxplayers-src-miniquake-net-loop-ml-1034298359"></a>
### configureServer

```ml
function configureServer(state, hostName, mapName, currentPlayers, maxPlayers)
```

Update subsystem configuration for configure server.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `configureServer`. |
| `hostName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `currentPlayers` | `dynamic` | — | The current players input consumed by `configureServer`. |
| `maxPlayers` | `dynamic` | — | The max players input consumed by `configureServer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L442)

<a id="function-function-miniquake-net-loop-connect-function-connect-state-host-src-miniquake-net-loop-ml-258844318"></a>
### connect

```ml
function connect(state, host)
```

Implements the `connect` operation for `miniquake.net_loop` (connect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `connect`. |
| `host` | `dynamic` | — | The host input consumed by `connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L243)

<a id="function-function-miniquake-net-loop-connectionrequestaction-function-connectionrequestaction-existing-port-now-src-miniquake-net-loop-ml-1356463791"></a>
### connectionRequestAction

```ml
function connectionRequestAction(existing, port, now)
```

Implements the `connectionRequestAction` operation for `miniquake.net_loop` (connection request action).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `existing` | `dynamic` | — | The existing input consumed by `connectionRequestAction`. |
| `port` | `dynamic` | — | The port input consumed by `connectionRequestAction`. |
| `now` | `dynamic` | — | The now input consumed by `connectionRequestAction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L654)

<a id="function-function-miniquake-net-loop-connectremote-function-connectremote-state-address-port-timeoutmilliseconds-src-miniquake-net-loop-ml-1865602316"></a>
### connectRemote

```ml
function connectRemote(state, address, port, timeoutMilliseconds)
```

Establish remote using the active network transport.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `connectRemote`. |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `connectRemote`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `connectRemote`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L281)

<a id="function-function-miniquake-net-loop-connectremotepersistent-function-connectremotepersistent-state-address-port-timeoutmilliseconds-resendmilliseconds-src-miniquake-net-loop-ml-691731701"></a>
### connectRemotePersistent

```ml
function connectRemotePersistent(state, address, port, timeoutMilliseconds, resendMilliseconds)
```

External original-binary interoperability needs a persistent control socket.  Reusing the same source endpoint and resending inside Quake's two-second duplicate window lets the original server repeat CCREP_ACCEPT instead of treating each short-lived process as a crashed client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `connectRemotePersistent`. |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `connectRemotePersistent`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `connectRemotePersistent`. |
| `resendMilliseconds` | `dynamic` | — | The resend milliseconds input consumed by `connectRemotePersistent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L337)

<a id="function-function-miniquake-net-loop-createremotesocket-function-createremotesocket-udpsocket-address-port-src-miniquake-net-loop-ml-1198538334"></a>
### createRemoteSocket

```ml
function createRemoteSocket(udpSocket, address, port)
```

Create and initialize remote socket.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `udpSocket` | `dynamic` | — | The udp socket input consumed by `createRemoteSocket`. |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `createRemoteSocket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L49)

<a id="function-function-miniquake-net-loop-createsocket-function-createsocket-src-miniquake-net-loop-ml-120007889"></a>
### createSocket

```ml
function createSocket()
```

Create and initialize socket.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L40)

<a id="function-function-miniquake-net-loop-createstate-function-createstate-src-miniquake-net-loop-ml-1266003587"></a>
### createState

```ml
function createState()
```

Creates state for `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L35)

<a id="function-function-miniquake-net-loop-datagram-checknewconnections-function-datagram-checknewconnections-state-src-miniquake-net-loop-ml-1874975724"></a>
### Datagram_CheckNewConnections

```ml
function Datagram_CheckNewConnections(state)
```

Mirror Quake's Datagram_CheckNewConnections routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_CheckNewConnections`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1025)

<a id="function-function-miniquake-net-loop-datagram-close-function-datagram-close-socket-src-miniquake-net-loop-ml-541469798"></a>
### Datagram_Close

```ml
function Datagram_Close(socket)
```

Mirror Quake's Datagram_Close routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L995)

<a id="function-function-miniquake-net-loop-datagram-connect-function-datagram-connect-state-host-timeoutmilliseconds-src-miniquake-net-loop-ml-1542788409"></a>
### Datagram_Connect

```ml
function Datagram_Connect(state, host, timeoutMilliseconds)
```

Mirror Quake's Datagram_Connect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_Connect`. |
| `host` | `dynamic` | — | The host input consumed by `Datagram_Connect`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Datagram_Connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1100)

<a id="function-function-miniquake-net-loop-datagram-connectpersistent-function-datagram-connectpersistent-state-host-timeoutmilliseconds-resendmilliseconds-defaultport-src-miniquake-net-loop-ml-1069229500"></a>
### Datagram_ConnectPersistent

```ml
function Datagram_ConnectPersistent(state, host, timeoutMilliseconds, resendMilliseconds, defaultPort)
```

Mirror Quake's Datagram_ConnectPersistent routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_ConnectPersistent`. |
| `host` | `dynamic` | — | The host input consumed by `Datagram_ConnectPersistent`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Datagram_ConnectPersistent`. |
| `resendMilliseconds` | `dynamic` | — | The resend milliseconds input consumed by `Datagram_ConnectPersistent`. |
| `defaultPort` | `dynamic` | — | The default port input consumed by `Datagram_ConnectPersistent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1081)

<a id="function-function-miniquake-net-loop-datagram-connectport-function-datagram-connectport-state-host-timeoutmilliseconds-defaultport-src-miniquake-net-loop-ml-535082733"></a>
### Datagram_ConnectPort

```ml
function Datagram_ConnectPort(state, host, timeoutMilliseconds, defaultPort)
```

Mirror Quake's Datagram_ConnectPort routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_ConnectPort`. |
| `host` | `dynamic` | — | The host input consumed by `Datagram_ConnectPort`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Datagram_ConnectPort`. |
| `defaultPort` | `dynamic` | — | The default port input consumed by `Datagram_ConnectPort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1071)

<a id="function-function-miniquake-net-loop-datagram-endhostsearch-function-datagram-endhostsearch-src-miniquake-net-loop-ml-1657568797"></a>
### Datagram_EndHostSearch

```ml
function Datagram_EndHostSearch()
```

Finish a multi-frame server search and release its persistent control socket.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L588)

<a id="function-function-miniquake-net-loop-datagram-hostsearchactive-function-datagram-hostsearchactive-src-miniquake-net-loop-ml-981958625"></a>
### Datagram_HostSearchActive

```ml
function Datagram_HostSearchActive()
```

Report whether LAN discovery currently owns its non-blocking control socket.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L597)

<a id="function-function-miniquake-net-loop-datagram-init-function-datagram-init-state-nolan-src-miniquake-net-loop-ml-134218290"></a>
### Datagram_Init

```ml
function Datagram_Init(state, noLan)
```

Mirror Quake's Datagram_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_Init`. |
| `noLan` | `dynamic` | — | The no lan input consumed by `Datagram_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L968)

<a id="function-function-miniquake-net-loop-datagram-listen-function-datagram-listen-state-enabled-port-src-miniquake-net-loop-ml-1257481796"></a>
### Datagram_Listen

```ml
function Datagram_Listen(state, enabled, port)
```

Mirror Quake's Datagram_Listen routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_Listen`. |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |
| `port` | `dynamic` | — | The port input consumed by `Datagram_Listen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1004)

<a id="function-function-miniquake-net-loop-datagram-searchforhosts-function-datagram-searchforhosts-state-xmit-port-timeoutmilliseconds-src-miniquake-net-loop-ml-2059472954"></a>
### Datagram_SearchForHosts

```ml
function Datagram_SearchForHosts(state, xmit, port, timeoutMilliseconds)
```

Mirror Quake's Datagram_SearchForHosts routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_SearchForHosts`. |
| `xmit` | `dynamic` | — | The xmit input consumed by `Datagram_SearchForHosts`. |
| `port` | `dynamic` | — | The port input consumed by `Datagram_SearchForHosts`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Datagram_SearchForHosts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L573)

<a id="function-function-miniquake-net-loop-datagram-shutdown-function-datagram-shutdown-state-src-miniquake-net-loop-ml-207512520"></a>
### Datagram_Shutdown

```ml
function Datagram_Shutdown(state)
```

Mirror Quake's Datagram_Shutdown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Datagram_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L982)

<a id="global-global-miniquake-net-loop-datagramsearchsocket-datagramsearchsocket-src-miniquake-net-loop-ml-1014188913"></a>
### datagramSearchSocket

```ml
datagramSearchSocket
```

Tracks the module-level datagram search socket state owned by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L27)

<a id="function-function-miniquake-net-loop-discoveredaddress-function-discoveredaddress-fields-receivedaddress-receivedport-src-miniquake-net-loop-ml-742464457"></a>
### discoveredAddress

```ml
function discoveredAddress(fields, receivedAddress, receivedPort)
```

Implements the `discoveredAddress` operation for `miniquake.net_loop` (discovered address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fields` | `dynamic` | — | The fields input consumed by `discoveredAddress`. |
| `receivedAddress` | `dynamic` | — | The received address input consumed by `discoveredAddress`. |
| `receivedPort` | `dynamic` | — | The received port input consumed by `discoveredAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L497)

<a id="function-function-miniquake-net-loop-expandpartialipaddress-function-expandpartialipaddress-address-src-miniquake-net-loop-ml-180483951"></a>
### expandPartialIPAddress

```ml
function expandPartialIPAddress(address)
```

WINS_GetAddrFromName routes digit-leading names through PartialIPAddress. Preserve that user-visible connect syntax in the production UDP path even though the x64 bridge uses sendto rather than the old landriver vtable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L90)

<a id="function-function-miniquake-net-loop-getmessage-function-getmessage-socket-destination-src-miniquake-net-loop-ml-1433056102"></a>
### getMessage

```ml
function getMessage(socket, destination)
```

Return message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L900)

<a id="constant-constant-miniquake-net-loop-host-cache-size-const-host-cache-size-8-src-miniquake-net-loop-ml-1494960032"></a>
### HOST_CACHE_SIZE

```ml
const HOST_CACHE_SIZE = 8
```

Defines the host cache size value used by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L32)

<a id="function-function-miniquake-net-loop-hostnameexists-function-hostnameexists-hosts-name-src-miniquake-net-loop-ml-536527375"></a>
### hostNameExists

```ml
function hostNameExists(hosts, name)
```

Apply the Quake-compatible host name exists behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hosts` | `dynamic` | — | The hosts input consumed by `hostNameExists`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L463)

<a id="function-function-miniquake-net-loop-intalign-inline-function-intalign-value-src-miniquake-net-loop-ml-141764541"></a>
### IntAlign

```ml
inline function IntAlign(value)
```

Implements the `IntAlign` operation for `miniquake.net_loop` (int align).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `IntAlign`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L771)

<a id="function-function-miniquake-net-loop-ipv4number-function-ipv4number-address-src-miniquake-net-loop-ml-1281593439"></a>
### ipv4Number

```ml
function ipv4Number(address)
```

Return ipv4 number derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L162)

<a id="function-function-miniquake-net-loop-ipv4text-inline-function-ipv4text-value-src-miniquake-net-loop-ml-1515657157"></a>
### ipv4Text

```ml
inline function ipv4Text(value)
```

Implements the `ipv4Text` operation for `miniquake.net_loop` (ipv4 text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ipv4Text`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L190)

<a id="function-function-miniquake-net-loop-isnumericaddress-function-isnumericaddress-address-src-miniquake-net-loop-ml-321136795"></a>
### isNumericAddress

```ml
function isNumericAddress(address)
```

Report whether is numeric address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L146)

<a id="function-function-miniquake-net-loop-listen-function-listen-state-port-src-miniquake-net-loop-ml-47570241"></a>
### listen

```ml
function listen(state, port)
```

Implements the `listen` operation for `miniquake.net_loop` (listen).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `listen`. |
| `port` | `dynamic` | — | The port input consumed by `listen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L417)

<a id="function-function-miniquake-net-loop-listeneraddress-function-listeneraddress-address-port-src-miniquake-net-loop-ml-495613734"></a>
### listenerAddress

```ml
function listenerAddress(address, port)
```

Implements the `listenerAddress` operation for `miniquake.net_loop` (listener address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `listenerAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L604)

<a id="function-function-miniquake-net-loop-loop-cansendmessage-function-loop-cansendmessage-socket-src-miniquake-net-loop-ml-176654586"></a>
### Loop_CanSendMessage

```ml
function Loop_CanSendMessage(socket)
```

Mirror Quake's Loop_CanSendMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1282)

<a id="function-function-miniquake-net-loop-loop-cansendunreliablemessage-function-loop-cansendunreliablemessage-socket-src-miniquake-net-loop-ml-801698452"></a>
### Loop_CanSendUnreliableMessage

```ml
function Loop_CanSendUnreliableMessage(socket)
```

Mirror Quake's Loop_CanSendUnreliableMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1288)

<a id="function-function-miniquake-net-loop-loop-checknewconnections-function-loop-checknewconnections-state-src-miniquake-net-loop-ml-1841438236"></a>
### Loop_CheckNewConnections

```ml
function Loop_CheckNewConnections(state)
```

Mirror Quake's Loop_CheckNewConnections routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Loop_CheckNewConnections`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1244)

<a id="function-function-miniquake-net-loop-loop-close-function-loop-close-socket-src-miniquake-net-loop-ml-938166858"></a>
### Loop_Close

```ml
function Loop_Close(socket)
```

Mirror Quake's Loop_Close routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1294)

<a id="function-function-miniquake-net-loop-loop-connect-function-loop-connect-state-host-src-miniquake-net-loop-ml-121933282"></a>
### Loop_Connect

```ml
function Loop_Connect(state, host)
```

Mirror Quake's Loop_Connect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Loop_Connect`. |
| `host` | `dynamic` | — | The host input consumed by `Loop_Connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1235)

<a id="function-function-miniquake-net-loop-loop-getmessage-function-loop-getmessage-socket-destination-src-miniquake-net-loop-ml-1383325302"></a>
### Loop_GetMessage

```ml
function Loop_GetMessage(socket, destination)
```

Mirror Quake's Loop_GetMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1262)

<a id="function-function-miniquake-net-loop-loop-init-function-loop-init-dedicated-src-miniquake-net-loop-ml-548397678"></a>
### Loop_Init

```ml
function Loop_Init(dedicated)
```

-------------------------------------------------------------------------- net_loop.c / net_loop.h compatibility surface

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dedicated` | `dynamic` | — | The dedicated input consumed by `Loop_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1195)

<a id="function-function-miniquake-net-loop-loop-listen-function-loop-listen-state-src-miniquake-net-loop-ml-1471715916"></a>
### Loop_Listen

```ml
function Loop_Listen(state)
```

Mirror Quake's Loop_Listen routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Loop_Listen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1207)

<a id="constant-constant-miniquake-net-loop-loop-max-message-const-loop-max-message-8192-src-miniquake-net-loop-ml-1789102774"></a>
### LOOP_MAX_MESSAGE

```ml
const LOOP_MAX_MESSAGE = 8192
```

Defines the loop max message value used by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L30)

<a id="function-function-miniquake-net-loop-loop-searchforhosts-function-loop-searchforhosts-state-serveractive-driverlevel-src-miniquake-net-loop-ml-1056673603"></a>
### Loop_SearchForHosts

```ml
function Loop_SearchForHosts(state, serverActive, driverLevel)
```

Mirror Quake's Loop_SearchForHosts routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `Loop_SearchForHosts`. |
| `serverActive` | `dynamic` | — | The server active input consumed by `Loop_SearchForHosts`. |
| `driverLevel` | `dynamic` | — | The driver level input consumed by `Loop_SearchForHosts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1216)

<a id="function-function-miniquake-net-loop-loop-sendmessage-function-loop-sendmessage-socket-data-src-miniquake-net-loop-ml-1705683906"></a>
### Loop_SendMessage

```ml
function Loop_SendMessage(socket, data)
```

Mirror Quake's Loop_SendMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1269)

<a id="function-function-miniquake-net-loop-loop-sendunreliablemessage-function-loop-sendunreliablemessage-socket-data-src-miniquake-net-loop-ml-2061430098"></a>
### Loop_SendUnreliableMessage

```ml
function Loop_SendUnreliableMessage(socket, data)
```

Mirror Quake's Loop_SendUnreliableMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1276)

<a id="function-function-miniquake-net-loop-loop-shutdown-function-loop-shutdown-src-miniquake-net-loop-ml-222260763"></a>
### Loop_Shutdown

```ml
function Loop_Shutdown()
```

Mirror Quake's Loop_Shutdown routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1201)

<a id="function-function-miniquake-net-loop-loopqueuedbytes-function-loopqueuedbytes-socket-src-miniquake-net-loop-ml-938007506"></a>
### loopQueuedBytes

```ml
function loopQueuedBytes(socket)
```

Return loop queued bytes derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L777)

<a id="function-function-miniquake-net-loop-matchingremote-function-matchingremote-state-address-src-miniquake-net-loop-ml-638544280"></a>
### matchingRemote

```ml
function matchingRemote(state, address)
```

Implements the `matchingRemote` operation for `miniquake.net_loop` (matching remote).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `matchingRemote`. |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L643)

<a id="global-global-miniquake-net-loop-messagesreceived-messagesreceived-src-miniquake-net-loop-ml-1306354395"></a>
### messagesReceived

```ml
messagesReceived
```

Tracks the module-level messages received state owned by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L21)

<a id="global-global-miniquake-net-loop-messagessent-messagessent-src-miniquake-net-loop-ml-830213857"></a>
### messagesSent

```ml
messagesSent
```

Tracks the module-level messages sent state owned by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L19)

<a id="function-function-miniquake-net-loop-net-ban-f-function-net-ban-f-state-arguments-src-miniquake-net-loop-ml-843460800"></a>
### NET_Ban_f

```ml
function NET_Ban_f(state, arguments)
```

Mirror Quake's NET_Ban_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `NET_Ban_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L197)

<a id="function-function-miniquake-net-loop-nextserverrule-function-nextserverrule-rules-previous-src-miniquake-net-loop-ml-1837694657"></a>
### nextServerRule

```ml
function nextServerRule(rules, previous)
```

Return next server rule for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rules` | `dynamic` | — | The rules input consumed by `nextServerRule`. |
| `previous` | `dynamic` | — | The previous input consumed by `nextServerRule`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L619)

<a id="function-function-miniquake-net-loop-normalizeaddress-function-normalizeaddress-address-src-miniquake-net-loop-ml-1851252103"></a>
### normalizeAddress

```ml
function normalizeAddress(address)
```

Convert address into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L56)

<a id="function-function-miniquake-net-loop-numericaddressparts-function-numericaddressparts-address-src-miniquake-net-loop-ml-1246983949"></a>
### numericAddressParts

```ml
function numericAddressParts(address)
```

Implements the `numericAddressParts` operation for `miniquake.net_loop` (numeric address parts).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L64)

<a id="function-function-miniquake-net-loop-parseaddress-function-parseaddress-text-defaultport-src-miniquake-net-loop-ml-1651572754"></a>
### parseAddress

```ml
function parseAddress(text, defaultPort)
```

Read and validate address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `defaultPort` | `dynamic` | — | The default port input consumed by `parseAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L113)

<a id="function-function-miniquake-net-loop-publiclisteneraddress-function-publiclisteneraddress-state-src-miniquake-net-loop-ml-118806230"></a>
### publicListenerAddress

```ml
function publicListenerAddress(state)
```

Implements the `publicListenerAddress` operation for `miniquake.net_loop` (public listener address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `publicListenerAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L610)

<a id="function-function-miniquake-net-loop-pumplistener-function-pumplistener-state-src-miniquake-net-loop-ml-1186487916"></a>
### pumpListener

```ml
function pumpListener(state)
```

Advance listener by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `pumpListener`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L662)

<a id="function-function-miniquake-net-loop-pumpremote-function-pumpremote-socket-src-miniquake-net-loop-ml-233312870"></a>
### pumpRemote

```ml
function pumpRemote(socket)
```

Advance remote by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L854)

<a id="function-function-miniquake-net-loop-resolvedatagramtarget-function-resolvedatagramtarget-state-host-defaultport-src-miniquake-net-loop-ml-641572572"></a>
### resolveDatagramTarget

```ml
function resolveDatagramTarget(state, host, defaultPort)
```

Implements the `resolveDatagramTarget` operation for `miniquake.net_loop` (resolve datagram target).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `resolveDatagramTarget`. |
| `host` | `dynamic` | — | The host input consumed by `resolveDatagramTarget`. |
| `defaultPort` | `dynamic` | — | The default port input consumed by `resolveDatagramTarget`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1046)

<a id="function-function-miniquake-net-loop-searchhosts-function-searchhosts-port-timeoutmilliseconds-src-miniquake-net-loop-ml-300997689"></a>
### searchHosts

```ml
function searchHosts(port, timeoutMilliseconds)
```

Implements the `searchHosts` operation for `miniquake.net_loop` (search hosts).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | The port input consumed by `searchHosts`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `searchHosts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L507)

<a id="function-function-miniquake-net-loop-sendmessage-function-sendmessage-socket-buffer-src-miniquake-net-loop-ml-1764007958"></a>
### sendMessage

```ml
function sendMessage(socket, buffer)
```

Send message through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `buffer` | `dynamic` | — | The buffer input consumed by `sendMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L788)

<a id="function-function-miniquake-net-loop-sendunreliablemessage-function-sendunreliablemessage-socket-buffer-src-miniquake-net-loop-ml-1717905640"></a>
### sendUnreliableMessage

```ml
function sendUnreliableMessage(socket, buffer)
```

Send unreliable message through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `buffer` | `dynamic` | — | The buffer input consumed by `sendUnreliableMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L822)

<a id="function-function-miniquake-net-loop-shorttext-function-shorttext-text-maximum-src-miniquake-net-loop-ml-1722328440"></a>
### shortText

```ml
function shortText(text, maximum)
```

Implements the `shortText` operation for `miniquake.net_loop` (short text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L138)

<a id="function-function-miniquake-net-loop-stoplistening-function-stoplistening-state-src-miniquake-net-loop-ml-25101246"></a>
### stopListening

```ml
function stopListening(state)
```

Finalize state for stop listening.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_loop` state used by `stopListening`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L428)

<a id="function-function-miniquake-net-loop-straddr-function-straddr-address-port-src-miniquake-net-loop-ml-1764625070"></a>
### StrAddr

```ml
function StrAddr(address, port)
```

Implements the `StrAddr` operation for `miniquake.net_loop` (str addr).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `StrAddr`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L184)

<a id="function-function-miniquake-net-loop-test2-f-function-test2-f-host-timeoutmilliseconds-src-miniquake-net-loop-ml-2053454356"></a>
### Test2_f

```ml
function Test2_f(host, timeoutMilliseconds)
```

Mirror Quake's Test2_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `host` | `dynamic` | — | The host input consumed by `Test2_f`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Test2_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1169)

<a id="function-function-miniquake-net-loop-test2-poll-function-test2-poll-socket-expectedaddress-expectedport-timeoutmilliseconds-src-miniquake-net-loop-ml-1375181254"></a>
### Test2_Poll

```ml
function Test2_Poll(socket, expectedAddress, expectedPort, timeoutMilliseconds)
```

Mirror Quake's Test2_Poll routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `expectedAddress` | `dynamic` | — | The expected address input consumed by `Test2_Poll`. |
| `expectedPort` | `dynamic` | — | The expected port input consumed by `Test2_Poll`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Test2_Poll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1151)

<a id="function-function-miniquake-net-loop-test-f-function-test-f-host-maximumplayers-timeoutmilliseconds-src-miniquake-net-loop-ml-100201346"></a>
### Test_f

```ml
function Test_f(host, maximumPlayers, timeoutMilliseconds)
```

Verify f against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `host` | `dynamic` | — | The host input consumed by `Test_f`. |
| `maximumPlayers` | `dynamic` | — | The maximum players input consumed by `Test_f`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Test_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1130)

<a id="function-function-miniquake-net-loop-test-poll-function-test-poll-socket-expectedaddress-expectedport-timeoutmilliseconds-src-miniquake-net-loop-ml-1456156470"></a>
### Test_Poll

```ml
function Test_Poll(socket, expectedAddress, expectedPort, timeoutMilliseconds)
```

Verify poll against the expected Quake behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `expectedAddress` | `dynamic` | — | The expected address input consumed by `Test_Poll`. |
| `expectedPort` | `dynamic` | — | The expected port input consumed by `Test_Poll`. |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `Test_Poll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L1109)

<a id="function-function-miniquake-net-loop-timedout-function-timedout-socket-timeoutseconds-src-miniquake-net-loop-ml-1749910606"></a>
### timedOut

```ml
function timedOut(socket, timeoutSeconds)
```

Implements the `timedOut` operation for `miniquake.net_loop` (timed out).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socket` | `dynamic` | — | Network socket used for communication. |
| `timeoutSeconds` | `dynamic` | — | The timeout seconds input consumed by `timedOut`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L945)

<a id="function-function-miniquake-net-loop-uniquehostname-function-uniquehostname-hosts-requested-src-miniquake-net-loop-ml-56389158"></a>
### uniqueHostName

```ml
function uniqueHostName(hosts, requested)
```

Return unique host name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hosts` | `dynamic` | — | The hosts input consumed by `uniqueHostName`. |
| `requested` | `dynamic` | — | The requested input consumed by `uniqueHostName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L474)

<a id="global-global-miniquake-net-loop-unreliablemessagesreceived-unreliablemessagesreceived-src-miniquake-net-loop-ml-149165961"></a>
### unreliableMessagesReceived

```ml
unreliableMessagesReceived
```

Tracks the module-level unreliable messages received state owned by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L25)

<a id="global-global-miniquake-net-loop-unreliablemessagessent-unreliablemessagessent-src-miniquake-net-loop-ml-1757287087"></a>
### unreliableMessagesSent

```ml
unreliableMessagesSent
```

Tracks the module-level unreliable messages sent state owned by `miniquake.net_loop`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_loop.ml#L23)
