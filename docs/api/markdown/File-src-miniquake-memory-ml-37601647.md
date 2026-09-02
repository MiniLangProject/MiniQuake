# `src/miniquake/memory.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.memory`](Package-miniquake-memory-517763568.md)

Reachable from entry: **yes**

## Imports

- `miniquake/protocol_text.ml` as `quakeText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/zone.ml` as `zone` → [src/miniquake/zone.ml](File-src-miniquake-zone-ml-1287623204.md)

## Declarations

<a id="function-function-miniquake-memory-align16-inline-function-align16-value-src-miniquake-memory-ml-1239360427"></a>
### align16

```ml
inline function align16(value)
```

Implements the `align16` operation for `miniquake.memory` (align16).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `align16`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L108)

<a id="function-function-miniquake-memory-allocate-function-allocate-state-size-name-kind-src-miniquake-memory-ml-1107195326"></a>
### allocate

```ml
function allocate(state, size, name, kind)
```

Implements the `allocate` operation for `miniquake.memory` (allocate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `allocate`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `kind` | `dynamic` | — | The kind input consumed by `allocate`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L762)

<a id="function-function-miniquake-memory-cache-alloc-function-cache-alloc-state-user-size-name-src-miniquake-memory-ml-2119051145"></a>
### Cache_Alloc

```ml
function Cache_Alloc(state, user, size, name)
```

Mirror Quake's Cache_Alloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Alloc`. |
| `user` | `dynamic` | — | The user input consumed by `Cache_Alloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L967)

<a id="function-function-miniquake-memory-cache-check-function-cache-check-state-user-src-miniquake-memory-ml-406052301"></a>
### Cache_Check

```ml
function Cache_Check(state, user)
```

Implements the `Cache_Check` operation for `miniquake.memory` (cache check).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Check`. |
| `user` | `dynamic` | — | The user input consumed by `Cache_Check`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L958)

<a id="function-function-miniquake-memory-cache-compact-function-cache-compact-state-src-miniquake-memory-ml-1864137098"></a>
### Cache_Compact

```ml
function Cache_Compact(state)
```

Mirror Quake's Cache_Compact routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Compact`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L939)

<a id="function-function-miniquake-memory-cache-flush-function-cache-flush-state-src-miniquake-memory-ml-1773880272"></a>
### Cache_Flush

```ml
function Cache_Flush(state)
```

Mirror Quake's Cache_Flush routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Flush`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L921)

<a id="function-function-miniquake-memory-cache-free-function-cache-free-user-src-miniquake-memory-ml-1530134612"></a>
### Cache_Free

```ml
function Cache_Free(user)
```

Mirror Quake's Cache_Free routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `user` | `dynamic` | — | The user input consumed by `Cache_Free`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L951)

<a id="function-function-miniquake-memory-cache-freehigh-function-cache-freehigh-state-newhighhunk-src-miniquake-memory-ml-1205977562"></a>
### Cache_FreeHigh

```ml
function Cache_FreeHigh(state, newHighHunk)
```

Mirror Quake's Cache_FreeHigh routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_FreeHigh`. |
| `newHighHunk` | `dynamic` | — | The new high hunk input consumed by `Cache_FreeHigh`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L895)

<a id="function-function-miniquake-memory-cache-freelow-function-cache-freelow-state-newlowhunk-src-miniquake-memory-ml-1427936188"></a>
### Cache_FreeLow

```ml
function Cache_FreeLow(state, newLowHunk)
```

Mirror Quake's Cache_FreeLow routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_FreeLow`. |
| `newLowHunk` | `dynamic` | — | The new low hunk input consumed by `Cache_FreeLow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L888)

<a id="constant-constant-miniquake-memory-cache-header-size-const-cache-header-size-40-src-miniquake-memory-ml-606373978"></a>
### CACHE_HEADER_SIZE

```ml
const CACHE_HEADER_SIZE = 40
```

Defines the cache header size value used by `miniquake.memory`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L18)

<a id="function-function-miniquake-memory-cache-init-function-cache-init-state-src-miniquake-memory-ml-1896027878"></a>
### Cache_Init

```ml
function Cache_Init(state)
```

Mirror Quake's Cache_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L945)

<a id="function-function-miniquake-memory-cache-makelru-function-cache-makelru-block-src-miniquake-memory-ml-1836112366"></a>
### Cache_MakeLRU

```ml
function Cache_MakeLRU(block)
```

Mirror Quake's Cache_MakeLRU routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `Cache_MakeLRU`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L907)

<a id="function-function-miniquake-memory-cache-move-function-cache-move-block-src-miniquake-memory-ml-441110446"></a>
### Cache_Move

```ml
function Cache_Move(block)
```

Mirror Quake's Cache_Move routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `Cache_Move`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L881)

<a id="function-function-miniquake-memory-cache-print-function-cache-print-state-src-miniquake-memory-ml-923865314"></a>
### Cache_Print

```ml
function Cache_Print(state)
```

Mirror Quake's Cache_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Print`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L927)

<a id="function-function-miniquake-memory-cache-report-function-cache-report-state-src-miniquake-memory-ml-11779038"></a>
### Cache_Report

```ml
function Cache_Report(state)
```

Mirror Quake's Cache_Report routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_Report`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L933)

<a id="function-function-miniquake-memory-cache-tryalloc-function-cache-tryalloc-state-size-nobottom-src-miniquake-memory-ml-1677225661"></a>
### Cache_TryAlloc

```ml
function Cache_TryAlloc(state, size, noBottom)
```

Mirror Quake's Cache_TryAlloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Cache_TryAlloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `noBottom` | `dynamic` | — | The no bottom input consumed by `Cache_TryAlloc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L915)

<a id="function-function-miniquake-memory-cache-unlinklru-function-cache-unlinklru-block-src-miniquake-memory-ml-775501280"></a>
### Cache_UnlinkLRU

```ml
function Cache_UnlinkLRU(block)
```

Mirror Quake's Cache_UnlinkLRU routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `Cache_UnlinkLRU`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L901)

<a id="function-function-miniquake-memory-cachealloc-function-cachealloc-state-size-name-src-miniquake-memory-ml-290606188"></a>
### cacheAlloc

```ml
function cacheAlloc(state, size, name)
```

Implements the `cacheAlloc` operation for `miniquake.memory` (cache alloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheAlloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L600)

<a id="function-function-miniquake-memory-cacheallocuser-function-cacheallocuser-state-user-size-name-src-miniquake-memory-ml-821992865"></a>
### cacheAllocUser

```ml
function cacheAllocUser(state, user, size, name)
```

Implements the `cacheAllocUser` operation for `miniquake.memory` (cache alloc user).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheAllocUser`. |
| `user` | `dynamic` | — | The user input consumed by `cacheAllocUser`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L561)

- [miniquake.memory.CacheBlock](Type-miniquake-memory-cacheblock-1820573865.md) — struct
<a id="function-function-miniquake-memory-cachecheck-function-cachecheck-state-user-src-miniquake-memory-ml-1317966199"></a>
### cacheCheck

```ml
function cacheCheck(state, user)
```

Implements the `cacheCheck` operation for `miniquake.memory` (cache check).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheCheck`. |
| `user` | `dynamic` | — | The user input consumed by `cacheCheck`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L549)

<a id="function-function-miniquake-memory-cachecompact-function-cachecompact-state-src-miniquake-memory-ml-1509939246"></a>
### cacheCompact

```ml
function cacheCompact(state)
```

Implements the `cacheCompact` operation for `miniquake.memory` (cache compact).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheCompact`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L679)

<a id="function-function-miniquake-memory-cacheflush-function-cacheflush-state-src-miniquake-memory-ml-792253710"></a>
### cacheFlush

```ml
function cacheFlush(state)
```

Implements the `cacheFlush` operation for `miniquake.memory` (cache flush).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheFlush`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L654)

<a id="function-function-miniquake-memory-cachefree-function-cachefree-user-src-miniquake-memory-ml-1130112048"></a>
### cacheFree

```ml
function cacheFree(user)
```

Implements the `cacheFree` operation for `miniquake.memory` (cache free).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `user` | `dynamic` | — | The user input consumed by `cacheFree`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L530)

<a id="function-function-miniquake-memory-cachefreehigh-function-cachefreehigh-state-newhighhunk-src-miniquake-memory-ml-1215134842"></a>
### cacheFreeHigh

```ml
function cacheFreeHigh(state, newHighHunk)
```

Implements the `cacheFreeHigh` operation for `miniquake.memory` (cache free high).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheFreeHigh`. |
| `newHighHunk` | `dynamic` | — | The new high hunk input consumed by `cacheFreeHigh`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L641)

<a id="function-function-miniquake-memory-cachefreelow-function-cachefreelow-state-newlowhunk-src-miniquake-memory-ml-2145701546"></a>
### cacheFreeLow

```ml
function cacheFreeLow(state, newLowHunk)
```

Implements the `cacheFreeLow` operation for `miniquake.memory` (cache free low).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheFreeLow`. |
| `newLowHunk` | `dynamic` | — | The new low hunk input consumed by `cacheFreeLow`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L629)

<a id="function-function-miniquake-memory-cacheinit-function-cacheinit-state-src-miniquake-memory-ml-282819534"></a>
### cacheInit

```ml
function cacheInit(state)
```

Update subsystem state for cache init.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheInit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L685)

<a id="function-function-miniquake-memory-cachemove-function-cachemove-block-src-miniquake-memory-ml-143930832"></a>
### cacheMove

```ml
function cacheMove(block)
```

Implements the `cacheMove` operation for `miniquake.memory` (cache move).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `cacheMove`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L609)

<a id="function-function-miniquake-memory-cachepayloadused-function-cachepayloadused-state-src-miniquake-memory-ml-1215957870"></a>
### cachePayloadUsed

```ml
function cachePayloadUsed(state)
```

Implements the `cachePayloadUsed` operation for `miniquake.memory` (cache payload used).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cachePayloadUsed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L140)

<a id="function-function-miniquake-memory-cacheprint-function-cacheprint-state-src-miniquake-memory-ml-906277062"></a>
### cachePrint

```ml
function cachePrint(state)
```

Implements the `cachePrint` operation for `miniquake.memory` (cache print).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cachePrint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L663)

<a id="function-function-miniquake-memory-cachereport-function-cachereport-state-src-miniquake-memory-ml-2099374582"></a>
### cacheReport

```ml
function cacheReport(state)
```

Implements the `cacheReport` operation for `miniquake.memory` (cache report).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheReport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L673)

<a id="function-function-miniquake-memory-cachestartindex-function-cachestartindex-state-block-src-miniquake-memory-ml-388496919"></a>
### cacheStartIndex

```ml
function cacheStartIndex(state, block)
```

Return cache start index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheStartIndex`. |
| `block` | `dynamic` | — | The block input consumed by `cacheStartIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L397)

<a id="function-function-miniquake-memory-cachetryalloc-function-cachetryalloc-state-span-nobottom-src-miniquake-memory-ml-831336886"></a>
### cacheTryAlloc

```ml
function cacheTryAlloc(state, span, noBottom)
```

Implements the `cacheTryAlloc` operation for `miniquake.memory` (cache try alloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheTryAlloc`. |
| `span` | `dynamic` | — | The span input consumed by `cacheTryAlloc`. |
| `noBottom` | `dynamic` | — | The no bottom input consumed by `cacheTryAlloc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L439)

<a id="function-function-miniquake-memory-cachetryallocblock-function-cachetryallocblock-state-span-nobottom-src-miniquake-memory-ml-1463697086"></a>
### cacheTryAllocBlock

```ml
function cacheTryAllocBlock(state, span, noBottom)
```

Cache_TryAlloc itself creates and links a cache header.  Cache_Alloc uses the lower-level position search because it must fill the user/name/payload fields atomically before exposing the new block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `cacheTryAllocBlock`. |
| `span` | `dynamic` | — | The span input consumed by `cacheTryAllocBlock`. |
| `noBottom` | `dynamic` | — | The no bottom input consumed by `cacheTryAllocBlock`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L467)

- [miniquake.memory.CacheUser](Type-miniquake-memory-cacheuser-951233691.md) — struct
<a id="function-function-miniquake-memory-create-function-create-capacity-src-miniquake-memory-ml-1233429105"></a>
### create

```ml
function create(capacity)
```

Implements the `create` operation for `miniquake.memory` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capacity` | `dynamic` | — | Maximum number of entries the destination can hold. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L123)

<a id="function-function-miniquake-memory-freehunkbytes-inline-function-freehunkbytes-state-src-miniquake-memory-ml-1532100675"></a>
### freeHunkBytes

```ml
inline function freeHunkBytes(state)
```

Release state for free hunk bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `freeHunkBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L167)

<a id="function-function-miniquake-memory-freetohighmark-function-freetohighmark-state-mark-src-miniquake-memory-ml-1990417005"></a>
### freeToHighMark

```ml
function freeToHighMark(state, mark)
```

Release state for free to high mark.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `freeToHighMark`. |
| `mark` | `dynamic` | — | The mark input consumed by `freeToHighMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L294)

<a id="function-function-miniquake-memory-freetolowmark-function-freetolowmark-state-mark-src-miniquake-memory-ml-1509292341"></a>
### freeToLowMark

```ml
function freeToLowMark(state, mark)
```

Release state for free to low mark.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `freeToLowMark`. |
| `mark` | `dynamic` | — | The mark input consumed by `freeToLowMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L279)

<a id="function-function-miniquake-memory-highmark-function-highmark-state-src-miniquake-memory-ml-2011768570"></a>
### highMark

```ml
function highMark(state)
```

Implements the `highMark` operation for `miniquake.memory` (high mark).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `highMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L206)

<a id="function-function-miniquake-memory-hunk-alloc-function-hunk-alloc-state-size-src-miniquake-memory-ml-471739193"></a>
### Hunk_Alloc

```ml
function Hunk_Alloc(state, size)
```

Mirror Quake's Hunk_Alloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_Alloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L834)

<a id="function-function-miniquake-memory-hunk-allocname-function-hunk-allocname-state-size-name-src-miniquake-memory-ml-992636896"></a>
### Hunk_AllocName

```ml
function Hunk_AllocName(state, size, name)
```

Mirror Quake's Hunk_AllocName routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_AllocName`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L827)

<a id="function-function-miniquake-memory-hunk-check-function-hunk-check-state-src-miniquake-memory-ml-824526634"></a>
### Hunk_Check

```ml
function Hunk_Check(state)
```

Explicit zone.c entry points. MemoryManager replaces the original global hunk/cache variables, while marks remain byte offsets as in MiniQuake.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_Check`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L812)

<a id="function-function-miniquake-memory-hunk-freetohighmark-function-hunk-freetohighmark-state-mark-src-miniquake-memory-ml-808291019"></a>
### Hunk_FreeToHighMark

```ml
function Hunk_FreeToHighMark(state, mark)
```

Mirror Quake's Hunk_FreeToHighMark routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_FreeToHighMark`. |
| `mark` | `dynamic` | — | The mark input consumed by `Hunk_FreeToHighMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L860)

<a id="function-function-miniquake-memory-hunk-freetolowmark-function-hunk-freetolowmark-state-mark-src-miniquake-memory-ml-1598897809"></a>
### Hunk_FreeToLowMark

```ml
function Hunk_FreeToLowMark(state, mark)
```

Mirror Quake's Hunk_FreeToLowMark routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_FreeToLowMark`. |
| `mark` | `dynamic` | — | The mark input consumed by `Hunk_FreeToLowMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L847)

<a id="constant-constant-miniquake-memory-hunk-header-size-const-hunk-header-size-16-src-miniquake-memory-ml-235479115"></a>
### HUNK_HEADER_SIZE

```ml
const HUNK_HEADER_SIZE = 16
```

Defines the hunk header size value used by `miniquake.memory`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L16)

<a id="function-function-miniquake-memory-hunk-highallocname-function-hunk-highallocname-state-size-name-src-miniquake-memory-ml-1134526460"></a>
### Hunk_HighAllocName

```ml
function Hunk_HighAllocName(state, size, name)
```

Mirror Quake's Hunk_HighAllocName routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_HighAllocName`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L868)

<a id="function-function-miniquake-memory-hunk-highmark-function-hunk-highmark-state-src-miniquake-memory-ml-1468791458"></a>
### Hunk_HighMark

```ml
function Hunk_HighMark(state)
```

Mirror Quake's Hunk_HighMark routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_HighMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L853)

<a id="function-function-miniquake-memory-hunk-lowmark-function-hunk-lowmark-state-src-miniquake-memory-ml-1679274098"></a>
### Hunk_LowMark

```ml
function Hunk_LowMark(state)
```

Mirror Quake's Hunk_LowMark routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_LowMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L840)

<a id="function-function-miniquake-memory-hunk-print-function-hunk-print-state-all-src-miniquake-memory-ml-211311753"></a>
### Hunk_Print

```ml
function Hunk_Print(state, all)
```

Mirror Quake's Hunk_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_Print`. |
| `all` | `dynamic` | — | The all input consumed by `Hunk_Print`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L819)

<a id="constant-constant-miniquake-memory-hunk-sentinel-const-hunk-sentinel-502268397-src-miniquake-memory-ml-1911644718"></a>
### HUNK_SENTINEL

```ml
const HUNK_SENTINEL = 502268397
```

Defines the hunk sentinel value used by `miniquake.memory`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L14)

<a id="function-function-miniquake-memory-hunk-tempalloc-function-hunk-tempalloc-state-size-src-miniquake-memory-ml-692492017"></a>
### Hunk_TempAlloc

```ml
function Hunk_TempAlloc(state, size)
```

Mirror Quake's Hunk_TempAlloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `Hunk_TempAlloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L875)

<a id="function-function-miniquake-memory-hunkalloc-function-hunkalloc-state-size-src-miniquake-memory-ml-1462978687"></a>
### hunkAlloc

```ml
function hunkAlloc(state, size)
```

Implements the `hunkAlloc` operation for `miniquake.memory` (hunk alloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkAlloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L232)

<a id="function-function-miniquake-memory-hunkallocname-function-hunkallocname-state-size-name-src-miniquake-memory-ml-743965644"></a>
### hunkAllocName

```ml
function hunkAllocName(state, size, name)
```

Return hunk alloc name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkAllocName`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L219)

- [miniquake.memory.HunkBlock](Type-miniquake-memory-hunkblock-1777378239.md) — struct
<a id="function-function-miniquake-memory-hunkcheck-function-hunkcheck-state-src-miniquake-memory-ml-1669810454"></a>
### hunkCheck

```ml
function hunkCheck(state)
```

Implements the `hunkCheck` operation for `miniquake.memory` (hunk check).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkCheck`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L313)

<a id="function-function-miniquake-memory-hunkhighallocname-function-hunkhighallocname-state-size-name-src-miniquake-memory-ml-477334404"></a>
### hunkHighAllocName

```ml
function hunkHighAllocName(state, size, name)
```

Return hunk high alloc name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkHighAllocName`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L240)

<a id="function-function-miniquake-memory-hunkpayloadused-function-hunkpayloadused-state-src-miniquake-memory-ml-1097463784"></a>
### hunkPayloadUsed

```ml
function hunkPayloadUsed(state)
```

Implements the `hunkPayloadUsed` operation for `miniquake.memory` (hunk payload used).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkPayloadUsed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L130)

<a id="function-function-miniquake-memory-hunkprint-function-hunkprint-state-all-src-miniquake-memory-ml-7762123"></a>
### hunkPrint

```ml
function hunkPrint(state, all)
```

Implements the `hunkPrint` operation for `miniquake.memory` (hunk print).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkPrint`. |
| `all` | `dynamic` | — | The all input consumed by `hunkPrint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L331)

<a id="function-function-miniquake-memory-hunktempalloc-function-hunktempalloc-state-size-name-src-miniquake-memory-ml-1187954290"></a>
### hunkTempAlloc

```ml
function hunkTempAlloc(state, size, name)
```

Implements the `hunkTempAlloc` operation for `miniquake.memory` (hunk temp alloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `hunkTempAlloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L259)

<a id="function-function-miniquake-memory-insertcachesorted-function-insertcachesorted-state-block-src-miniquake-memory-ml-1783713023"></a>
### insertCacheSorted

```ml
function insertCacheSorted(state, block)
```

Add state for insert cache sorted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `insertCacheSorted`. |
| `block` | `dynamic` | — | The block input consumed by `insertCacheSorted`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L409)

<a id="function-function-miniquake-memory-leastrecentlyused-function-leastrecentlyused-state-src-miniquake-memory-ml-1147703950"></a>
### leastRecentlyUsed

```ml
function leastRecentlyUsed(state)
```

Implements the `leastRecentlyUsed` operation for `miniquake.memory` (least recently used).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `leastRecentlyUsed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L520)

<a id="function-function-miniquake-memory-lowmark-function-lowmark-state-src-miniquake-memory-ml-471510028"></a>
### lowMark

```ml
function lowMark(state)
```

Implements the `lowMark` operation for `miniquake.memory` (low mark).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `lowMark`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L200)

<a id="function-function-miniquake-memory-makelru-function-makelru-block-src-miniquake-memory-ml-1010611872"></a>
### makeLru

```ml
function makeLru(block)
```

Create and initialize lru.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `makeLru`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L499)

<a id="function-function-miniquake-memory-memory-init-function-memory-init-capacity-zonesize-src-miniquake-memory-ml-266177956"></a>
### Memory_Init

```ml
function Memory_Init(capacity, zoneSize)
```

Mirror Quake's Memory_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capacity` | `dynamic` | — | Maximum number of entries the destination can hold. |
| `zoneSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L974)

<a id="function-function-miniquake-memory-memoryinit-function-memoryinit-capacity-zonesize-src-miniquake-memory-ml-1481033608"></a>
### memoryInit

```ml
function memoryInit(capacity, zoneSize)
```

Update subsystem state for memory init.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capacity` | `dynamic` | — | Maximum number of entries the destination can hold. |
| `zoneSize` | `dynamic` | — | Size of the requested data or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L772)

<a id="function-function-miniquake-memory-memoryinitarguments-function-memoryinitarguments-capacity-commandline-src-miniquake-memory-ml-522167462"></a>
### memoryInitArguments

```ml
function memoryInitArguments(capacity, commandLine)
```

Implements the `memoryInitArguments` operation for `miniquake.memory` (memory init arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capacity` | `dynamic` | — | Maximum number of entries the destination can hold. |
| `commandLine` | `dynamic` | — | The command line input consumed by `memoryInitArguments`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L785)

- [miniquake.memory.MemoryManager](Type-miniquake-memory-memorymanager-2931116.md) — struct
<a id="function-function-miniquake-memory-newcacheuser-function-newcacheuser-state-src-miniquake-memory-ml-1681562214"></a>
### newCacheUser

```ml
function newCacheUser(state)
```

Create and initialize cache user.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `newCacheUser`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L493)

<a id="function-function-miniquake-memory-newhunkblock-function-newhunkblock-state-requestedsize-name-kind-side-start-span-src-miniquake-memory-ml-785468381"></a>
### newHunkBlock

```ml
function newHunkBlock(state, requestedSize, name, kind, side, start, span)
```

Create and initialize hunk block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `newHunkBlock`. |
| `requestedSize` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `kind` | `dynamic` | — | The kind input consumed by `newHunkBlock`. |
| `side` | `dynamic` | — | The side input consumed by `newHunkBlock`. |
| `start` | `dynamic` | — | The start input consumed by `newHunkBlock`. |
| `span` | `dynamic` | — | The span input consumed by `newHunkBlock`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L179)

<a id="function-function-miniquake-memory-removecacheat-function-removecacheat-state-index-src-miniquake-memory-ml-914759110"></a>
### removeCacheAt

```ml
function removeCacheAt(state, index)
```

Release state for remove cache at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `removeCacheAt`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L426)

<a id="function-function-miniquake-memory-truncatename-function-truncatename-name-count-src-miniquake-memory-ml-292623987"></a>
### truncateName

```ml
function truncateName(name, count)
```

Return truncate name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L115)

<a id="function-function-miniquake-memory-unlinklru-function-unlinklru-block-src-miniquake-memory-ml-1066209374"></a>
### unlinkLru

```ml
function unlinkLru(block)
```

Implements the `unlinkLru` operation for `miniquake.memory` (unlink lru).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `unlinkLru`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L510)

<a id="function-function-miniquake-memory-used-function-used-state-src-miniquake-memory-ml-1730987018"></a>
### used

```ml
function used(state)
```

Implements the `used` operation for `miniquake.memory` (used).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `used`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L161)

<a id="function-function-miniquake-memory-zonecheck-function-zonecheck-state-src-miniquake-memory-ml-374259906"></a>
### zoneCheck

```ml
function zoneCheck(state)
```

Implements the `zoneCheck` operation for `miniquake.memory` (zone check).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zoneCheck`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L735)

<a id="function-function-miniquake-memory-zonedumpheap-function-zonedumpheap-state-src-miniquake-memory-ml-592442946"></a>
### zoneDumpHeap

```ml
function zoneDumpHeap(state)
```

Implements the `zoneDumpHeap` operation for `miniquake.memory` (zone dump heap).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zoneDumpHeap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L747)

<a id="function-function-miniquake-memory-zonefree-function-zonefree-block-src-miniquake-memory-ml-1470582838"></a>
### zoneFree

```ml
function zoneFree(block)
```

Implements the `zoneFree` operation for `miniquake.memory` (zone free).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `block` | `dynamic` | — | The block input consumed by `zoneFree`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L729)

<a id="function-function-miniquake-memory-zonefreememory-function-zonefreememory-state-src-miniquake-memory-ml-1977971334"></a>
### zoneFreeMemory

```ml
function zoneFreeMemory(state)
```

Implements the `zoneFreeMemory` operation for `miniquake.memory` (zone free memory).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zoneFreeMemory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L753)

<a id="function-function-miniquake-memory-zonemalloc-function-zonemalloc-state-size-name-src-miniquake-memory-ml-1182973292"></a>
### zoneMalloc

```ml
function zoneMalloc(state, size, name)
```

Implements the `zoneMalloc` operation for `miniquake.memory` (zone malloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zoneMalloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L720)

<a id="function-function-miniquake-memory-zonepayloadused-function-zonepayloadused-state-src-miniquake-memory-ml-1374916924"></a>
### zonePayloadUsed

```ml
function zonePayloadUsed(state)
```

Implements the `zonePayloadUsed` operation for `miniquake.memory` (zone payload used).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zonePayloadUsed`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L150)

<a id="function-function-miniquake-memory-zoneprint-function-zoneprint-state-src-miniquake-memory-ml-1442318140"></a>
### zonePrint

```ml
function zonePrint(state)
```

Implements the `zonePrint` operation for `miniquake.memory` (zone print).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zonePrint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L741)

<a id="function-function-miniquake-memory-zonestate-function-zonestate-state-src-miniquake-memory-ml-845616976"></a>
### zoneState

```ml
function zoneState(state)
```

Return zone state derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zoneState`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L698)

<a id="function-function-miniquake-memory-zonetagmalloc-function-zonetagmalloc-state-size-tag-name-src-miniquake-memory-ml-328542296"></a>
### zoneTagMalloc

```ml
function zoneTagMalloc(state, size, tag, name)
```

Implements the `zoneTagMalloc` operation for `miniquake.memory` (zone tag malloc).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable `miniquake.memory` state used by `zoneTagMalloc`. |
| `size` | `dynamic` | — | Size of the requested data or resource. |
| `tag` | `dynamic` | — | The tag input consumed by `zoneTagMalloc`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/memory.ml#L708)
