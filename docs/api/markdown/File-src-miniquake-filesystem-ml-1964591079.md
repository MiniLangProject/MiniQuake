# `src/miniquake/filesystem.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.filesystem`](Package-miniquake-filesystem-105445480.md)

Reachable from entry: **yes**

## Imports

- `miniquake/array_util.ml` as `arrayutil` → [src/miniquake/array_util.ml](File-src-miniquake-array-util-ml-1490619700.md)
- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/memory.ml` as `memory` → [src/miniquake/memory.ml](File-src-miniquake-memory-ml-37601647.md)
- `miniquake/pak.ml` as `pak` → [src/miniquake/pak.ml](File-src-miniquake-pak-ml-44503636.md)
- `miniquake/protocol_text.ml` as `quakeText` → [src/miniquake/protocol_text.ml](File-src-miniquake-protocol-text-ml-438970794.md)
- `miniquake/types.ml` as `t` → [src/miniquake/types.ml](File-src-miniquake-types-ml-326034235.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerML/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-filesystem-adddirectory-function-adddirectory-system-directory-src-miniquake-filesystem-ml-200880421"></a>
### addDirectory

```ml
function addDirectory(system, directory)
```

Add state for add directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `addDirectory`. |
| `directory` | `dynamic` | — | The directory input consumed by `addDirectory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L56)

<a id="function-function-miniquake-filesystem-addgamedirectory-function-addgamedirectory-system-directory-src-miniquake-filesystem-ml-1783459957"></a>
### addGameDirectory

```ml
function addGameDirectory(system, directory)
```

Add state for add game directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `addGameDirectory`. |
| `directory` | `dynamic` | — | The directory input consumed by `addGameDirectory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L80)

<a id="function-function-miniquake-filesystem-addpack-function-addpack-system-filename-src-miniquake-filesystem-ml-2114214293"></a>
### addPack

```ml
function addPack(system, filename)
```

Add state for add pack.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `addPack`. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L70)

<a id="function-function-miniquake-filesystem-cachedlocation-function-cachedlocation-system-netpath-src-miniquake-filesystem-ml-409356752"></a>
### cachedLocation

```ml
function cachedLocation(system, netPath)
```

Return cached location derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `cachedLocation`. |
| `netPath` | `dynamic` | — | Filesystem path used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L295)

<a id="function-function-miniquake-filesystem-cachepath-function-cachepath-system-netpath-src-miniquake-filesystem-ml-1600329822"></a>
### cachePath

```ml
function cachePath(system, netPath)
```

Return cache path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `cachePath`. |
| `netPath` | `dynamic` | — | Filesystem path used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L262)

<a id="function-function-miniquake-filesystem-checkregistered-function-checkregistered-system-src-miniquake-filesystem-ml-1495834446"></a>
### checkRegistered

```ml
function checkRegistered(system)
```

Validate registered and report any incompatibility.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `checkRegistered`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L211)

<a id="function-function-miniquake-filesystem-closefile-function-closefile-handle-src-miniquake-filesystem-ml-624654999"></a>
### closeFile

```ml
function closeFile(handle)
```

Release state for close file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `closeFile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L416)

<a id="function-function-miniquake-filesystem-com-addgamedirectory-function-com-addgamedirectory-system-directory-src-miniquake-filesystem-ml-2071174845"></a>
### COM_AddGameDirectory

```ml
function COM_AddGameDirectory(system, directory)
```

Mirror Quake's COM_AddGameDirectory routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_AddGameDirectory`. |
| `directory` | `dynamic` | — | The directory input consumed by `COM_AddGameDirectory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L880)

<a id="function-function-miniquake-filesystem-com-checkregistered-function-com-checkregistered-system-src-miniquake-filesystem-ml-474409722"></a>
### COM_CheckRegistered

```ml
function COM_CheckRegistered(system)
```

Original WinQuake/common.c filesystem entry points.  The state that was global in C is explicit in MiniLang, but the observable operations are the same and remain independently differential-testable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_CheckRegistered`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L776)

<a id="function-function-miniquake-filesystem-com-closefile-function-com-closefile-handle-src-miniquake-filesystem-ml-1382540907"></a>
### COM_CloseFile

```ml
function COM_CloseFile(handle)
```

Mirror Quake's COM_CloseFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `COM_CloseFile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L830)

<a id="function-function-miniquake-filesystem-com-copyfile-function-com-copyfile-netpath-cachepath-src-miniquake-filesystem-ml-830199618"></a>
### COM_CopyFile

```ml
function COM_CopyFile(netPath, cachePath)
```

Mirror Quake's COM_CopyFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `netPath` | `dynamic` | — | Filesystem path used by the operation. |
| `cachePath` | `dynamic` | — | Filesystem path used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L803)

<a id="function-function-miniquake-filesystem-com-createpath-function-com-createpath-path-src-miniquake-filesystem-ml-1778502148"></a>
### COM_CreatePath

```ml
function COM_CreatePath(path)
```

Mirror Quake's COM_CreatePath routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L796)

<a id="function-function-miniquake-filesystem-com-findfile-function-com-findfile-system-filename-src-miniquake-filesystem-ml-172133097"></a>
### COM_FindFile

```ml
function COM_FindFile(system, filename)
```

Mirror Quake's COM_FindFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_FindFile`. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L810)

<a id="function-function-miniquake-filesystem-com-fopenfile-function-com-fopenfile-system-filename-src-miniquake-filesystem-ml-863754181"></a>
### COM_FOpenFile

```ml
function COM_FOpenFile(system, filename)
```

Mirror Quake's COM_FOpenFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_FOpenFile`. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L824)

<a id="function-function-miniquake-filesystem-com-initfilesystem-function-com-initfilesystem-suppliedbasedirectory-commandline-src-miniquake-filesystem-ml-1924398158"></a>
### COM_InitFilesystem

```ml
function COM_InitFilesystem(suppliedBaseDirectory, commandLine)
```

Mirror Quake's COM_InitFilesystem routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `suppliedBaseDirectory` | `dynamic` | — | The supplied base directory input consumed by `COM_InitFilesystem`. |
| `commandLine` | `dynamic` | — | The command line input consumed by `COM_InitFilesystem`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L887)

<a id="function-function-miniquake-filesystem-com-loadcachefile-function-com-loadcachefile-system-path-src-miniquake-filesystem-ml-2017524375"></a>
### COM_LoadCacheFile

```ml
function COM_LoadCacheFile(system, path)
```

Mirror Quake's COM_LoadCacheFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_LoadCacheFile`. |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L858)

<a id="function-function-miniquake-filesystem-com-loadfile-function-com-loadfile-system-path-src-miniquake-filesystem-ml-1802122599"></a>
### COM_LoadFile

```ml
function COM_LoadFile(system, path)
```

Mirror Quake's COM_LoadFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_LoadFile`. |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L837)

<a id="function-function-miniquake-filesystem-com-loadhunkfile-function-com-loadhunkfile-system-path-src-miniquake-filesystem-ml-266843815"></a>
### COM_LoadHunkFile

```ml
function COM_LoadHunkFile(system, path)
```

Mirror Quake's COM_LoadHunkFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_LoadHunkFile`. |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L844)

<a id="function-function-miniquake-filesystem-com-loadpackfile-function-com-loadpackfile-filename-src-miniquake-filesystem-ml-1125248114"></a>
### COM_LoadPackFile

```ml
function COM_LoadPackFile(filename)
```

Mirror Quake's COM_LoadPackFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L872)

<a id="function-function-miniquake-filesystem-com-loadstackfile-function-com-loadstackfile-system-path-buffer-src-miniquake-filesystem-ml-748810153"></a>
### COM_LoadStackFile

```ml
function COM_LoadStackFile(system, path, buffer)
```

Mirror Quake's COM_LoadStackFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_LoadStackFile`. |
| `path` | `dynamic` | — | Filesystem path to process. |
| `buffer` | `dynamic` | — | The buffer input consumed by `COM_LoadStackFile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L866)

<a id="function-function-miniquake-filesystem-com-loadtempfile-function-com-loadtempfile-system-path-src-miniquake-filesystem-ml-154705279"></a>
### COM_LoadTempFile

```ml
function COM_LoadTempFile(system, path)
```

Mirror Quake's COM_LoadTempFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_LoadTempFile`. |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L851)

<a id="function-function-miniquake-filesystem-com-openfile-function-com-openfile-system-filename-src-miniquake-filesystem-ml-74824505"></a>
### COM_OpenFile

```ml
function COM_OpenFile(system, filename)
```

Mirror Quake's COM_OpenFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_OpenFile`. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L817)

<a id="function-function-miniquake-filesystem-com-path-f-function-com-path-f-system-src-miniquake-filesystem-ml-2090219626"></a>
### COM_Path_f

```ml
function COM_Path_f(system)
```

Mirror Quake's COM_Path_f routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_Path_f`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L782)

<a id="function-function-miniquake-filesystem-com-writefile-function-com-writefile-system-filename-data-src-miniquake-filesystem-ml-2028083335"></a>
### COM_WriteFile

```ml
function COM_WriteFile(system, filename, data)
```

Mirror Quake's COM_WriteFile routine and its observable state changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `COM_WriteFile`. |
| `filename` | `dynamic` | — | Path of the file to process. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L790)

<a id="function-function-miniquake-filesystem-containsdirectoryseparator-function-containsdirectoryseparator-name-src-miniquake-filesystem-ml-1551574944"></a>
### containsDirectorySeparator

```ml
function containsDirectorySeparator(name)
```

Implements the `containsDirectorySeparator` operation for `miniquake.filesystem` (contains directory separator).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L236)

<a id="function-function-miniquake-filesystem-copyfile-function-copyfile-netpath-destination-src-miniquake-filesystem-ml-1229615297"></a>
### copyFile

```ml
function copyFile(netPath, destination)
```

Transfer data for copy file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `netPath` | `dynamic` | — | Filesystem path used by the operation. |
| `destination` | `dynamic` | — | Destination value or collection to update. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L275)

<a id="function-function-miniquake-filesystem-copyterminated-function-copyterminated-destination-source-src-miniquake-filesystem-ml-186519166"></a>
### copyTerminated

```ml
function copyTerminated(destination, source)
```

Transfer data for copy terminated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Destination value or collection to update. |
| `source` | `dynamic` | — | Source value or collection to read. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L474)

<a id="function-function-miniquake-filesystem-create-function-create-basedirectory-gamedirectory-src-miniquake-filesystem-ml-257403074"></a>
### create

```ml
function create(baseDirectory, gameDirectory)
```

Implements the `create` operation for `miniquake.filesystem` (create).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L34)

<a id="extern_function-extern-function-miniquake-filesystem-createdirectoryw-extern-function-createdirectoryw-path-as-wstr-security-as-ptr-from-kernel32-dll-returns-bool-src-miniquake-filesystem-ml-643027048"></a>
### CreateDirectoryW

```ml
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" returns bool
```

Invokes the native `CreateDirectoryW` bridge operation used by `miniquake.filesystem`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — | Filesystem path to process. |
| `security` | `ptr` | — | The security input consumed by `CreateDirectoryW`. |


**Returns:** The newly created value returned by `CreateDirectoryW`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L23)

<a id="function-function-miniquake-filesystem-createpath-function-createpath-path-src-miniquake-filesystem-ml-1531015204"></a>
### createPath

```ml
function createPath(path)
```

Create and initialize path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L246)

<a id="function-function-miniquake-filesystem-describe-function-describe-system-src-miniquake-filesystem-ml-429375370"></a>
### describe

```ml
function describe(system)
```

Implements the `describe` operation for `miniquake.filesystem` (describe).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `describe`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L690)

<a id="function-function-miniquake-filesystem-exists-function-exists-system-name-src-miniquake-filesystem-ml-279192691"></a>
### exists

```ml
function exists(system, name)
```

Report whether exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `exists`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L573)

<a id="function-function-miniquake-filesystem-fileexists-function-fileexists-system-name-src-miniquake-filesystem-ml-1678747127"></a>
### fileExists

```ml
function fileExists(system, name)
```

Report whether file exists holds for the active state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `fileExists`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L548)

<a id="function-function-miniquake-filesystem-filetime-function-filetime-path-src-miniquake-filesystem-ml-1549433668"></a>
### fileTime

```ml
function fileTime(path)
```

Implements the `fileTime` operation for `miniquake.filesystem` (file time).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L284)

<a id="function-function-miniquake-filesystem-findfile-function-findfile-system-name-src-miniquake-filesystem-ml-383708435"></a>
### findFile

```ml
function findFile(system, name)
```

Return file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `findFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L365)

<a id="function-function-miniquake-filesystem-findlocation-function-findlocation-system-name-src-miniquake-filesystem-ml-1126898683"></a>
### findLocation

```ml
function findLocation(system, name)
```

Return location.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `findLocation`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L580)

<a id="function-function-miniquake-filesystem-fopenfile-function-fopenfile-system-name-src-miniquake-filesystem-ml-1164883647"></a>
### fOpenFile

```ml
function fOpenFile(system, name)
```

Implements the `fOpenFile` operation for `miniquake.filesystem` (f open file).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `fOpenFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L384)

<a id="function-function-miniquake-filesystem-gamepath-function-gamepath-system-name-src-miniquake-filesystem-ml-2030407819"></a>
### gamePath

```ml
function gamePath(system, name)
```

Return game path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `gamePath`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L589)

<a id="extern_function-extern-function-miniquake-filesystem-getfileattributesexw-extern-function-getfileattributesexw-path-as-wstr-infolevel-as-i32-data-as-bytes-from-kernel32-dll-returns-bool-src-miniquake-filesystem-ml-254768929"></a>
### GetFileAttributesExW

```ml
extern function GetFileAttributesExW(path as wstr, infoLevel as i32, data as bytes) from "kernel32.dll" returns bool
```

Invokes the native `GetFileAttributesExW` bridge operation used by `miniquake.filesystem`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — | Filesystem path to process. |
| `infoLevel` | `i32` | — | The info level input consumed by `GetFileAttributesExW`. |
| `data` | `bytes` | — | Input data consumed by the operation. |


**Returns:** The value resolved by `GetFileAttributesExW`.

[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L29)

<a id="function-function-miniquake-filesystem-handleread-function-handleread-handle-count-src-miniquake-filesystem-ml-919096482"></a>
### handleRead

```ml
function handleRead(handle, count)
```

Handle read and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `handleRead`. |
| `count` | `dynamic` | — | Number of entries or units to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L404)

<a id="function-function-miniquake-filesystem-handleseek-function-handleseek-handle-position-src-miniquake-filesystem-ml-202175422"></a>
### handleSeek

```ml
function handleSeek(handle, position)
```

Handle seek and update the associated state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — | The handle input consumed by `handleSeek`. |
| `position` | `dynamic` | — | Position used by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L394)

<a id="function-function-miniquake-filesystem-initfilesystem-function-initfilesystem-suppliedbasedirectory-commandline-src-miniquake-filesystem-ml-600256186"></a>
### initFilesystem

```ml
function initFilesystem(suppliedBaseDirectory, commandLine)
```

Initialize state for init filesystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `suppliedBaseDirectory` | `dynamic` | — | The supplied base directory input consumed by `initFilesystem`. |
| `commandLine` | `dynamic` | — | The command line input consumed by `initFilesystem`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L191)

<a id="function-function-miniquake-filesystem-initialize-function-initialize-basedirectory-gamename-src-miniquake-filesystem-ml-1209369502"></a>
### initialize

```ml
function initialize(baseDirectory, gameName)
```

Initializes ialize for `miniquake.filesystem`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L111)

<a id="function-function-miniquake-filesystem-initializearguments-function-initializearguments-suppliedbasedirectory-commandline-src-miniquake-filesystem-ml-812685338"></a>
### initializeArguments

```ml
function initializeArguments(suppliedBaseDirectory, commandLine)
```

Initialize state for initialize arguments.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `suppliedBaseDirectory` | `dynamic` | — | The supplied base directory input consumed by `initializeArguments`. |
| `commandLine` | `dynamic` | — | The command line input consumed by `initializeArguments`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L128)

<a id="function-function-miniquake-filesystem-ismodified-function-ismodified-system-src-miniquake-filesystem-ml-1466446218"></a>
### isModified

```ml
function isModified(system)
```

Report whether is modified.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `isModified`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L762)

<a id="function-function-miniquake-filesystem-join-function-join-a-b-src-miniquake-filesystem-ml-1080243196"></a>
### join

```ml
function join(a, b)
```

Implements the `join` operation for `miniquake.filesystem` (join).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — | The a input consumed by `join`. |
| `b` | `dynamic` | — | The b input consumed by `join`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L41)

<a id="function-function-miniquake-filesystem-loadcacheallocation-function-loadcacheallocation-system-memorystate-name-src-miniquake-filesystem-ml-1758803829"></a>
### loadCacheAllocation

```ml
function loadCacheAllocation(system, memoryState, name)
```

Read and validate cache allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadCacheAllocation`. |
| `memoryState` | `dynamic` | — | Mutable state used by `loadCacheAllocation`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L520)

<a id="function-function-miniquake-filesystem-loadcachefile-function-loadcachefile-system-name-src-miniquake-filesystem-ml-1072342119"></a>
### loadCacheFile

```ml
function loadCacheFile(system, name)
```

Read and validate cache file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadCacheFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L453)

<a id="function-function-miniquake-filesystem-loadfile-function-loadfile-system-name-src-miniquake-filesystem-ml-423213879"></a>
### loadFile

```ml
function loadFile(system, name)
```

COM_LoadFile always allocated one extra byte and NUL-terminated it.  Keep readFile as the raw COM_FindFile view used by binary parsers, and expose the load-family behavior explicitly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L428)

<a id="function-function-miniquake-filesystem-loadhunkallocation-function-loadhunkallocation-system-memorystate-name-src-miniquake-filesystem-ml-1259659745"></a>
### loadHunkAllocation

```ml
function loadHunkAllocation(system, memoryState, name)
```

Read and validate hunk allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadHunkAllocation`. |
| `memoryState` | `dynamic` | — | Mutable state used by `loadHunkAllocation`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L484)

<a id="function-function-miniquake-filesystem-loadhunkfile-function-loadhunkfile-system-name-src-miniquake-filesystem-ml-794621847"></a>
### loadHunkFile

```ml
function loadHunkFile(system, name)
```

Read and validate hunk file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadHunkFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L439)

<a id="function-function-miniquake-filesystem-loadpackfile-function-loadpackfile-filename-src-miniquake-filesystem-ml-2052531306"></a>
### loadPackFile

```ml
function loadPackFile(filename)
```

Read and validate pack file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L63)

<a id="function-function-miniquake-filesystem-loadstackallocation-function-loadstackallocation-system-memorystate-name-buffer-src-miniquake-filesystem-ml-191914307"></a>
### loadStackAllocation

```ml
function loadStackAllocation(system, memoryState, name, buffer)
```

Read and validate stack allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadStackAllocation`. |
| `memoryState` | `dynamic` | — | Mutable state used by `loadStackAllocation`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `buffer` | `dynamic` | — | The buffer input consumed by `loadStackAllocation`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L533)

<a id="function-function-miniquake-filesystem-loadstackfile-function-loadstackfile-system-name-buffer-src-miniquake-filesystem-ml-398151521"></a>
### loadStackFile

```ml
function loadStackFile(system, name, buffer)
```

Read and validate stack file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadStackFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `buffer` | `dynamic` | — | The buffer input consumed by `loadStackFile`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L461)

<a id="function-function-miniquake-filesystem-loadtempallocation-function-loadtempallocation-system-memorystate-name-src-miniquake-filesystem-ml-460721329"></a>
### loadTempAllocation

```ml
function loadTempAllocation(system, memoryState, name)
```

Read and validate temp allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadTempAllocation`. |
| `memoryState` | `dynamic` | — | Mutable state used by `loadTempAllocation`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L496)

<a id="function-function-miniquake-filesystem-loadtempfile-function-loadtempfile-system-name-src-miniquake-filesystem-ml-278190483"></a>
### loadTempFile

```ml
function loadTempFile(system, name)
```

Read and validate temp file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadTempFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L446)

<a id="function-function-miniquake-filesystem-loadzoneallocation-function-loadzoneallocation-system-memorystate-name-src-miniquake-filesystem-ml-1401041613"></a>
### loadZoneAllocation

```ml
function loadZoneAllocation(system, memoryState, name)
```

Read and validate zone allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `loadZoneAllocation`. |
| `memoryState` | `dynamic` | — | Mutable state used by `loadZoneAllocation`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L508)

<a id="function-function-miniquake-filesystem-musictrackname-function-musictrackname-track-src-miniquake-filesystem-ml-1831354268"></a>
### musicTrackName

```ml
function musicTrackName(track)
```

Return music track name derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `track` | `dynamic` | — | The track input consumed by `musicTrackName`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L621)

<a id="function-function-miniquake-filesystem-musictrackpath-function-musictrackpath-system-track-src-miniquake-filesystem-ml-1607811569"></a>
### musicTrackPath

```ml
function musicTrackPath(system, track)
```

Return music track path derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `musicTrackPath`. |
| `track` | `dynamic` | — | The track input consumed by `musicTrackPath`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L652)

<a id="function-function-miniquake-filesystem-normalizename-function-normalizename-name-src-miniquake-filesystem-ml-1226516964"></a>
### normalizeName

```ml
function normalizeName(name)
```

Convert name into its canonical representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L47)

<a id="function-function-miniquake-filesystem-openfile-function-openfile-system-name-src-miniquake-filesystem-ml-551041175"></a>
### openFile

```ml
function openFile(system, name)
```

Initialize state for open file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `openFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L374)

<a id="function-function-miniquake-filesystem-packfilecount-function-packfilecount-system-src-miniquake-filesystem-ml-1929039098"></a>
### packFileCount

```ml
function packFileCount(system)
```

Return pack file count derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `packFileCount`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L752)

<a id="function-function-miniquake-filesystem-pathcommandtext-function-pathcommandtext-system-src-miniquake-filesystem-ml-2084466228"></a>
### pathCommandText

```ml
function pathCommandText(system)
```

Return path command text for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `pathCommandText`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L704)

<a id="function-function-miniquake-filesystem-readfile-function-readfile-system-name-src-miniquake-filesystem-ml-1259010295"></a>
### readFile

```ml
function readFile(system, name)
```

Read and validate file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `readFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L347)

<a id="function-function-miniquake-filesystem-readloosemusictrack-function-readloosemusictrack-directory-filename-src-miniquake-filesystem-ml-769810375"></a>
### readLooseMusicTrack

```ml
function readLooseMusicTrack(directory, filename)
```

Read and validate loose music track.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `directory` | `dynamic` | — | The directory input consumed by `readLooseMusicTrack`. |
| `filename` | `dynamic` | — | Path of the file to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L630)

<a id="function-function-miniquake-filesystem-readmusictrack-function-readmusictrack-system-track-src-miniquake-filesystem-ml-1229674457"></a>
### readMusicTrack

```ml
function readMusicTrack(system, track)
```

Read and validate music track.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `readMusicTrack`. |
| `track` | `dynamic` | — | The track input consumed by `readMusicTrack`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L671)

<a id="function-function-miniquake-filesystem-readtext-function-readtext-system-name-src-miniquake-filesystem-ml-595771487"></a>
### readText

```ml
function readText(system, name)
```

Reads text for `miniquake.filesystem`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `readText`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L356)

<a id="function-function-miniquake-filesystem-registeredwords-function-registeredwords-src-miniquake-filesystem-ml-1642941295"></a>
### registeredWords

```ml
function registeredWords()
```

Registers ed words for `miniquake.filesystem`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L196)

<a id="function-function-miniquake-filesystem-release-function-release-system-src-miniquake-filesystem-ml-24858712"></a>
### release

```ml
function release(system)
```

Release or remove state for the requested value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `release`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L736)

<a id="function-function-miniquake-filesystem-rereleasemusicdirectory-function-rereleasemusicdirectory-system-gamedirectory-src-miniquake-filesystem-ml-1271948451"></a>
### rereleaseMusicDirectory

```ml
function rereleaseMusicDirectory(system, gameDirectory)
```

Implements the `rereleaseMusicDirectory` operation for `miniquake.filesystem` (rerelease music directory).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `rereleaseMusicDirectory`. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L639)

<a id="function-function-miniquake-filesystem-resolve-function-resolve-system-name-src-miniquake-filesystem-ml-745143559"></a>
### resolve

```ml
function resolve(system, name)
```

Implements the `resolve` operation for `miniquake.filesystem` (resolve).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `resolve`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L308)

<a id="function-function-miniquake-filesystem-searchpathsummary-function-searchpathsummary-system-src-miniquake-filesystem-ml-1350325076"></a>
### searchPathSummary

```ml
function searchPathSummary(system)
```

Return search path summary derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `searchPathSummary`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L718)

<a id="function-function-miniquake-filesystem-standard-function-standard-basedirectory-gamename-src-miniquake-filesystem-ml-2057884686"></a>
### standard

```ml
function standard(baseDirectory, gameName)
```

Implements the `standard` operation for `miniquake.filesystem` (standard).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameName` | `dynamic` | — | Name that identifies the requested value or resource. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L97)

<a id="function-function-miniquake-filesystem-trimtrailingseparator-function-trimtrailingseparator-path-src-miniquake-filesystem-ml-641128186"></a>
### trimTrailingSeparator

```ml
function trimTrailingSeparator(path)
```

Implements the `trimTrailingSeparator` operation for `miniquake.filesystem` (trim trailing separator).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Filesystem path to process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L117)

<a id="function-function-miniquake-filesystem-writebytes-function-writebytes-system-name-data-src-miniquake-filesystem-ml-1979038219"></a>
### writeBytes

```ml
function writeBytes(system, name, data)
```

Writes bytes for `miniquake.filesystem`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `writeBytes`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L605)

<a id="function-function-miniquake-filesystem-writefile-function-writefile-system-name-data-src-miniquake-filesystem-ml-1809097985"></a>
### writeFile

```ml
function writeFile(system, name, data)
```

Encode and write file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `writeFile`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `data` | `dynamic` | — | Input data consumed by the operation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L597)

<a id="function-function-miniquake-filesystem-writetext-function-writetext-system-name-text-src-miniquake-filesystem-ml-645835794"></a>
### writeText

```ml
function writeText(system, name, text)
```

Writes text for `miniquake.filesystem`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `system` | `dynamic` | — | The system input consumed by `writeText`. |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |
| `text` | `dynamic` | — | Text to parse or process. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/filesystem.ml#L613)
