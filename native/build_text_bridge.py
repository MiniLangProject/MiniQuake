#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Build the small Win64 caller-owned text bridge without Windows SDK headers."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess


def run(command: list[str], cwd: Path) -> None:
    """Run one text-bridge build command and propagate tool failures."""
    print("+", " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def find_msvc_tools() -> tuple[str, str, str] | None:
    """Locate a complete x64 MSVC compiler, linker and librarian toolchain."""
    roots: list[Path] = []
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
    """Parse build options and compile the caller-owned Win64 text bridge."""
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
    build = root / "text_build"
    if args.clean and build.exists():
        shutil.rmtree(build)
    build.mkdir(parents=True, exist_ok=True)

    clang_cl = shutil.which(args.clang_cl or "clang-cl")
    lld_link = shutil.which(args.lld_link or "lld-link")
    use_msvc = not (clang_cl and lld_link)
    if use_msvc:
        tools = find_msvc_tools()
        if args.cl and args.link and args.lib:
            tools = (args.cl, args.link, args.lib)
        if tools is None:
            raise SystemExit("required tool not found: clang-cl/lld-link or x64 MSVC cl/link/lib")
        compiler, linker, librarian = tools
        print(f"using MSVC fallback: {compiler}")
    else:
        compiler, linker, librarian = str(clang_cl), str(lld_link), str(lld_link)

    kernel_def = build / "kernel32.def"
    kernel_lib = build / "kernel32.lib"
    kernel_def.write_text(
        "LIBRARY kernel32.dll\nEXPORTS\n"
        "  GetModuleHandleW\n"
        "  LoadLibraryW\n"
        "  GetProcAddress\n",
        encoding="utf-8",
    )
    library_command = [librarian, "/machine:x64", f"/def:{kernel_def}", f"/out:{kernel_lib}"]
    if not use_msvc:
        library_command.insert(1, "/lib")
    run(library_command, build)

    source = root / "miniquake_text.c"
    obj = build / "miniquake_text.obj"
    output = root / "miniquake_text.dll"
    import_library = build / "miniquake_text.lib"
    run(
        [
            compiler,
            "/nologo",
            "/c",
            "/W4",
            "/GS-",
            "/Zl",
            "/Od" if args.debug else "/O2",
            f"/Fo{obj}",
            str(source),
        ],
        root,
    )
    link_flags = [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/subsystem:windows,6.0",
            "/nodefaultlib",
            "/dynamicbase",
            "/nxcompat",
            "/Brepro",
            "/opt:ref",
            "/opt:icf",
            f"/def:{root / 'miniquake_text.def'}",
            f"/out:{output}",
            f"/implib:{import_library}",
            str(obj),
            str(kernel_lib),
    ]
    # lld-link supports deterministic PE timestamps directly. MSVC /Brepro
    # already provides reproducible output and rejects the lld-only spelling.
    if not use_msvc:
        link_flags.insert(6, "/timestamp:0")
    run(link_flags, root)
    print(f"built {output} ({output.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
