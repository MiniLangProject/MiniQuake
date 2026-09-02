# `src/miniquake/protocol15_freeze.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol15_freeze`](Package-miniquake-protocol15-freeze-357562521.md)

Reachable from entry: **no**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)

## Declarations

<a id="constant-constant-miniquake-protocol15-freeze-clc-valid-count-const-clc-valid-count-4-src-miniquake-protocol15-freeze-ml-1472615900"></a>
### CLC_VALID_COUNT

```ml
const CLC_VALID_COUNT = 4
```

Defines the clc valid count value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L22)

<a id="constant-constant-miniquake-protocol15-freeze-client-data-mask-const-client-data-mask-32511-src-miniquake-protocol15-freeze-ml-766697562"></a>
### CLIENT_DATA_MASK

```ml
const CLIENT_DATA_MASK = 32511
```

Defines the client data mask value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L26)

<a id="function-function-miniquake-protocol15-freeze-clientdatabits-function-clientdatabits-src-miniquake-protocol15-freeze-ml-1950949119"></a>
### clientDataBits

```ml
function clientDataBits()
```

Return client data bits derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L60)

<a id="function-function-miniquake-protocol15-freeze-combinemask-function-combinemask-values-src-miniquake-protocol15-freeze-ml-1754852863"></a>
### combineMask

```ml
function combineMask(values)
```

Implements the `combineMask` operation for `miniquake.protocol15_freeze` (combine mask).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `combineMask`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L115)

<a id="function-function-miniquake-protocol15-freeze-contains-function-contains-values-wanted-src-miniquake-protocol15-freeze-ml-703414426"></a>
### contains

```ml
function contains(values, wanted)
```

Implements the `contains` operation for `miniquake.protocol15_freeze` (contains).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `contains`. |
| `wanted` | `dynamic` | — | The wanted input consumed by `contains`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L88)

<a id="function-function-miniquake-protocol15-freeze-coveragesummary-function-coveragesummary-src-miniquake-protocol15-freeze-ml-1038252483"></a>
### coverageSummary

```ml
function coverageSummary()
```

Return coverage summary derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L161)

<a id="constant-constant-miniquake-protocol15-freeze-fast-update-mask-const-fast-update-mask-32767-src-miniquake-protocol15-freeze-ml-367218979"></a>
### FAST_UPDATE_MASK

```ml
const FAST_UPDATE_MASK = 32767
```

Defines the fast update mask value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L24)

<a id="function-function-miniquake-protocol15-freeze-fastupdatebits-function-fastupdatebits-src-miniquake-protocol15-freeze-ml-1270876031"></a>
### fastUpdateBits

```ml
function fastUpdateBits()
```

Return fast update bits derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L50)

<a id="constant-constant-miniquake-protocol15-freeze-fingerprint-const-fingerprint-217178410-src-miniquake-protocol15-freeze-ml-37604489"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 217178410
```

Defines the fingerprint value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L32)

<a id="function-function-miniquake-protocol15-freeze-fingerprintvalue-inline-function-fingerprintvalue-current-value-src-miniquake-protocol15-freeze-ml-140923146"></a>
### fingerprintValue

```ml
inline function fingerprintValue(current, value)
```

Return fingerprint value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `current` | `dynamic` | — | The current input consumed by `fingerprintValue`. |
| `value` | `dynamic` | — | Value consumed by `fingerprintValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L126)

<a id="function-function-miniquake-protocol15-freeze-fingerprintvalues-function-fingerprintvalues-current-values-src-miniquake-protocol15-freeze-ml-2140194682"></a>
### fingerprintValues

```ml
function fingerprintValues(current, values)
```

Return fingerprint values derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `current` | `dynamic` | — | The current input consumed by `fingerprintValues`. |
| `values` | `dynamic` | — | The values input consumed by `fingerprintValues`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L133)

<a id="function-function-miniquake-protocol15-freeze-isreservedsvc-function-isreservedsvc-command-src-miniquake-protocol15-freeze-ml-649000032"></a>
### isReservedSvc

```ml
function isReservedSvc(command)
```

Report whether is reserved svc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L103)

<a id="function-function-miniquake-protocol15-freeze-isvalidclc-function-isvalidclc-command-src-miniquake-protocol15-freeze-ml-845019144"></a>
### isValidClc

```ml
function isValidClc(command)
```

Report whether is valid clc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L109)

<a id="function-function-miniquake-protocol15-freeze-isvalidsvc-function-isvalidsvc-command-src-miniquake-protocol15-freeze-ml-103450568"></a>
### isValidSvc

```ml
function isValidSvc(command)
```

Report whether is valid svc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | Console or protocol command to execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L97)

<a id="constant-constant-miniquake-protocol15-freeze-protocol-version-const-protocol-version-15-src-miniquake-protocol15-freeze-ml-1871924248"></a>
### PROTOCOL_VERSION

```ml
const PROTOCOL_VERSION = 15
```

Defines the protocol version value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L18)

<a id="function-function-miniquake-protocol15-freeze-protocolfingerprint-function-protocolfingerprint-src-miniquake-protocol15-freeze-ml-1604665511"></a>
### protocolFingerprint

```ml
function protocolFingerprint()
```

Implements the `protocolFingerprint` operation for `miniquake.protocol15_freeze` (protocol fingerprint).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L142)

<a id="constant-constant-miniquake-protocol15-freeze-sound-mask-const-sound-mask-7-src-miniquake-protocol15-freeze-ml-1245044685"></a>
### SOUND_MASK

```ml
const SOUND_MASK = 7
```

Defines the sound mask value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L28)

<a id="function-function-miniquake-protocol15-freeze-soundbits-function-soundbits-src-miniquake-protocol15-freeze-ml-1194360945"></a>
### soundBits

```ml
function soundBits()
```

Return sound bits derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L71)

<a id="constant-constant-miniquake-protocol15-freeze-status-const-status-protocol15-frozen-v1-src-miniquake-protocol15-freeze-ml-1217925439"></a>
### STATUS

```ml
const STATUS = "protocol15_frozen_v1"
```

Defines the status value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L16)

<a id="constant-constant-miniquake-protocol15-freeze-svc-valid-count-const-svc-valid-count-33-src-miniquake-protocol15-freeze-ml-1440239636"></a>
### SVC_VALID_COUNT

```ml
const SVC_VALID_COUNT = 33
```

Defines the svc valid count value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L20)

<a id="constant-constant-miniquake-protocol15-freeze-temp-entity-count-const-temp-entity-count-14-src-miniquake-protocol15-freeze-ml-1123608205"></a>
### TEMP_ENTITY_COUNT

```ml
const TEMP_ENTITY_COUNT = 14
```

Defines the temp entity count value used by `miniquake.protocol15_freeze`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L30)

<a id="function-function-miniquake-protocol15-freeze-temporaryentitytypes-function-temporaryentitytypes-src-miniquake-protocol15-freeze-ml-1976178391"></a>
### temporaryEntityTypes

```ml
function temporaryEntityTypes()
```

Implements the `temporaryEntityTypes` operation for `miniquake.protocol15_freeze` (temporary entity types).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L76)

<a id="function-function-miniquake-protocol15-freeze-validclccommands-inline-function-validclccommands-src-miniquake-protocol15-freeze-ml-1987043194"></a>
### validClcCommands

```ml
inline function validClcCommands()
```

Report whether valid clc commands.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L45)

<a id="function-function-miniquake-protocol15-freeze-validsvccommands-function-validsvccommands-src-miniquake-protocol15-freeze-ml-539357951"></a>
### validSvcCommands

```ml
function validSvcCommands()
```

Report whether valid svc commands.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol15_freeze.ml#L35)
