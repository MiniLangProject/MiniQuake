# Native bridge guide

MiniQuake keeps game and engine behavior in MiniLang. The native Windows and
Linux x64 layers expose only functionality that cannot be expressed efficiently
or directly through the current MiniLang runtime.

## Components

### Main native bridge

The main bridge provides:

- Win32/WGL or SDL2 window, display, timing, input, controller, and gamma
  integration;
- OpenGL 1.1, Direct3D 9, and Vulkan renderer entry points, including the
  optional shared per-pixel dynamic-light shader bridge;
- `waveOut` or SDL2 audio submission and device state;
- Winsock or POSIX UDP and address helpers;
- OGG decoding through the vendored `stb_vorbis` implementation; and
- a small set of ABI-safe math and memory helpers.

The Windows artifact is `miniquake_native.dll`; the Linux artifact is
`libminiquake_native.so`. Linux uses SDL2 queued audio and POSIX UDP while
Windows retains `waveOut` and Winsock. OpenGL is supported on both systems;
Direct3D 9 and the current Vulkan bridge remain Windows-specific.

IEEE-754 single-precision values cross the MiniLang/native boundary as their
32-bit bit patterns. `mq_f32_from_ml_raw` and `mq_f32_to_ml_raw` are the
canonical conversion path.

Rebuild the DLL with:

```powershell
python .\native\build_bridge.py --clean
```

The builder prefers `clang-cl` and `lld-link` and can use an installed x64 MSVC
toolchain. Renderer SDK interfaces are either part of Windows or vendored in
`third_party` as documented by their respective license files.

Build the Linux ELF executable and both shared libraries with:

```bash
./scripts/build_linux.sh --compiler /path/to/MiniLangCompilerPy/mlc_win64.py
```

### Buffered text bridge

The text bridge copies native NUL-terminated strings into MiniLang-owned byte
buffers. This avoids returning high-address native string pointers through a
MiniLang native ABI path that is reliable for `bytes` but not for direct
`cstr` results. Its artifacts are `miniquake_text.dll` and
`libminiquake_text.so`.

It is used for float formatting, ASCII conversion, console-process exchange,
UDP and host names, and OpenGL string queries. Rebuild it independently with:

```powershell
python .\native\build_text_bridge.py --clean
```

The bridge requires `clang-cl` and `lld-link` and links reproducibly with
`/Brepro`.

## Ownership rules

- MiniLang owns all buffers passed to the text bridge.
- Native code copies at most the caller-provided capacity and reports the byte
  count separately.
- Native handles are opaque to MiniLang and must be released through their
  matching bridge function.
- Mixer scheduling, channel policy, QuakeC, networking policy, and renderer
  scene construction remain in MiniLang.

## Input and audio stability

Windows mouse capture recenters the cursor and discards the first relative
sample after a capture or focus transition. SDL relative mode already supplies
unbounded deltas on Linux, so its bridge deliberately avoids synthetic cursor
warps while captured. The `waveOut` submission path checks every ring header so
a busy slot cannot hide another completed slot; SDL audio enforces the same
bounded queue contract. These platform rules keep input and playback stable
without moving game-facing behavior into C.

## Source documentation

Native files carry SPDX license identifiers, provenance, and function-level
documentation. Verify the maintained source set with:

```powershell
python .\tools\check_source_documentation.py --root .
```
