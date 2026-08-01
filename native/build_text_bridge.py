#!/usr/bin/env python3
"""Build the small Win64 caller-owned text bridge without Windows SDK headers."""
from __future__ import annotations

import argparse
from pathlib import Path
import shutil
import subprocess


def run(command: list[str], cwd: Path) -> None:
    print("+", " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--clean", action="store_true")
    parser.add_argument("--clang-cl")
    parser.add_argument("--lld-link")
    parser.add_argument("--debug", action="store_true")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent
    build = root / "text_build"
    if args.clean and build.exists():
        shutil.rmtree(build)
    build.mkdir(parents=True, exist_ok=True)

    compiler = shutil.which(args.clang_cl or "clang-cl")
    linker = shutil.which(args.lld_link or "lld-link")
    if not compiler or not linker:
        raise SystemExit("required tools not found: clang-cl and lld-link")

    kernel_def = build / "kernel32.def"
    kernel_lib = build / "kernel32.lib"
    kernel_def.write_text(
        "LIBRARY kernel32.dll\nEXPORTS\n"
        "  GetModuleHandleW\n"
        "  LoadLibraryW\n"
        "  GetProcAddress\n",
        encoding="utf-8",
    )
    run([linker, "/lib", "/machine:x64", f"/def:{kernel_def}", f"/out:{kernel_lib}"], build)

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
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/subsystem:windows,6.0",
            "/nodefaultlib",
            "/timestamp:0",
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
        ],
        root,
    )
    print(f"built {output} ({output.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
