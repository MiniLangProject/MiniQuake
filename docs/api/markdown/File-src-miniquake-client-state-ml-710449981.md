# `src/miniquake/client_state.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.client_state`](Package-miniquake-client-state-1803307254.md)

Reachable from entry: **no**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-client-state-clear-function-clear-state-src-miniquake-client-state-ml-2135579260"></a>
### clear

```ml
function clear(state)
```

Implements the `clear` operation for `miniquake.client_state` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.client_state` state used by `clear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_state.ml#L26)

<a id="function-function-miniquake-client-state-create-function-create-src-miniquake-client-state-ml-765167749"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.client_state` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_state.ml#L20)

<a id="function-function-miniquake-client-state-queueevent-function-queueevent-state-event-src-miniquake-client-state-ml-816188836"></a>
### queueEvent

```ml
function queueEvent(state, event)
```

Add state for queue event.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.client_state` state used by `queueEvent`. |
| `event` | `dynamic` | — | Runtime event to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_state.ml#L39)

<a id="function-function-miniquake-client-state-zerostats-function-zerostats-count-src-miniquake-client-state-ml-1922022042"></a>
### zeroStats

```ml
function zeroStats(count)
```

Create the zero-initialized state for stats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/client_state.ml#L15)
