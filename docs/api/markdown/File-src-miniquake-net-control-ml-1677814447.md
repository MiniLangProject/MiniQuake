# `src/miniquake/net_control.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.net_control`](Package-miniquake-net-control-330112864.md)

Reachable from entry: **yes**

## Imports

- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/net_datagram.ml` as `datagram` → [src/miniquake/net_datagram.ml](File-src-miniquake-net-datagram-ml-84886599.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)

## Declarations

<a id="constant-constant-miniquake-net-control-ccrep-accept-const-ccrep-accept-129-src-miniquake-net-control-ml-3346612"></a>
### CCREP_ACCEPT

```ml
const CCREP_ACCEPT = 129
```

Defines the ccrep accept value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L29)

<a id="constant-constant-miniquake-net-control-ccrep-player-info-const-ccrep-player-info-132-src-miniquake-net-control-ml-604477070"></a>
### CCREP_PLAYER_INFO

```ml
const CCREP_PLAYER_INFO = 132
```

Defines the ccrep player info value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L35)

<a id="constant-constant-miniquake-net-control-ccrep-reject-const-ccrep-reject-130-src-miniquake-net-control-ml-1305021792"></a>
### CCREP_REJECT

```ml
const CCREP_REJECT = 130
```

Defines the ccrep reject value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L31)

<a id="constant-constant-miniquake-net-control-ccrep-rule-info-const-ccrep-rule-info-133-src-miniquake-net-control-ml-1767336919"></a>
### CCREP_RULE_INFO

```ml
const CCREP_RULE_INFO = 133
```

Defines the ccrep rule info value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L37)

<a id="constant-constant-miniquake-net-control-ccrep-server-info-const-ccrep-server-info-131-src-miniquake-net-control-ml-1770578353"></a>
### CCREP_SERVER_INFO

```ml
const CCREP_SERVER_INFO = 131
```

Defines the ccrep server info value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L33)

<a id="constant-constant-miniquake-net-control-ccreq-connect-const-ccreq-connect-1-src-miniquake-net-control-ml-935686593"></a>
### CCREQ_CONNECT

```ml
const CCREQ_CONNECT = 1
```

Defines the ccreq connect value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L20)

<a id="constant-constant-miniquake-net-control-ccreq-player-info-const-ccreq-player-info-3-src-miniquake-net-control-ml-1019708083"></a>
### CCREQ_PLAYER_INFO

```ml
const CCREQ_PLAYER_INFO = 3
```

Defines the ccreq player info value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L24)

<a id="constant-constant-miniquake-net-control-ccreq-rule-info-const-ccreq-rule-info-4-src-miniquake-net-control-ml-1434468092"></a>
### CCREQ_RULE_INFO

```ml
const CCREQ_RULE_INFO = 4
```

Defines the ccreq rule info value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L26)

<a id="constant-constant-miniquake-net-control-ccreq-server-info-const-ccreq-server-info-2-src-miniquake-net-control-ml-387334754"></a>
### CCREQ_SERVER_INFO

```ml
const CCREQ_SERVER_INFO = 2
```

Defines the ccreq server info value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L22)

<a id="constant-constant-miniquake-net-control-game-name-const-game-name-quake-src-miniquake-net-control-ml-1894114225"></a>
### GAME_NAME

```ml
const GAME_NAME = "QUAKE"
```

Defines the game name value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L17)

<a id="constant-constant-miniquake-net-control-net-protocol-version-const-net-protocol-version-3-src-miniquake-net-control-ml-1562790927"></a>
### NET_PROTOCOL_VERSION

```ml
const NET_PROTOCOL_VERSION = 3
```

Defines the net protocol version value used by `miniquake.net_control`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L15)

<a id="function-function-miniquake-net-control-parse-function-parse-wirepacket-src-miniquake-net-control-ml-1455416770"></a>
### parse

```ml
function parse(wirePacket)
```

Returns [command, fields].  The field order is the exact net.h wire order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wirePacket` | `dynamic` | — | The wire packet input consumed by `parse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L152)

<a id="function-function-miniquake-net-control-replyaccept-function-replyaccept-port-src-miniquake-net-control-ml-1431821330"></a>
### replyAccept

```ml
function replyAccept(port)
```

Implements the `replyAccept` operation for `miniquake.net_control` (reply accept).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — | The port input consumed by `replyAccept`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L83)

<a id="function-function-miniquake-net-control-replyplayerinfo-function-replyplayerinfo-playernumber-name-colors-frags-connecttime-address-src-miniquake-net-control-ml-1585684894"></a>
### replyPlayerInfo

```ml
function replyPlayerInfo(playerNumber, name, colors, frags, connectTime, address)
```

Implements the `replyPlayerInfo` operation for `miniquake.net_control` (reply player info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playerNumber` | `dynamic` | — | The player number input consumed by `replyPlayerInfo`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `colors` | `dynamic` | — | The colors input consumed by `replyPlayerInfo`. |
| `frags` | `dynamic` | — | The frags input consumed by `replyPlayerInfo`. |
| `connectTime` | `dynamic` | — | Time value used by the operation. |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L124)

<a id="function-function-miniquake-net-control-replyreject-function-replyreject-reason-src-miniquake-net-control-ml-1050315859"></a>
### replyReject

```ml
function replyReject(reason)
```

Implements the `replyReject` operation for `miniquake.net_control` (reply reject).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reason` | `dynamic` | — | The reason input consumed by `replyReject`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L92)

<a id="function-function-miniquake-net-control-replyruleinfo-function-replyruleinfo-rule-value-src-miniquake-net-control-ml-771947414"></a>
### replyRuleInfo

```ml
function replyRuleInfo(rule, value)
```

Implements the `replyRuleInfo` operation for `miniquake.net_control` (reply rule info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rule` | `dynamic` | — | The rule input consumed by `replyRuleInfo`. |
| `value` | `dynamic` | — | Value consumed by `replyRuleInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L139)

<a id="function-function-miniquake-net-control-replyserverinfo-function-replyserverinfo-address-hostname-levelname-currentplayers-maxplayers-src-miniquake-net-control-ml-804420636"></a>
### replyServerInfo

```ml
function replyServerInfo(address, hostName, levelName, currentPlayers, maxPlayers)
```

Implements the `replyServerInfo` operation for `miniquake.net_control` (reply server info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |
| `hostName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `levelName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `currentPlayers` | `dynamic` | — | The current players input consumed by `replyServerInfo`. |
| `maxPlayers` | `dynamic` | — | The max players input consumed by `replyServerInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L105)

<a id="function-function-miniquake-net-control-requestconnect-function-requestconnect-src-miniquake-net-control-ml-943885537"></a>
### requestConnect

```ml
function requestConnect()
```

Implements the `requestConnect` operation for `miniquake.net_control` (request connect).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L46)

<a id="function-function-miniquake-net-control-requestplayerinfo-function-requestplayerinfo-playernumber-src-miniquake-net-control-ml-882053385"></a>
### requestPlayerInfo

```ml
function requestPlayerInfo(playerNumber)
```

Implements the `requestPlayerInfo` operation for `miniquake.net_control` (request player info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playerNumber` | `dynamic` | — | The player number input consumed by `requestPlayerInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L65)

<a id="function-function-miniquake-net-control-requestruleinfo-function-requestruleinfo-previousrule-src-miniquake-net-control-ml-2111935400"></a>
### requestRuleInfo

```ml
function requestRuleInfo(previousRule)
```

Implements the `requestRuleInfo` operation for `miniquake.net_control` (request rule info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previousRule` | `dynamic` | — | The previous rule input consumed by `requestRuleInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L74)

<a id="function-function-miniquake-net-control-requestserverinfo-function-requestserverinfo-src-miniquake-net-control-ml-1755147849"></a>
### requestServerInfo

```ml
function requestServerInfo()
```

Implements the `requestServerInfo` operation for `miniquake.net_control` (request server info).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L55)

<a id="function-function-miniquake-net-control-validconnectrequest-inline-function-validconnectrequest-parsed-src-miniquake-net-control-ml-1968506269"></a>
### validConnectRequest

```ml
inline function validConnectRequest(parsed)
```

Report whether valid connect request.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parsed` | `dynamic` | — | The parsed input consumed by `validConnectRequest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L211)

<a id="function-function-miniquake-net-control-validquakerequest-function-validquakerequest-parsed-src-miniquake-net-control-ml-299636036"></a>
### validQuakeRequest

```ml
function validQuakeRequest(parsed)
```

Report whether valid quake request.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parsed` | `dynamic` | — | The parsed input consumed by `validQuakeRequest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L200)

<a id="function-function-miniquake-net-control-validserverinforequest-inline-function-validserverinforequest-parsed-src-miniquake-net-control-ml-2056966307"></a>
### validServerInfoRequest

```ml
inline function validServerInfoRequest(parsed)
```

Report whether valid server info request.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parsed` | `dynamic` | — | The parsed input consumed by `validServerInfoRequest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L217)

<a id="function-function-miniquake-net-control-wrap-function-wrap-buffer-src-miniquake-net-control-ml-1772373399"></a>
### wrap

```ml
function wrap(buffer)
```

Implements the `wrap` operation for `miniquake.net_control` (wrap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `wrap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_control.ml#L41)
