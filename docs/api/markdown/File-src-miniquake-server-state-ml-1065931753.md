# `src/miniquake/server_state.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.server_state`](Package-miniquake-server-state-1630300138.md)

Reachable from entry: **no**

## Imports

- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-server-state-create-function-create-maxclients-src-miniquake-server-state-ml-399908915"></a>
### create

```ml
function create(maxClients)
```

Implements the `create` operation for `miniquake.server_state` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxClients` | `dynamic` | — | The max clients input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_state.ml#L15)

<a id="function-function-miniquake-server-state-frame-function-frame-state-deltatime-src-miniquake-server-state-ml-687421783"></a>
### frame

```ml
function frame(state, deltaTime)
```

Implements the `frame` operation for `miniquake.server_state` (frame).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.server_state` state used by `frame`. |
| `deltaTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_state.ml#L44)

<a id="function-function-miniquake-server-state-shutdown-function-shutdown-state-src-miniquake-server-state-ml-670215286"></a>
### shutdown

```ml
function shutdown(state)
```

Implements the `shutdown` operation for `miniquake.server_state` (shutdown).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.server_state` state used by `shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_state.ml#L34)

<a id="function-function-miniquake-server-state-spawn-function-spawn-state-mapname-src-miniquake-server-state-ml-1286637113"></a>
### spawn

```ml
function spawn(state, mapName)
```

Implements the `spawn` operation for `miniquake.server_state` (spawn).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.server_state` state used by `spawn`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/server_state.ml#L23)
