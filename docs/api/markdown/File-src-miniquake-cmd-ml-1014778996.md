# `src/miniquake/cmd.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.cmd`](Package-miniquake-cmd-1243415301.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/message.ml` as `msg` → [src/miniquake/message.ml](File-src-miniquake-message-ml-238261765.md)
- `miniquake/sizebuf.ml` as `sz` → [src/miniquake/sizebuf.ml](File-src-miniquake-sizebuf-ml-252484438.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-cmd-addalias-function-addalias-system-name-value-src-miniquake-cmd-ml-759250106"></a>
### addAlias

```ml
function addAlias(system, name, value)
```

Add state for add alias.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `addAlias`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `value` | `dynamic` | — | Value consumed by `addAlias`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L64)

<a id="function-function-miniquake-cmd-addcommand-function-addcommand-system-name-callback-src-miniquake-cmd-ml-241830638"></a>
### addCommand

```ml
function addCommand(system, name, callback)
```

Add state for add command.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `addCommand`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `callback` | `dynamic` | — | The callback input consumed by `addCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L32)

<a id="function-function-miniquake-cmd-addtext-function-addtext-system-text-src-miniquake-cmd-ml-546303369"></a>
### addText

```ml
function addText(system, text)
```

Add state for add text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `addText`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L228)

<a id="function-function-miniquake-cmd-argc-function-argc-system-src-miniquake-cmd-ml-768254974"></a>
### argc

```ml
function argc(system)
```

Return the number of tokenized command arguments.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `argc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L162)

<a id="function-function-miniquake-cmd-argsfrom-function-argsfrom-system-first-src-miniquake-cmd-ml-180952356"></a>
### argsFrom

```ml
function argsFrom(system, first)
```

Implements the `argsFrom` operation for `miniquake.cmd` (args from).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `argsFrom`. |
| `first` | `dynamic` | — | The first input consumed by `argsFrom`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L177)

<a id="function-function-miniquake-cmd-argv-function-argv-system-index-src-miniquake-cmd-ml-1031674146"></a>
### argv

```ml
function argv(system, index)
```

Return one tokenized command argument by index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `argv`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L169)

<a id="function-function-miniquake-cmd-cbuf-addtext-function-cbuf-addtext-system-text-src-miniquake-cmd-ml-455225005"></a>
### Cbuf_AddText

```ml
function Cbuf_AddText(system, text)
```

Mirror Quake's Cbuf_AddText routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cbuf_AddText`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L351)

<a id="function-function-miniquake-cmd-cbuf-execute-function-cbuf-execute-system-src-miniquake-cmd-ml-893968530"></a>
### Cbuf_Execute

```ml
function Cbuf_Execute(system)
```

Mirror Quake's Cbuf_Execute routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cbuf_Execute`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L364)

<a id="function-function-miniquake-cmd-cbuf-init-function-cbuf-init-src-miniquake-cmd-ml-2008418509"></a>
### Cbuf_Init

```ml
function Cbuf_Init()
```

Mirror Quake's Cbuf_Init routine and its observable state changes.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L344)

<a id="function-function-miniquake-cmd-cbuf-inserttext-function-cbuf-inserttext-system-text-src-miniquake-cmd-ml-721225735"></a>
### Cbuf_InsertText

```ml
function Cbuf_InsertText(system, text)
```

Mirror Quake's Cbuf_InsertText routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cbuf_InsertText`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L358)

<a id="function-function-miniquake-cmd-checkparm-function-checkparm-system-name-src-miniquake-cmd-ml-925703853"></a>
### checkParm

```ml
function checkParm(system, name)
```

Validate parm and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `checkParm`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L191)

<a id="function-function-miniquake-cmd-cmd-addcommand-function-cmd-addcommand-system-name-callback-variableexists-src-miniquake-cmd-ml-2105979518"></a>
### Cmd_AddCommand

```ml
function Cmd_AddCommand(system, name, callback, variableExists)
```

Mirror Quake's Cmd_AddCommand routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_AddCommand`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `callback` | `dynamic` | — | The callback input consumed by `Cmd_AddCommand`. |
| `variableExists` | `dynamic` | — | The variable exists input consumed by `Cmd_AddCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L495)

<a id="function-function-miniquake-cmd-cmd-alias-f-function-cmd-alias-f-system-arguments-src-miniquake-cmd-ml-1681300142"></a>
### Cmd_Alias_f

```ml
function Cmd_Alias_f(system, arguments)
```

Mirror Quake's Cmd_Alias_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Alias_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L432)

<a id="function-function-miniquake-cmd-cmd-argc-function-cmd-argc-system-src-miniquake-cmd-ml-942048386"></a>
### Cmd_Argc

```ml
function Cmd_Argc(system)
```

Mirror Quake's Cmd_Argc routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Argc`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L464)

<a id="function-function-miniquake-cmd-cmd-args-function-cmd-args-system-src-miniquake-cmd-ml-429544386"></a>
### Cmd_Args

```ml
function Cmd_Args(system)
```

Mirror Quake's Cmd_Args routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Args`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L477)

<a id="function-function-miniquake-cmd-cmd-argv-function-cmd-argv-system-index-src-miniquake-cmd-ml-67463998"></a>
### Cmd_Argv

```ml
function Cmd_Argv(system, index)
```

Mirror Quake's Cmd_Argv routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Argv`. |
| `index` | `dynamic` | — | Zero-based index of the requested entry. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L471)

<a id="function-function-miniquake-cmd-cmd-checkparm-function-cmd-checkparm-system-name-src-miniquake-cmd-ml-46715439"></a>
### Cmd_CheckParm

```ml
function Cmd_CheckParm(system, name)
```

Mirror Quake's Cmd_CheckParm routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_CheckParm`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L541)

<a id="function-function-miniquake-cmd-cmd-completecommand-function-cmd-completecommand-system-partial-src-miniquake-cmd-ml-434077993"></a>
### Cmd_CompleteCommand

```ml
function Cmd_CompleteCommand(system, partial)
```

Mirror Quake's Cmd_CompleteCommand routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_CompleteCommand`. |
| `partial` | `dynamic` | — | The partial input consumed by `Cmd_CompleteCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L510)

<a id="function-function-miniquake-cmd-cmd-echo-f-function-cmd-echo-f-arguments-src-miniquake-cmd-ml-470976861"></a>
### Cmd_Echo_f

```ml
function Cmd_Echo_f(arguments)
```

Mirror Quake's Cmd_Echo_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L412)

<a id="function-function-miniquake-cmd-cmd-exec-f-function-cmd-exec-f-system-arguments-loadedtext-src-miniquake-cmd-ml-243858852"></a>
### Cmd_Exec_f

```ml
function Cmd_Exec_f(system, arguments, loadedText)
```

Mirror Quake's Cmd_Exec_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Exec_f`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |
| `loadedText` | `dynamic` | — | The loaded text input consumed by `Cmd_Exec_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L405)

<a id="function-function-miniquake-cmd-cmd-executestring-function-cmd-executestring-system-text-source-src-miniquake-cmd-ml-261896270"></a>
### Cmd_ExecuteString

```ml
function Cmd_ExecuteString(system, text, source)
```

Mirror Quake's Cmd_ExecuteString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_ExecuteString`. |
| `text` | `dynamic` | — | Text to parse or process. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L518)

<a id="function-function-miniquake-cmd-cmd-exists-function-cmd-exists-system-name-src-miniquake-cmd-ml-1650862765"></a>
### Cmd_Exists

```ml
function Cmd_Exists(system, name)
```

Report whether cmd exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Exists`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L503)

<a id="function-function-miniquake-cmd-cmd-forwardtoserver-function-cmd-forwardtoserver-system-outgoing-connected-demoplayback-src-miniquake-cmd-ml-578680629"></a>
### Cmd_ForwardToServer

```ml
function Cmd_ForwardToServer(system, outgoing, connected, demoPlayback)
```

Mirror Quake's Cmd_ForwardToServer routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_ForwardToServer`. |
| `outgoing` | `dynamic` | — | The outgoing input consumed by `Cmd_ForwardToServer`. |
| `connected` | `dynamic` | — | The connected input consumed by `Cmd_ForwardToServer`. |
| `demoPlayback` | `dynamic` | — | The demo playback input consumed by `Cmd_ForwardToServer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L527)

<a id="function-function-miniquake-cmd-cmd-init-function-cmd-init-system-src-miniquake-cmd-ml-820573402"></a>
### Cmd_Init

```ml
function Cmd_Init(system)
```

Mirror Quake's Cmd_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Init`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L452)

<a id="function-function-miniquake-cmd-cmd-initcallback-function-cmd-initcallback-arguments-src-miniquake-cmd-ml-1776888873"></a>
### Cmd_InitCallback

```ml
function Cmd_InitCallback(arguments)
```

Mirror Quake's Cmd_InitCallback routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L446)

<a id="function-function-miniquake-cmd-cmd-stuffcmds-f-function-cmd-stuffcmds-f-system-commandlineargs-src-miniquake-cmd-ml-1222093146"></a>
### Cmd_StuffCmds_f

```ml
function Cmd_StuffCmds_f(system, commandLineArgs)
```

Mirror Quake's Cmd_StuffCmds_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_StuffCmds_f`. |
| `commandLineArgs` | `dynamic` | — | The command line args input consumed by `Cmd_StuffCmds_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L371)

<a id="function-function-miniquake-cmd-cmd-tokenizestring-function-cmd-tokenizestring-system-text-src-miniquake-cmd-ml-504674017"></a>
### Cmd_TokenizeString

```ml
function Cmd_TokenizeString(system, text)
```

Mirror Quake's Cmd_TokenizeString routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_TokenizeString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L484)

<a id="function-function-miniquake-cmd-cmd-wait-f-function-cmd-wait-f-system-src-miniquake-cmd-ml-1196505614"></a>
### Cmd_Wait_f

```ml
function Cmd_Wait_f(system)
```

Mirror Quake's Cmd_Wait_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `Cmd_Wait_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L338)

<a id="constant-constant-miniquake-cmd-command-buffer-size-const-command-buffer-size-8192-src-miniquake-cmd-ml-763134350"></a>
### COMMAND_BUFFER_SIZE

```ml
const COMMAND_BUFFER_SIZE = 8192
```

Defines the command buffer size value used by `miniquake.cmd`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L21)

<a id="function-function-miniquake-cmd-commandexists-function-commandexists-system-name-src-miniquake-cmd-ml-411993423"></a>
### commandExists

```ml
function commandExists(system, name)
```

Report whether command exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `commandExists`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L44)

<a id="function-function-miniquake-cmd-completecommand-function-completecommand-system-partial-src-miniquake-cmd-ml-743380331"></a>
### completeCommand

```ml
function completeCommand(system, partial)
```

Handle command and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `completeCommand`. |
| `partial` | `dynamic` | — | The partial input consumed by `completeCommand`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L329)

<a id="function-function-miniquake-cmd-copystring-function-copystring-value-src-miniquake-cmd-ml-402135052"></a>
### CopyString

```ml
function CopyString(value)
```

Transfer data for copy string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `CopyString`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L425)

<a id="function-function-miniquake-cmd-create-function-create-src-miniquake-cmd-ml-897598859"></a>
### create

```ml
function create()
```

Implements the `create` operation for `miniquake.cmd` (create).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L24)

<a id="function-function-miniquake-cmd-executebuffer-function-executebuffer-system-src-miniquake-cmd-ml-966731380"></a>
### executeBuffer

```ml
function executeBuffer(system)
```

Execute buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `executeBuffer`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L294)

<a id="function-function-miniquake-cmd-executestring-function-executestring-system-text-src-miniquake-cmd-ml-322194413"></a>
### executeString

```ml
function executeString(system, text)
```

Execute string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `executeString`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L204)

<a id="function-function-miniquake-cmd-inserttext-function-inserttext-system-text-src-miniquake-cmd-ml-442722129"></a>
### insertText

```ml
function insertText(system, text)
```

Add state for insert text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `insertText`. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L240)

<a id="constant-constant-miniquake-cmd-max-alias-name-const-max-alias-name-32-src-miniquake-cmd-ml-1562743241"></a>
### MAX_ALIAS_NAME

```ml
const MAX_ALIAS_NAME = 32
```

Defines the max alias name value used by `miniquake.cmd`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L17)

<a id="constant-constant-miniquake-cmd-max-args-const-max-args-80-src-miniquake-cmd-ml-373348336"></a>
### MAX_ARGS

```ml
const MAX_ARGS = 80
```

Defines the max args value used by `miniquake.cmd`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L19)

<a id="function-function-miniquake-cmd-prefixmatches-function-prefixmatches-candidate-partial-src-miniquake-cmd-ml-1109766419"></a>
### prefixMatches

```ml
function prefixMatches(candidate, partial)
```

Implements the `prefixMatches` operation for `miniquake.cmd` (prefix matches).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `candidate` | `dynamic` | — | The candidate input consumed by `prefixMatches`. |
| `partial` | `dynamic` | — | The partial input consumed by `prefixMatches`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L314)

<a id="function-function-miniquake-cmd-rawargumenttail-function-rawargumenttail-text-src-miniquake-cmd-ml-879466858"></a>
### rawArgumentTail

```ml
function rawArgumentTail(text)
```

Implements the `rawArgumentTail` operation for `miniquake.cmd` (raw argument tail).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L127)

<a id="function-function-miniquake-cmd-removecommandsnamed-function-removecommandsnamed-system-requestedname-src-miniquake-cmd-ml-621822419"></a>
### removeCommandsNamed

```ml
function removeCommandsNamed(system, requestedName)
```

Remove every pending command with the requested name while preserving the order of unrelated buffered commands.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `removeCommandsNamed`. |
| `requestedName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L253)

<a id="function-function-miniquake-cmd-splitfirstcommand-function-splitfirstcommand-text-src-miniquake-cmd-ml-1969270170"></a>
### splitFirstCommand

```ml
function splitFirstCommand(text)
```

Convert first command into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L271)

<a id="function-function-miniquake-cmd-terminatedaliasvalue-function-terminatedaliasvalue-value-src-miniquake-cmd-ml-4743684"></a>
### terminatedAliasValue

```ml
function terminatedAliasValue(value)
```

Return terminated alias value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `terminatedAliasValue`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L53)

<a id="function-function-miniquake-cmd-tokenize-function-tokenize-text-src-miniquake-cmd-ml-797987804"></a>
### tokenize

```ml
function tokenize(text)
```

Convert the requested value into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/cmd.ml#L81)
