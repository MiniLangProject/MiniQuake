# `miniquake.render.gl_refrag.EfragRef`

[Home](README.md) · [Source file](File-src-miniquake-render-gl-refrag-ml-1270523792.md)

<a id="struct-struct-miniquake-render-gl-refrag-efragref-struct-efragref-src-miniquake-render-gl-refrag-ml-815970599"></a>
## EfragRef

```ml
struct EfragRef
```

Direct MiniLang pendant of WinQuake/gl_refrag.c. Native pointer-linked efrags are represented by shared EfragRef objects in per-entity/per-leaf arrays; insertion, removal, BSP splitting and visible-entity de-duplication retain the original behavior.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L22)

## Members

<a id="field-field-miniquake-render-gl-refrag-efragref-entity-entity-src-miniquake-render-gl-refrag-ml-1592533163"></a>
### entity

```ml
entity
```

Stores the entity value in `miniquake.render.gl_refrag.EfragRef`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L24)

<a id="field-field-miniquake-render-gl-refrag-efragref-leafindex-leafindex-src-miniquake-render-gl-refrag-ml-1770236509"></a>
### leafIndex

```ml
leafIndex
```

Stores the leaf index value in `miniquake.render.gl_refrag.EfragRef`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/gl_refrag.ml#L26)
