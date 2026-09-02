# `src/miniquake/world_render_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.world_render_contract`](Package-miniquake-world-render-contract-2045927073.md)

Reachable from entry: **no**

## Declarations

<a id="constant-constant-miniquake-world-render-contract-backface-epsilon-milli-const-backface-epsilon-milli-10-src-miniquake-world-render-contract-ml-1439593809"></a>
### BACKFACE_EPSILON_MILLI

```ml
const BACKFACE_EPSILON_MILLI = 10
```

Defines the backface epsilon milli value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L29)

<a id="function-function-miniquake-world-render-contract-constants-function-constants-src-miniquake-world-render-contract-ml-1751842965"></a>
### constants

```ml
function constants()
```

Returns the compatibility constants exposed by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L69)

<a id="constant-constant-miniquake-world-render-contract-far-clip-const-far-clip-4096-src-miniquake-world-render-contract-ml-569926137"></a>
### FAR_CLIP

```ml
const FAR_CLIP = 4096
```

Defines the far clip value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L19)

<a id="constant-constant-miniquake-world-render-contract-fingerprint-const-fingerprint-2221569246-src-miniquake-world-render-contract-ml-1510692887"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 2221569246
```

Defines the fingerprint value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L15)

<a id="function-function-miniquake-world-render-contract-fingerprint-inline-function-fingerprint-src-miniquake-world-render-contract-ml-109673392"></a>
### fingerprint

```ml
inline function fingerprint()
```

Returns the compatibility fingerprint for `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L51)

<a id="constant-constant-miniquake-world-render-contract-lightmap-height-const-lightmap-height-128-src-miniquake-world-render-contract-ml-224813583"></a>
### LIGHTMAP_HEIGHT

```ml
const LIGHTMAP_HEIGHT = 128
```

Defines the lightmap height value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L23)

<a id="constant-constant-miniquake-world-render-contract-lightmap-width-const-lightmap-width-128-src-miniquake-world-render-contract-ml-119964043"></a>
### LIGHTMAP_WIDTH

```ml
const LIGHTMAP_WIDTH = 128
```

Defines the lightmap width value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L21)

<a id="constant-constant-miniquake-world-render-contract-max-lightmaps-const-max-lightmaps-64-src-miniquake-world-render-contract-ml-847696968"></a>
### MAX_LIGHTMAPS

```ml
const MAX_LIGHTMAPS = 64
```

Defines the max lightmaps value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L25)

<a id="constant-constant-miniquake-world-render-contract-max-visible-entities-const-max-visible-entities-256-src-miniquake-world-render-contract-ml-1981647963"></a>
### MAX_VISIBLE_ENTITIES

```ml
const MAX_VISIBLE_ENTITIES = 256
```

Defines the max visible entities value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L27)

<a id="constant-constant-miniquake-world-render-contract-near-clip-const-near-clip-4-src-miniquake-world-render-contract-ml-1817915372"></a>
### NEAR_CLIP

```ml
const NEAR_CLIP = 4
```

Defines the near clip value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L17)

<a id="constant-constant-miniquake-world-render-contract-stage-dlights-const-stage-dlights-3-src-miniquake-world-render-contract-ml-553162183"></a>
### STAGE_DLIGHTS

```ml
const STAGE_DLIGHTS = 3
```

Defines the stage dlights value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L35)

<a id="constant-constant-miniquake-world-render-contract-stage-entities-const-stage-entities-2-src-miniquake-world-render-contract-ml-2089171560"></a>
### STAGE_ENTITIES

```ml
const STAGE_ENTITIES = 2
```

Defines the stage entities value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L33)

<a id="constant-constant-miniquake-world-render-contract-stage-particles-const-stage-particles-4-src-miniquake-world-render-contract-ml-1053340480"></a>
### STAGE_PARTICLES

```ml
const STAGE_PARTICLES = 4
```

Defines the stage particles value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L37)

<a id="constant-constant-miniquake-world-render-contract-stage-polyblend-const-stage-polyblend-7-src-miniquake-world-render-contract-ml-1769303079"></a>
### STAGE_POLYBLEND

```ml
const STAGE_POLYBLEND = 7
```

Defines the stage polyblend value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L43)

<a id="constant-constant-miniquake-world-render-contract-stage-viewmodel-const-stage-viewmodel-5-src-miniquake-world-render-contract-ml-631702341"></a>
### STAGE_VIEWMODEL

```ml
const STAGE_VIEWMODEL = 5
```

Defines the stage viewmodel value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L39)

<a id="constant-constant-miniquake-world-render-contract-stage-water-const-stage-water-6-src-miniquake-world-render-contract-ml-1821245318"></a>
### STAGE_WATER

```ml
const STAGE_WATER = 6
```

Defines the stage water value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L41)

<a id="constant-constant-miniquake-world-render-contract-stage-world-const-stage-world-1-src-miniquake-world-render-contract-ml-1154561073"></a>
### STAGE_WORLD

```ml
const STAGE_WORLD = 1
```

Defines the stage world value used by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L31)

<a id="function-function-miniquake-world-render-contract-stageorder-function-stageorder-src-miniquake-world-render-contract-ml-1796445787"></a>
### stageOrder

```ml
function stageOrder()
```

Implements the `stageOrder` operation for `miniquake.world_render_contract` (stage order).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L56)

<a id="constant-constant-miniquake-world-render-contract-status-const-status-world-render-109-frozen-v1-src-miniquake-world-render-contract-ml-2044019187"></a>
### STATUS

```ml
const STATUS = "world_render_109_frozen_v1"
```

BP-044: the authoritative MiniQuake 1.09 world-render contract.  Modern backends may consume the same render handoff, but compatibility mode keeps these observable constants and pass ordering fixed.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L13)

<a id="function-function-miniquake-world-render-contract-status-inline-function-status-src-miniquake-world-render-contract-ml-858006394"></a>
### status

```ml
inline function status()
```

Returns the compatibility status reported by `miniquake.world_render_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/world_render_contract.ml#L46)
