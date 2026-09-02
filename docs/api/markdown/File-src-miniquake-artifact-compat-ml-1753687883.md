# `src/miniquake/artifact_compat.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.artifact_compat`](Package-miniquake-artifact-compat-1877167036.md)

Reachable from entry: **no**

## Imports

- `miniquake/crc.ml` as `crc` → [src/miniquake/crc.ml](File-src-miniquake-crc-ml-699476266.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-artifact-compat-bytescrc-function-bytescrc-data-src-miniquake-artifact-compat-ml-350849357"></a>
### bytesCrc

```ml
function bytesCrc(data)
```

Return bytes crc derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L48)

<a id="function-function-miniquake-artifact-compat-bytesequal-function-bytesequal-left-right-src-miniquake-artifact-compat-ml-1461236568"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Assert exact equality and report both values on failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `bytesEqual`. |
| `right` | `dynamic` | — | The right input consumed by `bytesEqual`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L36)

<a id="constant-constant-miniquake-artifact-compat-contract-text-const-contract-text-artifact-compat-demo-protocol15-retail-demos-3-save-version-5-save-roundtrip-deterministic-evidence-src-miniquake-artifact-compat-ml-628585942"></a>
### CONTRACT_TEXT

```ml
const CONTRACT_TEXT = "artifact-compat|demo-protocol15|retail-demos=3|save-version=5|save-roundtrip|deterministic-evidence"
```

Defines the contract text value used by `miniquake.artifact_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L20)

<a id="function-function-miniquake-artifact-compat-contractvector-function-contractvector-src-miniquake-artifact-compat-ml-724532113"></a>
### contractVector

```ml
function contractVector()
```

Implements the `contractVector` operation for `miniquake.artifact_compat` (contract vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L172)

<a id="function-function-miniquake-artifact-compat-demosummary-function-demosummary-recording-report-sourcebytes-src-miniquake-artifact-compat-ml-1134129324"></a>
### demoSummary

```ml
function demoSummary(recording, report, sourceBytes)
```

Return demo summary derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recording` | `dynamic` | — | The recording input consumed by `demoSummary`. |
| `report` | `dynamic` | — | The report input consumed by `demoSummary`. |
| `sourceBytes` | `dynamic` | — | Byte data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L147)

<a id="constant-constant-miniquake-artifact-compat-fingerprint-const-fingerprint-1498615953-src-miniquake-artifact-compat-ml-1337992845"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 1498615953
```

Defines the fingerprint value used by `miniquake.artifact_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L18)

<a id="function-function-miniquake-artifact-compat-firstbytedifference-function-firstbytedifference-left-right-src-miniquake-artifact-compat-ml-1901489142"></a>
### firstByteDifference

```ml
function firstByteDifference(left, right)
```

Return [first differing offset, left byte, right byte, left length, right length].  Byte values are -1 when the corresponding stream ended first.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `firstByteDifference`. |
| `right` | `dynamic` | — | The right input consumed by `firstByteDifference`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L126)

<a id="function-function-miniquake-artifact-compat-pairlistdifference-function-pairlistdifference-leftpairs-rightpairs-label-src-miniquake-artifact-compat-ml-967666700"></a>
### pairListDifference

```ml
function pairListDifference(leftPairs, rightPairs, label)
```

A Quake version-5 savegame is a deliberately lossy text snapshot.  Runtime floats are written with six decimals and only DEF_SAVEGLOBAL globals are archived.  Compare the parsed save-domain state instead of the complete live VM state, which also contains transient globals that the original format does not preserve.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftPairs` | `dynamic` | — | The left pairs input consumed by `pairListDifference`. |
| `rightPairs` | `dynamic` | — | The right pairs input consumed by `pairListDifference`. |
| `label` | `dynamic` | — | The label input consumed by `pairListDifference`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L61)

<a id="constant-constant-miniquake-artifact-compat-retail-demo-count-const-retail-demo-count-3-src-miniquake-artifact-compat-ml-544623931"></a>
### RETAIL_DEMO_COUNT

```ml
const RETAIL_DEMO_COUNT = 3
```

Defines the retail demo count value used by `miniquake.artifact_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L24)

<a id="function-function-miniquake-artifact-compat-retaildemonames-function-retaildemonames-src-miniquake-artifact-compat-ml-1303173485"></a>
### retailDemoNames

```ml
function retailDemoNames()
```

Return retail demo names derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L29)

<a id="constant-constant-miniquake-artifact-compat-save-float-format-const-save-float-format-msvcrt-percent-f-src-miniquake-artifact-compat-ml-98268906"></a>
### SAVE_FLOAT_FORMAT

```ml
const SAVE_FLOAT_FORMAT = "msvcrt_percent_f"
```

Defines the save float format value used by `miniquake.artifact_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L26)

<a id="constant-constant-miniquake-artifact-compat-savegame-version-const-savegame-version-5-src-miniquake-artifact-compat-ml-578035439"></a>
### SAVEGAME_VERSION

```ml
const SAVEGAME_VERSION = 5
```

Defines the savegame version value used by `miniquake.artifact_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L22)

<a id="function-function-miniquake-artifact-compat-savesemanticdifference-function-savesemanticdifference-left-right-src-miniquake-artifact-compat-ml-1119186836"></a>
### saveSemanticDifference

```ml
function saveSemanticDifference(left, right)
```

Encode and write semantic difference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `saveSemanticDifference`. |
| `right` | `dynamic` | — | The right input consumed by `saveSemanticDifference`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L83)

<a id="function-function-miniquake-artifact-compat-savesemanticequal-function-savesemanticequal-left-right-src-miniquake-artifact-compat-ml-703873370"></a>
### saveSemanticEqual

```ml
function saveSemanticEqual(left, right)
```

Compare semantic equal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `saveSemanticEqual`. |
| `right` | `dynamic` | — | The right input consumed by `saveSemanticEqual`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L118)

<a id="function-function-miniquake-artifact-compat-savesummary-function-savesummary-savebytes-mapname-timevalue-edicthash-globalshash-src-miniquake-artifact-compat-ml-1969594687"></a>
### saveSummary

```ml
function saveSummary(saveBytes, mapName, timeValue, edictHash, globalsHash)
```

Encode and write summary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `saveBytes` | `dynamic` | — | Byte data consumed by the operation. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `timeValue` | `dynamic` | — | The time value input consumed by `saveSummary`. |
| `edictHash` | `dynamic` | — | The edict hash input consumed by `saveSummary`. |
| `globalsHash` | `dynamic` | — | The globals hash input consumed by `saveSummary`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L167)

<a id="constant-constant-miniquake-artifact-compat-status-const-status-artifact-compat-109-frozen-v1-src-miniquake-artifact-compat-ml-176586525"></a>
### STATUS

```ml
const STATUS = "artifact_compat_109_frozen_v1"
```

Defines the status value used by `miniquake.artifact_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/artifact_compat.ml#L16)
