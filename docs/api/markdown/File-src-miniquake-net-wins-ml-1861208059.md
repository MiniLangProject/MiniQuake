# `src/miniquake/net_wins.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.net_wins`](Package-miniquake-net-wins-1209258716.md)

Reachable from entry: **yes**

## Imports

- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/net_udp.ml` as `udp` → [src/miniquake/net_udp.ml](File-src-miniquake-net-udp-ml-1891257481.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="constant-constant-miniquake-net-wins-af-inet-const-af-inet-2-src-miniquake-net-wins-ml-1400637260"></a>
### AF_INET

```ml
const AF_INET = 2
```

Defines the af inet value used by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L20)

<a id="function-function-miniquake-net-wins-blockinghook-function-blockinghook-src-miniquake-net-wins-ml-1651938173"></a>
### BlockingHook

```ml
function BlockingHook()
```

Implements the `BlockingHook` operation for `miniquake.net_wins` (blocking hook).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L238)

<a id="global-global-miniquake-net-wins-blocktime-blocktime-src-miniquake-net-wins-ml-208089519"></a>
### blocktime

```ml
blocktime
```

Tracks the module-level blocktime state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L49)

<a id="global-global-miniquake-net-wins-broadcastaddr-broadcastaddr-src-miniquake-net-wins-ml-1664821295"></a>
### broadcastaddr

```ml
broadcastaddr
```

Tracks the module-level broadcastaddr state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L33)

<a id="global-global-miniquake-net-wins-configuredhostname-configuredhostname-src-miniquake-net-wins-ml-1695659345"></a>
### configuredHostname

```ml
configuredHostname
```

Tracks the module-level configured hostname state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L39)

<a id="function-function-miniquake-net-wins-htonl-function-htonl-value-src-miniquake-net-wins-ml-1501022260"></a>
### htonl

```ml
function htonl(value)
```

Implements the `htonl` operation for `miniquake.net_wins` (htonl).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `htonl`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L139)

<a id="function-function-miniquake-net-wins-htons-function-htons-value-src-miniquake-net-wins-ml-510891642"></a>
### htons

```ml
function htons(value)
```

Implements the `htons` operation for `miniquake.net_wins` (htons).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `htons`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L126)

<a id="function-function-miniquake-net-wins-ipv4text-function-ipv4text-hostorderaddress-src-miniquake-net-wins-ml-888704203"></a>
### ipv4Text

```ml
function ipv4Text(hostOrderAddress)
```

Implements the `ipv4Text` operation for `miniquake.net_wins` (ipv4 text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hostOrderAddress` | `dynamic` | — | The host order address input consumed by `ipv4Text`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L211)

<a id="global-global-miniquake-net-wins-lasterror-lasterror-src-miniquake-net-wins-ml-38363687"></a>
### lastError

```ml
lastError
```

Tracks the module-level last error state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L51)

<a id="constant-constant-miniquake-net-wins-maxhostnamelen-const-maxhostnamelen-256-src-miniquake-net-wins-ml-1494047213"></a>
### MAXHOSTNAMELEN

```ml
const MAXHOSTNAMELEN = 256
```

Defines the maxhostnamelen value used by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L22)

<a id="global-global-miniquake-net-wins-my-tcpip-address-my-tcpip-address-src-miniquake-net-wins-ml-1302127335"></a>
### my_tcpip_address

```ml
my_tcpip_address
```

Tracks the module-level my tcpip address state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L37)

<a id="global-global-miniquake-net-wins-myaddr-myaddr-src-miniquake-net-wins-ml-785579113"></a>
### myAddr

```ml
myAddr
```

Tracks the module-level my addr state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L35)

<a id="global-global-miniquake-net-wins-net-acceptsocket-net-acceptsocket-src-miniquake-net-wins-ml-370142013"></a>
### net_acceptsocket

```ml
net_acceptsocket
```

Tracks the module-level net acceptsocket state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L27)

<a id="global-global-miniquake-net-wins-net-broadcastsocket-net-broadcastsocket-src-miniquake-net-wins-ml-1644634455"></a>
### net_broadcastsocket

```ml
net_broadcastsocket
```

Tracks the module-level net broadcastsocket state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L31)

<a id="global-global-miniquake-net-wins-net-controlsocket-net-controlsocket-src-miniquake-net-wins-ml-720213635"></a>
### net_controlsocket

```ml
net_controlsocket
```

Tracks the module-level net controlsocket state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L29)

<a id="global-global-miniquake-net-wins-net-hostport-net-hostport-src-miniquake-net-wins-ml-298219473"></a>
### net_hostport

```ml
net_hostport
```

Tracks the module-level net hostport state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L47)

<a id="constant-constant-miniquake-net-wins-net-namelen-const-net-namelen-64-src-miniquake-net-wins-ml-1379883260"></a>
### NET_NAMELEN

```ml
const NET_NAMELEN = 64
```

Defines the net namelen value used by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L24)

<a id="function-function-miniquake-net-wins-newaddress-function-newaddress-addresstext-port-src-miniquake-net-wins-ml-1802399689"></a>
### newAddress

```ml
function newAddress(addressText, port)
```

Create and initialize address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addressText` | `dynamic` | — | The address text input consumed by `newAddress`. |
| `port` | `dynamic` | — | The port input consumed by `newAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L221)

<a id="function-function-miniquake-net-wins-ntohl-function-ntohl-value-src-miniquake-net-wins-ml-2083448448"></a>
### ntohl

```ml
function ntohl(value)
```

Implements the `ntohl` operation for `miniquake.net_wins` (ntohl).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ntohl`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L148)

<a id="function-function-miniquake-net-wins-ntohs-function-ntohs-value-src-miniquake-net-wins-ml-316020154"></a>
### ntohs

```ml
function ntohs(value)
```

Implements the `ntohs` operation for `miniquake.net_wins` (ntohs).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ntohs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L133)

<a id="function-function-miniquake-net-wins-numerichostname-function-numerichostname-text-src-miniquake-net-wins-ml-436480860"></a>
### numericHostName

```ml
function numericHostName(text)
```

Return numeric host name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L257)

<a id="function-function-miniquake-net-wins-parsedecimal-function-parsedecimal-text-maximumdigits-maximumvalue-src-miniquake-net-wins-ml-1007426539"></a>
### parseDecimal

```ml
function parseDecimal(text, maximumDigits, maximumValue)
```

Read and validate decimal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `maximumDigits` | `dynamic` | — | The maximum digits input consumed by `parseDecimal`. |
| `maximumValue` | `dynamic` | — | The maximum value input consumed by `parseDecimal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L183)

<a id="function-function-miniquake-net-wins-parseipv4-function-parseipv4-text-src-miniquake-net-wins-ml-1456985240"></a>
### parseIpv4

```ml
function parseIpv4(text)
```

Read and validate ipv4.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L197)

<a id="function-function-miniquake-net-wins-partialipaddress-function-partialipaddress-input-hostaddr-src-miniquake-net-wins-ml-1691395702"></a>
### PartialIPAddress

```ml
function PartialIPAddress(input, hostaddr)
```

Implements the `PartialIPAddress` operation for `miniquake.net_wins` (partial ip address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `PartialIPAddress`. |
| `hostaddr` | `dynamic` | — | The hostaddr input consumed by `PartialIPAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L375)

<a id="function-function-miniquake-net-wins-setaddress-function-setaddress-target-source-src-miniquake-net-wins-ml-372675249"></a>
### setAddress

```ml
function setAddress(target, source)
```

Update module state for address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | The target input consumed by `setAddress`. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L230)

<a id="function-function-miniquake-net-wins-shorthostname-function-shorthostname-text-src-miniquake-net-wins-ml-1728230174"></a>
### shortHostName

```ml
function shortHostName(text)
```

Return short host name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L268)

<a id="function-function-miniquake-net-wins-shorttext-function-shorttext-text-maximum-src-miniquake-net-wins-ml-1547771930"></a>
### shortText

```ml
function shortText(text, maximum)
```

Implements the `shortText` operation for `miniquake.net_wins` (short text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L155)

<a id="function-function-miniquake-net-wins-splittext-function-splittext-text-separator-src-miniquake-net-wins-ml-304934165"></a>
### splitText

```ml
function splitText(text, separator)
```

Convert text into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `separator` | `dynamic` | — | The separator input consumed by `splitText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L164)

<a id="global-global-miniquake-net-wins-tcpipavailable-tcpipavailable-src-miniquake-net-wins-ml-1594194573"></a>
### tcpipAvailable

```ml
tcpipAvailable
```

Tracks the module-level tcpip available state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L45)

<a id="function-function-miniquake-net-wins-wins-addrcompare-function-wins-addrcompare-addr1-addr2-src-miniquake-net-wins-ml-520130106"></a>
### WINS_AddrCompare

```ml
function WINS_AddrCompare(addr1, addr2)
```

Mirror Quake's WINS_AddrCompare routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addr1` | `dynamic` | — | The addr1 input consumed by `WINS_AddrCompare`. |
| `addr2` | `dynamic` | — | The addr2 input consumed by `WINS_AddrCompare`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L581)

<a id="function-function-miniquake-net-wins-wins-addrtostring-function-wins-addrtostring-addr-src-miniquake-net-wins-ml-2014491522"></a>
### WINS_AddrToString

```ml
function WINS_AddrToString(addr)
```

Mirror Quake's WINS_AddrToString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_AddrToString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L512)

<a id="function-function-miniquake-net-wins-wins-broadcast-function-wins-broadcast-socketvalue-buffer-length-src-miniquake-net-wins-ml-45582645"></a>
### WINS_Broadcast

```ml
function WINS_Broadcast(socketValue, buffer, length)
```

Mirror Quake's WINS_Broadcast routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_Broadcast`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `WINS_Broadcast`. |
| `length` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L485)

<a id="function-function-miniquake-net-wins-wins-checknewconnections-function-wins-checknewconnections-src-miniquake-net-wins-ml-1668403129"></a>
### WINS_CheckNewConnections

```ml
function WINS_CheckNewConnections()
```

Mirror Quake's WINS_CheckNewConnections routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L441)

<a id="function-function-miniquake-net-wins-wins-closesocket-function-wins-closesocket-socketvalue-src-miniquake-net-wins-ml-1477901463"></a>
### WINS_CloseSocket

```ml
function WINS_CloseSocket(socketValue)
```

Mirror Quake's WINS_CloseSocket routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_CloseSocket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L364)

<a id="function-function-miniquake-net-wins-wins-connect-function-wins-connect-socketvalue-addr-src-miniquake-net-wins-ml-1026644898"></a>
### WINS_Connect

```ml
function WINS_Connect(socketValue, addr)
```

Mirror Quake's WINS_Connect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_Connect`. |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_Connect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L436)

<a id="function-function-miniquake-net-wins-wins-getaddrfromname-function-wins-getaddrfromname-name-addr-src-miniquake-net-wins-ml-1237421281"></a>
### WINS_GetAddrFromName

```ml
function WINS_GetAddrFromName(name, addr)
```

Mirror Quake's WINS_GetAddrFromName routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_GetAddrFromName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L566)

<a id="function-function-miniquake-net-wins-wins-getlocaladdress-function-wins-getlocaladdress-src-miniquake-net-wins-ml-881162769"></a>
### WINS_GetLocalAddress

```ml
function WINS_GetLocalAddress()
```

Mirror Quake's WINS_GetLocalAddress routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L244)

<a id="function-function-miniquake-net-wins-wins-getnamefromaddr-function-wins-getnamefromaddr-addr-src-miniquake-net-wins-ml-1936117628"></a>
### WINS_GetNameFromAddr

```ml
function WINS_GetNameFromAddr(addr)
```

Mirror Quake's WINS_GetNameFromAddr routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_GetNameFromAddr`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L556)

<a id="function-function-miniquake-net-wins-wins-getsocketaddr-function-wins-getsocketaddr-socketvalue-addr-src-miniquake-net-wins-ml-986700354"></a>
### WINS_GetSocketAddr

```ml
function WINS_GetSocketAddr(socketValue, addr)
```

Mirror Quake's WINS_GetSocketAddr routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_GetSocketAddr`. |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_GetSocketAddr`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L542)

<a id="function-function-miniquake-net-wins-wins-getsocketport-function-wins-getsocketport-addr-src-miniquake-net-wins-ml-2142792608"></a>
### WINS_GetSocketPort

```ml
function WINS_GetSocketPort(addr)
```

Mirror Quake's WINS_GetSocketPort routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_GetSocketPort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L590)

<a id="function-function-miniquake-net-wins-wins-init-function-wins-init-hostname-noudp-configuredip-hostport-src-miniquake-net-wins-ml-1968552238"></a>
### WINS_Init

```ml
function WINS_Init(hostName, noUdp, configuredIp, hostPort)
```

Mirror Quake's WINS_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hostName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `noUdp` | `dynamic` | — | The no udp input consumed by `WINS_Init`. |
| `configuredIp` | `dynamic` | — | The configured ip input consumed by `WINS_Init`. |
| `hostPort` | `dynamic` | — | The host port input consumed by `WINS_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L286)

<a id="function-function-miniquake-net-wins-wins-listen-function-wins-listen-state-src-miniquake-net-wins-ml-1472452564"></a>
### WINS_Listen

```ml
function WINS_Listen(state)
```

Mirror Quake's WINS_Listen routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.net_wins` state used by `WINS_Listen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L336)

<a id="function-function-miniquake-net-wins-wins-makesocketbroadcastcapable-function-wins-makesocketbroadcastcapable-socketvalue-src-miniquake-net-wins-ml-669772695"></a>
### WINS_MakeSocketBroadcastCapable

```ml
function WINS_MakeSocketBroadcastCapable(socketValue)
```

Mirror Quake's WINS_MakeSocketBroadcastCapable routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_MakeSocketBroadcastCapable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L472)

<a id="function-function-miniquake-net-wins-wins-opensocket-function-wins-opensocket-port-src-miniquake-net-wins-ml-108122018"></a>
### WINS_OpenSocket

```ml
function WINS_OpenSocket(port)
```

Mirror Quake's WINS_OpenSocket routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | The port input consumed by `WINS_OpenSocket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L352)

<a id="function-function-miniquake-net-wins-wins-read-function-wins-read-socketvalue-buffer-length-addr-src-miniquake-net-wins-ml-252057652"></a>
### WINS_Read

```ml
function WINS_Read(socketValue, buffer, length, addr)
```

Mirror Quake's WINS_Read routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_Read`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `WINS_Read`. |
| `length` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_Read`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L453)

<a id="function-function-miniquake-net-wins-wins-resetstate-function-wins-resetstate-src-miniquake-net-wins-ml-1744422833"></a>
### WINS_ResetState

```ml
function WINS_ResetState()
```

Mirror Quake's WINS_ResetState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L54)

<a id="function-function-miniquake-net-wins-wins-setacceptsocket-function-wins-setacceptsocket-socketvalue-src-miniquake-net-wins-ml-139349991"></a>
### WINS_SetAcceptSocket

```ml
function WINS_SetAcceptSocket(socketValue)
```

Mirror Quake's WINS_SetAcceptSocket routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_SetAcceptSocket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L110)

<a id="function-function-miniquake-net-wins-wins-setblocktime-function-wins-setblocktime-value-src-miniquake-net-wins-ml-617441926"></a>
### WINS_SetBlockTime

```ml
function WINS_SetBlockTime(value)
```

Mirror Quake's WINS_SetBlockTime routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `WINS_SetBlockTime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L88)

<a id="function-function-miniquake-net-wins-wins-setbroadcastsocket-function-wins-setbroadcastsocket-socketvalue-src-miniquake-net-wins-ml-1007853999"></a>
### WINS_SetBroadcastSocket

```ml
function WINS_SetBroadcastSocket(socketValue)
```

Mirror Quake's WINS_SetBroadcastSocket routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_SetBroadcastSocket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L118)

<a id="function-function-miniquake-net-wins-wins-setlocaladdress-function-wins-setlocaladdress-addresstext-src-miniquake-net-wins-ml-1217949296"></a>
### WINS_SetLocalAddress

```ml
function WINS_SetLocalAddress(addressText)
```

Mirror Quake's WINS_SetLocalAddress routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addressText` | `dynamic` | — | The address text input consumed by `WINS_SetLocalAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L77)

<a id="function-function-miniquake-net-wins-wins-setsocketport-function-wins-setsocketport-addr-port-src-miniquake-net-wins-ml-1179567245"></a>
### WINS_SetSocketPort

```ml
function WINS_SetSocketPort(addr, port)
```

Mirror Quake's WINS_SetSocketPort routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_SetSocketPort`. |
| `port` | `dynamic` | — | The port input consumed by `WINS_SetSocketPort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L597)

<a id="function-function-miniquake-net-wins-wins-shutdown-function-wins-shutdown-src-miniquake-net-wins-ml-1631217477"></a>
### WINS_Shutdown

```ml
function WINS_Shutdown()
```

Mirror Quake's WINS_Shutdown routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L322)

<a id="function-function-miniquake-net-wins-wins-statesnapshot-function-wins-statesnapshot-src-miniquake-net-wins-ml-741968517"></a>
### WINS_StateSnapshot

```ml
function WINS_StateSnapshot()
```

Mirror Quake's WINS_StateSnapshot routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L95)

<a id="function-function-miniquake-net-wins-wins-stringtoaddr-function-wins-stringtoaddr-text-addr-src-miniquake-net-wins-ml-44554939"></a>
### WINS_StringToAddr

```ml
function WINS_StringToAddr(text, addr)
```

Mirror Quake's WINS_StringToAddr routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_StringToAddr`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L519)

<a id="function-function-miniquake-net-wins-wins-write-function-wins-write-socketvalue-buffer-length-addr-src-miniquake-net-wins-ml-1023917852"></a>
### WINS_Write

```ml
function WINS_Write(socketValue, buffer, length, addr)
```

Mirror Quake's WINS_Write routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `socketValue` | `dynamic` | — | The socket value input consumed by `WINS_Write`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `WINS_Write`. |
| `length` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |
| `addr` | `dynamic` | — | The addr input consumed by `WINS_Write`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L500)

<a id="global-global-miniquake-net-wins-winsock-initialized-winsock-initialized-src-miniquake-net-wins-ml-2128757851"></a>
### winsock_initialized

```ml
winsock_initialized
```

Tracks the module-level winsock initialized state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L43)

<a id="global-global-miniquake-net-wins-winsock-lib-initialized-winsock-lib-initialized-src-miniquake-net-wins-ml-1297532287"></a>
### winsock_lib_initialized

```ml
winsock_lib_initialized
```

Tracks the module-level winsock lib initialized state owned by `miniquake.net_wins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_wins.ml#L41)
