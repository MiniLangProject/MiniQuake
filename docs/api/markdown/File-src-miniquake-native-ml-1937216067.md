# `src/miniquake/native.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.native`](Package-miniquake-native-159137540.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-miniquake-native-asciichar-function-asciichar-value-src-miniquake-native-ml-1140847812"></a>
### asciiChar

```ml
function asciiChar(value)
```

Implements the `asciiChar` operation for `miniquake.native` (ascii char).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `asciiChar`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1596)

<a id="extern_function-extern-function-miniquake-native-asciicharraw-extern-function-asciicharraw-value-as-i32-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-ascii-char-returns-u32-src-miniquake-native-ml-198456323"></a>
### asciiCharRaw

```ml
extern function asciiCharRaw(value as i32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_ascii_char" returns u32
```

Invokes the native `asciiCharRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `i32` | — | Value consumed by `asciiCharRaw`. |
| `output` | `bytes` | — | Destination buffer that receives the encoded character. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `asciiCharRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L117)

<a id="extern_function-extern-function-miniquake-native-asciicode-extern-function-asciicode-text-as-cstr-from-miniquake-native-dll-symbol-mq-ascii-code-returns-i32-src-miniquake-native-ml-300806128"></a>
### asciiCode

```ml
extern function asciiCode(text as cstr) from "miniquake_native.dll" symbol "mq_ascii_code" returns i32
```

Invokes the native `asciiCode` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `cstr` | — | Text to parse or process. |


**Returns:** The `i32` result produced by `asciiCode`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L107)

<a id="function-function-miniquake-native-atan2-function-atan2-y-x-src-miniquake-native-ml-847862334"></a>
### atan2

```ml
function atan2(y, x)
```

Implements the `atan2` operation for `miniquake.native` (atan2).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `y` | `dynamic` | — | The y input consumed by `atan2`. |
| `x` | `dynamic` | — | The x input consumed by `atan2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1728)

<a id="extern_function-extern-function-miniquake-native-audiocapacity-extern-function-audiocapacity-from-miniquake-native-dll-symbol-mq-audio-capacity-returns-u32-src-miniquake-native-ml-764213937"></a>
### audioCapacity

```ml
extern function audioCapacity() from "miniquake_native.dll" symbol "mq_audio_capacity" returns u32
```

Invokes the native `audioCapacity` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `audioCapacity`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L853)

<a id="extern_function-extern-function-miniquake-native-audioclose-extern-function-audioclose-from-miniquake-native-dll-symbol-mq-audio-close-returns-void-src-miniquake-native-ml-883598759"></a>
### audioClose

```ml
extern function audioClose() from "miniquake_native.dll" symbol "mq_audio_close" returns void
```

Invokes the native `audioClose` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L795)

<a id="extern_function-extern-function-miniquake-native-audiocompleted-extern-function-audiocompleted-from-miniquake-native-dll-symbol-mq-audio-completed-returns-u32-src-miniquake-native-ml-490320740"></a>
### audioCompleted

```ml
extern function audioCompleted() from "miniquake_native.dll" symbol "mq_audio_completed" returns u32
```

Invokes the native `audioCompleted` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `audioCompleted`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L831)

<a id="extern_function-extern-function-miniquake-native-audioheaderstate-extern-function-audioheaderstate-index-as-u32-from-miniquake-native-dll-symbol-mq-audio-header-state-returns-u32-src-miniquake-native-ml-593262782"></a>
### audioHeaderState

```ml
extern function audioHeaderState(index as u32) from "miniquake_native.dll" symbol "mq_audio_header_state" returns u32
```

Invokes the native `audioHeaderState` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `u32` | — | Zero-based index of the requested entry. |


**Returns:** The `u32` result produced by `audioHeaderState`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L846)

<a id="extern_function-extern-function-miniquake-native-audioisopen-extern-function-audioisopen-from-miniquake-native-dll-symbol-mq-audio-is-open-returns-i32-src-miniquake-native-ml-1640593194"></a>
### audioIsOpen

```ml
extern function audioIsOpen() from "miniquake_native.dll" symbol "mq_audio_is_open" returns i32
```

Invokes the native `audioIsOpen` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `audioIsOpen`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L860)

<a id="extern_function-extern-function-miniquake-native-audioopen-extern-function-audioopen-samplerate-as-u32-channels-as-u32-bitspersample-as-u32-from-miniquake-native-dll-symbol-mq-audio-open-returns-i32-src-miniquake-native-ml-1183209620"></a>
### audioOpen

```ml
extern function audioOpen(sampleRate as u32, channels as u32, bitsPerSample as u32) from "miniquake_native.dll" symbol "mq_audio_open" returns i32
```

Invokes the native `audioOpen` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sampleRate` | `u32` | — | The sample rate input consumed by `audioOpen`. |
| `channels` | `u32` | — | Number of interleaved audio channels. |
| `bitsPerSample` | `u32` | — | The bits per sample input consumed by `audioOpen`. |


**Returns:** The `i32` result produced by `audioOpen`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L780)

<a id="extern_function-extern-function-miniquake-native-audioposition-extern-function-audioposition-samplemask-as-u32-from-miniquake-native-dll-symbol-mq-audio-position-returns-u32-src-miniquake-native-ml-129915054"></a>
### audioPosition

```ml
extern function audioPosition(sampleMask as u32) from "miniquake_native.dll" symbol "mq_audio_position" returns u32
```

Invokes the native `audioPosition` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sampleMask` | `u32` | — | The sample mask input consumed by `audioPosition`. |


**Returns:** The `u32` result produced by `audioPosition`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L817)

<a id="extern_function-extern-function-miniquake-native-audioqueued-extern-function-audioqueued-from-miniquake-native-dll-symbol-mq-audio-queued-returns-u32-src-miniquake-native-ml-1990843746"></a>
### audioQueued

```ml
extern function audioQueued() from "miniquake_native.dll" symbol "mq_audio_queued" returns u32
```

Invokes the native `audioQueued` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `audioQueued`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L802)

<a id="extern_function-extern-function-miniquake-native-audioreset-extern-function-audioreset-from-miniquake-native-dll-symbol-mq-audio-reset-returns-i32-src-miniquake-native-ml-718224046"></a>
### audioReset

```ml
extern function audioReset() from "miniquake_native.dll" symbol "mq_audio_reset" returns i32
```

Invokes the native `audioReset` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `audioReset`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L809)

<a id="extern_function-extern-function-miniquake-native-audiosubmit-extern-function-audiosubmit-data-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-audio-submit-returns-i32-src-miniquake-native-ml-2056907037"></a>
### audioSubmit

```ml
extern function audioSubmit(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_audio_submit" returns i32
```

Invokes the native `audioSubmit` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `audioSubmit`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L789)

<a id="extern_function-extern-function-miniquake-native-audiosubmitted-extern-function-audiosubmitted-from-miniquake-native-dll-symbol-mq-audio-submitted-returns-u32-src-miniquake-native-ml-1700477020"></a>
### audioSubmitted

```ml
extern function audioSubmitted() from "miniquake_native.dll" symbol "mq_audio_submitted" returns u32
```

Invokes the native `audioSubmitted` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `audioSubmitted`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L824)

<a id="extern_function-extern-function-miniquake-native-audiounderruns-extern-function-audiounderruns-from-miniquake-native-dll-symbol-mq-audio-underruns-returns-u32-src-miniquake-native-ml-975459257"></a>
### audioUnderruns

```ml
extern function audioUnderruns() from "miniquake_native.dll" symbol "mq_audio_underruns" returns u32
```

Invokes the native `audioUnderruns` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `audioUnderruns`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L838)

<a id="function-function-miniquake-native-bitsfloat-function-bitsfloat-bits-src-miniquake-native-ml-420330249"></a>
### bitsFloat

```ml
function bitsFloat(bits)
```

Implements the `bitsFloat` operation for `miniquake.native` (bits float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `dynamic` | — | The bits input consumed by `bitsFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1678)

<a id="extern_function-extern-function-miniquake-native-conprocclosehandle-extern-function-conprocclosehandle-handle-as-u64-from-miniquake-native-dll-symbol-mq-conproc-close-handle-returns-void-src-miniquake-native-ml-1931211313"></a>
### conprocCloseHandle

```ml
extern function conprocCloseHandle(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_close_handle" returns void
```

Invokes the native `conprocCloseHandle` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `conprocCloseHandle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L664)

<a id="extern_function-extern-function-miniquake-native-conproccreateevent-extern-function-conproccreateevent-from-miniquake-native-dll-symbol-mq-conproc-create-event-returns-u64-src-miniquake-native-ml-624048617"></a>
### conprocCreateEvent

```ml
extern function conprocCreateEvent() from "miniquake_native.dll" symbol "mq_conproc_create_event" returns u64
```

Invokes the native `conprocCreateEvent` bridge operation used by `miniquake.native`.


**Returns:** The `u64` result produced by `conprocCreateEvent`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L649)

<a id="extern_function-extern-function-miniquake-native-conprocmap-extern-function-conprocmap-handle-as-u64-from-miniquake-native-dll-symbol-mq-conproc-map-returns-ptr-src-miniquake-native-ml-351354778"></a>
### conprocMap

```ml
extern function conprocMap(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_map" returns ptr
```

Invokes the native `conprocMap` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `conprocMap`. |


**Returns:** The `ptr` result produced by `conprocMap`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L682)

<a id="function-function-miniquake-native-conprocreadconsoletext-function-conprocreadconsoletext-beginline-endline-src-miniquake-native-ml-1124787763"></a>
### conprocReadConsoleText

```ml
function conprocReadConsoleText(beginLine, endLine)
```

Implements the `conprocReadConsoleText` operation for `miniquake.native` (conproc read console text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beginLine` | `dynamic` | — | The begin line input consumed by `conprocReadConsoleText`. |
| `endLine` | `dynamic` | — | The end line input consumed by `conprocReadConsoleText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1612)

<a id="extern_function-extern-function-miniquake-native-conprocreadconsoletextraw-extern-function-conprocreadconsoletextraw-beginline-as-i32-endline-as-i32-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-conproc-read-console-text-returns-u32-src-miniquake-native-ml-1304279865"></a>
### conprocReadConsoleTextRaw

```ml
extern function conprocReadConsoleTextRaw(beginLine as i32, endLine as i32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_conproc_read_console_text" returns u32
```

Invokes the native `conprocReadConsoleTextRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `beginLine` | `i32` | — | The begin line input consumed by `conprocReadConsoleTextRaw`. |
| `endLine` | `i32` | — | The end line input consumed by `conprocReadConsoleTextRaw`. |
| `output` | `bytes` | — | Destination buffer that receives console text. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `conprocReadConsoleTextRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L757)

<a id="extern_function-extern-function-miniquake-native-conprocreadi32-extern-function-conprocreadi32-mapped-as-ptr-index-as-u32-from-miniquake-native-dll-symbol-mq-conproc-read-i32-returns-i32-src-miniquake-native-ml-2007738855"></a>
### conprocReadI32

```ml
extern function conprocReadI32(mapped as ptr, index as u32) from "miniquake_native.dll" symbol "mq_conproc_read_i32" returns i32
```

Invokes the native `conprocReadI32` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `ptr` | — | The mapped input consumed by `conprocReadI32`. |
| `index` | `u32` | — | Zero-based index of the requested entry. |


**Returns:** The `i32` result produced by `conprocReadI32`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L699)

<a id="function-function-miniquake-native-conprocreadtext-function-conprocreadtext-mapped-byteoffset-src-miniquake-native-ml-607025897"></a>
### conprocReadText

```ml
function conprocReadText(mapped, byteOffset)
```

Implements the `conprocReadText` operation for `miniquake.native` (conproc read text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `dynamic` | — | The mapped input consumed by `conprocReadText`. |
| `byteOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1604)

<a id="extern_function-extern-function-miniquake-native-conprocreadtextraw-extern-function-conprocreadtextraw-mapped-as-ptr-byteoffset-as-u32-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-conproc-read-text-returns-u32-src-miniquake-native-ml-913396261"></a>
### conprocReadTextRaw

```ml
extern function conprocReadTextRaw(mapped as ptr, byteOffset as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_conproc_read_text" returns u32
```

Invokes the native `conprocReadTextRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `ptr` | — | The mapped input consumed by `conprocReadTextRaw`. |
| `byteOffset` | `u32` | — | Zero-based offset of the requested data. |
| `output` | `bytes` | — | Destination buffer that receives process text. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `conprocReadTextRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L719)

<a id="extern_function-extern-function-miniquake-native-conprocscreenlines-extern-function-conprocscreenlines-from-miniquake-native-dll-symbol-mq-conproc-screen-lines-returns-i32-src-miniquake-native-ml-687605009"></a>
### conprocScreenLines

```ml
extern function conprocScreenLines() from "miniquake_native.dll" symbol "mq_conproc_screen_lines" returns i32
```

Invokes the native `conprocScreenLines` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `conprocScreenLines`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L737)

<a id="extern_function-extern-function-miniquake-native-conprocsetevent-extern-function-conprocsetevent-handle-as-u64-from-miniquake-native-dll-symbol-mq-conproc-set-event-returns-i32-src-miniquake-native-ml-307184665"></a>
### conprocSetEvent

```ml
extern function conprocSetEvent(handle as u64) from "miniquake_native.dll" symbol "mq_conproc_set_event" returns i32
```

Invokes the native `conprocSetEvent` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `conprocSetEvent`. |


**Returns:** The `i32` result produced by `conprocSetEvent`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L657)

<a id="extern_function-extern-function-miniquake-native-conprocsetscreensize-extern-function-conprocsetscreensize-width-as-i32-height-as-i32-from-miniquake-native-dll-symbol-mq-conproc-set-screen-size-returns-i32-src-miniquake-native-ml-516924885"></a>
### conprocSetScreenSize

```ml
extern function conprocSetScreenSize(width as i32, height as i32) from "miniquake_native.dll" symbol "mq_conproc_set_screen_size" returns i32
```

Invokes the native `conprocSetScreenSize` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |


**Returns:** The `i32` result produced by `conprocSetScreenSize`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L746)

<a id="extern_function-extern-function-miniquake-native-conprocunmap-extern-function-conprocunmap-mapped-as-ptr-from-miniquake-native-dll-symbol-mq-conproc-unmap-returns-i32-src-miniquake-native-ml-1639169983"></a>
### conprocUnmap

```ml
extern function conprocUnmap(mapped as ptr) from "miniquake_native.dll" symbol "mq_conproc_unmap" returns i32
```

Invokes the native `conprocUnmap` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `ptr` | — | The mapped input consumed by `conprocUnmap`. |


**Returns:** The `i32` result produced by `conprocUnmap`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L690)

<a id="extern_function-extern-function-miniquake-native-conprocwaitany-extern-function-conprocwaitany-first-as-u64-second-as-u64-milliseconds-as-u32-from-miniquake-native-dll-symbol-mq-conproc-wait-any-returns-i32-src-miniquake-native-ml-686827377"></a>
### conprocWaitAny

```ml
extern function conprocWaitAny(first as u64, second as u64, milliseconds as u32) from "miniquake_native.dll" symbol "mq_conproc_wait_any" returns i32
```

Invokes the native `conprocWaitAny` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `u64` | — | The first input consumed by `conprocWaitAny`. |
| `second` | `u64` | — | The second input consumed by `conprocWaitAny`. |
| `milliseconds` | `u32` | — | The milliseconds input consumed by `conprocWaitAny`. |


**Returns:** The `i32` result produced by `conprocWaitAny`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L674)

<a id="extern_function-extern-function-miniquake-native-conprocwritei32-extern-function-conprocwritei32-mapped-as-ptr-index-as-u32-value-as-i32-from-miniquake-native-dll-symbol-mq-conproc-write-i32-returns-void-src-miniquake-native-ml-957368061"></a>
### conprocWriteI32

```ml
extern function conprocWriteI32(mapped as ptr, index as u32, value as i32) from "miniquake_native.dll" symbol "mq_conproc_write_i32" returns void
```

Invokes the native `conprocWriteI32` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `ptr` | — | The mapped input consumed by `conprocWriteI32`. |
| `index` | `u32` | — | Zero-based index of the requested entry. |
| `value` | `i32` | — | Value consumed by `conprocWriteI32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L708)

<a id="extern_function-extern-function-miniquake-native-conprocwritekey-extern-function-conprocwritekey-character-as-i32-virtualkey-as-i32-scancode-as-i32-shift-as-i32-down-as-i32-from-miniquake-native-dll-symbol-mq-conproc-write-key-returns-i32-src-miniquake-native-ml-892062981"></a>
### conprocWriteKey

```ml
extern function conprocWriteKey(character as i32, virtualKey as i32, scanCode as i32, shift as i32, down as i32) from "miniquake_native.dll" symbol "mq_conproc_write_key" returns i32
```

Invokes the native `conprocWriteKey` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `character` | `i32` | — | The character input consumed by `conprocWriteKey`. |
| `virtualKey` | `i32` | — | The virtual key input consumed by `conprocWriteKey`. |
| `scanCode` | `i32` | — | The scan code input consumed by `conprocWriteKey`. |
| `shift` | `i32` | — | The shift input consumed by `conprocWriteKey`. |
| `down` | `i32` | — | The down input consumed by `conprocWriteKey`. |


**Returns:** The `i32` result produced by `conprocWriteKey`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L769)

<a id="extern_function-extern-function-miniquake-native-conprocwritetext-extern-function-conprocwritetext-mapped-as-ptr-byteoffset-as-u32-text-as-cstr-capacity-as-u32-from-miniquake-native-dll-symbol-mq-conproc-write-text-returns-i32-src-miniquake-native-ml-691801239"></a>
### conprocWriteText

```ml
extern function conprocWriteText(mapped as ptr, byteOffset as u32, text as cstr, capacity as u32) from "miniquake_native.dll" symbol "mq_conproc_write_text" returns i32
```

Invokes the native `conprocWriteText` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapped` | `ptr` | — | The mapped input consumed by `conprocWriteText`. |
| `byteOffset` | `u32` | — | Zero-based offset of the requested data. |
| `text` | `cstr` | — | Text to parse or process. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `i32` result produced by `conprocWriteText`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L730)

<a id="function-function-miniquake-native-cos-function-cos-value-src-miniquake-native-ml-956013100"></a>
### cos

```ml
function cos(value)
```

Implements the `cos` operation for `miniquake.native` (cos).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `cos`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1715)

<a id="extern_function-extern-function-miniquake-native-f32atan2-extern-function-f32atan2-ybits-as-u32-xbits-as-u32-from-miniquake-native-dll-symbol-mq-f32-atan2-returns-u32-src-miniquake-native-ml-799818899"></a>
### f32Atan2

```ml
extern function f32Atan2(yBits as u32, xBits as u32) from "miniquake_native.dll" symbol "mq_f32_atan2" returns u32
```

Invokes the native `f32Atan2` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `yBits` | `u32` | — | The y bits input consumed by `f32Atan2`. |
| `xBits` | `u32` | — | The x bits input consumed by `f32Atan2`. |


**Returns:** The `u32` result produced by `f32Atan2`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L83)

<a id="extern_function-extern-function-miniquake-native-f32cos-extern-function-f32cos-bits-as-u32-from-miniquake-native-dll-symbol-mq-f32-cos-returns-u32-src-miniquake-native-ml-566962803"></a>
### f32Cos

```ml
extern function f32Cos(bits as u32) from "miniquake_native.dll" symbol "mq_f32_cos" returns u32
```

Invokes the native `f32Cos` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32Cos`. |


**Returns:** The `u32` result produced by `f32Cos`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L66)

<a id="extern_function-extern-function-miniquake-native-f32fromraw-extern-function-f32fromraw-rawvalue-as-u64-from-miniquake-native-dll-symbol-mq-f32-from-ml-raw-returns-u32-src-miniquake-native-ml-927579701"></a>
### f32FromRaw

```ml
extern function f32FromRaw(rawValue as u64) from "miniquake_native.dll" symbol "mq_f32_from_ml_raw" returns u32
```

Invokes the native `f32FromRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rawValue` | `u64` | — | The raw value input consumed by `f32FromRaw`. |


**Returns:** The `u32` result produced by `f32FromRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L22)

<a id="extern_function-extern-function-miniquake-native-f32fromtext-extern-function-f32fromtext-text-as-cstr-from-miniquake-native-dll-symbol-mq-f32-from-text-returns-u32-src-miniquake-native-ml-1156535713"></a>
### f32FromText

```ml
extern function f32FromText(text as cstr) from "miniquake_native.dll" symbol "mq_f32_from_text" returns u32
```

Invokes the native `f32FromText` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `cstr` | — | Text to parse or process. |


**Returns:** The `u32` result produced by `f32FromText`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L14)

<a id="extern_function-extern-function-miniquake-native-f32sin-extern-function-f32sin-bits-as-u32-from-miniquake-native-dll-symbol-mq-f32-sin-returns-u32-src-miniquake-native-ml-491001598"></a>
### f32Sin

```ml
extern function f32Sin(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sin" returns u32
```

Invokes the native `f32Sin` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32Sin`. |


**Returns:** The `u32` result produced by `f32Sin`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L58)

<a id="extern_function-extern-function-miniquake-native-f32sqrt-extern-function-f32sqrt-bits-as-u32-from-miniquake-native-dll-symbol-mq-f32-sqrt-returns-u32-src-miniquake-native-ml-183777238"></a>
### f32Sqrt

```ml
extern function f32Sqrt(bits as u32) from "miniquake_native.dll" symbol "mq_f32_sqrt" returns u32
```

Invokes the native `f32Sqrt` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32Sqrt`. |


**Returns:** The `u32` result produced by `f32Sqrt`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L74)

<a id="function-function-miniquake-native-f32tofixed6-function-f32tofixed6-bits-src-miniquake-native-ml-1892001273"></a>
### f32ToFixed6

```ml
function f32ToFixed6(bits)
```

C printf("%f") boundary used by Cvar_SetValue, ED_Write and version-5 savegames.  The native bridge avoids i32 overflow for values such as the stock Quake item bitmask 4097 and preserves negative zero exactly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `dynamic` | — | The bits input consumed by `f32ToFixed6`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1589)

<a id="extern_function-extern-function-miniquake-native-f32tofixed6raw-extern-function-f32tofixed6raw-bits-as-u32-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-f32-to-fixed6-returns-u32-src-miniquake-native-ml-200852214"></a>
### f32ToFixed6Raw

```ml
extern function f32ToFixed6Raw(bits as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_f32_to_fixed6" returns u32
```

Invokes the native `f32ToFixed6Raw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32ToFixed6Raw`. |
| `output` | `bytes` | — | Destination buffer that receives the fixed-point text. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `f32ToFixed6Raw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L50)

<a id="extern_function-extern-function-miniquake-native-f32toi32trunc-extern-function-f32toi32trunc-bits-as-u32-from-miniquake-native-dll-symbol-mq-f32-to-i32-trunc-returns-i32-src-miniquake-native-ml-15681851"></a>
### f32ToI32Trunc

```ml
extern function f32ToI32Trunc(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_i32_trunc" returns i32
```

Invokes the native `f32ToI32Trunc` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32ToI32Trunc`. |


**Returns:** The `i32` result produced by `f32ToI32Trunc`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L91)

<a id="extern_function-extern-function-miniquake-native-f32toraw-extern-function-f32toraw-bits-as-u32-from-miniquake-native-dll-symbol-mq-f32-to-ml-raw-returns-u64-src-miniquake-native-ml-1902592883"></a>
### f32ToRaw

```ml
extern function f32ToRaw(bits as u32) from "miniquake_native.dll" symbol "mq_f32_to_ml_raw" returns u64
```

Invokes the native `f32ToRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32ToRaw`. |


**Returns:** The `u64` result produced by `f32ToRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L30)

<a id="function-function-miniquake-native-f32totext-function-f32totext-bits-src-miniquake-native-ml-1915269395"></a>
### f32ToText

```ml
function f32ToText(bits)
```

Implements the `f32ToText` operation for `miniquake.native` (f32 to text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `dynamic` | — | The bits input consumed by `f32ToText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1580)

<a id="extern_function-extern-function-miniquake-native-f32totextraw-extern-function-f32totextraw-bits-as-u32-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-f32-to-text-returns-u32-src-miniquake-native-ml-298201357"></a>
### f32ToTextRaw

```ml
extern function f32ToTextRaw(bits as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_f32_to_text" returns u32
```

Invokes the native `f32ToTextRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bits` | `u32` | — | The bits input consumed by `f32ToTextRaw`. |
| `output` | `bytes` | — | Destination buffer that receives the formatted text. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `f32ToTextRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L40)

<a id="function-function-miniquake-native-fixedsixtext-function-fixedsixtext-value-src-miniquake-native-ml-1438054306"></a>
### fixedSixText

```ml
function fixedSixText(value)
```

Implements the `fixedSixText` operation for `miniquake.native` (fixed six text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fixedSixText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1703)

<a id="function-function-miniquake-native-floatbits-function-floatbits-value-src-miniquake-native-ml-1765878930"></a>
### floatBits

```ml
function floatBits(value)
```

Return float bits derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floatBits`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1669)

<a id="function-function-miniquake-native-floattext-function-floattext-value-src-miniquake-native-ml-1770414832"></a>
### floatText

```ml
function floatText(value)
```

Implements the `floatText` operation for `miniquake.native` (float text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floatText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1697)

<a id="extern_function-extern-function-miniquake-native-glactivetexture-extern-function-glactivetexture-unit-as-i32-from-miniquake-native-dll-symbol-mq-gl-active-texture-returns-void-src-miniquake-native-ml-1922410898"></a>
### glActiveTexture

```ml
extern function glActiveTexture(unit as i32) from "miniquake_native.dll" symbol "mq_gl_active_texture" returns void
```

Invokes the native `glActiveTexture` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `unit` | `i32` | — | The unit input consumed by `glActiveTexture`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1837)

<a id="extern_function-extern-function-miniquake-native-glalphafunc-extern-function-glalphafunc-functionname-as-u32-referencebits-as-u32-from-miniquake-native-dll-symbol-mq-gl-alpha-func-returns-void-src-miniquake-native-ml-2054606253"></a>
### glAlphaFunc

```ml
extern function glAlphaFunc(functionName as u32, referenceBits as u32) from "miniquake_native.dll" symbol "mq_gl_alpha_func" returns void
```

Invokes the native `glAlphaFunc` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `functionName` | `u32` | — | Name that identifies the requested value or resource. |
| `referenceBits` | `u32` | — | The reference bits input consumed by `glAlphaFunc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1181)

<a id="extern_function-extern-function-miniquake-native-glbegin-extern-function-glbegin-mode-as-u32-from-miniquake-native-dll-symbol-mq-gl-begin-returns-void-src-miniquake-native-ml-1753522926"></a>
### glBegin

```ml
extern function glBegin(mode as u32) from "miniquake_native.dll" symbol "mq_gl_begin" returns void
```

Invokes the native `glBegin` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `u32` | — | The mode input consumed by `glBegin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1071)

<a id="extern_function-extern-function-miniquake-native-glbindtexture-extern-function-glbindtexture-target-as-u32-texture-as-u32-from-miniquake-native-dll-symbol-mq-gl-bind-texture-returns-void-src-miniquake-native-ml-1041404561"></a>
### glBindTexture

```ml
extern function glBindTexture(target as u32, texture as u32) from "miniquake_native.dll" symbol "mq_gl_bind_texture" returns void
```

Invokes the native `glBindTexture` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `u32` | — | The target input consumed by `glBindTexture`. |
| `texture` | `u32` | — | Texture resource processed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1298)

<a id="extern_function-extern-function-miniquake-native-glblendfunc-extern-function-glblendfunc-source-as-u32-destination-as-u32-from-miniquake-native-dll-symbol-mq-gl-blend-func-returns-void-src-miniquake-native-ml-1113636217"></a>
### glBlendFunc

```ml
extern function glBlendFunc(source as u32, destination as u32) from "miniquake_native.dll" symbol "mq_gl_blend_func" returns void
```

Invokes the native `glBlendFunc` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `u32` | — | Source value or collection to read. |
| `destination` | `u32` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1151)

<a id="extern_function-extern-function-miniquake-native-glclear-extern-function-glclear-mask-as-u32-from-miniquake-native-dll-symbol-mq-gl-clear-returns-void-src-miniquake-native-ml-1211591793"></a>
### glClear

```ml
extern function glClear(mask as u32) from "miniquake_native.dll" symbol "mq_gl_clear" returns void
```

Invokes the native `glClear` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mask` | `u32` | — | The mask input consumed by `glClear`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1129)

<a id="extern_function-extern-function-miniquake-native-glclearcolor-extern-function-glclearcolor-redbits-as-u32-greenbits-as-u32-bluebits-as-u32-alphabits-as-u32-from-miniquake-native-dll-symbol-mq-gl-clear-color-returns-void-src-miniquake-native-ml-1314743029"></a>
### glClearColor

```ml
extern function glClearColor(redBits as u32, greenBits as u32, blueBits as u32, alphaBits as u32) from "miniquake_native.dll" symbol "mq_gl_clear_color" returns void
```

Invokes the native `glClearColor` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `redBits` | `u32` | — | The red bits input consumed by `glClearColor`. |
| `greenBits` | `u32` | — | The green bits input consumed by `glClearColor`. |
| `blueBits` | `u32` | — | The blue bits input consumed by `glClearColor`. |
| `alphaBits` | `u32` | — | The alpha bits input consumed by `glClearColor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1122)

<a id="extern_function-extern-function-miniquake-native-glcolor4ub-extern-function-glcolor4ub-red-as-u32-green-as-u32-blue-as-u32-alpha-as-u32-from-miniquake-native-dll-symbol-mq-gl-color4ub-returns-void-src-miniquake-native-ml-75443024"></a>
### glColor4ub

```ml
extern function glColor4ub(red as u32, green as u32, blue as u32, alpha as u32) from "miniquake_native.dll" symbol "mq_gl_color4ub" returns void
```

Invokes the native `glColor4ub` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `red` | `u32` | — | The red input consumed by `glColor4ub`. |
| `green` | `u32` | — | The green input consumed by `glColor4ub`. |
| `blue` | `u32` | — | The blue input consumed by `glColor4ub`. |
| `alpha` | `u32` | — | The alpha input consumed by `glColor4ub`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1112)

<a id="extern_function-extern-function-miniquake-native-glcullface-extern-function-glcullface-mode-as-u32-from-miniquake-native-dll-symbol-mq-gl-cull-face-returns-void-src-miniquake-native-ml-363331871"></a>
### glCullFace

```ml
extern function glCullFace(mode as u32) from "miniquake_native.dll" symbol "mq_gl_cull_face" returns void
```

Invokes the native `glCullFace` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `u32` | — | The mode input consumed by `glCullFace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1188)

<a id="extern_function-extern-function-miniquake-native-gldeletetextures-extern-function-gldeletetextures-count-as-i32-textureids-as-bytes-from-miniquake-native-dll-symbol-mq-gl-delete-textures-returns-void-src-miniquake-native-ml-1039881255"></a>
### glDeleteTextures

```ml
extern function glDeleteTextures(count as i32, textureIds as bytes) from "miniquake_native.dll" symbol "mq_gl_delete_textures" returns void
```

Invokes the native `glDeleteTextures` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `i32` | — | Number of entries or units to process. |
| `textureIds` | `bytes` | — | The texture ids input consumed by `glDeleteTextures`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1314)

<a id="extern_function-extern-function-miniquake-native-gldepthfunc-extern-function-gldepthfunc-functionname-as-u32-from-miniquake-native-dll-symbol-mq-gl-depth-func-returns-void-src-miniquake-native-ml-1983155071"></a>
### glDepthFunc

```ml
extern function glDepthFunc(functionName as u32) from "miniquake_native.dll" symbol "mq_gl_depth_func" returns void
```

Invokes the native `glDepthFunc` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `functionName` | `u32` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1158)

<a id="extern_function-extern-function-miniquake-native-gldepthmask-extern-function-gldepthmask-enabled-as-i32-from-miniquake-native-dll-symbol-mq-gl-depth-mask-returns-void-src-miniquake-native-ml-1290082685"></a>
### glDepthMask

```ml
extern function glDepthMask(enabled as i32) from "miniquake_native.dll" symbol "mq_gl_depth_mask" returns void
```

Invokes the native `glDepthMask` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `i32` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1165)

<a id="extern_function-extern-function-miniquake-native-gldepthrange-extern-function-gldepthrange-nearbits-as-u32-farbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-depth-range-returns-void-src-miniquake-native-ml-1273324480"></a>
### glDepthRange

```ml
extern function glDepthRange(nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_depth_range" returns void
```

Invokes the native `glDepthRange` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nearBits` | `u32` | — | The near bits input consumed by `glDepthRange`. |
| `farBits` | `u32` | — | The far bits input consumed by `glDepthRange`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1173)

<a id="extern_function-extern-function-miniquake-native-gldisable-extern-function-gldisable-capability-as-u32-from-miniquake-native-dll-symbol-mq-gl-disable-returns-void-src-miniquake-native-ml-260555930"></a>
### glDisable

```ml
extern function glDisable(capability as u32) from "miniquake_native.dll" symbol "mq_gl_disable" returns void
```

Invokes the native `glDisable` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capability` | `u32` | — | The capability input consumed by `glDisable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1143)

<a id="extern_function-extern-function-miniquake-native-gldrawaliasbatch-extern-function-gldrawaliasbatch-data-as-bytes-bytecount-as-u32-shadedots-as-bytes-shadedotcount-as-u32-shadelightbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-draw-alias-batch-returns-i32-src-miniquake-native-ml-611773114"></a>
### glDrawAliasBatch

```ml
extern function glDrawAliasBatch(data as bytes, byteCount as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_batch" returns i32
```

Invokes the native `glDrawAliasBatch` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |
| `shadeDots` | `bytes` | — | The shade dots input consumed by `glDrawAliasBatch`. |
| `shadeDotCount` | `u32` | — | Number of entries or units to process. |
| `shadeLightBits` | `u32` | — | The shade light bits input consumed by `glDrawAliasBatch`. |


**Returns:** The `i32` result produced by `glDrawAliasBatch`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1423)

<a id="extern_function-extern-function-miniquake-native-gldrawaliasmodel-extern-function-gldrawaliasmodel-data-as-bytes-bytecount-as-u32-shadedots-as-bytes-shadedotcount-as-u32-shadelightbits-as-u32-originx-as-u32-originy-as-u32-originz-as-u32-anglex-as-u32-angley-as-u32-anglez-as-u32-scaleoriginx-as-u32-scaleoriginy-as-u32-scaleoriginz-as-u32-scalex-as-u32-scaley-as-u32-scalez-as-u32-doubleeyes-as-i32-smooth-as-i32-from-miniquake-native-dll-symbol-mq-gl-draw-alias-model-returns-i32-src-miniquake-native-ml-1358633783"></a>
### glDrawAliasModel

```ml
extern function glDrawAliasModel(data as bytes, byteCount as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, smooth as i32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_model" returns i32
```

Invokes the native `glDrawAliasModel` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |
| `shadeDots` | `bytes` | — | The shade dots input consumed by `glDrawAliasModel`. |
| `shadeDotCount` | `u32` | — | Number of entries or units to process. |
| `shadeLightBits` | `u32` | — | The shade light bits input consumed by `glDrawAliasModel`. |
| `originX` | `u32` | — | The origin x input consumed by `glDrawAliasModel`. |
| `originY` | `u32` | — | The origin y input consumed by `glDrawAliasModel`. |
| `originZ` | `u32` | — | The origin z input consumed by `glDrawAliasModel`. |
| `angleX` | `u32` | — | The angle x input consumed by `glDrawAliasModel`. |
| `angleY` | `u32` | — | The angle y input consumed by `glDrawAliasModel`. |
| `angleZ` | `u32` | — | The angle z input consumed by `glDrawAliasModel`. |
| `scaleOriginX` | `u32` | — | The scale origin x input consumed by `glDrawAliasModel`. |
| `scaleOriginY` | `u32` | — | The scale origin y input consumed by `glDrawAliasModel`. |
| `scaleOriginZ` | `u32` | — | The scale origin z input consumed by `glDrawAliasModel`. |
| `scaleX` | `u32` | — | The scale x input consumed by `glDrawAliasModel`. |
| `scaleY` | `u32` | — | The scale y input consumed by `glDrawAliasModel`. |
| `scaleZ` | `u32` | — | The scale z input consumed by `glDrawAliasModel`. |
| `doubleEyes` | `i32` | — | The double eyes input consumed by `glDrawAliasModel`. |
| `smooth` | `i32` | — | The smooth input consumed by `glDrawAliasModel`. |


**Returns:** The `i32` result produced by `glDrawAliasModel`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1528)

<a id="extern_function-extern-function-miniquake-native-gldrawaliasmodellerp-extern-function-gldrawaliasmodellerp-previousdata-as-bytes-previousbytecount-as-u32-currentdata-as-bytes-currentbytecount-as-u32-fractionbits-as-u32-shadedots-as-bytes-shadedotcount-as-u32-shadelightbits-as-u32-originx-as-u32-originy-as-u32-originz-as-u32-anglex-as-u32-angley-as-u32-anglez-as-u32-scaleoriginx-as-u32-scaleoriginy-as-u32-scaleoriginz-as-u32-scalex-as-u32-scaley-as-u32-scalez-as-u32-doubleeyes-as-i32-smooth-as-i32-from-miniquake-native-dll-symbol-mq-gl-draw-alias-model-lerp-returns-i32-src-miniquake-native-ml-927382023"></a>
### glDrawAliasModelLerp

```ml
extern function glDrawAliasModelLerp(previousData as bytes, previousByteCount as u32, currentData as bytes, currentByteCount as u32, fractionBits as u32, shadeDots as bytes, shadeDotCount as u32, shadeLightBits as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, smooth as i32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_model_lerp" returns i32
```

Invokes the native `glDrawAliasModelLerp` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previousData` | `bytes` | — | The previous data input consumed by `glDrawAliasModelLerp`. |
| `previousByteCount` | `u32` | — | Number of entries or units to process. |
| `currentData` | `bytes` | — | The current data input consumed by `glDrawAliasModelLerp`. |
| `currentByteCount` | `u32` | — | Number of entries or units to process. |
| `fractionBits` | `u32` | — | The fraction bits input consumed by `glDrawAliasModelLerp`. |
| `shadeDots` | `bytes` | — | The shade dots input consumed by `glDrawAliasModelLerp`. |
| `shadeDotCount` | `u32` | — | Number of entries or units to process. |
| `shadeLightBits` | `u32` | — | The shade light bits input consumed by `glDrawAliasModelLerp`. |
| `originX` | `u32` | — | The origin x input consumed by `glDrawAliasModelLerp`. |
| `originY` | `u32` | — | The origin y input consumed by `glDrawAliasModelLerp`. |
| `originZ` | `u32` | — | The origin z input consumed by `glDrawAliasModelLerp`. |
| `angleX` | `u32` | — | The angle x input consumed by `glDrawAliasModelLerp`. |
| `angleY` | `u32` | — | The angle y input consumed by `glDrawAliasModelLerp`. |
| `angleZ` | `u32` | — | The angle z input consumed by `glDrawAliasModelLerp`. |
| `scaleOriginX` | `u32` | — | The scale origin x input consumed by `glDrawAliasModelLerp`. |
| `scaleOriginY` | `u32` | — | The scale origin y input consumed by `glDrawAliasModelLerp`. |
| `scaleOriginZ` | `u32` | — | The scale origin z input consumed by `glDrawAliasModelLerp`. |
| `scaleX` | `u32` | — | The scale x input consumed by `glDrawAliasModelLerp`. |
| `scaleY` | `u32` | — | The scale y input consumed by `glDrawAliasModelLerp`. |
| `scaleZ` | `u32` | — | The scale z input consumed by `glDrawAliasModelLerp`. |
| `doubleEyes` | `i32` | — | The double eyes input consumed by `glDrawAliasModelLerp`. |
| `smooth` | `i32` | — | The smooth input consumed by `glDrawAliasModelLerp`. |


**Returns:** The `i32` result produced by `glDrawAliasModelLerp`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1557)

<a id="extern_function-extern-function-miniquake-native-gldrawaliasrayshadow-extern-function-gldrawaliasrayshadow-data-as-bytes-bytecount-as-u32-originx-as-u32-originy-as-u32-originz-as-u32-anglex-as-u32-angley-as-u32-anglez-as-u32-scaleoriginx-as-u32-scaleoriginy-as-u32-scaleoriginz-as-u32-scalex-as-u32-scaley-as-u32-scalez-as-u32-doubleeyes-as-i32-pointlightactive-as-i32-lightx-as-u32-lighty-as-u32-lightz-as-u32-samplex-as-u32-sampley-as-u32-from-miniquake-native-dll-symbol-mq-gl-draw-alias-ray-shadow-returns-i32-src-miniquake-native-ml-570597193"></a>
### glDrawAliasRayShadow

```ml
extern function glDrawAliasRayShadow(data as bytes, byteCount as u32, originX as u32, originY as u32, originZ as u32, angleX as u32, angleY as u32, angleZ as u32, scaleOriginX as u32, scaleOriginY as u32, scaleOriginZ as u32, scaleX as u32, scaleY as u32, scaleZ as u32, doubleEyes as i32, pointLightActive as i32, lightX as u32, lightY as u32, lightZ as u32, sampleX as u32, sampleY as u32) from "miniquake_native.dll" symbol "mq_gl_draw_alias_ray_shadow" returns i32
```

Invokes the native `glDrawAliasRayShadow` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |
| `originX` | `u32` | — | The origin x input consumed by `glDrawAliasRayShadow`. |
| `originY` | `u32` | — | The origin y input consumed by `glDrawAliasRayShadow`. |
| `originZ` | `u32` | — | The origin z input consumed by `glDrawAliasRayShadow`. |
| `angleX` | `u32` | — | The angle x input consumed by `glDrawAliasRayShadow`. |
| `angleY` | `u32` | — | The angle y input consumed by `glDrawAliasRayShadow`. |
| `angleZ` | `u32` | — | The angle z input consumed by `glDrawAliasRayShadow`. |
| `scaleOriginX` | `u32` | — | The scale origin x input consumed by `glDrawAliasRayShadow`. |
| `scaleOriginY` | `u32` | — | The scale origin y input consumed by `glDrawAliasRayShadow`. |
| `scaleOriginZ` | `u32` | — | The scale origin z input consumed by `glDrawAliasRayShadow`. |
| `scaleX` | `u32` | — | The scale x input consumed by `glDrawAliasRayShadow`. |
| `scaleY` | `u32` | — | The scale y input consumed by `glDrawAliasRayShadow`. |
| `scaleZ` | `u32` | — | The scale z input consumed by `glDrawAliasRayShadow`. |
| `doubleEyes` | `i32` | — | The double eyes input consumed by `glDrawAliasRayShadow`. |
| `pointLightActive` | `i32` | — | The point light active input consumed by `glDrawAliasRayShadow`. |
| `lightX` | `u32` | — | The light x input consumed by `glDrawAliasRayShadow`. |
| `lightY` | `u32` | — | The light y input consumed by `glDrawAliasRayShadow`. |
| `lightZ` | `u32` | — | The light z input consumed by `glDrawAliasRayShadow`. |
| `sampleX` | `u32` | — | The sample x input consumed by `glDrawAliasRayShadow`. |
| `sampleY` | `u32` | — | The sample y input consumed by `glDrawAliasRayShadow`. |


**Returns:** The `i32` result produced by `glDrawAliasRayShadow`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1460)

<a id="extern_function-extern-function-miniquake-native-gldrawbuffer-extern-function-gldrawbuffer-mode-as-u32-from-miniquake-native-dll-symbol-mq-gl-draw-buffer-returns-void-src-miniquake-native-ml-2053014756"></a>
### glDrawBuffer

```ml
extern function glDrawBuffer(mode as u32) from "miniquake_native.dll" symbol "mq_gl_draw_buffer" returns void
```

Invokes the native `glDrawBuffer` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `u32` | — | The mode input consumed by `glDrawBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1411)

<a id="extern_function-extern-function-miniquake-native-gldrawparticlebatch-extern-function-gldrawparticlebatch-data-as-bytes-bytecount-as-u32-vieworiginx-as-u32-vieworiginy-as-u32-vieworiginz-as-u32-viewforwardx-as-u32-viewforwardy-as-u32-viewforwardz-as-u32-viewupx-as-u32-viewupy-as-u32-viewupz-as-u32-viewrightx-as-u32-viewrighty-as-u32-viewrightz-as-u32-from-miniquake-native-dll-symbol-mq-gl-draw-particle-batch-returns-i32-src-miniquake-native-ml-1103791668"></a>
### glDrawParticleBatch

```ml
extern function glDrawParticleBatch(data as bytes, byteCount as u32, viewOriginX as u32, viewOriginY as u32, viewOriginZ as u32, viewForwardX as u32, viewForwardY as u32, viewForwardZ as u32, viewUpX as u32, viewUpY as u32, viewUpZ as u32, viewRightX as u32, viewRightY as u32, viewRightZ as u32) from "miniquake_native.dll" symbol "mq_gl_draw_particle_batch" returns i32
```

Invokes the native `glDrawParticleBatch` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |
| `viewOriginX` | `u32` | — | The view origin x input consumed by `glDrawParticleBatch`. |
| `viewOriginY` | `u32` | — | The view origin y input consumed by `glDrawParticleBatch`. |
| `viewOriginZ` | `u32` | — | The view origin z input consumed by `glDrawParticleBatch`. |
| `viewForwardX` | `u32` | — | The view forward x input consumed by `glDrawParticleBatch`. |
| `viewForwardY` | `u32` | — | The view forward y input consumed by `glDrawParticleBatch`. |
| `viewForwardZ` | `u32` | — | The view forward z input consumed by `glDrawParticleBatch`. |
| `viewUpX` | `u32` | — | The view up x input consumed by `glDrawParticleBatch`. |
| `viewUpY` | `u32` | — | The view up y input consumed by `glDrawParticleBatch`. |
| `viewUpZ` | `u32` | — | The view up z input consumed by `glDrawParticleBatch`. |
| `viewRightX` | `u32` | — | The view right x input consumed by `glDrawParticleBatch`. |
| `viewRightY` | `u32` | — | The view right y input consumed by `glDrawParticleBatch`. |
| `viewRightZ` | `u32` | — | The view right z input consumed by `glDrawParticleBatch`. |


**Returns:** The `i32` result produced by `glDrawParticleBatch`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1481)

<a id="extern_function-extern-function-miniquake-native-gldrawparticlebatchstyled-extern-function-gldrawparticlebatchstyled-data-as-bytes-bytecount-as-u32-vieworiginx-as-u32-vieworiginy-as-u32-vieworiginz-as-u32-viewforwardx-as-u32-viewforwardy-as-u32-viewforwardz-as-u32-viewupx-as-u32-viewupy-as-u32-viewupz-as-u32-viewrightx-as-u32-viewrighty-as-u32-viewrightz-as-u32-from-miniquake-native-dll-symbol-mq-gl-draw-particle-batch-styled-returns-i32-src-miniquake-native-ml-621970424"></a>
### glDrawParticleBatchStyled

```ml
extern function glDrawParticleBatchStyled(data as bytes, byteCount as u32, viewOriginX as u32, viewOriginY as u32, viewOriginZ as u32, viewForwardX as u32, viewForwardY as u32, viewForwardZ as u32, viewUpX as u32, viewUpY as u32, viewUpZ as u32, viewRightX as u32, viewRightY as u32, viewRightZ as u32) from "miniquake_native.dll" symbol "mq_gl_draw_particle_batch_styled" returns i32
```

Invokes the native `glDrawParticleBatchStyled` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |
| `viewOriginX` | `u32` | — | The view origin x input consumed by `glDrawParticleBatchStyled`. |
| `viewOriginY` | `u32` | — | The view origin y input consumed by `glDrawParticleBatchStyled`. |
| `viewOriginZ` | `u32` | — | The view origin z input consumed by `glDrawParticleBatchStyled`. |
| `viewForwardX` | `u32` | — | The view forward x input consumed by `glDrawParticleBatchStyled`. |
| `viewForwardY` | `u32` | — | The view forward y input consumed by `glDrawParticleBatchStyled`. |
| `viewForwardZ` | `u32` | — | The view forward z input consumed by `glDrawParticleBatchStyled`. |
| `viewUpX` | `u32` | — | The view up x input consumed by `glDrawParticleBatchStyled`. |
| `viewUpY` | `u32` | — | The view up y input consumed by `glDrawParticleBatchStyled`. |
| `viewUpZ` | `u32` | — | The view up z input consumed by `glDrawParticleBatchStyled`. |
| `viewRightX` | `u32` | — | The view right x input consumed by `glDrawParticleBatchStyled`. |
| `viewRightY` | `u32` | — | The view right y input consumed by `glDrawParticleBatchStyled`. |
| `viewRightZ` | `u32` | — | The view right z input consumed by `glDrawParticleBatchStyled`. |


**Returns:** The `i32` result produced by `glDrawParticleBatchStyled`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1502)

<a id="extern_function-extern-function-miniquake-native-gldrawshadowbatch-extern-function-gldrawshadowbatch-data-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-gl-draw-shadow-batch-returns-i32-src-miniquake-native-ml-1154258668"></a>
### glDrawShadowBatch

```ml
extern function glDrawShadowBatch(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_draw_shadow_batch" returns i32
```

Invokes the native `glDrawShadowBatch` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `glDrawShadowBatch`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1432)

<a id="extern_function-extern-function-miniquake-native-glenable-extern-function-glenable-capability-as-u32-from-miniquake-native-dll-symbol-mq-gl-enable-returns-void-src-miniquake-native-ml-394477279"></a>
### glEnable

```ml
extern function glEnable(capability as u32) from "miniquake_native.dll" symbol "mq_gl_enable" returns void
```

Invokes the native `glEnable` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capability` | `u32` | — | The capability input consumed by `glEnable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1136)

<a id="extern_function-extern-function-miniquake-native-glend-extern-function-glend-from-miniquake-native-dll-symbol-mq-gl-end-returns-void-src-miniquake-native-ml-545548189"></a>
### glEnd

```ml
extern function glEnd() from "miniquake_native.dll" symbol "mq_gl_end" returns void
```

Invokes the native `glEnd` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1077)

<a id="extern_function-extern-function-miniquake-native-glenhancedavailable-extern-function-glenhancedavailable-from-miniquake-native-dll-symbol-mq-gl-enhanced-available-returns-i32-src-miniquake-native-ml-2020122532"></a>
### glEnhancedAvailable

```ml
extern function glEnhancedAvailable() from "miniquake_native.dll" symbol "mq_gl_enhanced_available" returns i32
```

Invokes the native `glEnhancedAvailable` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `glEnhancedAvailable`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1798)

<a id="extern_function-extern-function-miniquake-native-glenhancedbeginframe-extern-function-glenhancedbeginframe-lights-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-gl-enhanced-begin-frame-returns-i32-src-miniquake-native-ml-1449803823"></a>
### glEnhancedBeginFrame

```ml
extern function glEnhancedBeginFrame(lights as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_enhanced_begin_frame" returns i32
```

Invokes the native `glEnhancedBeginFrame` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lights` | `bytes` | — | The lights input consumed by `glEnhancedBeginFrame`. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `glEnhancedBeginFrame`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1817)

<a id="extern_function-extern-function-miniquake-native-glenhancedconfigure-extern-function-glenhancedconfigure-enabled-as-i32-shadows-as-i32-shadowquality-as-i32-from-miniquake-native-dll-symbol-mq-gl-enhanced-configure-returns-i32-src-miniquake-native-ml-1272476278"></a>
### glEnhancedConfigure

```ml
extern function glEnhancedConfigure(enabled as i32, shadows as i32, shadowQuality as i32) from "miniquake_native.dll" symbol "mq_gl_enhanced_configure" returns i32
```

Invokes the native `glEnhancedConfigure` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `i32` | — | Whether the optional behavior is enabled. |
| `shadows` | `i32` | — | The shadows input consumed by `glEnhancedConfigure`. |
| `shadowQuality` | `i32` | — | The shadow quality input consumed by `glEnhancedConfigure`. |


**Returns:** The `i32` result produced by `glEnhancedConfigure`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1808)

<a id="extern_function-extern-function-miniquake-native-glenhanceddrawkind-extern-function-glenhanceddrawkind-kind-as-i32-from-miniquake-native-dll-symbol-mq-gl-enhanced-draw-kind-returns-void-src-miniquake-native-ml-1515529890"></a>
### glEnhancedDrawKind

```ml
extern function glEnhancedDrawKind(kind as i32) from "miniquake_native.dll" symbol "mq_gl_enhanced_draw_kind" returns void
```

Invokes the native `glEnhancedDrawKind` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `i32` | — | The kind input consumed by `glEnhancedDrawKind`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1824)

<a id="extern_function-extern-function-miniquake-native-glenhancedendframe-extern-function-glenhancedendframe-from-miniquake-native-dll-symbol-mq-gl-enhanced-end-frame-returns-void-src-miniquake-native-ml-704884918"></a>
### glEnhancedEndFrame

```ml
extern function glEnhancedEndFrame() from "miniquake_native.dll" symbol "mq_gl_enhanced_end_frame" returns void
```

Invokes the native `glEnhancedEndFrame` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1830)

<a id="extern_function-extern-function-miniquake-native-glfinish-extern-function-glfinish-from-miniquake-native-dll-symbol-mq-gl-finish-returns-void-src-miniquake-native-ml-1237742189"></a>
### glFinish

```ml
extern function glFinish() from "miniquake_native.dll" symbol "mq_gl_finish" returns void
```

Invokes the native `glFinish` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1398)

<a id="extern_function-extern-function-miniquake-native-glflush-extern-function-glflush-from-miniquake-native-dll-symbol-mq-gl-flush-returns-void-src-miniquake-native-ml-1490903166"></a>
### glFlush

```ml
extern function glFlush() from "miniquake_native.dll" symbol "mq_gl_flush" returns void
```

Invokes the native `glFlush` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1404)

<a id="extern_function-extern-function-miniquake-native-glfrustum-extern-function-glfrustum-leftbits-as-u32-rightbits-as-u32-bottombits-as-u32-topbits-as-u32-nearbits-as-u32-farbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-frustum-returns-void-src-miniquake-native-ml-1303194656"></a>
### glFrustum

```ml
extern function glFrustum(leftBits as u32, rightBits as u32, bottomBits as u32, topBits as u32, nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_frustum" returns void
```

Invokes the native `glFrustum` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftBits` | `u32` | — | The left bits input consumed by `glFrustum`. |
| `rightBits` | `u32` | — | The right bits input consumed by `glFrustum`. |
| `bottomBits` | `u32` | — | The bottom bits input consumed by `glFrustum`. |
| `topBits` | `u32` | — | The top bits input consumed by `glFrustum`. |
| `nearBits` | `u32` | — | The near bits input consumed by `glFrustum`. |
| `farBits` | `u32` | — | The far bits input consumed by `glFrustum`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1290)

<a id="extern_function-extern-function-miniquake-native-glgentextures-extern-function-glgentextures-count-as-i32-textureids-as-bytes-from-miniquake-native-dll-symbol-mq-gl-gen-textures-returns-void-src-miniquake-native-ml-1585422112"></a>
### glGenTextures

```ml
extern function glGenTextures(count as i32, textureIds as bytes) from "miniquake_native.dll" symbol "mq_gl_gen_textures" returns void
```

Invokes the native `glGenTextures` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `i32` | — | Number of entries or units to process. |
| `textureIds` | `bytes` | — | The texture ids input consumed by `glGenTextures`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1306)

<a id="extern_function-extern-function-miniquake-native-glgeterror-extern-function-glgeterror-from-miniquake-native-dll-symbol-mq-gl-get-error-returns-u32-src-miniquake-native-ml-120765365"></a>
### glGetError

```ml
extern function glGetError() from "miniquake_native.dll" symbol "mq_gl_get_error" returns u32
```

Invokes the native `glGetError` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `glGetError`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1392)

<a id="function-function-miniquake-native-glgetstring-function-glgetstring-name-src-miniquake-native-ml-449223948"></a>
### glGetString

```ml
function glGetString(name)
```

Implements the `glGetString` operation for `miniquake.native` (gl get string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1662)

<a id="extern_function-extern-function-miniquake-native-glgetstringraw-extern-function-glgetstringraw-name-as-u32-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-gl-get-string-returns-u32-src-miniquake-native-ml-1395155497"></a>
### glGetStringRaw

```ml
extern function glGetStringRaw(name as u32, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_gl_get_string" returns u32
```

Invokes the native `glGetStringRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `u32` | — | Stable name that identifies the requested object or option. |
| `output` | `bytes` | — | Destination buffer that receives the OpenGL string. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `glGetStringRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1385)

<a id="extern_function-extern-function-miniquake-native-glloadidentity-extern-function-glloadidentity-from-miniquake-native-dll-symbol-mq-gl-load-identity-returns-void-src-miniquake-native-ml-759377997"></a>
### glLoadIdentity

```ml
extern function glLoadIdentity() from "miniquake_native.dll" symbol "mq_gl_load_identity" returns void
```

Invokes the native `glLoadIdentity` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1226)

<a id="extern_function-extern-function-miniquake-native-glmatrixmode-extern-function-glmatrixmode-mode-as-u32-from-miniquake-native-dll-symbol-mq-gl-matrix-mode-returns-void-src-miniquake-native-ml-1536886312"></a>
### glMatrixMode

```ml
extern function glMatrixMode(mode as u32) from "miniquake_native.dll" symbol "mq_gl_matrix_mode" returns void
```

Invokes the native `glMatrixMode` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `u32` | — | The mode input consumed by `glMatrixMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1220)

<a id="extern_function-extern-function-miniquake-native-glmultitexcoord2-extern-function-glmultitexcoord2-unit-as-i32-sbits-as-u32-tbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-multi-tex-coord2-returns-void-src-miniquake-native-ml-1186466930"></a>
### glMultiTexCoord2

```ml
extern function glMultiTexCoord2(unit as i32, sBits as u32, tBits as u32) from "miniquake_native.dll" symbol "mq_gl_multi_tex_coord2" returns void
```

Invokes the native `glMultiTexCoord2` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `unit` | `i32` | — | The unit input consumed by `glMultiTexCoord2`. |
| `sBits` | `u32` | — | The s bits input consumed by `glMultiTexCoord2`. |
| `tBits` | `u32` | — | The t bits input consumed by `glMultiTexCoord2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1846)

<a id="extern_function-extern-function-miniquake-native-glmultitextureavailable-extern-function-glmultitextureavailable-from-miniquake-native-dll-symbol-mq-gl-multitexture-available-returns-i32-src-miniquake-native-ml-2012878438"></a>
### glMultitextureAvailable

```ml
extern function glMultitextureAvailable() from "miniquake_native.dll" symbol "mq_gl_multitexture_available" returns i32
```

Invokes the native `glMultitextureAvailable` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `glMultitextureAvailable`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1777)

<a id="extern_function-extern-function-miniquake-native-glortho-extern-function-glortho-leftbits-as-u32-rightbits-as-u32-bottombits-as-u32-topbits-as-u32-nearbits-as-u32-farbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-ortho-returns-void-src-miniquake-native-ml-1504535548"></a>
### glOrtho

```ml
extern function glOrtho(leftBits as u32, rightBits as u32, bottomBits as u32, topBits as u32, nearBits as u32, farBits as u32) from "miniquake_native.dll" symbol "mq_gl_ortho" returns void
```

Invokes the native `glOrtho` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftBits` | `u32` | — | The left bits input consumed by `glOrtho`. |
| `rightBits` | `u32` | — | The right bits input consumed by `glOrtho`. |
| `bottomBits` | `u32` | — | The bottom bits input consumed by `glOrtho`. |
| `topBits` | `u32` | — | The top bits input consumed by `glOrtho`. |
| `nearBits` | `u32` | — | The near bits input consumed by `glOrtho`. |
| `farBits` | `u32` | — | The far bits input consumed by `glOrtho`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1278)

<a id="extern_function-extern-function-miniquake-native-glpolygonmode-extern-function-glpolygonmode-face-as-u32-mode-as-u32-from-miniquake-native-dll-symbol-mq-gl-polygon-mode-returns-void-src-miniquake-native-ml-1462130134"></a>
### glPolygonMode

```ml
extern function glPolygonMode(face as u32, mode as u32) from "miniquake_native.dll" symbol "mq_gl_polygon_mode" returns void
```

Invokes the native `glPolygonMode` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `face` | `u32` | — | The face input consumed by `glPolygonMode`. |
| `mode` | `u32` | — | The mode input consumed by `glPolygonMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1203)

<a id="extern_function-extern-function-miniquake-native-glpopmatrix-extern-function-glpopmatrix-from-miniquake-native-dll-symbol-mq-gl-pop-matrix-returns-void-src-miniquake-native-ml-1057995331"></a>
### glPopMatrix

```ml
extern function glPopMatrix() from "miniquake_native.dll" symbol "mq_gl_pop_matrix" returns void
```

Invokes the native `glPopMatrix` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1238)

<a id="extern_function-extern-function-miniquake-native-glpushmatrix-extern-function-glpushmatrix-from-miniquake-native-dll-symbol-mq-gl-push-matrix-returns-void-src-miniquake-native-ml-873975872"></a>
### glPushMatrix

```ml
extern function glPushMatrix() from "miniquake_native.dll" symbol "mq_gl_push_matrix" returns void
```

Invokes the native `glPushMatrix` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1232)

<a id="extern_function-extern-function-miniquake-native-glreadpixels-extern-function-glreadpixels-x-as-i32-y-as-i32-width-as-i32-height-as-i32-format-as-u32-type-as-u32-pixels-as-bytes-from-miniquake-native-dll-symbol-mq-gl-read-pixels-returns-void-src-miniquake-native-ml-1503426485"></a>
### glReadPixels

```ml
extern function glReadPixels(x as i32, y as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_read_pixels" returns void
```

Invokes the native `glReadPixels` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `i32` | — | The x input consumed by `glReadPixels`. |
| `y` | `i32` | — | The y input consumed by `glReadPixels`. |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |
| `format` | `u32` | — | The format input consumed by `glReadPixels`. |
| `type` | `u32` | — | The type input consumed by `glReadPixels`. |
| `pixels` | `bytes` | — | The pixels input consumed by `glReadPixels`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1375)

<a id="extern_function-extern-function-miniquake-native-glrotate-extern-function-glrotate-anglebits-as-u32-xbits-as-u32-ybits-as-u32-zbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-rotate-returns-void-src-miniquake-native-ml-1347143239"></a>
### glRotate

```ml
extern function glRotate(angleBits as u32, xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_rotate" returns void
```

Invokes the native `glRotate` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `angleBits` | `u32` | — | The angle bits input consumed by `glRotate`. |
| `xBits` | `u32` | — | The x bits input consumed by `glRotate`. |
| `yBits` | `u32` | — | The y bits input consumed by `glRotate`. |
| `zBits` | `u32` | — | The z bits input consumed by `glRotate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1257)

<a id="extern_function-extern-function-miniquake-native-glscale-extern-function-glscale-xbits-as-u32-ybits-as-u32-zbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-scale-returns-void-src-miniquake-native-ml-650972709"></a>
### glScale

```ml
extern function glScale(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_scale" returns void
```

Invokes the native `glScale` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `xBits` | `u32` | — | The x bits input consumed by `glScale`. |
| `yBits` | `u32` | — | The y bits input consumed by `glScale`. |
| `zBits` | `u32` | — | The z bits input consumed by `glScale`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1266)

<a id="extern_function-extern-function-miniquake-native-glshademodel-extern-function-glshademodel-mode-as-u32-from-miniquake-native-dll-symbol-mq-gl-shade-model-returns-void-src-miniquake-native-ml-1072426270"></a>
### glShadeModel

```ml
extern function glShadeModel(mode as u32) from "miniquake_native.dll" symbol "mq_gl_shade_model" returns void
```

Invokes the native `glShadeModel` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `u32` | — | The mode input consumed by `glShadeModel`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1195)

<a id="extern_function-extern-function-miniquake-native-glstaticgeometrycall-extern-function-glstaticgeometrycall-keyvalue-as-u64-passvalue-as-i32-from-miniquake-native-dll-symbol-mq-gl-static-geometry-call-returns-i32-src-miniquake-native-ml-852066573"></a>
### glStaticGeometryCall

```ml
extern function glStaticGeometryCall(keyValue as u64, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call" returns i32
```

Invokes the native `glStaticGeometryCall` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyValue` | `u64` | — | The key value input consumed by `glStaticGeometryCall`. |
| `passValue` | `i32` | — | The pass value input consumed by `glStaticGeometryCall`. |


**Returns:** The `i32` result produced by `glStaticGeometryCall`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1736)

<a id="extern_function-extern-function-miniquake-native-glstaticgeometrycallbatch-extern-function-glstaticgeometrycallbatch-keys-as-bytes-bytecount-as-u32-passvalue-as-i32-from-miniquake-native-dll-symbol-mq-gl-static-geometry-call-batch-returns-i32-src-miniquake-native-ml-1062626079"></a>
### glStaticGeometryCallBatch

```ml
extern function glStaticGeometryCallBatch(keys as bytes, byteCount as u32, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call_batch" returns i32
```

Invokes the native `glStaticGeometryCallBatch` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `bytes` | — | The keys input consumed by `glStaticGeometryCallBatch`. |
| `byteCount` | `u32` | — | Number of entries or units to process. |
| `passValue` | `i32` | — | The pass value input consumed by `glStaticGeometryCallBatch`. |


**Returns:** The `i32` result produced by `glStaticGeometryCallBatch`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1746)

<a id="extern_function-extern-function-miniquake-native-glstaticgeometrycallmultitexturebatch-extern-function-glstaticgeometrycallmultitexturebatch-records-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-gl-static-geometry-call-multitexture-batch-returns-i32-src-miniquake-native-ml-1287517922"></a>
### glStaticGeometryCallMultitextureBatch

```ml
extern function glStaticGeometryCallMultitextureBatch(records as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_call_multitexture_batch" returns i32
```

Invokes the native `glStaticGeometryCallMultitextureBatch` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `records` | `bytes` | — | The records input consumed by `glStaticGeometryCallMultitextureBatch`. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `glStaticGeometryCallMultitextureBatch`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1755)

<a id="extern_function-extern-function-miniquake-native-glstaticgeometryclear-extern-function-glstaticgeometryclear-from-miniquake-native-dll-symbol-mq-gl-static-geometry-clear-returns-void-src-miniquake-native-ml-1121738901"></a>
### glStaticGeometryClear

```ml
extern function glStaticGeometryClear() from "miniquake_native.dll" symbol "mq_gl_static_geometry_clear" returns void
```

Invokes the native `glStaticGeometryClear` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1770)

<a id="extern_function-extern-function-miniquake-native-glstaticgeometryprepare-extern-function-glstaticgeometryprepare-keyvalue-as-u64-passvalue-as-i32-from-miniquake-native-dll-symbol-mq-gl-static-geometry-prepare-returns-i32-src-miniquake-native-ml-1706723642"></a>
### glStaticGeometryPrepare

```ml
extern function glStaticGeometryPrepare(keyValue as u64, passValue as i32) from "miniquake_native.dll" symbol "mq_gl_static_geometry_prepare" returns i32
```

Invokes the native `glStaticGeometryPrepare` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyValue` | `u64` | — | The key value input consumed by `glStaticGeometryPrepare`. |
| `passValue` | `i32` | — | The pass value input consumed by `glStaticGeometryPrepare`. |


**Returns:** The `i32` result produced by `glStaticGeometryPrepare`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1764)

<a id="extern_function-extern-function-miniquake-native-gltexcoord2-extern-function-gltexcoord2-sbits-as-u32-tbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-texcoord2-returns-void-src-miniquake-native-ml-1141636229"></a>
### glTexcoord2

```ml
extern function glTexcoord2(sBits as u32, tBits as u32) from "miniquake_native.dll" symbol "mq_gl_texcoord2" returns void
```

Invokes the native `glTexcoord2` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sBits` | `u32` | — | The s bits input consumed by `glTexcoord2`. |
| `tBits` | `u32` | — | The t bits input consumed by `glTexcoord2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1102)

<a id="extern_function-extern-function-miniquake-native-gltexenvi-extern-function-gltexenvi-target-as-u32-name-as-u32-value-as-i32-from-miniquake-native-dll-symbol-mq-gl-tex-env-i-returns-void-src-miniquake-native-ml-695845038"></a>
### glTexEnvI

```ml
extern function glTexEnvI(target as u32, name as u32, value as i32) from "miniquake_native.dll" symbol "mq_gl_tex_env_i" returns void
```

Invokes the native `glTexEnvI` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `u32` | — | The target input consumed by `glTexEnvI`. |
| `name` | `u32` | — | Stable name that identifies the requested object or option. |
| `value` | `i32` | — | Value consumed by `glTexEnvI`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1332)

<a id="extern_function-extern-function-miniquake-native-glteximage2d-extern-function-glteximage2d-target-as-u32-level-as-i32-internalformat-as-i32-width-as-i32-height-as-i32-border-as-i32-format-as-u32-type-as-u32-pixels-as-bytes-from-miniquake-native-dll-symbol-mq-gl-tex-image-2d-returns-void-src-miniquake-native-ml-1789241097"></a>
### glTexImage2D

```ml
extern function glTexImage2D(target as u32, level as i32, internalFormat as i32, width as i32, height as i32, border as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_image_2d" returns void
```

Invokes the native `glTexImage2D` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `u32` | — | The target input consumed by `glTexImage2D`. |
| `level` | `i32` | — | The level input consumed by `glTexImage2D`. |
| `internalFormat` | `i32` | — | The internal format input consumed by `glTexImage2D`. |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |
| `border` | `i32` | — | The border input consumed by `glTexImage2D`. |
| `format` | `u32` | — | The format input consumed by `glTexImage2D`. |
| `type` | `u32` | — | The type input consumed by `glTexImage2D`. |
| `pixels` | `bytes` | — | The pixels input consumed by `glTexImage2D`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1347)

<a id="extern_function-extern-function-miniquake-native-gltexparameteri-extern-function-gltexparameteri-target-as-u32-name-as-u32-value-as-i32-from-miniquake-native-dll-symbol-mq-gl-tex-parameter-i-returns-void-src-miniquake-native-ml-622919798"></a>
### glTexParameterI

```ml
extern function glTexParameterI(target as u32, name as u32, value as i32) from "miniquake_native.dll" symbol "mq_gl_tex_parameter_i" returns void
```

Invokes the native `glTexParameterI` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `u32` | — | The target input consumed by `glTexParameterI`. |
| `name` | `u32` | — | Stable name that identifies the requested object or option. |
| `value` | `i32` | — | Value consumed by `glTexParameterI`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1323)

<a id="extern_function-extern-function-miniquake-native-gltexsubimage2d-extern-function-gltexsubimage2d-target-as-u32-level-as-i32-xoffset-as-i32-yoffset-as-i32-width-as-i32-height-as-i32-format-as-u32-type-as-u32-pixels-as-bytes-from-miniquake-native-dll-symbol-mq-gl-tex-sub-image-2d-returns-void-src-miniquake-native-ml-828391311"></a>
### glTexSubImage2D

```ml
extern function glTexSubImage2D(target as u32, level as i32, xOffset as i32, yOffset as i32, width as i32, height as i32, format as u32, type as u32, pixels as bytes) from "miniquake_native.dll" symbol "mq_gl_tex_sub_image_2d" returns void
```

Invokes the native `glTexSubImage2D` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `u32` | — | The target input consumed by `glTexSubImage2D`. |
| `level` | `i32` | — | The level input consumed by `glTexSubImage2D`. |
| `xOffset` | `i32` | — | Zero-based offset of the requested data. |
| `yOffset` | `i32` | — | Zero-based offset of the requested data. |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |
| `format` | `u32` | — | The format input consumed by `glTexSubImage2D`. |
| `type` | `u32` | — | The type input consumed by `glTexSubImage2D`. |
| `pixels` | `bytes` | — | The pixels input consumed by `glTexSubImage2D`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1362)

<a id="extern_function-extern-function-miniquake-native-gltranslate-extern-function-gltranslate-xbits-as-u32-ybits-as-u32-zbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-translate-returns-void-src-miniquake-native-ml-2130524897"></a>
### glTranslate

```ml
extern function glTranslate(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_translate" returns void
```

Invokes the native `glTranslate` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `xBits` | `u32` | — | The x bits input consumed by `glTranslate`. |
| `yBits` | `u32` | — | The y bits input consumed by `glTranslate`. |
| `zBits` | `u32` | — | The z bits input consumed by `glTranslate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1247)

<a id="extern_function-extern-function-miniquake-native-glvertex2-extern-function-glvertex2-xbits-as-u32-ybits-as-u32-from-miniquake-native-dll-symbol-mq-gl-vertex2-returns-void-src-miniquake-native-ml-311710835"></a>
### glVertex2

```ml
extern function glVertex2(xBits as u32, yBits as u32) from "miniquake_native.dll" symbol "mq_gl_vertex2" returns void
```

Invokes the native `glVertex2` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `xBits` | `u32` | — | The x bits input consumed by `glVertex2`. |
| `yBits` | `u32` | — | The y bits input consumed by `glVertex2`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1085)

<a id="extern_function-extern-function-miniquake-native-glvertex3-extern-function-glvertex3-xbits-as-u32-ybits-as-u32-zbits-as-u32-from-miniquake-native-dll-symbol-mq-gl-vertex3-returns-void-src-miniquake-native-ml-373294396"></a>
### glVertex3

```ml
extern function glVertex3(xBits as u32, yBits as u32, zBits as u32) from "miniquake_native.dll" symbol "mq_gl_vertex3" returns void
```

Invokes the native `glVertex3` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `xBits` | `u32` | — | The x bits input consumed by `glVertex3`. |
| `yBits` | `u32` | — | The y bits input consumed by `glVertex3`. |
| `zBits` | `u32` | — | The z bits input consumed by `glVertex3`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1094)

<a id="extern_function-extern-function-miniquake-native-glviewport-extern-function-glviewport-x-as-i32-y-as-i32-width-as-i32-height-as-i32-from-miniquake-native-dll-symbol-mq-gl-viewport-returns-void-src-miniquake-native-ml-903839210"></a>
### glViewport

```ml
extern function glViewport(x as i32, y as i32, width as i32, height as i32) from "miniquake_native.dll" symbol "mq_gl_viewport" returns void
```

Invokes the native `glViewport` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `i32` | — | The x input consumed by `glViewport`. |
| `y` | `i32` | — | The y input consumed by `glViewport`. |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1213)

<a id="extern_function-extern-function-miniquake-native-glworldprogramavailable-extern-function-glworldprogramavailable-from-miniquake-native-dll-symbol-mq-gl-world-program-available-returns-i32-src-miniquake-native-ml-303867325"></a>
### glWorldProgramAvailable

```ml
extern function glWorldProgramAvailable() from "miniquake_native.dll" symbol "mq_gl_world_program_available" returns i32
```

Invokes the native `glWorldProgramAvailable` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `glWorldProgramAvailable`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1784)

<a id="extern_function-extern-function-miniquake-native-glworldprogramenable-extern-function-glworldprogramenable-enabled-as-i32-from-miniquake-native-dll-symbol-mq-gl-world-program-enable-returns-void-src-miniquake-native-ml-92163912"></a>
### glWorldProgramEnable

```ml
extern function glWorldProgramEnable(enabled as i32) from "miniquake_native.dll" symbol "mq_gl_world_program_enable" returns void
```

Invokes the native `glWorldProgramEnable` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `i32` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1791)

<a id="extern_function-extern-function-miniquake-native-i32tof32-extern-function-i32tof32-value-as-i32-from-miniquake-native-dll-symbol-mq-i32-to-f32-returns-u32-src-miniquake-native-ml-793392131"></a>
### i32ToF32

```ml
extern function i32ToF32(value as i32) from "miniquake_native.dll" symbol "mq_i32_to_f32" returns u32
```

Invokes the native `i32ToF32` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `i32` | — | Value consumed by `i32ToF32`. |


**Returns:** The `u32` result produced by `i32ToF32`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L99)

<a id="function-function-miniquake-native-nativetextresult-function-nativetextresult-buffer-count-src-miniquake-native-ml-1981720106"></a>
### nativeTextResult

```ml
function nativeTextResult(buffer, count)
```

Win64-safe native text bridge.

The MiniLang v1.0 runtime can pass caller-owned bytes reliably, while a
direct extern `returns cstr` may truncate a high-address DLL pointer. Native
string producers therefore return a byte count and write into a MiniLang
buffer owned by the caller.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `nativeTextResult`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1570)

<a id="extern_function-extern-function-miniquake-native-oggchannels-extern-function-oggchannels-from-miniquake-native-dll-symbol-mq-ogg-channels-returns-u32-src-miniquake-native-ml-1139600304"></a>
### oggChannels

```ml
extern function oggChannels() from "miniquake_native.dll" symbol "mq_ogg_channels" returns u32
```

Invokes the native `oggChannels` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `oggChannels`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L891)

<a id="extern_function-extern-function-miniquake-native-oggclose-extern-function-oggclose-from-miniquake-native-dll-symbol-mq-ogg-close-returns-int-src-miniquake-native-ml-1874440515"></a>
### oggClose

```ml
extern function oggClose() from "miniquake_native.dll" symbol "mq_ogg_close" returns int
```

Invokes the native `oggClose` bridge operation used by `miniquake.native`.


**Returns:** The `int` result produced by `oggClose`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L921)

<a id="extern_function-extern-function-miniquake-native-oggdecode-extern-function-oggdecode-output-as-bytes-framecapacity-as-u32-from-miniquake-native-dll-symbol-mq-ogg-decode-returns-u32-src-miniquake-native-ml-390615273"></a>
### oggDecode

```ml
extern function oggDecode(output as bytes, frameCapacity as u32) from "miniquake_native.dll" symbol "mq_ogg_decode" returns u32
```

Invokes the native `oggDecode` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `bytes` | — | Destination buffer that receives decoded PCM samples. |
| `frameCapacity` | `u32` | — | The frame capacity input consumed by `oggDecode`. |


**Returns:** The `u32` result produced by `oggDecode`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L907)

<a id="extern_function-extern-function-miniquake-native-oggframes-extern-function-oggframes-from-miniquake-native-dll-symbol-mq-ogg-frames-returns-u32-src-miniquake-native-ml-1974037170"></a>
### oggFrames

```ml
extern function oggFrames() from "miniquake_native.dll" symbol "mq_ogg_frames" returns u32
```

Invokes the native `oggFrames` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `oggFrames`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L898)

<a id="extern_function-extern-function-miniquake-native-oggopen-extern-function-oggopen-data-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-ogg-open-returns-u32-src-miniquake-native-ml-1359113996"></a>
### oggOpen

```ml
extern function oggOpen(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_ogg_open" returns u32
```

Invokes the native `oggOpen` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `u32` result produced by `oggOpen`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L869)

<a id="extern_function-extern-function-miniquake-native-oggopenfile-extern-function-oggopenfile-filename-as-wstr-from-miniquake-native-dll-symbol-mq-ogg-open-file-returns-u32-src-miniquake-native-ml-469011588"></a>
### oggOpenFile

```ml
extern function oggOpenFile(filename as wstr) from "miniquake_native.dll" symbol "mq_ogg_open_file" returns u32
```

Invokes the native `oggOpenFile` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `wstr` | — | Path of the file to process. |


**Returns:** The `u32` result produced by `oggOpenFile`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L877)

<a id="extern_function-extern-function-miniquake-native-oggrate-extern-function-oggrate-from-miniquake-native-dll-symbol-mq-ogg-rate-returns-u32-src-miniquake-native-ml-529358890"></a>
### oggRate

```ml
extern function oggRate() from "miniquake_native.dll" symbol "mq_ogg_rate" returns u32
```

Invokes the native `oggRate` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `oggRate`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L884)

<a id="extern_function-extern-function-miniquake-native-oggseekstart-extern-function-oggseekstart-from-miniquake-native-dll-symbol-mq-ogg-seek-start-returns-i32-src-miniquake-native-ml-2121032051"></a>
### oggSeekStart

```ml
extern function oggSeekStart() from "miniquake_native.dll" symbol "mq_ogg_seek_start" returns i32
```

Invokes the native `oggSeekStart` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `oggSeekStart`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L914)

<a id="extern_function-extern-function-miniquake-native-processhandlecount-extern-function-processhandlecount-from-miniquake-native-dll-symbol-mq-process-handle-count-returns-u32-src-miniquake-native-ml-46356504"></a>
### processHandleCount

```ml
extern function processHandleCount() from "miniquake_native.dll" symbol "mq_process_handle_count" returns u32
```

Invokes the native `processHandleCount` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `processHandleCount`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L596)

<a id="extern_function-extern-function-miniquake-native-renderavailable-extern-function-renderavailable-backend-as-i32-from-miniquake-native-dll-symbol-mq-render-available-returns-i32-src-miniquake-native-ml-859659702"></a>
### renderAvailable

```ml
extern function renderAvailable(backend as i32) from "miniquake_native.dll" symbol "mq_render_available" returns i32
```

Invokes the native `renderAvailable` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `i32` | — | The backend input consumed by `renderAvailable`. |


**Returns:** The `i32` result produced by `renderAvailable`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L141)

<a id="extern_function-extern-function-miniquake-native-renderbackend-extern-function-renderbackend-from-miniquake-native-dll-symbol-mq-render-backend-returns-i32-src-miniquake-native-ml-937842841"></a>
### renderBackend

```ml
extern function renderBackend() from "miniquake_native.dll" symbol "mq_render_backend" returns i32
```

Invokes the native `renderBackend` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `renderBackend`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L133)

<a id="extern_function-extern-function-miniquake-native-renderselect-extern-function-renderselect-backend-as-i32-from-miniquake-native-dll-symbol-mq-render-select-returns-i32-src-miniquake-native-ml-1924609427"></a>
### renderSelect

```ml
extern function renderSelect(backend as i32) from "miniquake_native.dll" symbol "mq_render_select" returns i32
```

Invokes the native `renderSelect` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backend` | `i32` | — | The backend input consumed by `renderSelect`. |


**Returns:** The `i32` result produced by `renderSelect`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L126)

<a id="extern_function-extern-function-miniquake-native-shadowtracebatch-extern-function-shadowtracebatch-rays-as-bytes-raybytes-as-u32-results-as-bytes-resultbytes-as-u32-from-miniquake-native-dll-symbol-mq-shadow-trace-batch-returns-i32-src-miniquake-native-ml-5046205"></a>
### shadowTraceBatch

```ml
extern function shadowTraceBatch(rays as bytes, rayBytes as u32, results as bytes, resultBytes as u32) from "miniquake_native.dll" symbol "mq_shadow_trace_batch" returns i32
```

Invokes the native `shadowTraceBatch` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rays` | `bytes` | — | The rays input consumed by `shadowTraceBatch`. |
| `rayBytes` | `u32` | — | Byte data consumed by the operation. |
| `results` | `bytes` | — | The results input consumed by `shadowTraceBatch`. |
| `resultBytes` | `u32` | — | Byte data consumed by the operation. |


**Returns:** The `i32` result produced by `shadowTraceBatch`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L176)

<a id="extern_function-extern-function-miniquake-native-shadowworldclear-extern-function-shadowworldclear-from-miniquake-native-dll-symbol-mq-shadow-world-clear-returns-void-src-miniquake-native-ml-311654271"></a>
### shadowWorldClear

```ml
extern function shadowWorldClear() from "miniquake_native.dll" symbol "mq_shadow_world_clear" returns void
```

Invokes the native `shadowWorldClear` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L147)

<a id="extern_function-extern-function-miniquake-native-shadowworldupload-extern-function-shadowworldupload-data-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-shadow-world-upload-returns-i32-src-miniquake-native-ml-1834333917"></a>
### shadowWorldUpload

```ml
extern function shadowWorldUpload(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_shadow_world_upload" returns i32
```

Invokes the native `shadowWorldUpload` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `shadowWorldUpload`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L156)

<a id="extern_function-extern-function-miniquake-native-shadowworlduploadsurfaces-extern-function-shadowworlduploadsurfaces-data-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-shadow-world-upload-surfaces-returns-i32-src-miniquake-native-ml-886689310"></a>
### shadowWorldUploadSurfaces

```ml
extern function shadowWorldUploadSurfaces(data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_shadow_world_upload_surfaces" returns i32
```

Invokes the native `shadowWorldUploadSurfaces` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `shadowWorldUploadSurfaces`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L165)

<a id="function-function-miniquake-native-sin-function-sin-value-src-miniquake-native-ml-643148338"></a>
### sin

```ml
function sin(value)
```

Implements the `sin` operation for `miniquake.native` (sin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `sin`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1709)

<a id="function-function-miniquake-native-sqrt-function-sqrt-value-src-miniquake-native-ml-1192250074"></a>
### sqrt

```ml
function sqrt(value)
```

Implements the `sqrt` operation for `miniquake.native` (sqrt).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `sqrt`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1721)

<a id="extern_function-extern-function-miniquake-native-sysconsolealloc-extern-function-sysconsolealloc-from-miniquake-native-dll-symbol-mq-sys-console-alloc-returns-i32-src-miniquake-native-ml-2026645077"></a>
### sysConsoleAlloc

```ml
extern function sysConsoleAlloc() from "miniquake_native.dll" symbol "mq_sys_console_alloc" returns i32
```

Invokes the native `sysConsoleAlloc` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `sysConsoleAlloc`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L612)

<a id="extern_function-extern-function-miniquake-native-sysconsoleeventpop-extern-function-sysconsoleeventpop-from-miniquake-native-dll-symbol-mq-sys-console-event-pop-returns-u32-src-miniquake-native-ml-1133401912"></a>
### sysConsoleEventPop

```ml
extern function sysConsoleEventPop() from "miniquake_native.dll" symbol "mq_sys_console_event_pop" returns u32
```

Invokes the native `sysConsoleEventPop` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `sysConsoleEventPop`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L626)

<a id="extern_function-extern-function-miniquake-native-sysconsolefree-extern-function-sysconsolefree-from-miniquake-native-dll-symbol-mq-sys-console-free-returns-i32-src-miniquake-native-ml-525718910"></a>
### sysConsoleFree

```ml
extern function sysConsoleFree() from "miniquake_native.dll" symbol "mq_sys_console_free" returns i32
```

Invokes the native `sysConsoleFree` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `sysConsoleFree`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L619)

<a id="extern_function-extern-function-miniquake-native-sysconsolewrite-extern-function-sysconsolewrite-text-as-cstr-from-miniquake-native-dll-symbol-mq-sys-console-write-returns-i32-src-miniquake-native-ml-810847514"></a>
### sysConsoleWrite

```ml
extern function sysConsoleWrite(text as cstr) from "miniquake_native.dll" symbol "mq_sys_console_write" returns i32
```

Invokes the native `sysConsoleWrite` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `cstr` | — | Text to parse or process. |


**Returns:** The `i32` result produced by `sysConsoleWrite`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L634)

<a id="extern_function-extern-function-miniquake-native-syscounter-extern-function-syscounter-from-miniquake-native-dll-symbol-mq-sys-counter-returns-u64-src-miniquake-native-ml-1236806181"></a>
### sysCounter

```ml
extern function sysCounter() from "miniquake_native.dll" symbol "mq_sys_counter" returns u64
```

Invokes the native `sysCounter` bridge operation used by `miniquake.native`.


**Returns:** The `u64` result produced by `sysCounter`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L582)

<a id="extern_function-extern-function-miniquake-native-sysfrequency-extern-function-sysfrequency-from-miniquake-native-dll-symbol-mq-sys-frequency-returns-u64-src-miniquake-native-ml-19691007"></a>
### sysFrequency

```ml
extern function sysFrequency() from "miniquake_native.dll" symbol "mq_sys_frequency" returns u64
```

Invokes the native `sysFrequency` bridge operation used by `miniquake.native`.


**Returns:** The `u64` result produced by `sysFrequency`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L589)

<a id="extern_function-extern-function-miniquake-native-sysmakecodewriteable-extern-function-sysmakecodewriteable-address-as-u64-length-as-u64-from-miniquake-native-dll-symbol-mq-sys-make-code-writeable-returns-i32-src-miniquake-native-ml-1952699476"></a>
### sysMakeCodeWriteable

```ml
extern function sysMakeCodeWriteable(address as u64, length as u64) from "miniquake_native.dll" symbol "mq_sys_make_code_writeable" returns i32
```

Invokes the native `sysMakeCodeWriteable` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `u64` | — | Network address of the peer. |
| `length` | `u64` | — | Length of the requested data in units appropriate to the operation. |


**Returns:** The `i32` result produced by `sysMakeCodeWriteable`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L605)

<a id="extern_function-extern-function-miniquake-native-syssleepuntilinput-extern-function-syssleepuntilinput-milliseconds-as-u32-from-miniquake-native-dll-symbol-mq-sys-sleep-until-input-returns-void-src-miniquake-native-ml-647451893"></a>
### sysSleepUntilInput

```ml
extern function sysSleepUntilInput(milliseconds as u32) from "miniquake_native.dll" symbol "mq_sys_sleep_until_input" returns void
```

Invokes the native `sysSleepUntilInput` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `u32` | — | The milliseconds input consumed by `sysSleepUntilInput`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L641)

<a id="function-function-miniquake-native-trunc-function-trunc-value-src-miniquake-native-ml-656621778"></a>
### trunc

```ml
function trunc(value)
```

Implements the `trunc` operation for `miniquake.native` (trunc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `trunc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1686)

<a id="function-function-miniquake-native-udpboundaddress-function-udpboundaddress-handle-src-miniquake-native-ml-1021095049"></a>
### udpBoundAddress

```ml
function udpBoundAddress(handle)
```

Implements the `udpBoundAddress` operation for `miniquake.native` (udp bound address).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `udpBoundAddress`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1623)

<a id="extern_function-extern-function-miniquake-native-udpboundaddressraw-extern-function-udpboundaddressraw-handle-as-u64-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-udp-bound-address-returns-u32-src-miniquake-native-ml-1104113390"></a>
### udpBoundAddressRaw

```ml
extern function udpBoundAddressRaw(handle as u64, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_bound_address" returns u32
```

Invokes the native `udpBoundAddressRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpBoundAddressRaw`. |
| `output` | `bytes` | — | Destination buffer that receives the bound address. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `udpBoundAddressRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L964)

<a id="extern_function-extern-function-miniquake-native-udpboundport-extern-function-udpboundport-handle-as-u64-from-miniquake-native-dll-symbol-mq-udp-bound-port-returns-u32-src-miniquake-native-ml-2069238571"></a>
### udpBoundPort

```ml
extern function udpBoundPort(handle as u64) from "miniquake_native.dll" symbol "mq_udp_bound_port" returns u32
```

Invokes the native `udpBoundPort` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpBoundPort`. |


**Returns:** The `u32` result produced by `udpBoundPort`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L954)

<a id="extern_function-extern-function-miniquake-native-udpclose-extern-function-udpclose-handle-as-u64-from-miniquake-native-dll-symbol-mq-udp-close-returns-void-src-miniquake-native-ml-343139653"></a>
### udpClose

```ml
extern function udpClose(handle as u64) from "miniquake_native.dll" symbol "mq_udp_close" returns void
```

Invokes the native `udpClose` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpClose`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L946)

<a id="extern_function-extern-function-miniquake-native-udpenablebroadcast-extern-function-udpenablebroadcast-handle-as-u64-from-miniquake-native-dll-symbol-mq-udp-enable-broadcast-returns-i32-src-miniquake-native-ml-1942589950"></a>
### udpEnableBroadcast

```ml
extern function udpEnableBroadcast(handle as u64) from "miniquake_native.dll" symbol "mq_udp_enable_broadcast" returns i32
```

Invokes the native `udpEnableBroadcast` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpEnableBroadcast`. |


**Returns:** The `i32` result produced by `udpEnableBroadcast`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L972)

<a id="function-function-miniquake-native-udphostname-function-udphostname-src-miniquake-native-ml-2139237497"></a>
### udpHostName

```ml
function udpHostName()
```

Return udp host name derived from the active module state.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1641)

<a id="extern_function-extern-function-miniquake-native-udphostnameraw-extern-function-udphostnameraw-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-udp-host-name-returns-u32-src-miniquake-native-ml-489056728"></a>
### udpHostNameRaw

```ml
extern function udpHostNameRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_host_name" returns u32
```

Invokes the native `udpHostNameRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `bytes` | — | Destination buffer that receives the local host name. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `udpHostNameRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1043)

<a id="function-function-miniquake-native-udplastaddress-function-udplastaddress-src-miniquake-native-ml-669742733"></a>
### udpLastAddress

```ml
function udpLastAddress()
```

Implements the `udpLastAddress` operation for `miniquake.native` (udp last address).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1629)

<a id="extern_function-extern-function-miniquake-native-udplastaddressraw-extern-function-udplastaddressraw-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-udp-last-address-returns-u32-src-miniquake-native-ml-1151953747"></a>
### udpLastAddressRaw

```ml
extern function udpLastAddressRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_last_address" returns u32
```

Invokes the native `udpLastAddressRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `bytes` | — | Destination buffer that receives the most recent peer address. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `udpLastAddressRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1011)

<a id="extern_function-extern-function-miniquake-native-udplasterror-extern-function-udplasterror-from-miniquake-native-dll-symbol-mq-udp-last-error-returns-i32-src-miniquake-native-ml-1804568481"></a>
### udpLastError

```ml
extern function udpLastError() from "miniquake_native.dll" symbol "mq_udp_last_error" returns i32
```

Invokes the native `udpLastError` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `udpLastError`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1025)

<a id="extern_function-extern-function-miniquake-native-udplastport-extern-function-udplastport-from-miniquake-native-dll-symbol-mq-udp-last-port-returns-u32-src-miniquake-native-ml-1890982868"></a>
### udpLastPort

```ml
extern function udpLastPort() from "miniquake_native.dll" symbol "mq_udp_last_port" returns u32
```

Invokes the native `udpLastPort` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `udpLastPort`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1018)

<a id="function-function-miniquake-native-udplocaladdress-function-udplocaladdress-src-miniquake-native-ml-1451527553"></a>
### udpLocalAddress

```ml
function udpLocalAddress()
```

Implements the `udpLocalAddress` operation for `miniquake.native` (udp local address).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1635)

<a id="extern_function-extern-function-miniquake-native-udplocaladdressraw-extern-function-udplocaladdressraw-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-udp-local-address-returns-u32-src-miniquake-native-ml-1532998576"></a>
### udpLocalAddressRaw

```ml
extern function udpLocalAddressRaw(output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_local_address" returns u32
```

Invokes the native `udpLocalAddressRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `bytes` | — | Destination buffer that receives the local address. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `udpLocalAddressRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1034)

<a id="extern_function-extern-function-miniquake-native-udpopen-extern-function-udpopen-port-as-u32-from-miniquake-native-dll-symbol-mq-udp-open-returns-u64-src-miniquake-native-ml-939617618"></a>
### udpOpen

```ml
extern function udpOpen(port as u32) from "miniquake_native.dll" symbol "mq_udp_open" returns u64
```

Invokes the native `udpOpen` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `u32` | — | The port input consumed by `udpOpen`. |


**Returns:** The `u64` result produced by `udpOpen`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L930)

<a id="extern_function-extern-function-miniquake-native-udpopenbound-extern-function-udpopenbound-port-as-u32-address-as-cstr-from-miniquake-native-dll-symbol-mq-udp-open-bound-returns-u64-src-miniquake-native-ml-730739453"></a>
### udpOpenBound

```ml
extern function udpOpenBound(port as u32, address as cstr) from "miniquake_native.dll" symbol "mq_udp_open_bound" returns u64
```

Invokes the native `udpOpenBound` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `u32` | — | The port input consumed by `udpOpenBound`. |
| `address` | `cstr` | — | Network address of the peer. |


**Returns:** The `u64` result produced by `udpOpenBound`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L939)

<a id="extern_function-extern-function-miniquake-native-udppeek-extern-function-udppeek-handle-as-u64-from-miniquake-native-dll-symbol-mq-udp-peek-returns-i32-src-miniquake-native-ml-1890136252"></a>
### udpPeek

```ml
extern function udpPeek(handle as u64) from "miniquake_native.dll" symbol "mq_udp_peek" returns i32
```

Invokes the native `udpPeek` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpPeek`. |


**Returns:** The `i32` result produced by `udpPeek`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L980)

<a id="extern_function-extern-function-miniquake-native-udpreceive-extern-function-udpreceive-handle-as-u64-data-as-bytes-capacity-as-u32-from-miniquake-native-dll-symbol-mq-udp-receive-returns-i32-src-miniquake-native-ml-1311591091"></a>
### udpReceive

```ml
extern function udpReceive(handle as u64, data as bytes, capacity as u32) from "miniquake_native.dll" symbol "mq_udp_receive" returns i32
```

Invokes the native `udpReceive` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpReceive`. |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `i32` result produced by `udpReceive`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1002)

<a id="function-function-miniquake-native-udpresolvename-function-udpresolvename-name-src-miniquake-native-ml-480302956"></a>
### udpResolveName

```ml
function udpResolveName(name)
```

Return udp resolve name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1648)

<a id="extern_function-extern-function-miniquake-native-udpresolvenameraw-extern-function-udpresolvenameraw-name-as-cstr-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-udp-resolve-name-returns-u32-src-miniquake-native-ml-87009129"></a>
### udpResolveNameRaw

```ml
extern function udpResolveNameRaw(name as cstr, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_resolve_name" returns u32
```

Invokes the native `udpResolveNameRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `cstr` | — | Stable name that identifies the requested object or option. |
| `output` | `bytes` | — | Destination buffer that receives the resolved address. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `udpResolveNameRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1053)

<a id="function-function-miniquake-native-udpreversename-function-udpreversename-address-src-miniquake-native-ml-282853857"></a>
### udpReverseName

```ml
function udpReverseName(address)
```

Return udp reverse name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — | Network address of the peer. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1655)

<a id="extern_function-extern-function-miniquake-native-udpreversenameraw-extern-function-udpreversenameraw-address-as-cstr-output-as-bytes-capacity-as-u32-from-miniquake-text-dll-symbol-mqt-udp-reverse-name-returns-u32-src-miniquake-native-ml-797659396"></a>
### udpReverseNameRaw

```ml
extern function udpReverseNameRaw(address as cstr, output as bytes, capacity as u32) from "miniquake_text.dll" symbol "mqt_udp_reverse_name" returns u32
```

Invokes the native `udpReverseNameRaw` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `cstr` | — | Network address of the peer. |
| `output` | `bytes` | — | Destination buffer that receives the reverse-resolved name. |
| `capacity` | `u32` | — | Maximum number of entries the destination can hold. |


**Returns:** The `u32` result produced by `udpReverseNameRaw`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L1063)

<a id="extern_function-extern-function-miniquake-native-udpsend-extern-function-udpsend-handle-as-u64-address-as-cstr-port-as-u32-data-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-udp-send-returns-i32-src-miniquake-native-ml-126156432"></a>
### udpSend

```ml
extern function udpSend(handle as u64, address as cstr, port as u32, data as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_udp_send" returns i32
```

Invokes the native `udpSend` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `u64` | — | The handle input consumed by `udpSend`. |
| `address` | `cstr` | — | Network address of the peer. |
| `port` | `u32` | — | The port input consumed by `udpSend`. |
| `data` | `bytes` | — | Input data consumed by the operation. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `udpSend`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L992)

<a id="extern_function-extern-function-miniquake-native-winactivate-extern-function-winactivate-active-as-i32-minimized-as-i32-from-miniquake-native-dll-symbol-mq-win-activate-returns-void-src-miniquake-native-ml-956692150"></a>
### winActivate

```ml
extern function winActivate(active as i32, minimized as i32) from "miniquake_native.dll" symbol "mq_win_activate" returns void
```

Invokes the native `winActivate` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `i32` | — | The active input consumed by `winActivate`. |
| `minimized` | `i32` | — | The minimized input consumed by `winActivate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L415)

<a id="extern_function-extern-function-miniquake-native-winclientheight-extern-function-winclientheight-from-miniquake-native-dll-symbol-mq-win-client-height-returns-i32-src-miniquake-native-ml-152556408"></a>
### winClientHeight

```ml
extern function winClientHeight() from "miniquake_native.dll" symbol "mq_win_client_height" returns i32
```

Invokes the native `winClientHeight` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winClientHeight`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L262)

<a id="extern_function-extern-function-miniquake-native-winclientwidth-extern-function-winclientwidth-from-miniquake-native-dll-symbol-mq-win-client-width-returns-i32-src-miniquake-native-ml-1849297763"></a>
### winClientWidth

```ml
extern function winClientWidth() from "miniquake_native.dll" symbol "mq_win_client_width" returns i32
```

Invokes the native `winClientWidth` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winClientWidth`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L255)

<a id="extern_function-extern-function-miniquake-native-winconfiguredisplaymode-extern-function-winconfiguredisplaymode-width-as-i32-height-as-i32-bpp-as-i32-frequency-as-i32-fullscreen-as-i32-usecurrent-as-i32-from-miniquake-native-dll-symbol-mq-win-configure-display-mode-returns-i32-src-miniquake-native-ml-1592115692"></a>
### winConfigureDisplayMode

```ml
extern function winConfigureDisplayMode(width as i32, height as i32, bpp as i32, frequency as i32, fullscreen as i32, useCurrent as i32) from "miniquake_native.dll" symbol "mq_win_configure_display_mode" returns i32
```

Invokes the native `winConfigureDisplayMode` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |
| `bpp` | `i32` | — | The bpp input consumed by `winConfigureDisplayMode`. |
| `frequency` | `i32` | — | The frequency input consumed by `winConfigureDisplayMode`. |
| `fullscreen` | `i32` | — | The fullscreen input consumed by `winConfigureDisplayMode`. |
| `useCurrent` | `i32` | — | The use current input consumed by `winConfigureDisplayMode`. |


**Returns:** The `i32` result produced by `winConfigureDisplayMode`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L369)

<a id="extern_function-extern-function-miniquake-native-wincontextready-extern-function-wincontextready-from-miniquake-native-dll-symbol-mq-win-context-ready-returns-i32-src-miniquake-native-ml-659613640"></a>
### winContextReady

```ml
extern function winContextReady() from "miniquake_native.dll" symbol "mq_win_context_ready" returns i32
```

Invokes the native `winContextReady` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winContextReady`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L400)

<a id="extern_function-extern-function-miniquake-native-wincreate-extern-function-wincreate-title-as-wstr-width-as-i32-height-as-i32-fullscreen-as-i32-from-miniquake-native-dll-symbol-mq-win-create-returns-ptr-src-miniquake-native-ml-204146271"></a>
### winCreate

```ml
extern function winCreate(title as wstr, width as i32, height as i32, fullscreen as i32) from "miniquake_native.dll" symbol "mq_win_create" returns ptr
```

Invokes the native `winCreate` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `wstr` | — | The title input consumed by `winCreate`. |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |
| `fullscreen` | `i32` | — | The fullscreen input consumed by `winCreate`. |


**Returns:** The `ptr` result produced by `winCreate`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L188)

<a id="extern_function-extern-function-miniquake-native-wincursorcenter-extern-function-wincursorcenter-from-miniquake-native-dll-symbol-mq-win-cursor-center-returns-i32-src-miniquake-native-ml-1924166011"></a>
### winCursorCenter

```ml
extern function winCursorCenter() from "miniquake_native.dll" symbol "mq_win_cursor_center" returns i32
```

Invokes the native `winCursorCenter` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winCursorCenter`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L487)

<a id="extern_function-extern-function-miniquake-native-wincursorshow-extern-function-wincursorshow-show-as-i32-from-miniquake-native-dll-symbol-mq-win-cursor-show-returns-void-src-miniquake-native-ml-1960645498"></a>
### winCursorShow

```ml
extern function winCursorShow(show as i32) from "miniquake_native.dll" symbol "mq_win_cursor_show" returns void
```

Invokes the native `winCursorShow` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `show` | `i32` | — | The show input consumed by `winCursorShow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L480)

<a id="extern_function-extern-function-miniquake-native-windesktopheight-extern-function-windesktopheight-from-miniquake-native-dll-symbol-mq-win-desktop-height-returns-i32-src-miniquake-native-ml-1853687057"></a>
### winDesktopHeight

```ml
extern function winDesktopHeight() from "miniquake_native.dll" symbol "mq_win_desktop_height" returns i32
```

Invokes the native `winDesktopHeight` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winDesktopHeight`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L306)

<a id="extern_function-extern-function-miniquake-native-windesktopwidth-extern-function-windesktopwidth-from-miniquake-native-dll-symbol-mq-win-desktop-width-returns-i32-src-miniquake-native-ml-833335808"></a>
### winDesktopWidth

```ml
extern function winDesktopWidth() from "miniquake_native.dll" symbol "mq_win_desktop_width" returns i32
```

Invokes the native `winDesktopWidth` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winDesktopWidth`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L299)

<a id="extern_function-extern-function-miniquake-native-windestroy-extern-function-windestroy-from-miniquake-native-dll-symbol-mq-win-destroy-returns-void-src-miniquake-native-ml-553308317"></a>
### winDestroy

```ml
extern function winDestroy() from "miniquake_native.dll" symbol "mq_win_destroy" returns void
```

Invokes the native `winDestroy` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L194)

<a id="extern_function-extern-function-miniquake-native-windisplaymodebpp-extern-function-windisplaymodebpp-index-as-u32-from-miniquake-native-dll-symbol-mq-win-display-mode-bpp-returns-i32-src-miniquake-native-ml-331519704"></a>
### winDisplayModeBpp

```ml
extern function winDisplayModeBpp(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_bpp" returns i32
```

Invokes the native `winDisplayModeBpp` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `u32` | — | Zero-based index of the requested entry. |


**Returns:** The `i32` result produced by `winDisplayModeBpp`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L337)

<a id="extern_function-extern-function-miniquake-native-windisplaymodecount-extern-function-windisplaymodecount-from-miniquake-native-dll-symbol-mq-win-display-mode-count-returns-u32-src-miniquake-native-ml-1634659569"></a>
### winDisplayModeCount

```ml
extern function winDisplayModeCount() from "miniquake_native.dll" symbol "mq_win_display_mode_count" returns u32
```

Invokes the native `winDisplayModeCount` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `winDisplayModeCount`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L313)

<a id="extern_function-extern-function-miniquake-native-windisplaymodefrequency-extern-function-windisplaymodefrequency-index-as-u32-from-miniquake-native-dll-symbol-mq-win-display-mode-frequency-returns-i32-src-miniquake-native-ml-1463444980"></a>
### winDisplayModeFrequency

```ml
extern function winDisplayModeFrequency(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_frequency" returns i32
```

Invokes the native `winDisplayModeFrequency` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `u32` | — | Zero-based index of the requested entry. |


**Returns:** The `i32` result produced by `winDisplayModeFrequency`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L345)

<a id="extern_function-extern-function-miniquake-native-windisplaymodeheight-extern-function-windisplaymodeheight-index-as-u32-from-miniquake-native-dll-symbol-mq-win-display-mode-height-returns-i32-src-miniquake-native-ml-766443085"></a>
### winDisplayModeHeight

```ml
extern function winDisplayModeHeight(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_height" returns i32
```

Invokes the native `winDisplayModeHeight` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `u32` | — | Zero-based index of the requested entry. |


**Returns:** The `i32` result produced by `winDisplayModeHeight`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L329)

<a id="extern_function-extern-function-miniquake-native-windisplaymodewidth-extern-function-windisplaymodewidth-index-as-u32-from-miniquake-native-dll-symbol-mq-win-display-mode-width-returns-i32-src-miniquake-native-ml-1793075218"></a>
### winDisplayModeWidth

```ml
extern function winDisplayModeWidth(index as u32) from "miniquake_native.dll" symbol "mq_win_display_mode_width" returns i32
```

Invokes the native `winDisplayModeWidth` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `u32` | — | Zero-based index of the requested entry. |


**Returns:** The `i32` result produced by `winDisplayModeWidth`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L321)

<a id="extern_function-extern-function-miniquake-native-wingetgammaramp-extern-function-wingetgammaramp-ramp-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-win-get-gamma-ramp-returns-i32-src-miniquake-native-ml-284072844"></a>
### winGetGammaRamp

```ml
extern function winGetGammaRamp(ramp as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_win_get_gamma_ramp" returns i32
```

Invokes the native `winGetGammaRamp` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ramp` | `bytes` | — | The ramp input consumed by `winGetGammaRamp`. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `winGetGammaRamp`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L384)

<a id="extern_function-extern-function-miniquake-native-winhasfocus-extern-function-winhasfocus-from-miniquake-native-dll-symbol-mq-win-has-focus-returns-i32-src-miniquake-native-ml-1151910048"></a>
### winHasFocus

```ml
extern function winHasFocus() from "miniquake_native.dll" symbol "mq_win_has_focus" returns i32
```

Invokes the native `winHasFocus` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winHasFocus`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L248)

<a id="extern_function-extern-function-miniquake-native-wininputeventpop-extern-function-wininputeventpop-from-miniquake-native-dll-symbol-mq-win-input-event-pop-returns-u32-src-miniquake-native-ml-1609386794"></a>
### winInputEventPop

```ml
extern function winInputEventPop() from "miniquake_native.dll" symbol "mq_win_input_event_pop" returns u32
```

Invokes the native `winInputEventPop` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `winInputEventPop`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L464)

<a id="extern_function-extern-function-miniquake-native-wininputtestpush-extern-function-wininputtestpush-eventtype-as-u32-code-as-u32-value-as-i32-from-miniquake-native-dll-symbol-mq-win-input-test-push-returns-void-src-miniquake-native-ml-1545887069"></a>
### winInputTestPush

```ml
extern function winInputTestPush(eventType as u32, code as u32, value as i32) from "miniquake_native.dll" symbol "mq_win_input_test_push" returns void
```

Invokes the native `winInputTestPush` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `eventType` | `u32` | — | The event type input consumed by `winInputTestPush`. |
| `code` | `u32` | — | The code input consumed by `winInputTestPush`. |
| `value` | `i32` | — | Value consumed by `winInputTestPush`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L473)

<a id="extern_function-extern-function-miniquake-native-winisminimized-extern-function-winisminimized-from-miniquake-native-dll-symbol-mq-win-is-minimized-returns-i32-src-miniquake-native-ml-145982088"></a>
### winIsMinimized

```ml
extern function winIsMinimized() from "miniquake_native.dll" symbol "mq_win_is_minimized" returns i32
```

Invokes the native `winIsMinimized` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winIsMinimized`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L292)

<a id="extern_function-extern-function-miniquake-native-winjoyaxis-extern-function-winjoyaxis-axis-as-u32-from-miniquake-native-dll-symbol-mq-win-joy-axis-returns-u32-src-miniquake-native-ml-1474008618"></a>
### winJoyAxis

```ml
extern function winJoyAxis(axis as u32) from "miniquake_native.dll" symbol "mq_win_joy_axis" returns u32
```

Invokes the native `winJoyAxis` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `axis` | `u32` | — | The axis input consumed by `winJoyAxis`. |


**Returns:** The `u32` result produced by `winJoyAxis`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L516)

<a id="extern_function-extern-function-miniquake-native-winjoybuttoncount-extern-function-winjoybuttoncount-from-miniquake-native-dll-symbol-mq-win-joy-button-count-returns-u32-src-miniquake-native-ml-1358964912"></a>
### winJoyButtonCount

```ml
extern function winJoyButtonCount() from "miniquake_native.dll" symbol "mq_win_joy_button_count" returns u32
```

Invokes the native `winJoyButtonCount` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `winJoyButtonCount`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L537)

<a id="extern_function-extern-function-miniquake-native-winjoybuttons-extern-function-winjoybuttons-from-miniquake-native-dll-symbol-mq-win-joy-buttons-returns-u32-src-miniquake-native-ml-975186165"></a>
### winJoyButtons

```ml
extern function winJoyButtons() from "miniquake_native.dll" symbol "mq_win_joy_buttons" returns u32
```

Invokes the native `winJoyButtons` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `winJoyButtons`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L523)

<a id="extern_function-extern-function-miniquake-native-winjoyhaspov-extern-function-winjoyhaspov-from-miniquake-native-dll-symbol-mq-win-joy-has-pov-returns-i32-src-miniquake-native-ml-235710770"></a>
### winJoyHasPov

```ml
extern function winJoyHasPov() from "miniquake_native.dll" symbol "mq_win_joy_has_pov" returns i32
```

Invokes the native `winJoyHasPov` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winJoyHasPov`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L544)

<a id="extern_function-extern-function-miniquake-native-winjoypov-extern-function-winjoypov-from-miniquake-native-dll-symbol-mq-win-joy-pov-returns-u32-src-miniquake-native-ml-530551249"></a>
### winJoyPov

```ml
extern function winJoyPov() from "miniquake_native.dll" symbol "mq_win_joy_pov" returns u32
```

Invokes the native `winJoyPov` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `winJoyPov`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L530)

<a id="extern_function-extern-function-miniquake-native-winjoyread-extern-function-winjoyread-from-miniquake-native-dll-symbol-mq-win-joy-read-returns-i32-src-miniquake-native-ml-797597560"></a>
### winJoyRead

```ml
extern function winJoyRead() from "miniquake_native.dll" symbol "mq_win_joy_read" returns i32
```

Invokes the native `winJoyRead` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winJoyRead`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L508)

<a id="extern_function-extern-function-miniquake-native-winjoystartup-extern-function-winjoystartup-from-miniquake-native-dll-symbol-mq-win-joy-startup-returns-i32-src-miniquake-native-ml-1362613373"></a>
### winJoyStartup

```ml
extern function winJoyStartup() from "miniquake_native.dll" symbol "mq_win_joy_startup" returns i32
```

Invokes the native `winJoyStartup` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winJoyStartup`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L501)

<a id="extern_function-extern-function-miniquake-native-winjoywarriorcurve-extern-function-winjoywarriorcurve-rawvalue-as-i32-from-miniquake-native-dll-symbol-mq-win-joy-warrior-curve-returns-i32-src-miniquake-native-ml-1898166753"></a>
### winJoyWarriorCurve

```ml
extern function winJoyWarriorCurve(rawValue as i32) from "miniquake_native.dll" symbol "mq_win_joy_warrior_curve" returns i32
```

Invokes the native `winJoyWarriorCurve` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rawValue` | `i32` | — | The raw value input consumed by `winJoyWarriorCurve`. |


**Returns:** The `i32` result produced by `winJoyWarriorCurve`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L552)

<a id="extern_function-extern-function-miniquake-native-winjoywarriorcurvef32-extern-function-winjoywarriorcurvef32-rawvalue-as-i32-from-miniquake-native-dll-symbol-mq-win-joy-warrior-curve-f32-returns-u32-src-miniquake-native-ml-1126454819"></a>
### winJoyWarriorCurveF32

```ml
extern function winJoyWarriorCurveF32(rawValue as i32) from "miniquake_native.dll" symbol "mq_win_joy_warrior_curve_f32" returns u32
```

Invokes the native `winJoyWarriorCurveF32` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rawValue` | `i32` | — | The raw value input consumed by `winJoyWarriorCurveF32`. |


**Returns:** The `u32` result produced by `winJoyWarriorCurveF32`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L560)

<a id="extern_function-extern-function-miniquake-native-winkeydown-extern-function-winkeydown-virtualkey-as-i32-from-miniquake-native-dll-symbol-mq-win-key-down-returns-i32-src-miniquake-native-ml-1883471797"></a>
### winKeyDown

```ml
extern function winKeyDown(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_down" returns i32
```

Invokes the native `winKeyDown` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `virtualKey` | `i32` | — | The virtual key input consumed by `winKeyDown`. |


**Returns:** The `i32` result produced by `winKeyDown`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L215)

<a id="extern_function-extern-function-miniquake-native-winkeypressed-extern-function-winkeypressed-virtualkey-as-i32-from-miniquake-native-dll-symbol-mq-win-key-pressed-returns-i32-src-miniquake-native-ml-1699342697"></a>
### winKeyPressed

```ml
extern function winKeyPressed(virtualKey as i32) from "miniquake_native.dll" symbol "mq_win_key_pressed" returns i32
```

Invokes the native `winKeyPressed` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `virtualKey` | `i32` | — | The virtual key input consumed by `winKeyPressed`. |


**Returns:** The `i32` result produced by `winKeyPressed`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L223)

<a id="extern_function-extern-function-miniquake-native-winkeysnapshot-extern-function-winkeysnapshot-downstates-as-bytes-pressedstates-as-bytes-querymask-as-bytes-statecount-as-u32-from-miniquake-native-dll-symbol-mq-win-key-snapshot-returns-i32-src-miniquake-native-ml-1457618642"></a>
### winKeySnapshot

```ml
extern function winKeySnapshot(downStates as bytes, pressedStates as bytes, queryMask as bytes, stateCount as u32) from "miniquake_native.dll" symbol "mq_win_key_snapshot" returns i32
```

Invokes the native `winKeySnapshot` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `downStates` | `bytes` | — | The down states input consumed by `winKeySnapshot`. |
| `pressedStates` | `bytes` | — | The pressed states input consumed by `winKeySnapshot`. |
| `queryMask` | `bytes` | — | The query mask input consumed by `winKeySnapshot`. |
| `stateCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `winKeySnapshot`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L234)

<a id="extern_function-extern-function-miniquake-native-winmakecurrent-extern-function-winmakecurrent-from-miniquake-native-dll-symbol-mq-win-make-current-returns-i32-src-miniquake-native-ml-1476724759"></a>
### winMakeCurrent

```ml
extern function winMakeCurrent() from "miniquake_native.dll" symbol "mq_win_make_current" returns i32
```

Invokes the native `winMakeCurrent` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winMakeCurrent`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L407)

<a id="extern_function-extern-function-miniquake-native-winmousebuttons-extern-function-winmousebuttons-from-miniquake-native-dll-symbol-mq-win-mouse-buttons-returns-i32-src-miniquake-native-ml-1761526406"></a>
### winMouseButtons

```ml
extern function winMouseButtons() from "miniquake_native.dll" symbol "mq_win_mouse_buttons" returns i32
```

Invokes the native `winMouseButtons` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winMouseButtons`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L450)

<a id="extern_function-extern-function-miniquake-native-winmousedx-extern-function-winmousedx-from-miniquake-native-dll-symbol-mq-win-mouse-dx-returns-i32-src-miniquake-native-ml-1384802083"></a>
### winMouseDx

```ml
extern function winMouseDx() from "miniquake_native.dll" symbol "mq_win_mouse_dx" returns i32
```

Invokes the native `winMouseDx` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winMouseDx`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L436)

<a id="extern_function-extern-function-miniquake-native-winmousedy-extern-function-winmousedy-from-miniquake-native-dll-symbol-mq-win-mouse-dy-returns-i32-src-miniquake-native-ml-1528143784"></a>
### winMouseDy

```ml
extern function winMouseDy() from "miniquake_native.dll" symbol "mq_win_mouse_dy" returns i32
```

Invokes the native `winMouseDy` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winMouseDy`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L443)

<a id="extern_function-extern-function-miniquake-native-winmousewheel-extern-function-winmousewheel-from-miniquake-native-dll-symbol-mq-win-mouse-wheel-returns-i32-src-miniquake-native-ml-82876568"></a>
### winMouseWheel

```ml
extern function winMouseWheel() from "miniquake_native.dll" symbol "mq_win_mouse_wheel" returns i32
```

Invokes the native `winMouseWheel` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winMouseWheel`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L457)

<a id="extern_function-extern-function-miniquake-native-winpoll-extern-function-winpoll-from-miniquake-native-dll-symbol-mq-win-poll-returns-i32-src-miniquake-native-ml-665067958"></a>
### winPoll

```ml
extern function winPoll() from "miniquake_native.dll" symbol "mq_win_poll" returns i32
```

Invokes the native `winPoll` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winPoll`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L201)

<a id="extern_function-extern-function-miniquake-native-winresizeclient-extern-function-winresizeclient-width-as-i32-height-as-i32-from-miniquake-native-dll-symbol-mq-win-resize-client-returns-i32-src-miniquake-native-ml-77366854"></a>
### winResizeClient

```ml
extern function winResizeClient(width as i32, height as i32) from "miniquake_native.dll" symbol "mq_win_resize_client" returns i32
```

Invokes the native `winResizeClient` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |


**Returns:** The `i32` result produced by `winResizeClient`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L271)

<a id="extern_function-extern-function-miniquake-native-winrestoredisplaymode-extern-function-winrestoredisplaymode-from-miniquake-native-dll-symbol-mq-win-restore-display-mode-returns-void-src-miniquake-native-ml-1067487604"></a>
### winRestoreDisplayMode

```ml
extern function winRestoreDisplayMode() from "miniquake_native.dll" symbol "mq_win_restore_display_mode" returns void
```

Invokes the native `winRestoreDisplayMode` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L375)

<a id="extern_function-extern-function-miniquake-native-winsetcursorcapture-extern-function-winsetcursorcapture-enabled-as-i32-from-miniquake-native-dll-symbol-mq-win-set-cursor-capture-returns-void-src-miniquake-native-ml-1545696610"></a>
### winSetCursorCapture

```ml
extern function winSetCursorCapture(enabled as i32) from "miniquake_native.dll" symbol "mq_win_set_cursor_capture" returns void
```

Invokes the native `winSetCursorCapture` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enabled` | `i32` | — | Whether the optional behavior is enabled. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L429)

<a id="extern_function-extern-function-miniquake-native-winsetgammaramp-extern-function-winsetgammaramp-ramp-as-bytes-bytecount-as-u32-from-miniquake-native-dll-symbol-mq-win-set-gamma-ramp-returns-i32-src-miniquake-native-ml-1075073056"></a>
### winSetGammaRamp

```ml
extern function winSetGammaRamp(ramp as bytes, byteCount as u32) from "miniquake_native.dll" symbol "mq_win_set_gamma_ramp" returns i32
```

Invokes the native `winSetGammaRamp` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ramp` | `bytes` | — | The ramp input consumed by `winSetGammaRamp`. |
| `byteCount` | `u32` | — | Number of entries or units to process. |


**Returns:** The `i32` result produced by `winSetGammaRamp`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L393)

<a id="extern_function-extern-function-miniquake-native-winsettitle-extern-function-winsettitle-title-as-wstr-from-miniquake-native-dll-symbol-mq-win-set-title-returns-void-src-miniquake-native-ml-555514090"></a>
### winSetTitle

```ml
extern function winSetTitle(title as wstr) from "miniquake_native.dll" symbol "mq_win_set_title" returns void
```

Invokes the native `winSetTitle` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `wstr` | — | The title input consumed by `winSetTitle`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L422)

<a id="extern_function-extern-function-miniquake-native-winsleep-extern-function-winsleep-milliseconds-as-u32-from-miniquake-native-dll-symbol-mq-win-sleep-returns-void-src-miniquake-native-ml-1141643624"></a>
### winSleep

```ml
extern function winSleep(milliseconds as u32) from "miniquake_native.dll" symbol "mq_win_sleep" returns void
```

Invokes the native `winSleep` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `u32` | — | The milliseconds input consumed by `winSleep`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L574)

<a id="extern_function-extern-function-miniquake-native-winswap-extern-function-winswap-from-miniquake-native-dll-symbol-mq-win-swap-returns-void-src-miniquake-native-ml-578473732"></a>
### winSwap

```ml
extern function winSwap() from "miniquake_native.dll" symbol "mq_win_swap" returns void
```

Invokes the native `winSwap` bridge operation used by `miniquake.native`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L207)

<a id="extern_function-extern-function-miniquake-native-wintestdisplaymode-extern-function-wintestdisplaymode-width-as-i32-height-as-i32-bpp-as-i32-frequency-as-i32-from-miniquake-native-dll-symbol-mq-win-test-display-mode-returns-i32-src-miniquake-native-ml-124274973"></a>
### winTestDisplayMode

```ml
extern function winTestDisplayMode(width as i32, height as i32, bpp as i32, frequency as i32) from "miniquake_native.dll" symbol "mq_win_test_display_mode" returns i32
```

Invokes the native `winTestDisplayMode` bridge operation used by `miniquake.native`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `i32` | — | Requested width in pixels or data units. |
| `height` | `i32` | — | Requested height in pixels or data units. |
| `bpp` | `i32` | — | The bpp input consumed by `winTestDisplayMode`. |
| `frequency` | `i32` | — | The frequency input consumed by `winTestDisplayMode`. |


**Returns:** The `i32` result produced by `winTestDisplayMode`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L356)

<a id="extern_function-extern-function-miniquake-native-wintextpop-extern-function-wintextpop-from-miniquake-native-dll-symbol-mq-win-text-pop-returns-i32-src-miniquake-native-ml-168062680"></a>
### winTextPop

```ml
extern function winTextPop() from "miniquake_native.dll" symbol "mq_win_text_pop" returns i32
```

Invokes the native `winTextPop` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winTextPop`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L241)

<a id="extern_function-extern-function-miniquake-native-winticks-extern-function-winticks-from-miniquake-native-dll-symbol-mq-win-ticks-returns-u32-src-miniquake-native-ml-688370683"></a>
### winTicks

```ml
extern function winTicks() from "miniquake_native.dll" symbol "mq_win_ticks" returns u32
```

Invokes the native `winTicks` bridge operation used by `miniquake.native`.


**Returns:** The `u32` result produced by `winTicks`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L567)

<a id="extern_function-extern-function-miniquake-native-winupdateclipcursor-extern-function-winupdateclipcursor-from-miniquake-native-dll-symbol-mq-win-update-clip-cursor-returns-i32-src-miniquake-native-ml-233087436"></a>
### winUpdateClipCursor

```ml
extern function winUpdateClipCursor() from "miniquake_native.dll" symbol "mq_win_update_clip_cursor" returns i32
```

Invokes the native `winUpdateClipCursor` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winUpdateClipCursor`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L494)

<a id="extern_function-extern-function-miniquake-native-winwindowx-extern-function-winwindowx-from-miniquake-native-dll-symbol-mq-win-window-x-returns-i32-src-miniquake-native-ml-1088529584"></a>
### winWindowX

```ml
extern function winWindowX() from "miniquake_native.dll" symbol "mq_win_window_x" returns i32
```

Invokes the native `winWindowX` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winWindowX`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L278)

<a id="extern_function-extern-function-miniquake-native-winwindowy-extern-function-winwindowy-from-miniquake-native-dll-symbol-mq-win-window-y-returns-i32-src-miniquake-native-ml-1422180503"></a>
### winWindowY

```ml
extern function winWindowY() from "miniquake_native.dll" symbol "mq_win_window_y" returns i32
```

Invokes the native `winWindowY` bridge operation used by `miniquake.native`.


**Returns:** The `i32` result produced by `winWindowY`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/native.ml#L285)
