# `src/miniquake/model_registry.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.model_registry`](Package-miniquake-model-registry-1462222818.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/cvar.ml` as `cvar` → [src/miniquake/cvar.ml](File-src-miniquake-cvar-ml-171521436.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/mdl.ml` as `mdl` → [src/miniquake/format/mdl.ml](File-src-miniquake-format-mdl-ml-1455458127.md)
- `miniquake/format/sprite.ml` as `sprite` → [src/miniquake/format/sprite.ml](File-src-miniquake-format-sprite-ml-531278995.md)
- `miniquake/render/colored_lightmaps.ml` as `coloredLightmaps` → [src/miniquake/render/colored_lightmaps.ml](File-src-miniquake-render-colored-lightmaps-ml-2051146857.md)
- `miniquake/render/gl_warp.ml` as `glWarp` → [src/miniquake/render/gl_warp.ml](File-src-miniquake-render-gl-warp-ml-268398757.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `world` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="function-function-miniquake-model-registry-create-function-create-src-miniquake-model-registry-ml-274377037"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.model_registry` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L55)

<a id="function-function-miniquake-model-registry-findindex-function-findindex-registry-name-src-miniquake-model-registry-ml-649554891"></a>
### findIndex

```ml
function findIndex(registry, name)
```

strcmp, not Q_strcasecmp: model identity is case-sensitive in MiniQuake.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `findIndex`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L62)

<a id="function-function-miniquake-model-registry-get-function-get-registry-name-src-miniquake-model-registry-ml-629702385"></a>
### get

```ml
function get(registry, name)
```

Implements the `get` operation for `miniquake.model_registry` (get).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `get`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L112)

<a id="function-function-miniquake-model-registry-loadbytes-function-loadbytes-registry-name-data-src-miniquake-model-registry-ml-1187378863"></a>
### loadBytes

```ml
function loadBytes(registry, name, data)
```

Loads bytes for `miniquake.model_registry`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `loadBytes`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L145)

<a id="constant-constant-miniquake-model-registry-mod-alias-const-mod-alias-2-src-miniquake-model-registry-ml-1843954196"></a>
### MOD_ALIAS

```ml
const MOD_ALIAS = 2
```

Defines the mod alias value used by `miniquake.model_registry`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L30)

<a id="constant-constant-miniquake-model-registry-mod-brush-const-mod-brush-0-src-miniquake-model-registry-ml-858408342"></a>
### MOD_BRUSH

```ml
const MOD_BRUSH = 0
```

Defines the mod brush value used by `miniquake.model_registry`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L26)

<a id="function-function-miniquake-model-registry-mod-clearall-function-mod-clearall-registry-src-miniquake-model-registry-ml-254879584"></a>
### Mod_ClearAll

```ml
function Mod_ClearAll(registry)
```

Mirror Quake's Mod_ClearAll routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_ClearAll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L226)

<a id="function-function-miniquake-model-registry-mod-extradata-function-mod-extradata-registry-filesystem-index-src-miniquake-model-registry-ml-1600702599"></a>
### Mod_Extradata

```ml
function Mod_Extradata(registry, filesystem, index)
```

Mirror Quake's Mod_Extradata routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_Extradata`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `Mod_Extradata`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L214)

<a id="function-function-miniquake-model-registry-mod-findname-function-mod-findname-registry-name-src-miniquake-model-registry-ml-725741689"></a>
### Mod_FindName

```ml
function Mod_FindName(registry, name)
```

Mirror Quake's Mod_FindName routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_FindName`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L74)

<a id="function-function-miniquake-model-registry-mod-forname-function-mod-forname-registry-filesystem-name-crash-src-miniquake-model-registry-ml-1033378205"></a>
### Mod_ForName

```ml
function Mod_ForName(registry, filesystem, name, crash)
```

Mirror Quake's Mod_ForName routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_ForName`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `Mod_ForName`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `crash` | `dynamic` | — | The crash input consumed by `Mod_ForName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L192)

<a id="function-function-miniquake-model-registry-mod-init-function-mod-init-registry-cvars-src-miniquake-model-registry-ml-1800023343"></a>
### Mod_Init

```ml
function Mod_Init(registry, cvars)
```

Mod_Init.  mod_novis is the original MAX_MAP_LEAFS/8 all-visible row. gl_subdivide_size is archived exactly as in gl_model.c.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_Init`. |
| `cvars` | `dynamic` | — | The cvars input consumed by `Mod_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L42)

<a id="function-function-miniquake-model-registry-mod-loadmodel-function-mod-loadmodel-registry-filesystem-index-crash-src-miniquake-model-registry-ml-1275435860"></a>
### Mod_LoadModel

```ml
function Mod_LoadModel(registry, filesystem, index, crash)
```

Mod_LoadModel.  MiniLang objects are relocatable GC values, so the alias cache check is represented by retaining registry.models[index].

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_LoadModel`. |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `Mod_LoadModel`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `crash` | `dynamic` | — | The crash input consumed by `Mod_LoadModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L159)

<a id="function-function-miniquake-model-registry-mod-print-function-mod-print-registry-src-miniquake-model-registry-ml-862017468"></a>
### Mod_Print

```ml
function Mod_Print(registry)
```

Mirror Quake's Mod_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_Print`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L237)

<a id="constant-constant-miniquake-model-registry-mod-sprite-const-mod-sprite-1-src-miniquake-model-registry-ml-891168127"></a>
### MOD_SPRITE

```ml
const MOD_SPRITE = 1
```

Defines the mod sprite value used by `miniquake.model_registry`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L28)

<a id="function-function-miniquake-model-registry-mod-touchmodel-function-mod-touchmodel-registry-name-src-miniquake-model-registry-ml-488352129"></a>
### Mod_TouchModel

```ml
function Mod_TouchModel(registry, name)
```

Mirror Quake's Mod_TouchModel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Mod_TouchModel`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L201)

<a id="constant-constant-miniquake-model-registry-mod-unknown-const-mod-unknown-1-src-miniquake-model-registry-ml-163094780"></a>
### MOD_UNKNOWN

```ml
const MOD_UNKNOWN = -1
```

Defines the mod unknown value used by `miniquake.model_registry`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L24)

<a id="function-function-miniquake-model-registry-modelbounds-function-modelbounds-registry-name-src-miniquake-model-registry-ml-1196599345"></a>
### modelBounds

```ml
function modelBounds(registry, name)
```

Implements the `modelBounds` operation for `miniquake.model_registry` (model bounds).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `modelBounds`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L252)

<a id="function-function-miniquake-model-registry-modelcommandneverexists-function-modelcommandneverexists-name-src-miniquake-model-registry-ml-1530344464"></a>
### modelCommandNeverExists

```ml
function modelCommandNeverExists(name)
```

Report whether model command never exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L34)

<a id="function-function-miniquake-model-registry-modelradius-function-modelradius-registry-name-src-miniquake-model-registry-ml-2004258479"></a>
### modelRadius

```ml
function modelRadius(registry, name)
```

Implements the `modelRadius` operation for `miniquake.model_registry` (model radius).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `modelRadius`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L275)

<a id="function-function-miniquake-model-registry-modeltype-function-modeltype-registry-name-src-miniquake-model-registry-ml-1884299491"></a>
### modelType

```ml
function modelType(registry, name)
```

Return model type derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `modelType`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L121)

<a id="function-function-miniquake-model-registry-register-function-register-registry-name-model-src-miniquake-model-registry-ml-925155618"></a>
### register

```ml
function register(registry, name, model)
```

Compatibility helper retained for existing callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `register`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `model` | `dynamic` | — | Model resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L105)

<a id="function-function-miniquake-model-registry-registerbrushsubmodels-function-registerbrushsubmodels-registry-map-src-miniquake-model-registry-ml-333229684"></a>
### registerBrushSubmodels

```ml
function registerBrushSubmodels(registry, map)
```

Update subsystem configuration for register brush submodels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `registerBrushSubmodels`. |
| `map` | `dynamic` | — | The map input consumed by `registerBrushSubmodels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L130)

<a id="function-function-miniquake-model-registry-registertyped-function-registertyped-registry-name-model-type-src-miniquake-model-registry-ml-1714249744"></a>
### registerTyped

```ml
function registerTyped(registry, name, model, type)
```

Update subsystem configuration for register typed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `registerTyped`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `model` | `dynamic` | — | Model resource processed by the operation. |
| `type` | `dynamic` | — | The type input consumed by `registerTyped`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/model_registry.ml#L92)
