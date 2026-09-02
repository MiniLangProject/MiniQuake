# `miniquake.render.original.EfragRef`

[Home](README.md) · [Source file](File-src-miniquake-render-original-ml-563356514.md)

<a id="struct-struct-miniquake-render-original-efragref-struct-efragref-src-miniquake-render-original-ml-1139766641"></a>
## EfragRef

```ml
struct EfragRef
```

Canonical WinQuake 1.09 gl_refrag.c, gl_rmain.c and gl_rmisc.c public surface.  C pointers, fixed arrays and translation-unit globals are mapped to explicit MiniLang object references and package globals.  Rendering and gameplay equations are retained; only platform/pointer storage differs.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L31)

## Members

<a id="field-field-miniquake-render-original-efragref-entity-entity-src-miniquake-render-original-ml-931697919"></a>
### entity

```ml
entity
```

Stores the entity value in `miniquake.render.original.EfragRef`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L33)

<a id="field-field-miniquake-render-original-efragref-leafindex-leafindex-src-miniquake-render-original-ml-143009557"></a>
### leafIndex

```ml
leafIndex
```

Stores the leaf index value in `miniquake.render.original.EfragRef`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/render/original.ml#L35)
