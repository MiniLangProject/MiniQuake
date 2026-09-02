# `src/miniquake/quakec/builtins.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.quakec.builtins`](Package-miniquake-quakec-builtins-972389497.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/cmd.ml` as `cmd` → [src/miniquake/cmd.ml](File-src-miniquake-cmd-ml-1014778996.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/filesystem.ml` as `filesystem` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/sprite.ml` as `sprite` → [src/miniquake/format/sprite.ml](File-src-miniquake-format-sprite-ml-531278995.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_events.ml` as `protocolEvents` → [src/miniquake/protocol_events.ml](File-src-miniquake-protocol-events-ml-1275855860.md)
- `miniquake/protocol_transients.ml` as `transients` → [src/miniquake/protocol_transients.ml](File-src-miniquake-protocol-transients-ml-999469098.md)
- `miniquake/quakec/edict.ml` as `qcedict` → [src/miniquake/quakec/edict.ml](File-src-miniquake-quakec-edict-ml-1018045152.md)
- `miniquake/quakec/opcodes.ml` as `op` → [src/miniquake/quakec/opcodes.ml](File-src-miniquake-quakec-opcodes-ml-1466187268.md)
- `miniquake/quakec/vm.ml` as `qvm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/server_collision.ml` as `collision` → [src/miniquake/server_collision.ml](File-src-miniquake-server-collision-ml-849122018.md)
- `miniquake/server_move.ml` as `serverMove` → [src/miniquake/server_move.ml](File-src-miniquake-server-move-ml-1725461935.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-quakec-builtins-absolutebuiltin-function-absolutebuiltin-machine-src-miniquake-quakec-builtins-ml-792475301"></a>
### absoluteBuiltin

```ml
function absoluteBuiltin(machine)
```

Implements the `absoluteBuiltin` operation for `miniquake.quakec.builtins` (absolute builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `absoluteBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1175)

<a id="global-global-miniquake-quakec-builtins-activecontext-activecontext-src-miniquake-quakec-builtins-ml-995130644"></a>
### activeContext

```ml
activeContext
```

Tracks the module-level active context state owned by `miniquake.quakec.builtins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L37)

<a id="function-function-miniquake-quakec-builtins-activeedictcount-function-activeedictcount-machine-src-miniquake-quakec-builtins-ml-1015162137"></a>
### activeEdictCount

```ml
function activeEdictCount(machine)
```

Report whether active edict count holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `activeEdictCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1001)

<a id="function-function-miniquake-quakec-builtins-activeedictlimit-function-activeedictlimit-machine-src-miniquake-quakec-builtins-ml-257663829"></a>
### activeEdictLimit

```ml
function activeEdictLimit(machine)
```

Report whether active edict limit holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `activeEdictLimit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L531)

<a id="function-function-miniquake-quakec-builtins-aimbuiltin-function-aimbuiltin-machine-src-miniquake-quakec-builtins-ml-1299893601"></a>
### aimBuiltin

```ml
function aimBuiltin(machine)
```

Implements the `aimBuiltin` operation for `miniquake.quakec.builtins` (aim builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `aimBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1184)

<a id="function-function-miniquake-quakec-builtins-allocateedict-function-allocateedict-machine-src-miniquake-quakec-builtins-ml-1002815905"></a>
### allocateEdict

```ml
function allocateEdict(machine)
```

Allocate and initialize edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `allocateEdict`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L501)

<a id="function-function-miniquake-quakec-builtins-ambientsoundbuiltin-function-ambientsoundbuiltin-machine-src-miniquake-quakec-builtins-ml-964037713"></a>
### ambientSoundBuiltin

```ml
function ambientSoundBuiltin(machine)
```

Implements the `ambientSoundBuiltin` operation for `miniquake.quakec.builtins` (ambient sound builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ambientSoundBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1489)

<a id="function-function-miniquake-quakec-builtins-appendconsole-function-appendconsole-text-src-miniquake-quakec-builtins-ml-4105499"></a>
### appendConsole

```ml
function appendConsole(text)
```

Add state for append console.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L546)

<a id="function-function-miniquake-quakec-builtins-badprecachestring-function-badprecachestring-name-src-miniquake-quakec-builtins-ml-1036903575"></a>
### badPrecacheString

```ml
function badPrecacheString(name)
```

Implements the `badPrecacheString` operation for `miniquake.quakec.builtins` (bad precache string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L539)

<a id="function-function-miniquake-quakec-builtins-bind-function-bind-contextvalue-src-miniquake-quakec-builtins-ml-164243042"></a>
### bind

```ml
function bind(contextValue)
```

Implements the `bind` operation for `miniquake.quakec.builtins` (bind).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `contextValue` | `dynamic` | — | The context value input consumed by `bind`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L45)

<a id="function-function-miniquake-quakec-builtins-breakbuiltin-function-breakbuiltin-machine-src-miniquake-quakec-builtins-ml-1073677709"></a>
### breakBuiltin

```ml
function breakBuiltin(machine)
```

Implements the `breakBuiltin` operation for `miniquake.quakec.builtins` (break builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `breakBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L602)

<a id="function-function-miniquake-quakec-builtins-broadcastprintbuiltin-function-broadcastprintbuiltin-machine-src-miniquake-quakec-builtins-ml-1458584879"></a>
### broadcastPrintBuiltin

```ml
function broadcastPrintBuiltin(machine)
```

Implements the `broadcastPrintBuiltin` operation for `miniquake.quakec.builtins` (broadcast print builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `broadcastPrintBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L896)

<a id="global-global-miniquake-quakec-builtins-brushboundsnames-brushboundsnames-src-miniquake-quakec-builtins-ml-882279258"></a>
### brushBoundsNames

```ml
brushBoundsNames
```

Tracks the module-level brush bounds names state owned by `miniquake.quakec.builtins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L39)

<a id="global-global-miniquake-quakec-builtins-brushboundsvalues-brushboundsvalues-src-miniquake-quakec-builtins-ml-1048690804"></a>
### brushBoundsValues

```ml
brushBoundsValues
```

Tracks the module-level brush bounds values state owned by `miniquake.quakec.builtins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L41)

<a id="function-function-miniquake-quakec-builtins-brushmodelbounds-function-brushmodelbounds-data-modelname-src-miniquake-quakec-builtins-ml-27710034"></a>
### brushModelBounds

```ml
function brushModelBounds(data, modelName)
```

External brush entities (ammo/health boxes, explosive barrels, etc.) are complete BSP29 files.  WinQuake's Mod_ForName loads their first dmodel and PF_setmodel copies its expanded mins/maxs into the edict.  Parsing only the model lump here keeps the server independent of renderer-owned model data and avoids loading all render/lightmap lumps during QuakeC spawning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `modelName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L422)

<a id="constant-constant-miniquake-quakec-builtins-builtin-count-const-builtin-count-79-src-miniquake-quakec-builtins-ml-1504501559"></a>
### BUILTIN_COUNT

```ml
const BUILTIN_COUNT = 79
```

Defines the builtin count value used by `miniquake.quakec.builtins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L30)

<a id="function-function-miniquake-quakec-builtins-builtincontractfingerprint-function-builtincontractfingerprint-src-miniquake-quakec-builtins-ml-356119222"></a>
### builtinContractFingerprint

```ml
function builtinContractFingerprint()
```

Implements the `builtinContractFingerprint` operation for `miniquake.quakec.builtins` (builtin contract fingerprint).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1546)

<a id="function-function-miniquake-quakec-builtins-builtinnames-function-builtinnames-src-miniquake-quakec-builtins-ml-578809946"></a>
### builtinNames

```ml
function builtinNames()
```

Return builtin names derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1525)

<a id="function-function-miniquake-quakec-builtins-cachedbrushmodelbounds-function-cachedbrushmodelbounds-ctx-modelname-src-miniquake-quakec-builtins-ml-191531135"></a>
### cachedBrushModelBounds

```ml
function cachedBrushModelBounds(ctx, modelName)
```

Implements the `cachedBrushModelBounds` operation for `miniquake.quakec.builtins` (cached brush model bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ctx` | `dynamic` | — | The ctx input consumed by `cachedBrushModelBounds`. |
| `modelName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L450)

<a id="function-function-miniquake-quakec-builtins-ceilbuiltin-function-ceilbuiltin-machine-src-miniquake-quakec-builtins-ml-740342445"></a>
### ceilBuiltin

```ml
function ceilBuiltin(machine)
```

Implements the `ceilBuiltin` operation for `miniquake.quakec.builtins` (ceil builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ceilBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1152)

<a id="function-function-miniquake-quakec-builtins-ceilnumber-function-ceilnumber-value-src-miniquake-quakec-builtins-ml-157189525"></a>
### ceilNumber

```ml
function ceilNumber(value)
```

Return ceil number derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ceilNumber`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L947)

<a id="function-function-miniquake-quakec-builtins-centerprintbuiltin-function-centerprintbuiltin-machine-src-miniquake-quakec-builtins-ml-103643937"></a>
### centerPrintBuiltin

```ml
function centerPrintBuiltin(machine)
```

Implements the `centerPrintBuiltin` operation for `miniquake.quakec.builtins` (center print builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `centerPrintBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1478)

<a id="function-function-miniquake-quakec-builtins-changelevelbuiltin-function-changelevelbuiltin-machine-src-miniquake-quakec-builtins-ml-900326469"></a>
### changeLevelBuiltin

```ml
function changeLevelBuiltin(machine)
```

Update subsystem configuration for change level builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `changeLevelBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1453)

<a id="function-function-miniquake-quakec-builtins-changeyawbuiltin-function-changeyawbuiltin-machine-src-miniquake-quakec-builtins-ml-553166253"></a>
### changeYawBuiltin

```ml
function changeYawBuiltin(machine)
```

Update subsystem configuration for change yaw builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `changeYawBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1282)

<a id="function-function-miniquake-quakec-builtins-checkbottombuiltin-function-checkbottombuiltin-machine-src-miniquake-quakec-builtins-ml-133968829"></a>
### checkBottomBuiltin

```ml
function checkBottomBuiltin(machine)
```

Validate bottom builtin and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `checkBottomBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1159)

<a id="function-function-miniquake-quakec-builtins-checkclientbuiltin-function-checkclientbuiltin-machine-src-miniquake-quakec-builtins-ml-177975213"></a>
### checkClientBuiltin

```ml
function checkClientBuiltin(machine)
```

Validate client builtin and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `checkClientBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L779)

<a id="function-function-miniquake-quakec-builtins-clientmessagebuffer-function-clientmessagebuffer-entityindex-src-miniquake-quakec-builtins-ml-1796559085"></a>
### clientMessageBuffer

```ml
function clientMessageBuffer(entityIndex)
```

Implements the `clientMessageBuffer` operation for `miniquake.quakec.builtins` (client message buffer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L852)

<a id="function-function-miniquake-quakec-builtins-clientprintbuiltin-function-clientprintbuiltin-machine-src-miniquake-quakec-builtins-ml-766673489"></a>
### clientPrintBuiltin

```ml
function clientPrintBuiltin(machine)
```

Implements the `clientPrintBuiltin` operation for `miniquake.quakec.builtins` (client print builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `clientPrintBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L921)

<a id="function-function-miniquake-quakec-builtins-context-function-context-src-miniquake-quakec-builtins-ml-1896538652"></a>
### context

```ml
function context()
```

Implements the `context` operation for `miniquake.quakec.builtins` (context).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L57)

<a id="function-function-miniquake-quakec-builtins-coredumpbuiltin-function-coredumpbuiltin-machine-src-miniquake-quakec-builtins-ml-722815125"></a>
### coreDumpBuiltin

```ml
function coreDumpBuiltin(machine)
```

Implements the `coreDumpBuiltin` operation for `miniquake.quakec.builtins` (core dump builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `coreDumpBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1014)

<a id="function-function-miniquake-quakec-builtins-cvarbuiltin-function-cvarbuiltin-machine-src-miniquake-quakec-builtins-ml-2042905299"></a>
### cvarBuiltin

```ml
function cvarBuiltin(machine)
```

Implements the `cvarBuiltin` operation for `miniquake.quakec.builtins` (cvar builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `cvarBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1242)

<a id="function-function-miniquake-quakec-builtins-cvarsetbuiltin-function-cvarsetbuiltin-machine-src-miniquake-quakec-builtins-ml-2102841137"></a>
### cvarSetBuiltin

```ml
function cvarSetBuiltin(machine)
```

Implements the `cvarSetBuiltin` operation for `miniquake.quakec.builtins` (cvar set builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `cvarSetBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1464)

<a id="function-function-miniquake-quakec-builtins-debugprintbuiltin-function-debugprintbuiltin-machine-src-miniquake-quakec-builtins-ml-1201459527"></a>
### debugPrintBuiltin

```ml
function debugPrintBuiltin(machine)
```

Implements the `debugPrintBuiltin` operation for `miniquake.quakec.builtins` (debug print builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `debugPrintBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L932)

<a id="function-function-miniquake-quakec-builtins-definitionoffset-function-definitionoffset-definitions-name-src-miniquake-quakec-builtins-ml-901576261"></a>
### definitionOffset

```ml
function definitionOffset(definitions, name)
```

Return definition offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definitions` | `dynamic` | — | The definitions input consumed by `definitionOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L225)

<a id="function-function-miniquake-quakec-builtins-destinationbuffer-function-destinationbuffer-machine-destination-src-miniquake-quakec-builtins-ml-312975973"></a>
### destinationBuffer

```ml
function destinationBuffer(machine, destination)
```

Implements the `destinationBuffer` operation for `miniquake.quakec.builtins` (destination buffer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `destinationBuffer`. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1325)

<a id="function-function-miniquake-quakec-builtins-droptofloorbuiltin-function-droptofloorbuiltin-machine-src-miniquake-quakec-builtins-ml-1539099925"></a>
### dropToFloorBuiltin

```ml
function dropToFloorBuiltin(machine)
```

Release state for drop to floor builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `dropToFloorBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1092)

<a id="function-function-miniquake-quakec-builtins-ensureglobal-function-ensureglobal-machine-offset-src-miniquake-quakec-builtins-ml-227888370"></a>
### ensureGlobal

```ml
function ensureGlobal(machine, offset)
```

Ensure sufficient storage or state for global.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ensureGlobal`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L65)

<a id="function-function-miniquake-quakec-builtins-entityfloat-function-entityfloat-machine-entityindex-name-src-miniquake-quakec-builtins-ml-1393053365"></a>
### entityFloat

```ml
function entityFloat(machine, entityIndex, name)
```

Implements the `entityFloat` operation for `miniquake.quakec.builtins` (entity float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityFloat`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L323)

<a id="function-function-miniquake-quakec-builtins-entityprintbuiltin-function-entityprintbuiltin-machine-src-miniquake-quakec-builtins-ml-411156517"></a>
### entityPrintBuiltin

```ml
function entityPrintBuiltin(machine)
```

Implements the `entityPrintBuiltin` operation for `miniquake.quakec.builtins` (entity print builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityPrintBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1035)

<a id="function-function-miniquake-quakec-builtins-entitystring-function-entitystring-machine-entityindex-name-src-miniquake-quakec-builtins-ml-1542339475"></a>
### entityString

```ml
function entityString(machine, entityIndex, name)
```

Implements the `entityString` operation for `miniquake.quakec.builtins` (entity string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityString`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L364)

<a id="function-function-miniquake-quakec-builtins-entityvector-function-entityvector-machine-entityindex-name-src-miniquake-quakec-builtins-ml-1338198035"></a>
### entityVector

```ml
function entityVector(machine, entityIndex, name)
```

Implements the `entityVector` operation for `miniquake.quakec.builtins` (entity vector).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L340)

<a id="function-function-miniquake-quakec-builtins-entityword-function-entityword-machine-entityindex-name-src-miniquake-quakec-builtins-ml-1617418151"></a>
### entityWord

```ml
function entityWord(machine, entityIndex, name)
```

Implements the `entityWord` operation for `miniquake.quakec.builtins` (entity word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityWord`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L301)

<a id="function-function-miniquake-quakec-builtins-errorbuiltin-function-errorbuiltin-machine-src-miniquake-quakec-builtins-ml-1061276033"></a>
### errorBuiltin

```ml
function errorBuiltin(machine)
```

Report builtin and return the corresponding failure status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `errorBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L652)

<a id="function-function-miniquake-quakec-builtins-fieldoffset-function-fieldoffset-machine-name-src-miniquake-quakec-builtins-ml-473617788"></a>
### fieldOffset

```ml
function fieldOffset(machine, name)
```

Implements the `fieldOffset` operation for `miniquake.quakec.builtins` (field offset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `fieldOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L242)

<a id="function-function-miniquake-quakec-builtins-findbuiltin-function-findbuiltin-machine-src-miniquake-quakec-builtins-ml-559308285"></a>
### findBuiltin

```ml
function findBuiltin(machine)
```

Return builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `findBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L802)

<a id="function-function-miniquake-quakec-builtins-findradiusbuiltin-function-findradiusbuiltin-machine-src-miniquake-quakec-builtins-ml-796635837"></a>
### findRadiusBuiltin

```ml
function findRadiusBuiltin(machine)
```

Return radius builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `findRadiusBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L871)

<a id="function-function-miniquake-quakec-builtins-fixedonedecimal-function-fixedonedecimal-value-src-miniquake-quakec-builtins-ml-1090416187"></a>
### fixedOneDecimal

```ml
function fixedOneDecimal(value)
```

Implements the `fixedOneDecimal` operation for `miniquake.quakec.builtins` (fixed one decimal).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fixedOneDecimal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L975)

<a id="function-function-miniquake-quakec-builtins-fixme-function-fixme-machine-src-miniquake-quakec-builtins-ml-249483907"></a>
### fixme

```ml
function fixme(machine)
```

Implements the `fixme` operation for `miniquake.quakec.builtins` (fixme).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `fixme`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L553)

<a id="function-function-miniquake-quakec-builtins-fixmeslots-function-fixmeslots-src-miniquake-quakec-builtins-ml-2124992806"></a>
### fixmeSlots

```ml
function fixmeSlots()
```

Implements the `fixmeSlots` operation for `miniquake.quakec.builtins` (fixme slots).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1541)

<a id="function-function-miniquake-quakec-builtins-floattostringbuiltin-function-floattostringbuiltin-machine-src-miniquake-quakec-builtins-ml-536982957"></a>
### floatToStringBuiltin

```ml
function floatToStringBuiltin(machine)
```

Implements the `floatToStringBuiltin` operation for `miniquake.quakec.builtins` (float to string builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `floatToStringBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L955)

<a id="function-function-miniquake-quakec-builtins-floatvalue-function-floatvalue-machine-offset-src-miniquake-quakec-builtins-ml-285565194"></a>
### floatValue

```ml
function floatValue(machine, offset)
```

Return float value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `floatValue`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L90)

<a id="function-function-miniquake-quakec-builtins-floorbuiltin-function-floorbuiltin-machine-src-miniquake-quakec-builtins-ml-1666336053"></a>
### floorBuiltin

```ml
function floorBuiltin(machine)
```

Implements the `floorBuiltin` operation for `miniquake.quakec.builtins` (floor builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `floorBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1145)

<a id="function-function-miniquake-quakec-builtins-floornumber-function-floornumber-value-src-miniquake-quakec-builtins-ml-7900539"></a>
### floorNumber

```ml
function floorNumber(value)
```

Return floor number derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floorNumber`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L939)

<a id="constant-constant-miniquake-quakec-builtins-fnv-offset-const-fnv-offset-2166136261-src-miniquake-quakec-builtins-ml-1263540969"></a>
### FNV_OFFSET

```ml
const FNV_OFFSET = 2166136261
```

Defines the fnv offset value used by `miniquake.quakec.builtins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L32)

<a id="constant-constant-miniquake-quakec-builtins-fnv-prime-const-fnv-prime-16777619-src-miniquake-quakec-builtins-ml-966805825"></a>
### FNV_PRIME

```ml
const FNV_PRIME = 16777619
```

Defines the fnv prime value used by `miniquake.quakec.builtins`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L34)

<a id="function-function-miniquake-quakec-builtins-globaloffset-function-globaloffset-machine-name-src-miniquake-quakec-builtins-ml-1706068130"></a>
### globalOffset

```ml
function globalOffset(machine, name)
```

Return global offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L235)

<a id="function-function-miniquake-quakec-builtins-globalvector-function-globalvector-machine-name-src-miniquake-quakec-builtins-ml-292494418"></a>
### globalVector

```ml
function globalVector(machine, name)
```

Return global vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalVector`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L258)

<a id="function-function-miniquake-quakec-builtins-globalword-function-globalword-machine-name-src-miniquake-quakec-builtins-ml-1814378982"></a>
### globalWord

```ml
function globalWord(machine, name)
```

Implements the `globalWord` operation for `miniquake.quakec.builtins` (global word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalWord`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L249)

<a id="function-function-miniquake-quakec-builtins-install-function-install-machine-contextvalue-src-miniquake-quakec-builtins-ml-1029366123"></a>
### install

```ml
function install(machine, contextValue)
```

Implements the `install` operation for `miniquake.quakec.builtins` (install).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `install`. |
| `contextValue` | `dynamic` | — | The context value input consumed by `install`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1567)

<a id="function-function-miniquake-quakec-builtins-internstring-function-internstring-machine-text-src-miniquake-quakec-builtins-ml-1958824602"></a>
### internString

```ml
function internString(machine, text)
```

Implements the `internString` operation for `miniquake.quakec.builtins` (intern string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `internString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L179)

<a id="function-function-miniquake-quakec-builtins-lightstylebuiltin-function-lightstylebuiltin-machine-src-miniquake-quakec-builtins-ml-1074898845"></a>
### lightStyleBuiltin

```ml
function lightStyleBuiltin(machine)
```

Implements the `lightStyleBuiltin` operation for `miniquake.quakec.builtins` (light style builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `lightStyleBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1110)

<a id="function-function-miniquake-quakec-builtins-localcommandbuiltin-function-localcommandbuiltin-machine-src-miniquake-quakec-builtins-ml-955439515"></a>
### localCommandBuiltin

```ml
function localCommandBuiltin(machine)
```

Implements the `localCommandBuiltin` operation for `miniquake.quakec.builtins` (local command builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `localCommandBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1249)

<a id="function-function-miniquake-quakec-builtins-makestaticbuiltin-function-makestaticbuiltin-machine-src-miniquake-quakec-builtins-ml-1372353999"></a>
### makeStaticBuiltin

```ml
function makeStaticBuiltin(machine)
```

Create and initialize static builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `makeStaticBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1443)

<a id="function-function-miniquake-quakec-builtins-makevectors-function-makevectors-machine-src-miniquake-quakec-builtins-ml-961815349"></a>
### makeVectors

```ml
function makeVectors(machine)
```

Create and initialize vectors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `makeVectors`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L559)

<a id="function-function-miniquake-quakec-builtins-modelbounds-function-modelbounds-machine-modelname-src-miniquake-quakec-builtins-ml-297768055"></a>
### modelBounds

```ml
function modelBounds(machine, modelName)
```

Implements the `modelBounds` operation for `miniquake.quakec.builtins` (model bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `modelBounds`. |
| `modelName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L468)

<a id="function-function-miniquake-quakec-builtins-movetogoalbuiltin-function-movetogoalbuiltin-machine-src-miniquake-quakec-builtins-ml-2029257969"></a>
### moveToGoalBuiltin

```ml
function moveToGoalBuiltin(machine)
```

Transfer data for move to goal builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `moveToGoalBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1397)

<a id="function-function-miniquake-quakec-builtins-newcheckclient-function-newcheckclient-machine-current-src-miniquake-quakec-builtins-ml-448869412"></a>
### newCheckClient

```ml
function newCheckClient(machine, current)
```

Create and initialize check client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `newCheckClient`. |
| `current` | `dynamic` | — | The current input consumed by `newCheckClient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L747)

<a id="function-function-miniquake-quakec-builtins-nextentitybuiltin-function-nextentitybuiltin-machine-src-miniquake-quakec-builtins-ml-697218171"></a>
### nextEntityBuiltin

```ml
function nextEntityBuiltin(machine)
```

Return next entity builtin for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `nextEntityBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1256)

<a id="function-function-miniquake-quakec-builtins-normalizebuiltin-function-normalizebuiltin-machine-src-miniquake-quakec-builtins-ml-1698348893"></a>
### normalizeBuiltin

```ml
function normalizeBuiltin(machine)
```

Convert builtin into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `normalizeBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L645)

<a id="function-function-miniquake-quakec-builtins-objecterrorbuiltin-function-objecterrorbuiltin-machine-src-miniquake-quakec-builtins-ml-2019292605"></a>
### objectErrorBuiltin

```ml
function objectErrorBuiltin(machine)
```

Implements the `objectErrorBuiltin` operation for `miniquake.quakec.builtins` (object error builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `objectErrorBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L661)

<a id="function-function-miniquake-quakec-builtins-parameteroffset-inline-function-parameteroffset-index-src-miniquake-quakec-builtins-ml-19934365"></a>
### parameterOffset

```ml
inline function parameterOffset(index)
```

Return parameter offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L124)

<a id="function-function-miniquake-quakec-builtins-parmfloat-function-parmfloat-machine-index-src-miniquake-quakec-builtins-ml-677994901"></a>
### parmFloat

```ml
function parmFloat(machine, index)
```

Implements the `parmFloat` operation for `miniquake.quakec.builtins` (parm float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `parmFloat`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L138)

<a id="function-function-miniquake-quakec-builtins-parmstring-function-parmstring-machine-index-src-miniquake-quakec-builtins-ml-1226829121"></a>
### parmString

```ml
function parmString(machine, index)
```

Implements the `parmString` operation for `miniquake.quakec.builtins` (parm string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `parmString`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L159)

<a id="function-function-miniquake-quakec-builtins-parmvector-function-parmvector-machine-index-src-miniquake-quakec-builtins-ml-610891421"></a>
### parmVector

```ml
function parmVector(machine, index)
```

Return parm vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `parmVector`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L145)

<a id="function-function-miniquake-quakec-builtins-parmword-function-parmword-machine-index-src-miniquake-quakec-builtins-ml-647267045"></a>
### parmWord

```ml
function parmWord(machine, index)
```

Implements the `parmWord` operation for `miniquake.quakec.builtins` (parm word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `parmWord`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L131)

<a id="function-function-miniquake-quakec-builtins-particlebuiltin-function-particlebuiltin-machine-src-miniquake-quakec-builtins-ml-1190160299"></a>
### particleBuiltin

```ml
function particleBuiltin(machine)
```

Implements the `particleBuiltin` operation for `miniquake.quakec.builtins` (particle builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `particleBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1269)

<a id="function-function-miniquake-quakec-builtins-pf-aim-function-pf-aim-machine-src-miniquake-quakec-builtins-ml-1703512601"></a>
### PF_aim

```ml
function PF_aim(machine)
```

Mirror Quake's PF_aim routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_aim`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1999)

<a id="function-function-miniquake-quakec-builtins-pf-ambientsound-function-pf-ambientsound-machine-src-miniquake-quakec-builtins-ml-437656589"></a>
### PF_ambientsound

```ml
function PF_ambientsound(machine)
```

Mirror Quake's PF_ambientsound routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_ambientsound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1767)

<a id="function-function-miniquake-quakec-builtins-pf-bprint-function-pf-bprint-machine-src-miniquake-quakec-builtins-ml-1588593345"></a>
### PF_bprint

```ml
function PF_bprint(machine)
```

Mirror Quake's PF_bprint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_bprint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1713)

<a id="function-function-miniquake-quakec-builtins-pf-break-function-pf-break-machine-src-miniquake-quakec-builtins-ml-869906013"></a>
### PF_break

```ml
function PF_break(machine)
```

Mirror Quake's PF_break routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_break`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1779)

<a id="function-function-miniquake-quakec-builtins-pf-ceil-function-pf-ceil-machine-src-miniquake-quakec-builtins-ml-1194455057"></a>
### PF_ceil

```ml
function PF_ceil(machine)
```

Mirror Quake's PF_ceil routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_ceil`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1975)

<a id="function-function-miniquake-quakec-builtins-pf-centerprint-function-pf-centerprint-machine-src-miniquake-quakec-builtins-ml-423297917"></a>
### PF_centerprint

```ml
function PF_centerprint(machine)
```

Mirror Quake's PF_centerprint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_centerprint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1725)

<a id="function-function-miniquake-quakec-builtins-pf-changelevel-function-pf-changelevel-machine-src-miniquake-quakec-builtins-ml-1374912657"></a>
### PF_changelevel

```ml
function PF_changelevel(machine)
```

Mirror Quake's PF_changelevel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_changelevel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2083)

<a id="function-function-miniquake-quakec-builtins-pf-changepitch-function-pf-changepitch-machine-src-miniquake-quakec-builtins-ml-1007952085"></a>
### PF_changepitch

```ml
function PF_changepitch(machine)
```

Mirror Quake's PF_changepitch routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_changepitch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2011)

<a id="function-function-miniquake-quakec-builtins-pf-changeyaw-function-pf-changeyaw-machine-src-miniquake-quakec-builtins-ml-336241597"></a>
### PF_changeyaw

```ml
function PF_changeyaw(machine)
```

Mirror Quake's PF_changeyaw routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_changeyaw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2005)

<a id="function-function-miniquake-quakec-builtins-pf-checkbottom-function-pf-checkbottom-machine-src-miniquake-quakec-builtins-ml-177042621"></a>
### PF_checkbottom

```ml
function PF_checkbottom(machine)
```

Mirror Quake's PF_checkbottom routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_checkbottom`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1981)

<a id="function-function-miniquake-quakec-builtins-pf-checkclient-function-pf-checkclient-machine-src-miniquake-quakec-builtins-ml-1006735757"></a>
### PF_checkclient

```ml
function PF_checkclient(machine)
```

Mirror Quake's PF_checkclient routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_checkclient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1812)

<a id="function-function-miniquake-quakec-builtins-pf-checkpos-function-pf-checkpos-machine-src-miniquake-quakec-builtins-ml-882359491"></a>
### PF_checkpos

```ml
function PF_checkpos(machine)
```

Mirror Quake's PF_checkpos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_checkpos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1797)

<a id="function-function-miniquake-quakec-builtins-pf-coredump-function-pf-coredump-machine-src-miniquake-quakec-builtins-ml-1804667401"></a>
### PF_coredump

```ml
function PF_coredump(machine)
```

Mirror Quake's PF_coredump routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_coredump`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1921)

<a id="function-function-miniquake-quakec-builtins-pf-cos-function-pf-cos-machine-src-miniquake-quakec-builtins-ml-1544921789"></a>
### PF_cos

```ml
function PF_cos(machine)
```

Mirror Quake's PF_cos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_cos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2101)

<a id="function-function-miniquake-quakec-builtins-pf-cvar-function-pf-cvar-machine-src-miniquake-quakec-builtins-ml-943145155"></a>
### PF_cvar

```ml
function PF_cvar(machine)
```

Mirror Quake's PF_cvar routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_cvar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1830)

<a id="function-function-miniquake-quakec-builtins-pf-cvar-set-function-pf-cvar-set-machine-src-miniquake-quakec-builtins-ml-1079895953"></a>
### PF_cvar_set

```ml
function PF_cvar_set(machine)
```

Mirror Quake's PF_cvar_set routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_cvar_set`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1836)

<a id="function-function-miniquake-quakec-builtins-pf-dprint-function-pf-dprint-machine-src-miniquake-quakec-builtins-ml-239898365"></a>
### PF_dprint

```ml
function PF_dprint(machine)
```

Mirror Quake's PF_dprint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_dprint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1848)

<a id="function-function-miniquake-quakec-builtins-pf-droptofloor-function-pf-droptofloor-machine-src-miniquake-quakec-builtins-ml-813616441"></a>
### PF_droptofloor

```ml
function PF_droptofloor(machine)
```

Mirror Quake's PF_droptofloor routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_droptofloor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1951)

<a id="function-function-miniquake-quakec-builtins-pf-eprint-function-pf-eprint-machine-src-miniquake-quakec-builtins-ml-798180043"></a>
### PF_eprint

```ml
function PF_eprint(machine)
```

Mirror Quake's PF_eprint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_eprint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1939)

<a id="function-function-miniquake-quakec-builtins-pf-error-function-pf-error-machine-src-miniquake-quakec-builtins-ml-366052229"></a>
### PF_error

```ml
function PF_error(machine)
```

Mirror Quake's PF_error routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_error`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1667)

<a id="function-function-miniquake-quakec-builtins-pf-etos-function-pf-etos-machine-src-miniquake-quakec-builtins-ml-737840301"></a>
### PF_etos

```ml
function PF_etos(machine)
```

Mirror Quake's PF_etos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_etos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1872)

<a id="function-function-miniquake-quakec-builtins-pf-fabs-function-pf-fabs-machine-src-miniquake-quakec-builtins-ml-332247983"></a>
### PF_fabs

```ml
function PF_fabs(machine)
```

Mirror Quake's PF_fabs routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_fabs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1860)

<a id="function-function-miniquake-quakec-builtins-pf-find-function-pf-find-machine-src-miniquake-quakec-builtins-ml-1804215485"></a>
### PF_Find

```ml
function PF_Find(machine)
```

Mirror Quake's PF_Find routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_Find`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1890)

<a id="function-function-miniquake-quakec-builtins-pf-findradius-function-pf-findradius-machine-src-miniquake-quakec-builtins-ml-998326125"></a>
### PF_findradius

```ml
function PF_findradius(machine)
```

Mirror Quake's PF_findradius routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_findradius`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1842)

<a id="function-function-miniquake-quakec-builtins-pf-fixme-function-pf-fixme-machine-src-miniquake-quakec-builtins-ml-244153333"></a>
### PF_Fixme

```ml
function PF_Fixme(machine)
```

Mirror Quake's PF_Fixme routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_Fixme`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2113)

<a id="function-function-miniquake-quakec-builtins-pf-floor-function-pf-floor-machine-src-miniquake-quakec-builtins-ml-280838001"></a>
### PF_floor

```ml
function PF_floor(machine)
```

Mirror Quake's PF_floor routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_floor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1969)

<a id="function-function-miniquake-quakec-builtins-pf-ftos-function-pf-ftos-machine-src-miniquake-quakec-builtins-ml-908742727"></a>
### PF_ftos

```ml
function PF_ftos(machine)
```

Mirror Quake's PF_ftos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_ftos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1854)

<a id="function-function-miniquake-quakec-builtins-pf-lightstyle-function-pf-lightstyle-machine-src-miniquake-quakec-builtins-ml-1289359317"></a>
### PF_lightstyle

```ml
function PF_lightstyle(machine)
```

Mirror Quake's PF_lightstyle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_lightstyle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1957)

<a id="function-function-miniquake-quakec-builtins-pf-localcmd-function-pf-localcmd-machine-src-miniquake-quakec-builtins-ml-555628929"></a>
### PF_localcmd

```ml
function PF_localcmd(machine)
```

Mirror Quake's PF_localcmd routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_localcmd`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1824)

<a id="function-function-miniquake-quakec-builtins-pf-makestatic-function-pf-makestatic-machine-src-miniquake-quakec-builtins-ml-2092468799"></a>
### PF_makestatic

```ml
function PF_makestatic(machine)
```

Mirror Quake's PF_makestatic routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_makestatic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2071)

<a id="function-function-miniquake-quakec-builtins-pf-makevectors-function-pf-makevectors-machine-src-miniquake-quakec-builtins-ml-191321369"></a>
### PF_makevectors

```ml
function PF_makevectors(machine)
```

Mirror Quake's PF_makevectors routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_makevectors`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1679)

<a id="function-function-miniquake-quakec-builtins-pf-newcheckclient-function-pf-newcheckclient-machine-check-src-miniquake-quakec-builtins-ml-2107599557"></a>
### PF_newcheckclient

```ml
function PF_newcheckclient(machine, check)
```

Mirror Quake's PF_newcheckclient routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_newcheckclient`. |
| `check` | `dynamic` | — | The check input consumed by `PF_newcheckclient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1806)

<a id="function-function-miniquake-quakec-builtins-pf-nextent-function-pf-nextent-machine-src-miniquake-quakec-builtins-ml-812093337"></a>
### PF_nextent

```ml
function PF_nextent(machine)
```

Mirror Quake's PF_nextent routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_nextent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1993)

<a id="function-function-miniquake-quakec-builtins-pf-normalize-function-pf-normalize-machine-src-miniquake-quakec-builtins-ml-534364749"></a>
### PF_normalize

```ml
function PF_normalize(machine)
```

Mirror Quake's PF_normalize routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_normalize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1731)

<a id="function-function-miniquake-quakec-builtins-pf-objerror-function-pf-objerror-machine-src-miniquake-quakec-builtins-ml-123979257"></a>
### PF_objerror

```ml
function PF_objerror(machine)
```

Mirror Quake's PF_objerror routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_objerror`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1673)

<a id="function-function-miniquake-quakec-builtins-pf-particle-function-pf-particle-machine-src-miniquake-quakec-builtins-ml-1803190015"></a>
### PF_particle

```ml
function PF_particle(machine)
```

Mirror Quake's PF_particle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_particle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1761)

<a id="function-function-miniquake-quakec-builtins-pf-pointcontents-function-pf-pointcontents-machine-src-miniquake-quakec-builtins-ml-2094382489"></a>
### PF_pointcontents

```ml
function PF_pointcontents(machine)
```

Mirror Quake's PF_pointcontents routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_pointcontents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1987)

<a id="function-function-miniquake-quakec-builtins-pf-precache-file-function-pf-precache-file-machine-src-miniquake-quakec-builtins-ml-513721049"></a>
### PF_precache_file

```ml
function PF_precache_file(machine)
```

Mirror Quake's PF_precache_file routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_precache_file`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1903)

<a id="function-function-miniquake-quakec-builtins-pf-precache-model-function-pf-precache-model-machine-src-miniquake-quakec-builtins-ml-635212557"></a>
### PF_precache_model

```ml
function PF_precache_model(machine)
```

Mirror Quake's PF_precache_model routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_precache_model`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1915)

<a id="function-function-miniquake-quakec-builtins-pf-precache-sound-function-pf-precache-sound-machine-src-miniquake-quakec-builtins-ml-960794721"></a>
### PF_precache_sound

```ml
function PF_precache_sound(machine)
```

Mirror Quake's PF_precache_sound routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_precache_sound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1909)

<a id="function-function-miniquake-quakec-builtins-pf-random-function-pf-random-machine-src-miniquake-quakec-builtins-ml-1237667277"></a>
### PF_random

```ml
function PF_random(machine)
```

Mirror Quake's PF_random routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_random`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1755)

<a id="function-function-miniquake-quakec-builtins-pf-remove-function-pf-remove-machine-src-miniquake-quakec-builtins-ml-901964783"></a>
### PF_Remove

```ml
function PF_Remove(machine)
```

Mirror Quake's PF_Remove routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_Remove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1884)

<a id="function-function-miniquake-quakec-builtins-pf-rint-function-pf-rint-machine-src-miniquake-quakec-builtins-ml-589463581"></a>
### PF_rint

```ml
function PF_rint(machine)
```

Mirror Quake's PF_rint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_rint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1963)

<a id="function-function-miniquake-quakec-builtins-pf-setmodel-function-pf-setmodel-machine-src-miniquake-quakec-builtins-ml-1073574301"></a>
### PF_setmodel

```ml
function PF_setmodel(machine)
```

Mirror Quake's PF_setmodel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_setmodel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1707)

<a id="function-function-miniquake-quakec-builtins-pf-setorigin-function-pf-setorigin-machine-src-miniquake-quakec-builtins-ml-1499074553"></a>
### PF_setorigin

```ml
function PF_setorigin(machine)
```

Mirror Quake's PF_setorigin routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_setorigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1685)

<a id="function-function-miniquake-quakec-builtins-pf-setsize-function-pf-setsize-machine-src-miniquake-quakec-builtins-ml-1024122749"></a>
### PF_setsize

```ml
function PF_setsize(machine)
```

Mirror Quake's PF_setsize routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_setsize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1701)

<a id="function-function-miniquake-quakec-builtins-pf-setspawnparms-function-pf-setspawnparms-machine-src-miniquake-quakec-builtins-ml-2055474221"></a>
### PF_setspawnparms

```ml
function PF_setspawnparms(machine)
```

Mirror Quake's PF_setspawnparms routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_setspawnparms`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2077)

<a id="function-function-miniquake-quakec-builtins-pf-sin-function-pf-sin-machine-src-miniquake-quakec-builtins-ml-939679221"></a>
### PF_sin

```ml
function PF_sin(machine)
```

Mirror Quake's PF_sin routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_sin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2095)

<a id="function-function-miniquake-quakec-builtins-pf-sound-function-pf-sound-machine-src-miniquake-quakec-builtins-ml-1463607797"></a>
### PF_sound

```ml
function PF_sound(machine)
```

Mirror Quake's PF_sound routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_sound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1773)

<a id="function-function-miniquake-quakec-builtins-pf-spawn-function-pf-spawn-machine-src-miniquake-quakec-builtins-ml-979592245"></a>
### PF_Spawn

```ml
function PF_Spawn(machine)
```

Mirror Quake's PF_Spawn routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_Spawn`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1878)

<a id="function-function-miniquake-quakec-builtins-pf-sprint-function-pf-sprint-machine-src-miniquake-quakec-builtins-ml-253920299"></a>
### PF_sprint

```ml
function PF_sprint(machine)
```

Mirror Quake's PF_sprint routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_sprint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1719)

<a id="function-function-miniquake-quakec-builtins-pf-sqrt-function-pf-sqrt-machine-src-miniquake-quakec-builtins-ml-1223249043"></a>
### PF_sqrt

```ml
function PF_sqrt(machine)
```

Mirror Quake's PF_sqrt routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_sqrt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2107)

<a id="function-function-miniquake-quakec-builtins-pf-stuffcmd-function-pf-stuffcmd-machine-src-miniquake-quakec-builtins-ml-2046465099"></a>
### PF_stuffcmd

```ml
function PF_stuffcmd(machine)
```

Mirror Quake's PF_stuffcmd routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_stuffcmd`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1818)

<a id="function-function-miniquake-quakec-builtins-pf-traceline-function-pf-traceline-machine-src-miniquake-quakec-builtins-ml-1220516669"></a>
### PF_traceline

```ml
function PF_traceline(machine)
```

Mirror Quake's PF_traceline routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_traceline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1785)

<a id="function-function-miniquake-quakec-builtins-pf-traceoff-function-pf-traceoff-machine-src-miniquake-quakec-builtins-ml-81963003"></a>
### PF_traceoff

```ml
function PF_traceoff(machine)
```

Mirror Quake's PF_traceoff routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_traceoff`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1933)

<a id="function-function-miniquake-quakec-builtins-pf-traceon-function-pf-traceon-machine-src-miniquake-quakec-builtins-ml-1840723337"></a>
### PF_traceon

```ml
function PF_traceon(machine)
```

Mirror Quake's PF_traceon routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_traceon`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1927)

<a id="function-function-miniquake-quakec-builtins-pf-tracetoss-function-pf-tracetoss-machine-src-miniquake-quakec-builtins-ml-2114633457"></a>
### PF_TraceToss

```ml
function PF_TraceToss(machine)
```

Mirror Quake's PF_TraceToss routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_TraceToss`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1791)

<a id="function-function-miniquake-quakec-builtins-pf-varstring-function-pf-varstring-machine-first-src-miniquake-quakec-builtins-ml-116215463"></a>
### PF_VarString

```ml
function PF_VarString(machine, first)
```

MiniQuake pr_cmds.c entry points.  These names intentionally mirror the C source so every target function has a concrete, searchable MiniLang pendant.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_VarString`. |
| `first` | `dynamic` | — | The first input consumed by `PF_VarString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1661)

<a id="function-function-miniquake-quakec-builtins-pf-vectoangles-function-pf-vectoangles-machine-src-miniquake-quakec-builtins-ml-244002021"></a>
### PF_vectoangles

```ml
function PF_vectoangles(machine)
```

Mirror Quake's PF_vectoangles routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_vectoangles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1749)

<a id="function-function-miniquake-quakec-builtins-pf-vectoyaw-function-pf-vectoyaw-machine-src-miniquake-quakec-builtins-ml-1261387423"></a>
### PF_vectoyaw

```ml
function PF_vectoyaw(machine)
```

Mirror Quake's PF_vectoyaw routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_vectoyaw`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1743)

<a id="function-function-miniquake-quakec-builtins-pf-vlen-function-pf-vlen-machine-src-miniquake-quakec-builtins-ml-1427223453"></a>
### PF_vlen

```ml
function PF_vlen(machine)
```

Mirror Quake's PF_vlen routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_vlen`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1737)

<a id="function-function-miniquake-quakec-builtins-pf-vtos-function-pf-vtos-machine-src-miniquake-quakec-builtins-ml-1930718023"></a>
### PF_vtos

```ml
function PF_vtos(machine)
```

Mirror Quake's PF_vtos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_vtos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1866)

<a id="function-function-miniquake-quakec-builtins-pf-walkmove-function-pf-walkmove-machine-src-miniquake-quakec-builtins-ml-533636287"></a>
### PF_walkmove

```ml
function PF_walkmove(machine)
```

Mirror Quake's PF_walkmove routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_walkmove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1945)

<a id="function-function-miniquake-quakec-builtins-pf-watermove-function-pf-watermove-machine-src-miniquake-quakec-builtins-ml-1675438641"></a>
### PF_WaterMove

```ml
function PF_WaterMove(machine)
```

Mirror Quake's PF_WaterMove routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WaterMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2089)

<a id="function-function-miniquake-quakec-builtins-pf-writeangle-function-pf-writeangle-machine-src-miniquake-quakec-builtins-ml-420627235"></a>
### PF_WriteAngle

```ml
function PF_WriteAngle(machine)
```

Mirror Quake's PF_WriteAngle routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteAngle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2047)

<a id="function-function-miniquake-quakec-builtins-pf-writebyte-function-pf-writebyte-machine-src-miniquake-quakec-builtins-ml-1907753981"></a>
### PF_WriteByte

```ml
function PF_WriteByte(machine)
```

Mirror Quake's PF_WriteByte routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2023)

<a id="function-function-miniquake-quakec-builtins-pf-writechar-function-pf-writechar-machine-src-miniquake-quakec-builtins-ml-685893421"></a>
### PF_WriteChar

```ml
function PF_WriteChar(machine)
```

Mirror Quake's PF_WriteChar routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2029)

<a id="function-function-miniquake-quakec-builtins-pf-writecoord-function-pf-writecoord-machine-src-miniquake-quakec-builtins-ml-923043779"></a>
### PF_WriteCoord

```ml
function PF_WriteCoord(machine)
```

Mirror Quake's PF_WriteCoord routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteCoord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2053)

<a id="function-function-miniquake-quakec-builtins-pf-writeentity-function-pf-writeentity-machine-src-miniquake-quakec-builtins-ml-2064664573"></a>
### PF_WriteEntity

```ml
function PF_WriteEntity(machine)
```

Mirror Quake's PF_WriteEntity routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2065)

<a id="function-function-miniquake-quakec-builtins-pf-writelong-function-pf-writelong-machine-src-miniquake-quakec-builtins-ml-790791285"></a>
### PF_WriteLong

```ml
function PF_WriteLong(machine)
```

Mirror Quake's PF_WriteLong routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2041)

<a id="function-function-miniquake-quakec-builtins-pf-writeshort-function-pf-writeshort-machine-src-miniquake-quakec-builtins-ml-2071230325"></a>
### PF_WriteShort

```ml
function PF_WriteShort(machine)
```

Mirror Quake's PF_WriteShort routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2035)

<a id="function-function-miniquake-quakec-builtins-pf-writestring-function-pf-writestring-machine-src-miniquake-quakec-builtins-ml-1557810181"></a>
### PF_WriteString

```ml
function PF_WriteString(machine)
```

Mirror Quake's PF_WriteString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PF_WriteString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2059)

<a id="function-function-miniquake-quakec-builtins-pointcontentsbuiltin-function-pointcontentsbuiltin-machine-src-miniquake-quakec-builtins-ml-599381709"></a>
### pointContentsBuiltin

```ml
function pointContentsBuiltin(machine)
```

Implements the `pointContentsBuiltin` operation for `miniquake.quakec.builtins` (point contents builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `pointContentsBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1168)

<a id="function-function-miniquake-quakec-builtins-pr-checkemptystring-function-pr-checkemptystring-value-src-miniquake-quakec-builtins-ml-602913211"></a>
### PR_CheckEmptyString

```ml
function PR_CheckEmptyString(value)
```

Mirror Quake's PR_CheckEmptyString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `PR_CheckEmptyString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1896)

<a id="function-function-miniquake-quakec-builtins-precachefilebuiltin-function-precachefilebuiltin-machine-src-miniquake-quakec-builtins-ml-1147696789"></a>
### precacheFileBuiltin

```ml
function precacheFileBuiltin(machine)
```

Preload and register the file builtin asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `precacheFileBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1414)

<a id="function-function-miniquake-quakec-builtins-precacheindex-function-precacheindex-values-name-src-miniquake-quakec-builtins-ml-1652525349"></a>
### precacheIndex

```ml
function precacheIndex(values, name)
```

Preload and register the index asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `precacheIndex`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L520)

<a id="function-function-miniquake-quakec-builtins-precachemodelbuiltin-function-precachemodelbuiltin-machine-src-miniquake-quakec-builtins-ml-171367865"></a>
### precacheModelBuiltin

```ml
function precacheModelBuiltin(machine)
```

Preload and register the model builtin asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `precacheModelBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L837)

<a id="function-function-miniquake-quakec-builtins-precachesoundbuiltin-function-precachesoundbuiltin-machine-src-miniquake-quakec-builtins-ml-444002101"></a>
### precacheSoundBuiltin

```ml
function precacheSoundBuiltin(machine)
```

Preload and register the sound builtin asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `precacheSoundBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L822)

<a id="function-function-miniquake-quakec-builtins-randombuiltin-function-randombuiltin-machine-src-miniquake-quakec-builtins-ml-1419882617"></a>
### randomBuiltin

```ml
function randomBuiltin(machine)
```

Implements the `randomBuiltin` operation for `miniquake.quakec.builtins` (random builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `randomBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L612)

<a id="function-function-miniquake-quakec-builtins-releaseedict-function-releaseedict-machine-entityindex-src-miniquake-quakec-builtins-ml-132386076"></a>
### releaseEdict

```ml
function releaseEdict(machine, entityIndex)
```

Release or remove state for edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `releaseEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L513)

<a id="function-function-miniquake-quakec-builtins-removebuiltin-function-removebuiltin-machine-src-miniquake-quakec-builtins-ml-1359459095"></a>
### removeBuiltin

```ml
function removeBuiltin(machine)
```

Release state for remove builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `removeBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L700)

<a id="function-function-miniquake-quakec-builtins-returnfloat-function-returnfloat-machine-value-src-miniquake-quakec-builtins-ml-225006384"></a>
### returnFloat

```ml
function returnFloat(machine, value)
```

Implements the `returnFloat` operation for `miniquake.quakec.builtins` (return float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `returnFloat`. |
| `value` | `dynamic` | — | Value consumed by `returnFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L195)

<a id="function-function-miniquake-quakec-builtins-returnstring-function-returnstring-machine-text-src-miniquake-quakec-builtins-ml-48014890"></a>
### returnString

```ml
function returnString(machine, text)
```

Implements the `returnString` operation for `miniquake.quakec.builtins` (return string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `returnString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L211)

<a id="function-function-miniquake-quakec-builtins-returntemporarystring-function-returntemporarystring-machine-text-src-miniquake-quakec-builtins-ml-645962290"></a>
### returnTemporaryString

```ml
function returnTemporaryString(machine, text)
```

Implements the `returnTemporaryString` operation for `miniquake.quakec.builtins` (return temporary string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `returnTemporaryString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L218)

<a id="function-function-miniquake-quakec-builtins-returnvector-function-returnvector-machine-value-src-miniquake-quakec-builtins-ml-1647827948"></a>
### returnVector

```ml
function returnVector(machine, value)
```

Return return vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `returnVector`. |
| `value` | `dynamic` | — | Value consumed by `returnVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L204)

<a id="function-function-miniquake-quakec-builtins-returnword-function-returnword-machine-value-src-miniquake-quakec-builtins-ml-1221078848"></a>
### returnWord

```ml
function returnWord(machine, value)
```

Implements the `returnWord` operation for `miniquake.quakec.builtins` (return word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `returnWord`. |
| `value` | `dynamic` | — | Value consumed by `returnWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L186)

<a id="function-function-miniquake-quakec-builtins-roundbuiltin-function-roundbuiltin-machine-src-miniquake-quakec-builtins-ml-1653935821"></a>
### roundBuiltin

```ml
function roundBuiltin(machine)
```

Implements the `roundBuiltin` operation for `miniquake.quakec.builtins` (round builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `roundBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1133)

<a id="function-function-miniquake-quakec-builtins-roundhalfevenpositive-function-roundhalfevenpositive-value-src-miniquake-quakec-builtins-ml-249090997"></a>
### roundHalfEvenPositive

```ml
function roundHalfEvenPositive(value)
```

Implements the `roundHalfEvenPositive` operation for `miniquake.quakec.builtins` (round half even positive).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `roundHalfEvenPositive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L964)

<a id="function-function-miniquake-quakec-builtins-setentityfloat-function-setentityfloat-machine-entityindex-name-value-src-miniquake-quakec-builtins-ml-1697194034"></a>
### setEntityFloat

```ml
function setEntityFloat(machine, entityIndex, name, value)
```

Sets entity float for `miniquake.quakec.builtins`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityFloat`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setEntityFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L332)

<a id="function-function-miniquake-quakec-builtins-setentityvector-function-setentityvector-machine-entityindex-name-value-src-miniquake-quakec-builtins-ml-677645310"></a>
### setEntityVector

```ml
function setEntityVector(machine, entityIndex, name, value)
```

Sets entity vector for `miniquake.quakec.builtins`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setEntityVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L351)

<a id="function-function-miniquake-quakec-builtins-setentityword-function-setentityword-machine-entityindex-name-value-src-miniquake-quakec-builtins-ml-2143143684"></a>
### setEntityWord

```ml
function setEntityWord(machine, entityIndex, name, value)
```

Update module state for entity word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityWord`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setEntityWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L312)

<a id="function-function-miniquake-quakec-builtins-setfloat-function-setfloat-machine-offset-value-src-miniquake-quakec-builtins-ml-1191104445"></a>
### setFloat

```ml
function setFloat(machine, offset, value)
```

Update module state for float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setFloat`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L98)

<a id="function-function-miniquake-quakec-builtins-setglobalfloat-function-setglobalfloat-machine-name-value-src-miniquake-quakec-builtins-ml-1645457605"></a>
### setGlobalFloat

```ml
function setGlobalFloat(machine, name, value)
```

Update module state for global float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setGlobalFloat`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setGlobalFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L279)

<a id="function-function-miniquake-quakec-builtins-setglobalvector-function-setglobalvector-machine-name-value-src-miniquake-quakec-builtins-ml-349926577"></a>
### setGlobalVector

```ml
function setGlobalVector(machine, name, value)
```

Update module state for global vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setGlobalVector`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setGlobalVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L290)

<a id="function-function-miniquake-quakec-builtins-setglobalword-function-setglobalword-machine-name-value-src-miniquake-quakec-builtins-ml-1952208211"></a>
### setGlobalWord

```ml
function setGlobalWord(machine, name, value)
```

Update module state for global word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setGlobalWord`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setGlobalWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L268)

<a id="function-function-miniquake-quakec-builtins-setminmaxsize-function-setminmaxsize-machine-entityindex-mins-maxs-rotate-src-miniquake-quakec-builtins-ml-674466467"></a>
### SetMinMaxSize

```ml
function SetMinMaxSize(machine, entityIndex, mins, maxs, rotate)
```

Update module state for min max size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `SetMinMaxSize`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `mins` | `dynamic` | — | The mins input consumed by `SetMinMaxSize`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `SetMinMaxSize`. |
| `rotate` | `dynamic` | — | The rotate input consumed by `SetMinMaxSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1695)

<a id="function-function-miniquake-quakec-builtins-setminmaxsize-function-setminmaxsize-machine-entityindex-mins-maxs-rotate-src-miniquake-quakec-builtins-ml-1890791587"></a>
### setMinMaxSize

```ml
function setMinMaxSize(machine, entityIndex, mins, maxs, rotate)
```

Update module state for min max size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setMinMaxSize`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `mins` | `dynamic` | — | The mins input consumed by `setMinMaxSize`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `setMinMaxSize`. |
| `rotate` | `dynamic` | — | The rotate input consumed by `setMinMaxSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L405)

<a id="function-function-miniquake-quakec-builtins-setmodel-function-setmodel-machine-src-miniquake-quakec-builtins-ml-561793081"></a>
### setModel

```ml
function setModel(machine)
```

Update module state for model.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L578)

<a id="function-function-miniquake-quakec-builtins-setorigin-function-setorigin-machine-src-miniquake-quakec-builtins-ml-835542969"></a>
### setOrigin

```ml
function setOrigin(machine)
```

Update module state for origin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setOrigin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L569)

<a id="function-function-miniquake-quakec-builtins-setsize-function-setsize-machine-src-miniquake-quakec-builtins-ml-180499347"></a>
### setSize

```ml
function setSize(machine)
```

Update module state for size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L593)

<a id="function-function-miniquake-quakec-builtins-setspawnparmsbuiltin-function-setspawnparmsbuiltin-machine-src-miniquake-quakec-builtins-ml-796260081"></a>
### setSpawnParmsBuiltin

```ml
function setSpawnParmsBuiltin(machine)
```

Update module state for spawn parms builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setSpawnParmsBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1507)

<a id="function-function-miniquake-quakec-builtins-settraceglobals-function-settraceglobals-machine-trace-src-miniquake-quakec-builtins-ml-1422892410"></a>
### setTraceGlobals

```ml
function setTraceGlobals(machine, trace)
```

Update module state for trace globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setTraceGlobals`. |
| `trace` | `dynamic` | — | The trace input consumed by `setTraceGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L707)

<a id="function-function-miniquake-quakec-builtins-setvectorvalue-function-setvectorvalue-machine-offset-value-src-miniquake-quakec-builtins-ml-145455321"></a>
### setVectorValue

```ml
function setVectorValue(machine, offset, value)
```

Update module state for vector value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setVectorValue`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setVectorValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L116)

<a id="function-function-miniquake-quakec-builtins-setword-function-setword-machine-offset-value-src-miniquake-quakec-builtins-ml-528260349"></a>
### setWord

```ml
function setWord(machine, offset, value)
```

Update module state for word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setWord`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L81)

<a id="function-function-miniquake-quakec-builtins-soundbuiltin-function-soundbuiltin-machine-src-miniquake-quakec-builtins-ml-1451105349"></a>
### soundBuiltin

```ml
function soundBuiltin(machine)
```

Implements the `soundBuiltin` operation for `miniquake.quakec.builtins` (sound builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `soundBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L629)

<a id="function-function-miniquake-quakec-builtins-spawnbuiltin-function-spawnbuiltin-machine-src-miniquake-quakec-builtins-ml-642592957"></a>
### spawnBuiltin

```ml
function spawnBuiltin(machine)
```

Allocate and initialize builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `spawnBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L692)

<a id="function-function-miniquake-quakec-builtins-stringat-function-stringat-machine-handle-src-miniquake-quakec-builtins-ml-1923437227"></a>
### stringAt

```ml
function stringAt(machine, handle)
```

Implements the `stringAt` operation for `miniquake.quakec.builtins` (string at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `stringAt`. |
| `handle` | `dynamic` | — | The handle input consumed by `stringAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L152)

<a id="function-function-miniquake-quakec-builtins-stuffcommandbuiltin-function-stuffcommandbuiltin-machine-src-miniquake-quakec-builtins-ml-1833125037"></a>
### stuffCommandBuiltin

```ml
function stuffCommandBuiltin(machine)
```

Implements the `stuffCommandBuiltin` operation for `miniquake.quakec.builtins` (stuff command builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `stuffCommandBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L860)

<a id="function-function-miniquake-quakec-builtins-traceentitymove-function-traceentitymove-machine-entityindex-start-finish-src-miniquake-quakec-builtins-ml-1548274711"></a>
### traceEntityMove

```ml
function traceEntityMove(machine, entityIndex, start, finish)
```

Trace entity move through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `traceEntityMove`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `start` | `dynamic` | — | The start input consumed by `traceEntityMove`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceEntityMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1046)

<a id="function-function-miniquake-quakec-builtins-tracelinebuiltin-function-tracelinebuiltin-machine-src-miniquake-quakec-builtins-ml-912274077"></a>
### traceLineBuiltin

```ml
function traceLineBuiltin(machine)
```

Trace line builtin through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `traceLineBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L727)

<a id="function-function-miniquake-quakec-builtins-traceoffbuiltin-function-traceoffbuiltin-machine-src-miniquake-quakec-builtins-ml-825023515"></a>
### traceOffBuiltin

```ml
function traceOffBuiltin(machine)
```

Trace off builtin through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `traceOffBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1028)

<a id="function-function-miniquake-quakec-builtins-traceonbuiltin-function-traceonbuiltin-machine-src-miniquake-quakec-builtins-ml-1777751349"></a>
### traceOnBuiltin

```ml
function traceOnBuiltin(machine)
```

Trace on builtin through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `traceOnBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1021)

<a id="function-function-miniquake-quakec-builtins-updatebounds-function-updatebounds-machine-entityindex-src-miniquake-quakec-builtins-ml-1121688592"></a>
### updateBounds

```ml
function updateBounds(machine, entityIndex)
```

Update module state for bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `updateBounds`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L371)

<a id="function-function-miniquake-quakec-builtins-varstring-function-varstring-machine-first-src-miniquake-quakec-builtins-ml-921751819"></a>
### varString

```ml
function varString(machine, first)
```

Implements the `varString` operation for `miniquake.quakec.builtins` (var string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `varString`. |
| `first` | `dynamic` | — | The first input consumed by `varString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L166)

<a id="function-function-miniquake-quakec-builtins-vectoranglesbuiltin-function-vectoranglesbuiltin-machine-src-miniquake-quakec-builtins-ml-1888453089"></a>
### vectorAnglesBuiltin

```ml
function vectorAnglesBuiltin(machine)
```

Implements the `vectorAnglesBuiltin` operation for `miniquake.quakec.builtins` (vector angles builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `vectorAnglesBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1305)

<a id="function-function-miniquake-quakec-builtins-vectorlengthbuiltin-function-vectorlengthbuiltin-machine-src-miniquake-quakec-builtins-ml-1487524421"></a>
### vectorLengthBuiltin

```ml
function vectorLengthBuiltin(machine)
```

Implements the `vectorLengthBuiltin` operation for `miniquake.quakec.builtins` (vector length builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `vectorLengthBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L672)

<a id="function-function-miniquake-quakec-builtins-vectortostringbuiltin-function-vectortostringbuiltin-machine-src-miniquake-quakec-builtins-ml-307444553"></a>
### vectorToStringBuiltin

```ml
function vectorToStringBuiltin(machine)
```

Implements the `vectorToStringBuiltin` operation for `miniquake.quakec.builtins` (vector to string builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `vectorToStringBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L993)

<a id="function-function-miniquake-quakec-builtins-vectorvalue-function-vectorvalue-machine-offset-src-miniquake-quakec-builtins-ml-1057466526"></a>
### vectorValue

```ml
function vectorValue(machine, offset)
```

Return vector value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `vectorValue`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L108)

<a id="function-function-miniquake-quakec-builtins-vectoryawbuiltin-function-vectoryawbuiltin-machine-src-miniquake-quakec-builtins-ml-1849647653"></a>
### vectorYawBuiltin

```ml
function vectorYawBuiltin(machine)
```

Implements the `vectorYawBuiltin` operation for `miniquake.quakec.builtins` (vector yaw builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `vectorYawBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L679)

<a id="function-function-miniquake-quakec-builtins-walkmovebuiltin-function-walkmovebuiltin-machine-src-miniquake-quakec-builtins-ml-1729940539"></a>
### walkMoveBuiltin

```ml
function walkMoveBuiltin(machine)
```

Implements the `walkMoveBuiltin` operation for `miniquake.quakec.builtins` (walk move builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `walkMoveBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1060)

<a id="function-function-miniquake-quakec-builtins-word-function-word-machine-offset-src-miniquake-quakec-builtins-ml-611367982"></a>
### word

```ml
function word(machine, offset)
```

Implements the `word` operation for `miniquake.quakec.builtins` (word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `word`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L72)

<a id="function-function-miniquake-quakec-builtins-writeanglebuiltin-function-writeanglebuiltin-machine-src-miniquake-quakec-builtins-ml-162389775"></a>
### writeAngleBuiltin

```ml
function writeAngleBuiltin(machine)
```

Encode and write angle builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeAngleBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1376)

<a id="function-function-miniquake-quakec-builtins-writebytebuiltin-function-writebytebuiltin-machine-src-miniquake-quakec-builtins-ml-1070182845"></a>
### writeByteBuiltin

```ml
function writeByteBuiltin(machine)
```

Encode and write byte builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeByteBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1341)

<a id="function-function-miniquake-quakec-builtins-writecharbuiltin-function-writecharbuiltin-machine-src-miniquake-quakec-builtins-ml-1027850269"></a>
### writeCharBuiltin

```ml
function writeCharBuiltin(machine)
```

Encode and write char builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeCharBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1348)

<a id="function-function-miniquake-quakec-builtins-writecoordbuiltin-function-writecoordbuiltin-machine-src-miniquake-quakec-builtins-ml-1276124415"></a>
### writeCoordBuiltin

```ml
function writeCoordBuiltin(machine)
```

Encode and write coord builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeCoordBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1369)

<a id="function-function-miniquake-quakec-builtins-writedest-function-writedest-machine-src-miniquake-quakec-builtins-ml-764799411"></a>
### WriteDest

```ml
function WriteDest(machine)
```

Encode and write dest.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `WriteDest`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L2017)

<a id="function-function-miniquake-quakec-builtins-writeentitybuiltin-function-writeentitybuiltin-machine-src-miniquake-quakec-builtins-ml-223870401"></a>
### writeEntityBuiltin

```ml
function writeEntityBuiltin(machine)
```

Encode and write entity builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeEntityBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1390)

<a id="function-function-miniquake-quakec-builtins-writelongbuiltin-function-writelongbuiltin-machine-src-miniquake-quakec-builtins-ml-214016173"></a>
### writeLongBuiltin

```ml
function writeLongBuiltin(machine)
```

Encode and write long builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeLongBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1362)

<a id="function-function-miniquake-quakec-builtins-writeshortbuiltin-function-writeshortbuiltin-machine-src-miniquake-quakec-builtins-ml-1493019513"></a>
### writeShortBuiltin

```ml
function writeShortBuiltin(machine)
```

Encode and write short builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeShortBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1355)

<a id="function-function-miniquake-quakec-builtins-writestaticbaseline-function-writestaticbaseline-buffer-machine-entityindex-src-miniquake-quakec-builtins-ml-691403214"></a>
### writeStaticBaseline

```ml
function writeStaticBaseline(buffer, machine, entityIndex)
```

Encode and write static baseline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeStaticBaseline`. |
| `machine` | `dynamic` | — | The machine input consumed by `writeStaticBaseline`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1423)

<a id="function-function-miniquake-quakec-builtins-writestringbuiltin-function-writestringbuiltin-machine-src-miniquake-quakec-builtins-ml-1245892345"></a>
### writeStringBuiltin

```ml
function writeStringBuiltin(machine)
```

Encode and write string builtin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeStringBuiltin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/builtins.ml#L1383)
