# `src/miniquake/net_datagram.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.net_datagram`](Package-miniquake-net-datagram-2128413400.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-net-datagram-acceptreliable-function-acceptreliable-channel-packet-src-miniquake-net-datagram-ml-1973527004"></a>
### acceptReliable

```ml
function acceptReliable(channel, packet)
```

Implements the `acceptReliable` operation for `miniquake.net_datagram` (accept reliable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `acceptReliable`. |
| `packet` | `dynamic` | — | Network packet to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L200)

<a id="function-function-miniquake-net-datagram-acceptunreliable-function-acceptunreliable-channel-packet-src-miniquake-net-datagram-ml-356193220"></a>
### acceptUnreliable

```ml
function acceptUnreliable(channel, packet)
```

Implements the `acceptUnreliable` operation for `miniquake.net_datagram` (accept unreliable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `acceptUnreliable`. |
| `packet` | `dynamic` | — | Network packet to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L210)

<a id="function-function-miniquake-net-datagram-acknowledgement-function-acknowledgement-sequence-src-miniquake-net-datagram-ml-402284186"></a>
### acknowledgement

```ml
function acknowledgement(sequence)
```

Implements the `acknowledgement` operation for `miniquake.net_datagram` (acknowledgement).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sequence` | `dynamic` | — | The sequence input consumed by `acknowledgement`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L181)

<a id="function-function-miniquake-net-datagram-appendbytes-function-appendbytes-a-b-src-miniquake-net-datagram-ml-1452288306"></a>
### appendBytes

```ml
function appendBytes(a, b)
```

Add state for append bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `appendBytes`. |
| `b` | `dynamic` | — | The b input consumed by `appendBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L100)

<a id="function-function-miniquake-net-datagram-beginreliable-function-beginreliable-channel-payload-now-src-miniquake-net-datagram-ml-1854669280"></a>
### beginReliable

```ml
function beginReliable(channel, payload, now)
```

Initialize state for begin reliable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `beginReliable`. |
| `payload` | `dynamic` | — | The payload input consumed by `beginReliable`. |
| `now` | `dynamic` | — | The now input consumed by `beginReliable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L246)

<a id="function-function-miniquake-net-datagram-bigu32-function-bigu32-data-offset-src-miniquake-net-datagram-ml-1053083908"></a>
### bigU32

```ml
function bigU32(data, offset)
```

Implements the `bigU32` operation for `miniquake.net_datagram` (big u32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L87)

<a id="function-function-miniquake-net-datagram-control-function-control-payload-src-miniquake-net-datagram-ml-801633533"></a>
### control

```ml
function control(payload)
```

Implements the `control` operation for `miniquake.net_datagram` (control).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | The payload input consumed by `control`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L193)

<a id="function-function-miniquake-net-datagram-createchannel-function-createchannel-src-miniquake-net-datagram-ml-258599087"></a>
### createChannel

```ml
function createChannel()
```

Create and initialize channel.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L93)

<a id="function-function-miniquake-net-datagram-datagram-cansendmessage-function-datagram-cansendmessage-channel-src-miniquake-net-datagram-ml-1239658034"></a>
### Datagram_CanSendMessage

```ml
function Datagram_CanSendMessage(channel)
```

Mirror Quake's Datagram_CanSendMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `Datagram_CanSendMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L390)

<a id="function-function-miniquake-net-datagram-datagram-cansendunreliablemessage-function-datagram-cansendunreliablemessage-channel-src-miniquake-net-datagram-ml-746200256"></a>
### Datagram_CanSendUnreliableMessage

```ml
function Datagram_CanSendUnreliableMessage(channel)
```

Mirror Quake's Datagram_CanSendUnreliableMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `Datagram_CanSendUnreliableMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L399)

<a id="function-function-miniquake-net-datagram-datagram-flushsendnext-function-datagram-flushsendnext-channel-now-src-miniquake-net-datagram-ml-590008862"></a>
### Datagram_FlushSendNext

```ml
function Datagram_FlushSendNext(channel, now)
```

Mirror Quake's Datagram_FlushSendNext routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `Datagram_FlushSendNext`. |
| `now` | `dynamic` | — | The now input consumed by `Datagram_FlushSendNext`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L383)

<a id="function-function-miniquake-net-datagram-datagram-getmessage-function-datagram-getmessage-channel-packet-now-src-miniquake-net-datagram-ml-1810238928"></a>
### Datagram_GetMessage

```ml
function Datagram_GetMessage(channel, packet, now)
```

Mirror Quake's Datagram_GetMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `Datagram_GetMessage`. |
| `packet` | `dynamic` | — | Network packet to process. |
| `now` | `dynamic` | — | The now input consumed by `Datagram_GetMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L415)

<a id="function-function-miniquake-net-datagram-datagram-sendmessage-function-datagram-sendmessage-channel-payload-now-src-miniquake-net-datagram-ml-1720942714"></a>
### Datagram_SendMessage

```ml
function Datagram_SendMessage(channel, payload, now)
```

Named net_dgrm.c entry points. The transport-facing net_loop module supplies the UDP socket operations; these functions own the original channel state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `Datagram_SendMessage`. |
| `payload` | `dynamic` | — | The payload input consumed by `Datagram_SendMessage`. |
| `now` | `dynamic` | — | The now input consumed by `Datagram_SendMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L362)

<a id="function-function-miniquake-net-datagram-datagram-sendunreliablemessage-function-datagram-sendunreliablemessage-channel-payload-src-miniquake-net-datagram-ml-1370907720"></a>
### Datagram_SendUnreliableMessage

```ml
function Datagram_SendUnreliableMessage(channel, payload)
```

Mirror Quake's Datagram_SendUnreliableMessage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `Datagram_SendUnreliableMessage`. |
| `payload` | `dynamic` | — | The payload input consumed by `Datagram_SendUnreliableMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L406)

<a id="function-function-miniquake-net-datagram-decodepacket-function-decodepacket-data-src-miniquake-net-datagram-ml-223949289"></a>
### decodePacket

```ml
function decodePacket(data)
```

Read and validate packet.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L136)

<a id="global-global-miniquake-net-datagram-droppeddatagrams-droppeddatagrams-src-miniquake-net-datagram-ml-78870547"></a>
### droppedDatagrams

```ml
droppedDatagrams
```

Tracks the module-level dropped datagrams state owned by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L45)

<a id="function-function-miniquake-net-datagram-dropprefix-function-dropprefix-data-count-src-miniquake-net-datagram-ml-1572275972"></a>
### dropPrefix

```ml
function dropPrefix(data, count)
```

Release state for drop prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L110)

<a id="function-function-miniquake-net-datagram-encode-function-encode-flags-sequence-payload-src-miniquake-net-datagram-ml-2079567673"></a>
### encode

```ml
function encode(flags, sequence, payload)
```

Implements the `encode` operation for `miniquake.net_datagram` (encode).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `flags` | `dynamic` | — | The flags input consumed by `encode`. |
| `sequence` | `dynamic` | — | The sequence input consumed by `encode`. |
| `payload` | `dynamic` | — | The payload input consumed by `encode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L120)

<a id="constant-constant-miniquake-net-datagram-max-datagram-const-max-datagram-1024-src-miniquake-net-datagram-ml-557240827"></a>
### MAX_DATAGRAM

```ml
const MAX_DATAGRAM = 1024
```

Defines the max datagram value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L32)

<a id="function-function-miniquake-net-datagram-negativeacknowledgement-function-negativeacknowledgement-sequence-src-miniquake-net-datagram-ml-1407504756"></a>
### negativeAcknowledgement

```ml
function negativeAcknowledgement(sequence)
```

Implements the `negativeAcknowledgement` operation for `miniquake.net_datagram` (negative acknowledgement).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sequence` | `dynamic` | — | The sequence input consumed by `negativeAcknowledgement`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L187)

<a id="constant-constant-miniquake-net-datagram-net-headersize-const-net-headersize-8-src-miniquake-net-datagram-ml-1815767152"></a>
### NET_HEADERSIZE

```ml
const NET_HEADERSIZE = 8
```

Defines the net headersize value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L28)

<a id="constant-constant-miniquake-net-datagram-net-maxmessage-const-net-maxmessage-8192-src-miniquake-net-datagram-ml-886819098"></a>
### NET_MAXMESSAGE

```ml
const NET_MAXMESSAGE = 8192
```

Defines the net maxmessage value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L30)

<a id="function-function-miniquake-net-datagram-net-stats-f-function-net-stats-f-channels-messagessent-messagesreceived-unreliablesent-unreliablereceived-src-miniquake-net-datagram-ml-1371554333"></a>
### NET_Stats_f

```ml
function NET_Stats_f(channels, messagesSent, messagesReceived, unreliableSent, unreliableReceived)
```

Mirror Quake's NET_Stats_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channels` | `dynamic` | — | Number of interleaved audio channels. |
| `messagesSent` | `dynamic` | — | The messages sent input consumed by `NET_Stats_f`. |
| `messagesReceived` | `dynamic` | — | The messages received input consumed by `NET_Stats_f`. |
| `unreliableSent` | `dynamic` | — | The unreliable sent input consumed by `NET_Stats_f`. |
| `unreliableReceived` | `dynamic` | — | The unreliable received input consumed by `NET_Stats_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L431)

<a id="constant-constant-miniquake-net-datagram-netflag-ack-const-netflag-ack-131072-src-miniquake-net-datagram-ml-556039390"></a>
### NETFLAG_ACK

```ml
const NETFLAG_ACK = 131072
```

Defines the netflag ack value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L18)

<a id="constant-constant-miniquake-net-datagram-netflag-ctl-const-netflag-ctl-2147483648-src-miniquake-net-datagram-ml-1149510699"></a>
### NETFLAG_CTL

```ml
const NETFLAG_CTL = 2147483648
```

Defines the netflag ctl value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L26)

<a id="constant-constant-miniquake-net-datagram-netflag-data-const-netflag-data-65536-src-miniquake-net-datagram-ml-1369714961"></a>
### NETFLAG_DATA

```ml
const NETFLAG_DATA = 65536
```

Defines the netflag data value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L16)

<a id="constant-constant-miniquake-net-datagram-netflag-eom-const-netflag-eom-524288-src-miniquake-net-datagram-ml-1870243327"></a>
### NETFLAG_EOM

```ml
const NETFLAG_EOM = 524288
```

Defines the netflag eom value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L22)

<a id="constant-constant-miniquake-net-datagram-netflag-length-mask-const-netflag-length-mask-65535-src-miniquake-net-datagram-ml-1160747174"></a>
### NETFLAG_LENGTH_MASK

```ml
const NETFLAG_LENGTH_MASK = 65535
```

Defines the netflag length mask value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L14)

<a id="constant-constant-miniquake-net-datagram-netflag-nak-const-netflag-nak-262144-src-miniquake-net-datagram-ml-817878959"></a>
### NETFLAG_NAK

```ml
const NETFLAG_NAK = 262144
```

Defines the netflag nak value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L20)

<a id="constant-constant-miniquake-net-datagram-netflag-unreliable-const-netflag-unreliable-1048576-src-miniquake-net-datagram-ml-1614853223"></a>
### NETFLAG_UNRELIABLE

```ml
const NETFLAG_UNRELIABLE = 1048576
```

Defines the netflag unreliable value used by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L24)

<a id="function-function-miniquake-net-datagram-nextreliablepacket-function-nextreliablepacket-channel-now-src-miniquake-net-datagram-ml-1425736130"></a>
### nextReliablePacket

```ml
function nextReliablePacket(channel, now)
```

Return next reliable packet for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `nextReliablePacket`. |
| `now` | `dynamic` | — | The now input consumed by `nextReliablePacket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L223)

<a id="function-function-miniquake-net-datagram-nextsequence-inline-function-nextsequence-sequence-src-miniquake-net-datagram-ml-414605799"></a>
### nextSequence

```ml
inline function nextSequence(sequence)
```

Return next sequence for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sequence` | `dynamic` | — | The sequence input consumed by `nextSequence`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L62)

<a id="global-global-miniquake-net-datagram-packetsreceived-packetsreceived-src-miniquake-net-datagram-ml-870118427"></a>
### packetsReceived

```ml
packetsReceived
```

Tracks the module-level packets received state owned by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L39)

<a id="global-global-miniquake-net-datagram-packetsresent-packetsresent-src-miniquake-net-datagram-ml-684114747"></a>
### packetsReSent

```ml
packetsReSent
```

Tracks the module-level packets re sent state owned by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L37)

<a id="global-global-miniquake-net-datagram-packetssent-packetssent-src-miniquake-net-datagram-ml-441684923"></a>
### packetsSent

```ml
packetsSent
```

Tracks the module-level packets sent state owned by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L35)

<a id="function-function-miniquake-net-datagram-pollretransmit-function-pollretransmit-channel-now-src-miniquake-net-datagram-ml-866948114"></a>
### pollRetransmit

```ml
function pollRetransmit(channel, now)
```

Implements the `pollRetransmit` operation for `miniquake.net_datagram` (poll retransmit).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `pollRetransmit`. |
| `now` | `dynamic` | — | The now input consumed by `pollRetransmit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L276)

<a id="function-function-miniquake-net-datagram-previoussequence-inline-function-previoussequence-sequence-src-miniquake-net-datagram-ml-669611847"></a>
### previousSequence

```ml
inline function previousSequence(sequence)
```

Implements the `previousSequence` operation for `miniquake.net_datagram` (previous sequence).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sequence` | `dynamic` | — | The sequence input consumed by `previousSequence`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L68)

<a id="function-function-miniquake-net-datagram-printstats-function-printstats-channel-src-miniquake-net-datagram-ml-1657652836"></a>
### PrintStats

```ml
function PrintStats(channel)
```

Format and emit stats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `PrintStats`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L421)

<a id="function-function-miniquake-net-datagram-processpacket-function-processpacket-channel-wirepacket-now-src-miniquake-net-datagram-ml-1878384453"></a>
### processPacket

```ml
function processPacket(channel, wirePacket, now)
```

Returns [message type, payload, ACK/NAK response, immediate transport reply]. Matching ACKs only mark sendNext.  The transport flushes the next reliable fragment after its receive loop, matching net_dgrm.c.  Message type follows NET_GetMessage: 0 = none, 1 = reliable, 2 = unreliable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `processPacket`. |
| `wirePacket` | `dynamic` | — | The wire packet input consumed by `processPacket`. |
| `now` | `dynamic` | — | The now input consumed by `processPacket`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L289)

<a id="function-function-miniquake-net-datagram-putbigu32-function-putbigu32-data-offset-value-src-miniquake-net-datagram-ml-1795794907"></a>
### putBigU32

```ml
function putBigU32(data, offset, value)
```

Encode and write big u32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putBigU32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L76)

<a id="global-global-miniquake-net-datagram-receivedduplicatecount-receivedduplicatecount-src-miniquake-net-datagram-ml-1594466709"></a>
### receivedDuplicateCount

```ml
receivedDuplicateCount
```

Tracks the module-level received duplicate count state owned by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L41)

<a id="function-function-miniquake-net-datagram-reliable-function-reliable-channel-payload-endofmessage-src-miniquake-net-datagram-ml-1102620745"></a>
### reliable

```ml
function reliable(channel, payload, endOfMessage)
```

Implements the `reliable` operation for `miniquake.net_datagram` (reliable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `reliable`. |
| `payload` | `dynamic` | — | The payload input consumed by `reliable`. |
| `endOfMessage` | `dynamic` | — | The end of message input consumed by `reliable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L158)

<a id="function-function-miniquake-net-datagram-resendmessage-function-resendmessage-channel-now-src-miniquake-net-datagram-ml-2043610386"></a>
### ReSendMessage

```ml
function ReSendMessage(channel, now)
```

Implements the `ReSendMessage` operation for `miniquake.net_datagram` (re send message).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `ReSendMessage`. |
| `now` | `dynamic` | — | The now input consumed by `ReSendMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L376)

<a id="function-function-miniquake-net-datagram-resendreliable-function-resendreliable-channel-now-src-miniquake-net-datagram-ml-1578748042"></a>
### resendReliable

```ml
function resendReliable(channel, now)
```

Implements the `resendReliable` operation for `miniquake.net_datagram` (resend reliable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `resendReliable`. |
| `now` | `dynamic` | — | The now input consumed by `resendReliable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L259)

<a id="function-function-miniquake-net-datagram-resetstats-function-resetstats-src-miniquake-net-datagram-ml-1589512897"></a>
### resetStats

```ml
function resetStats()
```

Update module state for stats.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L48)

<a id="function-function-miniquake-net-datagram-sendmessagenext-function-sendmessagenext-channel-now-src-miniquake-net-datagram-ml-2000938386"></a>
### SendMessageNext

```ml
function SendMessageNext(channel, now)
```

Send message next through the active connection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `SendMessageNext`. |
| `now` | `dynamic` | — | The now input consumed by `SendMessageNext`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L369)

<a id="global-global-miniquake-net-datagram-shortpacketcount-shortpacketcount-src-miniquake-net-datagram-ml-565831049"></a>
### shortPacketCount

```ml
shortPacketCount
```

Tracks the module-level short packet count state owned by `miniquake.net_datagram`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L43)

<a id="function-function-miniquake-net-datagram-unreliable-function-unreliable-channel-payload-src-miniquake-net-datagram-ml-516647100"></a>
### unreliable

```ml
function unreliable(channel, payload)
```

Implements the `unreliable` operation for `miniquake.net_datagram` (unreliable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `unreliable`. |
| `payload` | `dynamic` | — | The payload input consumed by `unreliable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/net_datagram.ml#L171)
