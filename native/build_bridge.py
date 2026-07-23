#!/usr/bin/env python3
"""Build the self-contained MiniQuake Win64 platform/OpenGL bridge.

The source deliberately avoids Windows SDK headers.  This script also creates
minimal COFF import libraries from module-definition files, so clang-cl and
lld-link are sufficient on Windows, Linux, or macOS hosts.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import shutil
import subprocess
import sys


IMPORTS: dict[str, list[str]] = {
    "kernel32.dll": ["GetModuleHandleW", "GetTickCount", "Sleep"],
    "user32.dll": [
        "RegisterClassExW", "UnregisterClassW", "CreateWindowExW", "DestroyWindow",
        "DefWindowProcW", "PostQuitMessage", "PeekMessageW", "TranslateMessage",
        "DispatchMessageW", "ShowWindow", "UpdateWindow", "SetWindowTextW",
        "GetSystemMetrics", "AdjustWindowRectEx", "GetClientRect", "GetAsyncKeyState",
        "GetForegroundWindow", "GetCursorPos", "SetCursorPos", "ClientToScreen",
        "ShowCursor", "LoadCursorW", "LoadIconW", "GetDC", "ReleaseDC",
    ],
    "gdi32.dll": ["ChoosePixelFormat", "SetPixelFormat", "SwapBuffers"],
    "winmm.dll": [
        "waveOutOpen", "waveOutPrepareHeader", "waveOutUnprepareHeader",
        "waveOutWrite", "waveOutReset", "waveOutClose",
    ],
    "ws2_32.dll": [
        "WSAStartup", "WSACleanup", "WSAGetLastError", "socket", "closesocket",
        "ioctlsocket", "bind", "getsockname", "sendto", "recvfrom",
        "htons", "ntohs", "inet_addr",
    ],
    "msvcrt.dll": ["strtod", "sprintf", "memset", "sin", "cos", "sqrt", "sqrtf", "atan2"],
    "opengl32.dll": [
        "wglCreateContext", "wglDeleteContext", "wglMakeCurrent", "glBegin", "glEnd",
        "glVertex2f", "glVertex3f", "glTexCoord2f", "glColor4ub", "glClearColor",
        "glClear", "glEnable", "glDisable", "glBlendFunc", "glDepthFunc", "glDepthMask", "glDepthRange",
        "glAlphaFunc", "glCullFace", "glShadeModel", "glPolygonMode", "glViewport",
        "glMatrixMode", "glLoadIdentity", "glPushMatrix", "glPopMatrix", "glTranslatef",
        "glRotatef", "glScalef", "glOrtho", "glFrustum", "glBindTexture", "glGenTextures",
        "glDeleteTextures", "glTexParameteri", "glTexImage2D", "glTexSubImage2D",
        "glReadPixels", "glGetString", "glGetError", "glFinish", "glFlush",
    ],
}


def run(command: list[str], cwd: Path) -> None:
    print("+", " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def find_tool(explicit: str | None, name: str) -> str:
    if explicit:
        path = shutil.which(explicit) or explicit
    else:
        path = shutil.which(name)
    if not path:
        raise SystemExit(f"required tool not found: {name}")
    return str(path)


def write_import_library(lld_link: str, build: Path, dll: str, symbols: list[str]) -> Path:
    stem = dll.rsplit(".", 1)[0]
    definition = build / f"{stem}.def"
    library = build / f"{stem}.lib"
    definition.write_text(
        f"LIBRARY {dll}\nEXPORTS\n" + "".join(f"  {symbol}\n" for symbol in symbols),
        encoding="utf-8",
    )
    run([lld_link, "/lib", "/machine:x64", f"/def:{definition}", f"/out:{library}"], build)
    return library


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--clean", action="store_true")
    parser.add_argument("--clang-cl")
    parser.add_argument("--lld-link")
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent
    build = root / "build"
    if args.clean and build.exists():
        shutil.rmtree(build)
    build.mkdir(parents=True, exist_ok=True)

    clang_cl = find_tool(args.clang_cl, "clang-cl")
    lld_link = find_tool(args.lld_link, "lld-link")

    libraries = [write_import_library(lld_link, build, dll, symbols) for dll, symbols in IMPORTS.items()]
    source = root / "miniquake_native.c"
    obj = build / "miniquake_native.obj"
    output = root / "miniquake_native.dll"
    import_library = build / "miniquake_native.lib"

    compile_flags = [
        clang_cl, "/nologo", "/c", "/W4", "/GS-", "/Zl", "/fp:precise",
        "/Od" if args.debug else "/O2", f"/Fo{obj}", str(source),
    ]
    run(compile_flags, root)

    link_flags = [
        lld_link, "/dll", "/noentry", "/machine:x64", "/subsystem:windows,6.0",
        "/nodefaultlib", "/dynamicbase", "/nxcompat", "/opt:ref", "/opt:icf",
        f"/def:{root / 'miniquake_native.def'}", f"/out:{output}",
        f"/implib:{import_library}", str(obj), *(str(path) for path in libraries),
    ]
    run(link_flags, root)
    print(f"built {output} ({output.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
