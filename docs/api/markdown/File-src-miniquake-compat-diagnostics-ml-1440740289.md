# `src/miniquake/compat_diagnostics.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.compat_diagnostics`](Package-miniquake-compat-diagnostics-179007218.md)

Reachable from entry: **yes**

## Imports

- `miniquake/build_info.ml` as `buildInfo` → [src/miniquake/build_info.ml](File-src-miniquake-build-info-ml-1156326101.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/optimization_baseline.ml` as `optBaseline` → [src/miniquake/optimization_baseline.ml](File-src-miniquake-optimization-baseline-ml-636998107.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-compat-diagnostics-activeedicts-function-activeedicts-session-src-miniquake-compat-diagnostics-ml-369109669"></a>
### activeEdicts

```ml
function activeEdicts(session)
```

Report whether active edicts holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `activeEdicts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L141)

<a id="function-function-miniquake-compat-diagnostics-activeserverclients-function-activeserverclients-session-src-miniquake-compat-diagnostics-ml-1290917259"></a>
### activeServerClients

```ml
function activeServerClients(session)
```

Report whether active server clients holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `activeServerClients`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L131)

<a id="function-function-miniquake-compat-diagnostics-beginframe-function-beginframe-session-src-miniquake-compat-diagnostics-ml-1416577093"></a>
### beginFrame

```ml
function beginFrame(session)
```

Initialize state for begin frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `beginFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L305)

<a id="function-function-miniquake-compat-diagnostics-booltext-function-booltext-value-src-miniquake-compat-diagnostics-ml-308257030"></a>
### boolText

```ml
function boolText(value)
```

Implements the `boolText` operation for `miniquake.compat_diagnostics` (bool text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `boolText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L24)

<a id="function-function-miniquake-compat-diagnostics-checkpoint-function-checkpoint-session-stage-src-miniquake-compat-diagnostics-ml-722905815"></a>
### checkpoint

```ml
function checkpoint(session, stage)
```

Checks point for `miniquake.compat_diagnostics`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `checkpoint`. |
| `stage` | `dynamic` | — | The stage input consumed by `checkpoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L317)

<a id="function-function-miniquake-compat-diagnostics-clientcontextjson-function-clientcontextjson-session-src-miniquake-compat-diagnostics-ml-8118809"></a>
### clientContextJson

```ml
function clientContextJson(session)
```

Implements the `clientContextJson` operation for `miniquake.compat_diagnostics` (client context json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `clientContextJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L218)

<a id="function-function-miniquake-compat-diagnostics-completeframe-function-completeframe-session-src-miniquake-compat-diagnostics-ml-1993085045"></a>
### completeFrame

```ml
function completeFrame(session)
```

Handle frame and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `completeFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L340)

<a id="constant-constant-miniquake-compat-diagnostics-context-schema-const-context-schema-1-src-miniquake-compat-diagnostics-ml-1559301033"></a>
### CONTEXT_SCHEMA

```ml
const CONTEXT_SCHEMA = 1
```

Defines the context schema value used by `miniquake.compat_diagnostics`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L20)

<a id="function-function-miniquake-compat-diagnostics-contextjson-function-contextjson-session-phase-errortext-src-miniquake-compat-diagnostics-ml-1938826467"></a>
### contextJson

```ml
function contextJson(session, phase, errorText)
```

Implements the `contextJson` operation for `miniquake.compat_diagnostics` (context json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `contextJson`. |
| `phase` | `dynamic` | — | The phase input consumed by `contextJson`. |
| `errorText` | `dynamic` | — | The error text input consumed by `contextJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L259)

<a id="function-function-miniquake-compat-diagnostics-f32hex-function-f32hex-value-src-miniquake-compat-diagnostics-ml-1515789194"></a>
### f32Hex

```ml
function f32Hex(value)
```

Implements the `f32Hex` operation for `miniquake.compat_diagnostics` (f32 hex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `f32Hex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L43)

<a id="function-function-miniquake-compat-diagnostics-failframe-function-failframe-session-message-src-miniquake-compat-diagnostics-ml-1359091674"></a>
### failFrame

```ml
function failFrame(session, message)
```

Report frame and return the corresponding failure status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `failFrame`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L359)

<a id="function-function-miniquake-compat-diagnostics-filteredframe-function-filteredframe-session-src-miniquake-compat-diagnostics-ml-1156967125"></a>
### filteredFrame

```ml
function filteredFrame(session)
```

Implements the `filteredFrame` operation for `miniquake.compat_diagnostics` (filtered frame).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `filteredFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L331)

<a id="function-function-miniquake-compat-diagnostics-hostcontextjson-function-hostcontextjson-session-src-miniquake-compat-diagnostics-ml-891871495"></a>
### hostContextJson

```ml
function hostContextJson(session)
```

The MiniLang Win64 backend reserves a bounded expression-temporary area. Keep serialized records as short, ordered appends instead of one very deep binary + tree. This preserves the BP-001 byte format while compiling safely.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `hostContextJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L192)

<a id="function-function-miniquake-compat-diagnostics-jsonescape-function-jsonescape-text-src-miniquake-compat-diagnostics-ml-1673362380"></a>
### jsonEscape

```ml
function jsonEscape(text)
```

Implements the `jsonEscape` operation for `miniquake.compat_diagnostics` (json escape).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L49)

<a id="function-function-miniquake-compat-diagnostics-jsonstring-function-jsonstring-text-src-miniquake-compat-diagnostics-ml-226733164"></a>
### jsonString

```ml
function jsonString(text)
```

Implements the `jsonString` operation for `miniquake.compat_diagnostics` (json string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L81)

<a id="function-function-miniquake-compat-diagnostics-laststage-function-laststage-session-src-miniquake-compat-diagnostics-ml-506884101"></a>
### lastStage

```ml
function lastStage(session)
```

Return last stage for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `lastStage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L182)

<a id="function-function-miniquake-compat-diagnostics-persist-function-persist-session-phase-errortext-src-miniquake-compat-diagnostics-ml-1083884853"></a>
### persist

```ml
function persist(session, phase, errorText)
```

Implements the `persist` operation for `miniquake.compat_diagnostics` (persist).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `persist`. |
| `phase` | `dynamic` | — | The phase input consumed by `persist`. |
| `errorText` | `dynamic` | — | The error text input consumed by `persist`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L283)

<a id="function-function-miniquake-compat-diagnostics-playercontextjson-function-playercontextjson-session-src-miniquake-compat-diagnostics-ml-1657756053"></a>
### playerContextJson

```ml
function playerContextJson(session)
```

Implements the `playerContextJson` operation for `miniquake.compat_diagnostics` (player context json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `playerContextJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L232)

<a id="function-function-miniquake-compat-diagnostics-postframestage-function-postframestage-session-stage-src-miniquake-compat-diagnostics-ml-514407223"></a>
### postFrameStage

```ml
function postFrameStage(session, stage)
```

Implements the `postFrameStage` operation for `miniquake.compat_diagnostics` (post frame stage).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `postFrameStage`. |
| `stage` | `dynamic` | — | The stage input consumed by `postFrameStage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L350)

<a id="function-function-miniquake-compat-diagnostics-qccalldepth-function-qccalldepth-session-src-miniquake-compat-diagnostics-ml-1033115867"></a>
### qcCallDepth

```ml
function qcCallDepth(session)
```

Implements the `qcCallDepth` operation for `miniquake.compat_diagnostics` (qc call depth).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `qcCallDepth`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L174)

<a id="function-function-miniquake-compat-diagnostics-qcfunctionname-function-qcfunctionname-session-src-miniquake-compat-diagnostics-ml-1758131073"></a>
### qcFunctionName

```ml
function qcFunctionName(session)
```

Return qc function name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `qcFunctionName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L155)

<a id="function-function-miniquake-compat-diagnostics-qcstatement-function-qcstatement-session-src-miniquake-compat-diagnostics-ml-685735919"></a>
### qcStatement

```ml
function qcStatement(session)
```

Implements the `qcStatement` operation for `miniquake.compat_diagnostics` (qc statement).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `qcStatement`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L166)

<a id="function-function-miniquake-compat-diagnostics-quakeccontextjson-function-quakeccontextjson-session-src-miniquake-compat-diagnostics-ml-1132243787"></a>
### quakeCContextJson

```ml
function quakeCContextJson(session)
```

Implements the `quakeCContextJson` operation for `miniquake.compat_diagnostics` (quake c context json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `quakeCContextJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L247)

<a id="function-function-miniquake-compat-diagnostics-servercontextjson-function-servercontextjson-session-src-miniquake-compat-diagnostics-ml-613643209"></a>
### serverContextJson

```ml
function serverContextJson(session)
```

Implements the `serverContextJson` operation for `miniquake.compat_diagnostics` (server context json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `serverContextJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L204)

<a id="function-function-miniquake-compat-diagnostics-stagejson-function-stagejson-stages-src-miniquake-compat-diagnostics-ml-320575424"></a>
### stageJson

```ml
function stageJson(stages)
```

Implements the `stageJson` operation for `miniquake.compat_diagnostics` (stage json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stages` | `dynamic` | — | The stages input consumed by `stageJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L118)

<a id="function-function-miniquake-compat-diagnostics-stagetext-function-stagetext-stages-src-miniquake-compat-diagnostics-ml-493544170"></a>
### stageText

```ml
function stageText(stages)
```

Implements the `stageText` operation for `miniquake.compat_diagnostics` (stage text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stages` | `dynamic` | — | The stages input consumed by `stageText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L105)

<a id="function-function-miniquake-compat-diagnostics-stagetraceenabled-inline-function-stagetraceenabled-session-src-miniquake-compat-diagnostics-ml-1688573292"></a>
### stageTraceEnabled

```ml
inline function stageTraceEnabled(session)
```

Report whether stage trace enabled holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `stageTraceEnabled`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L296)

<a id="function-function-miniquake-compat-diagnostics-u32hex-function-u32hex-value-src-miniquake-compat-diagnostics-ml-2076656354"></a>
### u32Hex

```ml
function u32Hex(value)
```

Implements the `u32Hex` operation for `miniquake.compat_diagnostics` (u32 hex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `u32Hex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L31)

<a id="function-function-miniquake-compat-diagnostics-vecjson-function-vecjson-value-src-miniquake-compat-diagnostics-ml-1610092194"></a>
### vecJson

```ml
function vecJson(value)
```

Implements the `vecJson` operation for `miniquake.compat_diagnostics` (vec json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `vecJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_diagnostics.ml#L87)
