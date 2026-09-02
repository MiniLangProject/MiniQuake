# `src/miniquake/compat_trace.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.compat_trace`](Package-miniquake-compat-trace-1517427143.md)

Reachable from entry: **yes**

## Imports

- `miniquake/build_info.ml` as `buildInfo` → [src/miniquake/build_info.ml](File-src-miniquake-build-info-ml-1156326101.md)
- `miniquake/compat_diagnostics.ml` as `diagnostics` → [src/miniquake/compat_diagnostics.ml](File-src-miniquake-compat-diagnostics-ml-1440740289.md)
- `miniquake/host.ml` as `host` → [src/miniquake/host.ml](File-src-miniquake-host-ml-652298408.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-compat-trace-appendfile-function-appendfile-path-text-src-miniquake-compat-trace-ml-1429706121"></a>
### appendFile

```ml
function appendFile(path, text)
```

Add state for append file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L598)

<a id="function-function-miniquake-compat-trace-attemptshutdown-function-attemptshutdown-session-src-miniquake-compat-trace-ml-969943349"></a>
### attemptShutdown

```ml
function attemptShutdown(session)
```

Update subsystem state for attempt shutdown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `attemptShutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L617)

<a id="function-function-miniquake-compat-trace-boolnumber-function-boolnumber-value-src-miniquake-compat-trace-ml-1460733380"></a>
### boolNumber

```ml
function boolNumber(value)
```

Return bool number derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `boolNumber`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L28)

<a id="function-function-miniquake-compat-trace-canonicalframe-function-canonicalframe-session-frameindex-accepted-src-miniquake-compat-trace-ml-1538318309"></a>
### canonicalFrame

```ml
function canonicalFrame(session, frameIndex, accepted)
```

BP-001 originally expressed the complete frame as one deeply nested + tree. The Win64 backend has a bounded expression-temporary area, so keep every canonical field in the same order but append it in compiler-safe statements.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `canonicalFrame`. |
| `frameIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `accepted` | `dynamic` | — | The accepted input consumed by `canonicalFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L297)

<a id="function-function-miniquake-compat-trace-cliententitieshash-function-cliententitieshash-session-src-miniquake-compat-trace-ml-512811811"></a>
### clientEntitiesHash

```ml
function clientEntitiesHash(session)
```

cl.entities is intentionally sparse.  SV_CreateBaseline omits non-model entities, while CL_EntityNum grows the array with void slots up to the next transmitted entity number.  Hash both the slot topology and the populated records without dereferencing void.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `clientEntitiesHash`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L238)

<a id="function-function-miniquake-compat-trace-cliententitiesjson-function-cliententitiesjson-session-src-miniquake-compat-trace-ml-1188591963"></a>
### clientEntitiesJson

```ml
function clientEntitiesJson(session)
```

Implements the `clientEntitiesJson` operation for `miniquake.compat_trace` (client entities json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `clientEntitiesJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L433)

<a id="function-function-miniquake-compat-trace-cliententityjson-function-cliententityjson-item-src-miniquake-compat-trace-ml-270110224"></a>
### clientEntityJson

```ml
function clientEntityJson(item)
```

Implements the `clientEntityJson` operation for `miniquake.compat_trace` (client entity json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `clientEntityJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L418)

<a id="function-function-miniquake-compat-trace-containstext-function-containstext-text-needle-src-miniquake-compat-trace-ml-1453530009"></a>
### containsText

```ml
function containsText(text, needle)
```

Implements the `containsText` operation for `miniquake.compat_trace` (contains text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `needle` | `dynamic` | — | The needle input consumed by `containsText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L895)

<a id="function-function-miniquake-compat-trace-edictjson-function-edictjson-session-index-item-src-miniquake-compat-trace-ml-769467574"></a>
### edictJson

```ml
function edictJson(session, index, item)
```

Implements the `edictJson` operation for `miniquake.compat_trace` (edict json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `edictJson`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `item` | `dynamic` | — | The item input consumed by `edictJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L378)

<a id="function-function-miniquake-compat-trace-edictsjson-function-edictsjson-session-src-miniquake-compat-trace-ml-2023533323"></a>
### edictsJson

```ml
function edictsJson(session)
```

Implements the `edictsJson` operation for `miniquake.compat_trace` (edicts json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `edictsJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L402)

<a id="constant-constant-miniquake-compat-trace-fnv-offset-const-fnv-offset-2166136261-src-miniquake-compat-trace-ml-151820508"></a>
### FNV_OFFSET

```ml
const FNV_OFFSET = 2166136261
```

Defines the fnv offset value used by `miniquake.compat_trace`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L22)

<a id="constant-constant-miniquake-compat-trace-fnv-prime-const-fnv-prime-16777619-src-miniquake-compat-trace-ml-194496268"></a>
### FNV_PRIME

```ml
const FNV_PRIME = 16777619
```

Defines the fnv prime value used by `miniquake.compat_trace`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L24)

<a id="function-function-miniquake-compat-trace-globalshash-function-globalshash-session-src-miniquake-compat-trace-ml-1774653227"></a>
### globalsHash

```ml
function globalsHash(session)
```

Implements the `globalsHash` operation for `miniquake.compat_trace` (globals hash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `globalsHash`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L160)

<a id="function-function-miniquake-compat-trace-hashbyte-inline-function-hashbyte-state-value-src-miniquake-compat-trace-ml-759555644"></a>
### hashByte

```ml
inline function hashByte(state, value)
```

Returns whether `miniquake.compat_trace` has h byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.compat_trace` state used by `hashByte`. |
| `value` | `dynamic` | — | Value consumed by `hashByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L50)

<a id="function-function-miniquake-compat-trace-hashfloat-function-hashfloat-state-value-src-miniquake-compat-trace-ml-1948787251"></a>
### hashFloat

```ml
function hashFloat(state, value)
```

Fold float into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.compat_trace` state used by `hashFloat`. |
| `value` | `dynamic` | — | Value consumed by `hashFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L69)

<a id="function-function-miniquake-compat-trace-hashsizebuffer-function-hashsizebuffer-state-buffer-src-miniquake-compat-trace-ml-857341986"></a>
### hashSizeBuffer

```ml
function hashSizeBuffer(state, buffer)
```

Fold size buffer into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.compat_trace` state used by `hashSizeBuffer`. |
| `buffer` | `dynamic` | — | The buffer input consumed by `hashSizeBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L145)

<a id="function-function-miniquake-compat-trace-hashtext-function-hashtext-text-src-miniquake-compat-trace-ml-481991112"></a>
### hashText

```ml
function hashText(text)
```

Fold text into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L126)

<a id="function-function-miniquake-compat-trace-hashtextseed-function-hashtextseed-state-text-src-miniquake-compat-trace-ml-1247174385"></a>
### hashTextSeed

```ml
function hashTextSeed(state, text)
```

Fold text seed into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.compat_trace` state used by `hashTextSeed`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L113)

<a id="function-function-miniquake-compat-trace-hashvec3-function-hashvec3-state-value-label-src-miniquake-compat-trace-ml-2016197923"></a>
### hashVec3

```ml
function hashVec3(state, value, label)
```

Hash a Vec3 without keeping a heap object only inside a nested call expression.  This is deliberately allocation-free after the type check.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.compat_trace` state used by `hashVec3`. |
| `value` | `dynamic` | — | Value consumed by `hashVec3`. |
| `label` | `dynamic` | — | The label input consumed by `hashVec3`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L85)

<a id="function-function-miniquake-compat-trace-hashword-function-hashword-state-value-src-miniquake-compat-trace-ml-690038419"></a>
### hashWord

```ml
function hashWord(state, value)
```

Fold word into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.compat_trace` state used by `hashWord`. |
| `value` | `dynamic` | — | Value consumed by `hashWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L57)

<a id="function-function-miniquake-compat-trace-hashwordarray-function-hashwordarray-words-src-miniquake-compat-trace-ml-1479030490"></a>
### hashWordArray

```ml
function hashWordArray(words)
```

Fold word array into the deterministic rolling hash.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | The words input consumed by `hashWordArray`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L132)

<a id="function-function-miniquake-compat-trace-inspect-function-inspect-path-src-miniquake-compat-trace-ml-1010203056"></a>
### inspect

```ml
function inspect(path)
```

Implements the `inspect` operation for `miniquake.compat_trace` (inspect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L929)

<a id="function-function-miniquake-compat-trace-linecount-function-linecount-text-src-miniquake-compat-trace-ml-1431885294"></a>
### lineCount

```ml
function lineCount(text)
```

Return line count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L916)

<a id="function-function-miniquake-compat-trace-makeresult-function-makeresult-ok-requested-written-accepted-rollinghash-prefix-laststage-errortext-cleanshutdown-src-miniquake-compat-trace-ml-2031846506"></a>
### makeResult

```ml
function makeResult(ok, requested, written, accepted, rollingHash, prefix, lastStage, errorText, cleanShutdown)
```

Create and initialize result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ok` | `dynamic` | — | The ok input consumed by `makeResult`. |
| `requested` | `dynamic` | — | The requested input consumed by `makeResult`. |
| `written` | `dynamic` | — | The written input consumed by `makeResult`. |
| `accepted` | `dynamic` | — | The accepted input consumed by `makeResult`. |
| `rollingHash` | `dynamic` | — | The rolling hash input consumed by `makeResult`. |
| `prefix` | `dynamic` | — | The prefix input consumed by `makeResult`. |
| `lastStage` | `dynamic` | — | The last stage input consumed by `makeResult`. |
| `errorText` | `dynamic` | — | The error text input consumed by `makeResult`. |
| `cleanShutdown` | `dynamic` | — | The clean shutdown input consumed by `makeResult`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L667)

<a id="function-function-miniquake-compat-trace-printresult-function-printresult-result-src-miniquake-compat-trace-ml-1066634682"></a>
### printResult

```ml
function printResult(result)
```

Format and emit result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `result` | `dynamic` | — | Result value to report or translate into a status code. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L878)

<a id="function-function-miniquake-compat-trace-protocolhash-function-protocolhash-session-src-miniquake-compat-trace-ml-1896537599"></a>
### protocolHash

```ml
function protocolHash(session)
```

Implements the `protocolHash` operation for `miniquake.compat_trace` (protocol hash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `protocolHash`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L267)

<a id="function-function-miniquake-compat-trace-qcedictshash-function-qcedictshash-session-src-miniquake-compat-trace-ml-1500250815"></a>
### qcEdictsHash

```ml
function qcEdictsHash(session)
```

Implements the `qcEdictsHash` operation for `miniquake.compat_trace` (qc edicts hash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `qcEdictsHash`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L168)

<a id="function-function-miniquake-compat-trace-qcfunctionindex-function-qcfunctionindex-session-src-miniquake-compat-trace-ml-1122202283"></a>
### qcFunctionIndex

```ml
function qcFunctionIndex(session)
```

Return qc function index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `qcFunctionIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L42)

<a id="function-function-miniquake-compat-trace-rawedicthash-function-rawedicthash-session-index-src-miniquake-compat-trace-ml-2012366373"></a>
### rawEdictHash

```ml
function rawEdictHash(session, index)
```

Implements the `rawEdictHash` operation for `miniquake.compat_trace` (raw edict hash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `rawEdictHash`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L368)

<a id="function-function-miniquake-compat-trace-resourcejson-function-resourcejson-session-src-miniquake-compat-trace-ml-314956011"></a>
### resourceJson

```ml
function resourceJson(session)
```

Implements the `resourceJson` operation for `miniquake.compat_trace` (resource json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `resourceJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L452)

<a id="function-function-miniquake-compat-trace-run-function-run-basedirectory-gamedirectory-mapname-framecount-outputprefix-src-miniquake-compat-trace-ml-1102729872"></a>
### run

```ml
function run(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix)
```

No diagnostics-only failure may escape as an unclassified process exit. Convert unexpected propagation into a regular failed result and leave an emergency summary for the black-port feedback loop whenever possible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `run`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L854)

<a id="function-function-miniquake-compat-trace-runinternal-function-runinternal-basedirectory-gamedirectory-mapname-framecount-outputprefix-src-miniquake-compat-trace-ml-1668452246"></a>
### runInternal

```ml
function runInternal(baseDirectory, gameDirectory, mapName, frameCount, outputPrefix)
```

Execute internal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `outputPrefix` | `dynamic` | — | The output prefix input consumed by `runInternal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L690)

<a id="function-function-miniquake-compat-trace-safetext-function-safetext-value-src-miniquake-compat-trace-ml-304468652"></a>
### safeText

```ml
function safeText(value)
```

Return a validated safe text value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `safeText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L35)

<a id="function-function-miniquake-compat-trace-serveredictshash-function-serveredictshash-session-src-miniquake-compat-trace-ml-186018675"></a>
### serverEdictsHash

```ml
function serverEdictsHash(session)
```

Implements the `serverEdictsHash` operation for `miniquake.compat_trace` (server edicts hash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `serverEdictsHash`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L195)

<a id="function-function-miniquake-compat-trace-snapshotclientjson-function-snapshotclientjson-session-src-miniquake-compat-trace-ml-1608340659"></a>
### snapshotClientJson

```ml
function snapshotClientJson(session)
```

Implements the `snapshotClientJson` operation for `miniquake.compat_trace` (snapshot client json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotClientJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L504)

<a id="function-function-miniquake-compat-trace-snapshotdigestsjson-function-snapshotdigestsjson-session-src-miniquake-compat-trace-ml-1503268545"></a>
### snapshotDigestsJson

```ml
function snapshotDigestsJson(session)
```

Implements the `snapshotDigestsJson` operation for `miniquake.compat_trace` (snapshot digests json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotDigestsJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L549)

<a id="function-function-miniquake-compat-trace-snapshothostjson-function-snapshothostjson-session-src-miniquake-compat-trace-ml-338010367"></a>
### snapshotHostJson

```ml
function snapshotHostJson(session)
```

Implements the `snapshotHostJson` operation for `miniquake.compat_trace` (snapshot host json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotHostJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L478)

<a id="function-function-miniquake-compat-trace-snapshotjson-function-snapshotjson-session-frameindex-phase-errortext-src-miniquake-compat-trace-ml-1951636546"></a>
### snapshotJson

```ml
function snapshotJson(session, frameIndex, phase, errorText)
```

Implements the `snapshotJson` operation for `miniquake.compat_trace` (snapshot json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotJson`. |
| `frameIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `phase` | `dynamic` | — | The phase input consumed by `snapshotJson`. |
| `errorText` | `dynamic` | — | The error text input consumed by `snapshotJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L562)

<a id="function-function-miniquake-compat-trace-snapshotplayerjson-function-snapshotplayerjson-session-src-miniquake-compat-trace-ml-702697131"></a>
### snapshotPlayerJson

```ml
function snapshotPlayerJson(session)
```

Implements the `snapshotPlayerJson` operation for `miniquake.compat_trace` (snapshot player json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotPlayerJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L517)

<a id="function-function-miniquake-compat-trace-snapshotquakecjson-function-snapshotquakecjson-session-src-miniquake-compat-trace-ml-1209903983"></a>
### snapshotQuakeCJson

```ml
function snapshotQuakeCJson(session)
```

Implements the `snapshotQuakeCJson` operation for `miniquake.compat_trace` (snapshot quake c json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotQuakeCJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L536)

<a id="function-function-miniquake-compat-trace-snapshotserverjson-function-snapshotserverjson-session-src-miniquake-compat-trace-ml-1550208155"></a>
### snapshotServerJson

```ml
function snapshotServerJson(session)
```

Implements the `snapshotServerJson` operation for `miniquake.compat_trace` (snapshot server json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `snapshotServerJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L490)

<a id="function-function-miniquake-compat-trace-stageshash-function-stageshash-session-src-miniquake-compat-trace-ml-1132288191"></a>
### stagesHash

```ml
function stagesHash(session)
```

Implements the `stagesHash` operation for `miniquake.compat_trace` (stages hash).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `stagesHash`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L282)

<a id="function-function-miniquake-compat-trace-summaryjson-function-summaryjson-ok-requested-written-accepted-rollinghash-tracepath-snapshotpath-contextpath-laststage-errortext-cleanshutdown-diagnosticwriteerror-src-miniquake-compat-trace-ml-1591196441"></a>
### summaryJson

```ml
function summaryJson(ok, requested, written, accepted, rollingHash, tracePath, snapshotPath, contextPath, lastStage, errorText, cleanShutdown, diagnosticWriteError)
```

Implements the `summaryJson` operation for `miniquake.compat_trace` (summary json).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ok` | `dynamic` | — | The ok input consumed by `summaryJson`. |
| `requested` | `dynamic` | — | The requested input consumed by `summaryJson`. |
| `written` | `dynamic` | — | The written input consumed by `summaryJson`. |
| `accepted` | `dynamic` | — | The accepted input consumed by `summaryJson`. |
| `rollingHash` | `dynamic` | — | The rolling hash input consumed by `summaryJson`. |
| `tracePath` | `dynamic` | — | Filesystem path used by the operation. |
| `snapshotPath` | `dynamic` | — | Filesystem path used by the operation. |
| `contextPath` | `dynamic` | — | Filesystem path used by the operation. |
| `lastStage` | `dynamic` | — | The last stage input consumed by `summaryJson`. |
| `errorText` | `dynamic` | — | The error text input consumed by `summaryJson`. |
| `cleanShutdown` | `dynamic` | — | The clean shutdown input consumed by `summaryJson`. |
| `diagnosticWriteError` | `dynamic` | — | The diagnostic write error input consumed by `summaryJson`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L637)

<a id="constant-constant-miniquake-compat-trace-trace-schema-const-trace-schema-1-src-miniquake-compat-trace-ml-17812175"></a>
### TRACE_SCHEMA

```ml
const TRACE_SCHEMA = 1
```

Defines the trace schema value used by `miniquake.compat_trace`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L20)

<a id="function-function-miniquake-compat-trace-traceerrorline-function-traceerrorline-frameindex-laststage-message-src-miniquake-compat-trace-ml-524315263"></a>
### traceErrorLine

```ml
function traceErrorLine(frameIndex, lastStage, message)
```

Trace error line through the collision world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frameIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `lastStage` | `dynamic` | — | The last stage input consumed by `traceErrorLine`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L608)

<a id="function-function-miniquake-compat-trace-traceline-function-traceline-session-frameindex-accepted-src-miniquake-compat-trace-ml-2006778551"></a>
### traceLine

```ml
function traceLine(session, frameIndex, accepted)
```

Implements the `traceLine` operation for `miniquake.compat_trace` (trace line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | The session input consumed by `traceLine`. |
| `frameIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `accepted` | `dynamic` | — | The accepted input consumed by `traceLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L360)

<a id="function-function-miniquake-compat-trace-vec3error-function-vec3error-label-value-src-miniquake-compat-trace-ml-925097030"></a>
### vec3Error

```ml
function vec3Error(label, value)
```

Implements the `vec3Error` operation for `miniquake.compat_trace` (vec3 error).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `dynamic` | — | The label input consumed by `vec3Error`. |
| `value` | `dynamic` | — | Value consumed by `vec3Error`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L76)

<a id="function-function-miniquake-compat-trace-vec3hex-function-vec3hex-value-label-src-miniquake-compat-trace-ml-359097834"></a>
### vec3Hex

```ml
function vec3Hex(value, label)
```

Implements the `vec3Hex` operation for `miniquake.compat_trace` (vec3 hex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `vec3Hex`. |
| `label` | `dynamic` | — | The label input consumed by `vec3Hex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L99)

<a id="function-function-miniquake-compat-trace-writefile-function-writefile-path-text-src-miniquake-compat-trace-ml-302303483"></a>
### writeFile

```ml
function writeFile(path, text)
```

Encode and write file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/compat_trace.ml#L589)
