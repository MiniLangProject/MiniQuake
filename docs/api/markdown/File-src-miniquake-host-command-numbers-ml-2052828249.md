# `src/miniquake/host_command_numbers.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.host_command_numbers`](Package-miniquake-host-command-numbers-1345603898.md)

Reachable from entry: **yes**

## Imports

- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)

## Declarations

<a id="function-function-miniquake-host-command-numbers-colorarguments-function-colorarguments-arguments-firstindex-src-miniquake-host-command-numbers-ml-534130147"></a>
### colorArguments

```ml
function colorArguments(arguments, firstIndex)
```

Implements the `colorArguments` operation for `miniquake.host_command_numbers` (color arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `firstIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_command_numbers.ml#L42)

<a id="function-function-miniquake-host-command-numbers-colorcomponent-function-colorcomponent-value-src-miniquake-host-command-numbers-ml-1362358322"></a>
### colorComponent

```ml
function colorComponent(value)
```

Implements the `colorComponent` operation for `miniquake.host_command_numbers` (color component).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `colorComponent`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_command_numbers.ml#L33)

<a id="function-function-miniquake-host-command-numbers-integer-function-integer-text-src-miniquake-host-command-numbers-ml-1664968644"></a>
### integer

```ml
function integer(text)
```

Implements the `integer` operation for `miniquake.host_command_numbers` (integer).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_command_numbers.ml#L25)

<a id="function-function-miniquake-host-command-numbers-playerindex-function-playerindex-text-src-miniquake-host-command-numbers-ml-1718931186"></a>
### playerIndex

```ml
function playerIndex(text)
```

Return player index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/host_command_numbers.ml#L18)
