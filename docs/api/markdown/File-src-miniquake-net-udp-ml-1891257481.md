# `src/miniquake/net_udp.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.net_udp`](Package-miniquake-net-udp-1237503338.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-net-udp-broadcast-function-broadcast-socketvalue-port-payload-src-miniquake-net-udp-ml-912514234"></a>
### broadcast

```ml
function broadcast(socketValue, port, payload)
```

Implements the `broadcast` operation for `miniquake.net_udp` (broadcast).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `broadcast`. |
| `port` | `dynamic` | — | The port input consumed by `broadcast`. |
| `payload` | `dynamic` | — | The payload input consumed by `broadcast`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L82)

<a id="function-function-miniquake-net-udp-close-function-close-socketvalue-src-miniquake-net-udp-ml-914073615"></a>
### close

```ml
function close(socketValue)
```

Implements the `close` operation for `miniquake.net_udp` (close).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `close`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L55)

<a id="function-function-miniquake-net-udp-configurebindaddress-function-configurebindaddress-address-src-miniquake-net-udp-ml-679762449"></a>
### configureBindAddress

```ml
function configureBindAddress(address)
```

Update subsystem configuration for configure bind address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L29)

<a id="global-global-miniquake-net-udp-defaultbindaddress-defaultbindaddress-src-miniquake-net-udp-ml-53303781"></a>
### defaultBindAddress

```ml
defaultBindAddress
```

Tracks the module-level default bind address state owned by `miniquake.net_udp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L17)

<a id="function-function-miniquake-net-udp-hostname-function-hostname-src-miniquake-net-udp-ml-799635609"></a>
### hostName

```ml
function hostName()
```

Apply the Quake-compatible host name behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L115)

<a id="function-function-miniquake-net-udp-localaddress-function-localaddress-src-miniquake-net-udp-ml-866191357"></a>
### localAddress

```ml
function localAddress()
```

Implements the `localAddress` operation for `miniquake.net_udp` (local address).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L108)

<a id="function-function-miniquake-net-udp-makebroadcastcapable-function-makebroadcastcapable-socketvalue-src-miniquake-net-udp-ml-806601211"></a>
### makeBroadcastCapable

```ml
function makeBroadcastCapable(socketValue)
```

Create and initialize broadcast capable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `makeBroadcastCapable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L90)

<a id="constant-constant-miniquake-net-udp-max-udp-payload-const-max-udp-payload-65507-src-miniquake-net-udp-ml-1477934131"></a>
### MAX_UDP_PAYLOAD

```ml
const MAX_UDP_PAYLOAD = 65507
```

Defines the max udp payload value used by `miniquake.net_udp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L15)

<a id="function-function-miniquake-net-udp-open-function-open-port-src-miniquake-net-udp-ml-952928926"></a>
### open

```ml
function open(port)
```

Implements the `open` operation for `miniquake.net_udp` (open).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | The port input consumed by `open`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L23)

<a id="function-function-miniquake-net-udp-openbound-function-openbound-port-bindaddress-src-miniquake-net-udp-ml-859892901"></a>
### openBound

```ml
function openBound(port, bindAddress)
```

Initialize state for open bound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | The port input consumed by `openBound`. |
| `bindAddress` | `dynamic` | — | The bind address input consumed by `openBound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L38)

<a id="function-function-miniquake-net-udp-peek-function-peek-socketvalue-src-miniquake-net-udp-ml-1817005503"></a>
### peek

```ml
function peek(socketValue)
```

Implements the `peek` operation for `miniquake.net_udp` (peek).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `peek`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L100)

<a id="function-function-miniquake-net-udp-receive-function-receive-socketvalue-capacity-src-miniquake-net-udp-ml-965978857"></a>
### receive

```ml
function receive(socketValue, capacity)
```

Implements the `receive` operation for `miniquake.net_udp` (receive).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `receive`. |
| `capacity` | `dynamic` | — | Maximum number of entries the destination can hold. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L140)

<a id="global-global-miniquake-net-udp-receivescratch-receivescratch-src-miniquake-net-udp-ml-861052595"></a>
### receiveScratch

```ml
receiveScratch
```

Tracks the module-level receive scratch state owned by `miniquake.net_udp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L19)

<a id="function-function-miniquake-net-udp-resolvename-function-resolvename-name-src-miniquake-net-udp-ml-16160944"></a>
### resolveName

```ml
function resolveName(name)
```

Return resolve name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L123)

<a id="function-function-miniquake-net-udp-reversename-function-reversename-address-src-miniquake-net-udp-ml-2066036555"></a>
### reverseName

```ml
function reverseName(address)
```

Return reverse name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L131)

<a id="function-function-miniquake-net-udp-send-function-send-socketvalue-address-port-payload-src-miniquake-net-udp-ml-1196674376"></a>
### send

```ml
function send(socketValue, address, port, payload)
```

Send the requested value through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `send`. |
| `address` | `dynamic` | — | Network address of the peer. |
| `port` | `dynamic` | — | The port input consumed by `send`. |
| `payload` | `dynamic` | — | The payload input consumed by `send`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L68)

<a id="function-function-miniquake-net-udp-smoke-function-smoke-timeoutmilliseconds-src-miniquake-net-udp-ml-2002273374"></a>
### smoke

```ml
function smoke(timeoutMilliseconds)
```

Implements the `smoke` operation for `miniquake.net_udp` (smoke).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `timeoutMilliseconds` | `dynamic` | — | The timeout milliseconds input consumed by `smoke`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_udp.ml#L162)
