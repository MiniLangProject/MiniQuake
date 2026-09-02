# `src/miniquake/protocol_text.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_text`](Package-miniquake-protocol-text-217274419.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-miniquake-protocol-text-decodebytes-function-decodebytes-data-src-miniquake-protocol-text-ml-1331592569"></a>
### decodeBytes

```ml
function decodeBytes(data)
```

Decodes bytes for `miniquake.protocol_text`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_text.ml#L68)

<a id="function-function-miniquake-protocol-text-encodebytes-function-encodebytes-text-src-miniquake-protocol-text-ml-432135746"></a>
### encodeBytes

```ml
function encodeBytes(text)
```

Encodes bytes for `miniquake.protocol_text`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_text.ml#L19)

<a id="function-function-miniquake-protocol-text-encodedlength-function-encodedlength-text-src-miniquake-protocol-text-ml-2135617380"></a>
### encodedLength

```ml
function encodedLength(text)
```

Encode and write d length.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_text.ml#L99)

<a id="function-function-miniquake-protocol-text-roundtripbytes-function-roundtripbytes-data-src-miniquake-protocol-text-ml-1687335111"></a>
### roundTripBytes

```ml
function roundTripBytes(data)
```

Return round trip bytes derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_text.ml#L105)

<a id="constant-constant-miniquake-protocol-text-text-abi-const-text-abi-quake-latin1-cstring-v1-src-miniquake-protocol-text-ml-124809210"></a>
### TEXT_ABI

```ml
const TEXT_ABI = "quake_latin1_cstring_v1"
```

Defines the text abi value used by `miniquake.protocol_text`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_text.ml#L15)

<a id="function-function-miniquake-protocol-text-truncate-function-truncate-text-maximum-src-miniquake-protocol-text-ml-1456207014"></a>
### truncate

```ml
function truncate(text, maximum)
```

Truncate by Quake bytes rather than MiniLang's UTF-8 storage bytes. This is the newName[15]=0 behavior needed by Host_Name_f while preserving every extended Quake byte 0x80..0xff.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_text.ml#L114)
