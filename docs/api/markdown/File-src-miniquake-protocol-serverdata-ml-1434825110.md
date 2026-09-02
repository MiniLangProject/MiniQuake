# `src/miniquake/protocol_serverdata.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_serverdata`](Package-miniquake-protocol-serverdata-2139420847.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-protocol-serverdata-appenddatagramiffits-function-appenddatagramiffits-destination-source-src-miniquake-protocol-serverdata-ml-1855989600"></a>
### appendDatagramIfFits

```ml
function appendDatagramIfFits(destination, source)
```

SV_SendClientDatagram copies sv.datagram only when the resulting size is strictly less than MAX_DATAGRAM. Equality is intentionally rejected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L235)

<a id="function-function-miniquake-protocol-serverdata-clientdatabits-function-clientdatabits-data-src-miniquake-protocol-serverdata-ml-664620439"></a>
### clientDataBits

```ml
function clientDataBits(data)
```

Return client data bits derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L165)

<a id="function-function-miniquake-protocol-serverdata-initialdeliveryplan-function-initialdeliveryplan-spawned-sendsignon-elapsed-src-miniquake-protocol-serverdata-ml-1475590765"></a>
### initialDeliveryPlan

```ml
function initialDeliveryPlan(spawned, sendSignon, elapsed)
```

First phase of SV_SendClientMessages. Spawned clients send an unreliable datagram and continue into the reliable phase. Unspawned clients without a requested signon stage either receive a five-second keepalive or wait.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spawned` | `dynamic` | — | The spawned input consumed by `initialDeliveryPlan`. |
| `sendSignon` | `dynamic` | — | The send signon input consumed by `initialDeliveryPlan`. |
| `elapsed` | `dynamic` | — | The elapsed input consumed by `initialDeliveryPlan`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L247)

<a id="constant-constant-miniquake-protocol-serverdata-plan-reliable-phase-const-plan-reliable-phase-8-src-miniquake-protocol-serverdata-ml-219113020"></a>
### PLAN_RELIABLE_PHASE

```ml
const PLAN_RELIABLE_PHASE = 8
```

Defines the plan reliable phase value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L26)

<a id="constant-constant-miniquake-protocol-serverdata-plan-send-nop-const-plan-send-nop-2-src-miniquake-protocol-serverdata-ml-642690194"></a>
### PLAN_SEND_NOP

```ml
const PLAN_SEND_NOP = 2
```

Defines the plan send nop value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L22)

<a id="constant-constant-miniquake-protocol-serverdata-plan-send-unreliable-const-plan-send-unreliable-1-src-miniquake-protocol-serverdata-ml-1157338143"></a>
### PLAN_SEND_UNRELIABLE

```ml
const PLAN_SEND_UNRELIABLE = 1
```

Defines the plan send unreliable value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L20)

<a id="constant-constant-miniquake-protocol-serverdata-plan-wait-signon-const-plan-wait-signon-4-src-miniquake-protocol-serverdata-ml-1076418234"></a>
### PLAN_WAIT_SIGNON

```ml
const PLAN_WAIT_SIGNON = 4
```

Defines the plan wait signon value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L24)

<a id="function-function-miniquake-protocol-serverdata-progscrctext-function-progscrctext-crc-src-miniquake-protocol-serverdata-ml-1053695779"></a>
### progsCrcText

```ml
function progsCrcText(crc)
```

Implements the `progsCrcText` operation for `miniquake.protocol_serverdata` (progs crc text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `crc` | `dynamic` | — | The crc input consumed by `progsCrcText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L41)

<a id="constant-constant-miniquake-protocol-serverdata-reliable-drop-asap-const-reliable-drop-asap-3-src-miniquake-protocol-serverdata-ml-71266265"></a>
### RELIABLE_DROP_ASAP

```ml
const RELIABLE_DROP_ASAP = 3
```

Defines the reliable drop asap value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L35)

<a id="constant-constant-miniquake-protocol-serverdata-reliable-drop-overflow-const-reliable-drop-overflow-1-src-miniquake-protocol-serverdata-ml-1818853957"></a>
### RELIABLE_DROP_OVERFLOW

```ml
const RELIABLE_DROP_OVERFLOW = 1
```

Defines the reliable drop overflow value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L31)

<a id="constant-constant-miniquake-protocol-serverdata-reliable-none-const-reliable-none-0-src-miniquake-protocol-serverdata-ml-1064042860"></a>
### RELIABLE_NONE

```ml
const RELIABLE_NONE = 0
```

Defines the reliable none value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L29)

<a id="constant-constant-miniquake-protocol-serverdata-reliable-send-const-reliable-send-4-src-miniquake-protocol-serverdata-ml-1653569416"></a>
### RELIABLE_SEND

```ml
const RELIABLE_SEND = 4
```

Defines the reliable send value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L37)

<a id="constant-constant-miniquake-protocol-serverdata-reliable-wait-const-reliable-wait-2-src-miniquake-protocol-serverdata-ml-1234275290"></a>
### RELIABLE_WAIT

```ml
const RELIABLE_WAIT = 2
```

Defines the reliable wait value used by `miniquake.protocol_serverdata`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L33)

<a id="function-function-miniquake-protocol-serverdata-reliabledeliveryplan-function-reliabledeliveryplan-overflowed-messagesize-dropasap-cansend-src-miniquake-protocol-serverdata-ml-188707194"></a>
### reliableDeliveryPlan

```ml
function reliableDeliveryPlan(overflowed, messageSize, dropAsap, canSend)
```

Implements the `reliableDeliveryPlan` operation for `miniquake.protocol_serverdata` (reliable delivery plan).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `overflowed` | `dynamic` | — | The overflowed input consumed by `reliableDeliveryPlan`. |
| `messageSize` | `dynamic` | — | Size of the requested data or resource. |
| `dropAsap` | `dynamic` | — | The drop asap input consumed by `reliableDeliveryPlan`. |
| `canSend` | `dynamic` | — | The can send input consumed by `reliableDeliveryPlan`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L261)

<a id="function-function-miniquake-protocol-serverdata-soundfieldmask-function-soundfieldmask-volume-attenuation-src-miniquake-protocol-serverdata-ml-1884053171"></a>
### soundFieldMask

```ml
function soundFieldMask(volume, attenuation)
```

Implements the `soundFieldMask` operation for `miniquake.protocol_serverdata` (sound field mask).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `volume` | `dynamic` | — | The volume input consumed by `soundFieldMask`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `soundFieldMask`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L105)

<a id="function-function-miniquake-protocol-serverdata-writebaseline-function-writebaseline-buffer-entitynumber-baseline-src-miniquake-protocol-serverdata-ml-1025480504"></a>
### writeBaseline

```ml
function writeBaseline(buffer, entityNumber, baseline)
```

Writes baseline for `miniquake.protocol_serverdata`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeBaseline`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `writeBaseline`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `writeBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L146)

<a id="function-function-miniquake-protocol-serverdata-writeclientdata-function-writeclientdata-buffer-data-src-miniquake-protocol-serverdata-ml-1485781037"></a>
### writeClientData

```ml
function writeClientData(buffer, data)
```

The final active-weapon byte intentionally follows stock Quake's two modes. In mission-pack mode a zero bitfield emits no byte, matching the original C loop's fall-through behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeClientData`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L188)

<a id="function-function-miniquake-protocol-serverdata-writeprecachelist-function-writeprecachelist-buffer-values-src-miniquake-protocol-serverdata-ml-737335991"></a>
### writePrecacheList

```ml
function writePrecacheList(buffer, values)
```

Encode and write precache list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writePrecacheList`. |
| `values` | `dynamic` | — | The values input consumed by `writePrecacheList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L48)

<a id="function-function-miniquake-protocol-serverdata-writeserverinfo-function-writeserverinfo-buffer-progscrc-maxclients-gametype-levelname-modelprecache-soundprecache-cdtrack-viewentity-src-miniquake-protocol-serverdata-ml-1816511505"></a>
### writeServerInfo

```ml
function writeServerInfo(buffer, progsCrc, maxClients, gameType, levelName, modelPrecache, soundPrecache, cdTrack, viewEntity)
```

SV_SendServerinfo payload, including the leading version print and stage-1 signon marker.  client lifecycle flags remain the caller's responsibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeServerInfo`. |
| `progsCrc` | `dynamic` | — | The progs crc input consumed by `writeServerInfo`. |
| `maxClients` | `dynamic` | — | The max clients input consumed by `writeServerInfo`. |
| `gameType` | `dynamic` | — | The game type input consumed by `writeServerInfo`. |
| `levelName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `modelPrecache` | `dynamic` | — | The model precache input consumed by `writeServerInfo`. |
| `soundPrecache` | `dynamic` | — | The sound precache input consumed by `writeServerInfo`. |
| `cdTrack` | `dynamic` | — | The cd track input consumed by `writeServerInfo`. |
| `viewEntity` | `dynamic` | — | The view entity input consumed by `writeServerInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L71)

<a id="function-function-miniquake-protocol-serverdata-writesound-function-writesound-buffer-entitynumber-channel-soundnumber-volume-attenuation-center-src-miniquake-protocol-serverdata-ml-768242551"></a>
### writeSound

```ml
function writeSound(buffer, entityNumber, channel, soundNumber, volume, attenuation, center)
```

SV_StartSound's wire payload. C has already converted channel/volume to int and attenuation to float before entering the function. Recreate that ABI boundary here so dynamic MiniLang callers cannot alter the optional bits. Validation, precache lookup and the MAX_DATAGRAM-16 early-out are performed by the production wrappers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `writeSound`. |
| `channel` | `dynamic` | — | The channel input consumed by `writeSound`. |
| `soundNumber` | `dynamic` | — | The sound number input consumed by `writeSound`. |
| `volume` | `dynamic` | — | The volume input consumed by `writeSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `writeSound`. |
| `center` | `dynamic` | — | The center input consumed by `writeSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_serverdata.ml#L121)
