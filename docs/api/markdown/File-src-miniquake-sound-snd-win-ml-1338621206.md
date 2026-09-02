# `src/miniquake/sound/snd_win.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.snd_win`](Package-miniquake-sound-snd-win-1781268586.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-sound-snd-win-completeheaders-function-completeheaders-state-count-src-miniquake-sound-snd-win-ml-1651246696"></a>
### completeHeaders

```ml
function completeHeaders(state, count)
```

Handle headers and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `completeHeaders`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L211)

<a id="function-function-miniquake-sound-snd-win-completeoneheader-function-completeoneheader-state-src-miniquake-sound-snd-win-ml-958731995"></a>
### completeOneHeader

```ml
function completeOneHeader(state)
```

Handle one header and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `completeOneHeader`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L196)

<a id="function-function-miniquake-sound-snd-win-copysubmission-function-copysubmission-state-data-header-src-miniquake-sound-snd-win-ml-184030234"></a>
### copySubmission

```ml
function copySubmission(state, data, header)
```

Transfer data for copy submission.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `copySubmission`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `header` | `dynamic` | — | The header input consumed by `copySubmission`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L373)

<a id="function-function-miniquake-sound-snd-win-create-function-create-simulated-samplerate-src-miniquake-sound-snd-win-ml-1812287288"></a>
### create

```ml
function create(simulated, sampleRate)
```

Implements the `create` operation for `miniquake.sound.snd_win` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `simulated` | `dynamic` | — | The simulated input consumed by `create`. |
| `sampleRate` | `dynamic` | — | The sample rate input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L121)

<a id="function-function-miniquake-sound-snd-win-createheaders-function-createheaders-src-miniquake-sound-snd-win-ml-1901182766"></a>
### createHeaders

```ml
function createHeaders()
```

Create and initialize headers.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L108)

<a id="function-function-miniquake-sound-snd-win-freesound-function-freesound-state-src-miniquake-sound-snd-win-ml-1276537113"></a>
### FreeSound

```ml
function FreeSound(state)
```

Release state for free sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `FreeSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L265)

<a id="function-function-miniquake-sound-snd-win-hasargument-function-hasargument-arguments-wanted-src-miniquake-sound-snd-win-ml-1544602427"></a>
### hasArgument

```ml
function hasArgument(arguments, wanted)
```

Report whether argument.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `wanted` | `dynamic` | — | The wanted input consumed by `hasArgument`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L158)

<a id="function-function-miniquake-sound-snd-win-nextheader-function-nextheader-state-src-miniquake-sound-snd-win-ml-131301931"></a>
### nextHeader

```ml
function nextHeader(state)
```

Return next header for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `nextHeader`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L365)

<a id="function-function-miniquake-sound-snd-win-prepareheaders-function-prepareheaders-state-src-miniquake-sound-snd-win-ml-335693167"></a>
### prepareHeaders

```ml
function prepareHeaders(state)
```

Implements the `prepareHeaders` operation for `miniquake.sound.snd_win` (prepare headers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `prepareHeaders`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L168)

<a id="function-function-miniquake-sound-snd-win-queuedheaders-function-queuedheaders-state-src-miniquake-sound-snd-win-ml-707714313"></a>
### queuedHeaders

```ml
function queuedHeaders(state)
```

Add state for queued headers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `queuedHeaders`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L232)

<a id="function-function-miniquake-sound-snd-win-refreshnativeheaders-function-refreshnativeheaders-state-src-miniquake-sound-snd-win-ml-1020189311"></a>
### refreshNativeHeaders

```ml
function refreshNativeHeaders(state)
```

Implements the `refreshNativeHeaders` operation for `miniquake.sound.snd_win` (refresh native headers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `refreshNativeHeaders`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L221)

<a id="function-function-miniquake-sound-snd-win-s-blocksound-function-s-blocksound-state-src-miniquake-sound-snd-win-ml-142655471"></a>
### S_BlockSound

```ml
function S_BlockSound(state)
```

Apply the Quake-compatible s block sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `S_BlockSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L241)

<a id="function-function-miniquake-sound-snd-win-s-unblocksound-function-s-unblocksound-state-src-miniquake-sound-snd-win-ml-1194465995"></a>
### S_UnblockSound

```ml
function S_UnblockSound(state)
```

Apply the Quake-compatible s unblock sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `S_UnblockSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L258)

<a id="constant-constant-miniquake-sound-snd-win-secondary-buffer-size-const-secondary-buffer-size-65536-src-miniquake-sound-snd-win-ml-70313208"></a>
### SECONDARY_BUFFER_SIZE

```ml
const SECONDARY_BUFFER_SIZE = 65536
```

Defines the secondary buffer size value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L27)

<a id="constant-constant-miniquake-sound-snd-win-sis-failure-const-sis-failure-1-src-miniquake-sound-snd-win-ml-88251574"></a>
### SIS_FAILURE

```ml
const SIS_FAILURE = 1
```

Defines the sis failure value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L16)

<a id="constant-constant-miniquake-sound-snd-win-sis-notavail-const-sis-notavail-2-src-miniquake-sound-snd-win-ml-2112230299"></a>
### SIS_NOTAVAIL

```ml
const SIS_NOTAVAIL = 2
```

Defines the sis notavail value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L18)

<a id="constant-constant-miniquake-sound-snd-win-sis-success-const-sis-success-0-src-miniquake-sound-snd-win-ml-703505999"></a>
### SIS_SUCCESS

```ml
const SIS_SUCCESS = 0
```

Defines the sis success value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L14)

<a id="function-function-miniquake-sound-snd-win-snddma-getdmapos-function-snddma-getdmapos-state-src-miniquake-sound-snd-win-ml-588492083"></a>
### SNDDMA_GetDMAPos

```ml
function SNDDMA_GetDMAPos(state)
```

Mirror Quake's SNDDMA_GetDMAPos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `SNDDMA_GetDMAPos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L352)

<a id="function-function-miniquake-sound-snd-win-snddma-init-function-snddma-init-state-arguments-src-miniquake-sound-snd-win-ml-322650337"></a>
### SNDDMA_Init

```ml
function SNDDMA_Init(state, arguments)
```

Mirror Quake's SNDDMA_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `SNDDMA_Init`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L321)

<a id="function-function-miniquake-sound-snd-win-snddma-initdirect-function-snddma-initdirect-state-src-miniquake-sound-snd-win-ml-1643830285"></a>
### SNDDMA_InitDirect

```ml
function SNDDMA_InitDirect(state)
```

Mirror Quake's SNDDMA_InitDirect routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `SNDDMA_InitDirect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L280)

<a id="function-function-miniquake-sound-snd-win-snddma-initwav-function-snddma-initwav-state-src-miniquake-sound-snd-win-ml-377891875"></a>
### SNDDMA_InitWav

```ml
function SNDDMA_InitWav(state)
```

Mirror Quake's SNDDMA_InitWav routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `SNDDMA_InitWav`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L291)

<a id="function-function-miniquake-sound-snd-win-snddma-shutdown-function-snddma-shutdown-state-src-miniquake-sound-snd-win-ml-2052652215"></a>
### SNDDMA_Shutdown

```ml
function SNDDMA_Shutdown(state)
```

Mirror Quake's SNDDMA_Shutdown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `SNDDMA_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L431)

<a id="function-function-miniquake-sound-snd-win-snddma-submit-function-snddma-submit-state-data-src-miniquake-sound-snd-win-ml-898373487"></a>
### SNDDMA_Submit

```ml
function SNDDMA_Submit(state, data)
```

Mirror Quake's SNDDMA_Submit routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `SNDDMA_Submit`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L396)

<a id="function-function-miniquake-sound-snd-win-unprepareheaders-function-unprepareheaders-state-src-miniquake-sound-snd-win-ml-165975855"></a>
### unprepareHeaders

```ml
function unprepareHeaders(state)
```

Implements the `unprepareHeaders` operation for `miniquake.sound.snd_win` (unprepare headers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_win` state used by `unprepareHeaders`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L183)

<a id="constant-constant-miniquake-sound-snd-win-wav-buffer-size-const-wav-buffer-size-1024-src-miniquake-sound-snd-win-ml-495638054"></a>
### WAV_BUFFER_SIZE

```ml
const WAV_BUFFER_SIZE = 1024
```

Defines the wav buffer size value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L25)

<a id="constant-constant-miniquake-sound-snd-win-wav-buffers-const-wav-buffers-64-src-miniquake-sound-snd-win-ml-967485841"></a>
### WAV_BUFFERS

```ml
const WAV_BUFFERS = 64
```

Defines the wav buffers value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L21)

<a id="constant-constant-miniquake-sound-snd-win-wav-mask-const-wav-mask-63-src-miniquake-sound-snd-win-ml-584724278"></a>
### WAV_MASK

```ml
const WAV_MASK = 63
```

Defines the wav mask value used by `miniquake.sound.snd_win`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_win.ml#L23)

- [miniquake.sound.snd_win.WaveHeader](Type-miniquake-sound-snd-win-waveheader-1240473856.md) — struct
- [miniquake.sound.snd_win.WindowsSoundState](Type-miniquake-sound-snd-win-windowssoundstate-1218098421.md) — struct
