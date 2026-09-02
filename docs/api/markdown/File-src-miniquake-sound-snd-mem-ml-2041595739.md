# `src/miniquake/sound/snd_mem.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.snd_mem`](Package-miniquake-sound-snd-mem-722089637.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

- [miniquake.sound.snd_mem.ChunkCursor](Type-miniquake-sound-snd-mem-chunkcursor-1007440468.md) — struct
<a id="function-function-miniquake-sound-snd-mem-chunknameat-function-chunknameat-cursor-offset-src-miniquake-sound-snd-mem-ml-590918599"></a>
### chunkNameAt

```ml
function chunkNameAt(cursor, offset)
```

Implements the `chunkNameAt` operation for `miniquake.sound.snd_mem` (chunk name at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | The cursor input consumed by `chunkNameAt`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L114)

<a id="function-function-miniquake-sound-snd-mem-createcursor-function-createcursor-data-length-src-miniquake-sound-snd-mem-ml-1017728544"></a>
### createCursor

```ml
function createCursor(data, length)
```

Create and initialize cursor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `length` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L80)

<a id="function-function-miniquake-sound-snd-mem-createdescriptor-function-createdescriptor-name-src-miniquake-sound-snd-mem-ml-1915022499"></a>
### createDescriptor

```ml
function createDescriptor(name)
```

Create and initialize descriptor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L73)

<a id="function-function-miniquake-sound-snd-mem-dumpchunks-function-dumpchunks-cursor-src-miniquake-sound-snd-mem-ml-18623146"></a>
### DumpChunks

```ml
function DumpChunks(cursor)
```

Implements the `DumpChunks` operation for `miniquake.sound.snd_mem` (dump chunks).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | The cursor input consumed by `DumpChunks`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L163)

<a id="function-function-miniquake-sound-snd-mem-emptywaveinfo-function-emptywaveinfo-src-miniquake-sound-snd-mem-ml-1839508404"></a>
### emptyWaveInfo

```ml
function emptyWaveInfo()
```

Implements the `emptyWaveInfo` operation for `miniquake.sound.snd_mem` (empty wave info).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L60)

<a id="function-function-miniquake-sound-snd-mem-findchunk-function-findchunk-cursor-name-src-miniquake-sound-snd-mem-ml-251123469"></a>
### FindChunk

```ml
function FindChunk(cursor, name)
```

Return chunk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | The cursor input consumed by `FindChunk`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L156)

<a id="function-function-miniquake-sound-snd-mem-findnextchunk-function-findnextchunk-cursor-name-src-miniquake-sound-snd-mem-ml-28687255"></a>
### FindNextChunk

```ml
function FindNextChunk(cursor, name)
```

Return next chunk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | The cursor input consumed by `FindNextChunk`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L122)

<a id="function-function-miniquake-sound-snd-mem-getlittlelong-function-getlittlelong-cursor-src-miniquake-sound-snd-mem-ml-1405474646"></a>
### GetLittleLong

```ml
function GetLittleLong(cursor)
```

Return little long.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | The cursor input consumed by `GetLittleLong`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L101)

<a id="function-function-miniquake-sound-snd-mem-getlittleshort-function-getlittleshort-cursor-src-miniquake-sound-snd-mem-ml-689097334"></a>
### GetLittleShort

```ml
function GetLittleShort(cursor)
```

Return little short.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | The cursor input consumed by `GetLittleShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L89)

<a id="function-function-miniquake-sound-snd-mem-getwavinfo-function-getwavinfo-name-wav-wavlength-src-miniquake-sound-snd-mem-ml-1635831415"></a>
### GetWavinfo

```ml
function GetWavinfo(name, wav, wavLength)
```

Return wavinfo.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `wav` | `dynamic` | — | The wav input consumed by `GetWavinfo`. |
| `wavLength` | `dynamic` | — | Length of the requested data in units appropriate to the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L182)

<a id="function-function-miniquake-sound-snd-mem-resamplesfx-function-resamplesfx-cache-inrate-inwidth-source-targetrate-loadas8bit-src-miniquake-sound-snd-mem-ml-1085959625"></a>
### ResampleSfx

```ml
function ResampleSfx(cache, inRate, inWidth, source, targetRate, loadAs8Bit)
```

Implements the `ResampleSfx` operation for `miniquake.sound.snd_mem` (resample sfx).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — | The cache input consumed by `ResampleSfx`. |
| `inRate` | `dynamic` | — | The in rate input consumed by `ResampleSfx`. |
| `inWidth` | `dynamic` | — | The in width input consumed by `ResampleSfx`. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `targetRate` | `dynamic` | — | The target rate input consumed by `ResampleSfx`. |
| `loadAs8Bit` | `dynamic` | — | The load as8 bit input consumed by `ResampleSfx`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L252)

<a id="function-function-miniquake-sound-snd-mem-s-alloc-function-s-alloc-size-src-miniquake-sound-snd-mem-ml-2039856863"></a>
### S_Alloc

```ml
function S_Alloc(size)
```

Apply the Quake-compatible s alloc behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L66)

<a id="function-function-miniquake-sound-snd-mem-s-loadsound-function-s-loadsound-filesystem-descriptor-targetrate-loadas8bit-src-miniquake-sound-snd-mem-ml-2077979764"></a>
### S_LoadSound

```ml
function S_LoadSound(filesystem, descriptor, targetRate, loadAs8Bit)
```

Apply the Quake-compatible s load sound behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filesystem` | `dynamic` | — | The filesystem input consumed by `S_LoadSound`. |
| `descriptor` | `dynamic` | — | The descriptor input consumed by `S_LoadSound`. |
| `targetRate` | `dynamic` | — | The target rate input consumed by `S_LoadSound`. |
| `loadAs8Bit` | `dynamic` | — | The load as8 bit input consumed by `S_LoadSound`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L344)

<a id="function-function-miniquake-sound-snd-mem-s-loadsounddata-function-s-loadsounddata-name-data-targetrate-loadas8bit-src-miniquake-sound-snd-mem-ml-666499021"></a>
### S_LoadSoundData

```ml
function S_LoadSoundData(name, data, targetRate, loadAs8Bit)
```

Apply the Quake-compatible s load sound data behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `targetRate` | `dynamic` | — | The target rate input consumed by `S_LoadSoundData`. |
| `loadAs8Bit` | `dynamic` | — | The load as8 bit input consumed by `S_LoadSoundData`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L315)

- [miniquake.sound.snd_mem.SoundCache](Type-miniquake-sound-snd-mem-soundcache-507510690.md) — struct
- [miniquake.sound.snd_mem.SoundDescriptor](Type-miniquake-sound-snd-mem-sounddescriptor-1378067977.md) — struct
<a id="function-function-miniquake-sound-snd-mem-soundf32-function-soundf32-value-src-miniquake-sound-snd-mem-ml-1235311631"></a>
### soundF32

```ml
function soundF32(value)
```

Implements the `soundF32` operation for `miniquake.sound.snd_mem` (sound f32).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `soundF32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L241)

<a id="function-function-miniquake-sound-snd-mem-soundpath-function-soundpath-name-src-miniquake-sound-snd-mem-ml-1474267075"></a>
### soundPath

```ml
function soundPath(name)
```

Return sound path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L333)

<a id="function-function-miniquake-sound-snd-mem-tosoundeffect-function-tosoundeffect-descriptor-src-miniquake-sound-snd-mem-ml-1875160315"></a>
### toSoundEffect

```ml
function toSoundEffect(descriptor)
```

Implements the `toSoundEffect` operation for `miniquake.sound.snd_mem` (to sound effect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `descriptor` | `dynamic` | — | The descriptor input consumed by `toSoundEffect`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/snd_mem.ml#L357)
