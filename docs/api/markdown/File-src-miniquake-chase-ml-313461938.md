# `src/miniquake/chase.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.chase`](Package-miniquake-chase-1762160059.md)

Reachable from entry: **yes**

## Imports

- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="constant-constant-miniquake-chase-chase-back-default-const-chase-back-default-100-src-miniquake-chase-ml-622269349"></a>
### CHASE_BACK_DEFAULT

```ml
const CHASE_BACK_DEFAULT = 100.
```

Defines the chase back default value used by `miniquake.chase`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L17)

<a id="function-function-miniquake-chase-chase-init-function-chase-init-registry-src-miniquake-chase-ml-1296521112"></a>
### Chase_Init

```ml
function Chase_Init(registry)
```

Chase_Init registers the same four non-archived, non-server cvars as MiniQuake and returns the value state used by the data-oriented MiniLang renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Chase_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L37)

<a id="function-function-miniquake-chase-chase-reset-function-chase-reset-state-src-miniquake-chase-ml-1682544156"></a>
### Chase_Reset

```ml
function Chase_Reset(state)
```

The original reset hook intentionally contains no state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.chase` state used by `Chase_Reset`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L58)

<a id="constant-constant-miniquake-chase-chase-right-default-const-chase-right-default-0-src-miniquake-chase-ml-43386312"></a>
### CHASE_RIGHT_DEFAULT

```ml
const CHASE_RIGHT_DEFAULT = 0.
```

Defines the chase right default value used by `miniquake.chase`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L21)

<a id="constant-constant-miniquake-chase-chase-up-default-const-chase-up-default-16-src-miniquake-chase-ml-649275063"></a>
### CHASE_UP_DEFAULT

```ml
const CHASE_UP_DEFAULT = 16.
```

Defines the chase up default value used by `miniquake.chase`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L19)

<a id="function-function-miniquake-chase-chase-update-function-chase-update-state-vieworigin-clientviewangles-worldmap-src-miniquake-chase-ml-958158903"></a>
### Chase_Update

```ml
function Chase_Update(state, viewOrigin, clientViewAngles, worldMap)
```

Mirror Quake's Chase_Update routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.chase` state used by `Chase_Update`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `Chase_Update`. |
| `clientViewAngles` | `dynamic` | — | The client view angles input consumed by `Chase_Update`. |
| `worldMap` | `dynamic` | — | The world map input consumed by `Chase_Update`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L107)

<a id="function-function-miniquake-chase-chase-updaterefdef-function-chase-updaterefdef-state-vieworigin-clientviewangles-renderviewangles-worldmap-src-miniquake-chase-ml-1272282778"></a>
### Chase_UpdateRefdef

```ml
function Chase_UpdateRefdef(state, viewOrigin, clientViewAngles, renderViewAngles, worldMap)
```

Returns [new view origin, new view angles, exact chase destination, impact]. cl.viewangles supplies the trace direction.  Original Chase_Update modifies only r_refdef.viewangles[PITCH]; yaw/roll, damage kick and idle sway survive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.chase` state used by `Chase_UpdateRefdef`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `Chase_UpdateRefdef`. |
| `clientViewAngles` | `dynamic` | — | The client view angles input consumed by `Chase_UpdateRefdef`. |
| `renderViewAngles` | `dynamic` | — | The render view angles input consumed by `Chase_UpdateRefdef`. |
| `worldMap` | `dynamic` | — | The world map input consumed by `Chase_UpdateRefdef`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L80)

<a id="function-function-miniquake-chase-commandneverexists-function-commandneverexists-name-src-miniquake-chase-ml-769747220"></a>
### commandNeverExists

```ml
function commandNeverExists(name)
```

Report whether command never exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L25)

<a id="function-function-miniquake-chase-create-function-create-src-miniquake-chase-ml-14839119"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.chase` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L30)

<a id="function-function-miniquake-chase-synccvars-function-synccvars-state-registry-src-miniquake-chase-ml-1048843283"></a>
### syncCvars

```ml
function syncCvars(state, registry)
```

Update module state for cvars.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.chase` state used by `syncCvars`. |
| `registry` | `dynamic` | — | The registry input consumed by `syncCvars`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L48)

<a id="function-function-miniquake-chase-traceline-function-traceline-worldmap-start-finish-src-miniquake-chase-ml-1828908806"></a>
### TraceLine

```ml
function TraceLine(worldMap, start, finish)
```

Implements the `TraceLine` operation for `miniquake.chase` (trace line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldMap` | `dynamic` | — | The world map input consumed by `TraceLine`. |
| `start` | `dynamic` | — | The start input consumed by `TraceLine`. |
| `finish` | `dynamic` | — | The finish input consumed by `TraceLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L66)

<a id="function-function-miniquake-chase-update-function-update-state-vieworigin-viewangles-src-miniquake-chase-ml-385799050"></a>
### update

```ml
function update(state, viewOrigin, viewAngles)
```

Existing convenience API retains its destination-only contract.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.chase` state used by `update`. |
| `viewOrigin` | `dynamic` | — | The view origin input consumed by `update`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `update`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/chase.ml#L115)
