# `src/miniquake/game_validation.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.game_validation`](Package-miniquake-game-validation-102502069.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/mdl.ml` as `mdl` → [src/miniquake/format/mdl.ml](File-src-miniquake-format-mdl-ml-1455458127.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/graphics_data.ml` as `graphicsData` → [src/miniquake/graphics_data.ml](File-src-miniquake-graphics-data-ml-1899344030.md)
- `miniquake/host.ml` as `host` → [src/miniquake/host.ml](File-src-miniquake-host-ml-652298408.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/sound/wav.ml` as `wav` → [src/miniquake/sound/wav.ml](File-src-miniquake-sound-wav-ml-1458929962.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-game-validation-append-inline-function-append-messages-level-text-src-miniquake-game-validation-ml-1525818971"></a>
### append

```ml
inline function append(messages, level, text)
```

Implements the `append` operation for `miniquake.game_validation` (append).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messages` | `dynamic` | — | The messages input consumed by `append`. |
| `level` | `dynamic` | — | The level input consumed by `append`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L28)

<a id="function-function-miniquake-game-validation-filesystemarguments-function-filesystemarguments-options-src-miniquake-game-validation-ml-473339877"></a>
### filesystemArguments

```ml
function filesystemArguments(options)
```

Implements the `filesystemArguments` operation for `miniquake.game_validation` (filesystem arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `dynamic` | — | The options input consumed by `filesystemArguments`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L34)

<a id="function-function-miniquake-game-validation-printreport-function-printreport-report-src-miniquake-game-validation-ml-2059968727"></a>
### printReport

```ml
function printReport(report)
```

Implements the `printReport` operation for `miniquake.game_validation` (print report).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `report` | `dynamic` | — | The report input consumed by `printReport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L346)

<a id="function-function-miniquake-game-validation-runtimearguments-function-runtimearguments-options-src-miniquake-game-validation-ml-647413755"></a>
### runtimeArguments

```ml
function runtimeArguments(options)
```

Runs time arguments for `miniquake.game_validation`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `dynamic` | — | The options input consumed by `runtimeArguments`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L68)

<a id="function-function-miniquake-game-validation-validate-function-validate-options-src-miniquake-game-validation-ml-344654439"></a>
### validate

```ml
function validate(options)
```

Implements the `validate` operation for `miniquake.game_validation` (validate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `dynamic` | — | The options input consumed by `validate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L274)

<a id="function-function-miniquake-game-validation-validategraphicsdata-function-validategraphicsdata-system-messages-src-miniquake-game-validation-ml-2091479322"></a>
### validateGraphicsData

```ml
function validateGraphicsData(system, messages)
```

Validate graphics data and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `validateGraphicsData`. |
| `messages` | `dynamic` | — | The messages input consumed by `validateGraphicsData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L133)

<a id="function-function-miniquake-game-validation-validateintegratedruntime-function-validateintegratedruntime-options-messages-src-miniquake-game-validation-ml-827680577"></a>
### validateIntegratedRuntime

```ml
function validateIntegratedRuntime(options, messages)
```

Validate integrated runtime and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `dynamic` | — | The options input consumed by `validateIntegratedRuntime`. |
| `messages` | `dynamic` | — | The messages input consumed by `validateIntegratedRuntime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L77)

<a id="function-function-miniquake-game-validation-validatemapdata-function-validatemapdata-system-options-messages-src-miniquake-game-validation-ml-478542244"></a>
### validateMapData

```ml
function validateMapData(system, options, messages)
```

Validate map data and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `validateMapData`. |
| `options` | `dynamic` | — | The options input consumed by `validateMapData`. |
| `messages` | `dynamic` | — | The messages input consumed by `validateMapData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L195)

<a id="function-function-miniquake-game-validation-validatemenusound-function-validatemenusound-system-messages-src-miniquake-game-validation-ml-1342236946"></a>
### validateMenuSound

```ml
function validateMenuSound(system, messages)
```

Validate menu sound and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `validateMenuSound`. |
| `messages` | `dynamic` | — | The messages input consumed by `validateMenuSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L255)

<a id="function-function-miniquake-game-validation-validateplayermodel-function-validateplayermodel-system-messages-src-miniquake-game-validation-ml-1769813690"></a>
### validatePlayerModel

```ml
function validatePlayerModel(system, messages)
```

Validate player model and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `validatePlayerModel`. |
| `messages` | `dynamic` | — | The messages input consumed by `validatePlayerModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L235)

<a id="function-function-miniquake-game-validation-validateprogramdata-function-validateprogramdata-system-messages-src-miniquake-game-validation-ml-791206694"></a>
### validateProgramData

```ml
function validateProgramData(system, messages)
```

Validate program data and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `validateProgramData`. |
| `messages` | `dynamic` | — | The messages input consumed by `validateProgramData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_validation.ml#L170)
