# `src/miniquake/format/progs.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.format.progs`](Package-miniquake-format-progs-47626707.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/crc.ml` as `crc16` → [src/miniquake/crc.ml](File-src-miniquake-crc-ml-699476266.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-format-progs-checksection-function-checksection-data-offset-count-stride-name-src-miniquake-format-progs-ml-1053284352"></a>
### checkSection

```ml
function checkSection(data, offset, count, stride, name)
```

Validate section and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `stride` | `dynamic` | — | The stride input consumed by `checkSection`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L161)

<a id="function-function-miniquake-format-progs-load-function-load-filename-src-miniquake-format-progs-ml-1605136053"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.format.progs` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L269)

<a id="function-function-miniquake-format-progs-parse-function-parse-data-filename-src-miniquake-format-progs-ml-192069539"></a>
### parse

```ml
function parse(data, filename)
```

Implements the `parse` operation for `miniquake.format.progs` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L169)

<a id="function-function-miniquake-format-progs-runtimecrc-function-runtimecrc-program-src-miniquake-format-progs-ml-1662505268"></a>
### runtimeCrc

```ml
function runtimeCrc(program)
```

Return runtime crc derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `runtimeCrc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L149)

<a id="function-function-miniquake-format-progs-stringat-function-stringat-strings-offset-src-miniquake-format-progs-ml-621548211"></a>
### stringAt

```ml
function stringAt(strings, offset)
```

Implements the `stringAt` operation for `miniquake.format.progs` (string at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `strings` | `dynamic` | — | The strings input consumed by `stringAt`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L21)

<a id="function-function-miniquake-format-progs-typesize-function-typesize-valuetype-src-miniquake-format-progs-ml-1713221019"></a>
### typeSize

```ml
function typeSize(valueType)
```

Implements the `typeSize` operation for `miniquake.format.progs` (type size).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `valueType` | `dynamic` | — | The value type input consumed by `typeSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L32)

<a id="function-function-miniquake-format-progs-validatedefinition-function-validatedefinition-definition-limit-sectionname-src-miniquake-format-progs-ml-2051778786"></a>
### validateDefinition

```ml
function validateDefinition(definition, limit, sectionName)
```

Validate definition and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definition` | `dynamic` | — | The definition input consumed by `validateDefinition`. |
| `limit` | `dynamic` | — | The limit input consumed by `validateDefinition`. |
| `sectionName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L49)

<a id="function-function-miniquake-format-progs-validateloadableprogram-function-validateloadableprogram-program-src-miniquake-format-progs-ml-1078441832"></a>
### validateLoadableProgram

```ml
function validateLoadableProgram(program)
```

Validate loadable program and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `validateLoadableProgram`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L61)

<a id="function-function-miniquake-format-progs-validateprogram-function-validateprogram-program-src-miniquake-format-progs-ml-1101444480"></a>
### validateProgram

```ml
function validateProgram(program)
```

Validate program and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `validateProgram`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L82)

<a id="function-function-miniquake-format-progs-validtype-function-validtype-valuetype-src-miniquake-format-progs-ml-1323476627"></a>
### validType

```ml
function validType(valueType)
```

Report whether valid type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `valueType` | `dynamic` | — | The value type input consumed by `validType`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/progs.ml#L40)
