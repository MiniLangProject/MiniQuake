# `src/miniquake/game_profile.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.game_profile`](Package-miniquake-game-profile-952522315.md)

Reachable from entry: **no**

## Imports

- `miniquake/byteio.ml` as `bio` → [src/miniquake/byteio.ml](File-src-miniquake-byteio-ml-1921171264.md)
- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)

## Declarations

<a id="constant-constant-miniquake-game-profile-contract-text-const-contract-text-game-profile-id1-first-rogue-before-hipnotic-explicit-game-last-path-overrides-registered-gate-caching-once-src-miniquake-game-profile-ml-496189570"></a>
### CONTRACT_TEXT

```ml
const CONTRACT_TEXT = "game-profile|id1-first|rogue-before-hipnotic|explicit-game-last|path-overrides|registered-gate|caching-once"
```

Defines the contract text value used by `miniquake.game_profile`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L20)

<a id="function-function-miniquake-game-profile-effectivegamedirectory-function-effectivegamedirectory-commandline-src-miniquake-game-profile-ml-1404048426"></a>
### effectiveGameDirectory

```ml
function effectiveGameDirectory(commandLine)
```

Implements the `effectiveGameDirectory` operation for `miniquake.game_profile` (effective game directory).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `effectiveGameDirectory`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L37)

<a id="function-function-miniquake-game-profile-expectedsearchdirectorynames-function-expectedsearchdirectorynames-commandline-src-miniquake-game-profile-ml-1483960126"></a>
### expectedSearchDirectoryNames

```ml
function expectedSearchDirectoryNames(commandLine)
```

Return expected search directory names derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `expectedSearchDirectoryNames`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L87)

<a id="function-function-miniquake-game-profile-explicitgame-function-explicitgame-commandline-src-miniquake-game-profile-ml-702154978"></a>
### explicitGame

```ml
function explicitGame(commandLine)
```

Implements the `explicitGame` operation for `miniquake.game_profile` (explicit game).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `explicitGame`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L62)

<a id="constant-constant-miniquake-game-profile-fingerprint-const-fingerprint-2047063693-src-miniquake-game-profile-ml-1222089838"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 2047063693
```

Defines the fingerprint value used by `miniquake.game_profile`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L18)

<a id="function-function-miniquake-game-profile-ismissionpack-function-ismissionpack-name-src-miniquake-game-profile-ml-1495492506"></a>
### isMissionPack

```ml
function isMissionPack(name)
```

Report whether is mission pack.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Stable name that identifies the requested object or option. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L44)

<a id="function-function-miniquake-game-profile-missionmode-function-missionmode-commandline-src-miniquake-game-profile-ml-775274688"></a>
### missionMode

```ml
function missionMode(commandLine)
```

Return mission mode derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `missionMode`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L51)

<a id="function-function-miniquake-game-profile-pathoverride-function-pathoverride-commandline-src-miniquake-game-profile-ml-1667082918"></a>
### pathOverride

```ml
function pathOverride(commandLine)
```

Return path override for the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `pathOverride`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L70)

<a id="function-function-miniquake-game-profile-profilevector-function-profilevector-commandline-src-miniquake-game-profile-ml-1001007302"></a>
### profileVector

```ml
function profileVector(commandLine)
```

Return profile vector derived from the active module state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `profileVector`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L109)

<a id="function-function-miniquake-game-profile-requesteddirectories-function-requesteddirectories-commandline-src-miniquake-game-profile-ml-1219882710"></a>
### requestedDirectories

```ml
function requestedDirectories(commandLine)
```

Implements the `requestedDirectories` operation for `miniquake.game_profile` (requested directories).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commandLine` | `dynamic` | — | The command line input consumed by `requestedDirectories`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L24)

<a id="constant-constant-miniquake-game-profile-status-const-status-game-profile-109-frozen-v1-src-miniquake-game-profile-ml-856279434"></a>
### STATUS

```ml
const STATUS = "game_profile_109_frozen_v1"
```

Defines the status value used by `miniquake.game_profile`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/game_profile.ml#L16)
