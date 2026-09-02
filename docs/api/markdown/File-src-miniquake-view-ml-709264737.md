# `src/miniquake/view.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.view`](Package-miniquake-view-1008417938.md)

Reachable from entry: **yes**

## Imports

- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/math.ml` as `stdmath` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/math.ml` — external dependency

## Declarations

<a id="function-function-miniquake-view-absolute-function-absolute-value-src-miniquake-view-ml-695156590"></a>
### absolute

```ml
function absolute(value)
```

Implements the `absolute` operation for `miniquake.view` (absolute).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `absolute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L164)

<a id="function-function-miniquake-view-adddamage-function-adddamage-state-count-fromdirection-viewangles-kickroll-kickpitch-kicktime-src-miniquake-view-ml-661364349"></a>
### addDamage

```ml
function addDamage(state, count, fromDirection, viewAngles, kickRoll, kickPitch, kickTime)
```

Compatibility entry points retained for the existing focused tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `addDamage`. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `fromDirection` | `dynamic` | — | The from direction input consumed by `addDamage`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `addDamage`. |
| `kickRoll` | `dynamic` | — | The kick roll input consumed by `addDamage`. |
| `kickPitch` | `dynamic` | — | The kick pitch input consumed by `addDamage`. |
| `kickTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L948)

<a id="function-function-miniquake-view-angledelta-function-angledelta-angle-src-miniquake-view-ml-1568225760"></a>
### angledelta

```ml
function angledelta(angle)
```

Implements the `angledelta` operation for `miniquake.view` (angledelta).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angle` | `dynamic` | — | The angle input consumed by `angledelta`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L548)

<a id="function-function-miniquake-view-buildgammatable-function-buildgammatable-state-gamma-src-miniquake-view-ml-748656449"></a>
### BuildGammaTable

```ml
function BuildGammaTable(state, gamma)
```

Create and initialize gamma table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `BuildGammaTable`. |
| `gamma` | `dynamic` | — | The gamma input consumed by `BuildGammaTable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L301)

<a id="function-function-miniquake-view-calcbob-function-calcbob-time-velocity-bobamount-bobcycle-bobup-src-miniquake-view-ml-1376984445"></a>
### calcBob

```ml
function calcBob(time, velocity, bobAmount, bobCycle, bobUp)
```

Implements the `calcBob` operation for `miniquake.view` (calc bob).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |
| `bobAmount` | `dynamic` | — | The bob amount input consumed by `calcBob`. |
| `bobCycle` | `dynamic` | — | The bob cycle input consumed by `calcBob`. |
| `bobUp` | `dynamic` | — | The bob up input consumed by `calcBob`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L226)

<a id="function-function-miniquake-view-calcgunangle-function-calcgunangle-state-clienttime-frametime-idlescale-yawcycle-rollcycle-pitchcycle-yawlevel-rolllevel-pitchlevel-src-miniquake-view-ml-995924524"></a>
### CalcGunAngle

```ml
function CalcGunAngle(state, clientTime, frameTime, idleScale, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
```

Implements the `CalcGunAngle` operation for `miniquake.view` (calc gun angle).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `CalcGunAngle`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `idleScale` | `dynamic` | — | The idle scale input consumed by `CalcGunAngle`. |
| `yawCycle` | `dynamic` | — | The yaw cycle input consumed by `CalcGunAngle`. |
| `rollCycle` | `dynamic` | — | The roll cycle input consumed by `CalcGunAngle`. |
| `pitchCycle` | `dynamic` | — | The pitch cycle input consumed by `CalcGunAngle`. |
| `yawLevel` | `dynamic` | — | The yaw level input consumed by `CalcGunAngle`. |
| `rollLevel` | `dynamic` | — | The roll level input consumed by `CalcGunAngle`. |
| `pitchLevel` | `dynamic` | — | The pitch level input consumed by `CalcGunAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L565)

<a id="function-function-miniquake-view-calcroll-function-calcroll-angles-velocity-rollangle-rollspeed-src-miniquake-view-ml-1602653692"></a>
### calcRoll

```ml
function calcRoll(angles, velocity, rollAngle, rollSpeed)
```

Implements the `calcRoll` operation for `miniquake.view` (calc roll).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |
| `rollAngle` | `dynamic` | — | The roll angle input consumed by `calcRoll`. |
| `rollSpeed` | `dynamic` | — | The roll speed input consumed by `calcRoll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L191)

<a id="function-function-miniquake-view-calculate-function-calculate-state-player-cameraangles-clienttime-frametime-bobamount-bobcycle-bobup-rollangle-rollspeed-kicktime-src-miniquake-view-ml-485553303"></a>
### calculate

```ml
function calculate(state, player, cameraAngles, clientTime, frameTime, bobAmount, bobCycle, bobUp, rollAngle, rollSpeed, kickTime)
```

Compute the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `calculate`. |
| `player` | `dynamic` | — | The player input consumed by `calculate`. |
| `cameraAngles` | `dynamic` | — | The camera angles input consumed by `calculate`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `bobAmount` | `dynamic` | — | The bob amount input consumed by `calculate`. |
| `bobCycle` | `dynamic` | — | The bob cycle input consumed by `calculate`. |
| `bobUp` | `dynamic` | — | The bob up input consumed by `calculate`. |
| `rollAngle` | `dynamic` | — | The roll angle input consumed by `calculate`. |
| `rollSpeed` | `dynamic` | — | The roll speed input consumed by `calculate`. |
| `kickTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L981)

<a id="function-function-miniquake-view-create-function-create-src-miniquake-view-ml-176493245"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.view` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L64)

<a id="constant-constant-miniquake-view-cshift-bonus-const-cshift-bonus-2-src-miniquake-view-ml-341600896"></a>
### CSHIFT_BONUS

```ml
const CSHIFT_BONUS = 2
```

Defines the cshift bonus value used by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L25)

<a id="constant-constant-miniquake-view-cshift-contents-const-cshift-contents-0-src-miniquake-view-ml-624530286"></a>
### CSHIFT_CONTENTS

```ml
const CSHIFT_CONTENTS = 0
```

Defines the cshift contents value used by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L21)

<a id="constant-constant-miniquake-view-cshift-damage-const-cshift-damage-1-src-miniquake-view-ml-1795680461"></a>
### CSHIFT_DAMAGE

```ml
const CSHIFT_DAMAGE = 1
```

Defines the cshift damage value used by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L23)

<a id="constant-constant-miniquake-view-cshift-powerup-const-cshift-powerup-3-src-miniquake-view-ml-1389922021"></a>
### CSHIFT_POWERUP

```ml
const CSHIFT_POWERUP = 3
```

Defines the cshift powerup value used by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L27)

<a id="function-function-miniquake-view-decaydamage-function-decaydamage-state-frametime-kicktime-src-miniquake-view-ml-477168795"></a>
### decayDamage

```ml
function decayDamage(state, frameTime, kickTime)
```

Implements the `decayDamage` operation for `miniquake.view` (decay damage).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `decayDamage`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `kickTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L958)

<a id="function-function-miniquake-view-emptygamma-function-emptygamma-src-miniquake-view-ml-2031394537"></a>
### emptyGamma

```ml
function emptyGamma()
```

Implements the `emptyGamma` operation for `miniquake.view` (empty gamma).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L48)

<a id="function-function-miniquake-view-emptyramps-function-emptyramps-src-miniquake-view-ml-930175281"></a>
### emptyRamps

```ml
function emptyRamps()
```

Implements the `emptyRamps` operation for `miniquake.view` (empty ramps).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L59)

<a id="constant-constant-miniquake-view-num-cshifts-const-num-cshifts-4-src-miniquake-view-ml-424660610"></a>
### NUM_CSHIFTS

```ml
const NUM_CSHIFTS = 4
```

Defines the num cshifts value used by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L45)

<a id="constant-constant-miniquake-view-pi-const-pi-3-14159265358979-src-miniquake-view-ml-1965572797"></a>
### PI

```ml
const PI = 3.14159265358979
```

Defines the pi value used by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L19)

<a id="function-function-miniquake-view-reset-function-reset-state-playerorigin-src-miniquake-view-ml-866680633"></a>
### reset

```ml
function reset(state, playerOrigin)
```

Implements the `reset` operation for `miniquake.view` (reset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `reset`. |
| `playerOrigin` | `dynamic` | — | The player origin input consumed by `reset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L116)

<a id="function-function-miniquake-view-smoothstairstep-function-smoothstairstep-state-player-frametime-src-miniquake-view-ml-741910411"></a>
### smoothStairStep

```ml
function smoothStairStep(state, player, frameTime)
```

Implements the `smoothStairStep` operation for `miniquake.view` (smooth stair step).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `smoothStairStep`. |
| `player` | `dynamic` | — | The player input consumed by `smoothStairStep`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L674)

<a id="function-function-miniquake-view-v-addidle-function-v-addidle-state-clienttime-idlescale-yawcycle-rollcycle-pitchcycle-yawlevel-rolllevel-pitchlevel-src-miniquake-view-ml-1689773754"></a>
### V_AddIdle

```ml
function V_AddIdle(state, clientTime, idleScale, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
```

Mirror Quake's V_AddIdle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_AddIdle`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `idleScale` | `dynamic` | — | The idle scale input consumed by `V_AddIdle`. |
| `yawCycle` | `dynamic` | — | The yaw cycle input consumed by `V_AddIdle`. |
| `rollCycle` | `dynamic` | — | The roll cycle input consumed by `V_AddIdle`. |
| `pitchCycle` | `dynamic` | — | The pitch cycle input consumed by `V_AddIdle`. |
| `yawLevel` | `dynamic` | — | The yaw level input consumed by `V_AddIdle`. |
| `rollLevel` | `dynamic` | — | The roll level input consumed by `V_AddIdle`. |
| `pitchLevel` | `dynamic` | — | The pitch level input consumed by `V_AddIdle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L615)

<a id="function-function-miniquake-view-v-bonusflash-f-function-v-bonusflash-f-state-src-miniquake-view-ml-26630626"></a>
### V_BonusFlash_f

```ml
function V_BonusFlash_f(state)
```

Mirror Quake's V_BonusFlash_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_BonusFlash_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L396)

<a id="function-function-miniquake-view-v-boundoffsets-function-v-boundoffsets-state-entityorigin-src-miniquake-view-ml-2129475289"></a>
### V_BoundOffsets

```ml
function V_BoundOffsets(state, entityOrigin)
```

Mirror Quake's V_BoundOffsets routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_BoundOffsets`. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `V_BoundOffsets`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L595)

<a id="function-function-miniquake-view-v-calcblend-function-v-calcblend-state-cshiftpercent-src-miniquake-view-ml-225378610"></a>
### V_CalcBlend

```ml
function V_CalcBlend(state, cshiftPercent)
```

Mirror Quake's V_CalcBlend routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CalcBlend`. |
| `cshiftPercent` | `dynamic` | — | The cshift percent input consumed by `V_CalcBlend`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L464)

<a id="function-function-miniquake-view-v-calcbob-function-v-calcbob-time-velocity-bobamount-bobcycle-bobup-src-miniquake-view-ml-1359777651"></a>
### V_CalcBob

```ml
function V_CalcBob(time, velocity, bobAmount, bobCycle, bobUp)
```

Mirror Quake's V_CalcBob routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |
| `bobAmount` | `dynamic` | — | The bob amount input consumed by `V_CalcBob`. |
| `bobCycle` | `dynamic` | — | The bob cycle input consumed by `V_CalcBob`. |
| `bobUp` | `dynamic` | — | The bob up input consumed by `V_CalcBob`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L201)

<a id="function-function-miniquake-view-v-calcintermissionrefdef-function-v-calcintermissionrefdef-state-player-clienttime-yawcycle-rollcycle-pitchcycle-yawlevel-rolllevel-pitchlevel-src-miniquake-view-ml-1964648831"></a>
### V_CalcIntermissionRefdef

```ml
function V_CalcIntermissionRefdef(state, player, clientTime, yawCycle, rollCycle, pitchCycle, yawLevel, rollLevel, pitchLevel)
```

Mirror Quake's V_CalcIntermissionRefdef routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CalcIntermissionRefdef`. |
| `player` | `dynamic` | — | The player input consumed by `V_CalcIntermissionRefdef`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `yawCycle` | `dynamic` | — | The yaw cycle input consumed by `V_CalcIntermissionRefdef`. |
| `rollCycle` | `dynamic` | — | The roll cycle input consumed by `V_CalcIntermissionRefdef`. |
| `pitchCycle` | `dynamic` | — | The pitch cycle input consumed by `V_CalcIntermissionRefdef`. |
| `yawLevel` | `dynamic` | — | The yaw level input consumed by `V_CalcIntermissionRefdef`. |
| `rollLevel` | `dynamic` | — | The roll level input consumed by `V_CalcIntermissionRefdef`. |
| `pitchLevel` | `dynamic` | — | The pitch level input consumed by `V_CalcIntermissionRefdef`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L657)

<a id="function-function-miniquake-view-v-calcpowerupcshift-function-v-calcpowerupcshift-state-items-src-miniquake-view-ml-1279032118"></a>
### V_CalcPowerupCshift

```ml
function V_CalcPowerupCshift(state, items)
```

Mirror Quake's V_CalcPowerupCshift routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CalcPowerupCshift`. |
| `items` | `dynamic` | — | The items input consumed by `V_CalcPowerupCshift`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L433)

<a id="function-function-miniquake-view-v-calcrefdef-function-v-calcrefdef-state-player-viewangles-idealpitch-forwardmove-forwardspeed-clienttime-frametime-stepframetime-demoplayback-registry-src-miniquake-view-ml-1600065918"></a>
### V_CalcRefdef

```ml
function V_CalcRefdef(state, player, viewAngles, idealPitch, forwardMove, forwardSpeed, clientTime, frameTime, stepFrameTime, demoPlayback, registry)
```

Mirror Quake's V_CalcRefdef routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CalcRefdef`. |
| `player` | `dynamic` | — | The player input consumed by `V_CalcRefdef`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `V_CalcRefdef`. |
| `idealPitch` | `dynamic` | — | The ideal pitch input consumed by `V_CalcRefdef`. |
| `forwardMove` | `dynamic` | — | The forward move input consumed by `V_CalcRefdef`. |
| `forwardSpeed` | `dynamic` | — | The forward speed input consumed by `V_CalcRefdef`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `stepFrameTime` | `dynamic` | — | Time value used by the operation. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `V_CalcRefdef`. |
| `registry` | `dynamic` | — | The registry input consumed by `V_CalcRefdef`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L704)

<a id="function-function-miniquake-view-v-calcroll-function-v-calcroll-angles-velocity-rollangle-rollspeed-src-miniquake-view-ml-162020940"></a>
### V_CalcRoll

```ml
function V_CalcRoll(angles, velocity, rollAngle, rollSpeed)
```

V_CalcRoll is also consumed by sv_user.c in the original engine.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angles` | `dynamic` | — | Orientation angles used by the operation. |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |
| `rollAngle` | `dynamic` | — | The roll angle input consumed by `V_CalcRoll`. |
| `rollSpeed` | `dynamic` | — | The roll speed input consumed by `V_CalcRoll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L174)

<a id="function-function-miniquake-view-v-calcviewroll-function-v-calcviewroll-state-entityangles-velocity-health-frametime-rollangle-rollspeed-kicktime-src-miniquake-view-ml-163667779"></a>
### V_CalcViewRoll

```ml
function V_CalcViewRoll(state, entityAngles, velocity, health, frameTime, rollAngle, rollSpeed, kickTime)
```

Mirror Quake's V_CalcViewRoll routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CalcViewRoll`. |
| `entityAngles` | `dynamic` | — | The entity angles input consumed by `V_CalcViewRoll`. |
| `velocity` | `dynamic` | — | Velocity applied by the operation. |
| `health` | `dynamic` | — | The health input consumed by `V_CalcViewRoll`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `rollAngle` | `dynamic` | — | The roll angle input consumed by `V_CalcViewRoll`. |
| `rollSpeed` | `dynamic` | — | The roll speed input consumed by `V_CalcViewRoll`. |
| `kickTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L631)

<a id="function-function-miniquake-view-v-checkgamma-function-v-checkgamma-state-gamma-src-miniquake-view-ml-174184247"></a>
### V_CheckGamma

```ml
function V_CheckGamma(state, gamma)
```

Mirror Quake's V_CheckGamma routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CheckGamma`. |
| `gamma` | `dynamic` | — | The gamma input consumed by `V_CheckGamma`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L323)

<a id="function-function-miniquake-view-v-clearclientstate-function-v-clearclientstate-state-src-miniquake-view-ml-115665958"></a>
### V_ClearClientState

```ml
function V_ClearClientState(state)
```

The cl-owned fields used by view.c are cleared by CL_ClearState's memset. Renderer statics (oldz, old gun angles, damage kick globals, gamma state and the user-configurable cshift_empty) intentionally survive map changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_ClearClientState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L138)

<a id="function-function-miniquake-view-v-commandtrace-function-v-commandtrace-state-src-miniquake-view-ml-939377694"></a>
### V_CommandTrace

```ml
function V_CommandTrace(state)
```

Mirror Quake's V_CommandTrace routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_CommandTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L897)

<a id="function-function-miniquake-view-v-cshift-f-function-v-cshift-f-state-arguments-src-miniquake-view-ml-1555160528"></a>
### V_cshift_f

```ml
function V_cshift_f(state, arguments)
```

Mirror Quake's V_cshift_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_cshift_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L377)

<a id="function-function-miniquake-view-v-driftpitch-function-v-driftpitch-state-viewangles-idealpitch-forwardmove-forwardspeed-frametime-clienttime-centermove-centerspeed-noclipanglehack-onground-demoplayback-src-miniquake-view-ml-204316419"></a>
### V_DriftPitch

```ml
function V_DriftPitch(state, viewAngles, idealPitch, forwardMove, forwardSpeed, frameTime, clientTime, centerMove, centerSpeed, noclipAngleHack, onGround, demoPlayback)
```

Mirror Quake's V_DriftPitch routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_DriftPitch`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `V_DriftPitch`. |
| `idealPitch` | `dynamic` | — | The ideal pitch input consumed by `V_DriftPitch`. |
| `forwardMove` | `dynamic` | — | The forward move input consumed by `V_DriftPitch`. |
| `forwardSpeed` | `dynamic` | — | The forward speed input consumed by `V_DriftPitch`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `centerMove` | `dynamic` | — | The center move input consumed by `V_DriftPitch`. |
| `centerSpeed` | `dynamic` | — | The center speed input consumed by `V_DriftPitch`. |
| `noclipAngleHack` | `dynamic` | — | The noclip angle hack input consumed by `V_DriftPitch`. |
| `onGround` | `dynamic` | — | The on ground input consumed by `V_DriftPitch`. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `V_DriftPitch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L267)

<a id="function-function-miniquake-view-v-init-function-v-init-state-src-miniquake-view-ml-425634578"></a>
### V_Init

```ml
function V_Init(state)
```

Mirror Quake's V_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L903)

<a id="function-function-miniquake-view-v-parsedamage-function-v-parsedamage-state-armor-blood-source-entityorigin-entityangles-kickroll-kickpitch-kicktime-src-miniquake-view-ml-812554808"></a>
### V_ParseDamage

```ml
function V_ParseDamage(state, armor, blood, source, entityOrigin, entityAngles, kickRoll, kickPitch, kickTime)
```

Mirror Quake's V_ParseDamage routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_ParseDamage`. |
| `armor` | `dynamic` | — | The armor input consumed by `V_ParseDamage`. |
| `blood` | `dynamic` | — | The blood input consumed by `V_ParseDamage`. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `entityOrigin` | `dynamic` | — | The entity origin input consumed by `V_ParseDamage`. |
| `entityAngles` | `dynamic` | — | The entity angles input consumed by `V_ParseDamage`. |
| `kickRoll` | `dynamic` | — | The kick roll input consumed by `V_ParseDamage`. |
| `kickPitch` | `dynamic` | — | The kick pitch input consumed by `V_ParseDamage`. |
| `kickTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L340)

<a id="function-function-miniquake-view-v-renderview-function-v-renderview-state-player-client-registry-frametime-paused-demoplayback-intermission-forcedconsole-src-miniquake-view-ml-1183982107"></a>
### V_RenderView

```ml
function V_RenderView(state, player, client, registry, frameTime, paused, demoPlayback, intermission, forcedConsole)
```

Mirror Quake's V_RenderView routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_RenderView`. |
| `player` | `dynamic` | — | The player input consumed by `V_RenderView`. |
| `client` | `dynamic` | — | Client state participating in the operation. |
| `registry` | `dynamic` | — | The registry input consumed by `V_RenderView`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `paused` | `dynamic` | — | The paused input consumed by `V_RenderView`. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `V_RenderView`. |
| `intermission` | `dynamic` | — | The intermission input consumed by `V_RenderView`. |
| `forcedConsole` | `dynamic` | — | The forced console input consumed by `V_RenderView`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L828)

<a id="function-function-miniquake-view-v-setcontentscolor-function-v-setcontentscolor-state-contents-src-miniquake-view-ml-1736412500"></a>
### V_SetContentsColor

```ml
function V_SetContentsColor(state, contents)
```

Mirror Quake's V_SetContentsColor routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_SetContentsColor`. |
| `contents` | `dynamic` | — | The contents input consumed by `V_SetContentsColor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L404)

<a id="function-function-miniquake-view-v-startpitchdrift-function-v-startpitchdrift-state-clienttime-centerspeed-src-miniquake-view-ml-1228167502"></a>
### V_StartPitchDrift

```ml
function V_StartPitchDrift(state, clientTime, centerSpeed)
```

Mirror Quake's V_StartPitchDrift routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_StartPitchDrift`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |
| `centerSpeed` | `dynamic` | — | The center speed input consumed by `V_StartPitchDrift`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L234)

<a id="function-function-miniquake-view-v-stoppitchdrift-function-v-stoppitchdrift-state-clienttime-src-miniquake-view-ml-1426891220"></a>
### V_StopPitchDrift

```ml
function V_StopPitchDrift(state, clientTime)
```

Mirror Quake's V_StopPitchDrift routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_StopPitchDrift`. |
| `clientTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L247)

<a id="function-function-miniquake-view-v-updatepalette-function-v-updatepalette-state-items-frametime-cshiftpercent-gamma-src-miniquake-view-ml-1254861515"></a>
### V_UpdatePalette

```ml
function V_UpdatePalette(state, items, frameTime, cshiftPercent, gamma)
```

This is the GLQUAKE V_UpdatePalette path.  It also constructs the original three gamma ramps so a diagnostic build can compare the software-palette result without asking the platform bridge to own game policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.view` state used by `V_UpdatePalette`. |
| `items` | `dynamic` | — | The items input consumed by `V_UpdatePalette`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `cshiftPercent` | `dynamic` | — | The cshift percent input consumed by `V_UpdatePalette`. |
| `gamma` | `dynamic` | — | The gamma input consumed by `V_UpdatePalette`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L499)

<a id="global-global-miniquake-view-viewtraceempty-viewtraceempty-src-miniquake-view-ml-953358689"></a>
### viewTraceEmpty

```ml
viewTraceEmpty
```

V_RenderView's compatibility trace contains only fixed stage names. Share the immutable variants instead of rebuilding nested arrays every frame.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L31)

<a id="global-global-miniquake-view-viewtraceintermission-viewtraceintermission-src-miniquake-view-ml-1828618395"></a>
### viewTraceIntermission

```ml
viewTraceIntermission
```

Tracks the module-level view trace intermission state owned by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L41)

<a id="global-global-miniquake-view-viewtraceintermissionstereo-viewtraceintermissionstereo-src-miniquake-view-ml-596184427"></a>
### viewTraceIntermissionStereo

```ml
viewTraceIntermissionStereo
```

Tracks the module-level view trace intermission stereo state owned by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L43)

<a id="global-global-miniquake-view-viewtracepaused-viewtracepaused-src-miniquake-view-ml-1990045943"></a>
### viewTracePaused

```ml
viewTracePaused
```

Tracks the module-level view trace paused state owned by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L33)

<a id="global-global-miniquake-view-viewtracepausedstereo-viewtracepausedstereo-src-miniquake-view-ml-846297563"></a>
### viewTracePausedStereo

```ml
viewTracePausedStereo
```

Tracks the module-level view trace paused stereo state owned by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L35)

<a id="global-global-miniquake-view-viewtracerefdef-viewtracerefdef-src-miniquake-view-ml-1192775675"></a>
### viewTraceRefdef

```ml
viewTraceRefdef
```

Tracks the module-level view trace refdef state owned by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L37)

<a id="global-global-miniquake-view-viewtracerefdefstereo-viewtracerefdefstereo-src-miniquake-view-ml-2102975299"></a>
### viewTraceRefdefStereo

```ml
viewTraceRefdefStereo
```

Tracks the module-level view trace refdef stereo state owned by `miniquake.view`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/view.ml#L39)
