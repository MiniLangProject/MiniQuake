# `src/miniquake/audio.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.audio`](Package-miniquake-audio-202110339.md)

Reachable from entry: **yes**

## Imports

- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-audio-capacity-function-capacity-state-src-miniquake-audio-ml-2138343936"></a>
### capacity

```ml
function capacity(state)
```

Return the backend queue capacity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `capacity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L92)

<a id="function-function-miniquake-audio-close-function-close-state-src-miniquake-audio-ml-1663011820"></a>
### close

```ml
function close(state)
```

Implements the `close` operation for `miniquake.audio` (close).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `close`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L99)

<a id="function-function-miniquake-audio-completed-function-completed-state-src-miniquake-audio-ml-1924084946"></a>
### completed

```ml
function completed(state)
```

Return completed for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `completed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L71)

<a id="function-function-miniquake-audio-create-function-create-src-miniquake-audio-ml-1999770927"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.audio` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L14)

<a id="function-function-miniquake-audio-headerstate-function-headerstate-state-index-src-miniquake-audio-ml-1291582556"></a>
### headerState

```ml
function headerState(state, index)
```

Return header state derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `headerState`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L85)

<a id="function-function-miniquake-audio-open-function-open-state-rate-channels-width-src-miniquake-audio-ml-1057182770"></a>
### open

```ml
function open(state, rate, channels, width)
```

Implements the `open` operation for `miniquake.audio` (open).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `open`. |
| `rate` | `dynamic` | — | Sample or update rate used by the operation. |
| `channels` | `dynamic` | — | Number of interleaved audio channels. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L23)

<a id="function-function-miniquake-audio-position-function-position-state-samplemask-src-miniquake-audio-ml-993403646"></a>
### position

```ml
function position(state, sampleMask)
```

Return the current backend playback position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `position`. |
| `sampleMask` | `dynamic` | — | The sample mask input consumed by `position`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L57)

<a id="function-function-miniquake-audio-queued-function-queued-state-src-miniquake-audio-ml-1180919144"></a>
### queued

```ml
function queued(state)
```

Add state for queued.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `queued`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L42)

<a id="function-function-miniquake-audio-reset-function-reset-state-src-miniquake-audio-ml-1831155482"></a>
### reset

```ml
function reset(state)
```

Implements the `reset` operation for `miniquake.audio` (reset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `reset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L49)

<a id="function-function-miniquake-audio-submit-function-submit-state-data-src-miniquake-audio-ml-796509084"></a>
### submit

```ml
function submit(state, data)
```

Submit state for submit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `submit`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L35)

<a id="function-function-miniquake-audio-submitted-function-submitted-state-src-miniquake-audio-ml-2034062478"></a>
### submitted

```ml
function submitted(state)
```

Return the number of buffers submitted to the backend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `submitted`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L64)

<a id="function-function-miniquake-audio-underruns-function-underruns-state-src-miniquake-audio-ml-456450436"></a>
### underruns

```ml
function underruns(state)
```

Return underruns for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.audio` state used by `underruns`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio.ml#L78)
