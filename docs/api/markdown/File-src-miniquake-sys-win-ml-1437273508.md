# `src/miniquake/sys_win.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sys_win`](Package-miniquake-sys-win-1090784061.md)

Reachable from entry: **yes**

## Imports

- `miniquake/conproc.ml` as `conproc` → [src/miniquake/conproc.ml](File-src-miniquake-conproc-ml-1901842008.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-sys-win-argumentindex-function-argumentindex-arguments-name-src-miniquake-sys-win-ml-829109168"></a>
### argumentIndex

```ml
function argumentIndex(arguments, name)
```

Return argument index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L446)

<a id="constant-constant-miniquake-sys-win-console-error-timeout-const-console-error-timeout-60-src-miniquake-sys-win-ml-759350548"></a>
### CONSOLE_ERROR_TIMEOUT

```ml
const CONSOLE_ERROR_TIMEOUT = 60.
```

Defines the console error timeout value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L22)

<a id="extern_function-extern-function-miniquake-sys-win-createdirectoryw-extern-function-createdirectoryw-path-as-wstr-security-as-ptr-from-kernel32-dll-returns-bool-src-miniquake-sys-win-ml-1459954288"></a>
### CreateDirectoryW

```ml
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" returns bool
```

Invokes the native `CreateDirectoryW` bridge operation used by `miniquake.sys_win`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — | Filesystem path to process. |
| `security` | `ptr` | — | The security input consumed by `CreateDirectoryW`. |


**Returns:** The newly created value returned by `CreateDirectoryW`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L51)

<a id="function-function-miniquake-sys-win-emptyhandles-function-emptyhandles-src-miniquake-sys-win-ml-20410223"></a>
### emptyHandles

```ml
function emptyHandles()
```

Implements the `emptyHandles` operation for `miniquake.sys_win` (empty handles).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L132)

<a id="constant-constant-miniquake-sys-win-file-begin-const-file-begin-0-src-miniquake-sys-win-ml-914521738"></a>
### FILE_BEGIN

```ml
const FILE_BEGIN = 0
```

Defines the file begin value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L30)

<a id="function-function-miniquake-sys-win-filelength-function-filelength-handle-src-miniquake-sys-win-ml-1500297369"></a>
### filelength

```ml
function filelength(handle)
```

Implements the `filelength` operation for `miniquake.sys_win` (filelength).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `filelength`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L256)

<a id="function-function-miniquake-sys-win-findhandle-function-findhandle-src-miniquake-sys-win-ml-280319159"></a>
### findhandle

```ml
function findhandle()
```

Finds handle for `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L237)

<a id="function-function-miniquake-sys-win-handleargument-function-handleargument-arguments-name-src-miniquake-sys-win-ml-887149470"></a>
### handleArgument

```ml
function handleArgument(arguments, name)
```

Handle argument and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L696)

<a id="constant-constant-miniquake-sys-win-invalid-set-file-pointer-const-invalid-set-file-pointer-4294967295-src-miniquake-sys-win-ml-70170739"></a>
### INVALID_SET_FILE_POINTER

```ml
const INVALID_SET_FILE_POINTER = 4294967295
```

Defines the invalid set file pointer value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L32)

<a id="function-function-miniquake-sys-win-listtail-function-listtail-values-src-miniquake-sys-win-ml-1369996329"></a>
### listTail

```ml
function listTail(values)
```

Implements the `listTail` operation for `miniquake.sys_win` (list tail).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `listTail`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L405)

<a id="function-function-miniquake-sys-win-maskexceptions-function-maskexceptions-src-miniquake-sys-win-ml-1831312963"></a>
### MaskExceptions

```ml
function MaskExceptions()
```

Implements the `MaskExceptions` operation for `miniquake.sys_win` (mask exceptions).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L399)

<a id="constant-constant-miniquake-sys-win-max-handles-const-max-handles-10-src-miniquake-sys-win-ml-16754261"></a>
### MAX_HANDLES

```ml
const MAX_HANDLES = 10
```

Defines the max handles value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L28)

<a id="constant-constant-miniquake-sys-win-maximum-win-memory-const-maximum-win-memory-16777216-src-miniquake-sys-win-ml-1518295503"></a>
### MAXIMUM_WIN_MEMORY

```ml
const MAXIMUM_WIN_MEMORY = 16777216
```

Defines the maximum win memory value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L20)

<a id="constant-constant-miniquake-sys-win-minimum-win-memory-const-minimum-win-memory-8912896-src-miniquake-sys-win-ml-451812205"></a>
### MINIMUM_WIN_MEMORY

```ml
const MINIMUM_WIN_MEMORY = 8912896
```

Defines the minimum win memory value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L18)

<a id="function-function-miniquake-sys-win-nextcounter-function-nextcounter-src-miniquake-sys-win-ml-1050139537"></a>
### nextCounter

```ml
function nextCounter()
```

Return next counter for the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L416)

<a id="constant-constant-miniquake-sys-win-not-focus-sleep-const-not-focus-sleep-20-src-miniquake-sys-win-ml-891495916"></a>
### NOT_FOCUS_SLEEP

```ml
const NOT_FOCUS_SLEEP = 20
```

Defines the not focus sleep value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L26)

<a id="constant-constant-miniquake-sys-win-pause-sleep-const-pause-sleep-50-src-miniquake-sys-win-ml-2015593117"></a>
### PAUSE_SLEEP

```ml
const PAUSE_SLEEP = 50
```

Defines the pause sleep value used by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L24)

<a id="function-function-miniquake-sys-win-popconsoleevent-function-popconsoleevent-src-miniquake-sys-win-ml-2046896931"></a>
### popConsoleEvent

```ml
function popConsoleEvent()
```

Consume pending state for pop console event.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L568)

<a id="function-function-miniquake-sys-win-readi32-function-readi32-data-offset-src-miniquake-sys-win-ml-2019485392"></a>
### readI32

```ml
function readI32(data, offset)
```

Read and validate i32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L203)

<a id="function-function-miniquake-sys-win-readu32-inline-function-readu32-data-src-miniquake-sys-win-ml-193759792"></a>
### readU32

```ml
inline function readU32(data)
```

Read and validate u32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L210)

<a id="extern_function-extern-function-miniquake-sys-win-setfilepointer-extern-function-setfilepointer-handle-as-ptr-distance-as-i32-distancehigh-as-ptr-movemethod-as-u32-from-kernel32-dll-returns-u32-src-miniquake-sys-win-ml-24692615"></a>
### SetFilePointer

```ml
extern function SetFilePointer(handle as ptr, distance as i32, distanceHigh as ptr, moveMethod as u32) from "kernel32.dll" returns u32
```

Invokes the native `SetFilePointer` bridge operation used by `miniquake.sys_win`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — | The handle input consumed by `SetFilePointer`. |
| `distance` | `i32` | — | The distance input consumed by `SetFilePointer`. |
| `distanceHigh` | `ptr` | — | The distance high input consumed by `SetFilePointer`. |
| `moveMethod` | `u32` | — | The move method input consumed by `SetFilePointer`. |


**Returns:** The `u32` result produced by `SetFilePointer`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L40)

<a id="function-function-miniquake-sys-win-signed32-function-signed32-value-src-miniquake-sys-win-ml-1081595676"></a>
### signed32

```ml
function signed32(value)
```

Implements the `signed32` operation for `miniquake.sys_win` (signed32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `signed32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L194)

<a id="function-function-miniquake-sys-win-sleepuntilinput-function-sleepuntilinput-time-src-miniquake-sys-win-ml-1593909476"></a>
### SleepUntilInput

```ml
function SleepUntilInput(time)
```

Implements the `SleepUntilInput` operation for `miniquake.sys_win` (sleep until input).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L647)

<a id="function-function-miniquake-sys-win-sys-consoleinject-function-sys-consoleinject-character-keydown-src-miniquake-sys-win-ml-1731450329"></a>
### Sys_ConsoleInject

```ml
function Sys_ConsoleInject(character, keyDown)
```

Mirror Quake's Sys_ConsoleInject routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `character` | `dynamic` | — | The character input consumed by `Sys_ConsoleInject`. |
| `keyDown` | `dynamic` | — | The key down input consumed by `Sys_ConsoleInject`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L561)

<a id="function-function-miniquake-sys-win-sys-consoleinput-function-sys-consoleinput-src-miniquake-sys-win-ml-1653283811"></a>
### Sys_ConsoleInput

```ml
function Sys_ConsoleInput()
```

Mirror Quake's Sys_ConsoleInput routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L586)

<a id="function-function-miniquake-sys-win-sys-createstate-function-sys-createstate-usenative-src-miniquake-sys-win-ml-1130771875"></a>
### Sys_CreateState

```ml
function Sys_CreateState(useNative)
```

Mirror Quake's Sys_CreateState routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `useNative` | `dynamic` | — | The use native input consumed by `Sys_CreateState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L138)

<a id="function-function-miniquake-sys-win-sys-error-function-sys-error-text-src-miniquake-sys-win-ml-406185932"></a>
### Sys_Error

```ml
function Sys_Error(text)
```

Mirror Quake's Sys_Error routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L480)

<a id="function-function-miniquake-sys-win-sys-fileclose-function-sys-fileclose-handle-src-miniquake-sys-win-ml-1297394585"></a>
### Sys_FileClose

```ml
function Sys_FileClose(handle)
```

Mirror Quake's Sys_FileClose routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `Sys_FileClose`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L309)

<a id="function-function-miniquake-sys-win-sys-fileopenread-function-sys-fileopenread-path-src-miniquake-sys-win-ml-536937668"></a>
### Sys_FileOpenRead

```ml
function Sys_FileOpenRead(path)
```

Mirror Quake's Sys_FileOpenRead routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L269)

<a id="function-function-miniquake-sys-win-sys-fileopenwrite-function-sys-fileopenwrite-path-src-miniquake-sys-win-ml-645252382"></a>
### Sys_FileOpenWrite

```ml
function Sys_FileOpenWrite(path)
```

Mirror Quake's Sys_FileOpenWrite routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L289)

<a id="function-function-miniquake-sys-win-sys-fileread-function-sys-fileread-handle-destination-count-src-miniquake-sys-win-ml-708959398"></a>
### Sys_FileRead

```ml
function Sys_FileRead(handle, destination, count)
```

Mirror Quake's Sys_FileRead routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `Sys_FileRead`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L331)

<a id="function-function-miniquake-sys-win-sys-fileseek-function-sys-fileseek-handle-position-src-miniquake-sys-win-ml-695111630"></a>
### Sys_FileSeek

```ml
function Sys_FileSeek(handle, position)
```

Mirror Quake's Sys_FileSeek routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `Sys_FileSeek`. |
| `position` | `dynamic` | — | Position used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L320)

<a id="function-function-miniquake-sys-win-sys-filetime-function-sys-filetime-path-src-miniquake-sys-win-ml-2129010324"></a>
### Sys_FileTime

```ml
function Sys_FileTime(path)
```

Mirror Quake's Sys_FileTime routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L357)

<a id="function-function-miniquake-sys-win-sys-filewrite-function-sys-filewrite-handle-data-count-src-miniquake-sys-win-ml-701551874"></a>
### Sys_FileWrite

```ml
function Sys_FileWrite(handle, data, count)
```

Mirror Quake's Sys_FileWrite routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `Sys_FileWrite`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L345)

<a id="function-function-miniquake-sys-win-sys-floattime-function-sys-floattime-src-miniquake-sys-win-ml-1754558469"></a>
### Sys_FloatTime

```ml
function Sys_FloatTime()
```

Mirror Quake's Sys_FloatTime routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L511)

<a id="function-function-miniquake-sys-win-sys-highfpprecision-function-sys-highfpprecision-src-miniquake-sys-win-ml-1755584299"></a>
### Sys_HighFPPrecision

```ml
function Sys_HighFPPrecision()
```

Mirror Quake's Sys_HighFPPrecision routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L735)

<a id="function-function-miniquake-sys-win-sys-init-function-sys-init-src-miniquake-sys-win-ml-393868031"></a>
### Sys_Init

```ml
function Sys_Init()
```

Mirror Quake's Sys_Init routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L456)

<a id="function-function-miniquake-sys-win-sys-initfloattime-function-sys-initfloattime-src-miniquake-sys-win-ml-1706708873"></a>
### Sys_InitFloatTime

```ml
function Sys_InitFloatTime()
```

Mirror Quake's Sys_InitFloatTime routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L543)

<a id="function-function-miniquake-sys-win-sys-lowfpprecision-function-sys-lowfpprecision-src-miniquake-sys-win-ml-1901232747"></a>
### Sys_LowFPPrecision

```ml
function Sys_LowFPPrecision()
```

Mirror Quake's Sys_LowFPPrecision routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L730)

<a id="function-function-miniquake-sys-win-sys-makecodewriteable-function-sys-makecodewriteable-startaddress-length-src-miniquake-sys-win-ml-960753183"></a>
### Sys_MakeCodeWriteable

```ml
function Sys_MakeCodeWriteable(startAddress, length)
```

Mirror Quake's Sys_MakeCodeWriteable routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startAddress` | `dynamic` | — | The start address input consumed by `Sys_MakeCodeWriteable`. |
| `length` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L372)

<a id="function-function-miniquake-sys-win-sys-mkdir-function-sys-mkdir-path-src-miniquake-sys-win-ml-1050864442"></a>
### Sys_mkdir

```ml
function Sys_mkdir(path)
```

Mirror Quake's Sys_mkdir routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L364)

<a id="function-function-miniquake-sys-win-sys-pagein-function-sys-pagein-memory-size-src-miniquake-sys-win-ml-610362025"></a>
### Sys_PageIn

```ml
function Sys_PageIn(memory, size)
```

Mirror Quake's Sys_PageIn routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `memory` | `dynamic` | — | The memory input consumed by `Sys_PageIn`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L217)

<a id="function-function-miniquake-sys-win-sys-parsecommandline-function-sys-parsecommandline-commandline-src-miniquake-sys-win-ml-1596493886"></a>
### Sys_ParseCommandLine

```ml
function Sys_ParseCommandLine(commandLine)
```

Mirror Quake's Sys_ParseCommandLine routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `Sys_ParseCommandLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L657)

<a id="function-function-miniquake-sys-win-sys-popfpcw-inline-function-sys-popfpcw-src-miniquake-sys-win-ml-1582520452"></a>
### Sys_PopFPCW

```ml
inline function Sys_PopFPCW()
```

Mirror Quake's Sys_PopFPCW routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L394)

<a id="function-function-miniquake-sys-win-sys-printf-function-sys-printf-text-src-miniquake-sys-win-ml-1468033072"></a>
### Sys_Printf

```ml
function Sys_Printf(text)
```

Mirror Quake's Sys_Printf routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L494)

<a id="function-function-miniquake-sys-win-sys-pushfpcw-sethigh-inline-function-sys-pushfpcw-sethigh-src-miniquake-sys-win-ml-1279705612"></a>
### Sys_PushFPCW_SetHigh

```ml
inline function Sys_PushFPCW_SetHigh()
```

Mirror Quake's Sys_PushFPCW_SetHigh routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L389)

<a id="function-function-miniquake-sys-win-sys-quit-function-sys-quit-src-miniquake-sys-win-ml-1559498931"></a>
### Sys_Quit

```ml
function Sys_Quit()
```

Mirror Quake's Sys_Quit routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L502)

<a id="function-function-miniquake-sys-win-sys-selectmemorysize-function-sys-selectmemorysize-available-total-arguments-src-miniquake-sys-win-ml-1082506416"></a>
### Sys_SelectMemorySize

```ml
function Sys_SelectMemorySize(available, total, arguments)
```

Mirror Quake's Sys_SelectMemorySize routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `available` | `dynamic` | — | The available input consumed by `Sys_SelectMemorySize`. |
| `total` | `dynamic` | — | The total input consumed by `Sys_SelectMemorySize`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L679)

<a id="function-function-miniquake-sys-win-sys-sendkeyevents-function-sys-sendkeyevents-src-miniquake-sys-win-ml-46585143"></a>
### Sys_SendKeyEvents

```ml
function Sys_SendKeyEvents()
```

Mirror Quake's Sys_SendKeyEvents routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L633)

<a id="function-function-miniquake-sys-win-sys-setcounterfixture-function-sys-setcounterfixture-frequency-counters-src-miniquake-sys-win-ml-1359199628"></a>
### Sys_SetCounterFixture

```ml
function Sys_SetCounterFixture(frequency, counters)
```

Mirror Quake's Sys_SetCounterFixture routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frequency` | `dynamic` | — | The frequency input consumed by `Sys_SetCounterFixture`. |
| `counters` | `dynamic` | — | The counters input consumed by `Sys_SetCounterFixture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L434)

<a id="function-function-miniquake-sys-win-sys-setfpcw-function-sys-setfpcw-src-miniquake-sys-win-ml-834846255"></a>
### Sys_SetFPCW

```ml
function Sys_SetFPCW()
```

Mirror Quake's Sys_SetFPCW routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L384)

<a id="function-function-miniquake-sys-win-sys-sleep-function-sys-sleep-src-miniquake-sys-win-ml-998133017"></a>
### Sys_Sleep

```ml
function Sys_Sleep()
```

Mirror Quake's Sys_Sleep routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L625)

<a id="function-function-miniquake-sys-win-sys-state-function-sys-state-src-miniquake-sys-win-ml-1264420389"></a>
### Sys_State

```ml
function Sys_State()
```

Mirror Quake's Sys_State routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L186)

<a id="function-function-miniquake-sys-win-sys-usestate-function-sys-usestate-state-src-miniquake-sys-win-ml-54382668"></a>
### Sys_UseState

```ml
function Sys_UseState(state)
```

Mirror Quake's Sys_UseState routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sys_win` state used by `Sys_UseState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L179)

<a id="global-global-miniquake-sys-win-syswinstate-syswinstate-src-miniquake-sys-win-ml-474710601"></a>
### sysWinState

```ml
sysWinState
```

Tracks the module-level Windows system state owned by `miniquake.sys_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L129)

- [miniquake.sys_win.SysWinState](Type-miniquake-sys-win-syswinstate-2070517817.md) — struct
<a id="function-function-miniquake-sys-win-validhandle-function-validhandle-index-src-miniquake-sys-win-ml-1714795721"></a>
### validHandle

```ml
function validHandle(index)
```

Report whether valid handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L249)

<a id="function-function-miniquake-sys-win-winmain-function-winmain-arguments-runner-src-miniquake-sys-win-ml-1464010593"></a>
### WinMain

```ml
function WinMain(arguments, runner)
```

Implements the `WinMain` operation for `miniquake.sys_win` (win main).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `runner` | `dynamic` | — | The runner input consumed by `WinMain`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sys_win.ml#L707)
