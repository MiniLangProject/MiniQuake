# `src/miniquake/sound/cd_audio.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.sound.cd_audio`](Package-miniquake-sound-cd-audio-335401106.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/sound/mixer.ml` as `mixer` → [src/miniquake/sound/mixer.ml](File-src-miniquake-sound-mixer-ml-2037667391.md)

## Declarations

<a id="function-function-miniquake-sound-cd-audio-cd-f-function-cd-f-state-arguments-src-miniquake-sound-cd-audio-ml-658892009"></a>
### CD_f

```ml
function CD_f(state, arguments)
```

Mirror Quake's CD_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CD_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L258)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-closedoor-function-cdaudio-closedoor-state-src-miniquake-sound-cd-audio-ml-172845207"></a>
### CDAudio_CloseDoor

```ml
function CDAudio_CloseDoor(state)
```

Mirror Quake's CDAudio_CloseDoor routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_CloseDoor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L327)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-eject-function-cdaudio-eject-state-src-miniquake-sound-cd-audio-ml-1089042681"></a>
### CDAudio_Eject

```ml
function CDAudio_Eject(state)
```

Mirror Quake's CDAudio_Eject routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Eject`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L318)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-getaudiodiskinfo-function-cdaudio-getaudiodiskinfo-state-src-miniquake-sound-cd-audio-ml-2123375411"></a>
### CDAudio_GetAudioDiskInfo

```ml
function CDAudio_GetAudioDiskInfo(state)
```

Mirror Quake's CDAudio_GetAudioDiskInfo routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_GetAudioDiskInfo`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L334)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-init-function-cdaudio-init-state-src-miniquake-sound-cd-audio-ml-656118131"></a>
### CDAudio_Init

```ml
function CDAudio_Init(state)
```

Mirror Quake's CDAudio_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L108)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-messagehandler-function-cdaudio-messagehandler-state-notification-devicematches-src-miniquake-sound-cd-audio-ml-807884487"></a>
### CDAudio_MessageHandler

```ml
function CDAudio_MessageHandler(state, notification, deviceMatches)
```

Mirror Quake's CDAudio_MessageHandler routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_MessageHandler`. |
| `notification` | `dynamic` | — | The notification input consumed by `CDAudio_MessageHandler`. |
| `deviceMatches` | `dynamic` | — | The device matches input consumed by `CDAudio_MessageHandler`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L349)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-pause-function-cdaudio-pause-state-src-miniquake-sound-cd-audio-ml-1379131803"></a>
### CDAudio_Pause

```ml
function CDAudio_Pause(state)
```

Mirror Quake's CDAudio_Pause routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Pause`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L166)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-play-function-cdaudio-play-state-requestedtrack-looping-src-miniquake-sound-cd-audio-ml-1525944004"></a>
### CDAudio_Play

```ml
function CDAudio_Play(state, requestedTrack, looping)
```

Mirror Quake's CDAudio_Play routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Play`. |
| `requestedTrack` | `dynamic` | — | The requested track input consumed by `CDAudio_Play`. |
| `looping` | `dynamic` | — | The looping input consumed by `CDAudio_Play`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L126)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-resume-function-cdaudio-resume-state-src-miniquake-sound-cd-audio-ml-1498071591"></a>
### CDAudio_Resume

```ml
function CDAudio_Resume(state)
```

Mirror Quake's CDAudio_Resume routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Resume`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L176)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-shutdown-function-cdaudio-shutdown-state-src-miniquake-sound-cd-audio-ml-1019685235"></a>
### CDAudio_Shutdown

```ml
function CDAudio_Shutdown(state)
```

Mirror Quake's CDAudio_Shutdown routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Shutdown`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L208)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-stop-function-cdaudio-stop-state-src-miniquake-sound-cd-audio-ml-795563291"></a>
### CDAudio_Stop

```ml
function CDAudio_Stop(state)
```

Mirror Quake's CDAudio_Stop routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Stop`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L156)

<a id="function-function-miniquake-sound-cd-audio-cdaudio-update-function-cdaudio-update-state-requestedvolume-src-miniquake-sound-cd-audio-ml-1092523467"></a>
### CDAudio_Update

```ml
function CDAudio_Update(state, requestedVolume)
```

Mirror Quake's CDAudio_Update routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `CDAudio_Update`. |
| `requestedVolume` | `dynamic` | — | The requested volume input consumed by `CDAudio_Update`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L186)

- [miniquake.sound.cd_audio.CdAudioState](Type-miniquake-sound-cd-audio-cdaudiostate-423221984.md) — struct
<a id="function-function-miniquake-sound-cd-audio-create-function-create-mixerstate-maxtrack-src-miniquake-sound-cd-audio-ml-1963385265"></a>
### create

```ml
function create(mixerState, maxTrack)
```

Implements the `create` operation for `miniquake.sound.cd_audio` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixerState` | `dynamic` | — | Mutable state used by `create`. |
| `maxTrack` | `dynamic` | — | The max track input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L65)

<a id="global-global-miniquake-sound-cd-audio-defaultstate-defaultstate-src-miniquake-sound-cd-audio-ml-1400668686"></a>
### defaultState

```ml
defaultState
```

Tracks the default module-level CD-audio state owned by `miniquake.sound.cd_audio`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L49)

<a id="function-function-miniquake-sound-cd-audio-ensure-function-ensure-mixerstate-src-miniquake-sound-cd-audio-ml-1841566610"></a>
### ensure

```ml
function ensure(mixerState)
```

Ensure sufficient storage or state for the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixerState` | `dynamic` | — | Mutable state used by `ensure`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L86)

<a id="function-function-miniquake-sound-cd-audio-identityremap-function-identityremap-src-miniquake-sound-cd-audio-ml-975845654"></a>
### identityRemap

```ml
function identityRemap()
```

Implements the `identityRemap` operation for `miniquake.sound.cd_audio` (identity remap).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L52)

<a id="function-function-miniquake-sound-cd-audio-infotext-function-infotext-state-src-miniquake-sound-cd-audio-ml-1402278755"></a>
### infoText

```ml
function infoText(state)
```

Implements the `infoText` operation for `miniquake.sound.cd_audio` (info text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `infoText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L240)

<a id="constant-constant-miniquake-sound-cd-audio-mci-notify-aborted-const-mci-notify-aborted-4-src-miniquake-sound-cd-audio-ml-771584311"></a>
### MCI_NOTIFY_ABORTED

```ml
const MCI_NOTIFY_ABORTED = 4
```

Defines the mci notify aborted value used by `miniquake.sound.cd_audio`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L312)

<a id="constant-constant-miniquake-sound-cd-audio-mci-notify-failure-const-mci-notify-failure-8-src-miniquake-sound-cd-audio-ml-147248753"></a>
### MCI_NOTIFY_FAILURE

```ml
const MCI_NOTIFY_FAILURE = 8
```

Defines the mci notify failure value used by `miniquake.sound.cd_audio`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L314)

<a id="constant-constant-miniquake-sound-cd-audio-mci-notify-successful-const-mci-notify-successful-1-src-miniquake-sound-cd-audio-ml-878450788"></a>
### MCI_NOTIFY_SUCCESSFUL

```ml
const MCI_NOTIFY_SUCCESSFUL = 1
```

--------------------------------------------------------------------------- WinQuake cd_win.c source-surface technical equivalents.

Physical MCI tray and media-notification operations do not exist in the
modern OGG backend. These adapters preserve all game-observable state
transitions and the original public names while documenting the mechanical
drive operation as a technical equivalent.
---------------------------------------------------------------------------


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L308)

<a id="constant-constant-miniquake-sound-cd-audio-mci-notify-superseded-const-mci-notify-superseded-2-src-miniquake-sound-cd-audio-ml-775462197"></a>
### MCI_NOTIFY_SUPERSEDED

```ml
const MCI_NOTIFY_SUPERSEDED = 2
```

Defines the mci notify superseded value used by `miniquake.sound.cd_audio`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L310)

<a id="function-function-miniquake-sound-cd-audio-release-function-release-mixerstate-src-miniquake-sound-cd-audio-ml-1669115632"></a>
### release

```ml
function release(mixerState)
```

Release or remove state for the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mixerState` | `dynamic` | — | Mutable state used by `release`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L98)

<a id="function-function-miniquake-sound-cd-audio-remapcommand-function-remapcommand-state-arguments-src-miniquake-sound-cd-audio-ml-1650890777"></a>
### remapCommand

```ml
function remapCommand(state, arguments)
```

Implements the `remapCommand` operation for `miniquake.sound.cd_audio` (remap command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.sound.cd_audio` state used by `remapCommand`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/sound/cd_audio.ml#L218)
