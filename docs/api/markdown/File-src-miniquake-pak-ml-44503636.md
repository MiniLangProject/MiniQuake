# `src/miniquake/pak.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.pak`](Package-miniquake-pak-1256273445.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/crc.ml` as `crc` → [src/miniquake/crc.ml](File-src-miniquake-crc-ml-699476266.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-pak-directorycrc-function-directorycrc-archive-src-miniquake-pak-ml-436128275"></a>
### directoryCrc

```ml
function directoryCrc(archive)
```

Return directory crc derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `directoryCrc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L95)

<a id="function-function-miniquake-pak-directoryrange-function-directoryrange-archive-src-miniquake-pak-ml-189391575"></a>
### directoryRange

```ml
function directoryRange(archive)
```

Implements the `directoryRange` operation for `miniquake.pak` (directory range).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `directoryRange`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L88)

<a id="function-function-miniquake-pak-find-function-find-archive-name-src-miniquake-pak-ml-1535373884"></a>
### find

```ml
function find(archive, name)
```

Implements the `find` operation for `miniquake.pak` (find).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `find`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L63)

<a id="function-function-miniquake-pak-hasfile-function-hasfile-archive-name-src-miniquake-pak-ml-1911754056"></a>
### hasFile

```ml
function hasFile(archive, name)
```

Report whether file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `hasFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L82)

<a id="function-function-miniquake-pak-isoriginalpak0directory-function-isoriginalpak0directory-archive-src-miniquake-pak-ml-261025487"></a>
### isOriginalPak0Directory

```ml
function isOriginalPak0Directory(archive)
```

Report whether is original pak0 directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `isOriginalPak0Directory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L102)

<a id="function-function-miniquake-pak-load-function-load-filename-src-miniquake-pak-ml-1118346462"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.pak` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L55)

<a id="constant-constant-miniquake-pak-max-files-in-pack-const-max-files-in-pack-2048-src-miniquake-pak-ml-1573382712"></a>
### MAX_FILES_IN_PACK

```ml
const MAX_FILES_IN_PACK = 2048
```

Defines the max files in pack value used by `miniquake.pak`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L17)

<a id="constant-constant-miniquake-pak-pak0-count-const-pak0-count-339-src-miniquake-pak-ml-719805837"></a>
### PAK0_COUNT

```ml
const PAK0_COUNT = 339
```

Defines the pak0 count value used by `miniquake.pak`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L19)

<a id="constant-constant-miniquake-pak-pak0-crc-const-pak0-crc-32981-src-miniquake-pak-ml-559345961"></a>
### PAK0_CRC

```ml
const PAK0_CRC = 32981
```

Defines the pak0 crc value used by `miniquake.pak`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L21)

<a id="function-function-miniquake-pak-parse-function-parse-data-filename-src-miniquake-pak-ml-1365595140"></a>
### parse

```ml
function parse(data, filename)
```

Implements the `parse` operation for `miniquake.pak` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L26)

<a id="function-function-miniquake-pak-readfile-function-readfile-archive-name-src-miniquake-pak-ml-1884703560"></a>
### readFile

```ml
function readFile(archive, name)
```

Read and validate file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `archive` | `dynamic` | — | The archive input consumed by `readFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/pak.ml#L73)
