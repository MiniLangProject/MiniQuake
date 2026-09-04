# `src/miniquake/format/bsp.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.format.bsp`](Package-miniquake-format-bsp-798664083.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-format-bsp-animationslot-function-animationslot-name-src-miniquake-format-bsp-ml-501654647"></a>
### animationSlot

```ml
function animationSlot(name)
```

Implements the `animationSlot` operation for `miniquake.format.bsp` (animation slot).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L499)

<a id="function-function-miniquake-format-bsp-calcsurfaceextents-function-calcsurfaceextents-map-faceindex-src-miniquake-format-bsp-ml-608690133"></a>
### CalcSurfaceExtents

```ml
function CalcSurfaceExtents(map, faceIndex)
```

Implements the `CalcSurfaceExtents` operation for `miniquake.format.bsp` (calc surface extents).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `CalcSurfaceExtents`. |
| `faceIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L647)

<a id="function-function-miniquake-format-bsp-ceilvalue-function-ceilvalue-value-src-miniquake-format-bsp-ml-280947307"></a>
### ceilValue

```ml
function ceilValue(value)
```

Return ceil value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ceilValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L620)

<a id="function-function-miniquake-format-bsp-decompressvisibility-function-decompressvisibility-data-offset-rowbytes-src-miniquake-format-bsp-ml-1019357482"></a>
### decompressVisibility

```ml
function decompressVisibility(data, offset, rowBytes)
```

Implements the `decompressVisibility` operation for `miniquake.format.bsp` (decompress visibility).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `rowBytes` | `dynamic` | — | Byte data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L430)

<a id="function-function-miniquake-format-bsp-emptyanimationtable-function-emptyanimationtable-count-src-miniquake-format-bsp-ml-843342695"></a>
### emptyAnimationTable

```ml
function emptyAnimationTable(count)
```

Implements the `emptyAnimationTable` operation for `miniquake.format.bsp` (empty animation table).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L511)

<a id="function-function-miniquake-format-bsp-entityvalue-function-entityvalue-entity-key-src-miniquake-format-bsp-ml-544837526"></a>
### entityValue

```ml
function entityValue(entity, key)
```

Return entity value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L389)

<a id="function-function-miniquake-format-bsp-entityvector-function-entityvector-entity-key-src-miniquake-format-bsp-ml-1341346838"></a>
### entityVector

```ml
function entityVector(entity, key)
```

Implements the `entityVector` operation for `miniquake.format.bsp` (entity vector).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L422)

<a id="function-function-miniquake-format-bsp-exactprefix-function-exactprefix-text-prefix-src-miniquake-format-bsp-ml-2093506409"></a>
### exactPrefix

```ml
function exactPrefix(text, prefix)
```

Implements the `exactPrefix` operation for `miniquake.format.bsp` (exact prefix).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `prefix` | `dynamic` | — | The prefix input consumed by `exactPrefix`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L470)

<a id="function-function-miniquake-format-bsp-faceunderwater-function-faceunderwater-map-faceindex-src-miniquake-format-bsp-ml-1808264737"></a>
### faceUnderwater

```ml
function faceUnderwater(map, faceIndex)
```

Implements the `faceUnderwater` operation for `miniquake.format.bsp` (face underwater).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `faceUnderwater`. |
| `faceIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L741)

<a id="function-function-miniquake-format-bsp-floorvalue-function-floorvalue-value-src-miniquake-format-bsp-ml-36809947"></a>
### floorValue

```ml
function floorValue(value)
```

Implements the `floorValue` operation for `miniquake.format.bsp` (floor value).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floorValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L612)

<a id="function-function-miniquake-format-bsp-load-function-load-filename-src-miniquake-format-bsp-ml-1621210721"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.format.bsp` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L1029)

<a id="function-function-miniquake-format-bsp-mod-decompressvis-function-mod-decompressvis-data-offset-numleafs-src-miniquake-format-bsp-ml-279898728"></a>
### Mod_DecompressVis

```ml
function Mod_DecompressVis(data, offset, numLeafs)
```

Mirror Quake's Mod_DecompressVis routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `numLeafs` | `dynamic` | — | The num leafs input consumed by `Mod_DecompressVis`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L461)

<a id="function-function-miniquake-format-bsp-mod-loadbrushmodel-function-mod-loadbrushmodel-data-filename-src-miniquake-format-bsp-ml-1001638381"></a>
### Mod_LoadBrushModel

```ml
function Mod_LoadBrushModel(data, filename)
```

Mirror Quake's Mod_LoadBrushModel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L1023)

<a id="function-function-miniquake-format-bsp-mod-loadclipnodes-function-mod-loadclipnodes-data-lump-src-miniquake-format-bsp-ml-676586672"></a>
### Mod_LoadClipnodes

```ml
function Mod_LoadClipnodes(data, lump)
```

Mirror Quake's Mod_LoadClipnodes routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadClipnodes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L946)

<a id="function-function-miniquake-format-bsp-mod-loadedges-function-mod-loadedges-data-lump-src-miniquake-format-bsp-ml-244926538"></a>
### Mod_LoadEdges

```ml
function Mod_LoadEdges(data, lump)
```

Mirror Quake's Mod_LoadEdges routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadEdges`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L911)

<a id="function-function-miniquake-format-bsp-mod-loadentities-function-mod-loadentities-data-lump-src-miniquake-format-bsp-ml-1806964240"></a>
### Mod_LoadEntities

```ml
function Mod_LoadEntities(data, lump)
```

Mirror Quake's Mod_LoadEntities routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L889)

<a id="function-function-miniquake-format-bsp-mod-loadfaces-function-mod-loadfaces-data-lump-src-miniquake-format-bsp-ml-1453391998"></a>
### Mod_LoadFaces

```ml
function Mod_LoadFaces(data, lump)
```

Mirror Quake's Mod_LoadFaces routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadFaces`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L925)

<a id="function-function-miniquake-format-bsp-mod-loadleafs-function-mod-loadleafs-data-lump-src-miniquake-format-bsp-ml-1530580100"></a>
### Mod_LoadLeafs

```ml
function Mod_LoadLeafs(data, lump)
```

Mirror Quake's Mod_LoadLeafs routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadLeafs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L939)

<a id="function-function-miniquake-format-bsp-mod-loadlighting-function-mod-loadlighting-data-lump-src-miniquake-format-bsp-ml-1723585908"></a>
### Mod_LoadLighting

```ml
function Mod_LoadLighting(data, lump)
```

Mirror Quake's Mod_LoadLighting routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadLighting`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L875)

<a id="function-function-miniquake-format-bsp-mod-loadmarksurfaces-function-mod-loadmarksurfaces-data-lump-src-miniquake-format-bsp-ml-1799950380"></a>
### Mod_LoadMarksurfaces

```ml
function Mod_LoadMarksurfaces(data, lump)
```

Mirror Quake's Mod_LoadMarksurfaces routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadMarksurfaces`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L953)

<a id="function-function-miniquake-format-bsp-mod-loadnodes-function-mod-loadnodes-data-lump-src-miniquake-format-bsp-ml-417163424"></a>
### Mod_LoadNodes

```ml
function Mod_LoadNodes(data, lump)
```

Mirror Quake's Mod_LoadNodes routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadNodes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L932)

<a id="function-function-miniquake-format-bsp-mod-loadplanes-function-mod-loadplanes-data-lump-src-miniquake-format-bsp-ml-1712409360"></a>
### Mod_LoadPlanes

```ml
function Mod_LoadPlanes(data, lump)
```

Mirror Quake's Mod_LoadPlanes routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadPlanes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L967)

<a id="function-function-miniquake-format-bsp-mod-loadsubmodels-function-mod-loadsubmodels-data-lump-src-miniquake-format-bsp-ml-359109674"></a>
### Mod_LoadSubmodels

```ml
function Mod_LoadSubmodels(data, lump)
```

Mirror Quake's Mod_LoadSubmodels routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadSubmodels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L904)

<a id="function-function-miniquake-format-bsp-mod-loadsurfedges-function-mod-loadsurfedges-data-lump-src-miniquake-format-bsp-ml-276868138"></a>
### Mod_LoadSurfedges

```ml
function Mod_LoadSurfedges(data, lump)
```

Mirror Quake's Mod_LoadSurfedges routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadSurfedges`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L960)

<a id="function-function-miniquake-format-bsp-mod-loadtexinfo-function-mod-loadtexinfo-data-lump-src-miniquake-format-bsp-ml-1073485848"></a>
### Mod_LoadTexinfo

```ml
function Mod_LoadTexinfo(data, lump)
```

Mirror Quake's Mod_LoadTexinfo routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadTexinfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L918)

<a id="function-function-miniquake-format-bsp-mod-loadtextures-function-mod-loadtextures-data-lump-src-miniquake-format-bsp-ml-1920901080"></a>
### Mod_LoadTextures

```ml
function Mod_LoadTextures(data, lump)
```

Logical equivalents of the original per-lump loaders.  Their storage outputs are immutable arrays rather than hunk pointer ranges.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadTextures`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L864)

<a id="function-function-miniquake-format-bsp-mod-loadvertexes-function-mod-loadvertexes-data-lump-src-miniquake-format-bsp-ml-2045965652"></a>
### Mod_LoadVertexes

```ml
function Mod_LoadVertexes(data, lump)
```

Mirror Quake's Mod_LoadVertexes routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadVertexes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L897)

<a id="function-function-miniquake-format-bsp-mod-loadvisibility-function-mod-loadvisibility-data-lump-src-miniquake-format-bsp-ml-1355591280"></a>
### Mod_LoadVisibility

```ml
function Mod_LoadVisibility(data, lump)
```

Mirror Quake's Mod_LoadVisibility routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `Mod_LoadVisibility`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L882)

<a id="function-function-miniquake-format-bsp-mod-setparent-function-mod-setparent-map-src-miniquake-format-bsp-ml-869074492"></a>
### Mod_SetParent

```ml
function Mod_SetParent(map)
```

Mirror Quake's Mod_SetParent routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `Mod_SetParent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L704)

<a id="function-function-miniquake-format-bsp-parse-function-parse-data-filename-src-miniquake-format-bsp-ml-1165451047"></a>
### parse

```ml
function parse(data, filename)
```

Implements the `parse` operation for `miniquake.format.bsp` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L974)

<a id="function-function-miniquake-format-bsp-parseclipnodes-function-parseclipnodes-data-lump-src-miniquake-format-bsp-ml-1969392272"></a>
### parseClipNodes

```ml
function parseClipNodes(data, lump)
```

Read and validate clip nodes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseClipNodes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L139)

<a id="function-function-miniquake-format-bsp-parseedges-function-parseedges-data-lump-src-miniquake-format-bsp-ml-2013482240"></a>
### parseEdges

```ml
function parseEdges(data, lump)
```

Read and validate edges.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseEdges`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L82)

<a id="function-function-miniquake-format-bsp-parseentities-function-parseentities-text-src-miniquake-format-bsp-ml-1710598591"></a>
### parseEntities

```ml
function parseEntities(text)
```

Read and validate entities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L366)

<a id="function-function-miniquake-format-bsp-parsefaces-function-parsefaces-data-lump-src-miniquake-format-bsp-ml-1250535120"></a>
### parseFaces

```ml
function parseFaces(data, lump)
```

Read and validate faces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseFaces`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L173)

<a id="function-function-miniquake-format-bsp-parseleafs-function-parseleafs-data-lump-src-miniquake-format-bsp-ml-29306236"></a>
### parseLeafs

```ml
function parseLeafs(data, lump)
```

Read and validate leafs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseLeafs`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L198)

<a id="function-function-miniquake-format-bsp-parselumps-function-parselumps-data-src-miniquake-format-bsp-ml-1983457586"></a>
### parseLumps

```ml
function parseLumps(data)
```

Read and validate lumps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L32)

<a id="function-function-miniquake-format-bsp-parsemarksurfaces-function-parsemarksurfaces-data-lump-src-miniquake-format-bsp-ml-2102959252"></a>
### parseMarkSurfaces

```ml
function parseMarkSurfaces(data, lump)
```

Read and validate mark surfaces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseMarkSurfaces`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L224)

<a id="function-function-miniquake-format-bsp-parsemodels-function-parsemodels-data-lump-src-miniquake-format-bsp-ml-51779366"></a>
### parseModels

```ml
function parseModels(data, lump)
```

Read and validate models.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseModels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L239)

<a id="function-function-miniquake-format-bsp-parsenodes-function-parsenodes-data-lump-src-miniquake-format-bsp-ml-1631294864"></a>
### parseNodes

```ml
function parseNodes(data, lump)
```

Read and validate nodes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseNodes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L113)

<a id="function-function-miniquake-format-bsp-parseplanes-function-parseplanes-data-lump-src-miniquake-format-bsp-ml-394003616"></a>
### parsePlanes

```ml
function parsePlanes(data, lump)
```

Read and validate planes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parsePlanes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L49)

<a id="function-function-miniquake-format-bsp-parsesurfedges-function-parsesurfedges-data-lump-src-miniquake-format-bsp-ml-338619260"></a>
### parseSurfEdges

```ml
function parseSurfEdges(data, lump)
```

Read and validate surf edges.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseSurfEdges`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L98)

<a id="function-function-miniquake-format-bsp-parsetexinfo-function-parsetexinfo-data-lump-src-miniquake-format-bsp-ml-408136136"></a>
### parseTexInfo

```ml
function parseTexInfo(data, lump)
```

Read and validate tex info.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseTexInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L155)

<a id="function-function-miniquake-format-bsp-parsetextures-function-parsetextures-data-lump-src-miniquake-format-bsp-ml-1546014058"></a>
### parseTextures

```ml
function parseTextures(data, lump)
```

Read and validate textures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseTextures`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L260)

<a id="function-function-miniquake-format-bsp-parsevector-function-parsevector-text-src-miniquake-format-bsp-ml-700346527"></a>
### parseVector

```ml
function parseVector(text)
```

Read and validate vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L398)

<a id="function-function-miniquake-format-bsp-parsevertices-function-parsevertices-data-lump-src-miniquake-format-bsp-ml-1236566352"></a>
### parseVertices

```ml
function parseVertices(data, lump)
```

Read and validate vertices.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lump` | `dynamic` | — | The lump input consumed by `parseVertices`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L66)

<a id="function-function-miniquake-format-bsp-planesignbits-function-planesignbits-plane-src-miniquake-format-bsp-ml-115797736"></a>
### planeSignBits

```ml
function planeSignBits(plane)
```

Return plane sign bits derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `plane` | `dynamic` | — | The plane input consumed by `planeSignBits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L694)

<a id="function-function-miniquake-format-bsp-sameanimationname-function-sameanimationname-left-right-src-miniquake-format-bsp-ml-431710873"></a>
### sameAnimationName

```ml
function sameAnimationName(left, right)
```

Return same animation name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `sameAnimationName`. |
| `right` | `dynamic` | — | The right input consumed by `sameAnimationName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L485)

<a id="function-function-miniquake-format-bsp-sequencetextureanimations-function-sequencetextureanimations-textures-src-miniquake-format-bsp-ml-762983756"></a>
### sequenceTextureAnimations

```ml
function sequenceTextureAnimations(textures)
```

The pointer links of texture_t are represented as stable texture indices.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textures` | `dynamic` | — | The textures input consumed by `sequenceTextureAnimations`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L524)

<a id="function-function-miniquake-format-bsp-surfacevertex-function-surfacevertex-map-face-edgenumber-src-miniquake-format-bsp-ml-973581347"></a>
### surfaceVertex

```ml
function surfaceVertex(map, face, edgeNumber)
```

Implements the `surfaceVertex` operation for `miniquake.format.bsp` (surface vertex).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `surfaceVertex`. |
| `face` | `dynamic` | — | The face input consumed by `surfaceVertex`. |
| `edgeNumber` | `dynamic` | — | The edge number input consumed by `surfaceVertex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L630)

<a id="function-function-miniquake-format-bsp-texinfomipadjust-function-texinfomipadjust-info-src-miniquake-format-bsp-ml-120988654"></a>
### texInfoMipAdjust

```ml
function texInfoMipAdjust(info)
```

Implements the `texInfoMipAdjust` operation for `miniquake.format.bsp` (tex info mip adjust).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `info` | `dynamic` | — | The info input consumed by `texInfoMipAdjust`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L682)

<a id="constant-constant-miniquake-format-bsp-texture-animation-cache-size-const-texture-animation-cache-size-16-src-miniquake-format-bsp-ml-744966262"></a>
### TEXTURE_ANIMATION_CACHE_SIZE

```ml
const TEXTURE_ANIMATION_CACHE_SIZE = 16
```

BSP texture arrays are immutable after loading.  Cache their linked animation tables so a render-frame lookup does not rebuild hundreds of short arrays for every visible animated texture.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L22)

<a id="global-global-miniquake-format-bsp-textureanimationcachekeys-textureanimationcachekeys-src-miniquake-format-bsp-ml-1055005566"></a>
### textureAnimationCacheKeys

```ml
textureAnimationCacheKeys
```

Tracks the module-level texture animation cache keys state owned by `miniquake.format.bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L24)

<a id="global-global-miniquake-format-bsp-textureanimationcachesources-textureanimationcachesources-src-miniquake-format-bsp-ml-1461547212"></a>
### textureAnimationCacheSources

```ml
textureAnimationCacheSources
```

Tracks the module-level texture animation cache sources state owned by `miniquake.format.bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L26)

<a id="global-global-miniquake-format-bsp-textureanimationcachetables-textureanimationcachetables-src-miniquake-format-bsp-ml-1069176334"></a>
### textureAnimationCacheTables

```ml
textureAnimationCacheTables
```

Tracks the module-level texture animation cache tables state owned by `miniquake.format.bsp`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L28)

<a id="function-function-miniquake-format-bsp-textureanimationindex-function-textureanimationindex-textures-baseindex-time-alternate-src-miniquake-format-bsp-ml-1568634576"></a>
### textureAnimationIndex

```ml
function textureAnimationIndex(textures, baseIndex, time, alternate)
```

Return texture animation index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textures` | `dynamic` | — | The textures input consumed by `textureAnimationIndex`. |
| `baseIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `time` | `dynamic` | — | Simulation or presentation time for the operation. |
| `alternate` | `dynamic` | — | The alternate input consumed by `textureAnimationIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L592)

<a id="function-function-miniquake-format-bsp-tokenizeentities-function-tokenizeentities-text-src-miniquake-format-bsp-ml-1570281823"></a>
### tokenizeEntities

```ml
function tokenizeEntities(text)
```

Convert entities into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L305)

<a id="function-function-miniquake-format-bsp-validatebrushmodel-function-validatebrushmodel-map-src-miniquake-format-bsp-ml-1361089538"></a>
### validateBrushModel

```ml
function validateBrushModel(map)
```

Validate brush model and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `validateBrushModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L774)

<a id="function-function-miniquake-format-bsp-validleafvisibilityoffset-function-validleafvisibilityoffset-offset-visibilitysize-src-miniquake-format-bsp-ml-775670694"></a>
### validLeafVisibilityOffset

```ml
function validLeafVisibilityOffset(offset, visibilitySize)
```

External BSP29 models (ammo and health boxes in the retail data) have no visibility lump and store visofs 0 in their leaves.  GLQuake accepts this: Mod_LoadVisibility leaves loadmodel->visdata NULL and NULL + 0 remains the no-PVS case.  World BSPs additionally use -1 as the explicit no-PVS sentinel.  Preserve both original encodings while still rejecting offsets outside a non-empty visibility lump.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `visibilitySize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/format/bsp.ml#L766)
