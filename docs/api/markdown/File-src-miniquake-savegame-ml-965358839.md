# `src/miniquake/savegame.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.savegame`](Package-miniquake-savegame-1459901296.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/quakec/edict.ml` as `qcedict` → [src/miniquake/quakec/edict.ml](File-src-miniquake-quakec-edict-ml-1018045152.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-savegame-apply-function-apply-server-saved-src-miniquake-savegame-ml-1521613795"></a>
### apply

```ml
function apply(server, saved)
```

Apply the requested value to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `saved` | `dynamic` | — | The saved input consumed by `apply`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L315)

<a id="function-function-miniquake-savegame-decodetext-function-decodetext-data-src-miniquake-savegame-ml-1757307325"></a>
### decodeText

```ml
function decodeText(data)
```

Decodes text for `miniquake.savegame`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L211)

<a id="function-function-miniquake-savegame-displaycomment-function-displaycomment-comment-src-miniquake-savegame-ml-837877294"></a>
### displayComment

```ml
function displayComment(comment)
```

Implements the `displayComment` operation for `miniquake.savegame` (display comment).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `comment` | `dynamic` | — | The comment input consumed by `displayComment`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L359)

<a id="function-function-miniquake-savegame-encodetext-function-encodetext-text-src-miniquake-savegame-ml-2053667960"></a>
### encodeText

```ml
function encodeText(text)
```

Encodes text for `miniquake.savegame`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L205)

<a id="function-function-miniquake-savegame-fieldname-function-fieldname-machine-offset-src-miniquake-savegame-ml-1804337893"></a>
### fieldName

```ml
function fieldName(machine, offset)
```

Return field name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `fieldName`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L67)

<a id="function-function-miniquake-savegame-filename-function-filename-name-src-miniquake-savegame-ml-594539748"></a>
### filename

```ml
function filename(name)
```

Implements the `filename` operation for `miniquake.savegame` (filename).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L407)

<a id="function-function-miniquake-savegame-floatline-function-floatline-data-offset-label-src-miniquake-savegame-ml-670667684"></a>
### floatLine

```ml
function floatLine(data, offset, label)
```

Implements the `floatLine` operation for `miniquake.savegame` (float line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `label` | `dynamic` | — | The label input consumed by `floatLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L246)

<a id="function-function-miniquake-savegame-functionname-function-functionname-machine-index-src-miniquake-savegame-ml-1686624280"></a>
### functionName

```ml
function functionName(machine, index)
```

Return function name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `functionName`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L59)

<a id="function-function-miniquake-savegame-hassuffixinsensitive-function-hassuffixinsensitive-text-suffix-src-miniquake-savegame-ml-1200663031"></a>
### hasSuffixInsensitive

```ml
function hasSuffixInsensitive(text, suffix)
```

Report whether suffix insensitive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `suffix` | `dynamic` | — | The suffix input consumed by `hasSuffixInsensitive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L389)

<a id="function-function-miniquake-savegame-host-savegamecomment-function-host-savegamecomment-levelname-killed-total-src-miniquake-savegame-ml-80720979"></a>
### Host_SavegameComment

```ml
function Host_SavegameComment(levelName, killed, total)
```

host_cmd.c entry points.  SaveGamestate/LoadGamestate are used only by the QUAKE2 compile-time path in the reference, but retain useful in-memory counterparts so the original functions have concrete MiniLang code sites.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `levelName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `killed` | `dynamic` | — | The killed input consumed by `Host_SavegameComment`. |
| `total` | `dynamic` | — | The total input consumed by `Host_SavegameComment`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L427)

<a id="function-function-miniquake-savegame-inspectcomment-function-inspectcomment-text-src-miniquake-savegame-ml-1421775236"></a>
### inspectComment

```ml
function inspectComment(text)
```

Inspect comment and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L380)

<a id="function-function-miniquake-savegame-inspectcommentbytes-function-inspectcommentbytes-data-src-miniquake-savegame-ml-1130702365"></a>
### inspectCommentBytes

```ml
function inspectCommentBytes(data)
```

Inspect comment bytes and emit its decoded metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L371)

<a id="function-function-miniquake-savegame-loadgamestate-function-loadgamestate-server-text-src-miniquake-savegame-ml-321361107"></a>
### LoadGamestate

```ml
function LoadGamestate(server, text)
```

Read and validate gamestate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L455)

<a id="function-function-miniquake-savegame-loadgamestatebytes-function-loadgamestatebytes-server-data-src-miniquake-savegame-ml-2118631492"></a>
### LoadGamestateBytes

```ml
function LoadGamestateBytes(server, data)
```

Read and validate gamestate bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L446)

<a id="function-function-miniquake-savegame-namedglobalfloat-function-namedglobalfloat-machine-name-src-miniquake-savegame-ml-863130247"></a>
### namedGlobalFloat

```ml
function namedGlobalFloat(machine, name)
```

Implements the `namedGlobalFloat` operation for `miniquake.savegame` (named global float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `namedGlobalFloat`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L150)

<a id="function-function-miniquake-savegame-numberline-function-numberline-data-offset-label-src-miniquake-savegame-ml-885551244"></a>
### numberLine

```ml
function numberLine(data, offset, label)
```

Implements the `numberLine` operation for `miniquake.savegame` (number line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `label` | `dynamic` | — | The label input consumed by `numberLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L235)

<a id="function-function-miniquake-savegame-paddedcomment-function-paddedcomment-levelname-killed-total-src-miniquake-savegame-ml-1974757029"></a>
### paddedComment

```ml
function paddedComment(levelName, killed, total)
```

Implements the `paddedComment` operation for `miniquake.savegame` (padded comment).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `levelName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `killed` | `dynamic` | — | The killed input consumed by `paddedComment`. |
| `total` | `dynamic` | — | The total input consumed by `paddedComment`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L112)

<a id="function-function-miniquake-savegame-parse-function-parse-text-src-miniquake-savegame-ml-927902886"></a>
### parse

```ml
function parse(text)
```

Implements the `parse` operation for `miniquake.savegame` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L306)

<a id="function-function-miniquake-savegame-parsebytes-function-parsebytes-data-src-miniquake-savegame-ml-1942673349"></a>
### parseBytes

```ml
function parseBytes(data)
```

Parses bytes for `miniquake.savegame`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L258)

<a id="function-function-miniquake-savegame-readline-function-readline-data-offset-src-miniquake-savegame-ml-1391183724"></a>
### readLine

```ml
function readLine(data, offset)
```

Read and validate line.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L218)

<a id="constant-constant-miniquake-savegame-savegame-comment-length-const-savegame-comment-length-39-src-miniquake-savegame-ml-665962574"></a>
### SAVEGAME_COMMENT_LENGTH

```ml
const SAVEGAME_COMMENT_LENGTH = 39
```

Defines the savegame comment length value used by `miniquake.savegame`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L23)

<a id="constant-constant-miniquake-savegame-savegame-version-const-savegame-version-5-src-miniquake-savegame-ml-1980519751"></a>
### SAVEGAME_VERSION

```ml
const SAVEGAME_VERSION = 5
```

Defines the savegame version value used by `miniquake.savegame`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L21)

<a id="function-function-miniquake-savegame-savegamestate-function-savegamestate-server-src-miniquake-savegame-ml-475723776"></a>
### SaveGamestate

```ml
function SaveGamestate(server)
```

Encode and write gamestate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L433)

<a id="function-function-miniquake-savegame-savegamestatebytes-function-savegamestatebytes-server-src-miniquake-savegame-ml-1365144724"></a>
### SaveGamestateBytes

```ml
function SaveGamestateBytes(server)
```

Encode and write gamestate bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L439)

<a id="function-function-miniquake-savegame-serializebytes-function-serializebytes-server-src-miniquake-savegame-ml-1354017976"></a>
### serializeBytes

```ml
function serializeBytes(server)
```

fopen(..., "w") writes the one-byte Quake text stream verbatim.  Keep the in-memory string API for tests and command code, but make byte I/O the authoritative savegame boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L197)

<a id="function-function-miniquake-savegame-serializeserver-function-serializeserver-server-src-miniquake-savegame-ml-273770942"></a>
### serializeServer

```ml
function serializeServer(server)
```

Encode and write server.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L158)

<a id="function-function-miniquake-savegame-typesize-function-typesize-valuetype-src-miniquake-savegame-ml-251141734"></a>
### typeSize

```ml
function typeSize(valueType)
```

Implements the `typeSize` operation for `miniquake.savegame` (type size).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `valueType` | `dynamic` | — | The value type input consumed by `typeSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L27)

<a id="function-function-miniquake-savegame-uglyvalue-function-uglyvalue-machine-words-definition-src-miniquake-savegame-ml-673611552"></a>
### uglyValue

```ml
function uglyValue(machine, words, definition)
```

Return ugly value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `uglyValue`. |
| `words` | `dynamic` | — | The words input consumed by `uglyValue`. |
| `definition` | `dynamic` | — | The definition input consumed by `uglyValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L78)

<a id="function-function-miniquake-savegame-vectorcomponentname-function-vectorcomponentname-name-src-miniquake-savegame-ml-1477000090"></a>
### vectorComponentName

```ml
function vectorComponentName(name)
```

Return vector component name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L35)

<a id="function-function-miniquake-savegame-wordsarezero-function-wordsarezero-words-offset-count-src-miniquake-savegame-ml-570243938"></a>
### wordsAreZero

```ml
function wordsAreZero(words, offset, count)
```

Implements the `wordsAreZero` operation for `miniquake.savegame` (words are zero).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | The words input consumed by `wordsAreZero`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L47)

<a id="function-function-miniquake-savegame-writedefinitions-function-writedefinitions-machine-words-definitions-globalsonly-src-miniquake-savegame-ml-1892442287"></a>
### writeDefinitions

```ml
function writeDefinitions(machine, words, definitions, globalsOnly)
```

Encode and write definitions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeDefinitions`. |
| `words` | `dynamic` | — | The words input consumed by `writeDefinitions`. |
| `definitions` | `dynamic` | — | The definitions input consumed by `writeDefinitions`. |
| `globalsOnly` | `dynamic` | — | The globals only input consumed by `writeDefinitions`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L87)

<a id="function-function-miniquake-savegame-writeedict-function-writeedict-machine-entityindex-src-miniquake-savegame-ml-782072075"></a>
### writeEdict

```ml
function writeEdict(machine, entityIndex)
```

Encode and write edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L102)

<a id="function-function-miniquake-savegame-writeglobals-function-writeglobals-machine-src-miniquake-savegame-ml-1278363466"></a>
### writeGlobals

```ml
function writeGlobals(machine)
```

Encode and write globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/savegame.ml#L95)
