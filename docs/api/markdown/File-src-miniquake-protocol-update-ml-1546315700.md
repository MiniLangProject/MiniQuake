# `src/miniquake/protocol_update.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_update`](Package-miniquake-protocol-update-2066059621.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)

## Declarations

<a id="function-function-miniquake-protocol-update-absolute-function-absolute-value-src-miniquake-protocol-update-ml-1833445572"></a>
### absolute

```ml
function absolute(value)
```

Implements the `absolute` operation for `miniquake.protocol_update` (absolute).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absolute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L15)

<a id="function-function-miniquake-protocol-update-canwrite-function-canwrite-buffer-bits-src-miniquake-protocol-update-ml-979560745"></a>
### canWrite

```ml
function canWrite(buffer, bits)
```

Report whether can write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `canWrite`. |
| `bits` | `dynamic` | — | The bits input consumed by `canWrite`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L90)

<a id="function-function-miniquake-protocol-update-canwritewithreservedtail-function-canwritewithreservedtail-buffer-bits-reservedbytes-src-miniquake-protocol-update-ml-1431994872"></a>
### canWriteWithReservedTail

```ml
function canWriteWithReservedTail(buffer, bits, reservedBytes)
```

The stock server appends sv.datagram after fast entity updates. Under a dense PVS that can discard the complete transient tail, including gunshot puffs and explosions. Reserve the already-known tail while scheduling entity deltas; the strict '< maxSize' append boundary still applies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `canWriteWithReservedTail`. |
| `bits` | `dynamic` | — | The bits input consumed by `canWriteWithReservedTail`. |
| `reservedBytes` | `dynamic` | — | Byte data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L103)

<a id="function-function-miniquake-protocol-update-computebits-function-computebits-entitynumber-baseline-modelindex-frame-colormap-skin-effects-origin-angles-movetype-src-miniquake-protocol-update-ml-289533791"></a>
### computeBits

```ml
function computeBits(entityNumber, baseline, modelIndex, frame, colormap, skin, effects, origin, angles, moveType)
```

Exact Protocol-15 bit selection from WinQuake sv_main.c: SV_WriteEntitiesToClient.  The entity-state baseline includes effects even though svc_spawnbaseline does not transmit it; SV_CreateBaseline leaves that field at zero in the original zero-initialized edict baseline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `computeBits`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `computeBits`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frame` | `dynamic` | — | The frame input consumed by `computeBits`. |
| `colormap` | `dynamic` | — | The colormap input consumed by `computeBits`. |
| `skin` | `dynamic` | — | The skin input consumed by `computeBits`. |
| `effects` | `dynamic` | — | The effects input consumed by `computeBits`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `moveType` | `dynamic` | — | The move type input consumed by `computeBits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L34)

<a id="function-function-miniquake-protocol-update-encodedsize-function-encodedsize-bits-src-miniquake-protocol-update-ml-212865445"></a>
### encodedSize

```ml
function encodedSize(bits)
```

Exact byte count for one Protocol-15 fast entity update. The original SV_WriteEntitiesToClient used a fixed 16-byte preflight even though the theoretical long-entity maximum is 18 bytes. MiniQuake preserves the original 16-byte scheduling gate and adds this exact memory-safety check.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `dynamic` | — | The bits input consumed by `encodedSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L69)

<a id="function-function-miniquake-protocol-update-writefastupdate-function-writefastupdate-buffer-entitynumber-baseline-modelindex-frame-colormap-skin-effects-origin-angles-movetype-src-miniquake-protocol-update-ml-1148451383"></a>
### writeFastUpdate

```ml
function writeFastUpdate(buffer, entityNumber, baseline, modelIndex, frame, colormap, skin, effects, origin, angles, moveType)
```

Encode and write fast update.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeFastUpdate`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `writeFastUpdate`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `writeFastUpdate`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frame` | `dynamic` | — | The frame input consumed by `writeFastUpdate`. |
| `colormap` | `dynamic` | — | The colormap input consumed by `writeFastUpdate`. |
| `skin` | `dynamic` | — | The skin input consumed by `writeFastUpdate`. |
| `effects` | `dynamic` | — | The effects input consumed by `writeFastUpdate`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `moveType` | `dynamic` | — | The move type input consumed by `writeFastUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L166)

<a id="function-function-miniquake-protocol-update-writefastupdatebits-function-writefastupdatebits-buffer-bits-entitynumber-modelindex-frame-colormap-skin-effects-origin-angles-src-miniquake-protocol-update-ml-2131109369"></a>
### writeFastUpdateBits

```ml
function writeFastUpdateBits(buffer, bits, entityNumber, modelIndex, frame, colormap, skin, effects, origin, angles)
```

Encode and write fast update bits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeFastUpdateBits`. |
| `bits` | `dynamic` | — | The bits input consumed by `writeFastUpdateBits`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `writeFastUpdateBits`. |
| `modelIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `frame` | `dynamic` | — | The frame input consumed by `writeFastUpdateBits`. |
| `colormap` | `dynamic` | — | The colormap input consumed by `writeFastUpdateBits`. |
| `skin` | `dynamic` | — | The skin input consumed by `writeFastUpdateBits`. |
| `effects` | `dynamic` | — | The effects input consumed by `writeFastUpdateBits`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_update.ml#L121)
