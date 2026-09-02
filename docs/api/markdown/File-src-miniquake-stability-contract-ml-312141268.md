# `src/miniquake/stability_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.stability_contract`](Package-miniquake-stability-contract-522350205.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)

## Declarations

<a id="constant-constant-miniquake-stability-contract-client-entity-policy-const-client-entity-policy-server-high-water-plus-existing-static-offset-src-miniquake-stability-contract-ml-1977253098"></a>
### CLIENT_ENTITY_POLICY

```ml
const CLIENT_ENTITY_POLICY = "server_high_water_plus_existing_static_offset"
```

Defines the client entity policy value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L20)

<a id="function-function-miniquake-stability-contract-cliententityhighwaterstable-function-cliententityhighwaterstable-serverbefore-serverafter-entitiesbefore-entitiesafter-src-miniquake-stability-contract-ml-1779095603"></a>
### clientEntityHighWaterStable

```ml
function clientEntityHighWaterStable(serverBefore, serverAfter, entitiesBefore, entitiesAfter)
```

Implements the `clientEntityHighWaterStable` operation for `miniquake.stability_contract` (client entity high water stable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverBefore` | `dynamic` | — | The server before input consumed by `clientEntityHighWaterStable`. |
| `serverAfter` | `dynamic` | — | The server after input consumed by `clientEntityHighWaterStable`. |
| `entitiesBefore` | `dynamic` | — | The entities before input consumed by `clientEntityHighWaterStable`. |
| `entitiesAfter` | `dynamic` | — | The entities after input consumed by `clientEntityHighWaterStable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L84)

<a id="function-function-miniquake-stability-contract-cliententitylimit-function-cliententitylimit-serverbefore-serverafter-entitiesbefore-src-miniquake-stability-contract-ml-461820160"></a>
### clientEntityLimit

```ml
function clientEntityLimit(serverBefore, serverAfter, entitiesBefore)
```

WinQuake owns a fixed cl_entities[MAX_EDICTS] array and advances cl_num_entities as higher server entity numbers are first observed. The MiniLang port stores only the reached prefix, so a listen-server client may legitimately catch up from N to an already existing sv.num_edicts high-water after the soak baseline. Preserve only the static-entity offset that already existed at the baseline; new growth beyond that topology remains a failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `serverBefore` | `dynamic` | — | The server before input consumed by `clientEntityLimit`. |
| `serverAfter` | `dynamic` | — | The server after input consumed by `clientEntityLimit`. |
| `entitiesBefore` | `dynamic` | — | The entities before input consumed by `clientEntityLimit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L61)

<a id="constant-constant-miniquake-stability-contract-contract-text-const-contract-text-stability-host-soak-5000-listen-soak-5000-gc-resource-plateau-client-entities-server-highwater-baseline-static-offset-clean-shutdown-live-output-src-miniquake-stability-contract-ml-692384128"></a>
### CONTRACT_TEXT

```ml
const CONTRACT_TEXT = "stability|host-soak=5000|listen-soak=5000|gc-resource-plateau|client-entities<=server-highwater+baseline-static-offset|clean-shutdown|live-output"
```

Defines the contract text value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L18)

<a id="function-function-miniquake-stability-contract-contractvector-function-contractvector-src-miniquake-stability-contract-ml-1623426161"></a>
### contractVector

```ml
function contractVector()
```

Implements the `contractVector` operation for `miniquake.stability_contract` (contract vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L135)

<a id="constant-constant-miniquake-stability-contract-default-soak-frames-const-default-soak-frames-5000-src-miniquake-stability-contract-ml-2136246807"></a>
### DEFAULT_SOAK_FRAMES

```ml
const DEFAULT_SOAK_FRAMES = 5000
```

Defines the default soak frames value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L22)

<a id="function-function-miniquake-stability-contract-deltastable-inline-function-deltastable-before-after-allowance-src-miniquake-stability-contract-ml-925286461"></a>
### deltaStable

```ml
inline function deltaStable(before, after, allowance)
```

Implements the `deltaStable` operation for `miniquake.stability_contract` (delta stable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `before` | `dynamic` | — | The before input consumed by `deltaStable`. |
| `after` | `dynamic` | — | The after input consumed by `deltaStable`. |
| `allowance` | `dynamic` | — | The allowance input consumed by `deltaStable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L39)

<a id="constant-constant-miniquake-stability-contract-fingerprint-const-fingerprint-3504586815-src-miniquake-stability-contract-ml-116285203"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 3504586815
```

Defines the fingerprint value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L16)

<a id="function-function-miniquake-stability-contract-hoststable-function-hoststable-livebefore-liveafter-bytesbefore-bytesafter-src-miniquake-stability-contract-ml-35266319"></a>
### hostStable

```ml
function hostStable(liveBefore, liveAfter, bytesBefore, bytesAfter)
```

Apply the Quake-compatible host stable behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `liveBefore` | `dynamic` | — | The live before input consumed by `hostStable`. |
| `liveAfter` | `dynamic` | — | The live after input consumed by `hostStable`. |
| `bytesBefore` | `dynamic` | — | The bytes before input consumed by `hostStable`. |
| `bytesAfter` | `dynamic` | — | The bytes after input consumed by `hostStable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L48)

<a id="constant-constant-miniquake-stability-contract-listen-soak-frames-const-listen-soak-frames-5000-src-miniquake-stability-contract-ml-1549341847"></a>
### LISTEN_SOAK_FRAMES

```ml
const LISTEN_SOAK_FRAMES = 5000
```

Defines the listen soak frames value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L24)

<a id="constant-constant-miniquake-stability-contract-live-block-allowance-const-live-block-allowance-512-src-miniquake-stability-contract-ml-1989502240"></a>
### LIVE_BLOCK_ALLOWANCE

```ml
const LIVE_BLOCK_ALLOWANCE = 512
```

Defines the live block allowance value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L26)

<a id="constant-constant-miniquake-stability-contract-live-byte-allowance-const-live-byte-allowance-65536-src-miniquake-stability-contract-ml-712902677"></a>
### LIVE_BYTE_ALLOWANCE

```ml
const LIVE_BYTE_ALLOWANCE = 65536
```

Defines the live byte allowance value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L28)

<a id="function-function-miniquake-stability-contract-longchecks-function-longchecks-before-after-src-miniquake-stability-contract-ml-591561238"></a>
### longChecks

```ml
function longChecks(before, after)
```

Implements the `longChecks` operation for `miniquake.stability_contract` (long checks).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `before` | `dynamic` | — | The before input consumed by `longChecks`. |
| `after` | `dynamic` | — | The after input consumed by `longChecks`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L93)

<a id="function-function-miniquake-stability-contract-longstable-function-longstable-before-after-src-miniquake-stability-contract-ml-1906766062"></a>
### longStable

```ml
function longStable(before, after)
```

Implements the `longStable` operation for `miniquake.stability_contract` (long stable).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `before` | `dynamic` | — | The before input consumed by `longStable`. |
| `after` | `dynamic` | — | The after input consumed by `longStable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L126)

<a id="function-function-miniquake-stability-contract-modes-inline-function-modes-src-miniquake-stability-contract-ml-303566748"></a>
### modes

```ml
inline function modes()
```

Implements the `modes` operation for `miniquake.stability_contract` (modes).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L31)

<a id="constant-constant-miniquake-stability-contract-status-const-status-stability-109-frozen-v1-src-miniquake-stability-contract-ml-1591102641"></a>
### STATUS

```ml
const STATUS = "stability_109_frozen_v1"
```

Defines the status value used by `miniquake.stability_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/stability_contract.ml#L14)
