# `src/miniquake/protocol_transients.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_transients`](Package-miniquake-protocol-transients-156648019.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-protocol-transients-activecompactbeamlist-function-activecompactbeamlist-beams-currenttime-src-miniquake-protocol-transients-ml-1329308843"></a>
### activeCompactBeamList

```ml
function activeCompactBeamList(beams, currentTime)
```

Return only the records that CL_UpdateTEnts would draw at currentTime.  This is deliberately a view over the compact beam state: expired records remain in the retained fixed-slot state so CL_ParseBeam can still find a previous entity in pass one, exactly like the original cl_beams[MAX_BEAMS] array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `activeCompactBeamList`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L298)

<a id="function-function-miniquake-protocol-transients-beamalive-function-beamalive-endtime-currenttime-src-miniquake-protocol-transients-ml-1449081343"></a>
### beamAlive

```ml
function beamAlive(endTime, currentTime)
```

Implements the `beamAlive` operation for `miniquake.protocol_transients` (beam alive).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `endTime` | `dynamic` | — | Time value used by the operation. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L288)

<a id="function-function-miniquake-protocol-transients-beamendtime-function-beamendtime-currenttime-src-miniquake-protocol-transients-ml-654639859"></a>
### beamEndTime

```ml
function beamEndTime(currentTime)
```

beam_t.endtime and dlight_t.die are C floats while cl.time is double.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L275)

<a id="function-function-miniquake-protocol-transients-canwritedynamicsound-inline-function-canwritedynamicsound-buffer-src-miniquake-protocol-transients-ml-895458086"></a>
### canWriteDynamicSound

```ml
inline function canWriteDynamicSound(buffer)
```

WinQuake reserves a conservative 16-byte tail before looking up the sound. Equality is accepted; only cursize > MAX_DATAGRAM-16 drops the event.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `canWriteDynamicSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L94)

<a id="function-function-miniquake-protocol-transients-cfloat-function-cfloat-value-src-miniquake-protocol-transients-ml-1234717764"></a>
### cFloat

```ml
function cFloat(value)
```

Implements the `cFloat` operation for `miniquake.protocol_transients` (c float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `cFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L29)

<a id="function-function-miniquake-protocol-transients-cfloatproduct-function-cfloatproduct-left-right-src-miniquake-protocol-transients-ml-981493892"></a>
### cFloatProduct

```ml
function cFloatProduct(left, right)
```

Implements the `cFloatProduct` operation for `miniquake.protocol_transients` (c float product).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `cFloatProduct`. |
| `right` | `dynamic` | — | The right input consumed by `cFloatProduct`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L36)

<a id="function-function-miniquake-protocol-transients-clientsoundattenuation-function-clientsoundattenuation-attenuationbyte-src-miniquake-protocol-transients-ml-1690642427"></a>
### clientSoundAttenuation

```ml
function clientSoundAttenuation(attenuationByte)
```

Implements the `clientSoundAttenuation` operation for `miniquake.protocol_transients` (client sound attenuation).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `attenuationByte` | `dynamic` | — | The attenuation byte input consumed by `clientSoundAttenuation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L253)

<a id="function-function-miniquake-protocol-transients-clientsoundvolume-function-clientsoundvolume-volumebyte-src-miniquake-protocol-transients-ml-1804411283"></a>
### clientSoundVolume

```ml
function clientSoundVolume(volumeByte)
```

CL_ParseStartSoundPacket stores attenuation as float and S_StartSound takes float volume/attenuation parameters.  Explicit binary32 conversion prevents MiniLang's wider numeric representation from changing mixer state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `volumeByte` | `dynamic` | — | The volume byte input consumed by `clientSoundVolume`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L247)

<a id="function-function-miniquake-protocol-transients-compactbeamindexforslot-function-compactbeamindexforslot-beams-slot-src-miniquake-protocol-transients-ml-531717239"></a>
### compactBeamIndexForSlot

```ml
function compactBeamIndexForSlot(beams, slot)
```

Implements the `compactBeamIndexForSlot` operation for `miniquake.protocol_transients` (compact beam index for slot).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `compactBeamIndexForSlot`. |
| `slot` | `dynamic` | — | The slot input consumed by `compactBeamIndexForSlot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L383)

<a id="function-function-miniquake-protocol-transients-compactbeamslot-function-compactbeamslot-record-fallback-src-miniquake-protocol-transients-ml-1577317340"></a>
### compactBeamSlot

```ml
function compactBeamSlot(record, fallback)
```

The integrated renderer stores compact records instead of beam_t objects. Each record is [wirePayload, endTime, originalSlot].  Retain expired records until their slot is reused: CL_ParseBeam first replaces the same entity even when that beam has expired, and only then searches the first free/expired slot in the fixed 24-entry pool.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | The record input consumed by `compactBeamSlot`. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L313)

<a id="function-function-miniquake-protocol-transients-compactbeamslottaken-function-compactbeamslottaken-beams-slot-src-miniquake-protocol-transients-ml-1558901049"></a>
### compactBeamSlotTaken

```ml
function compactBeamSlotTaken(beams, slot)
```

Implements the `compactBeamSlotTaken` operation for `miniquake.protocol_transients` (compact beam slot taken).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `compactBeamSlotTaken`. |
| `slot` | `dynamic` | — | The slot input consumed by `compactBeamSlotTaken`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L324)

<a id="function-function-miniquake-protocol-transients-dynamiclightdietime-function-dynamiclightdietime-currenttime-src-miniquake-protocol-transients-ml-612549085"></a>
### dynamicLightDieTime

```ml
function dynamicLightDieTime(currentTime)
```

Implements the `dynamicLightDieTime` operation for `miniquake.protocol_transients` (dynamic light die time).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L281)

<a id="function-function-miniquake-protocol-transients-dynamicsoundwiresize-function-dynamicsoundwiresize-volume-attenuation-src-miniquake-protocol-transients-ml-34446679"></a>
### dynamicSoundWireSize

```ml
function dynamicSoundWireSize(volume, attenuation)
```

Return dynamic sound wire size derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `volume` | `dynamic` | — | The volume input consumed by `dynamicSoundWireSize`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `dynamicSoundWireSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L83)

<a id="function-function-miniquake-protocol-transients-firstunusedcompactbeamslot-function-firstunusedcompactbeamslot-beams-src-miniquake-protocol-transients-ml-1641621609"></a>
### firstUnusedCompactBeamSlot

```ml
function firstUnusedCompactBeamSlot(beams)
```

Return first unused compact beam slot for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `firstUnusedCompactBeamSlot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L333)

<a id="function-function-miniquake-protocol-transients-insertcompactbeambyslot-function-insertcompactbeambyslot-beams-record-src-miniquake-protocol-transients-ml-1885392256"></a>
### insertCompactBeamBySlot

```ml
function insertCompactBeamBySlot(beams, record)
```

Add state for insert compact beam by slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `insertCompactBeamBySlot`. |
| `record` | `dynamic` | — | The record input consumed by `insertCompactBeamBySlot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L345)

<a id="function-function-miniquake-protocol-transients-isbeamtype-function-isbeamtype-type-src-miniquake-protocol-transients-ml-2136665663"></a>
### isBeamType

```ml
function isBeamType(type)
```

Report whether is beam type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `isBeamType`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L122)

<a id="function-function-miniquake-protocol-transients-ispointtype-function-ispointtype-type-src-miniquake-protocol-transients-ml-1533658355"></a>
### isPointType

```ml
function isPointType(type)
```

Report whether is point type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `isPointType`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L107)

<a id="constant-constant-miniquake-protocol-transients-max-beams-const-max-beams-24-src-miniquake-protocol-transients-ml-506624860"></a>
### MAX_BEAMS

```ml
const MAX_BEAMS = 24
```

Defines the max beams value used by `miniquake.protocol_transients`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L25)

<a id="function-function-miniquake-protocol-transients-normalizecompactbeamlist-function-normalizecompactbeamlist-beams-src-miniquake-protocol-transients-ml-716867525"></a>
### normalizeCompactBeamList

```ml
function normalizeCompactBeamList(beams)
```

Convert compact beam list into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `normalizeCompactBeamList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L362)

<a id="function-function-miniquake-protocol-transients-packsoundchannel-function-packsoundchannel-entitynumber-channel-src-miniquake-protocol-transients-ml-7686704"></a>
### packSoundChannel

```ml
function packSoundChannel(entityNumber, channel)
```

Implements the `packSoundChannel` operation for `miniquake.protocol_transients` (pack sound channel).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `packSoundChannel`. |
| `channel` | `dynamic` | — | The channel input consumed by `packSoundChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L101)

<a id="function-function-miniquake-protocol-transients-quakecsoundattenuation-function-quakecsoundattenuation-value-src-miniquake-protocol-transients-ml-2052644140"></a>
### quakeCSoundAttenuation

```ml
function quakeCSoundAttenuation(value)
```

Implements the `quakeCSoundAttenuation` operation for `miniquake.protocol_transients` (quake c sound attenuation).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `quakeCSoundAttenuation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L239)

<a id="function-function-miniquake-protocol-transients-quakecsoundchannel-function-quakecsoundchannel-value-src-miniquake-protocol-transients-ml-580743716"></a>
### quakeCSoundChannel

```ml
function quakeCSoundChannel(value)
```

PF_sound receives QuakeC floats.  The multiplication by 255 is performed as binary32 before assignment to C int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `quakeCSoundChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L227)

<a id="function-function-miniquake-protocol-transients-quakecsoundvolumebyte-function-quakecsoundvolumebyte-value-src-miniquake-protocol-transients-ml-1649673450"></a>
### quakeCSoundVolumeByte

```ml
function quakeCSoundVolumeByte(value)
```

Return quake csound volume byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `quakeCSoundVolumeByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L233)

<a id="function-function-miniquake-protocol-transients-soundattenuationbyte-function-soundattenuationbyte-attenuation-src-miniquake-protocol-transients-ml-1365475241"></a>
### soundAttenuationByte

```ml
function soundAttenuationByte(attenuation)
```

Return sound attenuation byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `soundAttenuationByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L42)

<a id="function-function-miniquake-protocol-transients-soundcenter-function-soundcenter-origin-minimum-maximum-src-miniquake-protocol-transients-ml-819187403"></a>
### soundCenter

```ml
function soundCenter(origin, minimum, maximum)
```

Implements the `soundCenter` operation for `miniquake.protocol_transients` (sound center).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L62)

<a id="function-function-miniquake-protocol-transients-soundcentercomponent-function-soundcentercomponent-origin-minimum-maximum-src-miniquake-protocol-transients-ml-186646663"></a>
### soundCenterComponent

```ml
function soundCenterComponent(origin, minimum, maximum)
```

SV_StartSound computes origin + 0.5 * (mins + maxs), then converts the result to MSG_WriteCoord's float parameter.  Keep both binary32 boundaries explicit rather than allowing MiniLang's wider arithmetic to leak into the Protocol-15 coordinate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L53)

<a id="function-function-miniquake-protocol-transients-soundchannel-function-soundchannel-packedchannel-src-miniquake-protocol-transients-ml-344640862"></a>
### soundChannel

```ml
function soundChannel(packedChannel)
```

Implements the `soundChannel` operation for `miniquake.protocol_transients` (sound channel).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `packedChannel` | `dynamic` | — | The packed channel input consumed by `soundChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L220)

<a id="function-function-miniquake-protocol-transients-soundentity-function-soundentity-packedchannel-src-miniquake-protocol-transients-ml-208978446"></a>
### soundEntity

```ml
function soundEntity(packedChannel)
```

Implements the `soundEntity` operation for `miniquake.protocol_transients` (sound entity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `packedChannel` | `dynamic` | — | The packed channel input consumed by `soundEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L214)

<a id="function-function-miniquake-protocol-transients-soundfieldmask-function-soundfieldmask-volume-attenuation-src-miniquake-protocol-transients-ml-1982047483"></a>
### soundFieldMask

```ml
function soundFieldMask(volume, attenuation)
```

Implements the `soundFieldMask` operation for `miniquake.protocol_transients` (sound field mask).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `volume` | `dynamic` | — | The volume input consumed by `soundFieldMask`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `soundFieldMask`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L73)

<a id="function-function-miniquake-protocol-transients-staticsoundattenuation-function-staticsoundattenuation-attenuationbyte-src-miniquake-protocol-transients-ml-27139523"></a>
### staticSoundAttenuation

```ml
function staticSoundAttenuation(attenuationByte)
```

Implements the `staticSoundAttenuation` operation for `miniquake.protocol_transients` (static sound attenuation).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `attenuationByte` | `dynamic` | — | The attenuation byte input consumed by `staticSoundAttenuation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L269)

<a id="function-function-miniquake-protocol-transients-staticsoundvolume-function-staticsoundvolume-volumebyte-src-miniquake-protocol-transients-ml-374221469"></a>
### staticSoundVolume

```ml
function staticSoundVolume(volumeByte)
```

Implements the `staticSoundVolume` operation for `miniquake.protocol_transients` (static sound volume).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `volumeByte` | `dynamic` | — | The volume byte input consumed by `staticSoundVolume`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L259)

<a id="constant-constant-miniquake-protocol-transients-temp-kind-beam-const-temp-kind-beam-2-src-miniquake-protocol-transients-ml-540365530"></a>
### TEMP_KIND_BEAM

```ml
const TEMP_KIND_BEAM = 2
```

Defines the temp kind beam value used by `miniquake.protocol_transients`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L21)

<a id="constant-constant-miniquake-protocol-transients-temp-kind-explosion2-const-temp-kind-explosion2-3-src-miniquake-protocol-transients-ml-2056024951"></a>
### TEMP_KIND_EXPLOSION2

```ml
const TEMP_KIND_EXPLOSION2 = 3
```

Defines the temp kind explosion2 value used by `miniquake.protocol_transients`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L23)

<a id="constant-constant-miniquake-protocol-transients-temp-kind-point-const-temp-kind-point-1-src-miniquake-protocol-transients-ml-1418622173"></a>
### TEMP_KIND_POINT

```ml
const TEMP_KIND_POINT = 1
```

Defines the temp kind point value used by `miniquake.protocol_transients`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L19)

<a id="function-function-miniquake-protocol-transients-tempkind-function-tempkind-type-src-miniquake-protocol-transients-ml-1585451019"></a>
### tempKind

```ml
function tempKind(type)
```

Implements the `tempKind` operation for `miniquake.protocol_transients` (temp kind).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `tempKind`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L132)

<a id="function-function-miniquake-protocol-transients-tempwiresize-function-tempwiresize-type-src-miniquake-protocol-transients-ml-1030390143"></a>
### tempWireSize

```ml
function tempWireSize(type)
```

Return temp wire size derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `dynamic` | — | The type input consumed by `tempWireSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L141)

<a id="function-function-miniquake-protocol-transients-updatecompactbeamlist-function-updatecompactbeamlist-beams-value-currenttime-src-miniquake-protocol-transients-ml-940329736"></a>
### updateCompactBeamList

```ml
function updateCompactBeamList(beams, value, currentTime)
```

Update module state for compact beam list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `updateCompactBeamList`. |
| `value` | `dynamic` | — | Value consumed by `updateCompactBeamList`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L438)

<a id="function-function-miniquake-protocol-transients-updatecompactbeamlistresult-function-updatecompactbeamlistresult-beams-value-currenttime-src-miniquake-protocol-transients-ml-735505890"></a>
### updateCompactBeamListResult

```ml
function updateCompactBeamListResult(beams, value, currentTime)
```

Update module state for compact beam list result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beams` | `dynamic` | — | The beams input consumed by `updateCompactBeamListResult`. |
| `value` | `dynamic` | — | Value consumed by `updateCompactBeamListResult`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L396)

<a id="function-function-miniquake-protocol-transients-writebeam-function-writebeam-buffer-type-entitynumber-startposition-endposition-src-miniquake-protocol-transients-ml-645122256"></a>
### writeBeam

```ml
function writeBeam(buffer, type, entityNumber, startPosition, endPosition)
```

Encode and write beam.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeBeam`. |
| `type` | `dynamic` | — | The type input consumed by `writeBeam`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `writeBeam`. |
| `startPosition` | `dynamic` | — | The start position input consumed by `writeBeam`. |
| `endPosition` | `dynamic` | — | The end position input consumed by `writeBeam`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L169)

<a id="function-function-miniquake-protocol-transients-writeexplosion2-function-writeexplosion2-buffer-origin-colorstart-colorlength-src-miniquake-protocol-transients-ml-1695085093"></a>
### writeExplosion2

```ml
function writeExplosion2(buffer, origin, colorStart, colorLength)
```

Encode and write explosion2.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeExplosion2`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `colorStart` | `dynamic` | — | The color start input consumed by `writeExplosion2`. |
| `colorLength` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L189)

<a id="function-function-miniquake-protocol-transients-writepoint-function-writepoint-buffer-type-origin-src-miniquake-protocol-transients-ml-735521703"></a>
### writePoint

```ml
function writePoint(buffer, type, origin)
```

Encode and write point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writePoint`. |
| `type` | `dynamic` | — | The type input consumed by `writePoint`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L152)

<a id="function-function-miniquake-protocol-transients-writereconnect-function-writereconnect-buffer-src-miniquake-protocol-transients-ml-1695516217"></a>
### writeReconnect

```ml
function writeReconnect(buffer)
```

Encode and write reconnect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeReconnect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L444)

<a id="function-function-miniquake-protocol-transients-writestopsound-function-writestopsound-buffer-entitynumber-channel-src-miniquake-protocol-transients-ml-238293282"></a>
### writeStopSound

```ml
function writeStopSound(buffer, entityNumber, channel)
```

Encode and write stop sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeStopSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `writeStopSound`. |
| `channel` | `dynamic` | — | The channel input consumed by `writeStopSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_transients.ml#L205)
