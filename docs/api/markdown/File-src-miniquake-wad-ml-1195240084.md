# `src/miniquake/wad.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.wad`](Package-miniquake-wad-1737918613.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/protocol_text.ml` as `quakeText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-wad-cleanupnametext-function-cleanupnametext-input-src-miniquake-wad-ml-1452212525"></a>
### cleanupNameText

```ml
function cleanupNameText(input)
```

Implements the `cleanupNameText` operation for `miniquake.wad` (cleanup name text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `cleanupNameText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L68)

<a id="constant-constant-miniquake-wad-cmp-lzss-const-cmp-lzss-1-src-miniquake-wad-ml-74934829"></a>
### CMP_LZSS

```ml
const CMP_LZSS = 1
```

Defines the cmp lzss value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L20)

<a id="constant-constant-miniquake-wad-cmp-none-const-cmp-none-0-src-miniquake-wad-ml-715139552"></a>
### CMP_NONE

```ml
const CMP_NONE = 0
```

Defines the cmp none value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L18)

<a id="function-function-miniquake-wad-find-function-find-archive-name-src-miniquake-wad-ml-679703804"></a>
### find

```ml
function find(archive, name)
```

Implements the `find` operation for `miniquake.wad` (find).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `find`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L193)

<a id="function-function-miniquake-wad-load-function-load-filename-src-miniquake-wad-ml-1084803598"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.wad` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L186)

<a id="function-function-miniquake-wad-parse-function-parse-data-filename-src-miniquake-wad-ml-1445996404"></a>
### parse

```ml
function parse(data, filename)
```

Existing idiomatic API retained for callers already ported to MiniLang.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L180)

<a id="function-function-miniquake-wad-picturedimensions-function-picturedimensions-archive-name-src-miniquake-wad-ml-680134662"></a>
### pictureDimensions

```ml
function pictureDimensions(archive, name)
```

Implements the `pictureDimensions` operation for `miniquake.wad` (picture dimensions).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `pictureDimensions`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L213)

<a id="function-function-miniquake-wad-readlump-function-readlump-archive-name-src-miniquake-wad-ml-1990528168"></a>
### readLump

```ml
function readLump(archive, name)
```

Read and validate lump.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `readLump`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L204)

<a id="function-function-miniquake-wad-swappic-function-swappic-data-offset-src-miniquake-wad-ml-832176510"></a>
### SwapPic

```ml
function SwapPic(data, offset)
```

SwapPic performs the two LittleLong conversions from the original.  The supported Windows x64 build is little-endian, but writing the decoded values back makes the operation explicit and keeps the observable in-place API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L82)

<a id="constant-constant-miniquake-wad-typ-label-const-typ-label-1-src-miniquake-wad-ml-586792397"></a>
### TYP_LABEL

```ml
const TYP_LABEL = 1
```

Defines the typ label value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L25)

<a id="constant-constant-miniquake-wad-typ-lumpy-const-typ-lumpy-64-src-miniquake-wad-ml-1983455924"></a>
### TYP_LUMPY

```ml
const TYP_LUMPY = 64
```

Defines the typ lumpy value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L27)

<a id="constant-constant-miniquake-wad-typ-miptex-const-typ-miptex-68-src-miniquake-wad-ml-804343940"></a>
### TYP_MIPTEX

```ml
const TYP_MIPTEX = 68
```

Defines the typ miptex value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L37)

<a id="constant-constant-miniquake-wad-typ-none-const-typ-none-0-src-miniquake-wad-ml-1765018762"></a>
### TYP_NONE

```ml
const TYP_NONE = 0
```

Defines the typ none value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L23)

<a id="constant-constant-miniquake-wad-typ-palette-const-typ-palette-64-src-miniquake-wad-ml-1962142800"></a>
### TYP_PALETTE

```ml
const TYP_PALETTE = 64
```

Defines the typ palette value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L29)

<a id="constant-constant-miniquake-wad-typ-qpic-const-typ-qpic-66-src-miniquake-wad-ml-1059451798"></a>
### TYP_QPIC

```ml
const TYP_QPIC = 66
```

Defines the typ qpic value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L33)

<a id="constant-constant-miniquake-wad-typ-qtex-const-typ-qtex-65-src-miniquake-wad-ml-1053336283"></a>
### TYP_QTEX

```ml
const TYP_QTEX = 65
```

Defines the typ qtex value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L31)

<a id="constant-constant-miniquake-wad-typ-sound-const-typ-sound-67-src-miniquake-wad-ml-152819403"></a>
### TYP_SOUND

```ml
const TYP_SOUND = 67
```

Defines the typ sound value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L35)

<a id="function-function-miniquake-wad-w-cleanupname-function-w-cleanupname-input-src-miniquake-wad-ml-1109535987"></a>
### W_CleanupName

```ml
function W_CleanupName(input)
```

W_CleanupName lowercases only ASCII A-Z, stops at the first NUL, truncates at 16 bytes, and NUL-pads the rest.  Returning the fixed buffer preserves the exact lumpinfo_t name representation and is safe for in-place callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | The input input consumed by `W_CleanupName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L48)

<a id="function-function-miniquake-wad-w-getlumpinfo-function-w-getlumpinfo-archive-name-src-miniquake-wad-ml-929183616"></a>
### W_GetLumpinfo

```ml
function W_GetLumpinfo(archive, name)
```

Mirror Quake's W_GetLumpinfo routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `W_GetLumpinfo`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L146)

<a id="function-function-miniquake-wad-w-getlumpname-function-w-getlumpname-archive-name-src-miniquake-wad-ml-616082986"></a>
### W_GetLumpName

```ml
function W_GetLumpName(archive, name)
```

C returns an untyped pointer.  MiniLang exposes the exact on-disk byte range instead; like the original this does not reject compressed lumps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `W_GetLumpName`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L158)

<a id="function-function-miniquake-wad-w-getlumpnum-function-w-getlumpnum-archive-number-src-miniquake-wad-ml-1295830566"></a>
### W_GetLumpNum

```ml
function W_GetLumpNum(archive, number)
```

Mirror Quake's W_GetLumpNum routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `W_GetLumpNum`. |
| `number` | `dynamic` | — | The number input consumed by `W_GetLumpNum`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L166)

<a id="function-function-miniquake-wad-w-loadwaddata-function-w-loadwaddata-data-filename-src-miniquake-wad-ml-1630743066"></a>
### W_LoadWadData

```ml
function W_LoadWadData(data, filename)
```

Data-oriented counterpart used when gfx.wad came from a Quake search path (most retail installs keep it inside pak0.pak).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L96)

<a id="function-function-miniquake-wad-w-loadwadfile-function-w-loadwadfile-filename-src-miniquake-wad-ml-1086014054"></a>
### W_LoadWadFile

```ml
function W_LoadWadFile(filename)
```

Mirror Quake's W_LoadWadFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L138)

<a id="constant-constant-miniquake-wad-wad-lumpinfo-size-const-wad-lumpinfo-size-32-src-miniquake-wad-ml-733858749"></a>
### WAD_LUMPINFO_SIZE

```ml
const WAD_LUMPINFO_SIZE = 32
```

Defines the wad lumpinfo size value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L42)

<a id="constant-constant-miniquake-wad-wad-name-length-const-wad-name-length-16-src-miniquake-wad-ml-1071844123"></a>
### WAD_NAME_LENGTH

```ml
const WAD_NAME_LENGTH = 16
```

Defines the wad name length value used by `miniquake.wad`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/wad.ml#L40)
