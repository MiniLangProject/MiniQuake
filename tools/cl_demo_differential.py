#!/usr/bin/env python3
"""Build pinned cl_demo.c with stubs and compare it with the MiniLang port."""

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
PINNED_SOURCE = ROOT / "reference" / "quake" / "WinQuake" / "cl_demo.c"
HARNESS = ROOT / "reference" / "harness" / "cl_demo_oracle.c"
DEFINITION = ROOT / "reference" / "harness" / "cl_demo_oracle.def"
FIXTURE = ROOT / "tests" / "cl_demo_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "cl_demo_differential_manifest.json"
MARKER = "/*__PINNED_CL_DEMO_SOURCE__*/"
VERIFY_REFERENCE = ROOT / "tools" / "verify_reference.py"


def load_build_bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("miniquake_build_bridge", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout if result.stdout is not None else ""


def materialize_patched_source(output: Path) -> Path:
    harness = HARNESS.read_text(encoding="utf-8")
    if harness.count(MARKER) != 1:
        raise RuntimeError("cl_demo oracle harness marker is missing or ambiguous")
    source = PINNED_SOURCE.read_text(encoding="utf-8")
    include = '#include "quakedef.h"'
    if source.count(include) != 1:
        raise RuntimeError("pinned cl_demo.c include boundary changed")
    source = source.replace(include, "/* quakedef.h replaced by deterministic harness stubs */")
    finish_print = (
        'Con_Printf ("%i frames %5.1f seconds %5.1f fps\\n", '
        "frames, time, frames/time);"
    )
    if source.count(finish_print) != 1:
        raise RuntimeError("pinned CL_FinishTimeDemo diagnostic boundary changed")
    source = source.replace(
        finish_print,
        "mq_capture_timedemo(frames, time, frames/time);\n\t" + finish_print,
    )
    generated = output / "cl_demo_oracle_generated.c"
    generated.write_text(harness.replace(MARKER, source), encoding="utf-8")
    return generated


def build_oracle(output: Path) -> Path:
    bridge = load_build_bridge()
    tools = bridge.find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link/lib toolset is required")
    compiler, linker, _ = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    if not msvcrt.exists():
        raise RuntimeError(
            "native/build/msvcrt.lib is missing; run native/build_bridge.py first"
        )
    generated = materialize_patched_source(output)
    obj = output / "cl_demo_oracle.obj"
    dll = output / "cl_demo_oracle.dll"
    run(
        [
            compiler,
            "/nologo",
            "/c",
            "/W4",
            "/GS-",
            "/Zl",
            "/fp:precise",
            "/O2",
            f"/Fo{obj}",
            str(generated),
        ]
    )
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/nodefaultlib",
            "/dynamicbase",
            "/nxcompat",
            f"/def:{DEFINITION}",
            f"/out:{dll}",
            str(obj),
            str(msvcrt),
        ]
    )
    return dll


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    function = library.cl_demo_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"oracle returned invalid byte count {size}")
    destination.write_bytes(buffer.raw[:size])


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "cl_demo_minilang.exe"
    shutil.copy2(ROOT / "native" / "miniquake_native.dll", output / "miniquake_native.dll")
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
            "50",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    destination.write_text(run([str(executable)], capture=True), encoding="utf-8", newline="\n")


def validate_manifest(reference: Path) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    allowed = {"reference-differential", "reference-artifact-byte-exact"}
    functions = manifest["functions"]
    if {item["classification"] for item in functions} - allowed:
        raise RuntimeError("cl_demo manifest contains a non-strict classification")
    differential = {
        item["name"]
        for item in functions
        if item["classification"] == "reference-differential"
    }
    events = [
        json.loads(line)
        for line in reference.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    observed = {event["function"] for event in events}
    if differential - observed:
        raise RuntimeError(
            f"differential functions lack events: {sorted(differential - observed)}"
        )
    if manifest["reference_execution"] != "direct-pinned-source-build":
        raise RuntimeError("cl_demo source execution classification is not strict")
    artifacts = manifest["reference_artifacts"]
    if any(item["reference_execution"] != "original-artifact" for item in artifacts):
        raise RuntimeError("retail demo evidence is not classified as original-artifact")


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
        default=ROOT / "build" / "cl_demo_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    run([sys.executable, str(VERIFY_REFERENCE)])
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    oracle = build_oracle(args.output)
    run_oracle(oracle, reference)
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
    run([sys.executable, str(VERIFY_REFERENCE)])
    events = sum(1 for line in reference.read_text(encoding="utf-8").splitlines() if line)
    print(f"cl_demo differential: PASS ({events} JSONL events, epsilon=1e-5)")
    print(f"reference={reference}")
    print(f"candidate={candidate}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
