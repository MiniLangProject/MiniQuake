# `src/miniquake/gl_smoke.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.gl_smoke`](Package-miniquake-gl-smoke-941918578.md)

Reachable from entry: **yes**

## Imports

- `miniquake/platform/win32.ml` as `win` → [src/miniquake/platform/win32.ml](File-src-miniquake-platform-win32-ml-1233303091.md)
- `miniquake/render/gl11.ml` as `gl` → [src/miniquake/render/gl11.ml](File-src-miniquake-render-gl11-ml-805308144.md)

## Declarations

<a id="function-function-miniquake-gl-smoke-draw-function-draw-width-height-src-miniquake-gl-smoke-ml-573955604"></a>
### draw

```ml
function draw(width, height)
```

Implements the `draw` operation for `miniquake.gl_smoke` (draw).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_smoke.ml#L16)

<a id="function-function-miniquake-gl-smoke-run-function-run-src-miniquake-gl-smoke-ml-1760627"></a>
### run

```ml
function run()
```

Implements the `run` operation for `miniquake.gl_smoke` (run).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_smoke.ml#L94)

<a id="function-function-miniquake-gl-smoke-runframes-function-runframes-maxframes-src-miniquake-gl-smoke-ml-761736235"></a>
### runFrames

```ml
function runFrames(maxFrames)
```

Execute frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxFrames` | `dynamic` | — | The max frames input consumed by `runFrames`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_smoke.ml#L60)

<a id="function-function-miniquake-gl-smoke-validatereadback-function-validatereadback-width-height-src-miniquake-gl-smoke-ml-442359444"></a>
### validateReadback

```ml
function validateReadback(width, height)
```

Validate readback and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `dynamic` | — | Requested width in pixels or data units. |
| `height` | `dynamic` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/gl_smoke.ml#L38)
