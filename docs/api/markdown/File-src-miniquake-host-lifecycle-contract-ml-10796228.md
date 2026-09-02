# `src/miniquake/host_lifecycle_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.host_lifecycle_contract`](Package-miniquake-host-lifecycle-contract-2012671789.md)

Reachable from entry: **no**

## Declarations

<a id="function-function-miniquake-host-lifecycle-contract-canonicaltext-function-canonicaltext-src-miniquake-host-lifecycle-contract-ml-1609050045"></a>
### canonicalText

```ml
function canonicalText()
```

Returns whether `miniquake.host_lifecycle_contract` can onical text.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L105)

<a id="function-function-miniquake-host-lifecycle-contract-changelevelstages-function-changelevelstages-src-miniquake-host-lifecycle-contract-ml-1723448009"></a>
### changeLevelStages

```ml
function changeLevelStages()
```

Update subsystem configuration for change level stages.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L71)

<a id="constant-constant-miniquake-host-lifecycle-contract-contract-fingerprint-const-contract-fingerprint-2361094303-src-miniquake-host-lifecycle-contract-ml-1966221385"></a>
### CONTRACT_FINGERPRINT

```ml
const CONTRACT_FINGERPRINT = 2361094303
```

Defines the contract fingerprint value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L14)

<a id="function-function-miniquake-host-lifecycle-contract-demoframestages-function-demoframestages-src-miniquake-host-lifecycle-contract-ml-1487812669"></a>
### demoFrameStages

```ml
function demoFrameStages()
```

Implements the `demoFrameStages` operation for `miniquake.host_lifecycle_contract` (demo frame stages).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L50)

<a id="function-function-miniquake-host-lifecycle-contract-errorstages-function-errorstages-src-miniquake-host-lifecycle-contract-ml-625601325"></a>
### errorStages

```ml
function errorStages()
```

Report stages and return the corresponding failure status.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L97)

<a id="function-function-miniquake-host-lifecycle-contract-fingerprint-function-fingerprint-text-src-miniquake-host-lifecycle-contract-ml-792769044"></a>
### fingerprint

```ml
function fingerprint(text)
```

Returns the compatibility fingerprint for `miniquake.host_lifecycle_contract`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L121)

<a id="function-function-miniquake-host-lifecycle-contract-frametracestages-function-frametracestages-sendstage-src-miniquake-host-lifecycle-contract-ml-961757793"></a>
### frameTraceStages

```ml
function frameTraceStages(sendStage)
```

Advance trace stages by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sendStage` | `dynamic` | — | The send stage input consumed by `frameTraceStages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L30)

<a id="constant-constant-miniquake-host-lifecycle-contract-lightstyle-count-const-lightstyle-count-64-src-miniquake-host-lifecycle-contract-ml-1970639436"></a>
### LIGHTSTYLE_COUNT

```ml
const LIGHTSTYLE_COUNT = 64
```

Defines the lightstyle count value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L22)

<a id="function-function-miniquake-host-lifecycle-contract-localframestages-function-localframestages-src-miniquake-host-lifecycle-contract-ml-987599999"></a>
### localFrameStages

```ml
function localFrameStages()
```

Implements the `localFrameStages` operation for `miniquake.host_lifecycle_contract` (local frame stages).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L40)

<a id="function-function-miniquake-host-lifecycle-contract-mapreplacestages-function-mapreplacestages-src-miniquake-host-lifecycle-contract-ml-2084094999"></a>
### mapReplaceStages

```ml
function mapReplaceStages()
```

Implements the `mapReplaceStages` operation for `miniquake.host_lifecycle_contract` (map replace stages).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L63)

<a id="function-function-miniquake-host-lifecycle-contract-remoteframestages-function-remoteframestages-src-miniquake-host-lifecycle-contract-ml-35664807"></a>
### remoteFrameStages

```ml
function remoteFrameStages()
```

Implements the `remoteFrameStages` operation for `miniquake.host_lifecycle_contract` (remote frame stages).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L45)

<a id="function-function-miniquake-host-lifecycle-contract-restartstages-function-restartstages-src-miniquake-host-lifecycle-contract-ml-757182007"></a>
### restartStages

```ml
function restartStages()
```

Implements the `restartStages` operation for `miniquake.host_lifecycle_contract` (restart stages).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L76)

<a id="constant-constant-miniquake-host-lifecycle-contract-savegame-comment-length-const-savegame-comment-length-39-src-miniquake-host-lifecycle-contract-ml-1689076842"></a>
### SAVEGAME_COMMENT_LENGTH

```ml
const SAVEGAME_COMMENT_LENGTH = 39
```

Defines the savegame comment length value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L18)

<a id="constant-constant-miniquake-host-lifecycle-contract-savegame-version-const-savegame-version-5-src-miniquake-host-lifecycle-contract-ml-1941510987"></a>
### SAVEGAME_VERSION

```ml
const SAVEGAME_VERSION = 5
```

Defines the savegame version value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L16)

<a id="function-function-miniquake-host-lifecycle-contract-savegamestages-function-savegamestages-src-miniquake-host-lifecycle-contract-ml-2049917579"></a>
### savegameStages

```ml
function savegameStages()
```

Encode and write game stages.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L81)

<a id="function-function-miniquake-host-lifecycle-contract-serverframestages-function-serverframestages-simulate-src-miniquake-host-lifecycle-contract-ml-87696979"></a>
### serverFrameStages

```ml
function serverFrameStages(simulate)
```

Implements the `serverFrameStages` operation for `miniquake.host_lifecycle_contract` (server frame stages).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `simulate` | `dynamic` | — | The simulate input consumed by `serverFrameStages`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L56)

<a id="constant-constant-miniquake-host-lifecycle-contract-shutdown-broadcast-seconds-const-shutdown-broadcast-seconds-5-src-miniquake-host-lifecycle-contract-ml-2025597795"></a>
### SHUTDOWN_BROADCAST_SECONDS

```ml
const SHUTDOWN_BROADCAST_SECONDS = 5
```

Defines the shutdown broadcast seconds value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L26)

<a id="constant-constant-miniquake-host-lifecycle-contract-shutdown-flush-seconds-const-shutdown-flush-seconds-3-src-miniquake-host-lifecycle-contract-ml-513086107"></a>
### SHUTDOWN_FLUSH_SECONDS

```ml
const SHUTDOWN_FLUSH_SECONDS = 3
```

Defines the shutdown flush seconds value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L24)

<a id="function-function-miniquake-host-lifecycle-contract-shutdownstages-function-shutdownstages-src-miniquake-host-lifecycle-contract-ml-1850574491"></a>
### shutdownStages

```ml
function shutdownStages()
```

Release state for shutdown stages.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L89)

<a id="constant-constant-miniquake-host-lifecycle-contract-spawn-parm-count-const-spawn-parm-count-16-src-miniquake-host-lifecycle-contract-ml-390675661"></a>
### SPAWN_PARM_COUNT

```ml
const SPAWN_PARM_COUNT = 16
```

Defines the spawn parm count value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L20)

<a id="constant-constant-miniquake-host-lifecycle-contract-status-const-status-host-lifecycle-109-frozen-v1-src-miniquake-host-lifecycle-contract-ml-1355085967"></a>
### STATUS

```ml
const STATUS = "host_lifecycle_109_frozen_v1"
```

Defines the status value used by `miniquake.host_lifecycle_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L12)

<a id="function-function-miniquake-host-lifecycle-contract-verify-function-verify-src-miniquake-host-lifecycle-contract-ml-1734644171"></a>
### verify

```ml
function verify()
```

Implements the `verify` operation for `miniquake.host_lifecycle_contract` (verify).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_lifecycle_contract.ml#L130)
