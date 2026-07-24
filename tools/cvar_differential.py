#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/cvar.c."""

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
PATCH = ROOT / "reference" / "patches" / "cvar_pinned_oracle.patch"
STUB_INCLUDE = ROOT / "reference" / "harness"
DRIVER = ROOT / "reference" / "harness" / "cvar_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "cvar_oracle.def"
FIXTURE = ROOT / "tests" / "cvar_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "cvar_differential_manifest.json"


class Cvar(ctypes.Structure):
    pass


Cvar._fields_ = [
    ("name", ctypes.c_char_p),
    ("string", ctypes.c_char_p),
    ("archive", ctypes.c_int),
    ("server", ctypes.c_int),
    ("value", ctypes.c_float),
    ("next", ctypes.POINTER(Cvar)),
]


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
                str(ROOT / "reference" / "quake"),
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
            str(ROOT / "reference" / "quake"),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PINNED_COMMIT,
        ]
    )
    run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "cvar_pinned.obj"
    driver_obj = output / "cvar_pinned_driver.obj"
    dll = output / "cvar_oracle.dll"
    common = [
        compiler,
        "/nologo",
        "/c",
        "/W4",
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
            str(worktree / "WinQuake" / "cvar.c"),
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
    library.Cvar_FindVar.argtypes = [ctypes.c_char_p]
    library.Cvar_FindVar.restype = ctypes.POINTER(Cvar)
    library.Cvar_VariableValue.argtypes = [ctypes.c_char_p]
    library.Cvar_VariableValue.restype = ctypes.c_float
    library.Cvar_VariableString.argtypes = [ctypes.c_char_p]
    library.Cvar_VariableString.restype = ctypes.c_char_p
    library.Cvar_CompleteVariable.argtypes = [ctypes.c_char_p]
    library.Cvar_CompleteVariable.restype = ctypes.c_char_p
    library.Cvar_Set.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
    library.Cvar_SetValue.argtypes = [ctypes.c_char_p, ctypes.c_float]
    library.Cvar_Command.argtypes = []
    library.Cvar_Command.restype = ctypes.c_int
    library.cvar_fixture_register.argtypes = []
    library.cvar_set_command.argtypes = [
        ctypes.c_int,
        ctypes.c_char_p,
        ctypes.c_char_p,
    ]
    library.cvar_broadcast_calls.argtypes = []
    library.cvar_broadcast_calls.restype = ctypes.c_int
    library.cvar_archive.argtypes = []
    library.cvar_archive.restype = ctypes.c_char_p


def text(value: bytes | None) -> str:
    return "" if value is None else value.decode("ascii")


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    events: list[dict[str, object]] = []
    library.cvar_fixture_register()
    events.append(
        {
            "function": "Cvar_RegisterVariable",
            "case": "three",
            "count": 3,
            "values": [
                float(library.Cvar_VariableValue(b"foo")),
                float(library.Cvar_VariableValue(b"bar")),
                float(library.Cvar_VariableValue(b"alpha")),
            ],
        }
    )
    found = library.Cvar_FindVar(b"foo")
    missing = library.Cvar_FindVar(b"missing")
    events.append(
        {
            "function": "Cvar_FindVar",
            "case": "found-missing",
            "found": text(found.contents.name),
            "missing": 0 if bool(missing) else 1,
        }
    )
    events.append(
        {
            "function": "Cvar_VariableValue",
            "case": "found-missing",
            "values": [
                float(library.Cvar_VariableValue(b"foo")),
                float(library.Cvar_VariableValue(b"missing")),
            ],
        }
    )
    events.append(
        {
            "function": "Cvar_VariableString",
            "case": "found-missing",
            "values": [
                text(library.Cvar_VariableString(b"foo")),
                text(library.Cvar_VariableString(b"missing")),
            ],
        }
    )
    events.append(
        {
            "function": "Cvar_CompleteVariable",
            "case": "prefix",
            "value": text(library.Cvar_CompleteVariable(b"al")),
            "empty": 1 if library.Cvar_CompleteVariable(b"") is None else 0,
        }
    )
    library.Cvar_Set(b"bar", b"9.5")
    events.append(
        {
            "function": "Cvar_Set",
            "case": "server",
            "value": float(library.Cvar_VariableValue(b"bar")),
            "string": text(library.Cvar_VariableString(b"bar")),
            "broadcast": library.cvar_broadcast_calls(),
        }
    )
    library.Cvar_SetValue(b"foo", ctypes.c_float(2.5))
    events.append(
        {
            "function": "Cvar_SetValue",
            "case": "format",
            "value": float(library.Cvar_VariableValue(b"foo")),
            "string": text(library.Cvar_VariableString(b"foo")),
        }
    )
    library.cvar_set_command(1, b"foo", b"")
    inspect_result = library.Cvar_Command()
    library.cvar_set_command(2, b"foo", b"3.75")
    set_result = library.Cvar_Command()
    events.append(
        {
            "function": "Cvar_Command",
            "case": "inspect-set",
            "inspect": inspect_result,
            "set": set_result,
            "value": float(library.Cvar_VariableValue(b"foo")),
        }
    )
    archive = text(library.cvar_archive())
    events.append(
        {
            "function": "Cvar_WriteVariables",
            "case": "archive",
            "matches": 1 if archive == 'foo "3.75"\n' else 0,
            "length": len(archive.encode("ascii")),
        }
    )
    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "cvar_minilang.exe"
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
    output_text = run([str(executable)], capture=True)
    json_lines = [
        line for line in output_text.splitlines() if line.startswith("{")
    ]
    destination.write_text(
        "\n".join(json_lines) + "\n",
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
        raise RuntimeError(f"manifest functions lack events: {sorted(expected - observed)}")


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
        default=ROOT / "build" / "cvar_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
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
    print("cvar differential: PASS (9 JSONL events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
