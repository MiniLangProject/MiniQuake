#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Build the self-contained MiniQuake Win64 platform/OpenGL bridge.

The source deliberately avoids Windows SDK headers.  This script also creates
minimal COFF import libraries from module-definition files.  It prefers
clang-cl/lld-link and falls back to an installed x64 MSVC cl/link/lib toolset.
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys


IMPORTS: dict[str, list[str]] = {
    "kernel32.dll": [
        "GetModuleHandleW", "GetCurrentProcess", "GetProcessHandleCount",
        "GetTickCount", "Sleep", "__chkstk",
        "CreateEventW", "SetEvent", "CloseHandle", "WaitForMultipleObjects",
        "MapViewOfFile", "UnmapViewOfFile", "GetStdHandle",
        "GetConsoleScreenBufferInfo", "GetLargestConsoleWindowSize",
        "SetConsoleWindowInfo", "SetConsoleScreenBufferSize",
        "ReadConsoleOutputCharacterA", "WriteConsoleInputA",
        "QueryPerformanceCounter", "QueryPerformanceFrequency", "VirtualProtect",
        "GetNumberOfConsoleInputEvents", "ReadConsoleInputA",
        "GetFileType", "PeekNamedPipe", "ReadFile", "WriteFile",
        "CreateFileW", "GetFileSizeEx", "VirtualAlloc", "VirtualFree",
        "LoadLibraryA", "GetProcAddress", "FreeLibrary",
        "AllocConsole", "FreeConsole",
    ],
    "user32.dll": [
        "RegisterClassExW", "UnregisterClassW", "CreateWindowExW", "DestroyWindow",
        "DefWindowProcW", "PostQuitMessage", "PeekMessageW", "TranslateMessage",
        "DispatchMessageW", "ShowWindow", "UpdateWindow", "SetWindowTextW", "SetWindowPos", "SetWindowLongPtrW",
        "GetSystemMetrics", "AdjustWindowRectEx", "GetClientRect", "GetAsyncKeyState",
        "GetForegroundWindow", "GetCursorPos", "SetCursorPos", "ClientToScreen",
        "ShowCursor", "LoadCursorW", "LoadIconW", "LoadImageW", "GetDC", "ReleaseDC",
        "SetCapture", "ReleaseCapture", "ClipCursor", "EnumDisplaySettingsW",
        "RegisterRawInputDevices", "GetRawInputData",
        "ChangeDisplaySettingsW", "IsIconic", "SetForegroundWindow",
        "MessageBoxW", "MsgWaitForMultipleObjects",
    ],
    "gdi32.dll": [
        "ChoosePixelFormat", "SetPixelFormat", "SwapBuffers",
        "GetDeviceGammaRamp", "SetDeviceGammaRamp",
    ],
    "winmm.dll": [
        "waveOutOpen", "waveOutPrepareHeader", "waveOutUnprepareHeader",
        "waveOutWrite", "waveOutReset", "waveOutClose", "waveOutGetPosition",
        "joyGetNumDevs", "joyGetPosEx", "joyGetDevCapsW",
    ],
    "ws2_32.dll": [
        "WSAStartup", "WSACleanup", "WSAGetLastError", "socket", "closesocket",
        "ioctlsocket", "bind", "getsockname", "setsockopt", "sendto", "recvfrom",
        "htons", "ntohs", "inet_addr", "gethostname", "gethostbyname", "gethostbyaddr",
    ],
    "msvcrt.dll": [
        "strtod", "sprintf", "memcpy", "memset", "qsort", "sin", "cos",
        "sqrt", "sqrtf", "atan2", "exp", "log", "pow", "floor", "ldexp",
    ],
    "opengl32.dll": [
        "wglCreateContext", "wglDeleteContext", "wglMakeCurrent", "wglGetProcAddress", "glBegin", "glEnd",
        "glVertex2f", "glVertex3f", "glTexCoord2f", "glColor4ub", "glClearColor",
        "glClear", "glEnable", "glDisable", "glBlendFunc", "glDepthFunc", "glDepthMask", "glDepthRange",
        "glAlphaFunc", "glCullFace", "glShadeModel", "glPolygonMode", "glViewport",
        "glMatrixMode", "glLoadIdentity", "glPushMatrix", "glPopMatrix", "glTranslatef",
        "glRotatef", "glScalef", "glOrtho", "glFrustum", "glBindTexture", "glGenTextures",
        "glDeleteTextures", "glGenLists", "glNewList", "glEndList", "glCallList", "glCallLists", "glDeleteLists",
        "glInterleavedArrays", "glDrawArrays", "glVertexPointer", "glTexCoordPointer",
        "glEnableClientState", "glDisableClientState",
        "glTexParameteri", "glTexImage2D", "glTexSubImage2D",
        "glTexEnvi", "glReadPixels", "glGetFloatv", "glGetString", "glGetError", "glFinish", "glFlush", "glDrawBuffer",
    ],
    "d3d9.dll": [
        "Direct3DCreate9",
        "Direct3DCreate9Ex",
    ],
}


def run(command: list[str], cwd: Path) -> None:
    """Run one build command and fail immediately if the tool reports an error."""
    print("+", " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def find_tool(explicit: str | None, name: str) -> str:
    """Resolve an explicitly configured tool or locate it on PATH."""
    if explicit:
        path = shutil.which(explicit) or explicit
    else:
        path = shutil.which(name)
    if not path:
        raise SystemExit(f"required tool not found: {name}")
    return str(path)


def write_import_library(librarian: str, build: Path, dll: str, symbols: list[str], msvc: bool) -> Path:
    """Generate a minimal x64 COFF import library for the requested DLL exports."""
    stem = dll.rsplit(".", 1)[0]
    definition = build / f"{stem}.def"
    library = build / f"{stem}.lib"
    definition.write_text(
        f"LIBRARY {dll}\nEXPORTS\n" + "".join(f"  {symbol}\n" for symbol in symbols),
        encoding="utf-8",
    )
    command = [librarian, "/machine:x64", f"/def:{definition}", f"/out:{library}"]
    if not msvc:
        command.insert(1, "/lib")
    run(command, build)
    return library


def find_msvc_tools() -> tuple[str, str, str] | None:
    """Locate a complete x64 MSVC compiler, linker and librarian toolchain."""
    roots = []
    for variable in ("ProgramFiles", "ProgramFiles(x86)"):
        value = os.environ.get(variable)
        if value:
            roots.append(Path(value) / "Microsoft Visual Studio")
    candidates: list[Path] = []
    for root in roots:
        if root.exists():
            candidates.extend(root.glob("*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe"))
    if not candidates:
        return None
    compiler = sorted(candidates)[-1]
    directory = compiler.parent
    linker = directory / "link.exe"
    librarian = directory / "lib.exe"
    if not linker.exists() or not librarian.exists():
        return None
    return str(compiler), str(linker), str(librarian)


def main() -> int:
    """Parse build options and compile the complete native MiniQuake bridge."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--clean", action="store_true")
    parser.add_argument("--clang-cl")
    parser.add_argument("--lld-link")
    parser.add_argument("--cl")
    parser.add_argument("--link")
    parser.add_argument("--lib")
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent
    build = root / "build"
    if args.clean and build.exists():
        shutil.rmtree(build)
    build.mkdir(parents=True, exist_ok=True)

    clang_cl = shutil.which(args.clang_cl or "clang-cl")
    lld_link = shutil.which(args.lld_link or "lld-link")
    use_msvc = not (clang_cl and lld_link)
    if use_msvc:
        tools = find_msvc_tools()
        if args.cl and args.link and args.lib:
            tools = (
                find_tool(args.cl, "cl"),
                find_tool(args.link, "link"),
                find_tool(args.lib, "lib"),
            )
        if tools is None:
            raise SystemExit("required tool not found: clang-cl/lld-link or x64 MSVC cl/link/lib")
        compiler, linker, librarian = tools
        print(f"using MSVC fallback: {compiler}")
    else:
        compiler, linker, librarian = str(clang_cl), str(lld_link), str(lld_link)

    libraries = [
        write_import_library(librarian, build, dll, symbols, use_msvc)
        for dll, symbols in IMPORTS.items()
    ]
    source = root / "miniquake_native.c"
    obj = build / "miniquake_native.obj"
    ogg_source = root / "miniquake_ogg.c"
    ogg_obj = build / "miniquake_ogg.obj"
    d3d_source = root / "miniquake_d3d9.c"
    d3d_obj = build / "miniquake_d3d9.obj"
    vulkan_source = root / "miniquake_vulkan.c"
    vulkan_obj = build / "miniquake_vulkan.obj"
    output = root / "miniquake_native.dll"
    import_library = build / "miniquake_native.lib"

    compile_flags = [
        compiler, "/nologo", "/c", "/W4", "/GS-", "/Zl", "/fp:precise",
        "/Od" if args.debug else "/O2", f"/Fo{obj}", str(source),
    ]
    run(compile_flags, root)
    ogg_flags = [
        compiler, "/nologo", "/c", "/W3", "/GS-", "/Gs9999999", "/Zl", "/fp:precise",
        "/Od" if args.debug else "/O2", f"/I{root / 'compat'}",
        f"/Fo{ogg_obj}", str(ogg_source),
    ]
    run(ogg_flags, root)
    d3d_flags = [
        compiler, "/nologo", "/c", "/W4", "/GS-", "/Zl", "/fp:precise",
        "/Od" if args.debug else "/O2", f"/Fo{d3d_obj}", str(d3d_source),
    ]
    run(d3d_flags, root)
    vulkan_flags = [
        compiler, "/nologo", "/c", "/W4", "/GS-", "/Zl", "/fp:precise",
        "/Od" if args.debug else "/O2",
        f"/I{root.parent / 'third_party' / 'Vulkan-Headers' / 'include'}",
        f"/Fo{vulkan_obj}", str(vulkan_source),
    ]
    run(vulkan_flags, root)
    link_flags = [
        linker, "/dll", "/noentry", "/machine:x64", "/subsystem:windows,6.0",
        "/nodefaultlib", "/dynamicbase", "/nxcompat", "/Brepro", "/opt:ref", "/opt:icf",
        f"/def:{root / 'miniquake_native.def'}", f"/out:{output}",
        f"/implib:{import_library}", str(obj), str(ogg_obj), str(d3d_obj), str(vulkan_obj), *(str(path) for path in libraries),
    ]
    run(link_flags, root)
    print(f"built {output} ({output.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
