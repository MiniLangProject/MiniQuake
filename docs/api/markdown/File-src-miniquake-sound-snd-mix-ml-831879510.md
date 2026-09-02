# `src/miniquake/sound/snd_mix.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.snd_mix`](Package-miniquake-sound-snd-mix-1038892922.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/sound/snd_mem.ml` as `sndmem` → [src/miniquake/sound/snd_mem.ml](File-src-miniquake-sound-snd-mem-ml-2041595739.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-sound-snd-mix-clamp16-function-clamp16-value-src-miniquake-sound-snd-mix-ml-948143379"></a>
### clamp16

```ml
function clamp16(value)
```

Clamps 16 for `miniquake.sound.snd_mix`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `clamp16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L202)

<a id="function-function-miniquake-sound-snd-mix-clearpaintbuffer-function-clearpaintbuffer-state-framecount-src-miniquake-sound-snd-mix-ml-783115243"></a>
### clearPaintBuffer

```ml
function clearPaintBuffer(state, frameCount)
```

Update module state for paint buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `clearPaintBuffer`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L333)

<a id="function-function-miniquake-sound-snd-mix-createchannel-function-createchannel-src-miniquake-sound-snd-mix-ml-153528740"></a>
### createChannel

```ml
function createChannel()
```

Create and initialize channel.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L124)

<a id="function-function-miniquake-sound-snd-mix-createdma-function-createdma-speed-samplebits-channels-samples-src-miniquake-sound-snd-mix-ml-1975560702"></a>
### createDma

```ml
function createDma(speed, sampleBits, channels, samples)
```

Create and initialize dma.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `speed` | `dynamic` | — | The speed input consumed by `createDma`. |
| `sampleBits` | `dynamic` | — | The sample bits input consumed by `createDma`. |
| `channels` | `dynamic` | — | Number of interleaved audio channels. |
| `samples` | `dynamic` | — | The samples input consumed by `createDma`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L104)

<a id="function-function-miniquake-sound-snd-mix-createstate-function-createstate-dma-src-miniquake-sound-snd-mix-ml-686143030"></a>
### createState

```ml
function createState(dma)
```

Creates state for `miniquake.sound.snd_mix`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dma` | `dynamic` | — | The dma input consumed by `createState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L159)

- [miniquake.sound.snd_mix.DmaSoundBuffer](Type-miniquake-sound-snd-mix-dmasoundbuffer-189812775.md) — struct
<a id="constant-constant-miniquake-sound-snd-mix-max-channels-const-max-channels-128-src-miniquake-sound-snd-mix-ml-1070815272"></a>
### MAX_CHANNELS

```ml
const MAX_CHANNELS = 128
```

Defines the max channels value used by `miniquake.sound.snd_mix`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L19)

- [miniquake.sound.snd_mix.MixState](Type-miniquake-sound-snd-mix-mixstate-778428823.md) — struct
<a id="constant-constant-miniquake-sound-snd-mix-paintbuffer-size-const-paintbuffer-size-512-src-miniquake-sound-snd-mix-ml-1395725497"></a>
### PAINTBUFFER_SIZE

```ml
const PAINTBUFFER_SIZE = 512
```

Defines the paintbuffer size value used by `miniquake.sound.snd_mix`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L17)

<a id="function-function-miniquake-sound-snd-mix-resetchannel-function-resetchannel-channel-src-miniquake-sound-snd-mix-ml-1351272445"></a>
### resetChannel

```ml
function resetChannel(channel)
```

Update module state for channel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `resetChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L142)

<a id="function-function-miniquake-sound-snd-mix-s-paintchannels-function-s-paintchannels-state-endtime-src-miniquake-sound-snd-mix-ml-509133729"></a>
### S_PaintChannels

```ml
function S_PaintChannels(state, endTime)
```

Apply the Quake-compatible s paint channels behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `S_PaintChannels`. |
| `endTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L344)

<a id="function-function-miniquake-sound-snd-mix-s-transferpaintbuffer-function-s-transferpaintbuffer-state-endtime-src-miniquake-sound-snd-mix-ml-217051207"></a>
### S_TransferPaintBuffer

```ml
function S_TransferPaintBuffer(state, endTime)
```

Apply the Quake-compatible s transfer paint buffer behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `S_TransferPaintBuffer`. |
| `endTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L263)

<a id="function-function-miniquake-sound-snd-mix-s-transferstereo16-function-s-transferstereo16-state-endtime-src-miniquake-sound-snd-mix-ml-45166825"></a>
### S_TransferStereo16

```ml
function S_TransferStereo16(state, endTime)
```

Apply the Quake-compatible s transfer stereo16 behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `S_TransferStereo16`. |
| `endTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L239)

<a id="function-function-miniquake-sound-snd-mix-signedbyte-function-signedbyte-value-src-miniquake-sound-snd-mix-ml-219595451"></a>
### signedByte

```ml
function signedByte(value)
```

Return signed byte derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `signedByte`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L186)

<a id="function-function-miniquake-sound-snd-mix-snd-initscaletable-function-snd-initscaletable-state-src-miniquake-sound-snd-mix-ml-1699664279"></a>
### SND_InitScaletable

```ml
function SND_InitScaletable(state)
```

Mirror Quake's SND_InitScaletable routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `SND_InitScaletable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L210)

<a id="function-function-miniquake-sound-snd-mix-snd-paintchannelfrom16-function-snd-paintchannelfrom16-state-channel-cache-count-src-miniquake-sound-snd-mix-ml-21623551"></a>
### SND_PaintChannelFrom16

```ml
function SND_PaintChannelFrom16(state, channel, cache, count)
```

Mirror Quake's SND_PaintChannelFrom16 routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `SND_PaintChannelFrom16`. |
| `channel` | `dynamic` | — | The channel input consumed by `SND_PaintChannelFrom16`. |
| `cache` | `dynamic` | — | The cache input consumed by `SND_PaintChannelFrom16`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L316)

<a id="function-function-miniquake-sound-snd-mix-snd-paintchannelfrom8-function-snd-paintchannelfrom8-state-channel-cache-count-src-miniquake-sound-snd-mix-ml-294684809"></a>
### SND_PaintChannelFrom8

```ml
function SND_PaintChannelFrom8(state, channel, cache, count)
```

Mirror Quake's SND_PaintChannelFrom8 routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `SND_PaintChannelFrom8`. |
| `channel` | `dynamic` | — | The channel input consumed by `SND_PaintChannelFrom8`. |
| `cache` | `dynamic` | — | The cache input consumed by `SND_PaintChannelFrom8`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L295)

<a id="function-function-miniquake-sound-snd-mix-snd-writelinearblaststereo16-function-snd-writelinearblaststereo16-state-src-miniquake-sound-snd-mix-ml-39740999"></a>
### Snd_WriteLinearBlastStereo16

```ml
function Snd_WriteLinearBlastStereo16(state)
```

Mirror Quake's Snd_WriteLinearBlastStereo16 routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.snd_mix` state used by `Snd_WriteLinearBlastStereo16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L225)

- [miniquake.sound.snd_mix.SoundChannel](Type-miniquake-sound-snd-mix-soundchannel-376593162.md) — struct
<a id="function-function-miniquake-sound-snd-mix-soundi32-function-soundi32-value-src-miniquake-sound-snd-mix-ml-1969929103"></a>
### soundI32

```ml
function soundI32(value)
```

Implements the `soundI32` operation for `miniquake.sound.snd_mix` (sound i32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `soundI32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mix.ml#L194)
