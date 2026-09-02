# `src/miniquake/sound/wav.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.wav`](Package-miniquake-sound-wav-1967420894.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-sound-wav-load-function-load-filename-src-miniquake-sound-wav-ml-2127465651"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.sound.wav` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/wav.ml#L74)

<a id="function-function-miniquake-sound-wav-parse-function-parse-data-filename-src-miniquake-sound-wav-ml-1358616273"></a>
### parse

```ml
function parse(data, filename)
```

Implements the `parse` operation for `miniquake.sound.wav` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/wav.ml#L18)

<a id="function-function-miniquake-sound-wav-resample-function-resample-info-data-targetrate-force8bit-src-miniquake-sound-wav-ml-850676167"></a>
### resample

```ml
function resample(info, data, targetRate, force8Bit)
```

Implements the `resample` operation for `miniquake.sound.wav` (resample).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `info` | `dynamic` | — | The info input consumed by `resample`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `targetRate` | `dynamic` | — | The target rate input consumed by `resample`. |
| `force8Bit` | `dynamic` | — | The force8 bit input consumed by `resample`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/wav.ml#L95)

<a id="function-function-miniquake-sound-wav-sampleat-function-sampleat-info-data-sampleindex-channel-src-miniquake-sound-wav-ml-2097828343"></a>
### sampleAt

```ml
function sampleAt(info, data, sampleIndex, channel)
```

Build deterministic test data for at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `info` | `dynamic` | — | The info input consumed by `sampleAt`. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `sampleIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `channel` | `dynamic` | — | The channel input consumed by `sampleAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/wav.ml#L84)
