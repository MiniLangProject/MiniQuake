# MiniQuake on Linux

MiniQuake supports Linux x86-64 through the MiniLang compiler's `linux-x64`
target. The Linux runtime uses SDL2 for windows, input, controllers and queued
audio, desktop OpenGL for rendering, POSIX sockets for Protocol 15 UDP, and
POSIX file services. Game rules and engine behavior remain in the shared
MiniLang implementation.

## Runtime requirements

The prebuilt Linux package requires a glibc-based x86-64 distribution, SDL2,
and an OpenGL implementation. Debian and Ubuntu provide the required runtime
libraries with:

```bash
sudo apt install libsdl2-2.0-0 libgl1
```

Building from source additionally requires Python 3 and GCC:

```bash
sudo apt install python3 gcc
```

The package deliberately does not bundle system graphics or audio libraries.
Use `ldd MiniQuake libminiquake_native.so libminiquake_text.so` to diagnose a
missing distribution dependency.

## Running a release

Extract the Linux archive, enter its directory and invoke the launcher rather
than the ELF executable directly:

```bash
tar -xzf MiniQuake-linux-x86_64.tar.gz
cd MiniQuake-linux-x86_64
./run-miniquake --play "$HOME/.local/share/Steam/steamapps/common/Quake"
```

The launcher makes the two private shared libraries available through a local
`LD_LIBRARY_PATH` without installing them globally. Supply `-game hipnotic` or
`-game rogue` for an installed mission pack. Original command-line forms such
as `-basedir`, `-window`, `-fullscreen`, `-width`, `-height`, `+map` and
`-dedicated` remain available.

Only OpenGL is exposed on Linux. Direct3D 9 and the current Vulkan bridge use
Windows-specific APIs and are omitted from Linux renderer selection. OpenGL
still supports MiniQuake's enhanced lighting, projected shadows, texture
scaling, model interpolation and anisotropic filtering.

## Building from source

From the repository root:

```bash
./scripts/build_linux.sh \
  --compiler ../MiniLangCompilerPy/mlc_win64.py \
  --stdlib ../MiniLangCompilerPy
```

The compiler must support `--target linux-x64`. The script can discover a
suitable sibling Python compiler automatically. `MINILANG_COMPILER`,
`MINILANG_STDLIB` and `PYTHON` provide equivalent environment overrides. Build
products are written to `build/linux`.

Run all Linux-specific checks, optionally including legally installed retail
data, with:

```bash
./scripts/test_linux.sh --quake-base /path/to/Quake
```

The suite covers the native ABI, executable identity, deterministic CRC, UDP
loopback, an SDL/OpenGL pixel readback, E1M1 runtime state, OGG decoding,
dedicated-server startup, audio-enabled rendering, and both windowed and
fullscreen presentation.

## WSLg acceleration

WSLg may expose a valid compatibility OpenGL context through Mesa's CPU-only
`llvmpipe` driver even when `/dev/dxg` GPU passthrough is available. This is
correct but unnecessarily slow for MiniQuake. The generated launcher detects
WSL, selects Mesa's accelerated D3D12 Gallium driver, and prefers an available
NVIDIA adapter. On other Linux systems it does not alter driver selection.

Explicit user settings always win. To choose another WSL adapter or diagnose a
driver, set the standard Mesa variables before starting MiniQuake:

```bash
MESA_D3D12_DEFAULT_ADAPTER_NAME=AMD ./run-miniquake --play /path/to/Quake
LIBGL_ALWAYS_SOFTWARE=1 ./run-miniquake --gl-smoke-frames 10
```

The OpenGL smoke test prints the selected vendor, renderer and version. A
hardware-accelerated WSL session normally reports `D3D12 (...)`; `llvmpipe`
means rendering is occurring on the CPU.

## Dedicated server

The same ELF can run without a graphical window:

```bash
./run-miniquake -basedir /path/to/Quake -game id1 \
  -dedicated 8 +map e1m1
```

MiniQuake uses the original default UDP port 26000 unless command-line or
console configuration selects another port. Host firewalls must allow the
chosen UDP port for LAN or Internet clients.

## Troubleshooting

- `gfx/palette.lmp not found` means the supplied base directory does not
  contain `id1/pak0.pak` or was split incorrectly by shell quoting.
- A loader error for `libminiquake_native.so` usually means the executable was
  started directly. Use `run-miniquake` from the extracted package.
- `llvmpipe` under WSL indicates software rendering. Confirm `/dev/dxg` exists,
  update the Windows display driver and WSL, then rerun the OpenGL smoke test.
- Missing music is diagnosed with `musicinfo` or `cd info` in the console.
  Track files are read from the documented `music/trackNN.ogg` locations.
- A compositor may implement exclusive fullscreen as borderless desktop
  fullscreen. MiniQuake accepts that presentation and uses the current desktop
  mode when a bare `-fullscreen` request has no separate enumerated mode.

Never copy proprietary Quake PAK or soundtrack files into a MiniQuake release
archive or the source repository.
