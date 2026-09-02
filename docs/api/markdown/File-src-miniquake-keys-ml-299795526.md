# `src/miniquake/keys.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.keys`](Package-miniquake-keys-849482823.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/cmd.ml` as `cmd` → [src/miniquake/cmd.ml](File-src-miniquake-cmd-ml-1014778996.md)
- `miniquake/console.ml` as `console` → [src/miniquake/console.ml](File-src-miniquake-console-ml-296415787.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/input.ml` as `input` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)

## Declarations

<a id="function-function-miniquake-keys-beginmessage-function-beginmessage-team-src-miniquake-keys-ml-694171710"></a>
### beginMessage

```ml
function beginMessage(team)
```

Initialize state for begin message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `team` | `dynamic` | — | The team input consumed by `beginMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L154)

<a id="global-global-miniquake-keys-chatbuffer-chatbuffer-src-miniquake-keys-ml-1010871361"></a>
### chatBuffer

```ml
chatBuffer
```

Tracks the module-level chat buffer state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L113)

<a id="global-global-miniquake-keys-consolekeys-consolekeys-src-miniquake-keys-ml-1649328297"></a>
### consoleKeys

```ml
consoleKeys
```

Tracks the module-level console keys state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L103)

<a id="function-function-miniquake-keys-destination-inline-function-destination-src-miniquake-keys-ml-398234300"></a>
### destination

```ml
inline function destination()
```

Implements the `destination` operation for `miniquake.keys` (destination).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L148)

<a id="global-global-miniquake-keys-editline-editline-src-miniquake-keys-ml-1240859745"></a>
### editLine

```ml
editLine
```

Tracks the module-level edit line state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L95)

<a id="function-function-miniquake-keys-hardwarekeycodes-function-hardwarekeycodes-src-miniquake-keys-ml-156599689"></a>
### hardwareKeyCodes

```ml
function hardwareKeyCodes()
```

Implements the `hardwareKeyCodes` operation for `miniquake.keys` (hardware key codes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L574)

<a id="global-global-miniquake-keys-historyline-historyline-src-miniquake-keys-ml-1964712321"></a>
### historyLine

```ml
historyLine
```

Tracks the module-level history line state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L97)

<a id="function-function-miniquake-keys-identityvalues-function-identityvalues-count-src-miniquake-keys-ml-1976745570"></a>
### identityValues

```ml
function identityValues(count)
```

Return identity values derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L129)

<a id="function-function-miniquake-keys-initializeshifttable-function-initializeshifttable-src-miniquake-keys-ml-11326281"></a>
### initializeShiftTable

```ml
function initializeShiftTable()
```

Initialize state for initialize shift table.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L241)

<a id="constant-constant-miniquake-keys-k-alt-const-k-alt-132-src-miniquake-keys-ml-1497407458"></a>
### K_ALT

```ml
const K_ALT = 132
```

Defines the k alt value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L48)

<a id="constant-constant-miniquake-keys-k-aux1-const-k-aux1-207-src-miniquake-keys-ml-1270059387"></a>
### K_AUX1

```ml
const K_AUX1 = 207
```

Defines the k aux1 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L78)

<a id="constant-constant-miniquake-keys-k-backspace-const-k-backspace-127-src-miniquake-keys-ml-1577346608"></a>
### K_BACKSPACE

```ml
const K_BACKSPACE = 127
```

Defines the k backspace value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L38)

<a id="constant-constant-miniquake-keys-k-ctrl-const-k-ctrl-133-src-miniquake-keys-ml-230975849"></a>
### K_CTRL

```ml
const K_CTRL = 133
```

Defines the k ctrl value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L50)

<a id="constant-constant-miniquake-keys-k-del-const-k-del-148-src-miniquake-keys-ml-1165305907"></a>
### K_DEL

```ml
const K_DEL = 148
```

Defines the k del value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L60)

<a id="constant-constant-miniquake-keys-k-downarrow-const-k-downarrow-129-src-miniquake-keys-ml-1462309954"></a>
### K_DOWNARROW

```ml
const K_DOWNARROW = 129
```

Defines the k downarrow value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L42)

<a id="constant-constant-miniquake-keys-k-end-const-k-end-152-src-miniquake-keys-ml-424821064"></a>
### K_END

```ml
const K_END = 152
```

Defines the k end value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L68)

<a id="constant-constant-miniquake-keys-k-enter-const-k-enter-13-src-miniquake-keys-ml-362054110"></a>
### K_ENTER

```ml
const K_ENTER = 13
```

Defines the k enter value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L32)

<a id="constant-constant-miniquake-keys-k-escape-const-k-escape-27-src-miniquake-keys-ml-833302873"></a>
### K_ESCAPE

```ml
const K_ESCAPE = 27
```

Defines the k escape value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L34)

<a id="constant-constant-miniquake-keys-k-f1-const-k-f1-135-src-miniquake-keys-ml-370495435"></a>
### K_F1

```ml
const K_F1 = 135
```

Defines the k f1 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L54)

<a id="constant-constant-miniquake-keys-k-f12-const-k-f12-146-src-miniquake-keys-ml-989599537"></a>
### K_F12

```ml
const K_F12 = 146
```

Defines the k f12 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L56)

<a id="constant-constant-miniquake-keys-k-home-const-k-home-151-src-miniquake-keys-ml-428111085"></a>
### K_HOME

```ml
const K_HOME = 151
```

Defines the k home value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L66)

<a id="constant-constant-miniquake-keys-k-ins-const-k-ins-147-src-miniquake-keys-ml-1346732458"></a>
### K_INS

```ml
const K_INS = 147
```

Defines the k ins value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L58)

<a id="constant-constant-miniquake-keys-k-joy1-const-k-joy1-203-src-miniquake-keys-ml-2130790551"></a>
### K_JOY1

```ml
const K_JOY1 = 203
```

Defines the k joy1 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L76)

<a id="constant-constant-miniquake-keys-k-leftarrow-const-k-leftarrow-130-src-miniquake-keys-ml-1785764704"></a>
### K_LEFTARROW

```ml
const K_LEFTARROW = 130
```

Defines the k leftarrow value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L44)

<a id="constant-constant-miniquake-keys-k-mouse1-const-k-mouse1-200-src-miniquake-keys-ml-696252724"></a>
### K_MOUSE1

```ml
const K_MOUSE1 = 200
```

Defines the k mouse1 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L70)

<a id="constant-constant-miniquake-keys-k-mouse2-const-k-mouse2-201-src-miniquake-keys-ml-1658254257"></a>
### K_MOUSE2

```ml
const K_MOUSE2 = 201
```

Defines the k mouse2 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L72)

<a id="constant-constant-miniquake-keys-k-mouse3-const-k-mouse3-202-src-miniquake-keys-ml-97500498"></a>
### K_MOUSE3

```ml
const K_MOUSE3 = 202
```

Defines the k mouse3 value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L74)

<a id="constant-constant-miniquake-keys-k-mwheeldown-const-k-mwheeldown-240-src-miniquake-keys-ml-838185404"></a>
### K_MWHEELDOWN

```ml
const K_MWHEELDOWN = 240
```

Defines the k mwheeldown value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L82)

<a id="constant-constant-miniquake-keys-k-mwheelup-const-k-mwheelup-239-src-miniquake-keys-ml-1324006758"></a>
### K_MWHEELUP

```ml
const K_MWHEELUP = 239
```

Defines the k mwheelup value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L80)

<a id="constant-constant-miniquake-keys-k-pause-const-k-pause-255-src-miniquake-keys-ml-1865261292"></a>
### K_PAUSE

```ml
const K_PAUSE = 255
```

Defines the k pause value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L84)

<a id="constant-constant-miniquake-keys-k-pgdn-const-k-pgdn-149-src-miniquake-keys-ml-1414956160"></a>
### K_PGDN

```ml
const K_PGDN = 149
```

Defines the k pgdn value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L62)

<a id="constant-constant-miniquake-keys-k-pgup-const-k-pgup-150-src-miniquake-keys-ml-243326232"></a>
### K_PGUP

```ml
const K_PGUP = 150
```

Defines the k pgup value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L64)

<a id="constant-constant-miniquake-keys-k-rightarrow-const-k-rightarrow-131-src-miniquake-keys-ml-111298523"></a>
### K_RIGHTARROW

```ml
const K_RIGHTARROW = 131
```

Defines the k rightarrow value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L46)

<a id="constant-constant-miniquake-keys-k-shift-const-k-shift-134-src-miniquake-keys-ml-554219436"></a>
### K_SHIFT

```ml
const K_SHIFT = 134
```

Defines the k shift value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L52)

<a id="constant-constant-miniquake-keys-k-space-const-k-space-32-src-miniquake-keys-ml-1764130823"></a>
### K_SPACE

```ml
const K_SPACE = 32
```

Defines the k space value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L36)

<a id="constant-constant-miniquake-keys-k-tab-const-k-tab-9-src-miniquake-keys-ml-412041495"></a>
### K_TAB

```ml
const K_TAB = 9
```

Defines the k tab value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L30)

<a id="constant-constant-miniquake-keys-k-uparrow-const-k-uparrow-128-src-miniquake-keys-ml-2031035469"></a>
### K_UPARROW

```ml
const K_UPARROW = 128
```

Defines the k uparrow value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L40)

<a id="function-function-miniquake-keys-key-bind-f-function-key-bind-f-arguments-src-miniquake-keys-ml-625624919"></a>
### Key_Bind_f

```ml
function Key_Bind_f(arguments)
```

Mirror Quake's Key_Bind_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L207)

<a id="function-function-miniquake-keys-key-bindlist-f-function-key-bindlist-f-src-miniquake-keys-ml-948677329"></a>
### Key_Bindlist_f

```ml
function Key_Bindlist_f()
```

Mirror Quake's Key_Bindlist_f routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L222)

<a id="function-function-miniquake-keys-key-clearstates-function-key-clearstates-src-miniquake-keys-ml-833167183"></a>
### Key_ClearStates

```ml
function Key_ClearStates()
```

Mirror Quake's Key_ClearStates routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L524)

<a id="constant-constant-miniquake-keys-key-console-const-key-console-1-src-miniquake-keys-ml-1583814463"></a>
### KEY_CONSOLE

```ml
const KEY_CONSOLE = 1
```

Defines the key console value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L23)

<a id="function-function-miniquake-keys-key-console-function-key-console-key-state-commandsystem-registry-visiblerows-src-miniquake-keys-ml-21090109"></a>
### Key_Console

```ml
function Key_Console(key, state, commandSystem, registry, visibleRows)
```

Mirror Quake's Key_Console routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `state` | `dynamic` | — | Mutable `miniquake.keys` state used by `Key_Console`. |
| `commandSystem` | `dynamic` | — | The command system input consumed by `Key_Console`. |
| `registry` | `dynamic` | — | The registry input consumed by `Key_Console`. |
| `visibleRows` | `dynamic` | — | The visible rows input consumed by `Key_Console`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L337)

<a id="function-function-miniquake-keys-key-event-function-key-event-key-down-consolestate-commandsystem-registry-forcedconsole-demoplayback-src-miniquake-keys-ml-602544043"></a>
### Key_Event

```ml
function Key_Event(key, down, consoleState, commandSystem, registry, forcedConsole, demoPlayback)
```

Returns [commands-to-buffer, host-action, routed-key]. Host actions are intentionally small: menu policy stays in menu/host while key routing and binding semantics remain wholly owned here.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `down` | `dynamic` | — | The down input consumed by `Key_Event`. |
| `consoleState` | `dynamic` | — | Mutable state used by `Key_Event`. |
| `commandSystem` | `dynamic` | — | The command system input consumed by `Key_Event`. |
| `registry` | `dynamic` | — | The registry input consumed by `Key_Event`. |
| `forcedConsole` | `dynamic` | — | The forced console input consumed by `Key_Event`. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `Key_Event`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L464)

<a id="constant-constant-miniquake-keys-key-game-const-key-game-0-src-miniquake-keys-ml-2131913350"></a>
### KEY_GAME

```ml
const KEY_GAME = 0
```

Defines the key game value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L21)

<a id="function-function-miniquake-keys-key-init-function-key-init-src-miniquake-keys-ml-1665781265"></a>
### Key_Init

```ml
function Key_Init()
```

Mirror Quake's Key_Init routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L273)

<a id="function-function-miniquake-keys-key-keynumtostring-function-key-keynumtostring-keynum-src-miniquake-keys-ml-796072502"></a>
### Key_KeynumToString

```ml
function Key_KeynumToString(keynum)
```

Mirror Quake's Key_KeynumToString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keynum` | `dynamic` | — | The keynum input consumed by `Key_KeynumToString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L173)

<a id="constant-constant-miniquake-keys-key-menu-const-key-menu-3-src-miniquake-keys-ml-9440457"></a>
### KEY_MENU

```ml
const KEY_MENU = 3
```

Defines the key menu value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L27)

<a id="constant-constant-miniquake-keys-key-message-const-key-message-2-src-miniquake-keys-ml-1425551910"></a>
### KEY_MESSAGE

```ml
const KEY_MESSAGE = 2
```

Defines the key message value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L25)

<a id="function-function-miniquake-keys-key-message-function-key-message-key-src-miniquake-keys-ml-276689068"></a>
### Key_Message

```ml
function Key_Message(key)
```

Mirror Quake's Key_Message routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L419)

<a id="function-function-miniquake-keys-key-queuereleaseallcommands-function-key-queuereleaseallcommands-src-miniquake-keys-ml-2116092671"></a>
### Key_QueueReleaseAllCommands

```ml
function Key_QueueReleaseAllCommands()
```

Mirror Quake's Key_QueueReleaseAllCommands routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L559)

<a id="function-function-miniquake-keys-key-releaseallcommands-function-key-releaseallcommands-src-miniquake-keys-ml-1962774633"></a>
### Key_ReleaseAllCommands

```ml
function Key_ReleaseAllCommands()
```

gl_vidnt.c::ClearAllStates sends an up event for every Quake key before clearing the physical key table.  The releases are deliberately generated for every + binding, not only keys that still appear down: this is how the original clears server-side button state after Alt-Tab and mode changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L540)

<a id="function-function-miniquake-keys-key-setbinding-function-key-setbinding-keynum-binding-src-miniquake-keys-ml-1058343989"></a>
### Key_SetBinding

```ml
function Key_SetBinding(keynum, binding)
```

Mirror Quake's Key_SetBinding routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keynum` | `dynamic` | — | The keynum input consumed by `Key_SetBinding`. |
| `binding` | `dynamic` | — | The binding input consumed by `Key_SetBinding`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L180)

<a id="function-function-miniquake-keys-key-stringtokeynum-function-key-stringtokeynum-text-src-miniquake-keys-ml-415866240"></a>
### Key_StringToKeynum

```ml
function Key_StringToKeynum(text)
```

Mirror Quake's Key_StringToKeynum routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L164)

<a id="function-function-miniquake-keys-key-takependingcommands-function-key-takependingcommands-src-miniquake-keys-ml-2041325321"></a>
### Key_TakePendingCommands

```ml
function Key_TakePendingCommands()
```

Mirror Quake's Key_TakePendingCommands routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L566)

<a id="function-function-miniquake-keys-key-unbind-f-function-key-unbind-f-arguments-src-miniquake-keys-ml-429049423"></a>
### Key_Unbind_f

```ml
function Key_Unbind_f(arguments)
```

Mirror Quake's Key_Unbind_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L187)

<a id="function-function-miniquake-keys-key-unbindall-f-function-key-unbindall-f-src-miniquake-keys-ml-1260953109"></a>
### Key_Unbindall_f

```ml
function Key_Unbindall_f()
```

Mirror Quake's Key_Unbindall_f routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L196)

<a id="function-function-miniquake-keys-key-writebindings-function-key-writebindings-src-miniquake-keys-ml-518146091"></a>
### Key_WriteBindings

```ml
function Key_WriteBindings()
```

Mirror Quake's Key_WriteBindings routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L236)

<a id="global-global-miniquake-keys-keycount-keycount-src-miniquake-keys-ml-1249037097"></a>
### keyCount

```ml
keyCount
```

Tracks the module-level key count state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L101)

<a id="global-global-miniquake-keys-keydest-keydest-src-miniquake-keys-ml-384438849"></a>
### keyDest

```ml
keyDest
```

Tracks the module-level key dest state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L99)

<a id="global-global-miniquake-keys-keydownstates-keydownstates-src-miniquake-keys-ml-482437185"></a>
### keyDownStates

```ml
keyDownStates
```

Tracks the module-level key down states state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L111)

<a id="global-global-miniquake-keys-keylastpress-keylastpress-src-miniquake-keys-ml-1937646561"></a>
### keyLastPress

```ml
keyLastPress
```

Tracks the module-level key last press state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L93)

<a id="global-global-miniquake-keys-keylinepos-keylinepos-src-miniquake-keys-ml-93635683"></a>
### keyLinePos

```ml
keyLinePos
```

Tracks the module-level key line pos state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L89)

<a id="global-global-miniquake-keys-keylines-keylines-src-miniquake-keys-ml-181304257"></a>
### keyLines

```ml
keyLines
```

Tracks the module-level key lines state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L87)

<a id="global-global-miniquake-keys-keyrepeats-keyrepeats-src-miniquake-keys-ml-1277832231"></a>
### keyRepeats

```ml
keyRepeats
```

Tracks the module-level key repeats state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L109)

<a id="global-global-miniquake-keys-keyshift-keyshift-src-miniquake-keys-ml-467867195"></a>
### keyShift

```ml
keyShift
```

Tracks the module-level key shift state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L107)

<a id="constant-constant-miniquake-keys-maxcmdline-const-maxcmdline-256-src-miniquake-keys-ml-1308395991"></a>
### MAXCMDLINE

```ml
const MAXCMDLINE = 256
```

Defines the maxcmdline value used by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L19)

<a id="global-global-miniquake-keys-menubound-menubound-src-miniquake-keys-ml-1224272537"></a>
### menuBound

```ml
menuBound
```

Tracks the module-level menu bound state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L105)

<a id="global-global-miniquake-keys-pendingreleasecommands-pendingreleasecommands-src-miniquake-keys-ml-1502123313"></a>
### pendingReleaseCommands

```ml
pendingReleaseCommands
```

Tracks the module-level pending release commands state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L119)

<a id="function-function-miniquake-keys-plusrelease-function-plusrelease-binding-key-src-miniquake-keys-ml-203692999"></a>
### plusRelease

```ml
function plusRelease(binding, key)
```

Implements the `plusRelease` operation for `miniquake.keys` (plus release).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `binding` | `dynamic` | — | The binding input consumed by `plusRelease`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L447)

<a id="function-function-miniquake-keys-pollevents-function-pollevents-src-miniquake-keys-ml-732576093"></a>
### PollEvents

```ml
function PollEvents()
```

Consumes the ordered Win32 message queue. Packed native event types are: keyboard=1 (legacy raw VK), mouse button=2, wheel=3, focus=4, and keyboard=5 (MiniQuake hardware scan code).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L606)

<a id="global-global-miniquake-keys-registeredcommandnames-registeredcommandnames-src-miniquake-keys-ml-1397367703"></a>
### registeredCommandNames

```ml
registeredCommandNames
```

Tracks the module-level registered command names state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L117)

<a id="function-function-miniquake-keys-setdestination-function-setdestination-destination-src-miniquake-keys-ml-1984829807"></a>
### setDestination

```ml
function setDestination(destination)
```

Update module state for destination.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L141)

<a id="global-global-miniquake-keys-shiftdown-shiftdown-src-miniquake-keys-ml-1862059757"></a>
### shiftDown

```ml
shiftDown
```

Tracks the module-level shift down state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L91)

<a id="global-global-miniquake-keys-teammessage-teammessage-src-miniquake-keys-ml-1867243565"></a>
### teamMessage

```ml
teamMessage
```

Tracks the module-level team message state owned by `miniquake.keys`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L115)

<a id="function-function-miniquake-keys-zerovalues-function-zerovalues-count-src-miniquake-keys-ml-298021674"></a>
### zeroValues

```ml
function zeroValues(count)
```

Create the zero-initialized state for values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/keys.ml#L123)
