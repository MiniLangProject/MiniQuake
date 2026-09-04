# `src/miniquake/cvar.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.cvar`](Package-miniquake-cvar-955536269.md)

Reachable from entry: **yes**

## Imports

- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/ds/hashmap.ml` — external dependency

## Declarations

<a id="function-function-miniquake-cvar-archivetext-function-archivetext-registry-src-miniquake-cvar-ml-1593959622"></a>
### archiveText

```ml
function archiveText(registry)
```

Implements the `archiveText` operation for `miniquake.cvar` (archive text).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `archiveText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L180)

<a id="function-function-miniquake-cvar-command-function-command-registry-arguments-src-miniquake-cvar-ml-1311085598"></a>
### command

```ml
function command(registry, arguments)
```

Implements the `command` operation for `miniquake.cvar` (command).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `command`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L121)

<a id="function-function-miniquake-cvar-completevariable-function-completevariable-registry-partial-src-miniquake-cvar-ml-748760867"></a>
### completeVariable

```ml
function completeVariable(registry, partial)
```

Handle variable and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `completeVariable`. |
| `partial` | `dynamic` | — | The partial input consumed by `completeVariable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L153)

<a id="function-function-miniquake-cvar-create-function-create-name-stringvalue-archive-server-src-miniquake-cvar-ml-1824261249"></a>
### create

```ml
function create(name, stringValue, archive, server)
```

Implements the `create` operation for `miniquake.cvar` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `stringValue` | `dynamic` | — | The string value input consumed by `create`. |
| `archive` | `dynamic` | — | The archive input consumed by `create`. |
| `server` | `dynamic` | — | Server state participating in the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L36)

<a id="function-function-miniquake-cvar-createregistry-function-createregistry-src-miniquake-cvar-ml-252158513"></a>
### createRegistry

```ml
function createRegistry()
```

Create and initialize registry.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L24)

<a id="function-function-miniquake-cvar-cvar-command-function-cvar-command-registry-arguments-src-miniquake-cvar-ml-1257220920"></a>
### Cvar_Command

```ml
function Cvar_Command(registry, arguments)
```

Mirror Quake's Cvar_Command routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_Command`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L262)

<a id="function-function-miniquake-cvar-cvar-completevariable-function-cvar-completevariable-registry-partial-src-miniquake-cvar-ml-1540331419"></a>
### Cvar_CompleteVariable

```ml
function Cvar_CompleteVariable(registry, partial)
```

Mirror Quake's Cvar_CompleteVariable routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_CompleteVariable`. |
| `partial` | `dynamic` | — | The partial input consumed by `Cvar_CompleteVariable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L221)

<a id="function-function-miniquake-cvar-cvar-findvar-function-cvar-findvar-registry-varname-src-miniquake-cvar-ml-267263986"></a>
### Cvar_FindVar

```ml
function Cvar_FindVar(registry, varName)
```

--------------------------------------------------------------------------- WinQuake cvar.c source-surface adapters.

The C implementation stores its registry and current command arguments in
globals. MiniQuake keeps those contexts explicit, so the original exported
names are retained with the required context passed as parameters.
---------------------------------------------------------------------------

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_FindVar`. |
| `varName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L200)

<a id="function-function-miniquake-cvar-cvar-registervariable-function-cvar-registervariable-registry-variable-commandexists-src-miniquake-cvar-ml-1625975215"></a>
### Cvar_RegisterVariable

```ml
function Cvar_RegisterVariable(registry, variable, commandExists)
```

Mirror Quake's Cvar_RegisterVariable routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_RegisterVariable`. |
| `variable` | `dynamic` | — | The variable input consumed by `Cvar_RegisterVariable`. |
| `commandExists` | `dynamic` | — | The command exists input consumed by `Cvar_RegisterVariable`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L253)

<a id="function-function-miniquake-cvar-cvar-set-function-cvar-set-registry-varname-value-src-miniquake-cvar-ml-1471348213"></a>
### Cvar_Set

```ml
function Cvar_Set(registry, varName, value)
```

Mirror Quake's Cvar_Set routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_Set`. |
| `varName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `value` | `dynamic` | — | Value consumed by `Cvar_Set`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L229)

<a id="function-function-miniquake-cvar-cvar-setvalue-function-cvar-setvalue-registry-varname-value-src-miniquake-cvar-ml-549552421"></a>
### Cvar_SetValue

```ml
function Cvar_SetValue(registry, varName, value)
```

Mirror Quake's Cvar_SetValue routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_SetValue`. |
| `varName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `value` | `dynamic` | — | Value consumed by `Cvar_SetValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L243)

<a id="function-function-miniquake-cvar-cvar-variablestring-function-cvar-variablestring-registry-varname-src-miniquake-cvar-ml-430516770"></a>
### Cvar_VariableString

```ml
function Cvar_VariableString(registry, varName)
```

Mirror Quake's Cvar_VariableString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_VariableString`. |
| `varName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L214)

<a id="function-function-miniquake-cvar-cvar-variablevalue-function-cvar-variablevalue-registry-varname-src-miniquake-cvar-ml-1713758074"></a>
### Cvar_VariableValue

```ml
function Cvar_VariableValue(registry, varName)
```

Mirror Quake's Cvar_VariableValue routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_VariableValue`. |
| `varName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L207)

<a id="function-function-miniquake-cvar-cvar-writevariables-function-cvar-writevariables-registry-src-miniquake-cvar-ml-1034976286"></a>
### Cvar_WriteVariables

```ml
function Cvar_WriteVariables(registry)
```

Mirror Quake's Cvar_WriteVariables routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `Cvar_WriteVariables`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L268)

<a id="function-function-miniquake-cvar-find-function-find-registry-name-src-miniquake-cvar-ml-1850268881"></a>
### find

```ml
function find(registry, name)
```

Implements the `find` operation for `miniquake.cvar` (find).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `find`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L43)

<a id="function-function-miniquake-cvar-fixedsixvalue-function-fixedsixvalue-value-src-miniquake-cvar-ml-1741772606"></a>
### fixedSixValue

```ml
function fixedSixValue(value)
```

Return fixed six value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fixedSixValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L106)

<a id="function-function-miniquake-cvar-numericvalue-function-numericvalue-text-src-miniquake-cvar-ml-755417960"></a>
### numericValue

```ml
function numericValue(text)
```

Return numeric value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L17)

<a id="function-function-miniquake-cvar-quotevalue-function-quotevalue-text-src-miniquake-cvar-ml-2058276668"></a>
### quoteValue

```ml
function quoteValue(text)
```

Convert data for quote value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L173)

<a id="function-function-miniquake-cvar-register-function-register-registry-variable-commandexists-src-miniquake-cvar-ml-1012665315"></a>
### register

```ml
function register(registry, variable, commandExists)
```

Update subsystem configuration for register.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `register`. |
| `variable` | `dynamic` | — | The variable input consumed by `register`. |
| `commandExists` | `dynamic` | — | The command exists input consumed by `register`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L63)

<a id="function-function-miniquake-cvar-set-function-set-registry-name-stringvalue-src-miniquake-cvar-ml-1246140901"></a>
### set

```ml
function set(registry, name, stringValue)
```

Implements the `set` operation for `miniquake.cvar` (set).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `set`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `stringValue` | `dynamic` | — | The string value input consumed by `set`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L80)

<a id="function-function-miniquake-cvar-setvalue-function-setvalue-registry-name-value-src-miniquake-cvar-ml-543667784"></a>
### setValue

```ml
function setValue(registry, name, value)
```

Update module state for value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `setValue`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `setValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L114)

<a id="function-function-miniquake-cvar-takeserverchanges-function-takeserverchanges-registry-src-miniquake-cvar-ml-1171890370"></a>
### takeServerChanges

```ml
function takeServerChanges(registry)
```

Consume pending state for take server changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `takeServerChanges`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L94)

<a id="function-function-miniquake-cvar-variablestring-function-variablestring-registry-name-src-miniquake-cvar-ml-659247825"></a>
### variableString

```ml
function variableString(registry, name)
```

Implements the `variableString` operation for `miniquake.cvar` (variable string).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `variableString`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L144)

<a id="function-function-miniquake-cvar-variablevalue-function-variablevalue-registry-name-src-miniquake-cvar-ml-650808931"></a>
### variableValue

```ml
function variableValue(registry, name)
```

Return variable value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `registry` | `dynamic` | — | The registry input consumed by `variableValue`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cvar.ml#L135)
