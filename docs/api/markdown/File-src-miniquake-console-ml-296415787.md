# `src/miniquake/console.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.console`](Package-miniquake-console-582527596.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-console-adjustbackscroll-function-adjustbackscroll-state-delta-visiblerows-src-miniquake-console-ml-1296418097"></a>
### adjustBackscroll

```ml
function adjustBackscroll(state, delta, visibleRows)
```

Implements the `adjustBackscroll` operation for `miniquake.console` (adjust backscroll).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `adjustBackscroll`. |
| `delta` | `dynamic` | — | The delta input consumed by `adjustBackscroll`. |
| `visibleRows` | `dynamic` | — | The visible rows input consumed by `adjustBackscroll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L108)

<a id="function-function-miniquake-console-append-function-append-state-text-src-miniquake-console-ml-582224299"></a>
### append

```ml
function append(state, text)
```

Implements the `append` operation for `miniquake.console` (append).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `append`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L653)

<a id="function-function-miniquake-console-appendcharacter-function-appendcharacter-state-code-src-miniquake-console-ml-298899343"></a>
### appendCharacter

```ml
function appendCharacter(state, code)
```

Add state for append character.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `appendCharacter`. |
| `code` | `dynamic` | — | The code input consumed by `appendCharacter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L695)

<a id="function-function-miniquake-console-appendline-function-appendline-state-text-src-miniquake-console-ml-850594803"></a>
### appendLine

```ml
function appendLine(state, text)
```

Add state for append line.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `appendLine`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L645)

<a id="function-function-miniquake-console-backscroll-inline-function-backscroll-src-miniquake-console-ml-1917199822"></a>
### backscroll

```ml
inline function backscroll()
```

Implements the `backscroll` operation for `miniquake.console` (backscroll).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L91)

<a id="global-global-miniquake-console-backscrolllines-backscrolllines-src-miniquake-console-ml-2075206829"></a>
### backscrollLines

```ml
backscrollLines
```

Tracks the module-level backscroll lines state owned by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L26)

<a id="function-function-miniquake-console-backspace-function-backspace-state-src-miniquake-console-ml-760962338"></a>
### backspace

```ml
function backspace(state)
```

Implements the `backspace` operation for `miniquake.console` (backspace).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `backspace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L704)

<a id="function-function-miniquake-console-centerprint-function-centerprint-state-text-currenttime-duration-src-miniquake-console-ml-844403067"></a>
### centerPrint

```ml
function centerPrint(state, text, currentTime, duration)
```

Implements the `centerPrint` operation for `miniquake.console` (center print).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `centerPrint`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |
| `duration` | `dynamic` | — | The duration input consumed by `centerPrint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L724)

<a id="function-function-miniquake-console-clear-function-clear-state-src-miniquake-console-ml-1780487762"></a>
### clear

```ml
function clear(state)
```

Implements the `clear` operation for `miniquake.console` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `clear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L379)

<a id="function-function-miniquake-console-clearexpiredcenter-function-clearexpiredcenter-state-currenttime-src-miniquake-console-ml-521621170"></a>
### clearExpiredCenter

```ml
function clearExpiredCenter(state, currentTime)
```

Update module state for expired center.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `clearExpiredCenter`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L734)

<a id="function-function-miniquake-console-con-cancelnotifybox-function-con-cancelnotifybox-state-src-miniquake-console-ml-299568154"></a>
### Con_CancelNotifyBox

```ml
function Con_CancelNotifyBox(state)
```

Mirror Quake's Con_CancelNotifyBox routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_CancelNotifyBox`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L603)

<a id="function-function-miniquake-console-con-checkresize-function-con-checkresize-state-pixelwidth-src-miniquake-console-ml-943966842"></a>
### Con_CheckResize

```ml
function Con_CheckResize(state, pixelWidth)
```

Mirror Quake's Con_CheckResize routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_CheckResize`. |
| `pixelWidth` | `dynamic` | — | The pixel width input consumed by `Con_CheckResize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L127)

<a id="function-function-miniquake-console-con-clear-f-function-con-clear-f-state-src-miniquake-console-ml-1365921066"></a>
### Con_Clear_f

```ml
function Con_Clear_f(state)
```

Mirror Quake's Con_Clear_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Clear_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L369)

<a id="function-function-miniquake-console-con-clearnotify-function-con-clearnotify-state-src-miniquake-console-ml-1029501082"></a>
### Con_ClearNotify

```ml
function Con_ClearNotify(state)
```

Mirror Quake's Con_ClearNotify routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_ClearNotify`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L119)

<a id="function-function-miniquake-console-con-commandtrace-function-con-commandtrace-state-src-miniquake-console-ml-1547665468"></a>
### Con_CommandTrace

```ml
function Con_CommandTrace(state)
```

Mirror Quake's Con_CommandTrace routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_CommandTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L752)

<a id="function-function-miniquake-console-con-consolerows-function-con-consolerows-state-pixellines-src-miniquake-console-ml-551088485"></a>
### Con_ConsoleRows

```ml
function Con_ConsoleRows(state, pixelLines)
```

Mirror Quake's Con_ConsoleRows routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_ConsoleRows`. |
| `pixelLines` | `dynamic` | — | The pixel lines input consumed by `Con_ConsoleRows`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L517)

<a id="function-function-miniquake-console-con-debuglog-function-con-debuglog-state-filename-text-src-miniquake-console-ml-1487599590"></a>
### Con_DebugLog

```ml
function Con_DebugLog(state, filename, text)
```

Mirror Quake's Con_DebugLog routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_DebugLog`. |
| `filename` | `dynamic` | — | Path of the file to process. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L324)

<a id="function-function-miniquake-console-con-dprintf-function-con-dprintf-state-message-developer-dedicated-loadingdisabled-src-miniquake-console-ml-1403072492"></a>
### Con_DPrintf

```ml
function Con_DPrintf(state, message, developer, dedicated, loadingDisabled)
```

Mirror Quake's Con_DPrintf routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_DPrintf`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |
| `developer` | `dynamic` | — | The developer input consumed by `Con_DPrintf`. |
| `dedicated` | `dynamic` | — | The dedicated input consumed by `Con_DPrintf`. |
| `loadingDisabled` | `dynamic` | — | The loading disabled input consumed by `Con_DPrintf`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L351)

<a id="function-function-miniquake-console-con-drawconsole-function-con-drawconsole-state-pixellines-drawinput-realtime-src-miniquake-console-ml-1086326700"></a>
### Con_DrawConsole

```ml
function Con_DrawConsole(state, pixelLines, drawInput, realtime)
```

Mirror Quake's Con_DrawConsole routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_DrawConsole`. |
| `pixelLines` | `dynamic` | — | The pixel lines input consumed by `Con_DrawConsole`. |
| `drawInput` | `dynamic` | — | The draw input input consumed by `Con_DrawConsole`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L538)

<a id="function-function-miniquake-console-con-drawinput-function-con-drawinput-state-realtime-src-miniquake-console-ml-2058222447"></a>
### Con_DrawInput

```ml
function Con_DrawInput(state, realtime)
```

Mirror Quake's Con_DrawInput routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_DrawInput`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L435)

<a id="function-function-miniquake-console-con-drawnotify-function-con-drawnotify-state-realtime-notifytime-messagemode-chattext-src-miniquake-console-ml-1957396056"></a>
### Con_DrawNotify

```ml
function Con_DrawNotify(state, realtime, notifyTime, messageMode, chatText)
```

Mirror Quake's Con_DrawNotify routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_DrawNotify`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `notifyTime` | `dynamic` | — | Time value used by the operation. |
| `messageMode` | `dynamic` | — | The message mode input consumed by `Con_DrawNotify`. |
| `chatText` | `dynamic` | — | The chat text input consumed by `Con_DrawNotify`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L492)

<a id="function-function-miniquake-console-con-init-function-con-init-state-filesystem-pixelwidth-debuglog-src-miniquake-console-ml-1431265680"></a>
### Con_Init

```ml
function Con_Init(state, filesystem, pixelWidth, debugLog)
```

Mirror Quake's Con_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Init`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `Con_Init`. |
| `pixelWidth` | `dynamic` | — | The pixel width input consumed by `Con_Init`. |
| `debugLog` | `dynamic` | — | The debug log input consumed by `Con_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L182)

<a id="function-function-miniquake-console-con-linefeed-function-con-linefeed-state-src-miniquake-console-ml-1311996664"></a>
### Con_Linefeed

```ml
function Con_Linefeed(state)
```

Mirror Quake's Con_Linefeed routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Linefeed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L201)

<a id="function-function-miniquake-console-con-logcenterprint-function-con-logcenterprint-state-text-realtime-src-miniquake-console-ml-1002890770"></a>
### Con_LogCenterPrint

```ml
function Con_LogCenterPrint(state, text, realtime)
```

Mirror Quake's Con_LogCenterPrint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_LogCenterPrint`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L629)

<a id="function-function-miniquake-console-con-messagemode2-f-function-con-messagemode2-f-state-src-miniquake-console-ml-2033213756"></a>
### Con_MessageMode2_f

```ml
function Con_MessageMode2_f(state)
```

Mirror Quake's Con_MessageMode2_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_MessageMode2_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L427)

<a id="function-function-miniquake-console-con-messagemode-f-function-con-messagemode-f-state-src-miniquake-console-ml-309096412"></a>
### Con_MessageMode_f

```ml
function Con_MessageMode_f(state)
```

Mirror Quake's Con_MessageMode_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_MessageMode_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L420)

<a id="function-function-miniquake-console-con-notify-function-con-notify-state-text-src-miniquake-console-ml-1858773635"></a>
### Con_Notify

```ml
function Con_Notify(state, text)
```

Mirror Quake's Con_Notify routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Notify`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L638)

<a id="function-function-miniquake-console-con-notifybox-function-con-notifybox-state-text-src-miniquake-console-ml-307977985"></a>
### Con_NotifyBox

```ml
function Con_NotifyBox(state, text)
```

Mirror Quake's Con_NotifyBox routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_NotifyBox`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L561)

<a id="function-function-miniquake-console-con-notifyboxkey-function-con-notifyboxkey-state-down-src-miniquake-console-ml-1507938508"></a>
### Con_NotifyBoxKey

```ml
function Con_NotifyBoxKey(state, down)
```

Mirror Quake's Con_NotifyBoxKey routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_NotifyBoxKey`. |
| `down` | `dynamic` | — | The down input consumed by `Con_NotifyBoxKey`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L584)

<a id="function-function-miniquake-console-con-notifyboxpending-inline-function-con-notifyboxpending-src-miniquake-console-ml-826493970"></a>
### Con_NotifyBoxPending

```ml
inline function Con_NotifyBoxPending()
```

Mirror Quake's Con_NotifyBoxPending routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L577)

<a id="function-function-miniquake-console-con-notifyrows-function-con-notifyrows-state-realtime-notifytime-src-miniquake-console-ml-188051917"></a>
### Con_NotifyRows

```ml
function Con_NotifyRows(state, realtime, notifyTime)
```

Mirror Quake's Con_NotifyRows routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_NotifyRows`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `notifyTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L458)

<a id="function-function-miniquake-console-con-print-function-con-print-state-text-realtime-src-miniquake-console-ml-226015086"></a>
### Con_Print

```ml
function Con_Print(state, text, realtime)
```

Mirror Quake's Con_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Print`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L270)

<a id="function-function-miniquake-console-con-print-f-function-con-print-f-state-arguments-src-miniquake-console-ml-1241189032"></a>
### Con_Print_f

```ml
function Con_Print_f(state, arguments)
```

Mirror Quake's Con_Print_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Print_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L614)

<a id="function-function-miniquake-console-con-printf-function-con-printf-state-message-dedicated-loadingdisabled-src-miniquake-console-ml-1521366218"></a>
### Con_Printf

```ml
function Con_Printf(state, message, dedicated, loadingDisabled)
```

Mirror Quake's Con_Printf routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_Printf`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |
| `dedicated` | `dynamic` | — | The dedicated input consumed by `Con_Printf`. |
| `loadingDisabled` | `dynamic` | — | The loading disabled input consumed by `Con_Printf`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L335)

<a id="function-function-miniquake-console-con-safeprintf-function-con-safeprintf-state-message-dedicated-src-miniquake-console-ml-1836434440"></a>
### Con_SafePrintf

```ml
function Con_SafePrintf(state, message, dedicated)
```

Mirror Quake's Con_SafePrintf routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_SafePrintf`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |
| `dedicated` | `dynamic` | — | The dedicated input consumed by `Con_SafePrintf`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L360)

<a id="function-function-miniquake-console-con-setrealtime-function-con-setrealtime-state-realtime-src-miniquake-console-ml-738974841"></a>
### Con_SetRealtime

```ml
function Con_SetRealtime(state, realtime)
```

Mirror Quake's Con_SetRealtime routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_SetRealtime`. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L745)

<a id="constant-constant-miniquake-console-con-textsize-const-con-textsize-16384-src-miniquake-console-ml-1120857808"></a>
### CON_TEXTSIZE

```ml
const CON_TEXTSIZE = 16384
```

Defines the con textsize value used by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L17)

<a id="function-function-miniquake-console-con-toggleconsole-f-function-con-toggleconsole-f-state-connected-src-miniquake-console-ml-1164675051"></a>
### Con_ToggleConsole_f

```ml
function Con_ToggleConsole_f(state, connected)
```

Mirror Quake's Con_ToggleConsole_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `Con_ToggleConsole_f`. |
| `connected` | `dynamic` | — | The connected input consumed by `Con_ToggleConsole_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L386)

<a id="function-function-miniquake-console-create-function-create-maxlines-src-miniquake-console-ml-819298680"></a>
### create

```ml
function create(maxLines)
```

Implements the `create` operation for `miniquake.console` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxLines` | `dynamic` | — | The max lines input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L52)

<a id="constant-constant-miniquake-console-default-linewidth-const-default-linewidth-38-src-miniquake-console-ml-625282933"></a>
### DEFAULT_LINEWIDTH

```ml
const DEFAULT_LINEWIDTH = 38
```

Defines the default linewidth value used by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L21)

<a id="function-function-miniquake-console-filledbytes-function-filledbytes-count-value-src-miniquake-console-ml-2077056783"></a>
### filledBytes

```ml
function filledBytes(count, value)
```

Return filled bytes derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `value` | `dynamic` | — | Value consumed by `filledBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L35)

<a id="function-function-miniquake-console-linebytes-function-linebytes-state-logicalline-src-miniquake-console-ml-546911805"></a>
### lineBytes

```ml
function lineBytes(state, logicalLine)
```

Return line bytes derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `lineBytes`. |
| `logicalLine` | `dynamic` | — | The logical line input consumed by `lineBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L218)

<a id="constant-constant-miniquake-console-maxcmdline-const-maxcmdline-256-src-miniquake-console-ml-35984473"></a>
### MAXCMDLINE

```ml
const MAXCMDLINE = 256
```

Defines the maxcmdline value used by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L23)

<a id="global-global-miniquake-console-notifyboxsawdown-notifyboxsawdown-src-miniquake-console-ml-1051042959"></a>
### notifyBoxSawDown

```ml
notifyBoxSawDown
```

Tracks the module-level notify box saw down state owned by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L30)

<a id="global-global-miniquake-console-notifyboxwaiting-notifyboxwaiting-src-miniquake-console-ml-632582487"></a>
### notifyBoxWaiting

```ml
notifyBoxWaiting
```

Tracks the module-level notify box waiting state owned by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L28)

<a id="constant-constant-miniquake-console-num-con-times-const-num-con-times-4-src-miniquake-console-ml-1512829912"></a>
### NUM_CON_TIMES

```ml
const NUM_CON_TIMES = 4
```

Defines the num con times value used by `miniquake.console`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L19)

<a id="function-function-miniquake-console-printableline-function-printableline-raw-src-miniquake-console-ml-1961165661"></a>
### printableLine

```ml
function printableLine(raw)
```

Implements the `printableLine` operation for `miniquake.console` (printable line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — | The raw input consumed by `printableLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L233)

<a id="function-function-miniquake-console-setactive-function-setactive-state-active-src-miniquake-console-ml-706527786"></a>
### setActive

```ml
function setActive(state, active)
```

Update module state for active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `setActive`. |
| `active` | `dynamic` | — | The active input consumed by `setActive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L413)

<a id="function-function-miniquake-console-setbackscroll-function-setbackscroll-value-src-miniquake-console-ml-1446277208"></a>
### setBackscroll

```ml
function setBackscroll(value)
```

Update module state for backscroll.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `setBackscroll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L97)

<a id="function-function-miniquake-console-setinput-function-setinput-state-text-src-miniquake-console-ml-1036750207"></a>
### setInput

```ml
function setInput(state, text)
```

Update module state for input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `setInput`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L687)

<a id="function-function-miniquake-console-synclines-function-synclines-state-src-miniquake-console-ml-301120988"></a>
### syncLines

```ml
function syncLines(state)
```

Update module state for lines.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `syncLines`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L251)

<a id="function-function-miniquake-console-takeinput-function-takeinput-state-src-miniquake-console-ml-339011534"></a>
### takeInput

```ml
function takeInput(state)
```

Consume pending state for take input.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `takeInput`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L713)

<a id="function-function-miniquake-console-toggle-function-toggle-state-src-miniquake-console-ml-322118532"></a>
### toggle

```ml
function toggle(state)
```

Update subsystem configuration for toggle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `toggle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L404)

<a id="function-function-miniquake-console-trimoldest-function-trimoldest-lines-maximum-src-miniquake-console-ml-1609186330"></a>
### trimOldest

```ml
function trimOldest(lines, maximum)
```

Implements the `trimOldest` operation for `miniquake.console` (trim oldest).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lines` | `dynamic` | — | The lines input consumed by `trimOldest`. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L661)

<a id="function-function-miniquake-console-visiblelines-function-visiblelines-state-count-src-miniquake-console-ml-341237981"></a>
### visibleLines

```ml
function visibleLines(state, count)
```

Report whether visible lines holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.console` state used by `visibleLines`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L673)

<a id="function-function-miniquake-console-zerotimes-function-zerotimes-src-miniquake-console-ml-1885154281"></a>
### zeroTimes

```ml
function zeroTimes()
```

Create the zero-initialized state for times.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/console.ml#L46)
