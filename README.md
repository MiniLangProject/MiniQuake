# MiniQuake

MiniQuake is an unofficial Windows x64 port of the original GLQuake/WinQuake
1.09 engine to [MiniLang](https://github.com/MiniLangProject). The project aims
to preserve Quake's observable behavior, data formats, QuakeC semantics, and
Protocol 15 while providing a smooth modern desktop experience.

> [!IMPORTANT]
> MiniQuake does not include Quake game data. You must own and supply a legal
> Quake installation containing `id1/pak0.pak`.

## Screenshots

| Attract mode and main menu | E1M1 gameplay |
| --- | --- |
| ![The MiniQuake main menu over an original attract-mode demo](docs/screenshots/menu-demo.png) | ![MiniQuake running E1M1](docs/screenshots/e1m1-gameplay.png) |

![The scaled in-game console](docs/screenshots/console.png)

## Highlights

- Engine and game-facing behavior implemented in MiniLang.
- Windows x64 platform bridges for Win32, audio, UDP, input, codecs, and GPU
  APIs.
- Original Quake formats including PAK, WAD, BSP29, MDL6, SPR1, `progs.dat`
  v6, DEM, SAV, and Protocol 15.
- Single-player, listen-server, dedicated-server, demo, savegame, console,
  menu, HUD, and QuakeC runtime paths.
- Selectable OpenGL 1.1, Direct3D 9, and Vulkan renderers.
- Resolution-aware classic UI, windowed/fullscreen switching, mouse input,
  controller support, and archived settings in `config.cfg`.
- OGG soundtrack playback through the original CD-track command model.
- Compatibility targets for Quake, *Scourge of Armagon*, and *Dissolution of
  Eternity* within the original engine and Protocol 15 limits.

## Project status

MiniQuake is playable and under active development. The repository has broad
source and subsystem coverage, plus deterministic tests for engine contracts,
but it should not yet be treated as a defect-free replacement for every Quake
mod or hardware configuration. Retail map traversal, renderer comparisons,
network interoperability, and long-running soak tests remain important release
gates.

See [the current port status](docs/status/PORT_STATUS.md) for the maintained
summary. Historical implementation and acceptance records are retained under
[`docs/archive`](docs/archive/README.md).

## Quick start

Build MiniQuake, then point it at the directory that contains `id1`:

```powershell
$QuakeBase = "C:\Program Files (x86)\Steam\steamapps\common\Quake"
& .\build\MiniQuake.exe --play $QuakeBase
```

With only the directory argument, MiniQuake executes the original `quake.rc`
startup sequence, opens the main menu, and runs Quake's attract demos behind
it. A map may be supplied explicitly when a direct start is preferred:

```powershell
& .\build\MiniQuake.exe --play $QuakeBase e1m1
```

The expanded command-line form is also supported:

```powershell
& .\build\MiniQuake.exe `
  -basedir $QuakeBase `
  -game id1 `
  -window `
  -width 1280 `
  -height 720 `
  -renderer opengl `
  +map start
```

Use `-game hipnotic` or `-game rogue` for the official mission packs when
their data is installed below the Quake directory.

## Building

Requirements:

- Windows x64 and PowerShell.
- Python 3.
- The Python MiniLang compiler and standard library. A sibling checkout named
  `MiniLangCompilerPy` is detected automatically, or paths can be supplied
  explicitly.
- A Windows C/C++ toolchain only when rebuilding the native DLLs.

From the repository root:

```powershell
.\build.ps1
```

Explicit compiler paths:

```powershell
.\build.ps1 `
  -Compiler C:\path\to\MiniLangCompilerPy\mlc_win64.py `
  -StdLib C:\path\to\MiniLangCompilerPy
```

The release executable is written to `build/MiniQuake.exe`. Useful build
switches include `-Configuration Debug`, `-SkipTests`, `-NetworkTests`, and
`-RebuildNative`. Run `Get-Help .\build.ps1 -Detailed` or inspect the script's
parameter block for the complete build interface.

## Default controls

| Action | Default input |
| --- | --- |
| Move | `W`, `A`, `S`, `D` or arrow keys |
| Look | Mouse |
| Attack | Left mouse button or `Ctrl` |
| Jump | `Space` or right mouse button |
| Run | `Shift` |
| Select weapon | `1` through `8` |
| Main menu | `Esc` |
| Console | `` ` `` |

Bindings can be changed through **Options > Customize Controls** or with the
original `bind` console command.

## Rendering and display

Choose a renderer from **Options > Video Mode** or on the command line:

```powershell
-renderer opengl
-renderer direct3d9
-renderer vulkan
```

The aliases `-opengl`, `-directx`, `-d3d9`, and `-vulkan` are accepted. Display
mode, resolution, renderer, and other archived settings are written to
`config.cfg`. The console commands `vid_renderer` and `vid_restart` provide the
same renderer selection without editing the configuration file manually.

OpenGL remains the compatibility fallback. Direct3D 9 uses the Windows runtime,
and Vulkan is loaded dynamically from `vulkan-1.dll` when available.

## Music

Physical CD playback is replaced by OGG streaming. MiniQuake maps Quake's
original track numbers to `trackNN.ogg` and searches these locations:

```text
<Quake>/<game>/music/trackNN.ogg
<Quake>/rerelease/<game>/music/trackNN.ogg
<Quake>/rerelease/id1/music/trackNN.ogg
```

The Steam rerelease layout is therefore detected automatically. Use `cd info`
or `musicinfo` in the console to diagnose soundtrack discovery and playback.

## Tests and verification

The normal build compiles and runs the asset-free test suite. The top-level
test wrapper executes the current acceptance package:

```powershell
.\scripts\test.ps1 -QuakeBase $QuakeBase
```

Retail validation requires locally installed game data:

```powershell
.\scripts\validate_real_game.ps1 -QuakeBase $QuakeBase
```

Source integrity, documentation coverage, and MiniLang syntax can be checked
independently:

```powershell
python .\tools\verify.py --root .
python .\tools\check_source_documentation.py --root .
python .\tools\check_minilang_delimiters.py --root .
```

After an intentional repository change, maintainers can refresh the integrity
manifest with `python .\tools\verify.py --root . --refresh-manifest`.

## Repository layout

| Path | Purpose |
| --- | --- |
| `src/` | MiniLang engine, client, server, renderer, audio, and platform logic |
| `native/` | Narrow Windows x64 native bridges and renderer backends |
| `tests/` | Deterministic, differential, and retail test programs |
| `tools/` | Verification, comparison, build, and evidence utilities |
| `scripts/` | Maintainer and retail-validation workflows |
| `docs/` | Current documentation and historical acceptance records |
| `audit/` | Machine-readable compatibility and performance evidence |
| `patches/` | Historical delivery evidence retained for legacy verification |

## Legal and licensing

MiniQuake is an independent project and is not affiliated with or endorsed by
id Software or Bethesda Softworks. Quake names and game assets remain the
property of their respective owners. Do not commit or redistribute proprietary
PAK files, maps, music, or other retail data with this repository.

Quake-derived engine work is distributed under GPL-2.0-or-later; see
[`COPYING`](COPYING). Independently authored platform and build components may
carry Apache-2.0 notices; see [`LICENSES/Apache-2.0.txt`](LICENSES/Apache-2.0.txt)
and each file's SPDX identifier. Third-party components retain their own
licenses.
