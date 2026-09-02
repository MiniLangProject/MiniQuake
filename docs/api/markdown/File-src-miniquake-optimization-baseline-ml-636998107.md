# `src/miniquake/optimization_baseline.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.optimization_baseline`](Package-miniquake-optimization-baseline-657416844.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-optimization-baseline-beginframe-function-beginframe-src-miniquake-optimization-baseline-ml-313314877"></a>
### beginFrame

```ml
function beginFrame()
```

Initialize state for begin frame.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L169)

<a id="function-function-miniquake-optimization-baseline-booltext-function-booltext-value-src-miniquake-optimization-baseline-ml-626050356"></a>
### boolText

```ml
function boolText(value)
```

Implements the `boolText` operation for `miniquake.optimization_baseline` (bool text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `boolText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L98)

<a id="function-function-miniquake-optimization-baseline-checkpoint-function-checkpoint-stage-src-miniquake-optimization-baseline-ml-2141755279"></a>
### checkpoint

```ml
function checkpoint(stage)
```

Checks point for `miniquake.optimization_baseline`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stage` | `dynamic` | — | The stage input consumed by `checkpoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L181)

<a id="function-function-miniquake-optimization-baseline-classifyhandles-function-classifyhandles-handles-nonhandlestable-src-miniquake-optimization-baseline-ml-895657608"></a>
### classifyHandles

```ml
function classifyHandles(handles, nonHandleStable)
```

Implements the `classifyHandles` operation for `miniquake.optimization_baseline` (classify handles).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handles` | `dynamic` | — | The handles input consumed by `classifyHandles`. |
| `nonHandleStable` | `dynamic` | — | The non handle stable input consumed by `classifyHandles`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L421)

<a id="function-function-miniquake-optimization-baseline-completeframe-function-completeframe-src-miniquake-optimization-baseline-ml-683986997"></a>
### completeFrame

```ml
function completeFrame()
```

Handle frame and update the associated state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L205)

<a id="function-function-miniquake-optimization-baseline-configure-function-configure-framecapacity-src-miniquake-optimization-baseline-ml-1311694216"></a>
### configure

```ml
function configure(frameCapacity)
```

Implements the `configure` operation for `miniquake.optimization_baseline` (configure).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameCapacity` | `dynamic` | — | The frame capacity input consumed by `configure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L141)

<a id="function-function-miniquake-optimization-baseline-disable-function-disable-src-miniquake-optimization-baseline-ml-1725872245"></a>
### disable

```ml
function disable()
```

Implements the `disable` operation for `miniquake.optimization_baseline` (disable).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L161)

<a id="function-function-miniquake-optimization-baseline-enabled-function-enabled-src-miniquake-optimization-baseline-ml-1013377023"></a>
### enabled

```ml
function enabled()
```

Report whether enabled holds for the active state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L104)

<a id="function-function-miniquake-optimization-baseline-filteredframe-function-filteredframe-src-miniquake-optimization-baseline-ml-149702565"></a>
### filteredFrame

```ml
function filteredFrame()
```

Implements the `filteredFrame` operation for `miniquake.optimization_baseline` (filtered frame).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L197)

<a id="function-function-miniquake-optimization-baseline-handlesequencetext-function-handlesequencetext-values-src-miniquake-optimization-baseline-ml-170933155"></a>
### handleSequenceText

```ml
function handleSequenceText(values)
```

Handle sequence text and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `handleSequenceText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L407)

<a id="function-function-miniquake-optimization-baseline-normalizestage-function-normalizestage-stage-src-miniquake-optimization-baseline-ml-1786031479"></a>
### normalizeStage

```ml
function normalizeStage(stage)
```

Convert stage into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stage` | `dynamic` | — | The stage input consumed by `normalizeStage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L110)

<a id="constant-constant-miniquake-optimization-baseline-other-stage-index-const-other-stage-index-19-src-miniquake-optimization-baseline-ml-314458822"></a>
### OTHER_STAGE_INDEX

```ml
const OTHER_STAGE_INDEX = 19
```

Defines the other stage index value used by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L18)

<a id="function-function-miniquake-optimization-baseline-percentilefromsorted-function-percentilefromsorted-values-numerator-denominator-src-miniquake-optimization-baseline-ml-963922794"></a>
### percentileFromSorted

```ml
function percentileFromSorted(values, numerator, denominator)
```

Implements the `percentileFromSorted` operation for `miniquake.optimization_baseline` (percentile from sorted).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `percentileFromSorted`. |
| `numerator` | `dynamic` | — | The numerator input consumed by `percentileFromSorted`. |
| `denominator` | `dynamic` | — | The denominator input consumed by `percentileFromSorted`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L253)

<a id="function-function-miniquake-optimization-baseline-printslowframes-function-printslowframes-minimummilliseconds-src-miniquake-optimization-baseline-ml-582699211"></a>
### printSlowFrames

```ml
function printSlowFrames(minimumMilliseconds)
```

Print the stage breakdown for frames at or above the requested duration.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `minimumMilliseconds` | `dynamic` | — | The minimum milliseconds input consumed by `printSlowFrames`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L384)

<a id="function-function-miniquake-optimization-baseline-printsummary-function-printsummary-mode-mapname-src-miniquake-optimization-baseline-ml-668179881"></a>
### printSummary

```ml
function printSummary(mode, mapName)
```

Format and emit summary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — | The mode input consumed by `printSummary`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L364)

<a id="global-global-miniquake-optimization-baseline-profilecapacity-profilecapacity-src-miniquake-optimization-baseline-ml-151913417"></a>
### profileCapacity

```ml
profileCapacity
```

Tracks the module-level profile capacity state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L78)

<a id="global-global-miniquake-optimization-baseline-profiledurations-profiledurations-src-miniquake-optimization-baseline-ml-1525914365"></a>
### profileDurations

```ml
profileDurations
```

Tracks the module-level profile durations state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L88)

<a id="global-global-miniquake-optimization-baseline-profileenabled-profileenabled-src-miniquake-optimization-baseline-ml-1545940653"></a>
### profileEnabled

```ml
profileEnabled
```

Tracks the module-level profile enabled state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L76)

<a id="global-global-miniquake-optimization-baseline-profileframeactive-profileframeactive-src-miniquake-optimization-baseline-ml-968738461"></a>
### profileFrameActive

```ml
profileFrameActive
```

Tracks the module-level profile frame active state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L86)

<a id="global-global-miniquake-optimization-baseline-profileframecount-profileframecount-src-miniquake-optimization-baseline-ml-928815169"></a>
### profileFrameCount

```ml
profileFrameCount
```

Tracks the module-level profile frame count state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L80)

<a id="global-global-miniquake-optimization-baseline-profileframestart-profileframestart-src-miniquake-optimization-baseline-ml-854796797"></a>
### profileFrameStart

```ml
profileFrameStart
```

Tracks the module-level profile frame start state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L82)

<a id="global-global-miniquake-optimization-baseline-profilelasttick-profilelasttick-src-miniquake-optimization-baseline-ml-1822245157"></a>
### profileLastTick

```ml
profileLastTick
```

Tracks the module-level profile last tick state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L84)

<a id="global-global-miniquake-optimization-baseline-profilestageframes-profilestageframes-src-miniquake-optimization-baseline-ml-93360119"></a>
### profileStageFrames

```ml
profileStageFrames
```

Tracks the module-level profile stage frames state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L94)

<a id="global-global-miniquake-optimization-baseline-profilestagehits-profilestagehits-src-miniquake-optimization-baseline-ml-753287939"></a>
### profileStageHits

```ml
profileStageHits
```

Tracks the module-level profile stage hits state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L92)

<a id="global-global-miniquake-optimization-baseline-profilestagetotals-profilestagetotals-src-miniquake-optimization-baseline-ml-466672477"></a>
### profileStageTotals

```ml
profileStageTotals
```

Tracks the module-level profile stage totals state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L90)

<a id="function-function-miniquake-optimization-baseline-recordedframes-function-recordedframes-src-miniquake-optimization-baseline-ml-1216306237"></a>
### recordedFrames

```ml
function recordedFrames()
```

Implements the `recordedFrames` operation for `miniquake.optimization_baseline` (recorded frames).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L223)

<a id="function-function-miniquake-optimization-baseline-resourcejson-function-resourcejson-values-src-miniquake-optimization-baseline-ml-1812730103"></a>
### resourceJson

```ml
function resourceJson(values)
```

Implements the `resourceJson` operation for `miniquake.optimization_baseline` (resource json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `resourceJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L301)

<a id="function-function-miniquake-optimization-baseline-sorteddurations-function-sorteddurations-src-miniquake-optimization-baseline-ml-278953149"></a>
### sortedDurations

```ml
function sortedDurations()
```

Implements the `sortedDurations` operation for `miniquake.optimization_baseline` (sorted durations).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L228)

<a id="constant-constant-miniquake-optimization-baseline-stage-count-const-stage-count-46-src-miniquake-optimization-baseline-ml-1000487114"></a>
### STAGE_COUNT

```ml
const STAGE_COUNT = 46
```

Defines the stage count value used by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L16)

<a id="function-function-miniquake-optimization-baseline-stageindex-function-stageindex-stage-src-miniquake-optimization-baseline-ml-558701255"></a>
### stageIndex

```ml
function stageIndex(stage)
```

Return stage index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stage` | `dynamic` | — | The stage input consumed by `stageIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L119)

<a id="global-global-miniquake-optimization-baseline-stagelookupkeys-stagelookupkeys-src-miniquake-optimization-baseline-ml-220429697"></a>
### stageLookupKeys

```ml
stageLookupKeys
```

Tracks the module-level stage lookup keys state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L71)

<a id="global-global-miniquake-optimization-baseline-stagelookupvalues-stagelookupvalues-src-miniquake-optimization-baseline-ml-1506333277"></a>
### stageLookupValues

```ml
stageLookupValues
```

Tracks the module-level stage lookup values state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L73)

<a id="global-global-miniquake-optimization-baseline-stagenames-stagenames-src-miniquake-optimization-baseline-ml-174669665"></a>
### stageNames

```ml
stageNames
```

Tracks the module-level stage names state owned by `miniquake.optimization_baseline`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L21)

<a id="function-function-miniquake-optimization-baseline-stagetotalsjson-function-stagetotalsjson-src-miniquake-optimization-baseline-ml-1091297639"></a>
### stageTotalsJson

```ml
function stageTotalsJson()
```

Implements the `stageTotalsJson` operation for `miniquake.optimization_baseline` (stage totals json).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L286)

<a id="function-function-miniquake-optimization-baseline-summary-function-summary-src-miniquake-optimization-baseline-ml-1656015525"></a>
### summary

```ml
function summary()
```

Return summary derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L263)

<a id="function-function-miniquake-optimization-baseline-writereports-function-writereports-prefix-mode-mapname-beforeresources-afterresources-src-miniquake-optimization-baseline-ml-1786720670"></a>
### writeReports

```ml
function writeReports(prefix, mode, mapName, beforeResources, afterResources)
```

Encode and write reports.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — | The prefix input consumed by `writeReports`. |
| `mode` | `dynamic` | — | The mode input consumed by `writeReports`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `beforeResources` | `dynamic` | — | The before resources input consumed by `writeReports`. |
| `afterResources` | `dynamic` | — | The after resources input consumed by `writeReports`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/optimization_baseline.ml#L318)
