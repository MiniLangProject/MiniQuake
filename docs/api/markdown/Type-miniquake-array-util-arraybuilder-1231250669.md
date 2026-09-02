# `miniquake.array_util.ArrayBuilder`

[Home](README.md) · [Source file](File-src-miniquake-array-util-ml-1490619700.md)

<a id="struct-struct-miniquake-array-util-arraybuilder-struct-arraybuilder-src-miniquake-array-util-ml-392486436"></a>
## ArrayBuilder

```ml
struct ArrayBuilder
```

MiniLang arrays have a fixed length.  Repeatedly growing an array with `values = values + [item]` copies the complete prefix on every iteration, which turns binary-format parsing into O(n^2) allocation traffic.

These helpers create exact-sized arrays in O(n) total copying and provide a
geometrically growing builder for records whose final count is not known in
advance.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L20)

## Members

<a id="field-field-miniquake-array-util-arraybuilder-count-count-src-miniquake-array-util-ml-1165128174"></a>
### count

```ml
count
```

Stores the count value in `miniquake.array_util.ArrayBuilder`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L24)

<a id="field-field-miniquake-array-util-arraybuilder-values-values-src-miniquake-array-util-ml-2047605270"></a>
### values

```ml
values
```

Stores the accumulated values in `miniquake.array_util.ArrayBuilder`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/array_util.ml#L22)
