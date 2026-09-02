# `src/miniquake/crc.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.crc`](Package-miniquake-crc-1393972587.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-miniquake-crc-block-function-block-data-offset-count-src-miniquake-crc-ml-1159151129"></a>
### block

```ml
function block(data, offset, count)
```

Implements the `block` operation for `miniquake.crc` (block).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L75)

<a id="function-function-miniquake-crc-crc-block-function-crc-block-data-offset-count-src-miniquake-crc-ml-442714779"></a>
### CRC_Block

```ml
function CRC_Block(data, offset, count)
```

Compute crc block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L50)

<a id="function-function-miniquake-crc-crc-init-inline-function-crc-init-src-miniquake-crc-ml-1255552132"></a>
### CRC_Init

```ml
inline function CRC_Init()
```

Compute crc init.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L18)

<a id="constant-constant-miniquake-crc-crc-init-value-const-crc-init-value-65535-src-miniquake-crc-ml-3412360"></a>
### CRC_INIT_VALUE

```ml
const CRC_INIT_VALUE = 65535
```

Defines the crc init value value used by `miniquake.crc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L11)

<a id="constant-constant-miniquake-crc-crc-polynomial-const-crc-polynomial-4129-src-miniquake-crc-ml-386331488"></a>
### CRC_POLYNOMIAL

```ml
const CRC_POLYNOMIAL = 4129
```

Defines the crc polynomial value used by `miniquake.crc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L15)

<a id="function-function-miniquake-crc-crc-processbyte-function-crc-processbyte-crcvalue-data-src-miniquake-crc-ml-65695816"></a>
### CRC_ProcessByte

```ml
function CRC_ProcessByte(crcValue, data)
```

crc.c uses a 256-entry lookup table.  This bitwise form produces that exact non-reflected CCITT transition while retaining unsigned-short truncation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `crcValue` | `dynamic` | — | The crc value input consumed by `CRC_ProcessByte`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L26)

<a id="function-function-miniquake-crc-crc-value-function-crc-value-crcvalue-src-miniquake-crc-ml-384097260"></a>
### CRC_Value

```ml
function CRC_Value(crcValue)
```

Compute crc value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `crcValue` | `dynamic` | — | The crc value input consumed by `CRC_Value`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L42)

<a id="constant-constant-miniquake-crc-crc-xor-value-const-crc-xor-value-0-src-miniquake-crc-ml-927178472"></a>
### CRC_XOR_VALUE

```ml
const CRC_XOR_VALUE = 0
```

Defines the crc xor value value used by `miniquake.crc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L13)

<a id="function-function-miniquake-crc-processbyte-function-processbyte-value-data-src-miniquake-crc-ml-2036138578"></a>
### processByte

```ml
function processByte(value, data)
```

Existing idiomatic aliases retained for already-ported callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `processByte`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/crc.ml#L67)
