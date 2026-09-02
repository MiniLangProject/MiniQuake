# `src/miniquake/message.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.message`](Package-miniquake-message-1799907542.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-message-beginreading-function-beginreading-buffer-src-miniquake-message-ml-134055351"></a>
### beginReading

```ml
function beginReading(buffer)
```

Initialize state for begin reading.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `beginReading`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L140)

<a id="function-function-miniquake-message-beginreadingbytes-function-beginreadingbytes-data-src-miniquake-message-ml-340841009"></a>
### beginReadingBytes

```ml
function beginReadingBytes(data)
```

Initialize state for begin reading bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L146)

<a id="function-function-miniquake-message-floatargument-function-floatargument-value-operation-src-miniquake-message-ml-1931428045"></a>
### floatArgument

```ml
function floatArgument(value, operation)
```

Implements the `floatArgument` operation for `miniquake.message` (float argument).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floatArgument`. |
| `operation` | `dynamic` | — | The operation input consumed by `floatArgument`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L71)

<a id="function-function-miniquake-message-integerargument-function-integerargument-value-operation-src-miniquake-message-ml-1293779513"></a>
### integerArgument

```ml
function integerArgument(value, operation)
```

Implements the `integerArgument` operation for `miniquake.message` (integer argument).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `integerArgument`. |
| `operation` | `dynamic` | — | The operation input consumed by `integerArgument`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L19)

<a id="function-function-miniquake-message-msg-beginreading-function-msg-beginreading-buffer-src-miniquake-message-ml-1437378863"></a>
### MSG_BeginReading

```ml
function MSG_BeginReading(buffer)
```

Mirror Quake's MSG_BeginReading routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_BeginReading`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L322)

<a id="function-function-miniquake-message-msg-readangle-function-msg-readangle-reader-src-miniquake-message-ml-1514917312"></a>
### MSG_ReadAngle

```ml
function MSG_ReadAngle(reader)
```

Mirror Quake's MSG_ReadAngle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L370)

<a id="function-function-miniquake-message-msg-readbyte-function-msg-readbyte-reader-src-miniquake-message-ml-1300560214"></a>
### MSG_ReadByte

```ml
function MSG_ReadByte(reader)
```

Mirror Quake's MSG_ReadByte routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L334)

<a id="function-function-miniquake-message-msg-readchar-function-msg-readchar-reader-src-miniquake-message-ml-1326896030"></a>
### MSG_ReadChar

```ml
function MSG_ReadChar(reader)
```

Mirror Quake's MSG_ReadChar routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L328)

<a id="function-function-miniquake-message-msg-readcoord-function-msg-readcoord-reader-src-miniquake-message-ml-1125884744"></a>
### MSG_ReadCoord

```ml
function MSG_ReadCoord(reader)
```

Mirror Quake's MSG_ReadCoord routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadCoord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L364)

<a id="function-function-miniquake-message-msg-readfloat-function-msg-readfloat-reader-src-miniquake-message-ml-947182670"></a>
### MSG_ReadFloat

```ml
function MSG_ReadFloat(reader)
```

Mirror Quake's MSG_ReadFloat routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L352)

<a id="function-function-miniquake-message-msg-readlong-function-msg-readlong-reader-src-miniquake-message-ml-1288516390"></a>
### MSG_ReadLong

```ml
function MSG_ReadLong(reader)
```

Mirror Quake's MSG_ReadLong routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L346)

<a id="function-function-miniquake-message-msg-readshort-function-msg-readshort-reader-src-miniquake-message-ml-1682788482"></a>
### MSG_ReadShort

```ml
function MSG_ReadShort(reader)
```

Mirror Quake's MSG_ReadShort routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L340)

<a id="function-function-miniquake-message-msg-readstring-function-msg-readstring-reader-src-miniquake-message-ml-257372446"></a>
### MSG_ReadString

```ml
function MSG_ReadString(reader)
```

Mirror Quake's MSG_ReadString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `MSG_ReadString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L358)

<a id="function-function-miniquake-message-msg-writeangle-function-msg-writeangle-buffer-value-src-miniquake-message-ml-1940014978"></a>
### MSG_WriteAngle

```ml
function MSG_WriteAngle(buffer, value)
```

Mirror Quake's MSG_WriteAngle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteAngle`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L316)

<a id="function-function-miniquake-message-msg-writebyte-function-msg-writebyte-buffer-value-src-miniquake-message-ml-196176804"></a>
### MSG_WriteByte

```ml
function MSG_WriteByte(buffer, value)
```

Mirror Quake's MSG_WriteByte routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteByte`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L274)

<a id="function-function-miniquake-message-msg-writechar-function-msg-writechar-buffer-value-src-miniquake-message-ml-1447929352"></a>
### MSG_WriteChar

```ml
function MSG_WriteChar(buffer, value)
```

Direct pendants for the message section of WinQuake/common.c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteChar`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L267)

<a id="function-function-miniquake-message-msg-writecoord-function-msg-writecoord-buffer-value-src-miniquake-message-ml-1900445658"></a>
### MSG_WriteCoord

```ml
function MSG_WriteCoord(buffer, value)
```

Mirror Quake's MSG_WriteCoord routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteCoord`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteCoord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L309)

<a id="function-function-miniquake-message-msg-writefloat-function-msg-writefloat-buffer-value-src-miniquake-message-ml-1987159674"></a>
### MSG_WriteFloat

```ml
function MSG_WriteFloat(buffer, value)
```

Mirror Quake's MSG_WriteFloat routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteFloat`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L295)

<a id="function-function-miniquake-message-msg-writelong-function-msg-writelong-buffer-value-src-miniquake-message-ml-113379108"></a>
### MSG_WriteLong

```ml
function MSG_WriteLong(buffer, value)
```

Mirror Quake's MSG_WriteLong routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteLong`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L288)

<a id="function-function-miniquake-message-msg-writeshort-function-msg-writeshort-buffer-value-src-miniquake-message-ml-2126276530"></a>
### MSG_WriteShort

```ml
function MSG_WriteShort(buffer, value)
```

Mirror Quake's MSG_WriteShort routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteShort`. |
| `value` | `dynamic` | — | Value consumed by `MSG_WriteShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L281)

<a id="function-function-miniquake-message-msg-writestring-function-msg-writestring-buffer-text-src-miniquake-message-ml-1902926788"></a>
### MSG_WriteString

```ml
function MSG_WriteString(buffer, text)
```

Mirror Quake's MSG_WriteString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `MSG_WriteString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L302)

<a id="function-function-miniquake-message-need-function-need-reader-count-src-miniquake-message-ml-1100068791"></a>
### need

```ml
function need(reader, count)
```

Implements the `need` operation for `miniquake.message` (need).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `need`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L153)

<a id="function-function-miniquake-message-readangle-function-readangle-reader-src-miniquake-message-ml-1393044216"></a>
### readAngle

```ml
function readAngle(reader)
```

Read and validate angle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L254)

<a id="function-function-miniquake-message-readbyte-function-readbyte-reader-src-miniquake-message-ml-2046925302"></a>
### readByte

```ml
function readByte(reader)
```

Read and validate byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L172)

<a id="function-function-miniquake-message-readchar-function-readchar-reader-src-miniquake-message-ml-1978674078"></a>
### readChar

```ml
function readChar(reader)
```

Read and validate char.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L163)

<a id="function-function-miniquake-message-readcoord-function-readcoord-reader-src-miniquake-message-ml-1155492188"></a>
### readCoord

```ml
function readCoord(reader)
```

Read and validate coord.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readCoord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L248)

<a id="function-function-miniquake-message-readfloat-function-readfloat-reader-src-miniquake-message-ml-898263758"></a>
### readFloat

```ml
function readFloat(reader)
```

Read and validate float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L217)

<a id="function-function-miniquake-message-readlong-function-readlong-reader-src-miniquake-message-ml-56079246"></a>
### readLong

```ml
function readLong(reader)
```

Read and validate long.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L199)

<a id="function-function-miniquake-message-readshort-function-readshort-reader-src-miniquake-message-ml-516900430"></a>
### readShort

```ml
function readShort(reader)
```

Read and validate short.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L181)

<a id="function-function-miniquake-message-readstring-function-readstring-reader-src-miniquake-message-ml-1727125502"></a>
### readString

```ml
function readString(reader)
```

Read and validate string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L242)

<a id="function-function-miniquake-message-readstringbytes-function-readstringbytes-reader-src-miniquake-message-ml-1724030674"></a>
### readStringBytes

```ml
function readStringBytes(reader)
```

Read and validate string bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readStringBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L228)

<a id="function-function-miniquake-message-readunsignedlong-function-readunsignedlong-reader-src-miniquake-message-ml-227320618"></a>
### readUnsignedLong

```ml
function readUnsignedLong(reader)
```

Read and validate unsigned long.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readUnsignedLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L208)

<a id="function-function-miniquake-message-readunsignedshort-function-readunsignedshort-reader-src-miniquake-message-ml-997541460"></a>
### readUnsignedShort

```ml
function readUnsignedShort(reader)
```

Read and validate unsigned short.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `readUnsignedShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L190)

<a id="function-function-miniquake-message-remaining-inline-function-remaining-reader-src-miniquake-message-ml-231158683"></a>
### remaining

```ml
inline function remaining(reader)
```

Implements the `remaining` operation for `miniquake.message` (remaining).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | The reader input consumed by `remaining`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L260)

<a id="function-function-miniquake-message-writeangle-function-writeangle-buffer-value-src-miniquake-message-ml-1836667450"></a>
### writeAngle

```ml
function writeAngle(buffer, value)
```

Encode and write angle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeAngle`. |
| `value` | `dynamic` | — | Value consumed by `writeAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L131)

<a id="function-function-miniquake-message-writebyte-function-writebyte-buffer-value-src-miniquake-message-ml-823307616"></a>
### writeByte

```ml
function writeByte(buffer, value)
```

Encode and write byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeByte`. |
| `value` | `dynamic` | — | Value consumed by `writeByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L44)

<a id="function-function-miniquake-message-writechar-function-writechar-buffer-value-src-miniquake-message-ml-958076260"></a>
### writeChar

```ml
function writeChar(buffer, value)
```

Encode and write char.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeChar`. |
| `value` | `dynamic` | — | Value consumed by `writeChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L35)

<a id="function-function-miniquake-message-writecoord-function-writecoord-buffer-value-src-miniquake-message-ml-611637238"></a>
### writeCoord

```ml
function writeCoord(buffer, value)
```

Encode and write coord.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeCoord`. |
| `value` | `dynamic` | — | Value consumed by `writeCoord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L123)

<a id="function-function-miniquake-message-writefloat-function-writefloat-buffer-value-src-miniquake-message-ml-1329646050"></a>
### writeFloat

```ml
function writeFloat(buffer, value)
```

Encode and write float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeFloat`. |
| `value` | `dynamic` | — | Value consumed by `writeFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L88)

<a id="function-function-miniquake-message-writelong-function-writelong-buffer-value-src-miniquake-message-ml-793683600"></a>
### writeLong

```ml
function writeLong(buffer, value)
```

Encode and write long.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeLong`. |
| `value` | `dynamic` | — | Value consumed by `writeLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L62)

<a id="function-function-miniquake-message-writeshort-function-writeshort-buffer-value-src-miniquake-message-ml-1294415710"></a>
### writeShort

```ml
function writeShort(buffer, value)
```

Encode and write short.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeShort`. |
| `value` | `dynamic` | — | Value consumed by `writeShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L53)

<a id="function-function-miniquake-message-writestring-function-writestring-buffer-text-src-miniquake-message-ml-1942822136"></a>
### writeString

```ml
function writeString(buffer, text)
```

Encode and write string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L116)

<a id="function-function-miniquake-message-writestringbytes-function-writestringbytes-buffer-data-src-miniquake-message-ml-194513043"></a>
### writeStringBytes

```ml
function writeStringBytes(buffer, data)
```

Encode and write string bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeStringBytes`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/message.ml#L97)
