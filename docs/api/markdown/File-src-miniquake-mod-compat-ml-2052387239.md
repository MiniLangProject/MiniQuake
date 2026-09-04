# `src/miniquake/mod_compat.ml`

[Home](README.md) · [Files](Files.md)

Package: [`miniquake.mod_compat`](Package-miniquake-mod-compat-654411312.md)

Reachable from entry: **no**

## Imports

- `miniquake/common.ml` as `common` → [src/miniquake/common.ml](File-src-miniquake-common-ml-466436205.md)
- `miniquake/filesystem.ml` as `qfs` → [src/miniquake/filesystem.ml](File-src-miniquake-filesystem-ml-1964591079.md)
- `miniquake/format/bsp.ml` as `bsp` → [src/miniquake/format/bsp.ml](File-src-miniquake-format-bsp-ml-22292029.md)
- `miniquake/format/progs.ml` as `progs` → [src/miniquake/format/progs.ml](File-src-miniquake-format-progs-ml-1508573313.md)
- `miniquake/game_profile.ml` as `profile` → [src/miniquake/game_profile.ml](File-src-miniquake-game-profile-ml-1658088642.md)
- `std/fs.ml` as `fs` → `../MiniLangCompilerOptimization/MiniLangCompilerPy/std/fs.ml` — external dependency

## Declarations

<a id="function-function-miniquake-mod-compat-candidatedirectories-function-candidatedirectories-basedirectory-src-miniquake-mod-compat-ml-990558321"></a>
### candidateDirectories

```ml
function candidateDirectories(baseDirectory)
```

Report whether candidate directories.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L35)

<a id="constant-constant-miniquake-mod-compat-contract-text-const-contract-text-mod-runtime-progs-v6-bsp-v29-id1-required-rogue-optional-hipnotic-optional-integrated-host-src-miniquake-mod-compat-ml-2097283058"></a>
### CONTRACT_TEXT

```ml
const CONTRACT_TEXT = "mod-runtime|progs-v6|bsp-v29|id1-required|rogue-optional|hipnotic-optional|integrated-host"
```

Defines the contract text value used by `miniquake.mod_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L24)

<a id="function-function-miniquake-mod-compat-contractvector-inline-function-contractvector-src-miniquake-mod-compat-ml-858284262"></a>
### contractVector

```ml
inline function contractVector()
```

Implements the `contractVector` operation for `miniquake.mod_compat` (contract vector).


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L96)

<a id="function-function-miniquake-mod-compat-directorypresent-function-directorypresent-basedirectory-gamedirectory-src-miniquake-mod-compat-ml-1739771194"></a>
### directoryPresent

```ml
function directoryPresent(baseDirectory, gameDirectory)
```

Implements the `directoryPresent` operation for `miniquake.mod_compat` (directory present).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L29)

<a id="constant-constant-miniquake-mod-compat-fingerprint-const-fingerprint-1179222333-src-miniquake-mod-compat-ml-447929797"></a>
### FINGERPRINT

```ml
const FINGERPRINT = 1179222333
```

Defines the fingerprint value used by `miniquake.mod_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L22)

<a id="function-function-miniquake-mod-compat-inspect-function-inspect-basedirectory-gamedirectory-mapname-src-miniquake-mod-compat-ml-1525617299"></a>
### inspect

```ml
function inspect(baseDirectory, gameDirectory, mapName)
```

Implements the `inspect` operation for `miniquake.mod_compat` (inspect).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |
| `mapName` | `dynamic` | — | Name of the map to load or inspect. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L56)

<a id="function-function-miniquake-mod-compat-profilearguments-function-profilearguments-basedirectory-gamedirectory-src-miniquake-mod-compat-ml-1620069518"></a>
### profileArguments

```ml
function profileArguments(baseDirectory, gameDirectory)
```

Implements the `profileArguments` operation for `miniquake.mod_compat` (profile arguments).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `baseDirectory` | `dynamic` | — | Root directory containing the Quake installation. |
| `gameDirectory` | `dynamic` | — | Selected Quake game-data directory. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L45)

<a id="constant-constant-miniquake-mod-compat-status-const-status-mod-runtime-109-frozen-v1-src-miniquake-mod-compat-ml-27664823"></a>
### STATUS

```ml
const STATUS = "mod_runtime_109_frozen_v1"
```

Defines the status value used by `miniquake.mod_compat`.


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L20)

<a id="function-function-miniquake-mod-compat-validsummary-function-validsummary-summary-src-miniquake-mod-compat-ml-1565102937"></a>
### validSummary

```ml
function validSummary(summary)
```

Report whether valid summary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `summary` | `dynamic` | — | The summary input consumed by `validSummary`. |


[View source](https://github.com/MiniLangProject/MiniQuake/blob/main/src/miniquake/mod_compat.ml#L90)
