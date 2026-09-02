# `src/miniquake/quakec/edict.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.quakec.edict`](Package-miniquake-quakec-edict-550346160.md)

Reachable from entry: **yes**

## Imports

- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/quakec/vm.ml` as `vm` → [src/miniquake/quakec/vm.ml](File-src-miniquake-quakec-vm-ml-1211659018.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-quakec-edict-allocate-function-allocate-machine-firstindex-src-miniquake-quakec-edict-ml-1491853155"></a>
### allocate

```ml
function allocate(machine, firstIndex)
```

Implements the `allocate` operation for `miniquake.quakec.edict` (allocate).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `allocate`. |
| `firstIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L22)

<a id="function-function-miniquake-quakec-edict-appendquotedpair-function-appendquotedpair-prefix-name-value-src-miniquake-quakec-edict-ml-862856086"></a>
### appendQuotedPair

```ml
function appendQuotedPair(prefix, name, value)
```

Add state for append quoted pair.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — | The prefix input consumed by `appendQuotedPair`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `appendQuotedPair`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L587)

<a id="function-function-miniquake-quakec-edict-baseline-function-baseline-machine-entityindex-src-miniquake-quakec-edict-ml-1756417644"></a>
### baseline

```ml
function baseline(machine, entityIndex)
```

Implements the `baseline` operation for `miniquake.quakec.edict` (baseline).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `baseline`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L393)

<a id="function-function-miniquake-quakec-edict-classname-function-classname-machine-entityindex-src-miniquake-quakec-edict-ml-1698326022"></a>
### className

```ml
function className(machine, entityIndex)
```

Return class name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `className`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L302)

<a id="function-function-miniquake-quakec-edict-countedicts-function-countedicts-machine-src-miniquake-quakec-edict-ml-620278719"></a>
### countEdicts

```ml
function countEdicts(machine)
```

Return count edicts for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `countEdicts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L810)

<a id="function-function-miniquake-quakec-edict-definitionatoffset-function-definitionatoffset-definitions-offset-src-miniquake-quakec-edict-ml-1398164989"></a>
### definitionAtOffset

```ml
function definitionAtOffset(definitions, offset)
```

Return definition at offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definitions` | `dynamic` | — | The definitions input consumed by `definitionAtOffset`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L427)

<a id="function-function-miniquake-quakec-edict-definitionserializedlength-function-definitionserializedlength-machine-words-definition-src-miniquake-quakec-edict-ml-236370391"></a>
### definitionSerializedLength

```ml
function definitionSerializedLength(machine, words, definition)
```

Return definition serialized length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `definitionSerializedLength`. |
| `words` | `dynamic` | — | The words input consumed by `definitionSerializedLength`. |
| `definition` | `dynamic` | — | The definition input consumed by `definitionSerializedLength`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L700)

<a id="function-function-miniquake-quakec-edict-definitionshouldserialize-function-definitionshouldserialize-words-definition-globalsonly-src-miniquake-quakec-edict-ml-345154864"></a>
### definitionShouldSerialize

```ml
function definitionShouldSerialize(words, definition, globalsOnly)
```

Implements the `definitionShouldSerialize` operation for `miniquake.quakec.edict` (definition should serialize).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | The words input consumed by `definitionShouldSerialize`. |
| `definition` | `dynamic` | — | The definition input consumed by `definitionShouldSerialize`. |
| `globalsOnly` | `dynamic` | — | The globals only input consumed by `definitionShouldSerialize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L671)

<a id="function-function-miniquake-quakec-edict-diagnostic-function-diagnostic-machine-text-src-miniquake-quakec-edict-ml-1983440280"></a>
### diagnostic

```ml
function diagnostic(machine, text)
```

Implements the `diagnostic` operation for `miniquake.quakec.edict` (diagnostic).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `diagnostic`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L205)

<a id="function-function-miniquake-quakec-edict-displayvectorstring-function-displayvectorstring-words-offset-src-miniquake-quakec-edict-ml-1513519048"></a>
### displayVectorString

```ml
function displayVectorString(words, offset)
```

Implements the `displayVectorString` operation for `miniquake.quakec.edict` (display vector string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | The words input consumed by `displayVectorString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L518)

<a id="function-function-miniquake-quakec-edict-ed-alloc-function-ed-alloc-machine-firstindex-src-miniquake-quakec-edict-ml-381476087"></a>
### ED_Alloc

```ml
function ED_Alloc(machine, firstIndex)
```

Mirror Quake's ED_Alloc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_Alloc`. |
| `firstIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L865)

<a id="function-function-miniquake-quakec-edict-ed-clearedict-function-ed-clearedict-machine-entityindex-src-miniquake-quakec-edict-ml-113717564"></a>
### ED_ClearEdict

```ml
function ED_ClearEdict(machine, entityIndex)
```

Explicit MiniQuake entry-point names provide a one-to-one code-location map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_ClearEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L856)

<a id="function-function-miniquake-quakec-edict-ed-count-function-ed-count-machine-src-miniquake-quakec-edict-ml-928292965"></a>
### ED_Count

```ml
function ED_Count(machine)
```

Mirror Quake's ED_Count routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_Count`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1015)

<a id="function-function-miniquake-quakec-edict-ed-fieldatofs-function-ed-fieldatofs-machine-offset-src-miniquake-quakec-edict-ml-1173485098"></a>
### ED_FieldAtOfs

```ml
function ED_FieldAtOfs(machine, offset)
```

Mirror Quake's ED_FieldAtOfs routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_FieldAtOfs`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L886)

<a id="function-function-miniquake-quakec-edict-ed-findfield-function-ed-findfield-machine-name-src-miniquake-quakec-edict-ml-115467524"></a>
### ED_FindField

```ml
function ED_FindField(machine, name)
```

Mirror Quake's ED_FindField routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_FindField`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L893)

<a id="function-function-miniquake-quakec-edict-ed-findfunction-function-ed-findfunction-machine-name-src-miniquake-quakec-edict-ml-1088161254"></a>
### ED_FindFunction

```ml
function ED_FindFunction(machine, name)
```

Mirror Quake's ED_FindFunction routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_FindFunction`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L907)

<a id="function-function-miniquake-quakec-edict-ed-findglobal-function-ed-findglobal-machine-name-src-miniquake-quakec-edict-ml-422499244"></a>
### ED_FindGlobal

```ml
function ED_FindGlobal(machine, name)
```

Mirror Quake's ED_FindGlobal routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_FindGlobal`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L900)

<a id="function-function-miniquake-quakec-edict-ed-free-function-ed-free-machine-entityindex-src-miniquake-quakec-edict-ml-373396936"></a>
### ED_Free

```ml
function ED_Free(machine, entityIndex)
```

Mirror Quake's ED_Free routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_Free`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L872)

<a id="function-function-miniquake-quakec-edict-ed-globalatofs-function-ed-globalatofs-machine-offset-src-miniquake-quakec-edict-ml-1094652736"></a>
### ED_GlobalAtOfs

```ml
function ED_GlobalAtOfs(machine, offset)
```

Mirror Quake's ED_GlobalAtOfs routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_GlobalAtOfs`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L879)

<a id="function-function-miniquake-quakec-edict-ed-loadfromfile-function-ed-loadfromfile-machine-map-skill-deathmatch-firstdynamicindex-src-miniquake-quakec-edict-ml-1118607724"></a>
### ED_LoadFromFile

```ml
function ED_LoadFromFile(machine, map, skill, deathmatch, firstDynamicIndex)
```

Mirror Quake's ED_LoadFromFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_LoadFromFile`. |
| `map` | `dynamic` | — | The map input consumed by `ED_LoadFromFile`. |
| `skill` | `dynamic` | — | The skill input consumed by `ED_LoadFromFile`. |
| `deathmatch` | `dynamic` | — | The deathmatch input consumed by `ED_LoadFromFile`. |
| `firstDynamicIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1068)

<a id="function-function-miniquake-quakec-edict-ed-newstring-function-ed-newstring-text-src-miniquake-quakec-edict-ml-1960887103"></a>
### ED_NewString

```ml
function ED_NewString(text)
```

Mirror Quake's ED_NewString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1039)

<a id="function-function-miniquake-quakec-edict-ed-parseedict-function-ed-parseedict-machine-entityindex-entity-src-miniquake-quakec-edict-ml-2027307365"></a>
### ED_ParseEdict

```ml
function ED_ParseEdict(machine, entityIndex, entity)
```

Mirror Quake's ED_ParseEdict routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_ParseEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1058)

<a id="function-function-miniquake-quakec-edict-ed-parseepair-function-ed-parseepair-machine-entityindex-definition-value-globalbase-src-miniquake-quakec-edict-ml-1563273128"></a>
### ED_ParseEpair

```ml
function ED_ParseEpair(machine, entityIndex, definition, value, globalBase)
```

Mirror Quake's ED_ParseEpair routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_ParseEpair`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `definition` | `dynamic` | — | The definition input consumed by `ED_ParseEpair`. |
| `value` | `dynamic` | — | Value consumed by `ED_ParseEpair`. |
| `globalBase` | `dynamic` | — | The global base input consumed by `ED_ParseEpair`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1049)

<a id="function-function-miniquake-quakec-edict-ed-parseglobals-function-ed-parseglobals-machine-entity-src-miniquake-quakec-edict-ml-628208478"></a>
### ED_ParseGlobals

```ml
function ED_ParseGlobals(machine, entity)
```

Mirror Quake's ED_ParseGlobals routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_ParseGlobals`. |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1028)

<a id="function-function-miniquake-quakec-edict-ed-print-function-ed-print-machine-entityindex-src-miniquake-quakec-edict-ml-956965160"></a>
### ED_Print

```ml
function ED_Print(machine, entityIndex)
```

Mirror Quake's ED_Print routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_Print`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L972)

<a id="function-function-miniquake-quakec-edict-ed-printedict-f-function-ed-printedict-f-machine-entityindex-src-miniquake-quakec-edict-ml-1918856138"></a>
### ED_PrintEdict_f

```ml
function ED_PrintEdict_f(machine, entityIndex)
```

Mirror Quake's ED_PrintEdict_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_PrintEdict_f`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1006)

<a id="function-function-miniquake-quakec-edict-ed-printedicts-function-ed-printedicts-machine-src-miniquake-quakec-edict-ml-1518121513"></a>
### ED_PrintEdicts

```ml
function ED_PrintEdicts(machine)
```

Mirror Quake's ED_PrintEdicts routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_PrintEdicts`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L992)

<a id="function-function-miniquake-quakec-edict-ed-printnum-function-ed-printnum-machine-entityindex-src-miniquake-quakec-edict-ml-2081119166"></a>
### ED_PrintNum

```ml
function ED_PrintNum(machine, entityIndex)
```

Mirror Quake's ED_PrintNum routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_PrintNum`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L986)

<a id="function-function-miniquake-quakec-edict-ed-write-function-ed-write-machine-entityindex-src-miniquake-quakec-edict-ml-1295052124"></a>
### ED_Write

```ml
function ED_Write(machine, entityIndex)
```

Mirror Quake's ED_Write routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_Write`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L979)

<a id="function-function-miniquake-quakec-edict-ed-writeglobals-function-ed-writeglobals-machine-src-miniquake-quakec-edict-ml-190225655"></a>
### ED_WriteGlobals

```ml
function ED_WriteGlobals(machine)
```

Mirror Quake's ED_WriteGlobals routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ED_WriteGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1021)

<a id="function-function-miniquake-quakec-edict-edict-num-function-edict-num-machine-entityindex-src-miniquake-quakec-edict-ml-1626361960"></a>
### EDICT_NUM

```ml
function EDICT_NUM(machine, entityIndex)
```

Mirror Quake's EDICT_NUM routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `EDICT_NUM`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1092)

<a id="function-function-miniquake-quakec-edict-edictceil-function-edictceil-value-src-miniquake-quakec-edict-ml-1425723281"></a>
### edictCeil

```ml
function edictCeil(value)
```

Implements the `edictCeil` operation for `miniquake.quakec.edict` (edict ceil).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `edictCeil`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L465)

<a id="function-function-miniquake-quakec-edict-edictfloor-function-edictfloor-value-src-miniquake-quakec-edict-ml-1533014537"></a>
### edictFloor

```ml
function edictFloor(value)
```

Implements the `edictFloor` operation for `miniquake.quakec.edict` (edict floor).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `edictFloor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L457)

<a id="function-function-miniquake-quakec-edict-fielddefinition-function-fielddefinition-machine-name-src-miniquake-quakec-edict-ml-126331694"></a>
### fieldDefinition

```ml
function fieldDefinition(machine, name)
```

Implements the `fieldDefinition` operation for `miniquake.quakec.edict` (field definition).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `fieldDefinition`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L92)

<a id="function-function-miniquake-quakec-edict-fixedonedecimal-function-fixedonedecimal-value-src-miniquake-quakec-edict-ml-92090851"></a>
### fixedOneDecimal

```ml
function fixedOneDecimal(value)
```

Implements the `fixedOneDecimal` operation for `miniquake.quakec.edict` (fixed one decimal).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fixedOneDecimal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L473)

<a id="function-function-miniquake-quakec-edict-fixedsixdecimals-function-fixedsixdecimals-value-src-miniquake-quakec-edict-ml-94277185"></a>
### fixedSixDecimals

```ml
function fixedSixDecimals(value)
```

Implements the `fixedSixDecimals` operation for `miniquake.quakec.edict` (fixed six decimals).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fixedSixDecimals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L499)

<a id="function-function-miniquake-quakec-edict-fixedsixdecimalsword-function-fixedsixdecimalsword-rawword-src-miniquake-quakec-edict-ml-2009460796"></a>
### fixedSixDecimalsWord

```ml
function fixedSixDecimalsWord(rawWord)
```

Implements the `fixedSixDecimalsWord` operation for `miniquake.quakec.edict` (fixed six decimals word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rawWord` | `dynamic` | — | The raw word input consumed by `fixedSixDecimalsWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L493)

<a id="function-function-miniquake-quakec-edict-free-function-free-machine-entityindex-src-miniquake-quakec-edict-ml-1450008700"></a>
### free

```ml
function free(machine, entityIndex)
```

Implements the `free` operation for `miniquake.quakec.edict` (free).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `free`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L64)

<a id="function-function-miniquake-quakec-edict-getedictfieldvalue-function-getedictfieldvalue-machine-entityindex-name-src-miniquake-quakec-edict-ml-667627653"></a>
### GetEdictFieldValue

```ml
function GetEdictFieldValue(machine, entityIndex, name)
```

Return edict field value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `GetEdictFieldValue`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L915)

<a id="function-function-miniquake-quakec-edict-globaldefinition-function-globaldefinition-machine-name-src-miniquake-quakec-edict-ml-862037900"></a>
### globalDefinition

```ml
function globalDefinition(machine, name)
```

Implements the `globalDefinition` operation for `miniquake.quakec.edict` (global definition).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalDefinition`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L102)

<a id="function-function-miniquake-quakec-edict-initializeglobals-function-initializeglobals-machine-mapname-skill-deathmatch-coop-serverflags-src-miniquake-quakec-edict-ml-1124886657"></a>
### initializeGlobals

```ml
function initializeGlobals(machine, mapName, skill, deathmatch, coop, serverFlags)
```

Initialize state for initialize globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `initializeGlobals`. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |
| `skill` | `dynamic` | — | The skill input consumed by `initializeGlobals`. |
| `deathmatch` | `dynamic` | — | The deathmatch input consumed by `initializeGlobals`. |
| `coop` | `dynamic` | — | The coop input consumed by `initializeGlobals`. |
| `serverFlags` | `dynamic` | — | The server flags input consumed by `initializeGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L378)

<a id="function-function-miniquake-quakec-edict-initializeworldentity-function-initializeworldentity-machine-map-src-miniquake-quakec-edict-ml-1016319955"></a>
### initializeWorldEntity

```ml
function initializeWorldEntity(machine, map)
```

SV_SpawnServer initializes the world edict before ED_LoadFromFile.  The entity text then contributes keys such as message/sounds/worldtype while the engine-owned model, bounds and collision fields stay authoritative.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `initializeWorldEntity`. |
| `map` | `dynamic` | — | The map input consumed by `initializeWorldEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L260)

<a id="function-function-miniquake-quakec-edict-loadmapentities-function-loadmapentities-machine-map-skill-deathmatch-src-miniquake-quakec-edict-ml-753145703"></a>
### loadMapEntities

```ml
function loadMapEntities(machine, map, skill, deathmatch)
```

Read and validate map entities.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `loadMapEntities`. |
| `map` | `dynamic` | — | The map input consumed by `loadMapEntities`. |
| `skill` | `dynamic` | — | The skill input consumed by `loadMapEntities`. |
| `deathmatch` | `dynamic` | — | The deathmatch input consumed by `loadMapEntities`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L367)

<a id="function-function-miniquake-quakec-edict-loadmapentitiesfrom-function-loadmapentitiesfrom-machine-map-skill-deathmatch-firstdynamicindex-src-miniquake-quakec-edict-ml-72048922"></a>
### loadMapEntitiesFrom

```ml
function loadMapEntitiesFrom(machine, map, skill, deathmatch, firstDynamicIndex)
```

Read and validate map entities from.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `loadMapEntitiesFrom`. |
| `map` | `dynamic` | — | The map input consumed by `loadMapEntitiesFrom`. |
| `skill` | `dynamic` | — | The skill input consumed by `loadMapEntitiesFrom`. |
| `deathmatch` | `dynamic` | — | The deathmatch input consumed by `loadMapEntitiesFrom`. |
| `firstDynamicIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L314)

<a id="function-function-miniquake-quakec-edict-newstring-function-newstring-text-src-miniquake-quakec-edict-ml-1560676917"></a>
### newString

```ml
function newString(text)
```

Create and initialize string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L835)

<a id="function-function-miniquake-quakec-edict-num-for-edict-function-num-for-edict-machine-entityindex-src-miniquake-quakec-edict-ml-193146864"></a>
### NUM_FOR_EDICT

```ml
function NUM_FOR_EDICT(machine, entityIndex)
```

Mirror Quake's NUM_FOR_EDICT routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `NUM_FOR_EDICT`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1100)

<a id="function-function-miniquake-quakec-edict-parseentity-function-parseentity-machine-entityindex-entity-src-miniquake-quakec-edict-ml-460858289"></a>
### parseEntity

```ml
function parseEntity(machine, entityIndex, entity)
```

Read and validate entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `parseEntity`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `entity` | `dynamic` | — | Entity affected by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L214)

<a id="function-function-miniquake-quakec-edict-pr-globalstring-function-pr-globalstring-machine-offset-src-miniquake-quakec-edict-ml-737160450"></a>
### PR_GlobalString

```ml
function PR_GlobalString(machine, offset)
```

Mirror Quake's PR_GlobalString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_GlobalString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L942)

<a id="function-function-miniquake-quakec-edict-pr-globalstringnocontents-function-pr-globalstringnocontents-machine-offset-src-miniquake-quakec-edict-ml-485189352"></a>
### PR_GlobalStringNoContents

```ml
function PR_GlobalStringNoContents(machine, offset)
```

Mirror Quake's PR_GlobalStringNoContents routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_GlobalStringNoContents`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L959)

<a id="function-function-miniquake-quakec-edict-pr-init-function-pr-init-src-miniquake-quakec-edict-ml-1152015084"></a>
### PR_Init

```ml
function PR_Init()
```

Mirror Quake's PR_Init routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1085)

<a id="function-function-miniquake-quakec-edict-pr-loadprogs-function-pr-loadprogs-data-filename-src-miniquake-quakec-edict-ml-660433817"></a>
### PR_LoadProgs

```ml
function PR_LoadProgs(data, filename)
```

Mirror Quake's PR_LoadProgs routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L1075)

<a id="function-function-miniquake-quakec-edict-pr-uglyvaluestring-function-pr-uglyvaluestring-machine-valuetype-words-offset-src-miniquake-quakec-edict-ml-536767126"></a>
### PR_UglyValueString

```ml
function PR_UglyValueString(machine, valueType, words, offset)
```

Mirror Quake's PR_UglyValueString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_UglyValueString`. |
| `valueType` | `dynamic` | — | The value type input consumed by `PR_UglyValueString`. |
| `words` | `dynamic` | — | The words input consumed by `PR_UglyValueString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L935)

<a id="function-function-miniquake-quakec-edict-pr-valuestring-function-pr-valuestring-machine-valuetype-words-offset-src-miniquake-quakec-edict-ml-1971149858"></a>
### PR_ValueString

```ml
function PR_ValueString(machine, valueType, words, offset)
```

Mirror Quake's PR_ValueString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_ValueString`. |
| `valueType` | `dynamic` | — | The value type input consumed by `PR_ValueString`. |
| `words` | `dynamic` | — | The words input consumed by `PR_ValueString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L926)

<a id="function-function-miniquake-quakec-edict-printedict-function-printedict-machine-entityindex-src-miniquake-quakec-edict-ml-1637430908"></a>
### printEdict

```ml
function printEdict(machine, entityIndex)
```

Format and emit edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `printEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L642)

<a id="function-function-miniquake-quakec-edict-quotedpairline-function-quotedpairline-name-value-src-miniquake-quakec-edict-ml-1409829358"></a>
### quotedPairLine

```ml
function quotedPairLine(name, value)
```

Implements the `quotedPairLine` operation for `miniquake.quakec.edict` (quoted pair line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `quotedPairLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L635)

<a id="function-function-miniquake-quakec-edict-serializedefinitions-function-serializedefinitions-machine-words-definitions-firstindex-globalsonly-src-miniquake-quakec-edict-ml-1957677530"></a>
### serializeDefinitions

```ml
function serializeDefinitions(machine, words, definitions, firstIndex, globalsOnly)
```

Encode and write definitions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `serializeDefinitions`. |
| `words` | `dynamic` | — | The words input consumed by `serializeDefinitions`. |
| `definitions` | `dynamic` | — | The definitions input consumed by `serializeDefinitions`. |
| `firstIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `globalsOnly` | `dynamic` | — | The globals only input consumed by `serializeDefinitions`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L755)

<a id="function-function-miniquake-quakec-edict-setglobalbyname-function-setglobalbyname-machine-name-value-src-miniquake-quakec-edict-ml-1300173597"></a>
### setGlobalByName

```ml
function setGlobalByName(machine, name, value)
```

Update module state for global by name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setGlobalByName`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setGlobalByName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L113)

<a id="function-function-miniquake-quakec-edict-setkeyvalue-function-setkeyvalue-machine-entityindex-key-value-src-miniquake-quakec-edict-ml-656586444"></a>
### setKeyValue

```ml
function setKeyValue(machine, entityIndex, key, value)
```

Update module state for key value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setKeyValue`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `key` | `dynamic` | — | Key used to identify the requested entry. |
| `value` | `dynamic` | — | Value consumed by `setKeyValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L160)

<a id="function-function-miniquake-quakec-edict-setworldfloat-function-setworldfloat-machine-name-value-src-miniquake-quakec-edict-ml-1297130167"></a>
### setWorldFloat

```ml
function setWorldFloat(machine, name, value)
```

Update module state for world float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setWorldFloat`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setWorldFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L241)

<a id="function-function-miniquake-quakec-edict-setworldstring-function-setworldstring-machine-name-value-src-miniquake-quakec-edict-ml-515755671"></a>
### setWorldString

```ml
function setWorldString(machine, name, value)
```

Update module state for world string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setWorldString`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setWorldString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L250)

<a id="function-function-miniquake-quakec-edict-setworldvector-function-setworldvector-machine-name-value-src-miniquake-quakec-edict-ml-730724623"></a>
### setWorldVector

```ml
function setWorldVector(machine, name, value)
```

Update module state for world vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setWorldVector`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setWorldVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L232)

<a id="function-function-miniquake-quakec-edict-shouldinhibit-function-shouldinhibit-machine-entityindex-skill-deathmatch-src-miniquake-quakec-edict-ml-2059332666"></a>
### shouldInhibit

```ml
function shouldInhibit(machine, entityIndex, skill, deathmatch)
```

Report whether should inhibit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `shouldInhibit`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `skill` | `dynamic` | — | The skill input consumed by `shouldInhibit`. |
| `deathmatch` | `dynamic` | — | The deathmatch input consumed by `shouldInhibit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L287)

<a id="function-function-miniquake-quakec-edict-trimtrailingspaces-function-trimtrailingspaces-text-src-miniquake-quakec-edict-ml-745515507"></a>
### trimTrailingSpaces

```ml
function trimTrailingSpaces(text)
```

Implements the `trimTrailingSpaces` operation for `miniquake.quakec.edict` (trim trailing spaces).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L145)

<a id="function-function-miniquake-quakec-edict-typesize-function-typesize-valuetype-src-miniquake-quakec-edict-ml-444255917"></a>
### typeSize

```ml
function typeSize(valueType)
```

Implements the `typeSize` operation for `miniquake.quakec.edict` (type size).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `valueType` | `dynamic` | — | The value type input consumed by `typeSize`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L417)

<a id="function-function-miniquake-quakec-edict-uglyvectorstring-function-uglyvectorstring-words-offset-src-miniquake-quakec-edict-ml-1563472060"></a>
### uglyVectorString

```ml
function uglyVectorString(words, offset)
```

Implements the `uglyVectorString` operation for `miniquake.quakec.edict` (ugly vector string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | The words input consumed by `uglyVectorString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L506)

<a id="function-function-miniquake-quakec-edict-valuestring-function-valuestring-machine-valuetype-words-offset-ugly-src-miniquake-quakec-edict-ml-587155031"></a>
### valueString

```ml
function valueString(machine, valueType, words, offset, ugly)
```

Implements the `valueString` operation for `miniquake.quakec.edict` (value string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `valueString`. |
| `valueType` | `dynamic` | — | The value type input consumed by `valueString`. |
| `words` | `dynamic` | — | The words input consumed by `valueString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `ugly` | `dynamic` | — | The ugly input consumed by `valueString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L543)

<a id="function-function-miniquake-quakec-edict-vectorcomponentdefinition-function-vectorcomponentdefinition-name-src-miniquake-quakec-edict-ml-1387128369"></a>
### vectorComponentDefinition

```ml
function vectorComponentDefinition(name)
```

Implements the `vectorComponentDefinition` operation for `miniquake.quakec.edict` (vector component definition).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L436)

<a id="function-function-miniquake-quakec-edict-voidvaluestring-function-voidvaluestring-src-miniquake-quakec-edict-ml-2117140914"></a>
### voidValueString

```ml
function voidValueString()
```

Implements the `voidValueString` operation for `miniquake.quakec.edict` (void value string).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L530)

<a id="function-function-miniquake-quakec-edict-wordsarezero-function-wordsarezero-words-offset-count-src-miniquake-quakec-edict-ml-2021173169"></a>
### wordsAreZero

```ml
function wordsAreZero(words, offset, count)
```

Implements the `wordsAreZero` operation for `miniquake.quakec.edict` (words are zero).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | The words input consumed by `wordsAreZero`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L446)

<a id="function-function-miniquake-quakec-edict-writedefinitionbytes-function-writedefinitionbytes-machine-words-definition-output-cursor-src-miniquake-quakec-edict-ml-117937274"></a>
### writeDefinitionBytes

```ml
function writeDefinitionBytes(machine, words, definition, output, cursor)
```

Encode and write definition bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeDefinitionBytes`. |
| `words` | `dynamic` | — | The words input consumed by `writeDefinitionBytes`. |
| `definition` | `dynamic` | — | The definition input consumed by `writeDefinitionBytes`. |
| `output` | `dynamic` | — | Destination buffer that receives the serialized definition. |
| `cursor` | `dynamic` | — | The cursor input consumed by `writeDefinitionBytes`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L719)

<a id="function-function-miniquake-quakec-edict-writeedict-function-writeedict-machine-entityindex-src-miniquake-quakec-edict-ml-1089829860"></a>
### writeEdict

```ml
function writeEdict(machine, entityIndex)
```

Encode and write edict.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeEdict`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L796)

<a id="function-function-miniquake-quakec-edict-writeglobals-function-writeglobals-machine-src-miniquake-quakec-edict-ml-69943273"></a>
### writeGlobals

```ml
function writeGlobals(machine)
```

Encode and write globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `writeGlobals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/edict.ml#L804)
