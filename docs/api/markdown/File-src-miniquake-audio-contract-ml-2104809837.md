# `src/miniquake/audio_contract.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.audio_contract`](Package-miniquake-audio-contract-1615348166.md)

Reachable from entry: **no**

## Imports

- `miniquake/sound/mixer.ml` as `production` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)
- `miniquake/sound/snd_dma.ml` as `dma` → [src/miniquake/sound/snd_dma.ml](File-src-miniquake-sound-snd-dma-ml-1006726078.md)
- `miniquake/sound/snd_mix.ml` as `mix` → [src/miniquake/sound/snd_mix.ml](File-src-miniquake-sound-snd-mix-ml-831879510.md)
- `miniquake/sound/snd_win.ml` as `win` → [src/miniquake/sound/snd_win.ml](File-src-miniquake-sound-snd-win-ml-1338621206.md)

## Declarations

<a id="constant-constant-miniquake-audio-contract-ambient-channels-const-ambient-channels-4-src-miniquake-audio-contract-ml-1052373082"></a>
### AMBIENT_CHANNELS

```ml
const AMBIENT_CHANNELS = 4
```

Defines the ambient channels value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L26)

<a id="constant-constant-miniquake-audio-contract-binary32-spatial-const-binary32-spatial-1-src-miniquake-audio-contract-ml-2161333"></a>
### BINARY32_SPATIAL

```ml
const BINARY32_SPATIAL = 1
```

Defines the binary32 spatial value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L46)

<a id="constant-constant-miniquake-audio-contract-cd-remap-slots-const-cd-remap-slots-100-src-miniquake-audio-contract-ml-10593781"></a>
### CD_REMAP_SLOTS

```ml
const CD_REMAP_SLOTS = 100
```

Defines the cd remap slots value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L44)

<a id="function-function-miniquake-audio-contract-constants-function-constants-src-miniquake-audio-contract-ml-613538947"></a>
### constants

```ml
function constants()
```

Returns the compatibility constants exposed by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L67)

<a id="constant-constant-miniquake-audio-contract-default-channels-const-default-channels-2-src-miniquake-audio-contract-ml-1490443390"></a>
### DEFAULT_CHANNELS

```ml
const DEFAULT_CHANNELS = 2
```

Defines the default channels value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L42)

<a id="constant-constant-miniquake-audio-contract-default-sample-bits-const-default-sample-bits-16-src-miniquake-audio-contract-ml-1227825417"></a>
### DEFAULT_SAMPLE_BITS

```ml
const DEFAULT_SAMPLE_BITS = 16
```

Defines the default sample bits value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L40)

<a id="constant-constant-miniquake-audio-contract-distinct-ring-regions-const-distinct-ring-regions-1-src-miniquake-audio-contract-ml-866266861"></a>
### DISTINCT_RING_REGIONS

```ml
const DISTINCT_RING_REGIONS = 1
```

Defines the distinct ring regions value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L50)

<a id="constant-constant-miniquake-audio-contract-dynamic-channels-const-dynamic-channels-8-src-miniquake-audio-contract-ml-1313149660"></a>
### DYNAMIC_CHANNELS

```ml
const DYNAMIC_CHANNELS = 8
```

Defines the dynamic channels value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L28)

<a id="constant-constant-miniquake-audio-contract-fingerprint-const-fingerprint-3707215874-src-miniquake-audio-contract-ml-1920116818"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 3707215874
```

Defines the fingerprint value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L20)

<a id="function-function-miniquake-audio-contract-fingerprint-inline-function-fingerprint-src-miniquake-audio-contract-ml-466767626"></a>
### fingerprint

```ml
inline function fingerprint()
```

Returns the compatibility fingerprint for `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L62)

<a id="constant-constant-miniquake-audio-contract-i32-mixer-const-i32-mixer-1-src-miniquake-audio-contract-ml-927868793"></a>
### I32_MIXER

```ml
const I32_MIXER = 1
```

Defines the i32 mixer value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L48)

<a id="constant-constant-miniquake-audio-contract-max-channels-const-max-channels-128-src-miniquake-audio-contract-ml-716404943"></a>
### MAX_CHANNELS

```ml
const MAX_CHANNELS = 128
```

Defines the max channels value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L24)

<a id="constant-constant-miniquake-audio-contract-max-sfx-const-max-sfx-512-src-miniquake-audio-contract-ml-1194893590"></a>
### MAX_SFX

```ml
const MAX_SFX = 512
```

Defines the max sfx value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L22)

<a id="constant-constant-miniquake-audio-contract-nominal-clip-distance-const-nominal-clip-distance-1000-src-miniquake-audio-contract-ml-542905259"></a>
### NOMINAL_CLIP_DISTANCE

```ml
const NOMINAL_CLIP_DISTANCE = 1000
```

Defines the nominal clip distance value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L38)

<a id="constant-constant-miniquake-audio-contract-paintbuffer-frames-const-paintbuffer-frames-512-src-miniquake-audio-contract-ml-477788578"></a>
### PAINTBUFFER_FRAMES

```ml
const PAINTBUFFER_FRAMES = 512
```

Defines the paintbuffer frames value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L30)

<a id="constant-constant-miniquake-audio-contract-quake-atoi-cd-const-quake-atoi-cd-1-src-miniquake-audio-contract-ml-1368477321"></a>
### QUAKE_ATOI_CD

```ml
const QUAKE_ATOI_CD = 1
```

Defines the quake atoi cd value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L52)

<a id="constant-constant-miniquake-audio-contract-retail-evidence-sounds-const-retail-evidence-sounds-2-src-miniquake-audio-contract-ml-1162794478"></a>
### RETAIL_EVIDENCE_SOUNDS

```ml
const RETAIL_EVIDENCE_SOUNDS = 2
```

Defines the retail evidence sounds value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L54)

<a id="constant-constant-miniquake-audio-contract-secondary-buffer-size-const-secondary-buffer-size-65536-src-miniquake-audio-contract-ml-661179583"></a>
### SECONDARY_BUFFER_SIZE

```ml
const SECONDARY_BUFFER_SIZE = 65536
```

Defines the secondary buffer size value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L36)

<a id="constant-constant-miniquake-audio-contract-status-const-status-audio-109-frozen-v1-src-miniquake-audio-contract-ml-1258188828"></a>
### STATUS

```ml
const STATUS = "audio_109_frozen_v1"
```

Defines the status value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L18)

<a id="function-function-miniquake-audio-contract-status-inline-function-status-src-miniquake-audio-contract-ml-1579443228"></a>
### status

```ml
inline function status()
```

Returns the compatibility status reported by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L57)

<a id="function-function-miniquake-audio-contract-verify-function-verify-src-miniquake-audio-contract-ml-1891857149"></a>
### verify

```ml
function verify()
```

Implements the `verify` operation for `miniquake.audio_contract` (verify).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L90)

<a id="constant-constant-miniquake-audio-contract-wav-buffer-size-const-wav-buffer-size-1024-src-miniquake-audio-contract-ml-1453009257"></a>
### WAV_BUFFER_SIZE

```ml
const WAV_BUFFER_SIZE = 1024
```

Defines the wav buffer size value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L34)

<a id="constant-constant-miniquake-audio-contract-wav-buffers-const-wav-buffers-64-src-miniquake-audio-contract-ml-1392799900"></a>
### WAV_BUFFERS

```ml
const WAV_BUFFERS = 64
```

Defines the wav buffers value used by `miniquake.audio_contract`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/audio_contract.ml#L32)
