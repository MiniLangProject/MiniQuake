# `src/miniquake/sizebuf.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sizebuf`](Package-miniquake-sizebuf-1449841663.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/memory.ml` as `memory` → [src/miniquake/memory.ml](File-src-miniquake-memory-ml-37601647.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-sizebuf-alloc-function-alloc-maxsize-src-miniquake-sizebuf-ml-605484072"></a>
### alloc

```ml
function alloc(maxSize)
```

Create and initialize the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L17)

<a id="function-function-miniquake-sizebuf-allochunk-function-allochunk-startsize-src-miniquake-sizebuf-ml-416883110"></a>
### allocHunk

```ml
function allocHunk(startSize)
```

Create and initialize hunk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L24)

<a id="function-function-miniquake-sizebuf-allochunkmanaged-function-allochunkmanaged-memorystate-startsize-src-miniquake-sizebuf-ml-145393814"></a>
### allocHunkManaged

```ml
function allocHunkManaged(memoryState, startSize)
```

Create and initialize hunk managed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `memoryState` | `dynamic` | — | Mutable state used by `allocHunkManaged`. |
| `startSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L32)

<a id="function-function-miniquake-sizebuf-allocoverflowing-function-allocoverflowing-maxsize-src-miniquake-sizebuf-ml-852865322"></a>
### allocOverflowing

```ml
function allocOverflowing(maxSize)
```

Create and initialize overflowing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L41)

<a id="function-function-miniquake-sizebuf-clear-function-clear-buffer-src-miniquake-sizebuf-ml-35406863"></a>
### clear

```ml
function clear(buffer)
```

Implements the `clear` operation for `miniquake.sizebuf` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `clear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L49)

<a id="function-function-miniquake-sizebuf-dataslice-function-dataslice-buffer-src-miniquake-sizebuf-ml-1958464169"></a>
### dataSlice

```ml
function dataSlice(buffer)
```

Implements the `dataSlice` operation for `miniquake.sizebuf` (data slice).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `dataSlice`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L145)

<a id="function-function-miniquake-sizebuf-free-function-free-buffer-src-miniquake-sizebuf-ml-101168377"></a>
### free

```ml
function free(buffer)
```

Implements the `free` operation for `miniquake.sizebuf` (free).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `free`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L56)

<a id="function-function-miniquake-sizebuf-getspace-function-getspace-buffer-count-src-miniquake-sizebuf-ml-1292443592"></a>
### getSpace

```ml
function getSpace(buffer, count)
```

Return space.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `getSpace`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L66)

<a id="function-function-miniquake-sizebuf-printtext-function-printtext-buffer-text-src-miniquake-sizebuf-ml-1024526598"></a>
### printText

```ml
function printText(buffer, text)
```

Format and emit text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `printText`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L111)

<a id="function-function-miniquake-sizebuf-sz-alloc-function-sz-alloc-startsize-src-miniquake-sizebuf-ml-534709540"></a>
### SZ_Alloc

```ml
function SZ_Alloc(startSize)
```

Direct pendants for the size-buffer section of WinQuake/common.c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L151)

<a id="function-function-miniquake-sizebuf-sz-clear-function-sz-clear-buffer-src-miniquake-sizebuf-ml-1207112237"></a>
### SZ_Clear

```ml
function SZ_Clear(buffer)
```

Mirror Quake's SZ_Clear routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `SZ_Clear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L163)

<a id="function-function-miniquake-sizebuf-sz-free-function-sz-free-buffer-src-miniquake-sizebuf-ml-1812942617"></a>
### SZ_Free

```ml
function SZ_Free(buffer)
```

Mirror Quake's SZ_Free routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `SZ_Free`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L157)

<a id="function-function-miniquake-sizebuf-sz-getspace-function-sz-getspace-buffer-count-src-miniquake-sizebuf-ml-2055667736"></a>
### SZ_GetSpace

```ml
function SZ_GetSpace(buffer, count)
```

Mirror Quake's SZ_GetSpace routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `SZ_GetSpace`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L170)

<a id="function-function-miniquake-sizebuf-sz-print-function-sz-print-buffer-text-src-miniquake-sizebuf-ml-662754878"></a>
### SZ_Print

```ml
function SZ_Print(buffer, text)
```

Mirror Quake's SZ_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `SZ_Print`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L186)

<a id="function-function-miniquake-sizebuf-sz-write-function-sz-write-buffer-source-sourceoffset-count-src-miniquake-sizebuf-ml-1687213501"></a>
### SZ_Write

```ml
function SZ_Write(buffer, source, sourceOffset, count)
```

Mirror Quake's SZ_Write routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `SZ_Write`. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `sourceOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L179)

<a id="function-function-miniquake-sizebuf-write-function-write-buffer-source-sourceoffset-count-src-miniquake-sizebuf-ml-1571713047"></a>
### write

```ml
function write(buffer, source, sourceOffset, count)
```

Implements the `write` operation for `miniquake.sizebuf` (write).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `write`. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `sourceOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L84)

<a id="function-function-miniquake-sizebuf-writebytes-function-writebytes-buffer-source-src-miniquake-sizebuf-ml-1923415308"></a>
### writeBytes

```ml
function writeBytes(buffer, source)
```

Writes bytes for `miniquake.sizebuf`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeBytes`. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L93)

<a id="function-function-miniquake-sizebuf-writeencodedcstringat-function-writeencodedcstringat-buffer-encoded-count-offset-src-miniquake-sizebuf-ml-1188045127"></a>
### writeEncodedCStringAt

```ml
function writeEncodedCStringAt(buffer, encoded, count, offset)
```

Encode and write encoded cstring at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeEncodedCStringAt`. |
| `encoded` | `dynamic` | — | The encoded input consumed by `writeEncodedCStringAt`. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sizebuf.ml#L102)
