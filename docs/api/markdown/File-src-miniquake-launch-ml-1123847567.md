# `src/miniquake/launch.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.launch`](Package-miniquake-launch-2029011624.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-launch-appendpluscommand-function-appendpluscommand-commands-args-startindex-src-miniquake-launch-ml-719744530"></a>
### appendPlusCommand

```ml
function appendPlusCommand(commands, args, startIndex)
```

Add state for append plus command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commands` | `dynamic` | — | The commands input consumed by `appendPlusCommand`. |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |
| `startIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L76)

<a id="function-function-miniquake-launch-commandname-function-commandname-text-src-miniquake-launch-ml-390959020"></a>
### commandName

```ml
function commandName(text)
```

Return command name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L66)

<a id="function-function-miniquake-launch-firstbyte-function-firstbyte-text-src-miniquake-launch-ml-177548228"></a>
### firstByte

```ml
function firstByte(text)
```

Return first byte for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L15)

<a id="function-function-miniquake-launch-hasparm-function-hasparm-options-name-src-miniquake-launch-ml-1270693982"></a>
### hasParm

```ml
function hasParm(options, name)
```

Report whether parm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `dynamic` | — | The options input consumed by `hasParm`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L277)

<a id="function-function-miniquake-launch-integeroption-function-integeroption-text-fallback-minimum-maximum-src-miniquake-launch-ml-2045519298"></a>
### integerOption

```ml
function integerOption(text, fallback, minimum, maximum)
```

Implements the `integerOption` operation for `miniquake.launch` (integer option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |
| `minimum` | `dynamic` | — | Smallest accepted value. |
| `maximum` | `dynamic` | — | Largest accepted value. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L56)

<a id="function-function-miniquake-launch-parse-function-parse-args-src-miniquake-launch-ml-1868044956"></a>
### parse

```ml
function parse(args)
```

Implements the `parse` operation for `miniquake.launch` (parse).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L127)

<a id="function-function-miniquake-launch-startuptext-function-startuptext-options-src-miniquake-launch-ml-635374991"></a>
### startupText

```ml
function startupText(options)
```

Initialize state for startup text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `dynamic` | — | The options input consumed by `startupText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L266)

<a id="function-function-miniquake-launch-stripmapname-function-stripmapname-name-src-miniquake-launch-ml-1112356240"></a>
### stripMapName

```ml
function stripMapName(name)
```

Convert map name into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L36)

<a id="function-function-miniquake-launch-substring-function-substring-text-offset-count-src-miniquake-launch-ml-598860534"></a>
### substring

```ml
function substring(text, offset, count)
```

Implements the `substring` operation for `miniquake.launch` (substring).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L25)

<a id="function-function-miniquake-launch-words-function-words-text-src-miniquake-launch-ml-616948438"></a>
### words

```ml
function words(text)
```

Implements the `words` operation for `miniquake.launch` (words).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/launch.ml#L90)
