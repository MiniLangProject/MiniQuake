#!/usr/bin/env python3
"""Direct pinned-source differential for WinQuake/snd_dma.c."""
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
PIN = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
SOURCE = ROOT / "reference/quake/WinQuake/snd_dma.c"
STUBS = ROOT / "reference/harness/snd_dma_oracle_stubs.h"
DRIVER = ROOT / "reference/harness/snd_dma_pinned_driver.c"
DEFINITION = ROOT / "reference/harness/snd_dma_oracle.def"
FIXTURE = ROOT / "tests/snd_dma_differential_fixture.ml"
MANIFEST = ROOT / "audit/snd_dma_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools/verify_reference.py"


def bridge():
    path = ROOT / "native/build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
    module = importlib.util.module_from_spec(spec)
    assert spec is not None and spec.loader is not None
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
    return result.stdout or ""


def build(output: Path) -> Path:
    tools = bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC toolset is required")
    compiler, linker, _ = tools
    source_text = SOURCE.read_text(encoding="utf-8")
    quake_include = '#include "quakedef.h"'
    windows_include = '#include "winquake.h"'
    if source_text.count(quake_include) != 1:
        raise RuntimeError("pinned snd_dma.c Quake include boundary changed")
    if source_text.count(windows_include) != 1:
        raise RuntimeError("pinned snd_dma.c Windows include boundary changed")
    generated = output / "snd_dma_oracle_generated.c"
    generated.write_text(
        source_text.replace(quake_include, '#include "snd_dma_oracle_stubs.h"').replace(
            windows_include, "/* deterministic Windows service boundary */"
        ),
        encoding="utf-8",
    )
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
        f"/I{ROOT/'reference/harness'}",
    ]
    source_obj = output / "snd_dma.obj"
    driver_obj = output / "snd_dma_driver.obj"
    run(common + [f"/Fo{source_obj}", str(generated)])
    run(common + [f"/Fo{driver_obj}", str(DRIVER)])
    dll = output / "snd_dma_oracle.dll"
    run([
        linker,
        "/dll",
        "/noentry",
        "/machine:x64",
        "/nodefaultlib",
        "/opt:ref",
        f"/def:{DEFINITION}",
        f"/out:{dll}",
        str(source_obj),
        str(driver_obj),
        str(ROOT / "native/build/msvcrt.lib"),
        str(ROOT / "native/build/kernel32.lib"),
    ])
    return dll


def oracle(dll: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll))
    function = library.snd_dma_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(131072)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"invalid oracle size {size}")
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "snd_dma_minilang.exe"
    shutil.copy2(ROOT / "native/miniquake_native.dll", output / "miniquake_native.dll")
    run([
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
    ])
    raw = run([str(executable)], capture=True)
    lines = [line for line in raw.splitlines() if line.startswith("{")]
    destination.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy/mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build/snd_dma_differential",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    if not output.is_relative_to((ROOT / "build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True, exist_ok=True)
    run([sys.executable, str(VERIFY_REFERENCE)])
    reference = output / "reference.jsonl"
    candidate_trace = output / "minilang.jsonl"
    dll = build(output)
    oracle(dll, reference)
    candidate(args.compiler.resolve(), output, candidate_trace)
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if manifest["reference_execution"] != "direct-pinned-source-build":
        raise RuntimeError("snd_dma source classification is not strict")
    events = [json.loads(line) for line in reference.read_text().splitlines() if line]
    if len(events) != manifest["events"]:
        raise RuntimeError("event count mismatch")
    observed = {event["function"] for event in events}
    expected = {item["name"] for item in manifest["functions"]}
    if expected - observed:
        raise RuntimeError(f"missing function events: {sorted(expected-observed)}")
    run([
        sys.executable,
        str(ROOT / "tools/parity_oracle.py"),
        "compare-traces",
        str(reference),
        str(candidate_trace),
        "--epsilon",
        "1e-5",
    ])
    run([sys.executable, str(VERIFY_REFERENCE)])
    print(f"snd_dma differential: PASS ({len(events)} events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
