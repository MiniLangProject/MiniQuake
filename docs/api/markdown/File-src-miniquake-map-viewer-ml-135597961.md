# `src/miniquake/map_viewer.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.map_viewer`](Package-miniquake-map-viewer-1205174546.md)

Reachable from entry: **yes**

## Imports

- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-map-viewer-drawmap-function-drawmap-map-src-miniquake-map-viewer-ml-1643840099"></a>
### drawMap

```ml
function drawMap(map)
```

Render map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `drawMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/map_viewer.ml#L35)

<a id="function-function-miniquake-map-viewer-facevertex-function-facevertex-map-surfedgeindex-src-miniquake-map-viewer-ml-1467506066"></a>
### faceVertex

```ml
function faceVertex(map, surfEdgeIndex)
```

Implements the `faceVertex` operation for `miniquake.map_viewer` (face vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `faceVertex`. |
| `surfEdgeIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/map_viewer.ml#L20)

<a id="function-function-miniquake-map-viewer-render-function-render-map-angle-width-height-src-miniquake-map-viewer-ml-1938497337"></a>
### render

```ml
function render(map, angle, width, height)
```

Implements the `render` operation for `miniquake.map_viewer` (render).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `render`. |
| `angle` | `dynamic` | — | The angle input consumed by `render`. |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/map_viewer.ml#L56)

<a id="function-function-miniquake-map-viewer-rundirect-function-rundirect-bspfilename-palettefilename-src-miniquake-map-viewer-ml-221419823"></a>
### runDirect

```ml
function runDirect(bspFilename, paletteFilename)
```

Execute direct.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bspFilename` | `dynamic` | — | Name that identifies the requested value or resource. |
| `paletteFilename` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/map_viewer.ml#L101)

<a id="function-function-miniquake-map-viewer-runfromgame-function-runfromgame-basedirectory-mapname-src-miniquake-map-viewer-ml-2120669424"></a>
### runFromGame

```ml
function runFromGame(baseDirectory, mapName)
```

Execute from game.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/map_viewer.ml#L111)

<a id="function-function-miniquake-map-viewer-runmap-function-runmap-map-title-src-miniquake-map-viewer-ml-1125604313"></a>
### runMap

```ml
function runMap(map, title)
```

Execute map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `runMap`. |
| `title` | `dynamic` | — | The title input consumed by `runMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/map_viewer.ml#L80)
