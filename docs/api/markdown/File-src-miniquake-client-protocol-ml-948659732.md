# `src/miniquake/client_protocol.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.client_protocol`](Package-miniquake-client-protocol-109672373.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/protocol_events.ml` as `protocolEvents` → [src/miniquake/protocol_events.ml](File-src-miniquake-protocol-events-ml-1275855860.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/temp_entities.ml` as `temporary` → [src/miniquake/temp_entities.ml](File-src-miniquake-temp-entities-ml-1619498140.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-client-protocol-cl-parsebaseline-function-cl-parsebaseline-reader-src-miniquake-client-protocol-ml-170241644"></a>
### CL_ParseBaseline

```ml
function CL_ParseBaseline(reader)
```

Apply the Quake-compatible cl parse baseline behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L27)

<a id="function-function-miniquake-client-protocol-cl-parseclientdata-function-cl-parseclientdata-reader-bits-src-miniquake-client-protocol-ml-1135231428"></a>
### CL_ParseClientdata

```ml
function CL_ParseClientdata(reader, bits)
```

Apply the Quake-compatible cl parse clientdata behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseClientdata`. |
| `bits` | `dynamic` | — | The bits input consumed by `CL_ParseClientdata`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L96)

<a id="function-function-miniquake-client-protocol-cl-parseserverinfo-function-cl-parseserverinfo-reader-src-miniquake-client-protocol-ml-2060991660"></a>
### CL_ParseServerInfo

```ml
function CL_ParseServerInfo(reader)
```

Apply the Quake-compatible cl parse server info behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseServerInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L135)

<a id="function-function-miniquake-client-protocol-cl-parseservermessage-function-cl-parseservermessage-data-src-miniquake-client-protocol-ml-1175142177"></a>
### CL_ParseServerMessage

```ml
function CL_ParseServerMessage(data)
```

Apply the Quake-compatible cl parse server message behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L349)

<a id="function-function-miniquake-client-protocol-cl-parsestartsoundpacket-function-cl-parsestartsoundpacket-reader-src-miniquake-client-protocol-ml-1156744132"></a>
### CL_ParseStartSoundPacket

```ml
function CL_ParseStartSoundPacket(reader)
```

Apply the Quake-compatible cl parse start sound packet behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseStartSoundPacket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L183)

<a id="function-function-miniquake-client-protocol-cl-parsestatic-function-cl-parsestatic-reader-src-miniquake-client-protocol-ml-1950005000"></a>
### CL_ParseStatic

```ml
function CL_ParseStatic(reader)
```

Apply the Quake-compatible cl parse static behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseStatic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L231)

<a id="function-function-miniquake-client-protocol-cl-parsestaticsound-function-cl-parsestaticsound-reader-src-miniquake-client-protocol-ml-116720092"></a>
### CL_ParseStaticSound

```ml
function CL_ParseStaticSound(reader)
```

Apply the Quake-compatible cl parse static sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseStaticSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L215)

<a id="function-function-miniquake-client-protocol-cl-parseupdate-function-cl-parseupdate-reader-lowbits-src-miniquake-client-protocol-ml-1659703418"></a>
### CL_ParseUpdate

```ml
function CL_ParseUpdate(reader, lowBits)
```

Apply the Quake-compatible cl parse update behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `CL_ParseUpdate`. |
| `lowBits` | `dynamic` | — | The low bits input consumed by `CL_ParseUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L52)

<a id="function-function-miniquake-client-protocol-event-function-event-name-payload-src-miniquake-client-protocol-ml-160141394"></a>
### event

```ml
function event(name, payload)
```

Implements the `event` operation for `miniquake.client_protocol` (event).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `payload` | `dynamic` | — | The payload input consumed by `event`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L21)

<a id="function-function-miniquake-client-protocol-parse-function-parse-data-src-miniquake-client-protocol-ml-1185258945"></a>
### parse

```ml
function parse(data)
```

Implements the `parse` operation for `miniquake.client_protocol` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L237)

<a id="function-function-miniquake-client-protocol-readbaseline-function-readbaseline-reader-src-miniquake-client-protocol-ml-821985368"></a>
### readBaseline

```ml
function readBaseline(reader)
```

Read and validate baseline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L45)

<a id="function-function-miniquake-client-protocol-readclientdata-function-readclientdata-reader-src-miniquake-client-protocol-ml-662095740"></a>
### readClientData

```ml
function readClientData(reader)
```

Read and validate client data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readClientData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L128)

<a id="function-function-miniquake-client-protocol-readfastupdate-function-readfastupdate-reader-lowbits-src-miniquake-client-protocol-ml-381768938"></a>
### readFastUpdate

```ml
function readFastUpdate(reader, lowBits)
```

Read and validate fast update.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readFastUpdate`. |
| `lowBits` | `dynamic` | — | The low bits input consumed by `readFastUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L89)

<a id="function-function-miniquake-client-protocol-readparticle-function-readparticle-reader-src-miniquake-client-protocol-ml-1162543100"></a>
### readParticle

```ml
function readParticle(reader)
```

Read and validate particle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readParticle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L205)

<a id="function-function-miniquake-client-protocol-readserverinfo-function-readserverinfo-reader-src-miniquake-client-protocol-ml-2002330264"></a>
### readServerInfo

```ml
function readServerInfo(reader)
```

Read and validate server info.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readServerInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L177)

<a id="function-function-miniquake-client-protocol-readsound-function-readsound-reader-src-miniquake-client-protocol-ml-495276302"></a>
### readSound

```ml
function readSound(reader)
```

Read and validate sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L199)

<a id="function-function-miniquake-client-protocol-readstaticsound-function-readstaticsound-reader-src-miniquake-client-protocol-ml-1951305198"></a>
### readStaticSound

```ml
function readStaticSound(reader)
```

Read and validate static sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readStaticSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_protocol.ml#L225)
