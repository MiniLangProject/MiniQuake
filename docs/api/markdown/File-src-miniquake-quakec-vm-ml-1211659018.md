# `src/miniquake/quakec/vm.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.quakec.vm`](Package-miniquake-quakec-vm-869173468.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `protocolText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/quakec/opcodes.ml` as `op` → [src/miniquake/quakec/opcodes.ml](File-src-miniquake-quakec-opcodes-ml-1466187268.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-quakec-vm-callbuiltin-function-callbuiltin-machine-builtinindex-src-miniquake-quakec-vm-ml-450916630"></a>
### callBuiltin

```ml
function callBuiltin(machine, builtinIndex)
```

Implements the `callBuiltin` operation for `miniquake.quakec.vm` (call builtin).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `callBuiltin`. |
| `builtinIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L460)

<a id="function-function-miniquake-quakec-vm-calldepth-function-calldepth-machine-src-miniquake-quakec-vm-ml-1799505799"></a>
### callDepth

```ml
function callDepth(machine)
```

Resolve the active PR_ExecuteProgram depth for diagnostics without exposing the fixed-stack representation to compatibility fixtures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `callDepth`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1016)

<a id="function-function-miniquake-quakec-vm-canonicalstring-function-canonicalstring-text-src-miniquake-quakec-vm-ml-1785701073"></a>
### canonicalString

```ml
function canonicalString(text)
```

Report whether canonical string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L207)

<a id="function-function-miniquake-quakec-vm-clearentity-function-clearentity-machine-entityindex-src-miniquake-quakec-vm-ml-1271010178"></a>
### clearEntity

```ml
function clearEntity(machine, entityIndex)
```

Update module state for entity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `clearEntity`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1161)

<a id="function-function-miniquake-quakec-vm-copyprogramwords-function-copyprogramwords-source-src-miniquake-quakec-vm-ml-1469208805"></a>
### copyProgramWords

```ml
function copyProgramWords(source)
```

Transfer data for copy program words.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L104)

<a id="function-function-miniquake-quakec-vm-create-function-create-program-maxedicts-src-miniquake-quakec-vm-ml-394831438"></a>
### create

```ml
function create(program, maxEdicts)
```

Implements the `create` operation for `miniquake.quakec.vm` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | The program input consumed by `create`. |
| `maxEdicts` | `dynamic` | — | The max edicts input consumed by `create`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L111)

<a id="function-function-miniquake-quakec-vm-debugceil-function-debugceil-value-src-miniquake-quakec-vm-ml-1644767741"></a>
### debugCeil

```ml
function debugCeil(value)
```

Implements the `debugCeil` operation for `miniquake.quakec.vm` (debug ceil).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `debugCeil`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L496)

<a id="function-function-miniquake-quakec-vm-debugfloor-function-debugfloor-value-src-miniquake-quakec-vm-ml-1032402157"></a>
### debugFloor

```ml
function debugFloor(value)
```

Implements the `debugFloor` operation for `miniquake.quakec.vm` (debug floor).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `debugFloor`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L488)

<a id="function-function-miniquake-quakec-vm-debugglobalstring-function-debugglobalstring-machine-offset-includecontents-src-miniquake-quakec-vm-ml-1500492742"></a>
### debugGlobalString

```ml
function debugGlobalString(machine, offset, includeContents)
```

Implements the `debugGlobalString` operation for `miniquake.quakec.vm` (debug global string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `debugGlobalString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `includeContents` | `dynamic` | — | The include contents input consumed by `debugGlobalString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L559)

<a id="function-function-miniquake-quakec-vm-debugonedecimal-function-debugonedecimal-value-src-miniquake-quakec-vm-ml-269495497"></a>
### debugOneDecimal

```ml
function debugOneDecimal(value)
```

Implements the `debugOneDecimal` operation for `miniquake.quakec.vm` (debug one decimal).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `debugOneDecimal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L504)

<a id="function-function-miniquake-quakec-vm-debugvaluestring-function-debugvaluestring-machine-definition-offset-src-miniquake-quakec-vm-ml-1145965503"></a>
### debugValueString

```ml
function debugValueString(machine, definition, offset)
```

Implements the `debugValueString` operation for `miniquake.quakec.vm` (debug value string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `debugValueString`. |
| `definition` | `dynamic` | — | The definition input consumed by `debugValueString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L531)

<a id="function-function-miniquake-quakec-vm-definitionatoffset-function-definitionatoffset-definitions-offset-src-miniquake-quakec-vm-ml-351984193"></a>
### definitionAtOffset

```ml
function definitionAtOffset(definitions, offset)
```

Return definition at offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definitions` | `dynamic` | — | The definitions input consumed by `definitionAtOffset`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L520)

<a id="function-function-miniquake-quakec-vm-definitionoffset-function-definitionoffset-definitions-name-src-miniquake-quakec-vm-ml-199963021"></a>
### definitionOffset

```ml
function definitionOffset(definitions, name)
```

Return definition offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `definitions` | `dynamic` | — | The definitions input consumed by `definitionOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L734)

<a id="function-function-miniquake-quakec-vm-ensureglobal-function-ensureglobal-machine-offset-src-miniquake-quakec-vm-ml-1427923058"></a>
### ensureGlobal

```ml
function ensureGlobal(machine, offset)
```

Ensure sufficient storage or state for global.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ensureGlobal`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L134)

<a id="function-function-miniquake-quakec-vm-ensurelookupmachine-function-ensurelookupmachine-machine-src-miniquake-quakec-vm-ml-1385841423"></a>
### ensureLookupMachine

```ml
function ensureLookupMachine(machine)
```

Ensure sufficient storage or state for lookup machine.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ensureLookupMachine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L53)

<a id="function-function-miniquake-quakec-vm-ensureprogramstringcache-function-ensureprogramstringcache-machine-src-miniquake-quakec-vm-ml-389507417"></a>
### ensureProgramStringCache

```ml
function ensureProgramStringCache(machine)
```

Ensure immutable progs.dat strings have one decoded value per byte offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `ensureProgramStringCache`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L75)

<a id="function-function-miniquake-quakec-vm-enterfunction-function-enterfunction-machine-functionindex-src-miniquake-quakec-vm-ml-257285891"></a>
### enterFunction

```ml
function enterFunction(machine, functionIndex)
```

Implements the `enterFunction` operation for `miniquake.quakec.vm` (enter function).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `enterFunction`. |
| `functionIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L388)

<a id="function-function-miniquake-quakec-vm-entityfield-function-entityfield-machine-entityindex-fieldoffset-src-miniquake-quakec-vm-ml-1478075079"></a>
### entityField

```ml
function entityField(machine, entityIndex, fieldOffset)
```

Implements the `entityField` operation for `miniquake.quakec.vm` (entity field).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityField`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L270)

<a id="function-function-miniquake-quakec-vm-entityfloat-function-entityfloat-machine-entityindex-fieldoffsetvalue-src-miniquake-quakec-vm-ml-1877596728"></a>
### entityFloat

```ml
function entityFloat(machine, entityIndex, fieldOffsetValue)
```

Implements the `entityFloat` operation for `miniquake.quakec.vm` (entity float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityFloat`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffsetValue` | `dynamic` | — | The field offset value input consumed by `entityFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1104)

<a id="function-function-miniquake-quakec-vm-entitystring-function-entitystring-machine-entityindex-fieldoffsetvalue-src-miniquake-quakec-vm-ml-380788546"></a>
### entityString

```ml
function entityString(machine, entityIndex, fieldOffsetValue)
```

Implements the `entityString` operation for `miniquake.quakec.vm` (entity string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityString`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffsetValue` | `dynamic` | — | The field offset value input consumed by `entityString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1145)

<a id="function-function-miniquake-quakec-vm-entityvector-function-entityvector-machine-entityindex-fieldoffsetvalue-src-miniquake-quakec-vm-ml-129792314"></a>
### entityVector

```ml
function entityVector(machine, entityIndex, fieldOffsetValue)
```

Implements the `entityVector` operation for `miniquake.quakec.vm` (entity vector).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `entityVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffsetValue` | `dynamic` | — | The field offset value input consumed by `entityVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1121)

<a id="function-function-miniquake-quakec-vm-execute-function-execute-machine-functionindex-src-miniquake-quakec-vm-ml-42048545"></a>
### execute

```ml
function execute(machine, functionIndex)
```

Execute the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `execute`. |
| `functionIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L795)

<a id="function-function-miniquake-quakec-vm-executestate-function-executestate-machine-frameoffset-thinkoffset-src-miniquake-quakec-vm-ml-79981268"></a>
### executeState

```ml
function executeState(machine, frameOffset, thinkOffset)
```

Execute state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `executeState`. |
| `frameOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `thinkOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L772)

<a id="function-function-miniquake-quakec-vm-fastenterfunction-function-fastenterfunction-machine-functionindex-src-miniquake-quakec-vm-ml-1413956375"></a>
### fastEnterFunction

```ml
function fastEnterFunction(machine, functionIndex)
```

Enter a QuakeC function using the original fixed execution and locals stacks. Sources are saved before parameters overwrite a callee's locals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `fastEnterFunction`. |
| `functionIndex` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L349)

<a id="global-global-miniquake-quakec-vm-fieldlookupkeys-fieldlookupkeys-src-miniquake-quakec-vm-ml-1787579408"></a>
### fieldLookupKeys

```ml
fieldLookupKeys
```

Tracks the module-level field lookup keys state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L29)

<a id="global-global-miniquake-quakec-vm-fieldlookuprawkeys-fieldlookuprawkeys-src-miniquake-quakec-vm-ml-172914320"></a>
### fieldLookupRawKeys

```ml
fieldLookupRawKeys
```

Tracks the module-level field lookup raw keys state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L31)

<a id="global-global-miniquake-quakec-vm-fieldlookupvalues-fieldlookupvalues-src-miniquake-quakec-vm-ml-291680728"></a>
### fieldLookupValues

```ml
fieldLookupValues
```

Tracks the module-level field lookup values state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L33)

<a id="function-function-miniquake-quakec-vm-fieldoffset-function-fieldoffset-machine-name-src-miniquake-quakec-vm-ml-1142942132"></a>
### fieldOffset

```ml
function fieldOffset(machine, name)
```

Implements the `fieldOffset` operation for `miniquake.quakec.vm` (field offset).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `fieldOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1032)

<a id="function-function-miniquake-quakec-vm-floattruth-inline-function-floattruth-value-src-miniquake-quakec-vm-ml-836161026"></a>
### floatTruth

```ml
inline function floatTruth(value)
```

Implements the `floatTruth` operation for `miniquake.quakec.vm` (float truth).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `floatTruth`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L710)

<a id="function-function-miniquake-quakec-vm-functionindex-function-functionindex-machine-name-src-miniquake-quakec-vm-ml-611565002"></a>
### functionIndex

```ml
function functionIndex(machine, name)
```

Return function index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `functionIndex`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1078)

<a id="global-global-miniquake-quakec-vm-functionlookupkeys-functionlookupkeys-src-miniquake-quakec-vm-ml-1908953700"></a>
### functionLookupKeys

```ml
functionLookupKeys
```

Tracks the module-level function lookup keys state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L41)

<a id="global-global-miniquake-quakec-vm-functionlookuprawkeys-functionlookuprawkeys-src-miniquake-quakec-vm-ml-1679516400"></a>
### functionLookupRawKeys

```ml
functionLookupRawKeys
```

Tracks the module-level function lookup raw keys state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L43)

<a id="global-global-miniquake-quakec-vm-functionlookupvalues-functionlookupvalues-src-miniquake-quakec-vm-ml-1300601776"></a>
### functionLookupValues

```ml
functionLookupValues
```

Tracks the module-level function lookup values state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L45)

<a id="function-function-miniquake-quakec-vm-globalfloat-function-globalfloat-machine-offset-src-miniquake-quakec-vm-ml-804893744"></a>
### globalFloat

```ml
function globalFloat(machine, offset)
```

Implements the `globalFloat` operation for `miniquake.quakec.vm` (global float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalFloat`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L162)

<a id="global-global-miniquake-quakec-vm-globallookupkeys-globallookupkeys-src-miniquake-quakec-vm-ml-1849839414"></a>
### globalLookupKeys

```ml
globalLookupKeys
```

Tracks the module-level global lookup keys state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L35)

<a id="global-global-miniquake-quakec-vm-globallookuprawkeys-globallookuprawkeys-src-miniquake-quakec-vm-ml-165602672"></a>
### globalLookupRawKeys

```ml
globalLookupRawKeys
```

Tracks the module-level global lookup raw keys state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L37)

<a id="global-global-miniquake-quakec-vm-globallookupvalues-globallookupvalues-src-miniquake-quakec-vm-ml-1845592926"></a>
### globalLookupValues

```ml
globalLookupValues
```

Tracks the module-level global lookup values state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L39)

<a id="function-function-miniquake-quakec-vm-globaloffset-function-globaloffset-machine-name-src-miniquake-quakec-vm-ml-1355989962"></a>
### globalOffset

```ml
function globalOffset(machine, name)
```

Return global offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `globalOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1055)

<a id="function-function-miniquake-quakec-vm-internstring-function-internstring-machine-text-src-miniquake-quakec-vm-ml-1167294378"></a>
### internString

```ml
function internString(machine, text)
```

Implements the `internString` operation for `miniquake.quakec.vm` (intern string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `internString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L222)

<a id="function-function-miniquake-quakec-vm-leavefunction-function-leavefunction-machine-src-miniquake-quakec-vm-ml-1741271083"></a>
### leaveFunction

```ml
function leaveFunction(machine)
```

Implements the `leaveFunction` operation for `miniquake.quakec.vm` (leave function).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `leaveFunction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L425)

<a id="constant-constant-miniquake-quakec-vm-localstack-size-const-localstack-size-2048-src-miniquake-quakec-vm-ml-1132322111"></a>
### LOCALSTACK_SIZE

```ml
const LOCALSTACK_SIZE = 2048
```

Defines the localstack size value used by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L20)

<a id="constant-constant-miniquake-quakec-vm-lookup-cache-size-const-lookup-cache-size-512-src-miniquake-quakec-vm-ml-880383545"></a>
### LOOKUP_CACHE_SIZE

```ml
const LOOKUP_CACHE_SIZE = 512
```

Defines the lookup cache size value used by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L24)

<a id="global-global-miniquake-quakec-vm-lookupmachine-lookupmachine-src-miniquake-quakec-vm-ml-1982386328"></a>
### lookupMachine

```ml
lookupMachine
```

Tracks the module-level lookup machine state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L27)

<a id="function-function-miniquake-quakec-vm-lookupslot-inline-function-lookupslot-key-src-miniquake-quakec-vm-ml-793447778"></a>
### lookupSlot

```ml
inline function lookupSlot(key)
```

Return slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — | Key used to identify the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L92)

<a id="constant-constant-miniquake-quakec-vm-max-stack-depth-const-max-stack-depth-32-src-miniquake-quakec-vm-ml-1017502482"></a>
### MAX_STACK_DEPTH

```ml
const MAX_STACK_DEPTH = 32
```

Defines the max stack depth value used by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L18)

<a id="function-function-miniquake-quakec-vm-namedfieldoffset-function-namedfieldoffset-machine-name-src-miniquake-quakec-vm-ml-1815743982"></a>
### namedFieldOffset

```ml
function namedFieldOffset(machine, name)
```

Return named field offset derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `namedFieldOffset`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L764)

<a id="function-function-miniquake-quakec-vm-namedglobalfloat-function-namedglobalfloat-machine-name-src-miniquake-quakec-vm-ml-77430854"></a>
### namedGlobalFloat

```ml
function namedGlobalFloat(machine, name)
```

Implements the `namedGlobalFloat` operation for `miniquake.quakec.vm` (named global float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `namedGlobalFloat`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L755)

<a id="function-function-miniquake-quakec-vm-namedglobalword-function-namedglobalword-machine-name-src-miniquake-quakec-vm-ml-917426218"></a>
### namedGlobalWord

```ml
function namedGlobalWord(machine, name)
```

Implements the `namedGlobalWord` operation for `miniquake.quakec.vm` (named global word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `namedGlobalWord`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L746)

<a id="function-function-miniquake-quakec-vm-opcodename-function-opcodename-code-src-miniquake-quakec-vm-ml-97525681"></a>
### opcodeName

```ml
function opcodeName(code)
```

Return opcode name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | The code input consumed by `opcodeName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L468)

<a id="function-function-miniquake-quakec-vm-pointerentity-function-pointerentity-machine-pointer-src-miniquake-quakec-vm-ml-1421242878"></a>
### pointerEntity

```ml
function pointerEntity(machine, pointer)
```

Implements the `pointerEntity` operation for `miniquake.quakec.vm` (pointer entity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `pointerEntity`. |
| `pointer` | `dynamic` | — | The pointer input consumed by `pointerEntity`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L291)

<a id="function-function-miniquake-quakec-vm-pointerfield-function-pointerfield-machine-pointer-src-miniquake-quakec-vm-ml-2026087470"></a>
### pointerField

```ml
function pointerField(machine, pointer)
```

Implements the `pointerField` operation for `miniquake.quakec.vm` (pointer field).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `pointerField`. |
| `pointer` | `dynamic` | — | The pointer input consumed by `pointerField`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L299)

<a id="function-function-miniquake-quakec-vm-poparray-function-poparray-values-src-miniquake-quakec-vm-ml-402532870"></a>
### popArray

```ml
function popArray(values)
```

Consume pending state for pop array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | The values input consumed by `popArray`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L418)

<a id="function-function-miniquake-quakec-vm-pr-enterfunction-function-pr-enterfunction-machine-functionindexvalue-src-miniquake-quakec-vm-ml-184287340"></a>
### PR_EnterFunction

```ml
function PR_EnterFunction(machine, functionIndexValue)
```

Mirror Quake's PR_EnterFunction routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_EnterFunction`. |
| `functionIndexValue` | `dynamic` | — | The function index value input consumed by `PR_EnterFunction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1208)

<a id="function-function-miniquake-quakec-vm-pr-executeprogram-function-pr-executeprogram-machine-functionindexvalue-src-miniquake-quakec-vm-ml-1584964548"></a>
### PR_ExecuteProgram

```ml
function PR_ExecuteProgram(machine, functionIndexValue)
```

Mirror Quake's PR_ExecuteProgram routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_ExecuteProgram`. |
| `functionIndexValue` | `dynamic` | — | The function index value input consumed by `PR_ExecuteProgram`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1221)

<a id="function-function-miniquake-quakec-vm-pr-leavefunction-function-pr-leavefunction-machine-src-miniquake-quakec-vm-ml-405521545"></a>
### PR_LeaveFunction

```ml
function PR_LeaveFunction(machine)
```

Mirror Quake's PR_LeaveFunction routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_LeaveFunction`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1214)

<a id="function-function-miniquake-quakec-vm-pr-printstatement-function-pr-printstatement-machine-statementvalue-src-miniquake-quakec-vm-ml-237286177"></a>
### PR_PrintStatement

```ml
function PR_PrintStatement(machine, statementValue)
```

Names matching the MiniQuake entry points keep the source-to-port mapping explicit while the lower-camel functions remain the idiomatic MiniLang API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_PrintStatement`. |
| `statementValue` | `dynamic` | — | The statement value input consumed by `PR_PrintStatement`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1182)

<a id="function-function-miniquake-quakec-vm-pr-profile-f-function-pr-profile-f-machine-src-miniquake-quakec-vm-ml-235499977"></a>
### PR_Profile_f

```ml
function PR_Profile_f(machine)
```

Mirror Quake's PR_Profile_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_Profile_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1194)

<a id="function-function-miniquake-quakec-vm-pr-runerror-function-pr-runerror-machine-message-src-miniquake-quakec-vm-ml-1647219012"></a>
### PR_RunError

```ml
function PR_RunError(machine, message)
```

Mirror Quake's PR_RunError routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_RunError`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1201)

<a id="function-function-miniquake-quakec-vm-pr-stacktrace-function-pr-stacktrace-machine-src-miniquake-quakec-vm-ml-358233289"></a>
### PR_StackTrace

```ml
function PR_StackTrace(machine)
```

Mirror Quake's PR_StackTrace routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `PR_StackTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1188)

<a id="function-function-miniquake-quakec-vm-printstatement-function-printstatement-machine-statementvalue-src-miniquake-quakec-vm-ml-1247984943"></a>
### printStatement

```ml
function printStatement(machine, statementValue)
```

Format and emit statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `printStatement`. |
| `statementValue` | `dynamic` | — | The statement value input consumed by `printStatement`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L577)

<a id="function-function-miniquake-quakec-vm-profilereport-function-profilereport-machine-src-miniquake-quakec-vm-ml-734994963"></a>
### profileReport

```ml
function profileReport(machine)
```

Implements the `profileReport` operation for `miniquake.quakec.vm` (profile report).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `profileReport`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L661)

<a id="global-global-miniquake-quakec-vm-programstringcache-programstringcache-src-miniquake-quakec-vm-ml-2050722106"></a>
### programStringCache

```ml
programStringCache
```

Tracks the module-level program string cache state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L49)

<a id="global-global-miniquake-quakec-vm-programstringcachemachine-programstringcachemachine-src-miniquake-quakec-vm-ml-138469648"></a>
### programStringCacheMachine

```ml
programStringCacheMachine
```

Tracks the module-level program string cache machine state owned by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L47)

<a id="function-function-miniquake-quakec-vm-randomfloat-function-randomfloat-machine-src-miniquake-quakec-vm-ml-384053679"></a>
### randomFloat

```ml
function randomFloat(machine)
```

Implements the `randomFloat` operation for `miniquake.quakec.vm` (random float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `randomFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1173)

<a id="function-function-miniquake-quakec-vm-returnfloat-function-returnfloat-machine-src-miniquake-quakec-vm-ml-1428404021"></a>
### returnFloat

```ml
function returnFloat(machine)
```

Implements the `returnFloat` operation for `miniquake.quakec.vm` (return float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `returnFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L179)

<a id="function-function-miniquake-quakec-vm-runerror-function-runerror-machine-message-src-miniquake-quakec-vm-ml-1517137080"></a>
### runError

```ml
function runError(machine, message)
```

Execute error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `runError`. |
| `message` | `dynamic` | — | Diagnostic message that explains a failure or event. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L688)

<a id="function-function-miniquake-quakec-vm-savedlocalcount-function-savedlocalcount-machine-src-miniquake-quakec-vm-ml-1616005131"></a>
### savedLocalCount

```ml
function savedLocalCount(machine)
```

Encode and write d local count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `savedLocalCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L336)

<a id="function-function-miniquake-quakec-vm-savelocals-function-savelocals-machine-functionvalue-src-miniquake-quakec-vm-ml-851807606"></a>
### saveLocals

```ml
function saveLocals(machine, functionValue)
```

Encode and write locals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `saveLocals`. |
| `functionValue` | `dynamic` | — | The function value input consumed by `saveLocals`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L324)

<a id="function-function-miniquake-quakec-vm-setcontext-function-setcontext-machine-context-src-miniquake-quakec-vm-ml-1707760696"></a>
### setContext

```ml
function setContext(machine, context)
```

Update module state for context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setContext`. |
| `context` | `dynamic` | — | The context input consumed by `setContext`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1024)

<a id="function-function-miniquake-quakec-vm-setentityfield-function-setentityfield-machine-entityindex-fieldoffset-value-src-miniquake-quakec-vm-ml-1851568502"></a>
### setEntityField

```ml
function setEntityField(machine, entityIndex, fieldOffset, value)
```

Update module state for entity field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityField`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setEntityField`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L282)

<a id="function-function-miniquake-quakec-vm-setentityfloat-function-setentityfloat-machine-entityindex-fieldoffsetvalue-value-src-miniquake-quakec-vm-ml-1921491875"></a>
### setEntityFloat

```ml
function setEntityFloat(machine, entityIndex, fieldOffsetValue, value)
```

Sets entity float for `miniquake.quakec.vm`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityFloat`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffsetValue` | `dynamic` | — | The field offset value input consumed by `setEntityFloat`. |
| `value` | `dynamic` | — | Value consumed by `setEntityFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1113)

<a id="function-function-miniquake-quakec-vm-setentitystring-function-setentitystring-machine-entityindex-fieldoffsetvalue-text-src-miniquake-quakec-vm-ml-1748527729"></a>
### setEntityString

```ml
function setEntityString(machine, entityIndex, fieldOffsetValue, text)
```

Update module state for entity string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityString`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffsetValue` | `dynamic` | — | The field offset value input consumed by `setEntityString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1154)

<a id="function-function-miniquake-quakec-vm-setentityvector-function-setentityvector-machine-entityindex-fieldoffsetvalue-value-src-miniquake-quakec-vm-ml-1975376847"></a>
### setEntityVector

```ml
function setEntityVector(machine, entityIndex, fieldOffsetValue, value)
```

Sets entity vector for `miniquake.quakec.vm`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setEntityVector`. |
| `entityIndex` | `dynamic` | — | Zero-based index of the requested entry. |
| `fieldOffsetValue` | `dynamic` | — | The field offset value input consumed by `setEntityVector`. |
| `value` | `dynamic` | — | Value consumed by `setEntityVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L1134)

<a id="function-function-miniquake-quakec-vm-setglobalfloat-function-setglobalfloat-machine-offset-value-src-miniquake-quakec-vm-ml-563862967"></a>
### setGlobalFloat

```ml
function setGlobalFloat(machine, offset, value)
```

Update module state for global float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setGlobalFloat`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setGlobalFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L170)

<a id="function-function-miniquake-quakec-vm-setglobalstring-function-setglobalstring-machine-offset-text-src-miniquake-quakec-vm-ml-1142217557"></a>
### setGlobalString

```ml
function setGlobalString(machine, offset, text)
```

Update module state for global string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setGlobalString`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L245)

<a id="function-function-miniquake-quakec-vm-settemporarystring-function-settemporarystring-machine-text-src-miniquake-quakec-vm-ml-736592882"></a>
### setTemporaryString

```ml
function setTemporaryString(machine, text)
```

Update module state for temporary string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setTemporaryString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L236)

<a id="function-function-miniquake-quakec-vm-setvector-function-setvector-machine-offset-value-src-miniquake-quakec-vm-ml-1423981397"></a>
### setVector

```ml
function setVector(machine, offset, value)
```

Update module state for vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setVector`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L260)

<a id="function-function-miniquake-quakec-vm-setword-function-setword-machine-offset-value-src-miniquake-quakec-vm-ml-474386211"></a>
### setWord

```ml
function setWord(machine, offset, value)
```

Update module state for word.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `setWord`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `value` | `dynamic` | — | Value consumed by `setWord`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L153)

<a id="function-function-miniquake-quakec-vm-stackline-function-stackline-functionvalue-src-miniquake-quakec-vm-ml-1770465013"></a>
### stackLine

```ml
function stackLine(functionValue)
```

Implements the `stackLine` operation for `miniquake.quakec.vm` (stack line).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `functionValue` | `dynamic` | — | The function value input consumed by `stackLine`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L604)

<a id="function-function-miniquake-quakec-vm-stacktrace-function-stacktrace-machine-src-miniquake-quakec-vm-ml-1011309057"></a>
### stackTrace

```ml
function stackTrace(machine)
```

Implements the `stackTrace` operation for `miniquake.quakec.vm` (stack trace).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `stackTrace`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L614)

<a id="function-function-miniquake-quakec-vm-stringat-function-stringat-machine-globaloffset-src-miniquake-quakec-vm-ml-1368928189"></a>
### stringAt

```ml
function stringAt(machine, globalOffset)
```

Implements the `stringAt` operation for `miniquake.quakec.vm` (string at).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `stringAt`. |
| `globalOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L215)

<a id="function-function-miniquake-quakec-vm-stringcompare-function-stringcompare-left-right-src-miniquake-quakec-vm-ml-1399212405"></a>
### stringCompare

```ml
function stringCompare(left, right)
```

Implements the `stringCompare` operation for `miniquake.quakec.vm` (string compare).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | The left input consumed by `stringCompare`. |
| `right` | `dynamic` | — | The right input consumed by `stringCompare`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L717)

<a id="function-function-miniquake-quakec-vm-stringvalue-function-stringvalue-machine-rawvalue-src-miniquake-quakec-vm-ml-562895594"></a>
### stringValue

```ml
function stringValue(machine, rawValue)
```

Return string value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `stringValue`. |
| `rawValue` | `dynamic` | — | The raw value input consumed by `stringValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L186)

<a id="constant-constant-miniquake-quakec-vm-temp-string-handle-const-temp-string-handle-4294967295-src-miniquake-quakec-vm-ml-1060122364"></a>
### TEMP_STRING_HANDLE

```ml
const TEMP_STRING_HANDLE = 4294967295
```

Defines the temp string handle value used by `miniquake.quakec.vm`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L22)

<a id="function-function-miniquake-quakec-vm-validatepointer-function-validatepointer-machine-pointer-wordcount-src-miniquake-quakec-vm-ml-861965831"></a>
### validatePointer

```ml
function validatePointer(machine, pointer, wordCount)
```

Validate pointer and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `validatePointer`. |
| `pointer` | `dynamic` | — | The pointer input consumed by `validatePointer`. |
| `wordCount` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L308)

<a id="function-function-miniquake-quakec-vm-vector-function-vector-machine-offset-src-miniquake-quakec-vm-ml-1440010550"></a>
### vector

```ml
function vector(machine, offset)
```

Return vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `vector`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L252)

<a id="function-function-miniquake-quakec-vm-word-function-word-machine-offset-src-miniquake-quakec-vm-ml-313284510"></a>
### word

```ml
function word(machine, offset)
```

Implements the `word` operation for `miniquake.quakec.vm` (word).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `machine` | `dynamic` | — | The machine input consumed by `word`. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L144)

<a id="function-function-miniquake-quakec-vm-zeroarray-function-zeroarray-count-src-miniquake-quakec-vm-ml-2048713521"></a>
### zeroArray

```ml
function zeroArray(count)
```

Create the zero-initialized state for array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/quakec/vm.ml#L98)
