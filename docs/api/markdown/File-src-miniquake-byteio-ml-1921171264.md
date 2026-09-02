# `src/miniquake/byteio.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.byteio`](Package-miniquake-byteio-20919217.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `quakeText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)

## Declarations

<a id="function-function-miniquake-byteio-bigfloat-function-bigfloat-value-src-miniquake-byteio-ml-1619635500"></a>
### bigFloat

```ml
function bigFloat(value)
```

Convert byte order for big float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `bigFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L225)

<a id="function-function-miniquake-byteio-biglong-function-biglong-value-src-miniquake-byteio-ml-2110941192"></a>
### bigLong

```ml
function bigLong(value)
```

Convert byte order for big long.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `bigLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L213)

<a id="function-function-miniquake-byteio-bigshort-function-bigshort-value-src-miniquake-byteio-ml-2140299280"></a>
### bigShort

```ml
function bigShort(value)
```

MiniQuake's supported release platform is little-endian Windows x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `bigShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L201)

<a id="function-function-miniquake-byteio-copyinto-function-copyinto-destination-destinationoffset-source-sourceoffset-count-src-miniquake-byteio-ml-1822958818"></a>
### copyInto

```ml
function copyInto(destination, destinationOffset, source, sourceOffset, count)
```

Transfer data for copy into.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `destinationOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `sourceOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L241)

<a id="function-function-miniquake-byteio-cstring-function-cstring-data-offset-src-miniquake-byteio-ml-524791540"></a>
### cString

```ml
function cString(data, offset)
```

Implements the `cString` operation for `miniquake.byteio` (c string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L268)

<a id="function-function-miniquake-byteio-equalinsensitive-function-equalinsensitive-a-b-src-miniquake-byteio-ml-44320720"></a>
### equalInsensitive

```ml
function equalInsensitive(a, b)
```

Check equal insensitive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `equalInsensitive`. |
| `b` | `dynamic` | — | The b input consumed by `equalInsensitive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L295)

<a id="function-function-miniquake-byteio-f32-inline-function-f32-data-offset-src-miniquake-byteio-ml-1903142509"></a>
### f32

```ml
inline function f32(data, offset)
```

Read an IEEE-754 single-precision value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L82)

<a id="function-function-miniquake-byteio-fixedstring-function-fixedstring-data-offset-count-src-miniquake-byteio-ml-26711731"></a>
### fixedString

```ml
function fixedString(data, offset, count)
```

Implements the `fixedString` operation for `miniquake.byteio` (fixed string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L256)

<a id="function-function-miniquake-byteio-floatnoswap-function-floatnoswap-value-src-miniquake-byteio-ml-629294464"></a>
### floatNoSwap

```ml
function floatNoSwap(value)
```

Convert byte order for float no swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floatNoSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L195)

<a id="function-function-miniquake-byteio-floatswap-function-floatswap-value-src-miniquake-byteio-ml-1402397950"></a>
### floatSwap

```ml
function floatSwap(value)
```

Convert byte order for float swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floatSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L189)

<a id="function-function-miniquake-byteio-fourcc-function-fourcc-data-offset-src-miniquake-byteio-ml-523885516"></a>
### fourCC

```ml
function fourCC(data, offset)
```

Implements the `fourCC` operation for `miniquake.byteio` (four cc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L302)

<a id="function-function-miniquake-byteio-i16-inline-function-i16-data-offset-src-miniquake-byteio-ml-1170054489"></a>
### i16

```ml
inline function i16(data, offset)
```

Read a little-endian signed 16-bit value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L53)

<a id="function-function-miniquake-byteio-i32-function-i32-data-offset-src-miniquake-byteio-ml-410456708"></a>
### i32

```ml
function i32(data, offset)
```

Read a little-endian signed 32-bit value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L73)

<a id="function-function-miniquake-byteio-i8-inline-function-i8-data-offset-src-miniquake-byteio-ml-879218253"></a>
### i8

```ml
inline function i8(data, offset)
```

Read a signed 8-bit value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L36)

<a id="function-function-miniquake-byteio-littlefloat-function-littlefloat-value-src-miniquake-byteio-ml-1992741160"></a>
### littleFloat

```ml
function littleFloat(value)
```

Convert byte order for little float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `littleFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L231)

<a id="function-function-miniquake-byteio-littlelong-function-littlelong-value-src-miniquake-byteio-ml-1255103304"></a>
### littleLong

```ml
function littleLong(value)
```

Convert byte order for little long.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `littleLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L219)

<a id="function-function-miniquake-byteio-littleshort-function-littleshort-value-src-miniquake-byteio-ml-1597862652"></a>
### littleShort

```ml
function littleShort(value)
```

Convert byte order for little short.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `littleShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L207)

<a id="function-function-miniquake-byteio-longnoswap-function-longnoswap-value-src-miniquake-byteio-ml-700931320"></a>
### longNoSwap

```ml
function longNoSwap(value)
```

Convert byte order for long no swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `longNoSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L181)

<a id="function-function-miniquake-byteio-longswap-function-longswap-value-src-miniquake-byteio-ml-903767360"></a>
### longSwap

```ml
function longSwap(value)
```

Convert byte order for long swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `longSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L170)

<a id="function-function-miniquake-byteio-lower-function-lower-text-src-miniquake-byteio-ml-68768918"></a>
### lower

```ml
function lower(text)
```

Convert data for lower.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L279)

<a id="function-function-miniquake-byteio-putf32-inline-function-putf32-data-offset-value-src-miniquake-byteio-ml-1088564254"></a>
### putF32

```ml
inline function putF32(data, offset, value)
```

Encode and write f32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putF32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L148)

<a id="function-function-miniquake-byteio-puti16-inline-function-puti16-data-offset-value-src-miniquake-byteio-ml-1563674460"></a>
### putI16

```ml
inline function putI16(data, offset, value)
```

Encode and write i16.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putI16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L119)

<a id="function-function-miniquake-byteio-puti32-function-puti32-data-offset-value-src-miniquake-byteio-ml-600079011"></a>
### putI32

```ml
function putI32(data, offset, value)
```

Encode and write i32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putI32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L140)

<a id="function-function-miniquake-byteio-puti8-inline-function-puti8-data-offset-value-src-miniquake-byteio-ml-1011468216"></a>
### putI8

```ml
inline function putI8(data, offset, value)
```

Encode and write i8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putI8`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L100)

<a id="function-function-miniquake-byteio-putu16-inline-function-putu16-data-offset-value-src-miniquake-byteio-ml-1508995380"></a>
### putU16

```ml
inline function putU16(data, offset, value)
```

Encode and write u16.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putU16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L108)

<a id="function-function-miniquake-byteio-putu32-function-putu32-data-offset-value-src-miniquake-byteio-ml-936532475"></a>
### putU32

```ml
function putU32(data, offset, value)
```

Encode and write u32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putU32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L127)

<a id="function-function-miniquake-byteio-putu8-inline-function-putu8-data-offset-value-src-miniquake-byteio-ml-804498664"></a>
### putU8

```ml
inline function putU8(data, offset, value)
```

Encode and write u8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `putU8`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L90)

<a id="function-function-miniquake-byteio-requirerange-function-requirerange-data-offset-count-src-miniquake-byteio-ml-1500453737"></a>
### requireRange

```ml
function requireRange(data, offset, count)
```

Validate range and report any invalid state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L17)

<a id="function-function-miniquake-byteio-shortnoswap-function-shortnoswap-value-src-miniquake-byteio-ml-1985346012"></a>
### shortNoSwap

```ml
function shortNoSwap(value)
```

Convert byte order for short no swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `shortNoSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L162)

<a id="function-function-miniquake-byteio-shortswap-function-shortswap-value-src-miniquake-byteio-ml-941938022"></a>
### shortSwap

```ml
function shortSwap(value)
```

Convert byte order for short swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `shortSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L154)

<a id="function-function-miniquake-byteio-u16-inline-function-u16-data-offset-src-miniquake-byteio-ml-1044372081"></a>
### u16

```ml
inline function u16(data, offset)
```

Read a little-endian unsigned 16-bit value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L45)

<a id="function-function-miniquake-byteio-u32-function-u32-data-offset-src-miniquake-byteio-ml-1164957204"></a>
### u32

```ml
function u32(data, offset)
```

Read a little-endian unsigned 32-bit value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L62)

<a id="function-function-miniquake-byteio-u8-inline-function-u8-data-offset-src-miniquake-byteio-ml-1050237085"></a>
### u8

```ml
inline function u8(data, offset)
```

Read an unsigned 8-bit value from the byte buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/byteio.ml#L28)
