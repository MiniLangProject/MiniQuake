#!/usr/bin/env python3
"""Build/compare the pinned WinQuake world.c and MiniLang fixtures."""

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
DRIVER = ROOT / "reference" / "harness" / "world_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "world_oracle.def"
STUB_INCLUDE = ROOT / "reference" / "harness"
PATCH = ROOT / "reference" / "patches" / "world_pinned_oracle.patch"
FIXTURE = ROOT / "tests" / "world_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "world_differential_manifest.json"
PINNED_COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"


def load_bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
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


def build_oracle(output: Path) -> Path:
    tools = load_bridge().find_msvc_tools()
    if tools is None:
        raise RuntimeError("x64 MSVC cl/link toolset is required")
    compiler, linker, _ = tools
    msvcrt = ROOT / "native" / "build" / "msvcrt.lib"
    kernel32 = ROOT / "native" / "build" / "kernel32.lib"
    worktree = output / "pinned_quake"
    if worktree.exists():
        run([
            "git", "-C", str(ROOT / "reference" / "quake"),
            "worktree", "remove", "--force", str(worktree),
        ])
    run([
        "git", "-C", str(ROOT / "reference" / "quake"),
        "worktree", "add", "--detach", str(worktree), PINNED_COMMIT,
    ])
    run(["git", "-C", str(worktree), "apply", str(PATCH)])
    source_obj = output / "world_pinned.obj"
    driver_obj = output / "world_pinned_driver.obj"
    common = [
        compiler, "/nologo", "/c", "/W4", "/GS-", "/Zl",
        "/fp:precise", "/O2", "/Gy", f"/I{STUB_INCLUDE}",
    ]
    run(common + [
        "/DMINIQUAKE_PINNED_ORACLE", f"/Fo{source_obj}",
        str(worktree / "WinQuake" / "world.c"),
    ])
    run(common + [f"/Fo{driver_obj}", str(DRIVER)])
    dll = output / "world_oracle.dll"
    run([
        linker, "/dll", "/noentry", "/machine:x64", "/nodefaultlib",
        "/dynamicbase", "/nxcompat", "/opt:ref", f"/def:{DEFINITION}",
        f"/out:{dll}", str(source_obj), str(driver_obj), str(msvcrt),
        str(kernel32),
    ])
    return dll


def run_oracle(dll: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll))
    function = library.world_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    if size < 0 or size >= len(buffer):
        raise RuntimeError(f"invalid oracle byte count {size}")
    destination.write_bytes(buffer.raw[:size])


def run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "world_minilang.exe"
    shutil.copy2(
        ROOT / "native" / "miniquake_native.dll",
        output / "miniquake_native.dll",
    )
    run([
        sys.executable, str(compiler), str(FIXTURE), str(executable),
        "-I", str(ROOT), "-I", str(ROOT / "src"), "-I", str(compiler.parent),
        "--keep-going", "--max-errors", "50",
        "--heap-reserve", "512m", "--heap-commit", "32m",
        "--heap-grow", "4m",
    ])
    destination.write_text(
        run([str(executable)], capture=True), encoding="utf-8", newline="\n"
    )


def validate(reference: Path) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    events = [
        json.loads(line) for line in
        reference.read_text(encoding="utf-8").splitlines() if line.strip()
    ]
    if len(events) != manifest["events"]:
        raise RuntimeError(
            f"manifest expects {manifest['events']} events, got {len(events)}"
        )
    observed = {event["function"] for event in events}
    strict = {
        item["name"] for item in manifest["functions"]
        if item["classification"] == "reference-differential"
    }
    if strict - observed:
        raise RuntimeError(f"strict functions lack events: {sorted(strict-observed)}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--compiler", type=Path,
        default=ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
    )
    parser.add_argument(
        "--output", type=Path,
        default=ROOT / "build" / "world_differential",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    build_root = (ROOT / "build").resolve()
    if not output.is_relative_to(build_root):
        raise RuntimeError(f"output must remain inside {build_root}")
    output.mkdir(parents=True, exist_ok=True)
    reference = output / "reference.jsonl"
    candidate = output / "minilang.jsonl"
    run_oracle(build_oracle(output), reference)
    run_minilang(args.compiler.resolve(), output, candidate)
    validate(reference)
    run([
        sys.executable, str(ROOT / "tools" / "parity_oracle.py"),
        "compare-traces", str(reference), str(candidate),
        "--epsilon", "1e-5",
    ])
    count = sum(1 for line in reference.read_text().splitlines() if line)
    print(f"world differential: PASS ({count} events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
