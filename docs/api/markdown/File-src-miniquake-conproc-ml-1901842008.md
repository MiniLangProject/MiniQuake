# `src/miniquake/conproc.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.conproc`](Package-miniquake-conproc-415322817.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-conproc-asciiupper-function-asciiupper-code-src-miniquake-conproc-ml-323625474"></a>
### asciiUpper

```ml
function asciiUpper(code)
```

Implements the `asciiUpper` operation for `miniquake.conproc` (ascii upper).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `asciiUpper`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L187)

<a id="constant-constant-miniquake-conproc-ccom-get-scr-lines-const-ccom-get-scr-lines-4-src-miniquake-conproc-ml-1060952706"></a>
### CCOM_GET_SCR_LINES

```ml
const CCOM_GET_SCR_LINES = 4
```

Defines the ccom get scr lines value used by `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L19)

<a id="constant-constant-miniquake-conproc-ccom-get-text-const-ccom-get-text-3-src-miniquake-conproc-ml-230644107"></a>
### CCOM_GET_TEXT

```ml
const CCOM_GET_TEXT = 3
```

Defines the ccom get text value used by `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L17)

<a id="constant-constant-miniquake-conproc-ccom-set-scr-lines-const-ccom-set-scr-lines-5-src-miniquake-conproc-ml-259336315"></a>
### CCOM_SET_SCR_LINES

```ml
const CCOM_SET_SCR_LINES = 5
```

Defines the ccom set scr lines value used by `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L21)

<a id="constant-constant-miniquake-conproc-ccom-write-text-const-ccom-write-text-2-src-miniquake-conproc-ml-1461266742"></a>
### CCOM_WRITE_TEXT

```ml
const CCOM_WRITE_TEXT = 2
```

Defines the ccom write text value used by `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L15)

<a id="function-function-miniquake-conproc-chartocode-function-chartocode-character-src-miniquake-conproc-ml-694817330"></a>
### CharToCode

```ml
function CharToCode(character)
```

Implements the `CharToCode` operation for `miniquake.conproc` (char to code).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `character` | `dynamic` | — | The character input consumed by `CharToCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L194)

<a id="function-function-miniquake-conproc-conproc-poll-function-conproc-poll-src-miniquake-conproc-ml-1613741547"></a>
### ConProc_Poll

```ml
function ConProc_Poll()
```

Mirror Quake's ConProc_Poll routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L334)

<a id="function-function-miniquake-conproc-conproc-requestbuffer-function-conproc-requestbuffer-src-miniquake-conproc-ml-1694081127"></a>
### ConProc_RequestBuffer

```ml
function ConProc_RequestBuffer()
```

Mirror Quake's ConProc_RequestBuffer routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L329)

<a id="function-function-miniquake-conproc-conproc-settestbuffer-function-conproc-settestbuffer-buffer-src-miniquake-conproc-ml-764088867"></a>
### ConProc_SetTestBuffer

```ml
function ConProc_SetTestBuffer(buffer)
```

Mirror Quake's ConProc_SetTestBuffer routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `ConProc_SetTestBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L322)

<a id="function-function-miniquake-conproc-conproc-state-function-conproc-state-src-miniquake-conproc-ml-1446295119"></a>
### ConProc_State

```ml
function ConProc_State()
```

Mirror Quake's ConProc_State routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L78)

<a id="function-function-miniquake-conproc-conproc-usestate-function-conproc-usestate-state-src-miniquake-conproc-ml-116212964"></a>
### ConProc_UseState

```ml
function ConProc_UseState(state)
```

Mirror Quake's ConProc_UseState routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.conproc` state used by `ConProc_UseState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L71)

<a id="global-global-miniquake-conproc-conprocstate-conprocstate-src-miniquake-conproc-ml-2095661271"></a>
### conProcState

```ml
conProcState
```

Tracks the module-level console-process state owned by `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L62)

- [miniquake.conproc.ConProcState](Type-miniquake-conproc-conprocstate-1376974652.md) — struct
<a id="function-function-miniquake-conproc-createstate-function-createstate-src-miniquake-conproc-ml-2106259437"></a>
### createState

```ml
function createState()
```

Creates state for `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L65)

<a id="function-function-miniquake-conproc-deinitconproc-function-deinitconproc-src-miniquake-conproc-ml-225345517"></a>
### DeinitConProc

```ml
function DeinitConProc()
```

Release or remove state for con proc.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L109)

<a id="function-function-miniquake-conproc-getmappedbuffer-function-getmappedbuffer-filehandle-src-miniquake-conproc-ml-1522813841"></a>
### GetMappedBuffer

```ml
function GetMappedBuffer(fileHandle)
```

Return mapped buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileHandle` | `dynamic` | — | The file handle input consumed by `GetMappedBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L118)

<a id="function-function-miniquake-conproc-getscreenbufferlines-function-getscreenbufferlines-src-miniquake-conproc-ml-768851075"></a>
### GetScreenBufferLines

```ml
function GetScreenBufferLines()
```

Return screen buffer lines.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L137)

<a id="constant-constant-miniquake-conproc-infinite-const-infinite-4294967295-src-miniquake-conproc-ml-1410443269"></a>
### INFINITE

```ml
const INFINITE = 4294967295
```

Defines the infinite value used by `miniquake.conproc`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L23)

<a id="function-function-miniquake-conproc-initconproc-function-initconproc-filehandle-parentevent-childevent-usenative-src-miniquake-conproc-ml-726498725"></a>
### InitConProc

```ml
function InitConProc(fileHandle, parentEvent, childEvent, useNative)
```

Initialize state for init con proc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileHandle` | `dynamic` | — | The file handle input consumed by `InitConProc`. |
| `parentEvent` | `dynamic` | — | The parent event input consumed by `InitConProc`. |
| `childEvent` | `dynamic` | — | The child event input consumed by `InitConProc`. |
| `useNative` | `dynamic` | — | The use native input consumed by `InitConProc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L89)

<a id="function-function-miniquake-conproc-paddedline-function-paddedline-text-width-src-miniquake-conproc-ml-1103742092"></a>
### paddedLine

```ml
function paddedLine(text, width)
```

Implements the `paddedLine` operation for `miniquake.conproc` (padded line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L155)

<a id="function-function-miniquake-conproc-processnativerequest-function-processnativerequest-state-mapped-src-miniquake-conproc-ml-1393664119"></a>
### processNativeRequest

```ml
function processNativeRequest(state, mapped)
```

Execute native request.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.conproc` state used by `processNativeRequest`. |
| `mapped` | `dynamic` | — | The mapped input consumed by `processNativeRequest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L273)

<a id="function-function-miniquake-conproc-processtestrequest-function-processtestrequest-state-src-miniquake-conproc-ml-504537756"></a>
### processTestRequest

```ml
function processTestRequest(state)
```

Execute test request.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.conproc` state used by `processTestRequest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L249)

<a id="function-function-miniquake-conproc-readtext-function-readtext-beginline-endline-src-miniquake-conproc-ml-528120269"></a>
### ReadText

```ml
function ReadText(beginLine, endLine)
```

Reads text for `miniquake.conproc`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beginLine` | `dynamic` | — | The begin line input consumed by `ReadText`. |
| `endLine` | `dynamic` | — | The end line input consumed by `ReadText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L170)

<a id="function-function-miniquake-conproc-releasemappedbuffer-function-releasemappedbuffer-mapped-src-miniquake-conproc-ml-527289424"></a>
### ReleaseMappedBuffer

```ml
function ReleaseMappedBuffer(mapped)
```

Release or remove state for mapped buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `dynamic` | — | The mapped input consumed by `ReleaseMappedBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L128)

<a id="function-function-miniquake-conproc-requestproc-function-requestproc-block-src-miniquake-conproc-ml-1005740542"></a>
### RequestProc

```ml
function RequestProc(block)
```

Implements the `RequestProc` operation for `miniquake.conproc` (request proc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `RequestProc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L298)

<a id="function-function-miniquake-conproc-setconsolecxcy-function-setconsolecxcy-stdouthandle-width-height-src-miniquake-conproc-ml-1142199949"></a>
### SetConsoleCXCY

```ml
function SetConsoleCXCY(stdoutHandle, width, height)
```

Update module state for console cxcy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stdoutHandle` | `dynamic` | — | The stdout handle input consumed by `SetConsoleCXCY`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L236)

<a id="function-function-miniquake-conproc-setscreenbufferlines-function-setscreenbufferlines-lines-src-miniquake-conproc-ml-1365864970"></a>
### SetScreenBufferLines

```ml
function SetScreenBufferLines(lines)
```

Update module state for screen buffer lines.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lines` | `dynamic` | — | The lines input consumed by `SetScreenBufferLines`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L148)

<a id="function-function-miniquake-conproc-writetext-function-writetext-text-src-miniquake-conproc-ml-495351756"></a>
### WriteText

```ml
function WriteText(text)
```

Writes text for `miniquake.conproc`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/conproc.ml#L204)
