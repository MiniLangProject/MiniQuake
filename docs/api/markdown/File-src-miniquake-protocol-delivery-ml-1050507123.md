# `src/miniquake/protocol_delivery.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_delivery`](Package-miniquake-protocol-delivery-716610468.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-miniquake-protocol-delivery-clearaftersend-function-clearaftersend-result-src-miniquake-protocol-delivery-ml-110253544"></a>
### clearAfterSend

```ml
function clearAfterSend(result)
```

Update module state for after send.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L54)

<a id="function-function-miniquake-protocol-delivery-clientreliableplan-function-clientreliableplan-connected-messagesize-cansend-src-miniquake-protocol-delivery-ml-107199324"></a>
### clientReliablePlan

```ml
function clientReliablePlan(connected, messageSize, canSend)
```

Implements the `clientReliablePlan` operation for `miniquake.protocol_delivery` (client reliable plan).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `connected` | `dynamic` | — | The connected input consumed by `clientReliablePlan`. |
| `messageSize` | `dynamic` | — | Size of the requested data or resource. |
| `canSend` | `dynamic` | — | The can send input consumed by `clientReliablePlan`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L32)

<a id="function-function-miniquake-protocol-delivery-keepalivedue-inline-function-keepalivedue-elapsed-src-miniquake-protocol-delivery-ml-1384750796"></a>
### keepaliveDue

```ml
inline function keepaliveDue(elapsed)
```

Implements the `keepaliveDue` operation for `miniquake.protocol_delivery` (keepalive due).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `elapsed` | `dynamic` | — | The elapsed input consumed by `keepaliveDue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L41)

<a id="function-function-miniquake-protocol-delivery-reliablesendoutcome-function-reliablesendoutcome-result-src-miniquake-protocol-delivery-ml-878275516"></a>
### reliableSendOutcome

```ml
function reliableSendOutcome(result)
```

Implements the `reliableSendOutcome` operation for `miniquake.protocol_delivery` (reliable send outcome).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L22)

<a id="function-function-miniquake-protocol-delivery-reliableworkpending-function-reliableworkpending-messagesize-dropasap-src-miniquake-protocol-delivery-ml-1914935915"></a>
### reliableWorkPending

```ml
function reliableWorkPending(messageSize, dropAsap)
```

Implements the `reliableWorkPending` operation for `miniquake.protocol_delivery` (reliable work pending).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messageSize` | `dynamic` | — | Size of the requested data or resource. |
| `dropAsap` | `dynamic` | — | The drop asap input consumed by `reliableWorkPending`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L48)

<a id="constant-constant-miniquake-protocol-delivery-send-commit-const-send-commit-3-src-miniquake-protocol-delivery-ml-797002199"></a>
### SEND_COMMIT

```ml
const SEND_COMMIT = 3
```

Defines the send commit value used by `miniquake.protocol_delivery`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L18)

<a id="constant-constant-miniquake-protocol-delivery-send-drop-const-send-drop-1-src-miniquake-protocol-delivery-ml-1927172545"></a>
### SEND_DROP

```ml
const SEND_DROP = 1
```

Defines the send drop value used by `miniquake.protocol_delivery`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L14)

<a id="constant-constant-miniquake-protocol-delivery-send-retain-const-send-retain-2-src-miniquake-protocol-delivery-ml-2005553178"></a>
### SEND_RETAIN

```ml
const SEND_RETAIN = 2
```

Defines the send retain value used by `miniquake.protocol_delivery`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_delivery.ml#L16)
