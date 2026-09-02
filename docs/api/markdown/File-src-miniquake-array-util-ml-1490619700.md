# `src/miniquake/array_util.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.array_util`](Package-miniquake-array-util-8661965.md)

Reachable from entry: **yes**

## Declarations

- [miniquake.array_util.ArrayBuilder](Type-miniquake-array-util-arraybuilder-1231250669.md) — struct
<a id="function-function-miniquake-array-util-copyarraylinear-function-copyarraylinear-source-src-miniquake-array-util-ml-903092056"></a>
### copyArrayLinear

```ml
function copyArrayLinear(source)
```

Copy every source element into a new linear array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L45)

<a id="function-function-miniquake-array-util-copyarrayprefix-function-copyarrayprefix-source-count-src-miniquake-array-util-ml-2141450963"></a>
### copyArrayPrefix

```ml
function copyArrayPrefix(source, count)
```

Copy the requested source prefix into a new array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L57)

<a id="function-function-miniquake-array-util-createarraybuilder-function-createarraybuilder-initialcapacity-src-miniquake-array-util-ml-866568347"></a>
### createArrayBuilder

```ml
function createArrayBuilder(initialCapacity)
```

Create and initialize array builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initialCapacity` | `dynamic` | — | The initial capacity input consumed by `createArrayBuilder`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L88)

<a id="function-function-miniquake-array-util-finisharraybuilder-function-finisharraybuilder-builder-src-miniquake-array-util-ml-489140238"></a>
### finishArrayBuilder

```ml
function finishArrayBuilder(builder)
```

Finalize state for finish array builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | The builder input consumed by `finishArrayBuilder`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L113)

<a id="function-function-miniquake-array-util-growarrayto-function-growarrayto-source-requiredcount-fillvalue-src-miniquake-array-util-ml-1864810334"></a>
### growArrayTo

```ml
function growArrayTo(source, requiredCount, fillValue)
```

Ensure sufficient storage or state for array to.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `requiredCount` | `dynamic` | — | Number of entries or units to process. |
| `fillValue` | `dynamic` | — | The fill value input consumed by `growArrayTo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L70)

<a id="function-function-miniquake-array-util-makeemptyarray-function-makeemptyarray-count-src-miniquake-array-util-ml-1074341670"></a>
### makeEmptyArray

```ml
function makeEmptyArray(count)
```

Create an exact-sized array initialized with void slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L39)

<a id="function-function-miniquake-array-util-makefilledarray-function-makefilledarray-count-value-src-miniquake-array-util-ml-2022706363"></a>
### makeFilledArray

```ml
function makeFilledArray(count, value)
```

Create an array prefilled with one value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `value` | `dynamic` | — | Value consumed by `makeFilledArray`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L30)

<a id="function-function-miniquake-array-util-pusharraybuilder-function-pusharraybuilder-builder-value-src-miniquake-array-util-ml-1429407057"></a>
### pushArrayBuilder

```ml
function pushArrayBuilder(builder, value)
```

Add state for push array builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | The builder input consumed by `pushArrayBuilder`. |
| `value` | `dynamic` | — | Value consumed by `pushArrayBuilder`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L97)
