# `src/miniquake/sound/mixer.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.mixer`](Package-miniquake-sound-mixer-1744263025.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/audio.ml` as `audio` → [src/miniquake/audio.ml](File-src-miniquake-audio-ml-122971530.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/sound/snd_mem.ml` as `sndmem` → [src/miniquake/sound/snd_mem.ml](File-src-miniquake-sound-snd-mem-ml-2041595739.md)
- `miniquake/sound/wav.ml` as `wav` → [src/miniquake/sound/wav.ml](File-src-miniquake-sound-wav-ml-1458929962.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `miniquake/world_bsp.ml` as `soundWorld` → [src/miniquake/world_bsp.ml](File-src-miniquake-world-bsp-ml-1111600182.md)

## Declarations

<a id="constant-constant-miniquake-sound-mixer-ambient-water-entity-const-ambient-water-entity-1001-src-miniquake-sound-mixer-ml-800998634"></a>
### AMBIENT_WATER_ENTITY

```ml
const AMBIENT_WATER_ENTITY = -1001
```

Defines the ambient water entity value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L34)

<a id="constant-constant-miniquake-sound-mixer-ambient-wind-entity-const-ambient-wind-entity-1002-src-miniquake-sound-mixer-ml-2021306443"></a>
### AMBIENT_WIND_ENTITY

```ml
const AMBIENT_WIND_ENTITY = -1002
```

Defines the ambient wind entity value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L36)

<a id="function-function-miniquake-sound-mixer-ambienttarget-function-ambienttarget-levelbyte-ambientlevel-src-miniquake-sound-mixer-ml-1782967790"></a>
### ambientTarget

```ml
function ambientTarget(levelByte, ambientLevel)
```

Implements the `ambientTarget` operation for `miniquake.sound.mixer` (ambient target).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `levelByte` | `dynamic` | — | The level byte input consumed by `ambientTarget`. |
| `ambientLevel` | `dynamic` | — | The ambient level input consumed by `ambientTarget`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L770)

<a id="function-function-miniquake-sound-mixer-block-function-block-mixer-src-miniquake-sound-mixer-ml-1481582205"></a>
### block

```ml
function block(mixer)
```

S_BlockSound/S_UnblockSound production counterpart.  waveOutReset flushes all queued headers on the first nesting level; no painting/submission takes place until the matching final unblock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `block`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L123)

<a id="function-function-miniquake-sound-mixer-blockdepth-function-blockdepth-mixer-src-miniquake-sound-mixer-ml-1920989727"></a>
### blockDepth

```ml
function blockDepth(mixer)
```

Implements the `blockDepth` operation for `miniquake.sound.mixer` (block depth).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `blockDepth`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L143)

<a id="function-function-miniquake-sound-mixer-channelvolumes-function-channelvolumes-mixer-channel-src-miniquake-sound-mixer-ml-708760976"></a>
### channelVolumes

```ml
function channelVolumes(mixer, channel)
```

Implements the `channelVolumes` operation for `miniquake.sound.mixer` (channel volumes).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `channelVolumes`. |
| `channel` | `dynamic` | — | The channel input consumed by `channelVolumes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L865)

<a id="function-function-miniquake-sound-mixer-channelvolumesinto-function-channelvolumesinto-mixer-channel-leftvalues-rightvalues-index-src-miniquake-sound-mixer-ml-124249815"></a>
### channelVolumesInto

```ml
function channelVolumesInto(mixer, channel, leftValues, rightValues, index)
```

Calculate one channel's stereo volumes into reusable parallel arrays.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `channelVolumesInto`. |
| `channel` | `dynamic` | — | The channel input consumed by `channelVolumesInto`. |
| `leftValues` | `dynamic` | — | The left values input consumed by `channelVolumesInto`. |
| `rightValues` | `dynamic` | — | The right values input consumed by `channelVolumesInto`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L822)

<a id="function-function-miniquake-sound-mixer-clampsample-function-clampsample-value-src-miniquake-sound-mixer-ml-1622980877"></a>
### clampSample

```ml
function clampSample(value)
```

Return a validated clamp sample value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `clampSample`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L810)

<a id="function-function-miniquake-sound-mixer-close-function-close-mixer-src-miniquake-sound-mixer-ml-1785449143"></a>
### close

```ml
function close(mixer)
```

Implements the `close` operation for `miniquake.sound.mixer` (close).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `close`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L243)

<a id="function-function-miniquake-sound-mixer-converttomono16-function-converttomono16-info-source-targetrate-src-miniquake-sound-mixer-ml-2043105482"></a>
### convertToMono16

```ml
function convertToMono16(info, source, targetRate)
```

Convert data for convert to mono16.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `info` | `dynamic` | — | The info input consumed by `convertToMono16`. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `targetRate` | `dynamic` | — | The target rate input consumed by `convertToMono16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L270)

<a id="function-function-miniquake-sound-mixer-create-function-create-filesystem-samplerate-src-miniquake-sound-mixer-ml-1471321391"></a>
### create

```ml
function create(filesystem, sampleRate)
```

Implements the `create` operation for `miniquake.sound.mixer` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `create`. |
| `sampleRate` | `dynamic` | — | The sample rate input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L67)

<a id="function-function-miniquake-sound-mixer-decodemusicchunk-function-decodemusicchunk-track-restart-src-miniquake-sound-mixer-ml-291134866"></a>
### decodeMusicChunk

```ml
function decodeMusicChunk(track, restart)
```

Read and validate music chunk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `track` | `dynamic` | — | The track input consumed by `decodeMusicChunk`. |
| `restart` | `dynamic` | — | The restart input consumed by `decodeMusicChunk`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L221)

<a id="function-function-miniquake-sound-mixer-desiredqueuedbuffers-function-desiredqueuedbuffers-mixer-frametime-mixahead-src-miniquake-sound-mixer-ml-986545860"></a>
### desiredQueuedBuffers

```ml
function desiredQueuedBuffers(mixer, frameTime, mixAhead)
```

Implements the `desiredQueuedBuffers` operation for `miniquake.sound.mixer` (desired queued buffers).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `desiredQueuedBuffers`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `mixAhead` | `dynamic` | — | The mix ahead input consumed by `desiredQueuedBuffers`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L1170)

<a id="function-function-miniquake-sound-mixer-discardoldestchannel-function-discardoldestchannel-mixer-newentitynumber-src-miniquake-sound-mixer-ml-1913471763"></a>
### discardOldestChannel

```ml
function discardOldestChannel(mixer, newEntityNumber)
```

Release or consume state for discard oldest channel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `discardOldestChannel`. |
| `newEntityNumber` | `dynamic` | — | The new entity number input consumed by `discardOldestChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L410)

<a id="function-function-miniquake-sound-mixer-dynamicchannelcount-function-dynamicchannelcount-mixer-src-miniquake-sound-mixer-ml-1190483773"></a>
### dynamicChannelCount

```ml
function dynamicChannelCount(mixer)
```

Return dynamic channel count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `dynamicChannelCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L347)

<a id="function-function-miniquake-sound-mixer-effectindex-function-effectindex-mixer-name-src-miniquake-sound-mixer-ml-719868894"></a>
### effectIndex

```ml
function effectIndex(mixer, name)
```

Return effect index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `effectIndex`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L257)

<a id="function-function-miniquake-sound-mixer-ensureambientchannel-function-ensureambientchannel-mixer-entitynumber-channelnumber-name-src-miniquake-sound-mixer-ml-2002682324"></a>
### ensureAmbientChannel

```ml
function ensureAmbientChannel(mixer, entityNumber, channelNumber, name)
```

Ensure sufficient storage or state for ambient channel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `ensureAmbientChannel`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `ensureAmbientChannel`. |
| `channelNumber` | `dynamic` | — | The channel number input consumed by `ensureAmbientChannel`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L724)

<a id="function-function-miniquake-sound-mixer-fadeambientchannel-function-fadeambientchannel-channel-target-step-origin-src-miniquake-sound-mixer-ml-283758292"></a>
### fadeAmbientChannel

```ml
function fadeAmbientChannel(channel, target, step, origin)
```

Implements the `fadeAmbientChannel` operation for `miniquake.sound.mixer` (fade ambient channel).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `fadeAmbientChannel`. |
| `target` | `dynamic` | — | The target input consumed by `fadeAmbientChannel`. |
| `step` | `dynamic` | — | The step input consumed by `fadeAmbientChannel`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L751)

<a id="function-function-miniquake-sound-mixer-findchannel-function-findchannel-mixer-entitynumber-channelnumber-src-miniquake-sound-mixer-ml-509631023"></a>
### findChannel

```ml
function findChannel(mixer, entityNumber, channelNumber)
```

Return channel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `findChannel`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `findChannel`. |
| `channelNumber` | `dynamic` | — | The channel number input consumed by `findChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L330)

<a id="function-function-miniquake-sound-mixer-hasextension-function-hasextension-name-src-miniquake-sound-mixer-ml-1147392151"></a>
### hasExtension

```ml
function hasExtension(name)
```

Report whether extension.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L540)

<a id="function-function-miniquake-sound-mixer-isdynamicchannel-function-isdynamicchannel-channel-src-miniquake-sound-mixer-ml-263636757"></a>
### isDynamicChannel

```ml
function isDynamicChannel(channel)
```

Report whether is dynamic channel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `dynamic` | — | The channel input consumed by `isDynamicChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L339)

<a id="function-function-miniquake-sound-mixer-loadeffect-function-loadeffect-mixer-name-src-miniquake-sound-mixer-ml-77217816"></a>
### loadEffect

```ml
function loadEffect(mixer, name)
```

Read and validate effect.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `loadEffect`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L291)

<a id="function-function-miniquake-sound-mixer-localsound-function-localsound-mixer-name-src-miniquake-sound-mixer-ml-506855220"></a>
### localSound

```ml
function localSound(mixer, name)
```

Implements the `localSound` operation for `miniquake.sound.mixer` (local sound).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `localSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L531)

<a id="constant-constant-miniquake-sound-mixer-max-channels-const-max-channels-128-src-miniquake-sound-mixer-ml-1518355148"></a>
### MAX_CHANNELS

```ml
const MAX_CHANNELS = 128
```

Defines the max channels value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L32)

<a id="constant-constant-miniquake-sound-mixer-max-dynamic-channels-const-max-dynamic-channels-8-src-miniquake-sound-mixer-ml-1132959923"></a>
### MAX_DYNAMIC_CHANNELS

```ml
const MAX_DYNAMIC_CHANNELS = 8
```

Defines the max dynamic channels value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L40)

<a id="constant-constant-miniquake-sound-mixer-max-queued-buffers-const-max-queued-buffers-7-src-miniquake-sound-mixer-ml-500267706"></a>
### MAX_QUEUED_BUFFERS

```ml
const MAX_QUEUED_BUFFERS = 7
```

Defines the max queued buffers value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L30)

<a id="constant-constant-miniquake-sound-mixer-min-queued-buffers-const-min-queued-buffers-3-src-miniquake-sound-mixer-ml-2038384510"></a>
### MIN_QUEUED_BUFFERS

```ml
const MIN_QUEUED_BUFFERS = 3
```

Defines the min queued buffers value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L28)

<a id="function-function-miniquake-sound-mixer-mix-function-mix-mixer-framecount-src-miniquake-sound-mixer-ml-1862234171"></a>
### mix

```ml
function mix(mixer, frameCount)
```

Mix the requested value into the active audio buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mix`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L1091)

<a id="constant-constant-miniquake-sound-mixer-mix-frames-const-mix-frames-512-src-miniquake-sound-mixer-ml-863078971"></a>
### MIX_FRAMES

```ml
const MIX_FRAMES = 512
```

WinQuake reserves 128 software channels.  The former 32-channel limit could evict looping/static sounds very quickly on a populated retail map.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L24)

<a id="function-function-miniquake-sound-mixer-mixchannel-function-mixchannel-mixer-channel-accumulator-framecount-src-miniquake-sound-mixer-ml-1559025432"></a>
### mixChannel

```ml
function mixChannel(mixer, channel, accumulator, frameCount)
```

Mix channel into the active audio buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mixChannel`. |
| `channel` | `dynamic` | — | The channel input consumed by `mixChannel`. |
| `accumulator` | `dynamic` | — | The accumulator input consumed by `mixChannel`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L959)

<a id="function-function-miniquake-sound-mixer-mixchannelwithstereovolumes-function-mixchannelwithstereovolumes-mixer-channel-accumulator-framecount-leftvolumevalue-rightvolumevalue-src-miniquake-sound-mixer-ml-1076050395"></a>
### mixChannelWithStereoVolumes

```ml
function mixChannelWithStereoVolumes(mixer, channel, accumulator, frameCount, leftVolumeValue, rightVolumeValue)
```

Mix a channel using scalar stereo volumes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mixChannelWithStereoVolumes`. |
| `channel` | `dynamic` | — | The channel input consumed by `mixChannelWithStereoVolumes`. |
| `accumulator` | `dynamic` | — | The accumulator input consumed by `mixChannelWithStereoVolumes`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `leftVolumeValue` | `dynamic` | — | The left volume value input consumed by `mixChannelWithStereoVolumes`. |
| `rightVolumeValue` | `dynamic` | — | The right volume value input consumed by `mixChannelWithStereoVolumes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L878)

<a id="function-function-miniquake-sound-mixer-mixchannelwithvolumes-function-mixchannelwithvolumes-mixer-channel-accumulator-framecount-volumes-src-miniquake-sound-mixer-ml-1279367109"></a>
### mixChannelWithVolumes

```ml
function mixChannelWithVolumes(mixer, channel, accumulator, frameCount, volumes)
```

Mix channel with volumes into the active audio buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mixChannelWithVolumes`. |
| `channel` | `dynamic` | — | The channel input consumed by `mixChannelWithVolumes`. |
| `accumulator` | `dynamic` | — | The accumulator input consumed by `mixChannelWithVolumes`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `volumes` | `dynamic` | — | The volumes input consumed by `mixChannelWithVolumes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L950)

<a id="function-function-miniquake-sound-mixer-mixerf32-function-mixerf32-value-src-miniquake-sound-mixer-ml-1405270315"></a>
### mixerF32

```ml
function mixerF32(value)
```

Implements the `mixerF32` operation for `miniquake.sound.mixer` (mixer f32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `mixerF32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L434)

<a id="function-function-miniquake-sound-mixer-mixforsubmit-function-mixforsubmit-mixer-framecount-src-miniquake-sound-mixer-ml-277649079"></a>
### mixForSubmit

```ml
function mixForSubmit(mixer, frameCount)
```

Paint one backend block into the reusable submission buffer. audioSubmit copies the samples synchronously into its fixed waveOut header ring.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mixForSubmit`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L1100)

<a id="function-function-miniquake-sound-mixer-mixintooutput-function-mixintooutput-mixer-framecount-output-src-miniquake-sound-mixer-ml-922058300"></a>
### mixIntoOutput

```ml
function mixIntoOutput(mixer, frameCount, output)
```

Mix into a caller-owned PCM buffer using persistent paint scratch storage.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mixIntoOutput`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |
| `output` | `dynamic` | — | Destination buffer that receives mixed PCM samples. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L967)

<a id="function-function-miniquake-sound-mixer-mixmusic-function-mixmusic-mixer-accumulator-framecount-src-miniquake-sound-mixer-ml-442723297"></a>
### mixMusic

```ml
function mixMusic(mixer, accumulator, frameCount)
```

Mix music into the active audio buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `mixMusic`. |
| `accumulator` | `dynamic` | — | The accumulator input consumed by `mixMusic`. |
| `frameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L1111)

<a id="constant-constant-miniquake-sound-mixer-music-decode-frames-const-music-decode-frames-4096-src-miniquake-sound-mixer-ml-858988396"></a>
### MUSIC_DECODE_FRAMES

```ml
const MUSIC_DECODE_FRAMES = 4096
```

Defines the music decode frames value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L26)

<a id="function-function-miniquake-sound-mixer-musicinfo-function-musicinfo-mixer-src-miniquake-sound-mixer-ml-1050248337"></a>
### musicInfo

```ml
function musicInfo(mixer)
```

Implements the `musicInfo` operation for `miniquake.sound.mixer` (music info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `musicInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L631)

<a id="function-function-miniquake-sound-mixer-nextrandom-function-nextrandom-src-miniquake-sound-mixer-ml-304139996"></a>
### nextRandom

```ml
function nextRandom()
```

Return next random for the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L417)

<a id="function-function-miniquake-sound-mixer-open-function-open-mixer-src-miniquake-sound-mixer-ml-1959748579"></a>
### open

```ml
function open(mixer)
```

Implements the `open` operation for `miniquake.sound.mixer` (open).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `open`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L95)

<a id="global-global-miniquake-sound-mixer-paintaccumulatorscratch-paintaccumulatorscratch-src-miniquake-sound-mixer-ml-1253943766"></a>
### paintAccumulatorScratch

```ml
paintAccumulatorScratch
```

S_PaintChannels owns fixed paint/volume buffers in the original engine. Keep equivalent reusable storage so a real-time 44.1-kHz stream does not allocate several large arrays for every 512-sample block.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L50)

<a id="global-global-miniquake-sound-mixer-paintleftvolumescratch-paintleftvolumescratch-src-miniquake-sound-mixer-ml-1018631912"></a>
### paintLeftVolumeScratch

```ml
paintLeftVolumeScratch
```

Tracks the module-level paint left volume scratch state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L52)

<a id="global-global-miniquake-sound-mixer-paintoutputscratch-paintoutputscratch-src-miniquake-sound-mixer-ml-1797108252"></a>
### paintOutputScratch

```ml
paintOutputScratch
```

Tracks the module-level paint output scratch state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L62)

<a id="global-global-miniquake-sound-mixer-paintrightvolumescratch-paintrightvolumescratch-src-miniquake-sound-mixer-ml-2139892850"></a>
### paintRightVolumeScratch

```ml
paintRightVolumeScratch
```

Tracks the module-level paint right volume scratch state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L54)

<a id="global-global-miniquake-sound-mixer-paintstaticeffectscratch-paintstaticeffectscratch-src-miniquake-sound-mixer-ml-734480236"></a>
### paintStaticEffectScratch

```ml
paintStaticEffectScratch
```

Tracks the module-level paint static effect scratch state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L58)

<a id="global-global-miniquake-sound-mixer-paintstaticrepresentativescratch-paintstaticrepresentativescratch-src-miniquake-sound-mixer-ml-1084831948"></a>
### paintStaticRepresentativeScratch

```ml
paintStaticRepresentativeScratch
```

Tracks the module-level paint static representative scratch state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L60)

<a id="global-global-miniquake-sound-mixer-paintsurvivorscratch-paintsurvivorscratch-src-miniquake-sound-mixer-ml-496630146"></a>
### paintSurvivorScratch

```ml
paintSurvivorScratch
```

Tracks the module-level paint survivor scratch state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L56)

<a id="function-function-miniquake-sound-mixer-pausemusic-function-pausemusic-mixer-src-miniquake-sound-mixer-ml-1850428423"></a>
### pauseMusic

```ml
function pauseMusic(mixer)
```

Implements the `pauseMusic` operation for `miniquake.sound.mixer` (pause music).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `pauseMusic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L159)

<a id="function-function-miniquake-sound-mixer-pickdynamicchannel-function-pickdynamicchannel-mixer-newentitynumber-newchannelnumber-src-miniquake-sound-mixer-ml-948514095"></a>
### pickDynamicChannel

```ml
function pickDynamicChannel(mixer, newEntityNumber, newChannelNumber)
```

SND_PickChannel scans the fixed eight dynamic slots in order.  A matching non-zero entity channel wins immediately; otherwise the sound with the shortest remaining life is replaced, while a listener sound is protected from a non-listener replacement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `pickDynamicChannel`. |
| `newEntityNumber` | `dynamic` | — | The new entity number input consumed by `pickDynamicChannel`. |
| `newChannelNumber` | `dynamic` | — | The new channel number input consumed by `pickDynamicChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L378)

<a id="function-function-miniquake-sound-mixer-play-function-play-mixer-arguments-src-miniquake-sound-mixer-ml-672575275"></a>
### play

```ml
function play(mixer, arguments)
```

Play the requested value through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `play`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L551)

<a id="function-function-miniquake-sound-mixer-playmusic-function-playmusic-mixer-track-looping-src-miniquake-sound-mixer-ml-1372767542"></a>
### playMusic

```ml
function playMusic(mixer, track, looping)
```

Play music through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `playMusic`. |
| `track` | `dynamic` | — | The track input consumed by `playMusic`. |
| `looping` | `dynamic` | — | The looping input consumed by `playMusic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L177)

<a id="function-function-miniquake-sound-mixer-playvol-function-playvol-mixer-arguments-src-miniquake-sound-mixer-ml-591703049"></a>
### playVol

```ml
function playVol(mixer, arguments)
```

Play vol through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `playVol`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L568)

<a id="function-function-miniquake-sound-mixer-precache-function-precache-mixer-names-src-miniquake-sound-mixer-ml-552061711"></a>
### precache

```ml
function precache(mixer, names)
```

Preload and register the the requested value asset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `precache`. |
| `names` | `dynamic` | — | The names input consumed by `precache`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L309)

<a id="global-global-miniquake-sound-mixer-randomseed-randomseed-src-miniquake-sound-mixer-ml-1013745938"></a>
### randomSeed

```ml
randomSeed
```

Tracks the module-level random seed state owned by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L45)

<a id="function-function-miniquake-sound-mixer-removechannelat-function-removechannelat-mixer-victim-src-miniquake-sound-mixer-ml-768882483"></a>
### removeChannelAt

```ml
function removeChannelAt(mixer, victim)
```

Release state for remove channel at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `removeChannelAt`. |
| `victim` | `dynamic` | — | The victim input consumed by `removeChannelAt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L358)

<a id="function-function-miniquake-sound-mixer-resumemusic-function-resumemusic-mixer-src-miniquake-sound-mixer-ml-1060782575"></a>
### resumeMusic

```ml
function resumeMusic(mixer)
```

Implements the `resumeMusic` operation for `miniquake.sound.mixer` (resume music).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `resumeMusic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L167)

<a id="function-function-miniquake-sound-mixer-setlistenerentity-function-setlistenerentity-mixer-entitynumber-src-miniquake-sound-mixer-ml-532217823"></a>
### setListenerEntity

```ml
function setListenerEntity(mixer, entityNumber)
```

Update module state for listener entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `setListenerEntity`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `setListenerEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L673)

<a id="function-function-miniquake-sound-mixer-setrandomseed-function-setrandomseed-seed-src-miniquake-sound-mixer-ml-1168821925"></a>
### setRandomSeed

```ml
function setRandomSeed(seed)
```

Update module state for random seed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `seed` | `dynamic` | — | The seed input consumed by `setRandomSeed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L426)

<a id="function-function-miniquake-sound-mixer-soundinfo-function-soundinfo-mixer-src-miniquake-sound-mixer-ml-1175865801"></a>
### soundInfo

```ml
function soundInfo(mixer)
```

Implements the `soundInfo` operation for `miniquake.sound.mixer` (sound info).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `soundInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L600)

<a id="function-function-miniquake-sound-mixer-soundlist-function-soundlist-mixer-src-miniquake-sound-mixer-ml-1287499777"></a>
### soundList

```ml
function soundList(mixer)
```

Implements the `soundList` operation for `miniquake.sound.mixer` (sound list).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `soundList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L587)

<a id="function-function-miniquake-sound-mixer-startsound-function-startsound-mixer-entitynumber-channelnumber-name-origin-volume-attenuation-src-miniquake-sound-mixer-ml-423691002"></a>
### startSound

```ml
function startSound(mixer, entityNumber, channelNumber, name, origin, volume, attenuation)
```

Initialize state for start sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `startSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `startSound`. |
| `channelNumber` | `dynamic` | — | The channel number input consumed by `startSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `volume` | `dynamic` | — | The volume input consumed by `startSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `startSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L446)

<a id="constant-constant-miniquake-sound-mixer-static-channel-const-static-channel-32768-src-miniquake-sound-mixer-ml-414850376"></a>
### STATIC_CHANNEL

```ml
const STATIC_CHANNEL = -32768
```

Defines the static channel value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L38)

<a id="constant-constant-miniquake-sound-mixer-static-first-const-static-first-12-src-miniquake-sound-mixer-ml-1314056684"></a>
### STATIC_FIRST

```ml
const STATIC_FIRST = 12
```

Defines the static first value used by `miniquake.sound.mixer`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L42)

<a id="function-function-miniquake-sound-mixer-staticsound-function-staticsound-mixer-name-origin-volume-attenuation-src-miniquake-sound-mixer-ml-720461364"></a>
### staticSound

```ml
function staticSound(mixer, name, origin, volume, attenuation)
```

Implements the `staticSound` operation for `miniquake.sound.mixer` (static sound).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `staticSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `volume` | `dynamic` | — | The volume input consumed by `staticSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `staticSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L506)

<a id="function-function-miniquake-sound-mixer-stopall-function-stopall-mixer-src-miniquake-sound-mixer-ml-1386432389"></a>
### stopAll

```ml
function stopAll(mixer)
```

Finalize state for stop all.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `stopAll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L109)

<a id="function-function-miniquake-sound-mixer-stopmusic-function-stopmusic-mixer-src-miniquake-sound-mixer-ml-1366866125"></a>
### stopMusic

```ml
function stopMusic(mixer)
```

Finalize state for stop music.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `stopMusic`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L150)

<a id="function-function-miniquake-sound-mixer-stopsound-function-stopsound-mixer-entitynumber-channelnumber-src-miniquake-sound-mixer-ml-593032661"></a>
### stopSound

```ml
function stopSound(mixer, entityNumber, channelNumber)
```

Finalize state for stop sound.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `stopSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `stopSound`. |
| `channelNumber` | `dynamic` | — | The channel number input consumed by `stopSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L651)

<a id="function-function-miniquake-sound-mixer-unblock-function-unblock-mixer-src-miniquake-sound-mixer-ml-243195855"></a>
### unblock

```ml
function unblock(mixer)
```

Implements the `unblock` operation for `miniquake.sound.mixer` (unblock).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `unblock`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L135)

<a id="function-function-miniquake-sound-mixer-update-function-update-mixer-frametime-mixahead-src-miniquake-sound-mixer-ml-209347200"></a>
### update

```ml
function update(mixer, frameTime, mixAhead)
```

Implements the `update` operation for `miniquake.sound.mixer` (update).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `update`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `mixAhead` | `dynamic` | — | The mix ahead input consumed by `update`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L1188)

<a id="function-function-miniquake-sound-mixer-updateambient-function-updateambient-mixer-map-origin-frametime-ambientlevel-ambientfade-src-miniquake-sound-mixer-ml-667695069"></a>
### updateAmbient

```ml
function updateAmbient(mixer, map, origin, frameTime, ambientLevel, ambientFade)
```

S_UpdateAmbientSounds: BSP leaves contain four ambient bytes.  Stock Quake uses slot 0 for water and slot 1 for wind and fades them at ambient_fade.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `updateAmbient`. |
| `map` | `dynamic` | — | The map input consumed by `updateAmbient`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `ambientLevel` | `dynamic` | — | The ambient level input consumed by `updateAmbient`. |
| `ambientFade` | `dynamic` | — | The ambient fade input consumed by `updateAmbient`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L784)

<a id="function-function-miniquake-sound-mixer-updateentityorigins-function-updateentityorigins-mixer-entities-src-miniquake-sound-mixer-ml-2009171170"></a>
### updateEntityOrigins

```ml
function updateEntityOrigins(mixer, entities)
```

Update module state for entity origins.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `updateEntityOrigins`. |
| `entities` | `dynamic` | — | The entities input consumed by `updateEntityOrigins`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L701)

<a id="function-function-miniquake-sound-mixer-updatelistener-function-updatelistener-mixer-origin-forward-right-src-miniquake-sound-mixer-ml-1398514008"></a>
### updateListener

```ml
function updateListener(mixer, origin, forward, right)
```

Update module state for listener.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixer` | `dynamic` | — | The mixer input consumed by `updateListener`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `forward` | `dynamic` | — | The forward input consumed by `updateListener`. |
| `right` | `dynamic` | — | The right input consumed by `updateListener`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/mixer.ml#L683)
