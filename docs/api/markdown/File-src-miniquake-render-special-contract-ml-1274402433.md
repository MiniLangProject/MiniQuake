# `src/miniquake/render_special_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render_special_contract`](Package-miniquake-render-special-contract-167682530.md)

Reachable from entry: **no**

## Imports

- `miniquake/model_ui_render_contract.ml` as `parent` → [src/miniquake/model_ui_render_contract.ml](File-src-miniquake-model-ui-render-contract-ml-602666.md)
- `miniquake/render/special_paths.ml` as `special` → [src/miniquake/render/special_paths.ml](File-src-miniquake-render-special-paths-ml-2012876531.md)
- `miniquake/render_evidence_corpus.ml` as `corpus` → [src/miniquake/render_evidence_corpus.ml](File-src-miniquake-render-evidence-corpus-ml-694315805.md)

## Declarations

<a id="function-function-miniquake-render-special-contract-constants-function-constants-src-miniquake-render-special-contract-ml-1480325923"></a>
### constants

```ml
function constants()
```

Returns the compatibility constants exposed by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L54)

<a id="constant-constant-miniquake-render-special-contract-envmap-faces-const-envmap-faces-6-src-miniquake-render-special-contract-ml-748033332"></a>
### ENVMAP_FACES

```ml
const ENVMAP_FACES = 6
```

Defines the envmap faces value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L27)

<a id="constant-constant-miniquake-render-special-contract-envmap-size-const-envmap-size-256-src-miniquake-render-special-contract-ml-1642318447"></a>
### ENVMAP_SIZE

```ml
const ENVMAP_SIZE = 256
```

Defines the envmap size value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L25)

<a id="constant-constant-miniquake-render-special-contract-evidence-scenarios-const-evidence-scenarios-3-src-miniquake-render-special-contract-ml-15036735"></a>
### EVIDENCE_SCENARIOS

```ml
const EVIDENCE_SCENARIOS = 3
```

Defines the evidence scenarios value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L31)

<a id="constant-constant-miniquake-render-special-contract-exact-pair-required-const-exact-pair-required-1-src-miniquake-render-special-contract-ml-1534552449"></a>
### EXACT_PAIR_REQUIRED

```ml
const EXACT_PAIR_REQUIRED = 1
```

Defines the exact pair required value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L35)

<a id="constant-constant-miniquake-render-special-contract-fingerprint-const-fingerprint-708673665-src-miniquake-render-special-contract-ml-1132884762"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 708673665
```

Defines the fingerprint value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L17)

<a id="function-function-miniquake-render-special-contract-fingerprint-inline-function-fingerprint-src-miniquake-render-special-contract-ml-856105568"></a>
### fingerprint

```ml
inline function fingerprint()
```

Returns the compatibility fingerprint for `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L49)

<a id="constant-constant-miniquake-render-special-contract-mirror-depth-split-milli-const-mirror-depth-split-milli-500-src-miniquake-render-special-contract-ml-994771779"></a>
### MIRROR_DEPTH_SPLIT_MILLI

```ml
const MIRROR_DEPTH_SPLIT_MILLI = 500
```

Defines the mirror depth split milli value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L21)

<a id="constant-constant-miniquake-render-special-contract-mirror-prefix-bytes-const-mirror-prefix-bytes-10-src-miniquake-render-special-contract-ml-955526031"></a>
### MIRROR_PREFIX_BYTES

```ml
const MIRROR_PREFIX_BYTES = 10
```

Defines the mirror prefix bytes value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L19)

<a id="constant-constant-miniquake-render-special-contract-original-reference-external-const-original-reference-external-1-src-miniquake-render-special-contract-ml-1988574909"></a>
### ORIGINAL_REFERENCE_EXTERNAL

```ml
const ORIGINAL_REFERENCE_EXTERNAL = 1
```

Defines the original reference external value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L39)

<a id="constant-constant-miniquake-render-special-contract-original-ssim-milli-const-original-ssim-milli-950-src-miniquake-render-special-contract-ml-1171675614"></a>
### ORIGINAL_SSIM_MILLI

```ml
const ORIGINAL_SSIM_MILLI = 950
```

Defines the original ssim milli value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L33)

<a id="constant-constant-miniquake-render-special-contract-parent-status-const-parent-status-model-ui-render-109-frozen-v1-src-miniquake-render-special-contract-ml-1473296111"></a>
### PARENT_STATUS

```ml
const PARENT_STATUS = "model_ui_render_109_frozen_v1"
```

Defines the parent status value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L41)

<a id="constant-constant-miniquake-render-special-contract-special-render-stage-count-const-special-render-stage-count-12-src-miniquake-render-special-contract-ml-1541430925"></a>
### SPECIAL_RENDER_STAGE_COUNT

```ml
const SPECIAL_RENDER_STAGE_COUNT = 12
```

Defines the special render stage count value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L37)

<a id="constant-constant-miniquake-render-special-contract-status-const-status-render-special-109-frozen-v1-src-miniquake-render-special-contract-ml-295741540"></a>
### STATUS

```ml
const STATUS = "render_special_109_frozen_v1"
```

Defines the status value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L15)

<a id="function-function-miniquake-render-special-contract-status-inline-function-status-src-miniquake-render-special-contract-ml-532855554"></a>
### status

```ml
inline function status()
```

Returns the compatibility status reported by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L44)

<a id="constant-constant-miniquake-render-special-contract-timerefresh-steps-const-timerefresh-steps-128-src-miniquake-render-special-contract-ml-1184967727"></a>
### TIMEREFRESH_STEPS

```ml
const TIMEREFRESH_STEPS = 128
```

Defines the timerefresh steps value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L29)

<a id="function-function-miniquake-render-special-contract-verify-function-verify-src-miniquake-render-special-contract-ml-448805621"></a>
### verify

```ml
function verify()
```

Implements the `verify` operation for `miniquake.render_special_contract` (verify).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L71)

<a id="constant-constant-miniquake-render-special-contract-ztrick-odd-depth-micro-const-ztrick-odd-depth-micro-499990-src-miniquake-render-special-contract-ml-313647174"></a>
### ZTRICK_ODD_DEPTH_MICRO

```ml
const ZTRICK_ODD_DEPTH_MICRO = 499990
```

Defines the ztrick odd depth micro value used by `miniquake.render_special_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_special_contract.ml#L23)
