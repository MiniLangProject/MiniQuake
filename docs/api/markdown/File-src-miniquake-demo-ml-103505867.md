# `src/miniquake/demo.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.demo`](Package-miniquake-demo-1375427500.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrays` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-demo-cl-playdemo-f-function-cl-playdemo-f-data-src-miniquake-demo-ml-617512017"></a>
### CL_PlayDemo_f

```ml
function CL_PlayDemo_f(data)
```

Apply the Quake-compatible cl play demo f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L220)

<a id="function-function-miniquake-demo-cl-record-f-function-cl-record-f-arguments-connected-src-miniquake-demo-ml-506991712"></a>
### CL_Record_f

```ml
function CL_Record_f(arguments, connected)
```

Apply the Quake-compatible cl record f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `connected` | `dynamic` | — | The connected input consumed by `CL_Record_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L202)

<a id="function-function-miniquake-demo-cl-stop-f-function-cl-stop-f-recording-viewangles-src-miniquake-demo-ml-1245083357"></a>
### CL_Stop_f

```ml
function CL_Stop_f(recording, viewAngles)
```

Apply the Quake-compatible cl stop f behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recording` | `dynamic` | — | The recording input consumed by `CL_Stop_f`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `CL_Stop_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L190)

<a id="function-function-miniquake-demo-cl-writedemomessage-function-cl-writedemomessage-recording-payload-viewangles-src-miniquake-demo-ml-2072471177"></a>
### CL_WriteDemoMessage

```ml
function CL_WriteDemoMessage(recording, payload, viewAngles)
```

Apply the Quake-compatible cl write demo message behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recording` | `dynamic` | — | The recording input consumed by `CL_WriteDemoMessage`. |
| `payload` | `dynamic` | — | The payload input consumed by `CL_WriteDemoMessage`. |
| `viewAngles` | `dynamic` | — | The view angles input consumed by `CL_WriteDemoMessage`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L174)

<a id="function-function-miniquake-demo-filename-function-filename-name-src-miniquake-demo-ml-883694240"></a>
### filename

```ml
function filename(name)
```

Implements the `filename` operation for `miniquake.demo` (filename).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L28)

<a id="function-function-miniquake-demo-hassuffixinsensitive-function-hassuffixinsensitive-text-suffix-src-miniquake-demo-ml-1463666735"></a>
### hasSuffixInsensitive

```ml
function hasSuffixInsensitive(text, suffix)
```

Report whether suffix insensitive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `suffix` | `dynamic` | — | The suffix input consumed by `hasSuffixInsensitive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L20)

<a id="function-function-miniquake-demo-iskeepalivepayload-function-iskeepalivepayload-payload-src-miniquake-demo-ml-179364275"></a>
### isKeepalivePayload

```ml
function isKeepalivePayload(payload)
```

Report whether is keepalive payload.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | The payload input consumed by `isKeepalivePayload`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L67)

<a id="function-function-miniquake-demo-load-function-load-filename-src-miniquake-demo-ml-99013314"></a>
### load

```ml
function load(filename)
```

Implements the `load` operation for `miniquake.demo` (load).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L135)

<a id="function-function-miniquake-demo-parse-function-parse-data-src-miniquake-demo-ml-1253662511"></a>
### parse

```ml
function parse(data)
```

Implements the `parse` operation for `miniquake.demo` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L96)

<a id="function-function-miniquake-demo-parsetrack-function-parsetrack-data-src-miniquake-demo-ml-261662189"></a>
### parseTrack

```ml
function parseTrack(data)
```

Read and validate track.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L73)

<a id="function-function-miniquake-demo-recordtracknumber-function-recordtracknumber-text-src-miniquake-demo-ml-1818678858"></a>
### recordTrackNumber

```ml
function recordTrackNumber(text)
```

CL_Record_f uses the C library atoi, not MiniLang toNumber/Q_atof.  It skips leading ASCII whitespace, accepts an optional sign, consumes the initial decimal digit run and returns zero when no digits are present.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L44)

<a id="function-function-miniquake-demo-save-function-save-filename-recording-src-miniquake-demo-ml-215055641"></a>
### save

```ml
function save(filename, recording)
```

Implements the `save` operation for `miniquake.demo` (save).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |
| `recording` | `dynamic` | — | The recording input consumed by `save`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L166)

<a id="function-function-miniquake-demo-serialize-function-serialize-recording-src-miniquake-demo-ml-2003425748"></a>
### serialize

```ml
function serialize(recording)
```

Implements the `serialize` operation for `miniquake.demo` (serialize).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recording` | `dynamic` | — | The recording input consumed by `serialize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/demo.ml#L141)
