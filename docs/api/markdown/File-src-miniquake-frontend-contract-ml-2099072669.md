# `src/miniquake/frontend_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.frontend_contract`](Package-miniquake-frontend-contract-1637790782.md)

Reachable from entry: **no**

## Imports

- `miniquake/console.ml` as `frontendConsole` → [src/miniquake/console.ml](File-src-miniquake-console-ml-296415787.md)
- `miniquake/gl_vidnt.ml` as `frontendVideo` → [src/miniquake/gl_vidnt.ml](File-src-miniquake-gl-vidnt-ml-1573847321.md)
- `miniquake/input.ml` as `frontendInput` → [src/miniquake/input.ml](File-src-miniquake-input-ml-1422374844.md)
- `miniquake/keys.ml` as `frontendKeys` → [src/miniquake/keys.ml](File-src-miniquake-keys-ml-299795526.md)
- `miniquake/menu.ml` as `frontendMenu` → [src/miniquake/menu.ml](File-src-miniquake-menu-ml-537231111.md)

## Declarations

<a id="constant-constant-miniquake-frontend-contract-chat-bytes-const-chat-bytes-31-src-miniquake-frontend-contract-ml-1600312610"></a>
### CHAT_BYTES

```ml
const CHAT_BYTES = 31
```

Defines the chat bytes value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L27)

<a id="constant-constant-miniquake-frontend-contract-console-text-bytes-const-console-text-bytes-16384-src-miniquake-frontend-contract-ml-661778464"></a>
### CONSOLE_TEXT_BYTES

```ml
const CONSOLE_TEXT_BYTES = 16384
```

Defines the console text bytes value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L29)

<a id="constant-constant-miniquake-frontend-contract-fingerprint-const-fingerprint-2453819898-src-miniquake-frontend-contract-ml-1591351079"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 2453819898
```

Defines the fingerprint value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L19)

<a id="constant-constant-miniquake-frontend-contract-help-pages-const-help-pages-6-src-miniquake-frontend-contract-ml-2054357392"></a>
### HELP_PAGES

```ml
const HELP_PAGES = 6
```

Defines the help pages value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L39)

<a id="constant-constant-miniquake-frontend-contract-history-lines-const-history-lines-32-src-miniquake-frontend-contract-ml-1539589599"></a>
### HISTORY_LINES

```ml
const HISTORY_LINES = 32
```

Defines the history lines value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L23)

<a id="constant-constant-miniquake-frontend-contract-joystick-axes-const-joystick-axes-6-src-miniquake-frontend-contract-ml-2140001754"></a>
### JOYSTICK_AXES

```ml
const JOYSTICK_AXES = 6
```

Defines the joystick axes value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L33)

<a id="constant-constant-miniquake-frontend-contract-key-count-const-key-count-256-src-miniquake-frontend-contract-ml-738187871"></a>
### KEY_COUNT

```ml
const KEY_COUNT = 256
```

Defines the key count value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L21)

<a id="constant-constant-miniquake-frontend-contract-max-command-line-const-max-command-line-256-src-miniquake-frontend-contract-ml-929591647"></a>
### MAX_COMMAND_LINE

```ml
const MAX_COMMAND_LINE = 256
```

Defines the max command line value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L25)

<a id="constant-constant-miniquake-frontend-contract-max-video-descriptions-const-max-video-descriptions-27-src-miniquake-frontend-contract-ml-1273533059"></a>
### MAX_VIDEO_DESCRIPTIONS

```ml
const MAX_VIDEO_DESCRIPTIONS = 27
```

Defines the max video descriptions value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L43)

<a id="constant-constant-miniquake-frontend-contract-max-video-modes-const-max-video-modes-30-src-miniquake-frontend-contract-ml-729569397"></a>
### MAX_VIDEO_MODES

```ml
const MAX_VIDEO_MODES = 30
```

Defines the max video modes value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L41)

<a id="constant-constant-miniquake-frontend-contract-mouse-buttons-const-mouse-buttons-3-src-miniquake-frontend-contract-ml-948026195"></a>
### MOUSE_BUTTONS

```ml
const MOUSE_BUTTONS = 3
```

Defines the mouse buttons value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L35)

<a id="constant-constant-miniquake-frontend-contract-notify-ack-edges-const-notify-ack-edges-2-src-miniquake-frontend-contract-ml-1144773800"></a>
### NOTIFY_ACK_EDGES

```ml
const NOTIFY_ACK_EDGES = 2
```

Defines the notify ack edges value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L45)

<a id="constant-constant-miniquake-frontend-contract-notify-times-const-notify-times-4-src-miniquake-frontend-contract-ml-1117724198"></a>
### NOTIFY_TIMES

```ml
const NOTIFY_TIMES = 4
```

Defines the notify times value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L31)

<a id="constant-constant-miniquake-frontend-contract-options-items-const-options-items-14-src-miniquake-frontend-contract-ml-1014668951"></a>
### OPTIONS_ITEMS

```ml
const OPTIONS_ITEMS = 14
```

Defines the options items value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L37)

<a id="constant-constant-miniquake-frontend-contract-status-const-status-frontend-109-frozen-v1-src-miniquake-frontend-contract-ml-520889432"></a>
### STATUS

```ml
const STATUS = "frontend_109_frozen_v1"
```

Defines the status value used by `miniquake.frontend_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L17)

<a id="function-function-miniquake-frontend-contract-values-function-values-src-miniquake-frontend-contract-ml-927160641"></a>
### values

```ml
function values()
```

Return values derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L48)

<a id="function-function-miniquake-frontend-contract-verify-function-verify-src-miniquake-frontend-contract-ml-641352637"></a>
### verify

```ml
function verify()
```

Implements the `verify` operation for `miniquake.frontend_contract` (verify).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/frontend_contract.ml#L67)
