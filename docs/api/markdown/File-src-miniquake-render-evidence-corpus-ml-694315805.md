# `src/miniquake/render_evidence_corpus.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.render_evidence_corpus`](Package-miniquake-render-evidence-corpus-418619574.md)

Reachable from entry: **no**

## Declarations

<a id="function-function-miniquake-render-evidence-corpus-average-function-average-values-src-miniquake-render-evidence-corpus-ml-2090369241"></a>
### average

```ml
function average(values)
```

Implements the `average` operation for `miniquake.render_evidence_corpus` (average).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `average`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L108)

<a id="constant-constant-miniquake-render-evidence-corpus-capture-height-const-capture-height-480-src-miniquake-render-evidence-corpus-ml-1393132448"></a>
### CAPTURE_HEIGHT

```ml
const CAPTURE_HEIGHT = 480
```

Defines the capture height value used by `miniquake.render_evidence_corpus`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L18)

<a id="constant-constant-miniquake-render-evidence-corpus-capture-width-const-capture-width-640-src-miniquake-render-evidence-corpus-ml-324434916"></a>
### CAPTURE_WIDTH

```ml
const CAPTURE_WIDTH = 640
```

Defines the capture width value used by `miniquake.render_evidence_corpus`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L16)

<a id="function-function-miniquake-render-evidence-corpus-contractvector-function-contractvector-src-miniquake-render-evidence-corpus-ml-1186490405"></a>
### contractVector

```ml
function contractVector()
```

Implements the `contractVector` operation for `miniquake.render_evidence_corpus` (contract vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L118)

<a id="constant-constant-miniquake-render-evidence-corpus-corpus-schema-const-corpus-schema-1-src-miniquake-render-evidence-corpus-ml-294945405"></a>
### CORPUS_SCHEMA

```ml
const CORPUS_SCHEMA = 1
```

Defines the corpus schema value used by `miniquake.render_evidence_corpus`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L14)

<a id="function-function-miniquake-render-evidence-corpus-count-function-count-src-miniquake-render-evidence-corpus-ml-1236580047"></a>
### count

```ml
function count()
```

Return count derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L34)

<a id="constant-constant-miniquake-render-evidence-corpus-exact-pair-required-const-exact-pair-required-1-src-miniquake-render-evidence-corpus-ml-1379728929"></a>
### EXACT_PAIR_REQUIRED

```ml
const EXACT_PAIR_REQUIRED = 1
```

Defines the exact pair required value used by `miniquake.render_evidence_corpus`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L22)

<a id="function-function-miniquake-render-evidence-corpus-exactpair-function-exactpair-hasha-hashb-samplea-sampleb-src-miniquake-render-evidence-corpus-ml-132426803"></a>
### exactPair

```ml
function exactPair(hashA, hashB, sampleA, sampleB)
```

Implements the `exactPair` operation for `miniquake.render_evidence_corpus` (exact pair).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hashA` | `dynamic` | — | The hash a input consumed by `exactPair`. |
| `hashB` | `dynamic` | — | The hash b input consumed by `exactPair`. |
| `sampleA` | `dynamic` | — | The sample a input consumed by `exactPair`. |
| `sampleB` | `dynamic` | — | The sample b input consumed by `exactPair`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L83)

<a id="function-function-miniquake-render-evidence-corpus-frame-function-frame-index-src-miniquake-render-evidence-corpus-ml-133734775"></a>
### frame

```ml
function frame(index)
```

Implements the `frame` operation for `miniquake.render_evidence_corpus` (frame).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L60)

<a id="function-function-miniquake-render-evidence-corpus-mapname-function-mapname-index-src-miniquake-render-evidence-corpus-ml-377524111"></a>
### mapName

```ml
function mapName(index)
```

Return map name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L54)

<a id="function-function-miniquake-render-evidence-corpus-minimum-function-minimum-values-src-miniquake-render-evidence-corpus-ml-1432193603"></a>
### minimum

```ml
function minimum(values)
```

Implements the `minimum` operation for `miniquake.render_evidence_corpus` (minimum).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `minimum`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L95)

<a id="function-function-miniquake-render-evidence-corpus-miniprefix-function-miniprefix-root-index-suffix-src-miniquake-render-evidence-corpus-ml-269296990"></a>
### miniPrefix

```ml
function miniPrefix(root, index, suffix)
```

Implements the `miniPrefix` operation for `miniquake.render_evidence_corpus` (mini prefix).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — | The root input consumed by `miniPrefix`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `suffix` | `dynamic` | — | The suffix input consumed by `miniPrefix`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L68)

<a id="function-function-miniquake-render-evidence-corpus-name-function-name-index-src-miniquake-render-evidence-corpus-ml-515818317"></a>
### name

```ml
function name(index)
```

Return name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L48)

<a id="constant-constant-miniquake-render-evidence-corpus-original-ssim-milli-const-original-ssim-milli-950-src-miniquake-render-evidence-corpus-ml-937853932"></a>
### ORIGINAL_SSIM_MILLI

```ml
const ORIGINAL_SSIM_MILLI = 950
```

Defines the original ssim milli value used by `miniquake.render_evidence_corpus`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L20)

<a id="function-function-miniquake-render-evidence-corpus-originalfilename-function-originalfilename-index-src-miniquake-render-evidence-corpus-ml-1151639861"></a>
### originalFileName

```ml
function originalFileName(index)
```

Return original file name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L74)

<a id="function-function-miniquake-render-evidence-corpus-scenario-function-scenario-index-src-miniquake-render-evidence-corpus-ml-868988517"></a>
### scenario

```ml
function scenario(index)
```

Implements the `scenario` operation for `miniquake.render_evidence_corpus` (scenario).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L40)

<a id="function-function-miniquake-render-evidence-corpus-scenarios-function-scenarios-src-miniquake-render-evidence-corpus-ml-1411297955"></a>
### scenarios

```ml
function scenarios()
```

[name, map, frame]


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L25)

<a id="function-function-miniquake-render-evidence-corpus-ssimaccepted-function-ssimaccepted-value-src-miniquake-render-evidence-corpus-ml-234965542"></a>
### ssimAccepted

```ml
function ssimAccepted(value)
```

Implements the `ssimAccepted` operation for `miniquake.render_evidence_corpus` (ssim accepted).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ssimAccepted`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render_evidence_corpus.ml#L89)
