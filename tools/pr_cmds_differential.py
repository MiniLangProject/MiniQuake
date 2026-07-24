#!/usr/bin/env python3
"""Pinned WinQuake pr_cmds.c differential, including isolated fatal paths."""
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
SOURCE = ROOT / "reference/quake/WinQuake/pr_cmds.c"
STUBS = ROOT / "reference/harness/pr_cmds_oracle_stubs.h"
DRIVER = ROOT / "reference/harness/pr_cmds_pinned_driver.c"
DEFINITION = ROOT / "reference/harness/pr_cmds_oracle.def"
FIXTURE = ROOT / "tests/pr_cmds_differential_fixture.ml"
MANIFEST = ROOT / "audit/pr_cmds_differential_manifest.json"
VERIFY_REFERENCE = ROOT / "tools/verify_reference.py"


def bridge():
    path = ROOT / "native/build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
    module = importlib.util.module_from_spec(spec)
    assert spec is not None and spec.loader is not None
    spec.loader.exec_module(module)
    return module


def run(command, capture=False):
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )
    return result.stdout or ""


def build(output):
    tools = bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC toolset is required")
    compiler, linker, _ = tools
    source_text = SOURCE.read_text(encoding="utf-8")
    include = '#include "quakedef.h"'
    if source_text.count(include) != 1:
        raise RuntimeError("pinned pr_cmds.c include boundary changed")
    generated = output / "pr_cmds_oracle_generated.c"
    generated.write_text(
        source_text.replace(include, '#include "pr_cmds_oracle_stubs.h"'),
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
    source_obj = output / "pr_cmds.obj"
    driver_obj = output / "pr_cmds_driver.obj"
    run(common + [f"/Fo{source_obj}", str(generated)])
    run(common + [f"/Fo{driver_obj}", str(DRIVER)])
    dll = output / "pr_cmds_oracle.dll"
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


def oracle(dll, destination):
    library = ctypes.WinDLL(str(dll))
    function = library.pr_cmds_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(131072)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"invalid oracle size {size}")
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler, output, destination):
    executable = output / "pr_cmds_minilang.exe"
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
    raw = run([str(executable)], True)
    lines = [line for line in raw.splitlines() if line.startswith("{")]
    destination.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    return executable


def fatal_processes(dll, executable):
    fatal_cases = 16
    for case in range(fatal_cases):
        code = (
            "import ctypes; d=ctypes.WinDLL(r'"
            + str(dll)
            + "'); d.pr_cmds_fatal_case("
            + str(case)
            + ")"
        )
        reference = subprocess.run(
            [sys.executable, "-c", code],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        mini = subprocess.run(
            [str(executable), "--fatal", str(case)],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if reference.returncode == 0 or mini.returncode != 42:
            raise RuntimeError(
                f"fatal case {case} mismatch: reference={reference.returncode}, minilang={mini.returncode}"
            )
    print(f"pr_cmds fatal differential: PASS ({fatal_cases} isolated paths)")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler",
        type=Path,
        default=ROOT.parent / "MiniLangCompilerPy/mlc_win64.py",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build/pr_cmds_differential",
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
    executable = candidate(args.compiler.resolve(), output, candidate_trace)
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    if manifest["reference_execution"] != "direct-pinned-source-build":
        raise RuntimeError("pr_cmds source classification is not strict")
    events = [json.loads(line) for line in reference.read_text().splitlines() if line]
    if len(events) != manifest["events"]:
        raise RuntimeError("event count mismatch")
    observed = {event["function"] for event in events}
    expected = {
        item["name"]
        for item in manifest["functions"]
        if "differential:fatal-process" not in item["evidence"]
    }
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
    fatal_processes(dll, executable)
    run([sys.executable, str(VERIFY_REFERENCE)])
    print(f"pr_cmds differential: PASS ({len(events)} events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
