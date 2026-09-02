# `src/miniquake/input.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.input`](Package-miniquake-input-1813982325.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cv` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-input-absolutevalue-function-absolutevalue-value-src-miniquake-input-ml-1782072280"></a>
### absoluteValue

```ml
function absoluteValue(value)
```

Return absolute value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absoluteValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1914)

<a id="function-function-miniquake-input-actiondown-function-actiondown-command-src-miniquake-input-ml-1257414200"></a>
### actionDown

```ml
function actionDown(command)
```

Implements the `actionDown` operation for `miniquake.input` (action down).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L821)

<a id="function-function-miniquake-input-actionpressed-function-actionpressed-command-src-miniquake-input-ml-530241480"></a>
### actionPressed

```ml
function actionPressed(command)
```

Implements the `actionPressed` operation for `miniquake.input` (action pressed).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L831)

<a id="global-global-miniquake-input-alwaysmouselook-alwaysmouselook-src-miniquake-input-ml-1721000197"></a>
### alwaysMouseLook

```ml
alwaysMouseLook
```

Tracks the module-level always mouse look state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L130)

<a id="function-function-miniquake-input-applymodernmovementbindings-function-applymodernmovementbindings-src-miniquake-input-ml-19559651"></a>
### applyModernMovementBindings

```ml
function applyModernMovementBindings()
```

Install the modern movement layout once when upgrading an original Quake configuration.  Key_StringToKeynum deliberately distinguishes one-character upper- and lower-case names, while live Win32 polling uses the lower-case slots installed by resetBindings.  Clear stale upper-case aliases so one physical key cannot own two different kbutton commands.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L606)

<a id="function-function-miniquake-input-applymouse-function-applymouse-command-mousesensitivity-yawscale-pitchscale-filterenabled-src-miniquake-input-ml-1502569628"></a>
### applyMouse

```ml
function applyMouse(command, mouseSensitivity, yawScale, pitchScale, filterEnabled)
```

Apply mouse to the active subsystem state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `applyMouse`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `applyMouse`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `applyMouse`. |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `applyMouse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1811)

<a id="function-function-miniquake-input-applymousedelta-function-applymousedelta-command-deltax-deltay-mousesensitivity-yawscale-pitchscale-src-miniquake-input-ml-2037112624"></a>
### applyMouseDelta

```ml
function applyMouseDelta(command, deltaX, deltaY, mouseSensitivity, yawScale, pitchScale)
```

IN_MouseMove first multiplies raw cursor motion by sensitivity and then by m_yaw/m_pitch.  The former port treated sensitivity itself as degrees per pixel, making the stock value 3 about 45 times too strong.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `deltaX` | `dynamic` | — | The delta x input consumed by `applyMouseDelta`. |
| `deltaY` | `dynamic` | — | The delta y input consumed by `applyMouseDelta`. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `applyMouseDelta`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `applyMouseDelta`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `applyMouseDelta`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1799)

<a id="constant-constant-miniquake-input-axis-forward-const-axis-forward-1-src-miniquake-input-ml-1189200633"></a>
### AXIS_FORWARD

```ml
const AXIS_FORWARD = 1
```

Defines the axis forward value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L45)

<a id="constant-constant-miniquake-input-axis-look-const-axis-look-2-src-miniquake-input-ml-787910270"></a>
### AXIS_LOOK

```ml
const AXIS_LOOK = 2
```

Defines the axis look value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L47)

<a id="constant-constant-miniquake-input-axis-nada-const-axis-nada-0-src-miniquake-input-ml-521070740"></a>
### AXIS_NADA

```ml
const AXIS_NADA = 0
```

Defines the axis nada value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L43)

<a id="constant-constant-miniquake-input-axis-side-const-axis-side-3-src-miniquake-input-ml-890786327"></a>
### AXIS_SIDE

```ml
const AXIS_SIDE = 3
```

Defines the axis side value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L49)

<a id="constant-constant-miniquake-input-axis-turn-const-axis-turn-4-src-miniquake-input-ml-853739292"></a>
### AXIS_TURN

```ml
const AXIS_TURN = 4
```

Defines the axis turn value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L51)

<a id="function-function-miniquake-input-bindingforcode-function-bindingforcode-code-src-miniquake-input-ml-338792598"></a>
### bindingForCode

```ml
function bindingForCode(code)
```

Implements the `bindingForCode` operation for `miniquake.input` (binding for code).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `bindingForCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L533)

<a id="function-function-miniquake-input-bindingforcommand-function-bindingforcommand-command-src-miniquake-input-ml-781842166"></a>
### bindingForCommand

```ml
function bindingForCommand(command)
```

Implements the `bindingForCommand` operation for `miniquake.input` (binding for command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L634)

<a id="function-function-miniquake-input-bindingholdskey-function-bindingholdskey-command-key-src-miniquake-input-ml-1734545587"></a>
### bindingHoldsKey

```ml
function bindingHoldsKey(command, key)
```

Implements the `bindingHoldsKey` operation for `miniquake.input` (binding holds key).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L920)

<a id="global-global-miniquake-input-bindings-bindings-src-miniquake-input-ml-324877817"></a>
### bindings

```ml
bindings
```

Tracks the module-level bindings state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L114)

<a id="function-function-miniquake-input-bindingsforcommand-function-bindingsforcommand-command-src-miniquake-input-ml-1853369608"></a>
### bindingsForCommand

```ml
function bindingsForCommand(command)
```

Implements the `bindingsForCommand` operation for `miniquake.input` (bindings for command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L620)

<a id="function-function-miniquake-input-bindingtext-function-bindingtext-src-miniquake-input-ml-210124475"></a>
### bindingText

```ml
function bindingText()
```

Implements the `bindingText` operation for `miniquake.input` (binding text).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L680)

<a id="function-function-miniquake-input-bindkey-function-bindkey-keyname-command-src-miniquake-input-ml-393280698"></a>
### bindKey

```ml
function bindKey(keyName, command)
```

Implements the `bindKey` operation for `miniquake.input` (bind key).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L499)

<a id="function-function-miniquake-input-buildoriginalmove-function-buildoriginalmove-command-signon-framemilliseconds-mousesensitivity-yawscale-pitchscale-filterenabled-forwardspeed-backspeed-sidespeed-upspeed-noclipanglehack-pollbuttonbindings-deviceactive-minimized-src-miniquake-input-ml-1540388021"></a>
### buildOriginalMove

```ml
function buildOriginalMove(command, signon, frameMilliseconds, mouseSensitivity, yawScale, pitchScale, filterEnabled, forwardSpeed, backSpeed, sideSpeed, upSpeed, noclipAngleHack, pollButtonBindings, deviceActive, minimized)
```

Create and initialize original move.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `signon` | `dynamic` | — | The signon input consumed by `buildOriginalMove`. |
| `frameMilliseconds` | `dynamic` | — | The frame milliseconds input consumed by `buildOriginalMove`. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `buildOriginalMove`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `buildOriginalMove`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `buildOriginalMove`. |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `buildOriginalMove`. |
| `forwardSpeed` | `dynamic` | — | The forward speed input consumed by `buildOriginalMove`. |
| `backSpeed` | `dynamic` | — | The back speed input consumed by `buildOriginalMove`. |
| `sideSpeed` | `dynamic` | — | The side speed input consumed by `buildOriginalMove`. |
| `upSpeed` | `dynamic` | — | The up speed input consumed by `buildOriginalMove`. |
| `noclipAngleHack` | `dynamic` | — | The noclip angle hack input consumed by `buildOriginalMove`. |
| `pollButtonBindings` | `dynamic` | — | The poll button bindings input consumed by `buildOriginalMove`. |
| `deviceActive` | `dynamic` | — | The device active input consumed by `buildOriginalMove`. |
| `minimized` | `dynamic` | — | The minimized input consumed by `buildOriginalMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2101)

<a id="global-global-miniquake-input-buttoncommandbuttons-buttoncommandbuttons-src-miniquake-input-ml-753795441"></a>
### buttonCommandButtons

```ml
buttonCommandButtons
```

Keep the matching kbutton references beside the canonical names. The live poll visits every command once per frame, so resolving the same 17 constant strings through buttonForCommand would only allocate lowercase copies and repeat its linear comparison chain.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L190)

<a id="global-global-miniquake-input-buttoncommandnames-buttoncommandnames-src-miniquake-input-ml-824360527"></a>
### buttonCommandNames

```ml
buttonCommandNames
```

Keep the stock kbutton command set in persistent storage.  Constructing this array in buttonCommands used to allocate it multiple times in every gameplay frame while the live binding poll was active.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L180)

<a id="function-function-miniquake-input-buttoncommands-function-buttoncommands-src-miniquake-input-ml-2135293859"></a>
### buttonCommands

```ml
function buttonCommands()
```

Implements the `buttonCommands` operation for `miniquake.input` (button commands).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L913)

<a id="function-function-miniquake-input-buttonforcommand-function-buttonforcommand-command-src-miniquake-input-ml-1920646328"></a>
### buttonForCommand

```ml
function buttonForCommand(command)
```

Resolve an arbitrary-case button command through its canonical name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L867)

<a id="function-function-miniquake-input-buttonfornormalizedcommand-function-buttonfornormalizedcommand-wanted-src-miniquake-input-ml-1774372048"></a>
### buttonForNormalizedCommand

```ml
function buttonForNormalizedCommand(wanted)
```

Implements the `buttonForNormalizedCommand` operation for `miniquake.input` (button for normalized command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `wanted` | `dynamic` | — | The wanted input consumed by `buttonForNormalizedCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L844)

<a id="function-function-miniquake-input-capturegameplaytransitionheldcodes-function-capturegameplaytransitionheldcodes-src-miniquake-input-ml-619398499"></a>
### captureGameplayTransitionHeldCodes

```ml
function captureGameplayTransitionHeldCodes()
```

Capture only the physical +command controls that were already held when the UI/map transition began. Inputs first pressed after loading are intentional gameplay and must never extend the suppression latch.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1526)

<a id="function-function-miniquake-input-cl-adjustangles-function-cl-adjustangles-command-frametime-yawspeed-pitchspeed-anglespeedkey-src-miniquake-input-ml-798890078"></a>
### CL_AdjustAngles

```ml
function CL_AdjustAngles(command, frameTime, yawSpeed, pitchSpeed, angleSpeedKey)
```

Apply the Quake-compatible cl adjust angles behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `yawSpeed` | `dynamic` | — | The yaw speed input consumed by `CL_AdjustAngles`. |
| `pitchSpeed` | `dynamic` | — | The pitch speed input consumed by `CL_AdjustAngles`. |
| `angleSpeedKey` | `dynamic` | — | The angle speed key input consumed by `CL_AdjustAngles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1659)

<a id="function-function-miniquake-input-cl-basemove-function-cl-basemove-command-signon-frametime-forwardspeed-backspeed-sidespeed-upspeed-movespeedkey-yawspeed-pitchspeed-anglespeedkey-src-miniquake-input-ml-1650162541"></a>
### CL_BaseMove

```ml
function CL_BaseMove(command, signon, frameTime, forwardSpeed, backSpeed, sideSpeed, upSpeed, moveSpeedKey, yawSpeed, pitchSpeed, angleSpeedKey)
```

Apply the Quake-compatible cl base move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `signon` | `dynamic` | — | The signon input consumed by `CL_BaseMove`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `forwardSpeed` | `dynamic` | — | The forward speed input consumed by `CL_BaseMove`. |
| `backSpeed` | `dynamic` | — | The back speed input consumed by `CL_BaseMove`. |
| `sideSpeed` | `dynamic` | — | The side speed input consumed by `CL_BaseMove`. |
| `upSpeed` | `dynamic` | — | The up speed input consumed by `CL_BaseMove`. |
| `moveSpeedKey` | `dynamic` | — | The move speed key input consumed by `CL_BaseMove`. |
| `yawSpeed` | `dynamic` | — | The yaw speed input consumed by `CL_BaseMove`. |
| `pitchSpeed` | `dynamic` | — | The pitch speed input consumed by `CL_BaseMove`. |
| `angleSpeedKey` | `dynamic` | — | The angle speed key input consumed by `CL_BaseMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1698)

<a id="function-function-miniquake-input-cl-buttonbits-function-cl-buttonbits-src-miniquake-input-ml-1668665235"></a>
### CL_ButtonBits

```ml
function CL_ButtonBits()
```

Apply the Quake-compatible cl button bits behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2024)

<a id="function-function-miniquake-input-cl-finishmove-function-cl-finishmove-command-src-miniquake-input-ml-81376516"></a>
### CL_FinishMove

```ml
function CL_FinishMove(command)
```

Apply the Quake-compatible cl finish move behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2043)

<a id="function-function-miniquake-input-cl-initinput-function-cl-initinput-src-miniquake-input-ml-1492656851"></a>
### CL_InitInput

```ml
function CL_InitInput()
```

CL_InitInput's command registrations are represented explicitly so both the host command layer and tests can dispatch exactly the stock command set.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1608)

<a id="function-function-miniquake-input-cl-keystate-function-cl-keystate-button-src-miniquake-input-ml-1477914815"></a>
### CL_KeyState

```ml
function CL_KeyState(button)
```

Apply the Quake-compatible cl key state behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `button` | `dynamic` | — | The button input consumed by `CL_KeyState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L247)

<a id="function-function-miniquake-input-cl-takeimpulse-function-cl-takeimpulse-src-miniquake-input-ml-1718726307"></a>
### CL_TakeImpulse

```ml
function CL_TakeImpulse()
```

Apply the Quake-compatible cl take impulse behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2034)

<a id="function-function-miniquake-input-clear-function-clear-command-src-miniquake-input-ml-66345506"></a>
### clear

```ml
function clear(command)
```

Implements the `clear` operation for `miniquake.input` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2076)

<a id="function-function-miniquake-input-cleareventkeystates-function-cleareventkeystates-src-miniquake-input-ml-887969683"></a>
### clearEventKeyStates

```ml
function clearEventKeyStates()
```

Clear all ordered keyboard levels after focus loss or input shutdown.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L972)

<a id="function-function-miniquake-input-clearjoysticksnapshot-function-clearjoysticksnapshot-src-miniquake-input-ml-1560841141"></a>
### clearJoystickSnapshot

```ml
function clearJoystickSnapshot()
```

Clears joystick snapshot for `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1126)

<a id="function-function-miniquake-input-collect-function-collect-command-framemilliseconds-mousesensitivity-src-miniquake-input-ml-620077401"></a>
### collect

```ml
function collect(command, frameMilliseconds, mouseSensitivity)
```

Implements the `collect` operation for `miniquake.input` (collect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameMilliseconds` | `dynamic` | — | The frame milliseconds input consumed by `collect`. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `collect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2053)

<a id="function-function-miniquake-input-collectgame-function-collectgame-command-framemilliseconds-mousesensitivity-yawscale-pitchscale-filterenabled-forwardspeed-backspeed-sidespeed-upspeed-src-miniquake-input-ml-1050023871"></a>
### collectGame

```ml
function collectGame(command, frameMilliseconds, mouseSensitivity, yawScale, pitchScale, filterEnabled, forwardSpeed, backSpeed, sideSpeed, upSpeed)
```

Implements the `collectGame` operation for `miniquake.input` (collect game).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameMilliseconds` | `dynamic` | — | The frame milliseconds input consumed by `collectGame`. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `collectGame`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `collectGame`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `collectGame`. |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `collectGame`. |
| `forwardSpeed` | `dynamic` | — | The forward speed input consumed by `collectGame`. |
| `backSpeed` | `dynamic` | — | The back speed input consumed by `collectGame`. |
| `sideSpeed` | `dynamic` | — | The side speed input consumed by `collectGame`. |
| `upSpeed` | `dynamic` | — | The up speed input consumed by `collectGame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2147)

<a id="function-function-miniquake-input-commandbutton-function-commandbutton-command-src-miniquake-input-ml-1818722714"></a>
### commandButton

```ml
function commandButton(command)
```

Resolve an arbitrary-case signed input command to its shared kbutton.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1635)

<a id="function-function-miniquake-input-commandbuttonnormalized-function-commandbuttonnormalized-command-src-miniquake-input-ml-1282789272"></a>
### commandButtonNormalized

```ml
function commandButtonNormalized(command)
```

Implements the `commandButtonNormalized` operation for `miniquake.input` (command button normalized).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1623)

<a id="function-function-miniquake-input-commandforkey-function-commandforkey-keyname-src-miniquake-input-ml-381452287"></a>
### commandForKey

```ml
function commandForKey(keyName)
```

Implements the `commandForKey` operation for `miniquake.input` (command for key).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L657)

<a id="function-function-miniquake-input-configureplatform-function-configureplatform-registry-nomouse-nojoystick-usedirectinput-src-miniquake-input-ml-1593359623"></a>
### configurePlatform

```ml
function configurePlatform(registry, noMouse, noJoystick, useDirectInput)
```

Update subsystem configuration for configure platform.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `configurePlatform`. |
| `noMouse` | `dynamic` | — | The no mouse input consumed by `configurePlatform`. |
| `noJoystick` | `dynamic` | — | The no joystick input consumed by `configurePlatform`. |
| `useDirectInput` | `dynamic` | — | The use direct input input consumed by `configurePlatform`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1283)

<a id="function-function-miniquake-input-consumepitchdriftrequests-function-consumepitchdriftrequests-src-miniquake-input-ml-225243761"></a>
### consumePitchDriftRequests

```ml
function consumePitchDriftRequests()
```

Consume pending state for consume pitch drift requests.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L394)

<a id="function-function-miniquake-input-createbutton-function-createbutton-src-miniquake-input-ml-1952020139"></a>
### createButton

```ml
function createButton()
```

Create and initialize button.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L197)

<a id="function-function-miniquake-input-createcommand-function-createcommand-src-miniquake-input-ml-2011549461"></a>
### createCommand

```ml
function createCommand()
```

Create and initialize command.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1265)

<a id="function-function-miniquake-input-cvarvalue-function-cvarvalue-name-fallback-src-miniquake-input-ml-1757804520"></a>
### cvarValue

```ml
function cvarValue(name, fallback)
```

Return cvar value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1032)

<a id="constant-constant-miniquake-input-default-angle-speed-key-const-default-angle-speed-key-1-5-src-miniquake-input-ml-517512570"></a>
### DEFAULT_ANGLE_SPEED_KEY

```ml
const DEFAULT_ANGLE_SPEED_KEY = 1.5
```

Defines the default angle speed key value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L33)

<a id="constant-constant-miniquake-input-default-m-forward-const-default-m-forward-1-src-miniquake-input-ml-2127205959"></a>
### DEFAULT_M_FORWARD

```ml
const DEFAULT_M_FORWARD = 1.
```

Defines the default m forward value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L27)

<a id="constant-constant-miniquake-input-default-m-pitch-const-default-m-pitch-2-2e-002-src-miniquake-input-ml-241642552"></a>
### DEFAULT_M_PITCH

```ml
const DEFAULT_M_PITCH = 2.2e-002
```

Defines the default m pitch value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L23)

<a id="constant-constant-miniquake-input-default-m-side-const-default-m-side-0-8-src-miniquake-input-ml-1380948742"></a>
### DEFAULT_M_SIDE

```ml
const DEFAULT_M_SIDE = 0.8
```

Defines the default m side value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L25)

<a id="constant-constant-miniquake-input-default-m-yaw-const-default-m-yaw-2-2e-002-src-miniquake-input-ml-351167320"></a>
### DEFAULT_M_YAW

```ml
const DEFAULT_M_YAW = 2.2e-002
```

Defines the default m yaw value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L21)

<a id="constant-constant-miniquake-input-default-move-speed-key-const-default-move-speed-key-2-src-miniquake-input-ml-1491779722"></a>
### DEFAULT_MOVE_SPEED_KEY

```ml
const DEFAULT_MOVE_SPEED_KEY = 2.
```

Defines the default move speed key value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L35)

<a id="constant-constant-miniquake-input-default-pitch-speed-const-default-pitch-speed-150-src-miniquake-input-ml-391002266"></a>
### DEFAULT_PITCH_SPEED

```ml
const DEFAULT_PITCH_SPEED = 150.
```

Defines the default pitch speed value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L31)

<a id="constant-constant-miniquake-input-default-yaw-speed-const-default-yaw-speed-140-src-miniquake-input-ml-1882742619"></a>
### DEFAULT_YAW_SPEED

```ml
const DEFAULT_YAW_SPEED = 140.
```

Defines the default yaw speed value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L29)

<a id="global-global-miniquake-input-directinput-directinput-src-miniquake-input-ml-1952864097"></a>
### directInput

```ml
directInput
```

Tracks the module-level direct input state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L70)

<a id="global-global-miniquake-input-directinputrequested-directinputrequested-src-miniquake-input-ml-1613838279"></a>
### directInputRequested

```ml
directInputRequested
```

Tracks the module-level direct input requested state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L104)

<a id="function-function-miniquake-input-dispatchinputcommand-function-dispatchinputcommand-command-key-value-src-miniquake-input-ml-1512409016"></a>
### dispatchInputCommand

```ml
function dispatchInputCommand(command, key, value)
```

Execute input command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `value` | `dynamic` | — | Value consumed by `dispatchInputCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1643)

<a id="global-global-miniquake-input-eventkeydownstates-eventkeydownstates-src-miniquake-input-ml-420987835"></a>
### eventKeyDownStates

```ml
eventKeyDownStates
```

Tracks the module-level event key down states state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L124)

<a id="function-function-miniquake-input-filteredmousedelta-function-filteredmousedelta-filterenabled-src-miniquake-input-ml-1705694862"></a>
### filteredMouseDelta

```ml
function filteredMouseDelta(filterEnabled)
```

Implements the `filteredMouseDelta` operation for `miniquake.input` (filtered mouse delta).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `filteredMouseDelta`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1782)

<a id="function-function-miniquake-input-firstpressedkey-function-firstpressedkey-src-miniquake-input-ml-1080043937"></a>
### firstPressedKey

```ml
function firstPressedKey()
```

Return first pressed key for the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1251)

<a id="function-function-miniquake-input-force-centerview-f-function-force-centerview-f-command-src-miniquake-input-ml-154124452"></a>
### Force_CenterView_f

```ml
function Force_CenterView_f(command)
```

Mirror Quake's Force_CenterView_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1359)

<a id="global-global-miniquake-input-gameplaytransitionblocked-gameplaytransitionblocked-src-miniquake-input-ml-1695231097"></a>
### gameplayTransitionBlocked

```ml
gameplayTransitionBlocked
```

Tracks the module-level gameplay transition blocked state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L126)

<a id="function-function-miniquake-input-gameplaytransitioncodedown-function-gameplaytransitioncodedown-code-src-miniquake-input-ml-1780329706"></a>
### gameplayTransitionCodeDown

```ml
function gameplayTransitionCodeDown(code)
```

Query only the current physical device level for a control captured at a menu/map boundary.  eventKeyDownStates intentionally is not consulted here: it describes the pre-transition message stream and can remain set when the renderer or a synchronous map load clears/recreates the native input queue.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `gameplayTransitionCodeDown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1546)

<a id="global-global-miniquake-input-gameplaytransitionheldcodes-gameplaytransitionheldcodes-src-miniquake-input-ml-63499577"></a>
### gameplayTransitionHeldCodes

```ml
gameplayTransitionHeldCodes
```

Tracks the module-level gameplay transition held codes state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L128)

<a id="function-function-miniquake-input-hasbindingcode-function-hasbindingcode-code-src-miniquake-input-ml-230202970"></a>
### hasBindingCode

```ml
function hasBindingCode(code)
```

Report whether binding code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `hasBindingCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L542)

<a id="function-function-miniquake-input-impulseforcommand-function-impulseforcommand-command-src-miniquake-input-ml-1239750986"></a>
### impulseForCommand

```ml
function impulseForCommand(command)
```

Parse the exact canonical impulse binding accepted by the original polling path.  Non-impulse and non-canonical command strings return zero.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L874)

<a id="function-function-miniquake-input-in-accumulate-function-in-accumulate-src-miniquake-input-ml-642392259"></a>
### IN_Accumulate

```ml
function IN_Accumulate()
```

Mirror Quake's IN_Accumulate routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2012)

<a id="function-function-miniquake-input-in-activatemouse-function-in-activatemouse-src-miniquake-input-ml-716511783"></a>
### IN_ActivateMouse

```ml
function IN_ActivateMouse()
```

Mirror Quake's IN_ActivateMouse routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1391)

<a id="function-function-miniquake-input-in-attackdown-function-in-attackdown-key-src-miniquake-input-ml-1999286666"></a>
### IN_AttackDown

```ml
function IN_AttackDown(key)
```

Mirror Quake's IN_AttackDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L353)

<a id="function-function-miniquake-input-in-attackup-function-in-attackup-key-src-miniquake-input-ml-1354956020"></a>
### IN_AttackUp

```ml
function IN_AttackUp(key)
```

Mirror Quake's IN_AttackUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L356)

<a id="function-function-miniquake-input-in-backdown-function-in-backdown-key-src-miniquake-input-ml-843464456"></a>
### IN_BackDown

```ml
function IN_BackDown(key)
```

Mirror Quake's IN_BackDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L311)

<a id="function-function-miniquake-input-in-backup-function-in-backup-key-src-miniquake-input-ml-926023582"></a>
### IN_BackUp

```ml
function IN_BackUp(key)
```

Mirror Quake's IN_BackUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L314)

<a id="function-function-miniquake-input-in-blockgameplaytransition-function-in-blockgameplaytransition-src-miniquake-input-ml-584960867"></a>
### IN_BlockGameplayTransition

```ml
function IN_BlockGameplayTransition()
```

Block live gameplay controls while a menu selection or a map transition is still physically held.  Clearing kbutton_t alone is insufficient because IN_PollButtonCommands would reconstruct +attack/+jump from the held Win32 key or mouse button on the first playable frame.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1504)

<a id="function-function-miniquake-input-in-cleardevicestates-function-in-cleardevicestates-src-miniquake-input-ml-1516179119"></a>
### IN_ClearDeviceStates

```ml
function IN_ClearDeviceStates()
```

in_win.c::IN_ClearStates only clears the active mouse device state. Keep this distinct from MiniQuake's full input reset, which is used at startup and by deterministic evidence runs to clear command buttons as well.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1464)

<a id="function-function-miniquake-input-in-clearstates-function-in-clearstates-src-miniquake-input-ml-732916583"></a>
### IN_ClearStates

```ml
function IN_ClearStates()
```

Mirror Quake's IN_ClearStates routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1475)

<a id="function-function-miniquake-input-in-commands-function-in-commands-src-miniquake-input-ml-1310333179"></a>
### IN_Commands

```ml
function IN_Commands()
```

Mirror Quake's IN_Commands routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1168)

<a id="function-function-miniquake-input-in-deactivatemouse-function-in-deactivatemouse-src-miniquake-input-ml-172974855"></a>
### IN_DeactivateMouse

```ml
function IN_DeactivateMouse()
```

Mirror Quake's IN_DeactivateMouse routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1414)

<a id="function-function-miniquake-input-in-differentialclearjoystickstartup-function-in-differentialclearjoystickstartup-src-miniquake-input-ml-1568403625"></a>
### IN_DifferentialClearJoystickStartup

```ml
function IN_DifferentialClearJoystickStartup()
```

Mirror Quake's IN_DifferentialClearJoystickStartup routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1145)

<a id="function-function-miniquake-input-in-differentialsetjoystickstartup-function-in-differentialsetjoystickstartup-buttoncount-haspov-src-miniquake-input-ml-1646804251"></a>
### IN_DifferentialSetJoystickStartup

```ml
function IN_DifferentialSetJoystickStartup(buttonCount, hasPov)
```

Mirror Quake's IN_DifferentialSetJoystickStartup routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buttonCount` | `dynamic` | — | Number of entries or units to process. |
| `hasPov` | `dynamic` | — | The has pov input consumed by `IN_DifferentialSetJoystickStartup`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1138)

<a id="function-function-miniquake-input-in-differentialsetmouse-function-in-differentialsetmouse-initialized-active-activatetoggle-showtoggle-usedirectinput-oldbuttonstate-accumulatedx-accumulatedy-previousx-previousy-filterready-src-miniquake-input-ml-1299499388"></a>
### IN_DifferentialSetMouse

```ml
function IN_DifferentialSetMouse(initialized, active, activateToggle, showToggle, useDirectInput, oldButtonState, accumulatedX, accumulatedY, previousX, previousY, filterReady)
```

Mirror Quake's IN_DifferentialSetMouse routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initialized` | `dynamic` | — | The initialized input consumed by `IN_DifferentialSetMouse`. |
| `active` | `dynamic` | — | The active input consumed by `IN_DifferentialSetMouse`. |
| `activateToggle` | `dynamic` | — | The activate toggle input consumed by `IN_DifferentialSetMouse`. |
| `showToggle` | `dynamic` | — | The show toggle input consumed by `IN_DifferentialSetMouse`. |
| `useDirectInput` | `dynamic` | — | The use direct input input consumed by `IN_DifferentialSetMouse`. |
| `oldButtonState` | `dynamic` | — | Mutable state used by `IN_DifferentialSetMouse`. |
| `accumulatedX` | `dynamic` | — | The accumulated x input consumed by `IN_DifferentialSetMouse`. |
| `accumulatedY` | `dynamic` | — | The accumulated y input consumed by `IN_DifferentialSetMouse`. |
| `previousX` | `dynamic` | — | The previous x input consumed by `IN_DifferentialSetMouse`. |
| `previousY` | `dynamic` | — | The previous y input consumed by `IN_DifferentialSetMouse`. |
| `filterReady` | `dynamic` | — | The filter ready input consumed by `IN_DifferentialSetMouse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1304)

<a id="function-function-miniquake-input-in-differentialstate-function-in-differentialstate-src-miniquake-input-ml-1628962419"></a>
### IN_DifferentialState

```ml
function IN_DifferentialState()
```

Mirror Quake's IN_DifferentialState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1335)

<a id="function-function-miniquake-input-in-discardpolledkeyedges-function-in-discardpolledkeyedges-src-miniquake-input-ml-422950915"></a>
### IN_DiscardPolledKeyEdges

```ml
function IN_DiscardPolledKeyEdges()
```

Consume native keyboard press edges while UI-to-game handoff is blocked.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1490)

<a id="function-function-miniquake-input-in-downdown-function-in-downdown-key-src-miniquake-input-ml-325595002"></a>
### IN_DownDown

```ml
function IN_DownDown(key)
```

Mirror Quake's IN_DownDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L287)

<a id="function-function-miniquake-input-in-downup-function-in-downup-key-src-miniquake-input-ml-1306608056"></a>
### IN_DownUp

```ml
function IN_DownUp(key)
```

Mirror Quake's IN_DownUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L290)

<a id="function-function-miniquake-input-in-forwarddown-function-in-forwarddown-key-src-miniquake-input-ml-109356562"></a>
### IN_ForwardDown

```ml
function IN_ForwardDown(key)
```

Mirror Quake's IN_ForwardDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L305)

<a id="function-function-miniquake-input-in-forwardup-function-in-forwardup-key-src-miniquake-input-ml-1284394306"></a>
### IN_ForwardUp

```ml
function IN_ForwardUp(key)
```

Mirror Quake's IN_ForwardUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L308)

<a id="function-function-miniquake-input-in-gameplaytransitionblocked-function-in-gameplaytransitionblocked-src-miniquake-input-ml-1374097651"></a>
### IN_GameplayTransitionBlocked

```ml
function IN_GameplayTransitionBlocked()
```

Report whether a menu/map handoff is still suppressing live controls.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1519)

<a id="function-function-miniquake-input-in-gameplaytransitioncontrolheld-function-in-gameplaytransitioncontrolheld-src-miniquake-input-ml-229813511"></a>
### IN_GameplayTransitionControlHeld

```ml
function IN_GameplayTransitionControlHeld()
```

Report whether a control captured at the transition boundary remains held.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1559)

<a id="function-function-miniquake-input-in-hidemouse-function-in-hidemouse-src-miniquake-input-ml-1879445787"></a>
### IN_HideMouse

```ml
function IN_HideMouse()
```

Mirror Quake's IN_HideMouse routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1381)

<a id="function-function-miniquake-input-in-impulse-function-in-impulse-value-src-miniquake-input-ml-1892746556"></a>
### IN_Impulse

```ml
function IN_Impulse(value)
```

Mirror Quake's IN_Impulse routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `IN_Impulse`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L372)

<a id="function-function-miniquake-input-in-init-function-in-init-src-miniquake-input-ml-1294935095"></a>
### IN_Init

```ml
function IN_Init()
```

Mirror Quake's IN_Init routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1583)

<a id="function-function-miniquake-input-in-initdinput-function-in-initdinput-src-miniquake-input-ml-1510187307"></a>
### IN_InitDInput

```ml
function IN_InitDInput()
```

Mirror Quake's IN_InitDInput routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1442)

<a id="function-function-miniquake-input-in-joymove-function-in-joymove-command-frameseconds-src-miniquake-input-ml-1306557482"></a>
### IN_JoyMove

```ml
function IN_JoyMove(command, frameSeconds)
```

Mirror Quake's IN_JoyMove routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `frameSeconds` | `dynamic` | — | The frame seconds input consumed by `IN_JoyMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1922)

<a id="function-function-miniquake-input-in-jumpdown-function-in-jumpdown-key-src-miniquake-input-ml-1314636602"></a>
### IN_JumpDown

```ml
function IN_JumpDown(key)
```

Mirror Quake's IN_JumpDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L365)

<a id="function-function-miniquake-input-in-jumpup-function-in-jumpup-key-src-miniquake-input-ml-588322200"></a>
### IN_JumpUp

```ml
function IN_JumpUp(key)
```

Mirror Quake's IN_JumpUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L368)

<a id="function-function-miniquake-input-in-klookdown-function-in-klookdown-key-src-miniquake-input-ml-1928186506"></a>
### IN_KLookDown

```ml
function IN_KLookDown(key)
```

Mirror Quake's IN_KLookDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L265)

<a id="function-function-miniquake-input-in-klookup-function-in-klookup-key-src-miniquake-input-ml-1363137342"></a>
### IN_KLookUp

```ml
function IN_KLookUp(key)
```

Mirror Quake's IN_KLookUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L268)

<a id="function-function-miniquake-input-in-leftdown-function-in-leftdown-key-src-miniquake-input-ml-461222752"></a>
### IN_LeftDown

```ml
function IN_LeftDown(key)
```

Mirror Quake's IN_LeftDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L293)

<a id="function-function-miniquake-input-in-leftup-function-in-leftup-key-src-miniquake-input-ml-453007498"></a>
### IN_LeftUp

```ml
function IN_LeftUp(key)
```

Mirror Quake's IN_LeftUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L296)

<a id="function-function-miniquake-input-in-lookdowndown-function-in-lookdowndown-key-src-miniquake-input-ml-107492920"></a>
### IN_LookdownDown

```ml
function IN_LookdownDown(key)
```

Mirror Quake's IN_LookdownDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L323)

<a id="function-function-miniquake-input-in-lookdownup-function-in-lookdownup-key-src-miniquake-input-ml-1394497442"></a>
### IN_LookdownUp

```ml
function IN_LookdownUp(key)
```

Mirror Quake's IN_LookdownUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L326)

<a id="function-function-miniquake-input-in-lookupdown-function-in-lookupdown-key-src-miniquake-input-ml-54552746"></a>
### IN_LookupDown

```ml
function IN_LookupDown(key)
```

Mirror Quake's IN_LookupDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L317)

<a id="function-function-miniquake-input-in-lookupup-function-in-lookupup-key-src-miniquake-input-ml-2048909952"></a>
### IN_LookupUp

```ml
function IN_LookupUp(key)
```

Mirror Quake's IN_LookupUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L320)

<a id="function-function-miniquake-input-in-mlookdown-function-in-mlookdown-key-src-miniquake-input-ml-1430287998"></a>
### IN_MLookDown

```ml
function IN_MLookDown(key)
```

Mirror Quake's IN_MLookDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L271)

<a id="function-function-miniquake-input-in-mlookup-function-in-mlookup-key-src-miniquake-input-ml-1477054778"></a>
### IN_MLookUp

```ml
function IN_MLookUp(key)
```

Mirror Quake's IN_MLookUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L274)

<a id="function-function-miniquake-input-in-mouseevent-function-in-mouseevent-mousestate-src-miniquake-input-ml-1855310505"></a>
### IN_MouseEvent

```ml
function IN_MouseEvent(mouseState)
```

Mirror Quake's IN_MouseEvent routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mouseState` | `dynamic` | — | Mutable state used by `IN_MouseEvent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1864)

<a id="function-function-miniquake-input-in-mousemove-function-in-mousemove-command-mousesensitivity-yawscale-pitchscale-filterenabled-sidescale-forwardscale-lookstrafe-noclipanglehack-src-miniquake-input-ml-12042939"></a>
### IN_MouseMove

```ml
function IN_MouseMove(command, mouseSensitivity, yawScale, pitchScale, filterEnabled, sideScale, forwardScale, lookStrafe, noclipAngleHack)
```

Mirror Quake's IN_MouseMove routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `IN_MouseMove`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `IN_MouseMove`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `IN_MouseMove`. |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `IN_MouseMove`. |
| `sideScale` | `dynamic` | — | The side scale input consumed by `IN_MouseMove`. |
| `forwardScale` | `dynamic` | — | The forward scale input consumed by `IN_MouseMove`. |
| `lookStrafe` | `dynamic` | — | The look strafe input consumed by `IN_MouseMove`. |
| `noclipAngleHack` | `dynamic` | — | The noclip angle hack input consumed by `IN_MouseMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1893)

<a id="function-function-miniquake-input-in-move-function-in-move-command-mousesensitivity-yawscale-pitchscale-filterenabled-sidescale-forwardscale-lookstrafe-noclipanglehack-frameseconds-active-minimized-src-miniquake-input-ml-1742137567"></a>
### IN_Move

```ml
function IN_Move(command, mouseSensitivity, yawScale, pitchScale, filterEnabled, sideScale, forwardScale, lookStrafe, noclipAngleHack, frameSeconds, active, minimized)
```

Mirror Quake's IN_Move routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `IN_Move`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `IN_Move`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `IN_Move`. |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `IN_Move`. |
| `sideScale` | `dynamic` | — | The side scale input consumed by `IN_Move`. |
| `forwardScale` | `dynamic` | — | The forward scale input consumed by `IN_Move`. |
| `lookStrafe` | `dynamic` | — | The look strafe input consumed by `IN_Move`. |
| `noclipAngleHack` | `dynamic` | — | The noclip angle hack input consumed by `IN_Move`. |
| `frameSeconds` | `dynamic` | — | The frame seconds input consumed by `IN_Move`. |
| `active` | `dynamic` | — | The active input consumed by `IN_Move`. |
| `minimized` | `dynamic` | — | The minimized input consumed by `IN_Move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L2003)

<a id="function-function-miniquake-input-in-movedelta-function-in-movedelta-command-deltax-deltay-mousesensitivity-yawscale-pitchscale-sidescale-forwardscale-lookstrafe-noclipanglehack-src-miniquake-input-ml-42170997"></a>
### IN_MoveDelta

```ml
function IN_MoveDelta(command, deltaX, deltaY, mouseSensitivity, yawScale, pitchScale, sideScale, forwardScale, lookStrafe, noclipAngleHack)
```

Mirror Quake's IN_MoveDelta routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `deltaX` | `dynamic` | — | The delta x input consumed by `IN_MoveDelta`. |
| `deltaY` | `dynamic` | — | The delta y input consumed by `IN_MoveDelta`. |
| `mouseSensitivity` | `dynamic` | — | The mouse sensitivity input consumed by `IN_MoveDelta`. |
| `yawScale` | `dynamic` | — | The yaw scale input consumed by `IN_MoveDelta`. |
| `pitchScale` | `dynamic` | — | The pitch scale input consumed by `IN_MoveDelta`. |
| `sideScale` | `dynamic` | — | The side scale input consumed by `IN_MoveDelta`. |
| `forwardScale` | `dynamic` | — | The forward scale input consumed by `IN_MoveDelta`. |
| `lookStrafe` | `dynamic` | — | The look strafe input consumed by `IN_MoveDelta`. |
| `noclipAngleHack` | `dynamic` | — | The noclip angle hack input consumed by `IN_MoveDelta`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1838)

<a id="function-function-miniquake-input-in-moveleftdown-function-in-moveleftdown-key-src-miniquake-input-ml-1485317034"></a>
### IN_MoveleftDown

```ml
function IN_MoveleftDown(key)
```

Mirror Quake's IN_MoveleftDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L329)

<a id="function-function-miniquake-input-in-moveleftup-function-in-moveleftup-key-src-miniquake-input-ml-1277944780"></a>
### IN_MoveleftUp

```ml
function IN_MoveleftUp(key)
```

Mirror Quake's IN_MoveleftUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L332)

<a id="function-function-miniquake-input-in-moverightdown-function-in-moverightdown-key-src-miniquake-input-ml-1224618598"></a>
### IN_MoverightDown

```ml
function IN_MoverightDown(key)
```

Mirror Quake's IN_MoverightDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L335)

<a id="function-function-miniquake-input-in-moverightup-function-in-moverightup-key-src-miniquake-input-ml-712346694"></a>
### IN_MoverightUp

```ml
function IN_MoverightUp(key)
```

Mirror Quake's IN_MoverightUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L338)

<a id="function-function-miniquake-input-in-pollbuttoncommands-function-in-pollbuttoncommands-src-miniquake-input-ml-2049963129"></a>
### IN_PollButtonCommands

```ml
function IN_PollButtonCommands()
```

Mirror Quake's IN_PollButtonCommands routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1211)

<a id="function-function-miniquake-input-in-readjoystick-function-in-readjoystick-src-miniquake-input-ml-949181819"></a>
### IN_ReadJoystick

```ml
function IN_ReadJoystick()
```

Mirror Quake's IN_ReadJoystick routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1152)

<a id="function-function-miniquake-input-in-releasegameplaytransitionifneutral-function-in-releasegameplaytransitionifneutral-src-miniquake-input-ml-846754779"></a>
### IN_ReleaseGameplayTransitionIfNeutral

```ml
function IN_ReleaseGameplayTransitionIfNeutral()
```

Release the transition latch only after every gameplay control has returned to neutral.  The caller deliberately suppresses the release-detecting frame as well, so queued native press edges cannot leak into the new level.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1569)

<a id="function-function-miniquake-input-in-restoreoriginalmousestate-function-in-restoreoriginalmousestate-src-miniquake-input-ml-2039550119"></a>
### IN_RestoreOriginalMouseState

```ml
function IN_RestoreOriginalMouseState()
```

Mirror Quake's IN_RestoreOriginalMouseState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1429)

<a id="function-function-miniquake-input-in-rightdown-function-in-rightdown-key-src-miniquake-input-ml-1969841490"></a>
### IN_RightDown

```ml
function IN_RightDown(key)
```

Mirror Quake's IN_RightDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L299)

<a id="function-function-miniquake-input-in-rightup-function-in-rightup-key-src-miniquake-input-ml-517854050"></a>
### IN_RightUp

```ml
function IN_RightUp(key)
```

Mirror Quake's IN_RightUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L302)

<a id="function-function-miniquake-input-in-setfreelook-function-in-setfreelook-enabled-src-miniquake-input-ml-2147083212"></a>
### IN_SetFreeLook

```ml
function IN_SetFreeLook(enabled)
```

Select modern persistent free-look without changing the original +mlook button state.  Differential tests and compatibility callers retain stock Quake behavior until the production host explicitly enables this mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1821)

<a id="function-function-miniquake-input-in-setquakemousestate-function-in-setquakemousestate-src-miniquake-input-ml-461020629"></a>
### IN_SetQuakeMouseState

```ml
function IN_SetQuakeMouseState()
```

Mirror Quake's IN_SetQuakeMouseState routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1408)

<a id="function-function-miniquake-input-in-showmouse-function-in-showmouse-src-miniquake-input-ml-2011128363"></a>
### IN_ShowMouse

```ml
function IN_ShowMouse()
```

Mirror Quake's IN_ShowMouse routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1371)

<a id="function-function-miniquake-input-in-shutdown-function-in-shutdown-src-miniquake-input-ml-618951115"></a>
### IN_Shutdown

```ml
function IN_Shutdown()
```

Mirror Quake's IN_Shutdown routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1595)

<a id="function-function-miniquake-input-in-speeddown-function-in-speeddown-key-src-miniquake-input-ml-1335506574"></a>
### IN_SpeedDown

```ml
function IN_SpeedDown(key)
```

Mirror Quake's IN_SpeedDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L341)

<a id="function-function-miniquake-input-in-speedup-function-in-speedup-key-src-miniquake-input-ml-1879685346"></a>
### IN_SpeedUp

```ml
function IN_SpeedUp(key)
```

Mirror Quake's IN_SpeedUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L344)

<a id="function-function-miniquake-input-in-startupjoystick-function-in-startupjoystick-src-miniquake-input-ml-1494285895"></a>
### IN_StartupJoystick

```ml
function IN_StartupJoystick()
```

Mirror Quake's IN_StartupJoystick routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1069)

<a id="function-function-miniquake-input-in-startupmouse-function-in-startupmouse-src-miniquake-input-ml-1307789347"></a>
### IN_StartupMouse

```ml
function IN_StartupMouse()
```

Mirror Quake's IN_StartupMouse routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1450)

<a id="function-function-miniquake-input-in-strafedown-function-in-strafedown-key-src-miniquake-input-ml-1646250708"></a>
### IN_StrafeDown

```ml
function IN_StrafeDown(key)
```

Mirror Quake's IN_StrafeDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L347)

<a id="function-function-miniquake-input-in-strafeup-function-in-strafeup-key-src-miniquake-input-ml-642467646"></a>
### IN_StrafeUp

```ml
function IN_StrafeUp(key)
```

Mirror Quake's IN_StrafeUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L350)

<a id="function-function-miniquake-input-in-updateclipcursor-function-in-updateclipcursor-src-miniquake-input-ml-366193465"></a>
### IN_UpdateClipCursor

```ml
function IN_UpdateClipCursor()
```

Mirror Quake's IN_UpdateClipCursor routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1365)

<a id="function-function-miniquake-input-in-updown-function-in-updown-key-src-miniquake-input-ml-1696714776"></a>
### IN_UpDown

```ml
function IN_UpDown(key)
```

Mirror Quake's IN_UpDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L281)

<a id="function-function-miniquake-input-in-upup-function-in-upup-key-src-miniquake-input-ml-317209530"></a>
### IN_UpUp

```ml
function IN_UpUp(key)
```

Mirror Quake's IN_UpUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L284)

<a id="function-function-miniquake-input-in-usedown-function-in-usedown-key-src-miniquake-input-ml-649408202"></a>
### IN_UseDown

```ml
function IN_UseDown(key)
```

Mirror Quake's IN_UseDown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L359)

<a id="function-function-miniquake-input-in-useup-function-in-useup-key-src-miniquake-input-ml-847615802"></a>
### IN_UseUp

```ml
function IN_UseUp(key)
```

Mirror Quake's IN_UseUp routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L362)

<a id="global-global-miniquake-input-inattack-inattack-src-miniquake-input-ml-857480923"></a>
### inAttack

```ml
inAttack
```

Tracks the module-level in attack state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L163)

<a id="global-global-miniquake-input-inback-inback-src-miniquake-input-ml-1377315773"></a>
### inBack

```ml
inBack
```

Tracks the module-level in back state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L145)

<a id="global-global-miniquake-input-indown-indown-src-miniquake-input-ml-1782163479"></a>
### inDown

```ml
inDown
```

Tracks the module-level in down state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L167)

<a id="global-global-miniquake-input-inforward-inforward-src-miniquake-input-ml-975766865"></a>
### inForward

```ml
inForward
```

Tracks the module-level in forward state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L143)

<a id="global-global-miniquake-input-inimpulse-inimpulse-src-miniquake-input-ml-106333353"></a>
### inImpulse

```ml
inImpulse
```

Tracks the module-level in impulse state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L169)

<a id="global-global-miniquake-input-injump-injump-src-miniquake-input-ml-1902133399"></a>
### inJump

```ml
inJump
```

Tracks the module-level in jump state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L161)

<a id="global-global-miniquake-input-inklook-inklook-src-miniquake-input-ml-1130194813"></a>
### inKLook

```ml
inKLook
```

Tracks the module-level in k look state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L137)

<a id="global-global-miniquake-input-inleft-inleft-src-miniquake-input-ml-2006050721"></a>
### inLeft

```ml
inLeft
```

Tracks the module-level in left state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L139)

<a id="global-global-miniquake-input-inlookdown-inlookdown-src-miniquake-input-ml-1415261697"></a>
### inLookdown

```ml
inLookdown
```

Tracks the module-level in lookdown state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L149)

<a id="global-global-miniquake-input-inlookup-inlookup-src-miniquake-input-ml-2142947671"></a>
### inLookup

```ml
inLookup
```

Tracks the module-level in lookup state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L147)

<a id="global-global-miniquake-input-inmlook-inmlook-src-miniquake-input-ml-1284076929"></a>
### inMLook

```ml
inMLook
```

cl_input.c's kbutton_t is deliberately represented as a three-element mutable value: two independently held key numbers followed by the original state bitfield (down=1, impulse-down=2, impulse-up=4).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L135)

<a id="global-global-miniquake-input-inmoveleft-inmoveleft-src-miniquake-input-ml-835551603"></a>
### inMoveleft

```ml
inMoveleft
```

Tracks the module-level in moveleft state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L151)

<a id="global-global-miniquake-input-inmoveright-inmoveright-src-miniquake-input-ml-1152484733"></a>
### inMoveright

```ml
inMoveright
```

Tracks the module-level in moveright state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L153)

<a id="global-global-miniquake-input-inputregistry-inputregistry-src-miniquake-input-ml-551254393"></a>
### inputRegistry

```ml
inputRegistry
```

Tracks the module-level input registry state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L98)

<a id="global-global-miniquake-input-inright-inright-src-miniquake-input-ml-1480373025"></a>
### inRight

```ml
inRight
```

Tracks the module-level in right state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L141)

<a id="global-global-miniquake-input-inspeed-inspeed-src-miniquake-input-ml-268218089"></a>
### inSpeed

```ml
inSpeed
```

Tracks the module-level in speed state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L157)

<a id="global-global-miniquake-input-instrafe-instrafe-src-miniquake-input-ml-1803078581"></a>
### inStrafe

```ml
inStrafe
```

Tracks the module-level in strafe state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L155)

<a id="global-global-miniquake-input-inup-inup-src-miniquake-input-ml-2070244665"></a>
### inUp

```ml
inUp
```

Tracks the module-level in up state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L165)

<a id="global-global-miniquake-input-inuse-inuse-src-miniquake-input-ml-1006038345"></a>
### inUse

```ml
inUse
```

Tracks the module-level in use state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L159)

<a id="constant-constant-miniquake-input-joy-absolute-axis-const-joy-absolute-axis-0-src-miniquake-input-ml-443379256"></a>
### JOY_ABSOLUTE_AXIS

```ml
const JOY_ABSOLUTE_AXIS = 0
```

Defines the joy absolute axis value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L37)

<a id="function-function-miniquake-input-joy-advancedupdate-f-function-joy-advancedupdate-f-src-miniquake-input-ml-1191726599"></a>
### Joy_AdvancedUpdate_f

```ml
function Joy_AdvancedUpdate_f()
```

Mirror Quake's Joy_AdvancedUpdate_f routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1040)

<a id="constant-constant-miniquake-input-joy-max-axes-const-joy-max-axes-6-src-miniquake-input-ml-37474370"></a>
### JOY_MAX_AXES

```ml
const JOY_MAX_AXES = 6
```

Defines the joy max axes value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L41)

<a id="constant-constant-miniquake-input-joy-relative-axis-const-joy-relative-axis-16-src-miniquake-input-ml-541196175"></a>
### JOY_RELATIVE_AXIS

```ml
const JOY_RELATIVE_AXIS = 16
```

Defines the joy relative axis value used by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L39)

<a id="global-global-miniquake-input-joyadvancedinitialized-joyadvancedinitialized-src-miniquake-input-ml-1523432809"></a>
### joyAdvancedInitialized

```ml
joyAdvancedInitialized
```

Tracks the module-level joy advanced initialized state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L82)

<a id="global-global-miniquake-input-joyavailable-joyavailable-src-miniquake-input-ml-234558283"></a>
### joyAvailable

```ml
joyAvailable
```

Tracks the module-level joy available state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L80)

<a id="global-global-miniquake-input-joyaxes-joyaxes-src-miniquake-input-ml-2131371705"></a>
### joyAxes

```ml
joyAxes
```

Tracks the module-level joy axes state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L92)

<a id="global-global-miniquake-input-joyaxismap-joyaxismap-src-miniquake-input-ml-193069671"></a>
### joyAxisMap

```ml
joyAxisMap
```

Tracks the module-level joy axis map state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L94)

<a id="global-global-miniquake-input-joybuttoncount-joybuttoncount-src-miniquake-input-ml-1904673283"></a>
### joyButtonCount

```ml
joyButtonCount
```

Tracks the module-level joy button count state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L86)

<a id="global-global-miniquake-input-joycontrolmap-joycontrolmap-src-miniquake-input-ml-1345385397"></a>
### joyControlMap

```ml
joyControlMap
```

Tracks the module-level joy control map state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L96)

<a id="global-global-miniquake-input-joyhaspov-joyhaspov-src-miniquake-input-ml-169410105"></a>
### joyHasPov

```ml
joyHasPov
```

Tracks the module-level joy has pov state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L84)

<a id="global-global-miniquake-input-joyoldbuttonstate-joyoldbuttonstate-src-miniquake-input-ml-396711421"></a>
### joyOldButtonState

```ml
joyOldButtonState
```

Tracks the previous module-level joystick-button state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L88)

<a id="global-global-miniquake-input-joyoldpovstate-joyoldpovstate-src-miniquake-input-ml-498513947"></a>
### joyOldPovState

```ml
joyOldPovState
```

Tracks the previous module-level joystick POV state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L90)

<a id="global-global-miniquake-input-joypov-joypov-src-miniquake-input-ml-1653478611"></a>
### joyPov

```ml
joyPov
```

Tracks the module-level joy pov state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L110)

<a id="global-global-miniquake-input-joysnapshotbuttons-joysnapshotbuttons-src-miniquake-input-ml-1075335783"></a>
### joySnapshotButtons

```ml
joySnapshotButtons
```

Tracks the module-level joy snapshot buttons state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L112)

<a id="global-global-miniquake-input-joystickstartupoverride-joystickstartupoverride-src-miniquake-input-ml-523244381"></a>
### joystickStartupOverride

```ml
joystickStartupOverride
```

Tracks the module-level joystick startup override state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L108)

<a id="global-global-miniquake-input-joysticktestsnapshot-joysticktestsnapshot-src-miniquake-input-ml-372478537"></a>
### joystickTestSnapshot

```ml
joystickTestSnapshot
```

Tracks the module-level joystick test snapshot state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L106)

<a id="function-function-miniquake-input-keycodeforname-function-keycodeforname-name-src-miniquake-input-ml-1905548044"></a>
### keyCodeForName

```ml
function keyCodeForName(name)
```

Return key code for name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L418)

<a id="function-function-miniquake-input-keydown-function-keydown-button-key-src-miniquake-input-ml-1383407288"></a>
### KeyDown

```ml
function KeyDown(button, key)
```

KeyDown/KeyUp retain the original two-key ownership rule. A key number of -1 is the console's manual, continuously-held form; void on KeyUp is the original "unstick this action" command with no key-number argument.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `button` | `dynamic` | — | The button input consumed by `KeyDown`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L206)

<a id="function-function-miniquake-input-keyisdown-function-keyisdown-code-src-miniquake-input-ml-167098684"></a>
### keyIsDown

```ml
function keyIsDown(code)
```

Implements the `keyIsDown` operation for `miniquake.input` (key is down).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `keyIsDown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L695)

<a id="function-function-miniquake-input-keyisdownwithmousesnapshot-function-keyisdownwithmousesnapshot-code-mousebuttons-src-miniquake-input-ml-960230462"></a>
### keyIsDownWithMouseSnapshot

```ml
function keyIsDownWithMouseSnapshot(code, mouseButtons)
```

Test a physical key while reusing the mouse snapshot captured for this poll. Keyboard and joystick semantics deliberately remain identical to keyIsDown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `keyIsDownWithMouseSnapshot`. |
| `mouseButtons` | `dynamic` | — | The mouse buttons input consumed by `keyIsDownWithMouseSnapshot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L714)

<a id="function-function-miniquake-input-keynameforcode-function-keynameforcode-code-src-miniquake-input-ml-698354034"></a>
### keyNameForCode

```ml
function keyNameForCode(code)
```

Implements the `keyNameForCode` operation for `miniquake.input` (key name for code).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `keyNameForCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L465)

<a id="function-function-miniquake-input-keypressedforcode-function-keypressedforcode-code-src-miniquake-input-ml-859809844"></a>
### keyPressedForCode

```ml
function keyPressedForCode(code)
```

Implements the `keyPressedForCode` operation for `miniquake.input` (key pressed for code).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `keyPressedForCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L991)

<a id="function-function-miniquake-input-keyup-function-keyup-button-key-src-miniquake-input-ml-695780886"></a>
### KeyUp

```ml
function KeyUp(button, key)
```

Implements the `KeyUp` operation for `miniquake.input` (key up).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `button` | `dynamic` | — | The button input consumed by `KeyUp`. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L225)

<a id="global-global-miniquake-input-lookspringenabled-lookspringenabled-src-miniquake-input-ml-1200322561"></a>
### lookSpringEnabled

```ml
lookSpringEnabled
```

Tracks the module-level look spring enabled state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L175)

<a id="function-function-miniquake-input-lower-function-lower-text-src-miniquake-input-ml-834232558"></a>
### lower

```ml
function lower(text)
```

Convert data for lower.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L412)

<a id="global-global-miniquake-input-mouseaccumx-mouseaccumx-src-miniquake-input-ml-1828257393"></a>
### mouseAccumX

```ml
mouseAccumX
```

Tracks the module-level mouse accum x state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L74)

<a id="global-global-miniquake-input-mouseaccumy-mouseaccumy-src-miniquake-input-ml-808859525"></a>
### mouseAccumY

```ml
mouseAccumY
```

Tracks the module-level mouse accum y state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L76)

<a id="global-global-miniquake-input-mouseactivatetoggle-mouseactivatetoggle-src-miniquake-input-ml-1427869041"></a>
### mouseActivateToggle

```ml
mouseActivateToggle
```

Tracks the module-level mouse activate toggle state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L66)

<a id="global-global-miniquake-input-mouseactive-mouseactive-src-miniquake-input-ml-1459935029"></a>
### mouseActive

```ml
mouseActive
```

Tracks the module-level mouse active state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L64)

<a id="global-global-miniquake-input-mousecaptured-mousecaptured-src-miniquake-input-ml-995931685"></a>
### mouseCaptured

```ml
mouseCaptured
```

Tracks the module-level mouse captured state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L60)

<a id="global-global-miniquake-input-mousedeltascratch-mousedeltascratch-src-miniquake-input-ml-1184189477"></a>
### mouseDeltaScratch

```ml
mouseDeltaScratch
```

Tracks the module-level mouse delta scratch state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L78)

<a id="global-global-miniquake-input-mousefilterready-mousefilterready-src-miniquake-input-ml-1103894657"></a>
### mouseFilterReady

```ml
mouseFilterReady
```

Tracks the module-level mouse filter ready state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L58)

<a id="global-global-miniquake-input-mouseinitialized-mouseinitialized-src-miniquake-input-ml-354022583"></a>
### mouseInitialized

```ml
mouseInitialized
```

Tracks the module-level mouse initialized state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L62)

<a id="global-global-miniquake-input-mouseoldbuttonstate-mouseoldbuttonstate-src-miniquake-input-ml-990601829"></a>
### mouseOldButtonState

```ml
mouseOldButtonState
```

Tracks the previous module-level mouse-button state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L72)

<a id="global-global-miniquake-input-mouseshowtoggle-mouseshowtoggle-src-miniquake-input-ml-848700817"></a>
### mouseShowToggle

```ml
mouseShowToggle
```

Tracks the module-level mouse show toggle state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L68)

<a id="global-global-miniquake-input-nojoystickrequested-nojoystickrequested-src-miniquake-input-ml-376222569"></a>
### noJoystickRequested

```ml
noJoystickRequested
```

Tracks the module-level no joystick requested state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L102)

<a id="global-global-miniquake-input-nomouserequested-nomouserequested-src-miniquake-input-ml-453629769"></a>
### noMouseRequested

```ml
noMouseRequested
```

Tracks the module-level no mouse requested state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L100)

<a id="global-global-miniquake-input-oldmousex-oldmousex-src-miniquake-input-ml-455468245"></a>
### oldMouseX

```ml
oldMouseX
```

Tracks the module-level old mouse x state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L54)

<a id="global-global-miniquake-input-oldmousey-oldmousey-src-miniquake-input-ml-1413629253"></a>
### oldMouseY

```ml
oldMouseY
```

Tracks the module-level old mouse y state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L56)

<a id="global-global-miniquake-input-pitchdriftstartrequested-pitchdriftstartrequested-src-miniquake-input-ml-1107694147"></a>
### pitchDriftStartRequested

```ml
pitchDriftStartRequested
```

Tracks the module-level pitch drift start requested state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L173)

<a id="global-global-miniquake-input-pitchdriftstoprequested-pitchdriftstoprequested-src-miniquake-input-ml-1744193821"></a>
### pitchDriftStopRequested

```ml
pitchDriftStopRequested
```

Tracks the module-level pitch drift stop requested state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L171)

<a id="function-function-miniquake-input-polledbindingholdskey-function-polledbindingholdskey-command-key-mousebuttons-src-miniquake-input-ml-1403921027"></a>
### polledBindingHoldsKey

```ml
function polledBindingHoldsKey(command, key, mouseButtons)
```

Check a held owner against the pre-normalized polling cache and current physical snapshot without allocating or rescanning unrelated bind commands.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `mouseButtons` | `dynamic` | — | The mouse buttons input consumed by `polledBindingHoldsKey`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L934)

<a id="global-global-miniquake-input-polledbindings-polledbindings-src-miniquake-input-ml-779774985"></a>
### polledBindings

```ml
polledBindings
```

Tracks the module-level polled bindings state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L116)

<a id="function-function-miniquake-input-polledkeydownat-function-polledkeydownat-code-mousebuttons-src-miniquake-input-ml-2119738970"></a>
### polledKeyDownAt

```ml
function polledKeyDownAt(code, mouseButtons)
```

Resolve a binding level from the frame-local bulk keyboard/mouse snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `polledKeyDownAt`. |
| `mouseButtons` | `dynamic` | — | The mouse buttons input consumed by `polledKeyDownAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L947)

<a id="global-global-miniquake-input-polledkeydownsnapshot-polledkeydownsnapshot-src-miniquake-input-ml-478826993"></a>
### polledKeyDownSnapshot

```ml
polledKeyDownSnapshot
```

Tracks the module-level polled key down snapshot state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L118)

<a id="function-function-miniquake-input-polledkeypressedat-function-polledkeypressedat-code-src-miniquake-input-ml-1797252490"></a>
### polledKeyPressedAt

```ml
function polledKeyPressedAt(code)
```

Resolve a binding press edge from the frame-local bulk keyboard snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `polledKeyPressedAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L983)

<a id="global-global-miniquake-input-polledkeypressedsnapshot-polledkeypressedsnapshot-src-miniquake-input-ml-651920895"></a>
### polledKeyPressedSnapshot

```ml
polledKeyPressedSnapshot
```

Tracks the module-level polled key pressed snapshot state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L120)

<a id="global-global-miniquake-input-polledkeyquerymask-polledkeyquerymask-src-miniquake-input-ml-1953422959"></a>
### polledKeyQueryMask

```ml
polledKeyQueryMask
```

Tracks the module-level polled key query mask state owned by `miniquake.input`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L122)

<a id="function-function-miniquake-input-quakekeyforscancode-function-quakekeyforscancode-scancode-src-miniquake-input-ml-694082825"></a>
### quakeKeyForScanCode

```ml
function quakeKeyForScanCode(scanCode)
```

gl_vidnt.c does not translate keyboard messages through virtual-key values. It uses bits 16..23 of lParam, i.e. the hardware scan code.  Keeping that mapping here preserves keypad/navigation distinctions and makes keyboard input independent of the active Windows keyboard layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanCode` | `dynamic` | — | The scan code input consumed by `quakeKeyForScanCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L804)

<a id="function-function-miniquake-input-quakekeyforvirtualkey-function-quakekeyforvirtualkey-virtualkey-src-miniquake-input-ml-857943163"></a>
### quakeKeyForVirtualKey

```ml
function quakeKeyForVirtualKey(virtualKey)
```

Implements the `quakeKeyForVirtualKey` operation for `miniquake.input` (quake key for virtual key).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `virtualKey` | `dynamic` | — | The virtual key input consumed by `quakeKeyForVirtualKey`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L765)

<a id="function-function-miniquake-input-quotebinding-function-quotebinding-text-src-miniquake-input-ml-107841116"></a>
### quoteBinding

```ml
function quoteBinding(text)
```

Convert data for quote binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L666)

<a id="function-function-miniquake-input-rawvaluepointer-function-rawvaluepointer-axis-src-miniquake-input-ml-222075154"></a>
### RawValuePointer

```ml
function RawValuePointer(axis)
```

Implements the `RawValuePointer` operation for `miniquake.input` (raw value pointer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axis` | `dynamic` | — | The axis input consumed by `RawValuePointer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1063)

<a id="function-function-miniquake-input-rebuildpolledbindings-function-rebuildpolledbindings-src-miniquake-input-ml-129192329"></a>
### rebuildPolledBindings

```ml
function rebuildPolledBindings()
```

Rebuild the small, immutable-at-runtime subset needed by the live input poll. Bind commands that are handled solely by Key_Event are intentionally absent.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L884)

<a id="function-function-miniquake-input-requeststartpitchdrift-function-requeststartpitchdrift-src-miniquake-input-ml-1481626747"></a>
### requestStartPitchDrift

```ml
function requestStartPitchDrift()
```

Implements the `requestStartPitchDrift` operation for `miniquake.input` (request start pitch drift).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L387)

<a id="function-function-miniquake-input-requeststoppitchdrift-function-requeststoppitchdrift-src-miniquake-input-ml-2048766131"></a>
### requestStopPitchDrift

```ml
function requestStopPitchDrift()
```

Implements the `requestStopPitchDrift` operation for `miniquake.input` (request stop pitch drift).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L380)

<a id="function-function-miniquake-input-resetbindings-function-resetbindings-src-miniquake-input-ml-86247245"></a>
### resetBindings

```ml
function resetBindings()
```

Update module state for bindings.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L573)

<a id="function-function-miniquake-input-resetbutton-function-resetbutton-button-src-miniquake-input-ml-1252509161"></a>
### resetButton

```ml
function resetButton(button)
```

Update module state for button.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `button` | `dynamic` | — | The button input consumed by `resetButton`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1271)

<a id="function-function-miniquake-input-resetmouse-function-resetmouse-src-miniquake-input-ml-1010978499"></a>
### resetMouse

```ml
function resetMouse()
```

Clear both the MiniLang filter history and any native cursor displacement accumulated while the menu, console, or another application owned the mouse. WinQuake performs the equivalent reset whenever capture is reacquired.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1728)

<a id="function-function-miniquake-input-samplefilteredmousedelta-function-samplefilteredmousedelta-filterenabled-output-src-miniquake-input-ml-1963980155"></a>
### sampleFilteredMouseDelta

```ml
function sampleFilteredMouseDelta(filterEnabled, output)
```

Sample filtered mouse motion into caller-owned two-element storage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filterEnabled` | `dynamic` | — | The filter enabled input consumed by `sampleFilteredMouseDelta`. |
| `output` | `dynamic` | — | Destination that receives the filtered mouse delta. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1755)

<a id="function-function-miniquake-input-setbindingcode-function-setbindingcode-code-command-src-miniquake-input-ml-1611930079"></a>
### setBindingCode

```ml
function setBindingCode(code, command)
```

Update module state for binding code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `setBindingCode`. |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L509)

<a id="function-function-miniquake-input-seteventkeystate-function-seteventkeystate-code-down-src-miniquake-input-ml-89474010"></a>
### setEventKeyState

```ml
function setEventKeyState(code, down)
```

Record the ordered Quake key level delivered by the Win32 event queue. Keeping this separate from kbutton ownership lets live polling repair a consumed command without trusting a transient asynchronous key sample.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `setEventKeyState`. |
| `down` | `dynamic` | — | The down input consumed by `setEventKeyState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L965)

<a id="function-function-miniquake-input-setjoysticksnapshot-function-setjoysticksnapshot-axes-buttons-pov-buttoncount-haspov-src-miniquake-input-ml-1908456702"></a>
### setJoystickSnapshot

```ml
function setJoystickSnapshot(axes, buttons, pov, buttonCount, hasPov)
```

Sets joystick snapshot for `miniquake.input`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axes` | `dynamic` | — | The axes input consumed by `setJoystickSnapshot`. |
| `buttons` | `dynamic` | — | The buttons input consumed by `setJoystickSnapshot`. |
| `pov` | `dynamic` | — | The pov input consumed by `setJoystickSnapshot`. |
| `buttonCount` | `dynamic` | — | Number of entries or units to process. |
| `hasPov` | `dynamic` | — | The has pov input consumed by `setJoystickSnapshot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1098)

<a id="function-function-miniquake-input-setlookspring-function-setlookspring-enabled-src-miniquake-input-ml-125354668"></a>
### setLookSpring

```ml
function setLookSpring(enabled)
```

Update module state for look spring.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L404)

<a id="function-function-miniquake-input-setmousecapture-function-setmousecapture-enabled-src-miniquake-input-ml-1455631874"></a>
### setMouseCapture

```ml
function setMouseCapture(enabled)
```

Keep the capture transition in one place.  Calling this every host frame is intentional: it only touches Win32 when the desired state changes, while a focus loss/reacquire reliably resets both native and filtered deltas.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `dynamic` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1746)

<a id="function-function-miniquake-input-synchronizebutton-function-synchronizebutton-command-src-miniquake-input-ml-373880400"></a>
### synchronizeButton

```ml
function synchronizeButton(command)
```

Translate the native polling API into the same edge events Key_Event feeds into cl_input.c. This preserves ownership when two bound keys hold one action, and also preserves a press/release completed between two frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1001)

<a id="function-function-miniquake-input-unbindall-function-unbindall-src-miniquake-input-ml-1083367549"></a>
### unbindAll

```ml
function unbindAll()
```

Implements the `unbindAll` operation for `miniquake.input` (unbind all).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L565)

<a id="function-function-miniquake-input-unbindcommand-function-unbindcommand-command-src-miniquake-input-ml-552575702"></a>
### unbindCommand

```ml
function unbindCommand(command)
```

Implements the `unbindCommand` operation for `miniquake.input` (unbind command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L643)

<a id="function-function-miniquake-input-unbindkey-function-unbindkey-keyname-src-miniquake-input-ml-549176899"></a>
### unbindKey

```ml
function unbindKey(keyName)
```

Implements the `unbindKey` operation for `miniquake.input` (unbind key).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L551)

<a id="function-function-miniquake-input-updatejoysticksnapshot-function-updatejoysticksnapshot-axes-buttons-pov-src-miniquake-input-ml-1046655936"></a>
### updateJoystickSnapshot

```ml
function updateJoystickSnapshot(axes, buttons, pov)
```

Updates joystick snapshot for `miniquake.input`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axes` | `dynamic` | — | The axes input consumed by `updateJoystickSnapshot`. |
| `buttons` | `dynamic` | — | The buttons input consumed by `updateJoystickSnapshot`. |
| `pov` | `dynamic` | — | The pov input consumed by `updateJoystickSnapshot`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L1117)

<a id="function-function-miniquake-input-virtualkeyforcode-function-virtualkeyforcode-code-src-miniquake-input-ml-815436674"></a>
### virtualKeyForCode

```ml
function virtualKeyForCode(code)
```

Implements the `virtualKeyForCode` operation for `miniquake.input` (virtual key for code).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `virtualKeyForCode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/input.ml#L729)
