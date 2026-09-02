# `src/miniquake/protocol_write.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_write`](Package-miniquake-protocol-write-1729213395.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-protocol-write-writebaseline-function-writebaseline-buffer-baseline-src-miniquake-protocol-write-ml-1080692482"></a>
### writeBaseline

```ml
function writeBaseline(buffer, baseline)
```

Writes baseline for `miniquake.protocol_write`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeBaseline`. |
| `baseline` | `dynamic` | — | The baseline input consumed by `writeBaseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_write.ml#L52)

<a id="function-function-miniquake-protocol-write-writedisconnect-function-writedisconnect-buffer-src-miniquake-protocol-write-ml-168347917"></a>
### writeDisconnect

```ml
function writeDisconnect(buffer)
```

Encode and write disconnect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeDisconnect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_write.ml#L24)

<a id="function-function-miniquake-protocol-write-writemove-function-writemove-buffer-command-clienttime-src-miniquake-protocol-write-ml-2141093332"></a>
### writeMove

```ml
function writeMove(buffer, command, clientTime)
```

Encode and write move.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeMove`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_write.ml#L32)

<a id="function-function-miniquake-protocol-write-writestringcommand-function-writestringcommand-buffer-text-src-miniquake-protocol-write-ml-180517746"></a>
### writeStringCommand

```ml
function writeStringCommand(buffer, text)
```

Encode and write string command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeStringCommand`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_write.ml#L17)
