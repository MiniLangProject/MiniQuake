# `src/miniquake/world_hull.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.world_hull`](Package-miniquake-world-hull-1480008261.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-world-hull-createboxhull-function-createboxhull-mins-maxs-src-miniquake-world-hull-ml-425617523"></a>
### createBoxHull

```ml
function createBoxHull(mins, maxs)
```

Create and initialize box hull.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mins` | `dynamic` | — | The mins input consumed by `createBoxHull`. |
| `maxs` | `dynamic` | — | The maxs input consumed by `createBoxHull`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_hull.ml#L17)

<a id="function-function-miniquake-world-hull-emptyplane-function-emptyplane-src-miniquake-world-hull-ml-776995621"></a>
### emptyPlane

```ml
function emptyPlane()
```

Implements the `emptyPlane` operation for `miniquake.world_hull` (empty plane).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_hull.ml#L75)

<a id="function-function-miniquake-world-hull-inside-function-inside-box-point-src-miniquake-world-hull-ml-167525522"></a>
### inside

```ml
function inside(box, point)
```

Implements the `inside` operation for `miniquake.world_hull` (inside).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `box` | `dynamic` | — | The box input consumed by `inside`. |
| `point` | `dynamic` | — | The point input consumed by `inside`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_hull.ml#L24)

<a id="function-function-miniquake-world-hull-pointcontentsfromnode-function-pointcontentsfromnode-box-number-point-src-miniquake-world-hull-ml-1578056819"></a>
### pointContentsFromNode

```ml
function pointContentsFromNode(box, number, point)
```

Implements the `pointContentsFromNode` operation for `miniquake.world_hull` (point contents from node).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `box` | `dynamic` | — | The box input consumed by `pointContentsFromNode`. |
| `number` | `dynamic` | — | The number input consumed by `pointContentsFromNode`. |
| `point` | `dynamic` | — | The point input consumed by `pointContentsFromNode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_hull.ml#L44)

<a id="function-function-miniquake-world-hull-traceline-function-traceline-box-start-finish-src-miniquake-world-hull-ml-1839708471"></a>
### traceLine

```ml
function traceLine(box, start, finish)
```

Implements the `traceLine` operation for `miniquake.world_hull` (trace line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `box` | `dynamic` | — | The box input consumed by `traceLine`. |
| `start` | `dynamic` | — | The start input consumed by `traceLine`. |
| `finish` | `dynamic` | — | The finish input consumed by `traceLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_hull.ml#L83)

<a id="function-function-miniquake-world-hull-truepointcontents-function-truepointcontents-box-point-src-miniquake-world-hull-ml-1315602806"></a>
### truePointContents

```ml
function truePointContents(box, point)
```

Implements the `truePointContents` operation for `miniquake.world_hull` (true point contents).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `box` | `dynamic` | — | The box input consumed by `truePointContents`. |
| `point` | `dynamic` | — | The point input consumed by `truePointContents`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_hull.ml#L35)
