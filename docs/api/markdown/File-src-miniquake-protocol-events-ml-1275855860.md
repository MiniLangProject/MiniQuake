# `src/miniquake/protocol_events.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_events`](Package-miniquake-protocol-events-1741573693.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-protocol-events-canwritetransient-function-canwritetransient-buffer-src-miniquake-protocol-events-ml-904674311"></a>
### canWriteTransient

```ml
function canWriteTransient(buffer)
```

SV_StartParticle and SV_StartSound share the historical 16-byte preflight. Equality is accepted; only cursize > MAX_DATAGRAM-16 is rejected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `canWriteTransient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L38)

<a id="function-function-miniquake-protocol-events-cfloat-function-cfloat-value-src-miniquake-protocol-events-ml-1199918372"></a>
### cFloat

```ml
function cFloat(value)
```

Implements the `cFloat` operation for `miniquake.protocol_events` (c float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `cFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L24)

<a id="function-function-miniquake-protocol-events-cfloatproduct-function-cfloatproduct-left-right-src-miniquake-protocol-events-ml-1909801596"></a>
### cFloatProduct

```ml
function cFloatProduct(left, right)
```

Implements the `cFloatProduct` operation for `miniquake.protocol_events` (c float product).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `cFloatProduct`. |
| `right` | `dynamic` | — | The right input consumed by `cFloatProduct`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L31)

<a id="function-function-miniquake-protocol-events-fragchanged-function-fragchanged-oldfrags-currentfrags-src-miniquake-protocol-events-ml-661768899"></a>
### fragChanged

```ml
function fragChanged(oldFrags, currentFrags)
```

Implements the `fragChanged` operation for `miniquake.protocol_events` (frag changed).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `oldFrags` | `dynamic` | — | The old frags input consumed by `fragChanged`. |
| `currentFrags` | `dynamic` | — | The current frags input consumed by `fragChanged`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L225)

<a id="constant-constant-miniquake-protocol-events-max-player-name-bytes-const-max-player-name-bytes-15-src-miniquake-protocol-events-ml-2058836196"></a>
### MAX_PLAYER_NAME_BYTES

```ml
const MAX_PLAYER_NAME_BYTES = 15
```

Defines the max player name bytes value used by `miniquake.protocol_events`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L20)

<a id="function-function-miniquake-protocol-events-particlecount-function-particlecount-wirevalue-src-miniquake-protocol-events-ml-147666261"></a>
### particleCount

```ml
function particleCount(wireValue)
```

R_ParseParticleEffect expands the special wire value 255 to 1024 particles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wireValue` | `dynamic` | — | The wire value input consumed by `particleCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L144)

<a id="function-function-miniquake-protocol-events-particledirectionbyte-function-particledirectionbyte-value-src-miniquake-protocol-events-ml-1591066498"></a>
### particleDirectionByte

```ml
function particleDirectionByte(value)
```

Return particle direction byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `particleDirectionByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L115)

<a id="function-function-miniquake-protocol-events-staticsoundattenuationbyte-function-staticsoundattenuationbyte-attenuation-src-miniquake-protocol-events-ml-1720853153"></a>
### staticSoundAttenuationByte

```ml
function staticSoundAttenuationByte(attenuation)
```

Return static sound attenuation byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `staticSoundAttenuationByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L91)

<a id="function-function-miniquake-protocol-events-staticsoundvolumebyte-function-staticsoundvolumebyte-volume-src-miniquake-protocol-events-ml-320795087"></a>
### staticSoundVolumeByte

```ml
function staticSoundVolumeByte(volume)
```

Return static sound volume byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `volume` | `dynamic` | — | The volume input consumed by `staticSoundVolumeByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L83)

<a id="function-function-miniquake-protocol-events-storedfrag-function-storedfrag-currentfrags-src-miniquake-protocol-events-ml-1131004501"></a>
### storedFrag

```ml
function storedFrag(currentFrags)
```

Implements the `storedFrag` operation for `miniquake.protocol_events` (stored frag).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentFrags` | `dynamic` | — | The current frags input consumed by `storedFrag`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L234)

<a id="function-function-miniquake-protocol-events-truncateplayername-function-truncateplayername-text-src-miniquake-protocol-events-ml-1902478356"></a>
### truncatePlayerName

```ml
function truncatePlayerName(text)
```

Return truncate player name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L152)

<a id="function-function-miniquake-protocol-events-writedisconnect-function-writedisconnect-buffer-src-miniquake-protocol-events-ml-1399208699"></a>
### writeDisconnect

```ml
function writeDisconnect(buffer)
```

Encode and write disconnect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeDisconnect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L216)

<a id="function-function-miniquake-protocol-events-writeparticle-function-writeparticle-buffer-origin-direction-count-color-src-miniquake-protocol-events-ml-1615096412"></a>
### writeParticle

```ml
function writeParticle(buffer, origin, direction, count, color)
```

Encode and write particle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeParticle`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `direction` | `dynamic` | — | The direction input consumed by `writeParticle`. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `color` | `dynamic` | — | Color value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L128)

<a id="function-function-miniquake-protocol-events-writescorereset-function-writescorereset-buffer-clientindex-src-miniquake-protocol-events-ml-754369466"></a>
### writeScoreReset

```ml
function writeScoreReset(buffer, clientIndex)
```

Encode and write score reset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeScoreReset`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L210)

<a id="function-function-miniquake-protocol-events-writescorestate-function-writescorestate-buffer-clientindex-name-oldfrags-colors-src-miniquake-protocol-events-ml-67435711"></a>
### writeScoreState

```ml
function writeScoreState(buffer, clientIndex, name, oldFrags, colors)
```

Encode and write score state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeScoreState`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `oldFrags` | `dynamic` | — | The old frags input consumed by `writeScoreState`. |
| `colors` | `dynamic` | — | The colors input consumed by `writeScoreState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L199)

<a id="function-function-miniquake-protocol-events-writespawnstatic-function-writespawnstatic-buffer-modelindex-frame-colormap-skin-origin-angles-src-miniquake-protocol-events-ml-253556415"></a>
### writeSpawnStatic

```ml
function writeSpawnStatic(buffer, modelIndex, frame, colormap, skin, origin, angles)
```

Encode and write spawn static.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeSpawnStatic`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frame` | `dynamic` | — | The frame input consumed by `writeSpawnStatic`. |
| `colormap` | `dynamic` | — | The colormap input consumed by `writeSpawnStatic`. |
| `skin` | `dynamic` | — | The skin input consumed by `writeSpawnStatic`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L50)

<a id="function-function-miniquake-protocol-events-writestaticentity-function-writestaticentity-buffer-baseline-src-miniquake-protocol-events-ml-664158570"></a>
### writeStaticEntity

```ml
function writeStaticEntity(buffer, baseline)
```

Encode and write static entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeStaticEntity`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `writeStaticEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L69)

<a id="function-function-miniquake-protocol-events-writestaticsound-function-writestaticsound-buffer-origin-soundindex-volume-attenuation-src-miniquake-protocol-events-ml-556728816"></a>
### writeStaticSound

```ml
function writeStaticSound(buffer, origin, soundIndex, volume, attenuation)
```

Encode and write static sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeStaticSound`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `soundIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `volume` | `dynamic` | — | The volume input consumed by `writeStaticSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `writeStaticSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L101)

<a id="function-function-miniquake-protocol-events-writeupdatecolors-function-writeupdatecolors-buffer-clientindex-colors-src-miniquake-protocol-events-ml-281130766"></a>
### writeUpdateColors

```ml
function writeUpdateColors(buffer, clientIndex, colors)
```

Encode and write update colors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeUpdateColors`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `colors` | `dynamic` | — | The colors input consumed by `writeUpdateColors`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L185)

<a id="function-function-miniquake-protocol-events-writeupdatefrags-function-writeupdatefrags-buffer-clientindex-frags-src-miniquake-protocol-events-ml-274120911"></a>
### writeUpdateFrags

```ml
function writeUpdateFrags(buffer, clientIndex, frags)
```

Encode and write update frags.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeUpdateFrags`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frags` | `dynamic` | — | The frags input consumed by `writeUpdateFrags`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L172)

<a id="function-function-miniquake-protocol-events-writeupdatename-function-writeupdatename-buffer-clientindex-name-src-miniquake-protocol-events-ml-1377047743"></a>
### writeUpdateName

```ml
function writeUpdateName(buffer, clientIndex, name)
```

Encode and write update name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeUpdateName`. |
| `clientIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_events.ml#L160)
