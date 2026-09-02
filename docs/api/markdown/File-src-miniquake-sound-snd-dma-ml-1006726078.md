# `src/miniquake/sound/snd_dma.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.snd_dma`](Package-miniquake-sound-snd-dma-1940161794.md)

Reachable from entry: **no**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/sound/snd_mem.ml` as `sndmem` → [src/miniquake/sound/snd_mem.ml](File-src-miniquake-sound-snd-mem-ml-2041595739.md)
- `miniquake/sound/snd_mix.ml` as `sndmix` → [src/miniquake/sound/snd_mix.ml](File-src-miniquake-sound-snd-mix-ml-831879510.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-sound-snd-dma-combinestaticchannels-function-combinestaticchannels-system-src-miniquake-sound-snd-dma-ml-667231221"></a>
### combineStaticChannels

```ml
function combineStaticChannels(system)
```

Implements the `combineStaticChannels` operation for `miniquake.sound.snd_dma` (combine static channels).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `combineStaticChannels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L612)

<a id="function-function-miniquake-sound-snd-dma-create-function-create-filesystem-samplerate-src-miniquake-sound-snd-dma-ml-1159037493"></a>
### create

```ml
function create(filesystem, sampleRate)
```

Implements the `create` operation for `miniquake.sound.snd_dma` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `create`. |
| `sampleRate` | `dynamic` | — | The sample rate input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L118)

<a id="constant-constant-miniquake-sound-snd-dma-default-sound-packet-attenuation-const-default-sound-packet-attenuation-1-src-miniquake-sound-snd-dma-ml-149678574"></a>
### DEFAULT_SOUND_PACKET_ATTENUATION

```ml
const DEFAULT_SOUND_PACKET_ATTENUATION = 1.
```

Defines the default sound packet attenuation value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L35)

<a id="constant-constant-miniquake-sound-snd-dma-default-sound-packet-volume-const-default-sound-packet-volume-255-src-miniquake-sound-snd-dma-ml-1464801583"></a>
### DEFAULT_SOUND_PACKET_VOLUME

```ml
const DEFAULT_SOUND_PACKET_VOLUME = 255
```

Defines the default sound packet volume value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L33)

<a id="constant-constant-miniquake-sound-snd-dma-dynamic-first-const-dynamic-first-num-ambients-src-miniquake-sound-snd-dma-ml-62865499"></a>
### DYNAMIC_FIRST

```ml
const DYNAMIC_FIRST = NUM_AMBIENTS
```

Defines the dynamic first value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L27)

<a id="function-function-miniquake-sound-snd-dma-getsoundtime-function-getsoundtime-system-sampleposition-src-miniquake-sound-snd-dma-ml-2038240406"></a>
### GetSoundtime

```ml
function GetSoundtime(system, samplePosition)
```

Return soundtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `GetSoundtime`. |
| `samplePosition` | `dynamic` | — | The sample position input consumed by `GetSoundtime`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L637)

<a id="function-function-miniquake-sound-snd-dma-hasargument-function-hasargument-arguments-wanted-src-miniquake-sound-snd-dma-ml-547675011"></a>
### hasArgument

```ml
function hasArgument(arguments, wanted)
```

Report whether argument.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `wanted` | `dynamic` | — | The wanted input consumed by `hasArgument`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L208)

<a id="function-function-miniquake-sound-snd-dma-hasextension-function-hasextension-name-src-miniquake-sound-snd-dma-ml-1627008621"></a>
### hasExtension

```ml
function hasExtension(name)
```

Report whether extension.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L713)

<a id="constant-constant-miniquake-sound-snd-dma-max-channels-const-max-channels-128-src-miniquake-sound-snd-dma-ml-1702345320"></a>
### MAX_CHANNELS

```ml
const MAX_CHANNELS = 128
```

Defines the max channels value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L21)

<a id="constant-constant-miniquake-sound-snd-dma-max-dynamic-channels-const-max-dynamic-channels-8-src-miniquake-sound-snd-dma-ml-1731120111"></a>
### MAX_DYNAMIC_CHANNELS

```ml
const MAX_DYNAMIC_CHANNELS = 8
```

Defines the max dynamic channels value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L23)

<a id="constant-constant-miniquake-sound-snd-dma-max-sfx-const-max-sfx-512-src-miniquake-sound-snd-dma-ml-746807583"></a>
### MAX_SFX

```ml
const MAX_SFX = 512
```

Defines the max sfx value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L19)

<a id="function-function-miniquake-sound-snd-dma-nextrandom-function-nextrandom-system-src-miniquake-sound-snd-dma-ml-957940091"></a>
### nextRandom

```ml
function nextRandom(system)
```

Return next random for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `nextRandom`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L428)

<a id="constant-constant-miniquake-sound-snd-dma-num-ambients-const-num-ambients-4-src-miniquake-sound-snd-dma-ml-1624738977"></a>
### NUM_AMBIENTS

```ml
const NUM_AMBIENTS = 4
```

Defines the num ambients value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L25)

<a id="function-function-miniquake-sound-snd-dma-s-ambientoff-function-s-ambientoff-system-src-miniquake-sound-snd-dma-ml-1497680051"></a>
### S_AmbientOff

```ml
function S_AmbientOff(system)
```

Apply the Quake-compatible s ambient off behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_AmbientOff`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L218)

<a id="function-function-miniquake-sound-snd-dma-s-ambienton-function-s-ambienton-system-src-miniquake-sound-snd-dma-ml-1876820793"></a>
### S_AmbientOn

```ml
function S_AmbientOn(system)
```

Apply the Quake-compatible s ambient on behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_AmbientOn`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L225)

<a id="function-function-miniquake-sound-snd-dma-s-beginprecaching-function-s-beginprecaching-system-src-miniquake-sound-snd-dma-ml-1338770265"></a>
### S_BeginPrecaching

```ml
function S_BeginPrecaching(system)
```

Apply the Quake-compatible s begin precaching behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_BeginPrecaching`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L798)

<a id="function-function-miniquake-sound-snd-dma-s-clearbuffer-function-s-clearbuffer-system-src-miniquake-sound-snd-dma-ml-460002261"></a>
### S_ClearBuffer

```ml
function S_ClearBuffer(system)
```

Apply the Quake-compatible s clear buffer behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_ClearBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L507)

<a id="function-function-miniquake-sound-snd-dma-s-clearprecache-function-s-clearprecache-system-src-miniquake-sound-snd-dma-ml-162323587"></a>
### S_ClearPrecache

```ml
function S_ClearPrecache(system)
```

Apply the Quake-compatible s clear precache behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_ClearPrecache`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L792)

<a id="function-function-miniquake-sound-snd-dma-s-endprecaching-function-s-endprecaching-system-src-miniquake-sound-snd-dma-ml-971453741"></a>
### S_EndPrecaching

```ml
function S_EndPrecaching(system)
```

Apply the Quake-compatible s end precaching behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_EndPrecaching`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L804)

<a id="function-function-miniquake-sound-snd-dma-s-extraupdate-function-s-extraupdate-system-sampleposition-src-miniquake-sound-snd-dma-ml-1272588232"></a>
### S_ExtraUpdate

```ml
function S_ExtraUpdate(system, samplePosition)
```

Apply the Quake-compatible s extra update behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_ExtraUpdate`. |
| `samplePosition` | `dynamic` | — | The sample position input consumed by `S_ExtraUpdate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L703)

<a id="function-function-miniquake-sound-snd-dma-s-findname-function-s-findname-system-name-src-miniquake-sound-snd-dma-ml-375386368"></a>
### S_FindName

```ml
function S_FindName(system, name)
```

Apply the Quake-compatible s find name behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_FindName`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L321)

<a id="function-function-miniquake-sound-snd-dma-s-init-function-s-init-system-arguments-memorysize-src-miniquake-sound-snd-dma-ml-2017296483"></a>
### S_Init

```ml
function S_Init(system, arguments, memorySize)
```

Apply the Quake-compatible s init behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_Init`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `memorySize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L265)

<a id="function-function-miniquake-sound-snd-dma-s-initpaintchannels-function-s-initpaintchannels-system-src-miniquake-sound-snd-dma-ml-1815856115"></a>
### S_InitPaintChannels

```ml
function S_InitPaintChannels(system)
```

Apply the Quake-compatible s init paint channels behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_InitPaintChannels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L200)

<a id="function-function-miniquake-sound-snd-dma-s-localsound-function-s-localsound-system-sound-src-miniquake-sound-snd-dma-ml-1831932906"></a>
### S_LocalSound

```ml
function S_LocalSound(system, sound)
```

Apply the Quake-compatible s local sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_LocalSound`. |
| `sound` | `dynamic` | — | The sound input consumed by `S_LocalSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L783)

<a id="function-function-miniquake-sound-snd-dma-s-play-function-s-play-system-arguments-src-miniquake-sound-snd-dma-ml-877272673"></a>
### S_Play

```ml
function S_Play(system, arguments)
```

Apply the Quake-compatible s play behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_Play`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L726)

<a id="function-function-miniquake-sound-snd-dma-s-playvol-function-s-playvol-system-arguments-src-miniquake-sound-snd-dma-ml-1135738927"></a>
### S_PlayVol

```ml
function S_PlayVol(system, arguments)
```

Apply the Quake-compatible s play vol behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_PlayVol`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L745)

<a id="function-function-miniquake-sound-snd-dma-s-precachesound-function-s-precachesound-system-name-src-miniquake-sound-snd-dma-ml-1324971704"></a>
### S_PrecacheSound

```ml
function S_PrecacheSound(system, name)
```

Apply the Quake-compatible s precache sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_PrecacheSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L346)

<a id="function-function-miniquake-sound-snd-dma-s-shutdown-function-s-shutdown-system-src-miniquake-sound-snd-dma-ml-1899652631"></a>
### S_Shutdown

```ml
function S_Shutdown(system)
```

Apply the Quake-compatible s shutdown behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L310)

<a id="function-function-miniquake-sound-snd-dma-s-soundinfo-f-function-s-soundinfo-f-system-src-miniquake-sound-snd-dma-ml-1900564099"></a>
### S_SoundInfo_f

```ml
function S_SoundInfo_f(system)
```

Apply the Quake-compatible s sound info f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_SoundInfo_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L232)

<a id="function-function-miniquake-sound-snd-dma-s-soundlist-function-s-soundlist-system-src-miniquake-sound-snd-dma-ml-1541633617"></a>
### S_SoundList

```ml
function S_SoundList(system)
```

Apply the Quake-compatible s sound list behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_SoundList`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L766)

<a id="function-function-miniquake-sound-snd-dma-s-startsound-function-s-startsound-system-entitynumber-entitychannel-descriptor-origin-volume-attenuation-src-miniquake-sound-snd-dma-ml-647402696"></a>
### S_StartSound

```ml
function S_StartSound(system, entityNumber, entityChannel, descriptor, origin, volume, attenuation)
```

Apply the Quake-compatible s start sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_StartSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `S_StartSound`. |
| `entityChannel` | `dynamic` | — | The entity channel input consumed by `S_StartSound`. |
| `descriptor` | `dynamic` | — | The descriptor input consumed by `S_StartSound`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `volume` | `dynamic` | — | The volume input consumed by `S_StartSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `S_StartSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L442)

<a id="function-function-miniquake-sound-snd-dma-s-startup-function-s-startup-system-src-miniquake-sound-snd-dma-ml-1019463949"></a>
### S_Startup

```ml
function S_Startup(system)
```

Apply the Quake-compatible s startup behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_Startup`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L249)

<a id="function-function-miniquake-sound-snd-dma-s-staticsound-function-s-staticsound-system-descriptor-origin-volume-attenuation-src-miniquake-sound-snd-dma-ml-1585738876"></a>
### S_StaticSound

```ml
function S_StaticSound(system, descriptor, origin, volume, attenuation)
```

Apply the Quake-compatible s static sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_StaticSound`. |
| `descriptor` | `dynamic` | — | The descriptor input consumed by `S_StaticSound`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `volume` | `dynamic` | — | The volume input consumed by `S_StaticSound`. |
| `attenuation` | `dynamic` | — | The attenuation input consumed by `S_StaticSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L548)

<a id="function-function-miniquake-sound-snd-dma-s-stopallsounds-function-s-stopallsounds-system-clear-src-miniquake-sound-snd-dma-ml-1675538246"></a>
### S_StopAllSounds

```ml
function S_StopAllSounds(system, clear)
```

Apply the Quake-compatible s stop all sounds behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_StopAllSounds`. |
| `clear` | `dynamic` | — | The clear input consumed by `S_StopAllSounds`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L524)

<a id="function-function-miniquake-sound-snd-dma-s-stopallsoundsc-function-s-stopallsoundsc-system-src-miniquake-sound-snd-dma-ml-1950571515"></a>
### S_StopAllSoundsC

```ml
function S_StopAllSoundsC(system)
```

Apply the Quake-compatible s stop all sounds c behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_StopAllSoundsC`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L538)

<a id="function-function-miniquake-sound-snd-dma-s-stopsound-function-s-stopsound-system-entitynumber-entitychannel-src-miniquake-sound-snd-dma-ml-504527835"></a>
### S_StopSound

```ml
function S_StopSound(system, entityNumber, entityChannel)
```

Apply the Quake-compatible s stop sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_StopSound`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `S_StopSound`. |
| `entityChannel` | `dynamic` | — | The entity channel input consumed by `S_StopSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L489)

<a id="function-function-miniquake-sound-snd-dma-s-touchsound-function-s-touchsound-system-name-src-miniquake-sound-snd-dma-ml-238188272"></a>
### S_TouchSound

```ml
function S_TouchSound(system, name)
```

Apply the Quake-compatible s touch sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_TouchSound`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L336)

<a id="function-function-miniquake-sound-snd-dma-s-update-function-s-update-system-origin-forward-right-up-ambientlevels-frametime-sampleposition-src-miniquake-sound-snd-dma-ml-346599541"></a>
### S_Update

```ml
function S_Update(system, origin, forward, right, up, ambientLevels, frameTime, samplePosition)
```

Apply the Quake-compatible s update behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_Update`. |
| `origin` | `dynamic` | — | World-space origin of the operation. |
| `forward` | `dynamic` | — | The forward input consumed by `S_Update`. |
| `right` | `dynamic` | — | The right input consumed by `S_Update`. |
| `up` | `dynamic` | — | The up input consumed by `S_Update`. |
| `ambientLevels` | `dynamic` | — | The ambient levels input consumed by `S_Update`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |
| `samplePosition` | `dynamic` | — | The sample position input consumed by `S_Update`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L682)

<a id="function-function-miniquake-sound-snd-dma-s-update-function-s-update-system-sampleposition-src-miniquake-sound-snd-dma-ml-53551034"></a>
### S_Update_

```ml
function S_Update_(system, samplePosition)
```

Apply the Quake-compatible s update behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_Update_`. |
| `samplePosition` | `dynamic` | — | The sample position input consumed by `S_Update_`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L657)

<a id="function-function-miniquake-sound-snd-dma-s-updateambientsounds-function-s-updateambientsounds-system-ambientlevels-frametime-src-miniquake-sound-snd-dma-ml-1037225456"></a>
### S_UpdateAmbientSounds

```ml
function S_UpdateAmbientSounds(system, ambientLevels, frameTime)
```

Apply the Quake-compatible s update ambient sounds behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `S_UpdateAmbientSounds`. |
| `ambientLevels` | `dynamic` | — | The ambient levels input consumed by `S_UpdateAmbientSounds`. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L573)

<a id="function-function-miniquake-sound-snd-dma-snd-pickchannel-function-snd-pickchannel-system-entitynumber-entitychannel-src-miniquake-sound-snd-dma-ml-942634661"></a>
### SND_PickChannel

```ml
function SND_PickChannel(system, entityNumber, entityChannel)
```

Mirror Quake's SND_PickChannel routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `SND_PickChannel`. |
| `entityNumber` | `dynamic` | — | The entity number input consumed by `SND_PickChannel`. |
| `entityChannel` | `dynamic` | — | The entity channel input consumed by `SND_PickChannel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L361)

<a id="function-function-miniquake-sound-snd-dma-snd-spatialize-function-snd-spatialize-system-channel-src-miniquake-sound-snd-dma-ml-461126034"></a>
### SND_Spatialize

```ml
function SND_Spatialize(system, channel)
```

Mirror Quake's SND_Spatialize routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `SND_Spatialize`. |
| `channel` | `dynamic` | — | The channel input consumed by `SND_Spatialize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L395)

<a id="function-function-miniquake-sound-snd-dma-snddma-getdmapos-inline-function-snddma-getdmapos-system-src-miniquake-sound-snd-dma-ml-1832705288"></a>
### SNDDMA_GetDMAPos

```ml
inline function SNDDMA_GetDMAPos(system)
```

Mirror Quake's SNDDMA_GetDMAPos routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `SNDDMA_GetDMAPos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L176)

<a id="function-function-miniquake-sound-snd-dma-snddma-init-function-snddma-init-system-src-miniquake-sound-snd-dma-ml-194783603"></a>
### SNDDMA_Init

```ml
function SNDDMA_Init(system)
```

sound.h platform-facing API.  The native DLL owns waveOut handles; the portable sound core only controls its lifetime and supplies PCM blocks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `SNDDMA_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L164)

<a id="function-function-miniquake-sound-snd-dma-snddma-shutdown-function-snddma-shutdown-system-src-miniquake-sound-snd-dma-ml-1233026179"></a>
### SNDDMA_Shutdown

```ml
function SNDDMA_Shutdown(system)
```

Mirror Quake's SNDDMA_Shutdown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `SNDDMA_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L192)

<a id="function-function-miniquake-sound-snd-dma-snddma-submit-function-snddma-submit-system-src-miniquake-sound-snd-dma-ml-528480279"></a>
### SNDDMA_Submit

```ml
function SNDDMA_Submit(system)
```

Mirror Quake's SNDDMA_Submit routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `SNDDMA_Submit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L182)

<a id="constant-constant-miniquake-sound-snd-dma-sound-nominal-clip-distance-const-sound-nominal-clip-distance-1000-src-miniquake-sound-snd-dma-ml-1618640520"></a>
### SOUND_NOMINAL_CLIP_DISTANCE

```ml
const SOUND_NOMINAL_CLIP_DISTANCE = 1000.
```

Defines the sound nominal clip distance value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L31)

<a id="function-function-miniquake-sound-snd-dma-soundf32-function-soundf32-value-src-miniquake-sound-snd-dma-ml-310203243"></a>
### soundF32

```ml
function soundF32(value)
```

Implements the `soundF32` operation for `miniquake.sound.snd_dma` (sound f32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `soundF32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L388)

- [miniquake.sound.snd_dma.SoundSystem](Type-miniquake-sound-snd-dma-soundsystem-685375458.md) — struct
<a id="constant-constant-miniquake-sound-snd-dma-static-first-const-static-first-num-ambients-max-dynamic-channels-src-miniquake-sound-snd-dma-ml-1005579061"></a>
### STATIC_FIRST

```ml
const STATIC_FIRST = NUM_AMBIENTS + MAX_DYNAMIC_CHANNELS
```

Defines the static first value used by `miniquake.sound.snd_dma`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_dma.ml#L29)
