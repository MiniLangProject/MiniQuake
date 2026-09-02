# `src/miniquake/edict.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.edict`](Package-miniquake-edict-1318618138.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/mathlib.ml` as `math` → [src/miniquake/mathlib.ml](File-src-miniquake-mathlib-ml-2131866431.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-edict-allocate-function-allocate-edicts-currenttime-src-miniquake-edict-ml-1744884249"></a>
### allocate

```ml
function allocate(edicts, currentTime)
```

Implements the `allocate` operation for `miniquake.edict` (allocate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edicts` | `dynamic` | — | The edicts input consumed by `allocate`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L225)

<a id="function-function-miniquake-edict-baseline-function-baseline-item-src-miniquake-edict-ml-1293701734"></a>
### baseline

```ml
function baseline(item)
```

Implements the `baseline` operation for `miniquake.edict` (baseline).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `baseline`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L257)

<a id="function-function-miniquake-edict-buildbaselines-function-buildbaselines-edicts-src-miniquake-edict-ml-822417173"></a>
### buildBaselines

```ml
function buildBaselines(edicts)
```

Create and initialize baselines.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edicts` | `dynamic` | — | The edicts input consumed by `buildBaselines`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L275)

<a id="function-function-miniquake-edict-copypairs-function-copypairs-entity-src-miniquake-edict-ml-31798750"></a>
### copyPairs

```ml
function copyPairs(entity)
```

Transfer data for copy pairs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L121)

<a id="function-function-miniquake-edict-create-function-create-number-src-miniquake-edict-ml-441241488"></a>
### create

```ml
function create(number)
```

Implements the `create` operation for `miniquake.edict` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `number` | `dynamic` | — | The number input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L31)

<a id="function-function-miniquake-edict-emptybaseline-function-emptybaseline-src-miniquake-edict-ml-1757860073"></a>
### emptyBaseline

```ml
function emptyBaseline()
```

Implements the `emptyBaseline` operation for `miniquake.edict` (empty baseline).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L18)

<a id="function-function-miniquake-edict-findclass-function-findclass-edicts-classname-src-miniquake-edict-ml-1573556092"></a>
### findClass

```ml
function findClass(edicts, className)
```

Return class.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edicts` | `dynamic` | — | The edicts input consumed by `findClass`. |
| `className` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L190)

<a id="function-function-miniquake-edict-findfirstclass-function-findfirstclass-edicts-classname-src-miniquake-edict-ml-1031034798"></a>
### findFirstClass

```ml
function findFirstClass(edicts, className)
```

Return first class.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edicts` | `dynamic` | — | The edicts input consumed by `findFirstClass`. |
| `className` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L202)

<a id="function-function-miniquake-edict-free-function-free-item-currenttime-src-miniquake-edict-ml-2066470112"></a>
### free

```ml
function free(item, currentTime)
```

Implements the `free` operation for `miniquake.edict` (free).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `item` | `dynamic` | — | The item input consumed by `free`. |
| `currentTime` | `dynamic` | — | Time value used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L244)

<a id="function-function-miniquake-edict-fromentity-function-fromentity-number-entity-src-miniquake-edict-ml-558937887"></a>
### fromEntity

```ml
function fromEntity(number, entity)
```

Implements the `fromEntity` operation for `miniquake.edict` (from entity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `number` | `dynamic` | — | The number input consumed by `fromEntity`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L135)

<a id="function-function-miniquake-edict-getpair-function-getpair-edict-key-src-miniquake-edict-ml-509833627"></a>
### getPair

```ml
function getPair(edict, key)
```

Return pair.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edict` | `dynamic` | — | QuakeC edict affected by the operation. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L112)

<a id="function-function-miniquake-edict-loadmapentities-function-loadmapentities-map-src-miniquake-edict-ml-619802433"></a>
### loadMapEntities

```ml
function loadMapEntities(map)
```

Read and validate map entities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map` | `dynamic` | — | The map input consumed by `loadMapEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L171)

<a id="function-function-miniquake-edict-numbervalue-function-numbervalue-text-fallback-src-miniquake-edict-ml-1543892648"></a>
### numberValue

```ml
function numberValue(text, fallback)
```

Return number value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L90)

<a id="function-function-miniquake-edict-setpair-function-setpair-edict-key-newvalue-src-miniquake-edict-ml-1676926276"></a>
### setPair

```ml
function setPair(edict, key, newValue)
```

Update module state for pair.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edict` | `dynamic` | — | QuakeC edict affected by the operation. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `newValue` | `dynamic` | — | The new value input consumed by `setPair`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L101)

<a id="function-function-miniquake-edict-spawnpoint-function-spawnpoint-edicts-deathmatch-src-miniquake-edict-ml-1649089610"></a>
### spawnPoint

```ml
function spawnPoint(edicts, deathmatch)
```

Allocate and initialize point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `edicts` | `dynamic` | — | The edicts input consumed by `spawnPoint`. |
| `deathmatch` | `dynamic` | — | The deathmatch input consumed by `spawnPoint`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L213)

<a id="function-function-miniquake-edict-value-function-value-entity-key-src-miniquake-edict-ml-815506645"></a>
### value

```ml
function value(entity, key)
```

Return value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entity` | `dynamic` | — | Entity affected by the operation. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/edict.ml#L83)
