# Native bridge guide

MiniQuake keeps game and engine behavior in MiniLang. The native Windows x64
layer exposes only functionality that cannot be expressed efficiently or
directly through the current MiniLang runtime.

## Components

### `miniquake_native.dll`

The main bridge provides:

- Win32 window, display, timing, input, controller, and gamma integration;
- OpenGL 1.1, Direct3D 9, and Vulkan renderer entry points;
- `waveOut` audio submission and device state;
- Winsock UDP and address helpers;
- OGG decoding through the vendored `stb_vorbis` implementation; and
- a small set of ABI-safe math and memory helpers.

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

### `miniquake_text.dll`

The text bridge copies native NUL-terminated strings into MiniLang-owned byte
buffers. This avoids returning high-address native string pointers through a
MiniLang Win64 ABI path that is reliable for `bytes` but not for direct `cstr`
results.

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

Mouse capture recenters the cursor and discards the first relative sample after
a capture or focus transition. The `waveOut` submission path checks every ring
header so a busy slot cannot hide another completed slot. These platform rules
keep input and playback stable without moving game-facing behavior into C.

## Source documentation

Native files carry SPDX license identifiers, provenance, and function-level
documentation. Verify the maintained source set with:

```powershell
python .\tools\check_source_documentation.py --root .
```
