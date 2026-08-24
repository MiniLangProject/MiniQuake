# MiniQuake

<p align="center">
  <img src="icons/MiniQuake.png" width="240" alt="MiniQuake application icon">
</p>

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

### Complete level gallery

The gallery covers all 73 playable maps shipped with the original game and
the two official mission packs supported by MiniQuake. Every image was rendered
by MiniQuake at 1920x1080 with HQ2x texture scaling, enhanced lighting, and
high-quality shadows. The JPEG previews are progressive and open at full
resolution when clicked. Captures use each map's authored spawn viewpoint.

<details>
<summary><strong>Quake — 38 maps</strong></summary>

| | | |
| --- | --- | --- |
| **START**<br>[![START](docs/screenshots/levels/start.jpg)](docs/screenshots/levels/start.jpg) | **E1M1**<br>[![E1M1](docs/screenshots/levels/e1m1.jpg)](docs/screenshots/levels/e1m1.jpg) | **E1M2**<br>[![E1M2](docs/screenshots/levels/e1m2.jpg)](docs/screenshots/levels/e1m2.jpg) |
| **E1M3**<br>[![E1M3](docs/screenshots/levels/e1m3.jpg)](docs/screenshots/levels/e1m3.jpg) | **E1M4**<br>[![E1M4](docs/screenshots/levels/e1m4.jpg)](docs/screenshots/levels/e1m4.jpg) | **E1M5**<br>[![E1M5](docs/screenshots/levels/e1m5.jpg)](docs/screenshots/levels/e1m5.jpg) |
| **E1M6**<br>[![E1M6](docs/screenshots/levels/e1m6.jpg)](docs/screenshots/levels/e1m6.jpg) | **E1M7**<br>[![E1M7](docs/screenshots/levels/e1m7.jpg)](docs/screenshots/levels/e1m7.jpg) | **E1M8**<br>[![E1M8](docs/screenshots/levels/e1m8.jpg)](docs/screenshots/levels/e1m8.jpg) |
| **E2M1**<br>[![E2M1](docs/screenshots/levels/e2m1.jpg)](docs/screenshots/levels/e2m1.jpg) | **E2M2**<br>[![E2M2](docs/screenshots/levels/e2m2.jpg)](docs/screenshots/levels/e2m2.jpg) | **E2M3**<br>[![E2M3](docs/screenshots/levels/e2m3.jpg)](docs/screenshots/levels/e2m3.jpg) |
| **E2M4**<br>[![E2M4](docs/screenshots/levels/e2m4.jpg)](docs/screenshots/levels/e2m4.jpg) | **E2M5**<br>[![E2M5](docs/screenshots/levels/e2m5.jpg)](docs/screenshots/levels/e2m5.jpg) | **E2M6**<br>[![E2M6](docs/screenshots/levels/e2m6.jpg)](docs/screenshots/levels/e2m6.jpg) |
| **E2M7**<br>[![E2M7](docs/screenshots/levels/e2m7.jpg)](docs/screenshots/levels/e2m7.jpg) | **E3M1**<br>[![E3M1](docs/screenshots/levels/e3m1.jpg)](docs/screenshots/levels/e3m1.jpg) | **E3M2**<br>[![E3M2](docs/screenshots/levels/e3m2.jpg)](docs/screenshots/levels/e3m2.jpg) |
| **E3M3**<br>[![E3M3](docs/screenshots/levels/e3m3.jpg)](docs/screenshots/levels/e3m3.jpg) | **E3M4**<br>[![E3M4](docs/screenshots/levels/e3m4.jpg)](docs/screenshots/levels/e3m4.jpg) | **E3M5**<br>[![E3M5](docs/screenshots/levels/e3m5.jpg)](docs/screenshots/levels/e3m5.jpg) |
| **E3M6**<br>[![E3M6](docs/screenshots/levels/e3m6.jpg)](docs/screenshots/levels/e3m6.jpg) | **E3M7**<br>[![E3M7](docs/screenshots/levels/e3m7.jpg)](docs/screenshots/levels/e3m7.jpg) | **E4M1**<br>[![E4M1](docs/screenshots/levels/e4m1.jpg)](docs/screenshots/levels/e4m1.jpg) |
| **E4M2**<br>[![E4M2](docs/screenshots/levels/e4m2.jpg)](docs/screenshots/levels/e4m2.jpg) | **E4M3**<br>[![E4M3](docs/screenshots/levels/e4m3.jpg)](docs/screenshots/levels/e4m3.jpg) | **E4M4**<br>[![E4M4](docs/screenshots/levels/e4m4.jpg)](docs/screenshots/levels/e4m4.jpg) |
| **E4M5**<br>[![E4M5](docs/screenshots/levels/e4m5.jpg)](docs/screenshots/levels/e4m5.jpg) | **E4M6**<br>[![E4M6](docs/screenshots/levels/e4m6.jpg)](docs/screenshots/levels/e4m6.jpg) | **E4M7**<br>[![E4M7](docs/screenshots/levels/e4m7.jpg)](docs/screenshots/levels/e4m7.jpg) |
| **E4M8**<br>[![E4M8](docs/screenshots/levels/e4m8.jpg)](docs/screenshots/levels/e4m8.jpg) | **END**<br>[![END](docs/screenshots/levels/end.jpg)](docs/screenshots/levels/end.jpg) | **DM1**<br>[![DM1](docs/screenshots/levels/dm1.jpg)](docs/screenshots/levels/dm1.jpg) |
| **DM2**<br>[![DM2](docs/screenshots/levels/dm2.jpg)](docs/screenshots/levels/dm2.jpg) | **DM3**<br>[![DM3](docs/screenshots/levels/dm3.jpg)](docs/screenshots/levels/dm3.jpg) | **DM4**<br>[![DM4](docs/screenshots/levels/dm4.jpg)](docs/screenshots/levels/dm4.jpg) |
| **DM5**<br>[![DM5](docs/screenshots/levels/dm5.jpg)](docs/screenshots/levels/dm5.jpg) | **DM6**<br>[![DM6](docs/screenshots/levels/dm6.jpg)](docs/screenshots/levels/dm6.jpg) | |

</details>

<details>
<summary><strong>Scourge of Armagon — 18 maps</strong></summary>

| | | |
| --- | --- | --- |
| **START**<br>[![Scourge of Armagon START](docs/screenshots/levels/hipnotic-start.jpg)](docs/screenshots/levels/hipnotic-start.jpg) | **HIP1M1**<br>[![HIP1M1](docs/screenshots/levels/hipnotic-hip1m1.jpg)](docs/screenshots/levels/hipnotic-hip1m1.jpg) | **HIP1M2**<br>[![HIP1M2](docs/screenshots/levels/hipnotic-hip1m2.jpg)](docs/screenshots/levels/hipnotic-hip1m2.jpg) |
| **HIP1M3**<br>[![HIP1M3](docs/screenshots/levels/hipnotic-hip1m3.jpg)](docs/screenshots/levels/hipnotic-hip1m3.jpg) | **HIP1M4**<br>[![HIP1M4](docs/screenshots/levels/hipnotic-hip1m4.jpg)](docs/screenshots/levels/hipnotic-hip1m4.jpg) | **HIP1M5**<br>[![HIP1M5](docs/screenshots/levels/hipnotic-hip1m5.jpg)](docs/screenshots/levels/hipnotic-hip1m5.jpg) |
| **HIP2M1**<br>[![HIP2M1](docs/screenshots/levels/hipnotic-hip2m1.jpg)](docs/screenshots/levels/hipnotic-hip2m1.jpg) | **HIP2M2**<br>[![HIP2M2](docs/screenshots/levels/hipnotic-hip2m2.jpg)](docs/screenshots/levels/hipnotic-hip2m2.jpg) | **HIP2M3**<br>[![HIP2M3](docs/screenshots/levels/hipnotic-hip2m3.jpg)](docs/screenshots/levels/hipnotic-hip2m3.jpg) |
| **HIP2M4**<br>[![HIP2M4](docs/screenshots/levels/hipnotic-hip2m4.jpg)](docs/screenshots/levels/hipnotic-hip2m4.jpg) | **HIP2M5**<br>[![HIP2M5](docs/screenshots/levels/hipnotic-hip2m5.jpg)](docs/screenshots/levels/hipnotic-hip2m5.jpg) | **HIP2M6**<br>[![HIP2M6](docs/screenshots/levels/hipnotic-hip2m6.jpg)](docs/screenshots/levels/hipnotic-hip2m6.jpg) |
| **HIP3M1**<br>[![HIP3M1](docs/screenshots/levels/hipnotic-hip3m1.jpg)](docs/screenshots/levels/hipnotic-hip3m1.jpg) | **HIP3M2**<br>[![HIP3M2](docs/screenshots/levels/hipnotic-hip3m2.jpg)](docs/screenshots/levels/hipnotic-hip3m2.jpg) | **HIP3M3**<br>[![HIP3M3](docs/screenshots/levels/hipnotic-hip3m3.jpg)](docs/screenshots/levels/hipnotic-hip3m3.jpg) |
| **HIP3M4**<br>[![HIP3M4](docs/screenshots/levels/hipnotic-hip3m4.jpg)](docs/screenshots/levels/hipnotic-hip3m4.jpg) | **HIPEND**<br>[![HIPEND](docs/screenshots/levels/hipnotic-hipend.jpg)](docs/screenshots/levels/hipnotic-hipend.jpg) | **HIPDM1**<br>[![HIPDM1](docs/screenshots/levels/hipnotic-hipdm1.jpg)](docs/screenshots/levels/hipnotic-hipdm1.jpg) |

</details>

<details>
<summary><strong>Dissolution of Eternity — 17 maps</strong></summary>

| | | |
| --- | --- | --- |
| **START**<br>[![Dissolution of Eternity START](docs/screenshots/levels/rogue-start.jpg)](docs/screenshots/levels/rogue-start.jpg) | **R1M1**<br>[![R1M1](docs/screenshots/levels/rogue-r1m1.jpg)](docs/screenshots/levels/rogue-r1m1.jpg) | **R1M2**<br>[![R1M2](docs/screenshots/levels/rogue-r1m2.jpg)](docs/screenshots/levels/rogue-r1m2.jpg) |
| **R1M3**<br>[![R1M3](docs/screenshots/levels/rogue-r1m3.jpg)](docs/screenshots/levels/rogue-r1m3.jpg) | **R1M4**<br>[![R1M4](docs/screenshots/levels/rogue-r1m4.jpg)](docs/screenshots/levels/rogue-r1m4.jpg) | **R1M5**<br>[![R1M5](docs/screenshots/levels/rogue-r1m5.jpg)](docs/screenshots/levels/rogue-r1m5.jpg) |
| **R1M6**<br>[![R1M6](docs/screenshots/levels/rogue-r1m6.jpg)](docs/screenshots/levels/rogue-r1m6.jpg) | **R1M7**<br>[![R1M7](docs/screenshots/levels/rogue-r1m7.jpg)](docs/screenshots/levels/rogue-r1m7.jpg) | **R2M1**<br>[![R2M1](docs/screenshots/levels/rogue-r2m1.jpg)](docs/screenshots/levels/rogue-r2m1.jpg) |
| **R2M2**<br>[![R2M2](docs/screenshots/levels/rogue-r2m2.jpg)](docs/screenshots/levels/rogue-r2m2.jpg) | **R2M3**<br>[![R2M3](docs/screenshots/levels/rogue-r2m3.jpg)](docs/screenshots/levels/rogue-r2m3.jpg) | **R2M4**<br>[![R2M4](docs/screenshots/levels/rogue-r2m4.jpg)](docs/screenshots/levels/rogue-r2m4.jpg) |
| **R2M5**<br>[![R2M5](docs/screenshots/levels/rogue-r2m5.jpg)](docs/screenshots/levels/rogue-r2m5.jpg) | **R2M6**<br>[![R2M6](docs/screenshots/levels/rogue-r2m6.jpg)](docs/screenshots/levels/rogue-r2m6.jpg) | **R2M7**<br>[![R2M7](docs/screenshots/levels/rogue-r2m7.jpg)](docs/screenshots/levels/rogue-r2m7.jpg) |
| **R2M8**<br>[![R2M8](docs/screenshots/levels/rogue-r2m8.jpg)](docs/screenshots/levels/rogue-r2m8.jpg) | **CTF1**<br>[![CTF1](docs/screenshots/levels/rogue-ctf1.jpg)](docs/screenshots/levels/rogue-ctf1.jpg) | |

</details>

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

Prebuilt Windows x64 packages are published on the
[GitHub Releases page](https://github.com/MiniLangProject/MiniQuake/releases).
Release archives contain the engine executable and its native runtime bridges,
but never include proprietary Quake game data.

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

The release executable is written to `build/MiniQuake.exe`. The build compiles
the repository-local MiniLang icon injector and embeds the multi-resolution
`icons/MiniQuake.ico` automatically. Useful build switches include
`-Configuration Debug`, `-SkipTests`, `-NetworkTests`, `-RebuildNative`, and
`-SkipIcon`. Run `Get-Help .\build.ps1 -Detailed` or inspect the script's
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
original `bind` console command. Persistent free-look is enabled by default;
mouse sensitivity and vertical-axis inversion are available directly in the
Options menu. The archived `freelook` cvar can restore classic hold-to-look
behavior when set to `0`.

## Cheats

Single-player games and privileged multiplayer clients support the original
commands `god`, `notarget`, `noclip`, `fly`, and `give <item> <value>`.
The stock QuakeC cheats such as `impulse 9` (all weapons) are also supported.
MiniQuake additionally provides `invisible`, which toggles AI invisibility:
standard monsters stop targeting the player and cannot acquire the player
again until the command is disabled. The player model remains rendered.
Enter `cheats` or `cheatcodes` in the console to display the complete in-game
cheat reference, including command syntax.

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

The **Lighting** entry in **Options > Video Mode** switches between the original
GLQuake-compatible presentation and MiniQuake's optional enhanced lighting on
all three backends. Enhanced lighting adds per-pixel Protocol-15 dynamic lights
while retaining Quake's original lightmaps and art direction. It also enables
soft, camera-facing particles and automatically uses standard QLIT v1
`maps/<name>.lit` sidecars when a selected game or mod supplies them. Invalid or
mismatched sidecars are ignored safely. Water retains Quake's canonical sine
warp but interpolates between table entries to avoid visible stepping. **Shadows** are
independent of that lighting choice: opaque enemies, pickups, crates, doors,
platforms, and other modelled objects cast geometry-projected shadows whenever
the option is enabled. **Shadow Quality** selects low, medium, or high filtering.
Classic lighting remains the compatibility fallback; set Shadows to Off as well
for the unextended GLQuake presentation.

**Model Smoothing** interpolates animated alias-model poses, removing the
characteristic low-frame-rate stepping from monsters, weapons, and projectiles
without changing QuakeC timing or collision. **Texture Filter** selects 1x, 2x,
4x, 8x, or 16x anisotropic filtering for mipmapped 3-D textures. Unsupported
levels are clamped by the active OpenGL, Direct3D 9, or Vulkan device.

**Texture Scale** optionally enlarges world, model, sprite, sky, and translated
player textures when they are loaded. Available modes are Off, Nearest 2x,
Scale2x, Scale3x, HQ2x, xBR2x, and xBR4x. The preprocessing is shared by all
three renderers; HUD, menu/font art, lightmaps, and particle textures retain
their original sizing. Changing the option rebuilds graphics resources without
restarting the game and stores the choice in `config.cfg`.

The corresponding archived console variables are:

```text
r_lighting 0       // 0 = classic, 1 = enhanced
r_shadows 1        // 0 = disabled, 1 = enabled
r_shadowquality 1  // 0 = low, 1 = medium, 2 = high
r_modelinterpolate 1 // 0 = original stepped poses, 1 = smooth poses
r_anisotropy 4       // 1, 2, 4, 8, or 16; hardware-clamped
r_coloredlightmaps 1 // use matching QLIT v1 sidecars in enhanced mode
r_textureupscale 0 // 0=off, 1=nearest2x, 2=Scale2x, 3=Scale3x,
                   // 4=HQ2x, 5=xBR2x, 6=xBR4x
```

Changes made in the menu are stored in `config.cfg`. If a backend cannot create
its enhanced shader pipeline, MiniQuake keeps rendering through its classic
path instead of making the game unavailable.

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

The complete acceptance suite now has one entry point:

```powershell
.\scripts\test.ps1
```

With no arguments it detects the standard Steam Quake installation, rebuilds
the native bridges, runs every source/preflight and compiled MiniLang test,
exercises UDP loopback and an independent two-process handshake, and performs
asset, runtime, render and renderer-switch validation for every installed
official game (`id1`, `hipnotic` and `rogue`). It also runs the retail-only
QuakeC, movement, cheat, Chthon, telefrag, audio, save and demo evidence gates.

Use an explicit installation when Quake is elsewhere, or set the persistent
`MINIQUAKE_QUAKE_BASE` environment variable:

```powershell
.\scripts\test.ps1 -QuakeBase $QuakeBase
```

Focused retail validation without the full source suite remains available:

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
