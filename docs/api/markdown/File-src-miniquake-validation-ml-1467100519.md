# `src/miniquake/validation.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.validation`](Package-miniquake-validation-1607371976.md)

Reachable from entry: **no**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/render/world.ml` as `renderer` → [src/miniquake/render/world.ml](File-src-miniquake-render-world-ml-1647521183.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-validation-run-function-run-basedirectory-preferredmap-src-miniquake-validation-ml-864202160"></a>
### run

```ml
function run(baseDirectory, preferredMap)
```

Implements the `run` operation for `miniquake.validation` (run).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `preferredMap` | `dynamic` | — | The preferred map input consumed by `run`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/validation.ml#L40)

<a id="function-function-miniquake-validation-validatemap-function-validatemap-filesystem-mapname-palette-src-miniquake-validation-ml-481257848"></a>
### validateMap

```ml
function validateMap(filesystem, mapName, palette)
```

Validate map and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `validateMap`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `palette` | `dynamic` | — | The palette input consumed by `validateMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/validation.ml#L21)
