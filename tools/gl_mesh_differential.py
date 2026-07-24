#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/gl_mesh.c."""

from __future__ import annotations

import argparse
import ctypes
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
PINNED_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
REFERENCE = ROOT / "reference" / "quake"
PATCH = ROOT / "reference" / "patches" / "gl_mesh_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "gl_mesh_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "gl_mesh_oracle.def"
FIXTURE = ROOT / "tests" / "gl_mesh_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "gl_mesh_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"


def load_build_bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("miniquake_build_bridge", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, cwd: Path = ROOT, capture: bool = False) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout if result.stdout is not None else ""


def verify_reference() -> None:
    run([sys.executable, str(VERIFY_REFERENCE), "--quiet"])


def build_oracle(output: Path) -> Path:
    tools = load_build_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    if not msvcrt.exists():
        raise RuntimeError(
            "native/build/msvcrt.lib is missing; run native/build_bridge.py first"
        )
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(
            [
                "git",
                "-C",
                str(REFERENCE),
                "worktree",
                "remove",
                "--force",
                str(worktree),
            ]
        )
    run(
        [
            "git",
            "-C",
            str(REFERENCE),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PINNED_COMMIT,
        ]
    )
    run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "gl_mesh_pinned.obj"
    driver_obj = output / "gl_mesh_pinned_driver.obj"
    dll = output / "gl_mesh_oracle.dll"
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
        "/wd4101",
        "/wd4102",
        "/wd4244",
        "/GS-",
        "/Zl",
        "/fp:precise",
        "/O2",
        "/Gy",
        "/DMINIQUAKE_PINNED_ORACLE",
        f"/I{STUB_INCLUDE}",
    ]
    run(
        common
        + [
            f"/Fo{source_obj}",
            str(worktree / "WinQuake" / "gl_mesh.c"),
        ]
    )
    run(common + [f"/Fo{driver_obj}", str(DRIVER)])
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/nodefaultlib",
            "/dynamicbase",
            "/nxcompat",
            "/opt:ref",
            f"/def:{DEFINITION}",
            f"/out:{dll}",
            str(source_obj),
            str(driver_obj),
            str(msvcrt),
        ]
    )
    return dll


def configure(library: ctypes.WinDLL) -> None:
    library.mesh_setup_strip.argtypes = []
    library.mesh_setup_fan.argtypes = []
    library.mesh_make_display_lists.argtypes = []
    library.mesh_strip_vertex.argtypes = [ctypes.c_int]
    library.mesh_strip_vertex.restype = ctypes.c_int
    library.mesh_strip_triangle.argtypes = [ctypes.c_int]
    library.mesh_strip_triangle.restype = ctypes.c_int
    library.mesh_num_commands.argtypes = []
    library.mesh_num_commands.restype = ctypes.c_int
    library.mesh_num_order.argtypes = []
    library.mesh_num_order.restype = ctypes.c_int
    library.mesh_command_int.argtypes = [ctypes.c_int]
    library.mesh_command_int.restype = ctypes.c_int
    library.mesh_command_float.argtypes = [ctypes.c_int]
    library.mesh_command_float.restype = ctypes.c_float
    library.mesh_order.argtypes = [ctypes.c_int]
    library.mesh_order.restype = ctypes.c_int
    library.mesh_header_poseverts.argtypes = []
    library.mesh_header_poseverts.restype = ctypes.c_int
    library.mesh_header_commands_nonzero.argtypes = []
    library.mesh_header_commands_nonzero.restype = ctypes.c_int
    library.mesh_header_posedata_nonzero.argtypes = []
    library.mesh_header_posedata_nonzero.restype = ctypes.c_int
    library.StripLength.argtypes = [ctypes.c_int, ctypes.c_int]
    library.StripLength.restype = ctypes.c_int
    library.FanLength.argtypes = [ctypes.c_int, ctypes.c_int]
    library.FanLength.restype = ctypes.c_int
    library.BuildTris.argtypes = []


def strip_event(
    library: ctypes.WinDLL, function: str, count: int
) -> dict[str, object]:
    return {
        "function": function,
        "case": "chain",
        "count": count,
        "vertices": [
            library.mesh_strip_vertex(index) for index in range(count + 2)
        ],
        "triangles": [
            library.mesh_strip_triangle(index) for index in range(count)
        ],
    }


def build_event(library: ctypes.WinDLL, function: str, case: str) -> dict[str, object]:
    count = library.mesh_command_int(0)
    vertex_count = abs(count)
    last_word = 1 + (vertex_count - 1) * 2
    return {
        "function": function,
        "case": case,
        "numcommands": library.mesh_num_commands(),
        "numorder": library.mesh_num_order(),
        "count": count,
        "first": [
            library.mesh_command_float(1),
            library.mesh_command_float(2),
        ],
        "last": [
            library.mesh_command_float(last_word),
            library.mesh_command_float(last_word + 1),
        ],
        "order": [
            library.mesh_order(index)
            for index in range(library.mesh_num_order())
        ],
    }


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    events: list[dict[str, object]] = []

    library.mesh_setup_strip()
    events.append(strip_event(library, "StripLength", library.StripLength(0, 0)))

    library.mesh_setup_fan()
    events.append(strip_event(library, "FanLength", library.FanLength(0, 0)))

    library.mesh_setup_strip()
    library.BuildTris()
    events.append(build_event(library, "BuildTris", "strip"))

    library.mesh_setup_strip()
    library.mesh_make_display_lists()
    display = build_event(
        library, "GL_MakeAliasModelDisplayLists", "build"
    )
    display["poseverts"] = library.mesh_header_poseverts()
    display["commands"] = library.mesh_header_commands_nonzero()
    display["posedata"] = library.mesh_header_posedata_nonzero()
    events.append(display)

    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(
    compiler: Path, output: Path, destination: Path
) -> None:
    executable = output / "gl_mesh_minilang.exe"
    shutil.copy2(
        ROOT / "native" / "miniquake_native.dll",
        output / "miniquake_native.dll",
    )
    run(
        [
            sys.executable,
            str(compiler),
            str(FIXTURE),
            str(executable),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "40",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    destination.write_text(
        run([str(executable)], capture=True),
        encoding="utf-8",
        newline="\n",
    )


def validate_manifest(reference: Path) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    events = [
        json.loads(line)
        for line in reference.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if len(events) != manifest["events"]:
        raise RuntimeError(
            f"manifest expects {manifest['events']} events, observed {len(events)}"
        )
    observed = {event["function"] for event in events}
    expected = {
        item["name"]
        for item in manifest["functions"]
        if item["classification"] == "reference-differential"
    }
    if expected - observed:
        raise RuntimeError(
            f"manifest functions lack events: {sorted(expected - observed)}"
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build" / "gl_mesh_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    verify_reference()
    run_oracle(build_oracle(args.output), reference)
    build_and_run_minilang(args.compiler.resolve(), args.output, candidate)
    validate_manifest(reference)
    run(
        [
            sys.executable,
            str(ROOT / "tools" / "parity_oracle.py"),
            "compare-traces",
            str(reference),
            str(candidate),
            "--epsilon",
            "1e-5",
        ]
    )
    verify_reference()
    print("gl_mesh differential: PASS (4 JSONL events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
