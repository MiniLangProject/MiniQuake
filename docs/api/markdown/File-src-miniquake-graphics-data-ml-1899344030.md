# `src/miniquake/graphics_data.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.graphics_data`](Package-miniquake-graphics-data-354833679.md)

Reachable from entry: **yes**

## Imports

- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/wad.ml` as `wad` → [src/miniquake/wad.ml](File-src-miniquake-wad-ml-1195240084.md)

## Declarations

<a id="function-function-miniquake-graphics-data-readconsolecharacters-function-readconsolecharacters-filesystem-src-miniquake-graphics-data-ml-992489030"></a>
### readConsoleCharacters

```ml
function readConsoleCharacters(filesystem)
```

Stock Quake stores the console font as the "conchars" lump in gfx.wad. Some repackaged data sets expose gfx/conchars.lmp directly; keep that path only as a compatibility fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `readConsoleCharacters`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/graphics_data.ml#L25)

<a id="function-function-miniquake-graphics-data-readconsolecharactersfromwad-function-readconsolecharactersfromwad-filesystem-src-miniquake-graphics-data-ml-33160424"></a>
### readConsoleCharactersFromWad

```ml
function readConsoleCharactersFromWad(filesystem)
```

Read and validate console characters from wad.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `readConsoleCharactersFromWad`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/graphics_data.ml#L15)
