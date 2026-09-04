# `src/miniquake/format/sprite.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.format.sprite`](Package-miniquake-format-sprite-1229760843.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-format-sprite-load-function-load-filename-src-miniquake-format-sprite-ml-12191807"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.format.sprite` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L134)

<a id="function-function-miniquake-format-sprite-mod-loadspriteframe-function-mod-loadspriteframe-data-offset-src-miniquake-format-sprite-ml-553641131"></a>
### Mod_LoadSpriteFrame

```ml
function Mod_LoadSpriteFrame(data, offset)
```

Mirror Quake's Mod_LoadSpriteFrame routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L33)

<a id="function-function-miniquake-format-sprite-mod-loadspritegroup-function-mod-loadspritegroup-data-offset-src-miniquake-format-sprite-ml-579147795"></a>
### Mod_LoadSpriteGroup

```ml
function Mod_LoadSpriteGroup(data, offset)
```

Mirror Quake's Mod_LoadSpriteGroup routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L40)

<a id="function-function-miniquake-format-sprite-mod-loadspritemodel-function-mod-loadspritemodel-data-filename-src-miniquake-format-sprite-ml-1399430073"></a>
### Mod_LoadSpriteModel

```ml
function Mod_LoadSpriteModel(data, filename)
```

Mirror Quake's Mod_LoadSpriteModel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L114)

<a id="function-function-miniquake-format-sprite-parse-function-parse-data-filename-src-miniquake-format-sprite-ml-1838830721"></a>
### parse

```ml
function parse(data, filename)
```

Implements the `parse` operation for `miniquake.format.sprite` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L84)

<a id="function-function-miniquake-format-sprite-parseframeset-function-parseframeset-data-offset-src-miniquake-format-sprite-ml-1488412737"></a>
### parseFrameSet

```ml
function parseFrameSet(data, offset)
```

Read and validate frame set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L69)

<a id="function-function-miniquake-format-sprite-parsesingleframe-function-parsesingleframe-data-offset-src-miniquake-format-sprite-ml-1570760505"></a>
### parseSingleFrame

```ml
function parseSingleFrame(data, offset)
```

Read and validate single frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L19)

<a id="function-function-miniquake-format-sprite-spriteframebounds-function-spriteframebounds-frame-src-miniquake-format-sprite-ml-1540126059"></a>
### spriteFrameBounds

```ml
function spriteFrameBounds(frame)
```

Implements the `spriteFrameBounds` operation for `miniquake.format.sprite` (sprite frame bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | The frame input consumed by `spriteFrameBounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L120)

<a id="function-function-miniquake-format-sprite-spritemodelbounds-function-spritemodelbounds-model-src-miniquake-format-sprite-ml-891903375"></a>
### spriteModelBounds

```ml
function spriteModelBounds(model)
```

Implements the `spriteModelBounds` operation for `miniquake.format.sprite` (sprite model bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/sprite.ml#L126)
