# `src/miniquake/protocol_signon.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.protocol_signon`](Package-miniquake-protocol-signon-877996400.md)

Reachable from entry: **yes**

## Imports

- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_write.ml` as `writer` → [src/miniquake/protocol_write.ml](File-src-miniquake-protocol-write-ml-1461808162.md)

## Declarations

<a id="function-function-miniquake-protocol-signon-writeclientreply-function-writeclientreply-buffer-stage-name-colors-spawnparms-src-miniquake-protocol-signon-ml-1717987916"></a>
### writeClientReply

```ml
function writeClientReply(buffer, stage, name, colors, spawnParms)
```

CL_SignonReply from cl_main.c. Stage four is local client state only and deliberately writes no command: the first fast entity update promotes 3->4.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | The buffer input consumed by `writeClientReply`. |
| `stage` | `dynamic` | — | The stage input consumed by `writeClientReply`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `colors` | `dynamic` | — | The colors input consumed by `writeClientReply`. |
| `spawnParms` | `dynamic` | — | The spawn parms input consumed by `writeClientReply`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/protocol_signon.ml#L21)
