# `src/miniquake/host_timing.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.host_timing`](Package-miniquake-host-timing-2060852668.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-host-timing-binary32-function-binary32-value-src-miniquake-host-timing-ml-1749938248"></a>
### binary32

```ml
function binary32(value)
```

Implements the `binary32` operation for `miniquake.host_timing` (binary32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `binary32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_timing.ml#L21)

<a id="function-function-miniquake-host-timing-create-function-create-src-miniquake-host-timing-ml-1429230629"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.host_timing` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_timing.ml#L15)

<a id="function-function-miniquake-host-timing-filter-function-filter-timing-elapsed-timedemo-forcedframerate-timescale-maxfps-src-miniquake-host-timing-ml-243662757"></a>
### filter

```ml
function filter(timing, elapsed, timedemo, forcedFrameRate, timeScale, maxFps)
```

Implements the `filter` operation for `miniquake.host_timing` (filter).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `timing` | `dynamic` | — | The timing input consumed by `filter`. |
| `elapsed` | `dynamic` | — | The elapsed input consumed by `filter`. |
| `timedemo` | `dynamic` | — | The timedemo input consumed by `filter`. |
| `forcedFrameRate` | `dynamic` | — | The forced frame rate input consumed by `filter`. |
| `timeScale` | `dynamic` | — | The time scale input consumed by `filter`. |
| `maxFps` | `dynamic` | — | The max fps input consumed by `filter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_timing.ml#L65)

<a id="function-function-miniquake-host-timing-filterabsolute-function-filterabsolute-timing-newrealtime-maxfps-forcedframerate-timedemo-timescale-src-miniquake-host-timing-ml-1865228030"></a>
### filterAbsolute

```ml
function filterAbsolute(timing, newRealtime, maxFps, forcedFrameRate, timedemo, timeScale)
```

Exact Host_FilterTime core.  WinQuake receives a float delta from the platform entry point, accumulates it in the double-precision realtime clock, filters against the unmodified oldRealtime value and only then updates the accepted frame time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `timing` | `dynamic` | — | The timing input consumed by `filterAbsolute`. |
| `newRealtime` | `dynamic` | — | Time value used by the operation. |
| `maxFps` | `dynamic` | — | The max fps input consumed by `filterAbsolute`. |
| `forcedFrameRate` | `dynamic` | — | The forced frame rate input consumed by `filterAbsolute`. |
| `timedemo` | `dynamic` | — | The timedemo input consumed by `filterAbsolute`. |
| `timeScale` | `dynamic` | — | The time scale input consumed by `filterAbsolute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_timing.ml#L35)

<a id="function-function-miniquake-host-timing-milliseconds-function-milliseconds-timing-src-miniquake-host-timing-ml-496179771"></a>
### milliseconds

```ml
function milliseconds(timing)
```

Implements the `milliseconds` operation for `miniquake.host_timing` (milliseconds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `timing` | `dynamic` | — | The timing input consumed by `milliseconds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_timing.ml#L81)
