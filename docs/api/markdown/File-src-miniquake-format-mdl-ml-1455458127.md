# `src/miniquake/format/mdl.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.format.mdl`](Package-miniquake-format-mdl-1657484685.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-format-mdl-load-function-load-filename-src-miniquake-format-mdl-ml-857444993"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.format.mdl` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L312)

<a id="function-function-miniquake-format-mdl-mod-floodfillskin-function-mod-floodfillskin-skin-skinwidth-skinheight-src-miniquake-format-mdl-ml-1416158736"></a>
### Mod_FloodFillSkin

```ml
function Mod_FloodFillSkin(skin, skinWidth, skinHeight)
```

Mirror Quake's Mod_FloodFillSkin routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `skin` | `dynamic` | — | The skin input consumed by `Mod_FloodFillSkin`. |
| `skinWidth` | `dynamic` | — | The skin width input consumed by `Mod_FloodFillSkin`. |
| `skinHeight` | `dynamic` | — | The skin height input consumed by `Mod_FloodFillSkin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L47)

<a id="function-function-miniquake-format-mdl-mod-loadaliasframe-function-mod-loadaliasframe-data-offset-numvertices-src-miniquake-format-mdl-ml-246082962"></a>
### Mod_LoadAliasFrame

```ml
function Mod_LoadAliasFrame(data, offset, numVertices)
```

Mirror Quake's Mod_LoadAliasFrame routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `numVertices` | `dynamic` | — | The num vertices input consumed by `Mod_LoadAliasFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L159)

<a id="function-function-miniquake-format-mdl-mod-loadaliasgroup-function-mod-loadaliasgroup-data-offset-numvertices-src-miniquake-format-mdl-ml-846689894"></a>
### Mod_LoadAliasGroup

```ml
function Mod_LoadAliasGroup(data, offset, numVertices)
```

Mirror Quake's Mod_LoadAliasGroup routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `numVertices` | `dynamic` | — | The num vertices input consumed by `Mod_LoadAliasGroup`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L167)

<a id="function-function-miniquake-format-mdl-mod-loadaliasmodel-function-mod-loadaliasmodel-data-filename-src-miniquake-format-mdl-ml-734990701"></a>
### Mod_LoadAliasModel

```ml
function Mod_LoadAliasModel(data, filename)
```

Mirror Quake's Mod_LoadAliasModel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L306)

<a id="function-function-miniquake-format-mdl-mod-loadallskins-function-mod-loadallskins-data-offset-numskins-skinwidth-skinheight-src-miniquake-format-mdl-ml-2052380050"></a>
### Mod_LoadAllSkins

```ml
function Mod_LoadAllSkins(data, offset, numSkins, skinWidth, skinHeight)
```

Mirror Quake's Mod_LoadAllSkins routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `numSkins` | `dynamic` | — | The num skins input consumed by `Mod_LoadAllSkins`. |
| `skinWidth` | `dynamic` | — | The skin width input consumed by `Mod_LoadAllSkins`. |
| `skinHeight` | `dynamic` | — | The skin height input consumed by `Mod_LoadAllSkins`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L214)

<a id="function-function-miniquake-format-mdl-parse-function-parse-data-filename-src-miniquake-format-mdl-ml-2095057615"></a>
### parse

```ml
function parse(data, filename)
```

Implements the `parse` operation for `miniquake.format.mdl` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L230)

<a id="function-function-miniquake-format-mdl-parseframeset-function-parseframeset-data-offset-numvertices-src-miniquake-format-mdl-ml-1788165030"></a>
### parseFrameSet

```ml
function parseFrameSet(data, offset, numVertices)
```

Read and validate frame set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `numVertices` | `dynamic` | — | The num vertices input consumed by `parseFrameSet`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L196)

<a id="function-function-miniquake-format-mdl-parsesingleframe-function-parsesingleframe-data-offset-numvertices-src-miniquake-format-mdl-ml-1407923262"></a>
### parseSingleFrame

```ml
function parseSingleFrame(data, offset, numVertices)
```

Read and validate single frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `numVertices` | `dynamic` | — | The num vertices input consumed by `parseSingleFrame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L28)

<a id="function-function-miniquake-format-mdl-parseskin-function-parseskin-data-offset-skinwidth-skinheight-src-miniquake-format-mdl-ml-813934756"></a>
### parseSkin

```ml
function parseSkin(data, offset, skinWidth, skinHeight)
```

Read and validate skin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `skinWidth` | `dynamic` | — | The skin width input consumed by `parseSkin`. |
| `skinHeight` | `dynamic` | — | The skin height input consumed by `parseSkin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L120)

<a id="function-function-miniquake-format-mdl-parsevertex-function-parsevertex-data-offset-src-miniquake-format-mdl-ml-222093405"></a>
### parseVertex

```ml
function parseVertex(data, offset)
```

Read and validate vertex.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/mdl.ml#L19)
