# `src/miniquake/runtime_validation.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.runtime_validation`](Package-miniquake-runtime-validation-553202321.md)

Reachable from entry: **yes**

## Imports

- `miniquake/host.ml` as `host` → [src/miniquake/host.ml](File-src-miniquake-host-ml-652298408.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-runtime-validation-append-inline-function-append-messages-level-text-src-miniquake-runtime-validation-ml-659321693"></a>
### append

```ml
inline function append(messages, level, text)
```

Implements the `append` operation for `miniquake.runtime_validation` (append).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messages` | `dynamic` | — | The messages input consumed by `append`. |
| `level` | `dynamic` | — | The level input consumed by `append`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/runtime_validation.ml#L19)

<a id="function-function-miniquake-runtime-validation-failedreport-function-failedreport-messages-mapname-cleanshutdown-src-miniquake-runtime-validation-ml-460861641"></a>
### failedReport

```ml
function failedReport(messages, mapName, cleanShutdown)
```

Implements the `failedReport` operation for `miniquake.runtime_validation` (failed report).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messages` | `dynamic` | — | The messages input consumed by `failedReport`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `cleanShutdown` | `dynamic` | — | The clean shutdown input consumed by `failedReport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/runtime_validation.ml#L43)

<a id="function-function-miniquake-runtime-validation-printreport-function-printreport-report-src-miniquake-runtime-validation-ml-58303673"></a>
### printReport

```ml
function printReport(report)
```

Implements the `printReport` operation for `miniquake.runtime_validation` (print report).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `report` | `dynamic` | — | The report input consumed by `printReport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/runtime_validation.ml#L192)

<a id="function-function-miniquake-runtime-validation-rendersurfacecount-function-rendersurfacecount-renderer-src-miniquake-runtime-validation-ml-767908332"></a>
### renderSurfaceCount

```ml
function renderSurfaceCount(renderer)
```

Render surface count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `renderer` | `dynamic` | — | Renderer instance or backend used for drawing. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/runtime_validation.ml#L34)

<a id="function-function-miniquake-runtime-validation-validate-function-validate-basedirectory-gamedirectory-mapname-framecount-src-miniquake-runtime-validation-ml-436571657"></a>
### validate

```ml
function validate(baseDirectory, gameDirectory, mapName, frameCount)
```

Implements the `validate` operation for `miniquake.runtime_validation` (validate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/runtime_validation.ml#L70)

<a id="function-function-miniquake-runtime-validation-worldfacecount-function-worldfacecount-worldmodel-src-miniquake-runtime-validation-ml-835184978"></a>
### worldFaceCount

```ml
function worldFaceCount(worldModel)
```

Validation runs headless by design, so video-owned objects are absent.  Keep all report bookkeeping void-safe and return zero for intentionally omitted renderer data instead of dereferencing a missing renderer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worldModel` | `dynamic` | — | The world model input consumed by `worldFaceCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/runtime_validation.ml#L27)
