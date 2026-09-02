# `src/miniquake/zone.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.zone`](Package-miniquake-zone-859242805.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-miniquake-zone-align8-function-align8-value-src-miniquake-zone-ml-1994065760"></a>
### align8

```ml
function align8(value)
```

Implements the `align8` operation for `miniquake.zone` (align8).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `align8`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L65)

<a id="constant-constant-miniquake-zone-block-header-size-const-block-header-size-24-src-miniquake-zone-ml-1258822404"></a>
### BLOCK_HEADER_SIZE

```ml
const BLOCK_HEADER_SIZE = 24
```

Defines the block header size value used by `miniquake.zone`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L19)

<a id="function-function-miniquake-zone-check-function-check-state-src-miniquake-zone-ml-1880672076"></a>
### check

```ml
function check(state)
```

Implements the `check` operation for `miniquake.zone` (check).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `check`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L147)

<a id="function-function-miniquake-zone-clear-function-clear-state-size-src-miniquake-zone-ml-316572501"></a>
### clear

```ml
function clear(state, size)
```

Implements the `clear` operation for `miniquake.zone` (clear).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `clear`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L72)

<a id="function-function-miniquake-zone-create-function-create-size-src-miniquake-zone-ml-608013442"></a>
### create

```ml
function create(size)
```

Implements the `create` operation for `miniquake.zone` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L99)

<a id="function-function-miniquake-zone-dumpheap-function-dumpheap-state-src-miniquake-zone-ml-2017150608"></a>
### dumpHeap

```ml
function dumpHeap(state)
```

Implements the `dumpHeap` operation for `miniquake.zone` (dump heap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `dumpHeap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L297)

<a id="constant-constant-miniquake-zone-dynamic-size-const-dynamic-size-49152-src-miniquake-zone-ml-629708877"></a>
### DYNAMIC_SIZE

```ml
const DYNAMIC_SIZE = 49152
```

Defines the dynamic size value used by `miniquake.zone`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L11)

<a id="function-function-miniquake-zone-free-function-free-block-src-miniquake-zone-ml-58604320"></a>
### free

```ml
function free(block)
```

Implements the `free` operation for `miniquake.zone` (free).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `free`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L242)

<a id="function-function-miniquake-zone-freememory-function-freememory-state-src-miniquake-zone-ml-2011427944"></a>
### freeMemory

```ml
function freeMemory(state)
```

Release state for free memory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `freeMemory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L277)

<a id="function-function-miniquake-zone-indexof-function-indexof-state-block-src-miniquake-zone-ml-2079991633"></a>
### indexOf

```ml
function indexOf(state, block)
```

Return index of for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `indexOf`. |
| `block` | `dynamic` | — | The block input consumed by `indexOf`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L107)

<a id="function-function-miniquake-zone-insertafter-function-insertafter-state-index-block-src-miniquake-zone-ml-184040529"></a>
### insertAfter

```ml
function insertAfter(state, index, block)
```

Add state for insert after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `insertAfter`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |
| `block` | `dynamic` | — | The block input consumed by `insertAfter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L122)

<a id="function-function-miniquake-zone-malloc-function-malloc-state-size-src-miniquake-zone-ml-217765099"></a>
### malloc

```ml
function malloc(state, size)
```

Implements the `malloc` operation for `miniquake.zone` (malloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `malloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L233)

<a id="constant-constant-miniquake-zone-minfragment-const-minfragment-64-src-miniquake-zone-ml-850000940"></a>
### MINFRAGMENT

```ml
const MINFRAGMENT = 64
```

Defines the minfragment value used by `miniquake.zone`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L15)

<a id="function-function-miniquake-zone-printheap-function-printheap-state-src-miniquake-zone-ml-1224958826"></a>
### printHeap

```ml
function printHeap(state)
```

Format and emit heap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `printHeap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L287)

<a id="function-function-miniquake-zone-removeat-function-removeat-state-index-src-miniquake-zone-ml-573040596"></a>
### removeAt

```ml
function removeAt(state, index)
```

Release state for remove at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `removeAt`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L136)

<a id="function-function-miniquake-zone-tagmalloc-function-tagmalloc-state-size-tag-src-miniquake-zone-ml-473629045"></a>
### tagMalloc

```ml
function tagMalloc(state, size, tag)
```

Implements the `tagMalloc` operation for `miniquake.zone` (tag malloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `tagMalloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `tag` | `dynamic` | — | The tag input consumed by `tagMalloc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L177)

<a id="constant-constant-miniquake-zone-trash-size-const-trash-size-4-src-miniquake-zone-ml-1472999542"></a>
### TRASH_SIZE

```ml
const TRASH_SIZE = 4
```

Defines the trash size value used by `miniquake.zone`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L21)

<a id="function-function-miniquake-zone-z-checkheap-function-z-checkheap-state-src-miniquake-zone-ml-743084142"></a>
### Z_CheckHeap

```ml
function Z_CheckHeap(state)
```

Mirror Quake's Z_CheckHeap routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_CheckHeap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L344)

<a id="function-function-miniquake-zone-z-clearzone-function-z-clearzone-state-size-src-miniquake-zone-ml-317056515"></a>
### Z_ClearZone

```ml
function Z_ClearZone(state, size)
```

Explicit zone.c/header entry points. The zone state parameter replaces the original process-global mainzone pointer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_ClearZone`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L305)

<a id="function-function-miniquake-zone-z-dumpheap-function-z-dumpheap-state-src-miniquake-zone-ml-267471940"></a>
### Z_DumpHeap

```ml
function Z_DumpHeap(state)
```

Mirror Quake's Z_DumpHeap routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_DumpHeap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L338)

<a id="function-function-miniquake-zone-z-free-function-z-free-block-src-miniquake-zone-ml-928250516"></a>
### Z_Free

```ml
function Z_Free(block)
```

Mirror Quake's Z_Free routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `Z_Free`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L311)

<a id="function-function-miniquake-zone-z-freememory-function-z-freememory-state-src-miniquake-zone-ml-473526316"></a>
### Z_FreeMemory

```ml
function Z_FreeMemory(state)
```

Mirror Quake's Z_FreeMemory routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_FreeMemory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L350)

<a id="function-function-miniquake-zone-z-malloc-function-z-malloc-state-size-src-miniquake-zone-ml-459075811"></a>
### Z_Malloc

```ml
function Z_Malloc(state, size)
```

Mirror Quake's Z_Malloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_Malloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L318)

<a id="function-function-miniquake-zone-z-print-function-z-print-state-src-miniquake-zone-ml-2129007004"></a>
### Z_Print

```ml
function Z_Print(state)
```

Mirror Quake's Z_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_Print`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L332)

<a id="function-function-miniquake-zone-z-tagmalloc-function-z-tagmalloc-state-size-tag-src-miniquake-zone-ml-367957151"></a>
### Z_TagMalloc

```ml
function Z_TagMalloc(state, size, tag)
```

Mirror Quake's Z_TagMalloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.zone` state used by `Z_TagMalloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `tag` | `dynamic` | — | The tag input consumed by `Z_TagMalloc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L326)

<a id="constant-constant-miniquake-zone-zone-admin-size-const-zone-admin-size-32-src-miniquake-zone-ml-6185271"></a>
### ZONE_ADMIN_SIZE

```ml
const ZONE_ADMIN_SIZE = 32
```

Defines the zone admin size value used by `miniquake.zone`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L17)

- [miniquake.zone.ZoneBlock](Type-miniquake-zone-zoneblock-520275716.md) — struct
<a id="constant-constant-miniquake-zone-zoneid-const-zoneid-1919505-src-miniquake-zone-ml-2075908316"></a>
### ZONEID

```ml
const ZONEID = 1919505
```

Defines the zoneid value used by `miniquake.zone`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/zone.ml#L13)

- [miniquake.zone.ZoneState](Type-miniquake-zone-zonestate-1593612236.md) — struct
