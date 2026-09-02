# `src/miniquake/common.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.common`](Package-miniquake-common-1000441518.md)

Reachable from entry: **yes**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/constants.ml` as `c` → [src/miniquake/constants.ml](File-src-miniquake-constants-ml-2121832207.md)
- `miniquake/native.ml` as `native` → [src/miniquake/native.ml](File-src-miniquake-native-ml-1937216067.md)
- `miniquake/protocol_text.ml` as `quakeText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)

## Declarations

<a id="function-function-miniquake-common-atof-function-atof-text-src-miniquake-common-ml-44319216"></a>
### atof

```ml
function atof(text)
```

Q_atof deliberately stops at the first non-number and supports Quake's hexadecimal and character literal forms. It is not the host language's stricter general-purpose number parser.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L83)

<a id="function-function-miniquake-common-atoi-function-atoi-text-src-miniquake-common-ml-1914868872"></a>
### atoi

```ml
function atoi(text)
```

Implements the `atoi` operation for `miniquake.common` (atoi).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L134)

<a id="function-function-miniquake-common-basedirectory-function-basedirectory-commandline-src-miniquake-common-ml-562005324"></a>
### baseDirectory

```ml
function baseDirectory(commandLine)
```

Implements the `baseDirectory` operation for `miniquake.common` (base directory).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `baseDirectory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L726)

<a id="function-function-miniquake-common-catof-function-catof-text-src-miniquake-common-ml-1101165974"></a>
### cAtof

```ml
function cAtof(text)
```

C runtime atof semantics used by pr_edict.c and host_cmd.c save loading. The main native bridge calls strtod and narrows the result to C float, so signed zero, exponent syntax and the exact IEEE-754 binary32 boundary match WinQuake instead of depending on MiniLang's general toNumber() conversion.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L201)

<a id="function-function-miniquake-common-catoi-function-catoi-text-src-miniquake-common-ml-914622676"></a>
### cAtoi

```ml
function cAtoi(text)
```

C runtime atoi semantics used by host_cmd.c and view.c.  Unlike Quake's Q_atoi above, this accepts only the initial decimal digit run after ASCII whitespace and an optional sign; 0x and character-literal syntax are not recognized.  The result is narrowed to WinQuake's signed 32-bit int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L175)

<a id="function-function-miniquake-common-checkparm-function-checkparm-commandline-name-src-miniquake-common-ml-256881261"></a>
### checkParm

```ml
function checkParm(commandLine, name)
```

Validate parm and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `checkParm`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L674)

<a id="function-function-miniquake-common-clearlink-function-clearlink-link-src-miniquake-common-ml-566942171"></a>
### ClearLink

```ml
function ClearLink(link)
```

Original WinQuake/common.c entry points.  The engine uses the descriptive MiniLang names above internally; these aliases keep the source-file pendant explicit and make one-to-one differential fixtures readable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `ClearLink`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L778)

<a id="function-function-miniquake-common-clearlink-function-clearlink-link-src-miniquake-common-ml-528379931"></a>
### clearLink

```ml
function clearLink(link)
```

Update module state for link.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `clearLink`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L18)

<a id="function-function-miniquake-common-com-checkparm-function-com-checkparm-commandline-name-src-miniquake-common-ml-266031153"></a>
### COM_CheckParm

```ml
function COM_CheckParm(commandLine, name)
```

Mirror Quake's COM_CheckParm routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `COM_CheckParm`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L1003)

<a id="function-function-miniquake-common-com-defaultextension-function-com-defaultextension-pathname-extension-src-miniquake-common-ml-372525974"></a>
### COM_DefaultExtension

```ml
function COM_DefaultExtension(pathname, extension)
```

Mirror Quake's COM_DefaultExtension routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |
| `extension` | `dynamic` | — | The extension input consumed by `COM_DefaultExtension`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L989)

<a id="function-function-miniquake-common-com-filebase-function-com-filebase-pathname-src-miniquake-common-ml-1299853077"></a>
### COM_FileBase

```ml
function COM_FileBase(pathname)
```

Mirror Quake's COM_FileBase routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L982)

<a id="function-function-miniquake-common-com-fileextension-function-com-fileextension-pathname-src-miniquake-common-ml-1002883883"></a>
### COM_FileExtension

```ml
function COM_FileExtension(pathname)
```

Mirror Quake's COM_FileExtension routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L976)

<a id="function-function-miniquake-common-com-init-function-com-init-basedir-arguments-src-miniquake-common-ml-1169242277"></a>
### COM_Init

```ml
function COM_Init(basedir, arguments)
```

Mirror Quake's COM_Init routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `basedir` | `dynamic` | — | The basedir input consumed by `COM_Init`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L1016)

<a id="function-function-miniquake-common-com-initargv-function-com-initargv-arguments-src-miniquake-common-ml-1087090673"></a>
### COM_InitArgv

```ml
function COM_InitArgv(arguments)
```

Mirror Quake's COM_InitArgv routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L1009)

<a id="function-function-miniquake-common-com-parse-function-com-parse-text-startoffset-src-miniquake-common-ml-462747489"></a>
### COM_Parse

```ml
function COM_Parse(text, startOffset)
```

Mirror Quake's COM_Parse routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `startOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L996)

<a id="function-function-miniquake-common-com-skippath-function-com-skippath-pathname-src-miniquake-common-ml-900097177"></a>
### COM_SkipPath

```ml
function COM_SkipPath(pathname)
```

Mirror Quake's COM_SkipPath routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L964)

<a id="function-function-miniquake-common-com-stripextension-function-com-stripextension-pathname-src-miniquake-common-ml-947503341"></a>
### COM_StripExtension

```ml
function COM_StripExtension(pathname)
```

Mirror Quake's COM_StripExtension routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L970)

<a id="function-function-miniquake-common-create-function-create-args-src-miniquake-common-ml-357580826"></a>
### create

```ml
function create(args)
```

Implements the `create` operation for `miniquake.common` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L634)

<a id="function-function-miniquake-common-defaultextension-function-defaultextension-pathname-extension-src-miniquake-common-ml-1699520794"></a>
### defaultExtension

```ml
function defaultExtension(pathname, extension)
```

Implements the `defaultExtension` operation for `miniquake.common` (default extension).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |
| `extension` | `dynamic` | — | The extension input consumed by `defaultExtension`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L432)

<a id="function-function-miniquake-common-describe-function-describe-commandline-src-miniquake-common-ml-371663796"></a>
### describe

```ml
function describe(commandLine)
```

Implements the `describe` operation for `miniquake.common` (describe).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `describe`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L1051)

<a id="function-function-miniquake-common-filebase-function-filebase-pathname-src-miniquake-common-ml-527206545"></a>
### fileBase

```ml
function fileBase(pathname)
```

Implements the `fileBase` operation for `miniquake.common` (file base).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L410)

<a id="function-function-miniquake-common-fileextension-function-fileextension-pathname-src-miniquake-common-ml-1404575955"></a>
### fileExtension

```ml
function fileExtension(pathname)
```

Implements the `fileExtension` operation for `miniquake.common` (file extension).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L396)

<a id="function-function-miniquake-common-fixedfloat-function-fixedfloat-value-src-miniquake-common-ml-1642825822"></a>
### fixedFloat

```ml
function fixedFloat(value)
```

Implements the `fixedFloat` operation for `miniquake.common` (fixed float).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `fixedFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L513)

<a id="function-function-miniquake-common-floatnoswap-function-floatnoswap-value-src-miniquake-common-ml-142789278"></a>
### FloatNoSwap

```ml
function FloatNoSwap(value)
```

Convert byte order for float no swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `FloatNoSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L957)

<a id="function-function-miniquake-common-floatoption-function-floatoption-commandline-name-fallback-src-miniquake-common-ml-323053645"></a>
### floatOption

```ml
function floatOption(commandLine, name, fallback)
```

Implements the `floatOption` operation for `miniquake.common` (float option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `floatOption`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L718)

<a id="function-function-miniquake-common-floatswap-function-floatswap-value-src-miniquake-common-ml-1512711624"></a>
### FloatSwap

```ml
function FloatSwap(value)
```

Convert byte order for float swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `FloatSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L944)

<a id="function-function-miniquake-common-formatflag-function-formatflag-value-src-miniquake-common-ml-1642042306"></a>
### formatFlag

```ml
function formatFlag(value)
```

Format and emit flag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `formatFlag`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L549)

<a id="function-function-miniquake-common-gamedirectory-function-gamedirectory-commandline-src-miniquake-common-ml-614653962"></a>
### gameDirectory

```ml
function gameDirectory(commandLine)
```

Implements the `gameDirectory` operation for `miniquake.common` (game directory).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `gameDirectory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L732)

<a id="function-function-miniquake-common-hasparm-function-hasparm-commandline-name-src-miniquake-common-ml-648698637"></a>
### hasParm

```ml
function hasParm(commandLine, name)
```

Report whether parm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `hasParm`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L688)

<a id="function-function-miniquake-common-hexadecimal-function-hexadecimal-value-upper-src-miniquake-common-ml-1954880802"></a>
### hexadecimal

```ml
function hexadecimal(value, upper)
```

Implements the `hexadecimal` operation for `miniquake.common` (hexadecimal).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `hexadecimal`. |
| `upper` | `dynamic` | — | The upper input consumed by `hexadecimal`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L532)

<a id="function-function-miniquake-common-hexdigit-function-hexdigit-value-src-miniquake-common-ml-1610896326"></a>
### hexDigit

```ml
function hexDigit(value)
```

Implements the `hexDigit` operation for `miniquake.common` (hex digit).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `hexDigit`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L56)

<a id="function-function-miniquake-common-insertlinkafter-function-insertlinkafter-link-after-src-miniquake-common-ml-345327513"></a>
### InsertLinkAfter

```ml
function InsertLinkAfter(link, after)
```

Add state for insert link after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `InsertLinkAfter`. |
| `after` | `dynamic` | — | The after input consumed by `InsertLinkAfter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L798)

<a id="function-function-miniquake-common-insertlinkafter-function-insertlinkafter-link-after-src-miniquake-common-ml-1146501017"></a>
### insertLinkAfter

```ml
function insertLinkAfter(link, after)
```

Add state for insert link after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `insertLinkAfter`. |
| `after` | `dynamic` | — | The after input consumed by `insertLinkAfter`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L46)

<a id="function-function-miniquake-common-insertlinkbefore-function-insertlinkbefore-link-before-src-miniquake-common-ml-882584196"></a>
### InsertLinkBefore

```ml
function InsertLinkBefore(link, before)
```

Add state for insert link before.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `InsertLinkBefore`. |
| `before` | `dynamic` | — | The before input consumed by `InsertLinkBefore`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L791)

<a id="function-function-miniquake-common-insertlinkbefore-function-insertlinkbefore-link-before-src-miniquake-common-ml-1225779332"></a>
### insertLinkBefore

```ml
function insertLinkBefore(link, before)
```

Add state for insert link before.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `insertLinkBefore`. |
| `before` | `dynamic` | — | The before input consumed by `insertLinkBefore`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L35)

<a id="function-function-miniquake-common-integeroption-function-integeroption-commandline-name-fallback-src-miniquake-common-ml-109832445"></a>
### integerOption

```ml
function integerOption(commandLine, name, fallback)
```

Implements the `integerOption` operation for `miniquake.common` (integer option).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `integerOption`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L708)

<a id="function-function-miniquake-common-joinarguments-function-joinarguments-args-src-miniquake-common-ml-441011634"></a>
### joinArguments

```ml
function joinArguments(args)
```

Implements the `joinArguments` operation for `miniquake.common` (join arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line arguments supplied by the host process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L621)

<a id="function-function-miniquake-common-longnoswap-function-longnoswap-value-src-miniquake-common-ml-699530286"></a>
### LongNoSwap

```ml
function LongNoSwap(value)
```

Convert byte order for long no swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `LongNoSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L937)

<a id="function-function-miniquake-common-longswap-function-longswap-value-src-miniquake-common-ml-285373150"></a>
### LongSwap

```ml
function LongSwap(value)
```

Convert byte order for long swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `LongSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L924)

<a id="function-function-miniquake-common-memcompare-function-memcompare-first-second-count-src-miniquake-common-ml-632022486"></a>
### memCompare

```ml
function memCompare(first, second, count)
```

Implements the `memCompare` operation for `miniquake.common` (mem compare).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `memCompare`. |
| `second` | `dynamic` | — | The second input consumed by `memCompare`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L239)

<a id="function-function-miniquake-common-memcopy-function-memcopy-destination-source-count-src-miniquake-common-ml-369296777"></a>
### memCopy

```ml
function memCopy(destination, source, count)
```

Implements the `memCopy` operation for `miniquake.common` (mem copy).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L224)

<a id="function-function-miniquake-common-memorysearch-function-memorysearch-data-count-search-src-miniquake-common-ml-1265231192"></a>
### memorySearch

```ml
function memorySearch(data, count, search)
```

Implements the `memorySearch` operation for `miniquake.common` (memory search).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `search` | `dynamic` | — | The search input consumed by `memorySearch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L501)

<a id="function-function-miniquake-common-memsearch-function-memsearch-data-count-search-src-miniquake-common-ml-187787474"></a>
### memsearch

```ml
function memsearch(data, count, search)
```

Implements the `memsearch` operation for `miniquake.common` (memsearch).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Input data consumed by the operation. |
| `count` | `dynamic` | — | Number of entries or units to process. |
| `search` | `dynamic` | — | The search input consumed by `memsearch`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L1028)

<a id="function-function-miniquake-common-memset-function-memset-destination-fill-count-src-miniquake-common-ml-30786653"></a>
### memSet

```ml
function memSet(destination, fill, count)
```

MiniLang byte arrays replace Q_mem*'s untyped pointers.  These functions preserve Quake's observable copy/fill/compare rules at offset zero.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `fill` | `dynamic` | — | The fill input consumed by `memSet`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L210)

<a id="function-function-miniquake-common-parmvalue-function-parmvalue-commandline-name-fallback-src-miniquake-common-ml-1071510233"></a>
### parmValue

```ml
function parmValue(commandLine, name, fallback)
```

Return parm value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `parmValue`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L696)

<a id="function-function-miniquake-common-parsetoken-function-parsetoken-text-startoffset-src-miniquake-common-ml-1651164499"></a>
### parseToken

```ml
function parseToken(text, startOffset)
```

COM_Parse returns a pointer to the remaining source.  Its MiniLang pendant returns [token, nextOffset, eof], retaining punctuation and comment rules.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `startOffset` | `dynamic` | — | Zero-based offset of the requested data. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L452)

<a id="function-function-miniquake-common-plusvalue-function-plusvalue-commandline-commandname-fallback-src-miniquake-common-ml-886039232"></a>
### plusValue

```ml
function plusValue(commandLine, commandName, fallback)
```

Return plus value derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `plusValue`. |
| `commandName` | `dynamic` | — | Name that identifies the requested value or resource. |
| `fallback` | `dynamic` | — | Value to use when the requested input is unavailable or invalid. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L1036)

<a id="function-function-miniquake-common-punctuation-function-punctuation-value-src-miniquake-common-ml-600229022"></a>
### punctuation

```ml
function punctuation(value)
```

Implements the `punctuation` operation for `miniquake.common` (punctuation).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `punctuation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L444)

<a id="function-function-miniquake-common-q-atof-function-q-atof-text-src-miniquake-common-ml-313212476"></a>
### Q_atof

```ml
function Q_atof(text)
```

Provide the Quake-compatible atof entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L897)

<a id="function-function-miniquake-common-q-atoi-function-q-atoi-text-src-miniquake-common-ml-375100564"></a>
### Q_atoi

```ml
function Q_atoi(text)
```

Provide the Quake-compatible atoi entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L891)

<a id="function-function-miniquake-common-q-memcmp-function-q-memcmp-first-second-count-src-miniquake-common-ml-1880083378"></a>
### Q_memcmp

```ml
function Q_memcmp(first, second, count)
```

Provide the Quake-compatible memcmp entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `Q_memcmp`. |
| `second` | `dynamic` | — | The second input consumed by `Q_memcmp`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L822)

<a id="function-function-miniquake-common-q-memcpy-function-q-memcpy-destination-source-count-src-miniquake-common-ml-319603021"></a>
### Q_memcpy

```ml
function Q_memcpy(destination, source, count)
```

Provide the Quake-compatible memcpy entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L814)

<a id="function-function-miniquake-common-q-memset-function-q-memset-destination-fill-count-src-miniquake-common-ml-2016859877"></a>
### Q_memset

```ml
function Q_memset(destination, fill, count)
```

Provide the Quake-compatible memset entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `fill` | `dynamic` | — | The fill input consumed by `Q_memset`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L806)

<a id="function-function-miniquake-common-q-strcasecmp-function-q-strcasecmp-first-second-src-miniquake-common-ml-1643878011"></a>
### Q_strcasecmp

```ml
function Q_strcasecmp(first, second)
```

Provide the Quake-compatible strcasecmp entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `Q_strcasecmp`. |
| `second` | `dynamic` | — | The second input consumed by `Q_strcasecmp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L885)

<a id="function-function-miniquake-common-q-strcat-function-q-strcat-destination-source-src-miniquake-common-ml-568192758"></a>
### Q_strcat

```ml
function Q_strcat(destination, source)
```

Provide the Quake-compatible strcat entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L855)

<a id="function-function-miniquake-common-q-strcmp-function-q-strcmp-first-second-src-miniquake-common-ml-1888364691"></a>
### Q_strcmp

```ml
function Q_strcmp(first, second)
```

Provide the Quake-compatible strcmp entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `Q_strcmp`. |
| `second` | `dynamic` | — | The second input consumed by `Q_strcmp`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L862)

<a id="function-function-miniquake-common-q-strcpy-function-q-strcpy-source-src-miniquake-common-ml-1382844646"></a>
### Q_strcpy

```ml
function Q_strcpy(source)
```

Provide the Quake-compatible strcpy entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L828)

<a id="function-function-miniquake-common-q-strlen-function-q-strlen-text-src-miniquake-common-ml-1283559436"></a>
### Q_strlen

```ml
function Q_strlen(text)
```

Provide the Quake-compatible strlen entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L841)

<a id="function-function-miniquake-common-q-strncasecmp-function-q-strncasecmp-first-second-count-src-miniquake-common-ml-1201228932"></a>
### Q_strncasecmp

```ml
function Q_strncasecmp(first, second, count)
```

Provide the Quake-compatible strncasecmp entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `Q_strncasecmp`. |
| `second` | `dynamic` | — | The second input consumed by `Q_strncasecmp`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L878)

<a id="function-function-miniquake-common-q-strncmp-function-q-strncmp-first-second-count-src-miniquake-common-ml-1161461812"></a>
### Q_strncmp

```ml
function Q_strncmp(first, second, count)
```

Provide the Quake-compatible strncmp entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `Q_strncmp`. |
| `second` | `dynamic` | — | The second input consumed by `Q_strncmp`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L870)

<a id="function-function-miniquake-common-q-strncpy-function-q-strncpy-source-count-src-miniquake-common-ml-42795479"></a>
### Q_strncpy

```ml
function Q_strncpy(source, count)
```

Provide the Quake-compatible strncpy entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value or collection to read. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L835)

<a id="function-function-miniquake-common-q-strrchr-function-q-strrchr-text-character-src-miniquake-common-ml-610365807"></a>
### Q_strrchr

```ml
function Q_strrchr(text, character)
```

Provide the Quake-compatible strrchr entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `character` | `dynamic` | — | The character input consumed by `Q_strrchr`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L848)

<a id="function-function-miniquake-common-quakefloat-function-quakefloat-value-src-miniquake-common-ml-211235582"></a>
### quakeFloat

```ml
function quakeFloat(value)
```

Original Q_atof returns C float even though it accumulates through a double. Make the return boundary explicit so MiniLang wider precision cannot leak.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `quakeFloat`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L66)

<a id="function-function-miniquake-common-quakeint32-function-quakeint32-value-src-miniquake-common-ml-608707514"></a>
### quakeInt32

```ml
function quakeInt32(value)
```

WinQuake Q_atoi stores all intermediate results in a signed 32-bit int. MSVC on the original target observes two's-complement wrapping here.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `quakeInt32`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L73)

<a id="function-function-miniquake-common-quotecommandargument-function-quotecommandargument-text-src-miniquake-common-ml-1418664412"></a>
### quoteCommandArgument

```ml
function quoteCommandArgument(text)
```

Convert data for quote command argument.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L738)

<a id="function-function-miniquake-common-removelink-function-removelink-link-src-miniquake-common-ml-1344738657"></a>
### RemoveLink

```ml
function RemoveLink(link)
```

Release state for remove link.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `RemoveLink`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L784)

<a id="function-function-miniquake-common-removelink-function-removelink-link-src-miniquake-common-ml-648115105"></a>
### removeLink

```ml
function removeLink(link)
```

Release state for remove link.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `link` | `dynamic` | — | The link input consumed by `removeLink`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L26)

<a id="function-function-miniquake-common-shortnoswap-function-shortnoswap-value-src-miniquake-common-ml-1794751374"></a>
### ShortNoSwap

```ml
function ShortNoSwap(value)
```

Convert byte order for short no swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ShortNoSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L918)

<a id="function-function-miniquake-common-shortswap-function-shortswap-value-src-miniquake-common-ml-1857046140"></a>
### ShortSwap

```ml
function ShortSwap(value)
```

Convert byte order for short swap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `ShortSwap`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L911)

<a id="function-function-miniquake-common-signedshort-function-signedshort-value-src-miniquake-common-ml-1090906126"></a>
### signedShort

```ml
function signedShort(value)
```

Implements the `signedShort` operation for `miniquake.common` (signed short).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `signedShort`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L903)

<a id="function-function-miniquake-common-skippath-function-skippath-pathname-src-miniquake-common-ml-634911453"></a>
### skipPath

```ml
function skipPath(pathname)
```

Return skip path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L372)

<a id="function-function-miniquake-common-startswithmarker-function-startswithmarker-text-marker-src-miniquake-common-ml-1847180762"></a>
### startsWithMarker

```ml
function startsWithMarker(text, marker)
```

Initialize state for starts with marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `marker` | `dynamic` | — | The marker input consumed by `startsWithMarker`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L613)

<a id="function-function-miniquake-common-stringcompare-function-stringcompare-first-second-src-miniquake-common-ml-2069062003"></a>
### stringCompare

```ml
function stringCompare(first, second)
```

Implements the `stringCompare` operation for `miniquake.common` (string compare).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `stringCompare`. |
| `second` | `dynamic` | — | The second input consumed by `stringCompare`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L315)

<a id="function-function-miniquake-common-stringcomparecount-function-stringcomparecount-first-second-count-src-miniquake-common-ml-2024118034"></a>
### stringCompareCount

```ml
function stringCompareCount(first, second, count)
```

Return string compare count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `stringCompareCount`. |
| `second` | `dynamic` | — | The second input consumed by `stringCompareCount`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L296)

<a id="function-function-miniquake-common-stringcompareinsensitive-function-stringcompareinsensitive-first-second-src-miniquake-common-ml-1029340655"></a>
### stringCompareInsensitive

```ml
function stringCompareInsensitive(first, second)
```

Implements the `stringCompareInsensitive` operation for `miniquake.common` (string compare insensitive).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `stringCompareInsensitive`. |
| `second` | `dynamic` | — | The second input consumed by `stringCompareInsensitive`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L353)

<a id="function-function-miniquake-common-stringcompareinsensitivecount-function-stringcompareinsensitivecount-first-second-count-src-miniquake-common-ml-1820203714"></a>
### stringCompareInsensitiveCount

```ml
function stringCompareInsensitiveCount(first, second, count)
```

Return string compare insensitive count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `first` | `dynamic` | — | The first input consumed by `stringCompareInsensitiveCount`. |
| `second` | `dynamic` | — | The second input consumed by `stringCompareInsensitiveCount`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L334)

<a id="function-function-miniquake-common-stringconcat-function-stringconcat-destination-source-src-miniquake-common-ml-1445716210"></a>
### stringConcat

```ml
function stringConcat(destination, source)
```

Implements the `stringConcat` operation for `miniquake.common` (string concat).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L275)

<a id="function-function-miniquake-common-stringcopy-function-stringcopy-text-src-miniquake-common-ml-1953657048"></a>
### stringCopy

```ml
function stringCopy(text)
```

Implements the `stringCopy` operation for `miniquake.common` (string copy).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L258)

<a id="function-function-miniquake-common-stringcopycount-function-stringcopycount-text-count-src-miniquake-common-ml-1716131593"></a>
### stringCopyCount

```ml
function stringCopyCount(text, count)
```

Return string copy count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L265)

<a id="function-function-miniquake-common-stringlastindex-function-stringlastindex-text-character-src-miniquake-common-ml-1133148525"></a>
### stringLastIndex

```ml
function stringLastIndex(text, character)
```

Return string last index derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `character` | `dynamic` | — | The character input consumed by `stringLastIndex`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L282)

<a id="function-function-miniquake-common-stringlength-function-stringlength-text-src-miniquake-common-ml-1235066624"></a>
### stringLength

```ml
function stringLength(text)
```

Return string length derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L252)

<a id="function-function-miniquake-common-stripextension-function-stripextension-pathname-src-miniquake-common-ml-901519669"></a>
### stripExtension

```ml
function stripExtension(pathname)
```

Convert extension into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pathname` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L385)

<a id="function-function-miniquake-common-stuffcommands-function-stuffcommands-commandline-src-miniquake-common-ml-495824568"></a>
### stuffCommands

```ml
function stuffCommands(commandLine)
```

Implements the `stuffCommands` operation for `miniquake.common` (stuff commands).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `stuffCommands`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L754)

<a id="function-function-miniquake-common-substring-function-substring-text-offset-count-src-miniquake-common-ml-158252430"></a>
### substring

```ml
function substring(text, offset, count)
```

Implements the `substring` operation for `miniquake.common` (substring).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to parse or process. |
| `offset` | `dynamic` | — | Zero-based offset of the requested data. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L361)

<a id="function-function-miniquake-common-upperascii-function-upperascii-value-src-miniquake-common-ml-951539842"></a>
### upperAscii

```ml
function upperAscii(value)
```

Convert data for upper ascii.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed by `upperAscii`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L325)

<a id="function-function-miniquake-common-va-function-va-format-arguments-src-miniquake-common-ml-1118788174"></a>
### va

```ml
function va(format, arguments)
```

C va() is a transient 1024-byte vsprintf buffer. MiniLang strings are immutable, so callers pass the variadic values as an array and receive an owned string. This covers every conversion used by the MiniQuake target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `format` | `dynamic` | — | The format input consumed by `va`. |
| `arguments` | `dynamic` | — | Command-line arguments to inspect or execute. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/common.ml#L560)
