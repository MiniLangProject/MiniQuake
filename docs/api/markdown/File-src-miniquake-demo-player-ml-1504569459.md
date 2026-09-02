# `src/miniquake/demo_player.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.demo_player`](Package-miniquake-demo-player-1120670004.md)

Reachable from entry: **yes**

## Imports

- `miniquake/client.ml` as `client` → [src/miniquake/client.ml](File-src-miniquake-client-ml-1164576599.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/player_move.ml` as `movement` → [src/miniquake/player_move.ml](File-src-miniquake-player-move-ml-856575161.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-demo-player-cl-finishtimedemo-function-cl-finishtimedemo-playback-hostframecount-realtime-src-miniquake-demo-player-ml-1369557913"></a>
### CL_FinishTimeDemo

```ml
function CL_FinishTimeDemo(playback, hostFrameCount, realtime)
```

Apply the Quake-compatible cl finish time demo behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `CL_FinishTimeDemo`. |
| `hostFrameCount` | `dynamic` | — | Number of entries or units to process. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L44)

<a id="function-function-miniquake-demo-player-cl-getmessage-function-cl-getmessage-playback-hostframecount-realtime-src-miniquake-demo-player-ml-159369005"></a>
### CL_GetMessage

```ml
function CL_GetMessage(playback, hostFrameCount, realtime)
```

Apply the Quake-compatible cl get message behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `CL_GetMessage`. |
| `hostFrameCount` | `dynamic` | — | Number of entries or units to process. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L89)

<a id="function-function-miniquake-demo-player-cl-stopplayback-function-cl-stopplayback-playback-hostframecount-realtime-src-miniquake-demo-player-ml-1963873925"></a>
### CL_StopPlayback

```ml
function CL_StopPlayback(playback, hostFrameCount, realtime)
```

Apply the Quake-compatible cl stop playback behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `CL_StopPlayback`. |
| `hostFrameCount` | `dynamic` | — | Number of entries or units to process. |
| `realtime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L61)

<a id="function-function-miniquake-demo-player-cl-timedemo-f-function-cl-timedemo-f-playback-hostframecount-src-miniquake-demo-player-ml-785924744"></a>
### CL_TimeDemo_f

```ml
function CL_TimeDemo_f(playback, hostFrameCount)
```

Apply the Quake-compatible cl time demo f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `CL_TimeDemo_f`. |
| `hostFrameCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L75)

<a id="function-function-miniquake-demo-player-create-function-create-recording-src-miniquake-demo-player-ml-1577486578"></a>
### create

```ml
function create(recording)
```

Implements the `create` operation for `miniquake.demo_player` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recording` | `dynamic` | — | The recording input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L19)

<a id="function-function-miniquake-demo-player-playall-function-playall-playback-src-miniquake-demo-player-ml-1351996350"></a>
### playAll

```ml
function playAll(playback)
```

Play all through the active media subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `playAll`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L182)

<a id="function-function-miniquake-demo-player-printreport-function-printreport-report-src-miniquake-demo-player-ml-1622771717"></a>
### printReport

```ml
function printReport(report)
```

Implements the `printReport` operation for `miniquake.demo_player` (print report).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `report` | `dynamic` | — | The report input consumed by `printReport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L222)

<a id="function-function-miniquake-demo-player-processmessage-function-processmessage-playback-item-src-miniquake-demo-player-ml-1718061627"></a>
### processMessage

```ml
function processMessage(playback, item)
```

Execute message.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `processMessage`. |
| `item` | `dynamic` | — | The item input consumed by `processMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L120)

<a id="function-function-miniquake-demo-player-step-function-step-playback-src-miniquake-demo-player-ml-1188371604"></a>
### step

```ml
function step(playback)
```

Implements the `step` operation for `miniquake.demo_player` (step).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `step`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L161)

<a id="function-function-miniquake-demo-player-stepframe-function-stepframe-playback-hostframecount-realtime-frametime-src-miniquake-demo-player-ml-398594425"></a>
### stepFrame

```ml
function stepFrame(playback, hostFrameCount, realtime, frameTime)
```

Advance frame by one processing step.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `playback` | `dynamic` | — | The playback input consumed by `stepFrame`. |
| `hostFrameCount` | `dynamic` | — | Number of entries or units to process. |
| `realtime` | `dynamic` | — | Time value used by the operation. |
| `frameTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L137)

<a id="function-function-miniquake-demo-player-verify-function-verify-recording-src-miniquake-demo-player-ml-1161178450"></a>
### verify

```ml
function verify(recording)
```

Implements the `verify` operation for `miniquake.demo_player` (verify).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recording` | `dynamic` | — | The recording input consumed by `verify`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo_player.ml#L192)
