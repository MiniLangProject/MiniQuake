# `src/miniquake/render/colored_lightmaps.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render.colored_lightmaps`](Package-miniquake-render-colored-lightmaps-665799563.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)

## Declarations

<a id="function-function-miniquake-render-colored-lightmaps-attach-function-attach-map-samples-src-miniquake-render-colored-lightmaps-ml-1023344693"></a>
### attach

```ml
function attach(map, samples)
```

Associate validated RGB light samples with the relocatable BSP object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `attach`. |
| `samples` | `dynamic` | — | The samples input consumed by `attach`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L35)

<a id="function-function-miniquake-render-colored-lightmaps-clear-function-clear-src-miniquake-render-colored-lightmaps-ml-1883658268"></a>
### clear

```ml
function clear()
```

Clear sidecar roots when renderer/model state is torn down by tests.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L78)

<a id="function-function-miniquake-render-colored-lightmaps-decode-function-decode-data-lightsamplecount-src-miniquake-render-colored-lightmaps-ml-1584008033"></a>
### decode

```ml
function decode(data, lightSampleCount)
```

Decode a version-one QLIT payload and verify that it exactly mirrors the BSP's scalar light sample count. Invalid sidecars are ignored safely.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `lightSampleCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L23)

<a id="function-function-miniquake-render-colored-lightmaps-formap-function-formap-map-src-miniquake-render-colored-lightmaps-ml-1249245026"></a>
### forMap

```ml
function forMap(map)
```

Return RGB samples previously associated with this exact BSP instance.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `forMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L67)

<a id="function-function-miniquake-render-colored-lightmaps-loadformap-function-loadformap-filesystem-map-src-miniquake-render-colored-lightmaps-ml-619217617"></a>
### loadForMap

```ml
function loadForMap(filesystem, map)
```

Load the optional sidecar through Quake's normal search path. This supports loose files as well as .lit files supplied by a selected -game directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `loadForMap`. |
| `map` | `dynamic` | — | The map input consumed by `loadForMap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L54)

<a id="global-global-miniquake-render-colored-lightmaps-mapkeys-mapkeys-src-miniquake-render-colored-lightmaps-ml-1806248434"></a>
### mapKeys

```ml
mapKeys
```

Tracks the module-level map keys state owned by `miniquake.render.colored_lightmaps`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L15)

<a id="global-global-miniquake-render-colored-lightmaps-mapvalues-mapvalues-src-miniquake-render-colored-lightmaps-ml-1708504298"></a>
### mapValues

```ml
mapValues
```

Tracks the module-level map values state owned by `miniquake.render.colored_lightmaps`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/colored_lightmaps.ml#L17)
