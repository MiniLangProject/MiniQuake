#!/usr/bin/env python3
"""Pinned pr_edict.c differential, including isolated fatal Edict processes."""
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


def bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
    module = importlib.util.module_from_spec(spec)
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
    compiler, linker, _ = bridge().find_msvc_tools()
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(
            [
                "git",
                "-C",
                str(ROOT / "reference/quake"),
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
            str(ROOT / "reference/quake"),
            "worktree",
            "add",
            "--detach",
            str(worktree),
            PIN,
        ]
    )
    run(
        [
            "git",
            "-C",
            str(worktree),
            "apply",
            str(ROOT / "reference/patches/pr_edict_pinned_oracle.patch"),
        ]
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
        f"/I{ROOT / 'reference/harness'}",
    ]
    source = output / "pr_edict.obj"
    driver = output / "pr_edict_driver.obj"
    run(
        common
        + [
            "/DMINIQUAKE_PINNED_ORACLE",
            f"/Fo{source}",
            str(worktree / "WinQuake/pr_edict.c"),
        ]
    )
    run(
        common
        + [
            f"/Fo{driver}",
            str(ROOT / "reference/harness/pr_edict_pinned_driver.c"),
        ]
    )
    dll = output / "pr_edict_oracle.dll"
    run(
        [
            linker,
            "/dll",
            "/noentry",
            "/machine:x64",
            "/nodefaultlib",
            "/opt:ref",
            f"/def:{ROOT / 'reference/harness/pr_edict_oracle.def'}",
            f"/out:{dll}",
            str(source),
            str(driver),
            str(ROOT / "native/build/msvcrt.lib"),
            str(ROOT / "native/build/kernel32.lib"),
        ]
    )
    return dll


def oracle(dll, destination):
    library = ctypes.WinDLL(str(dll))
    function = library.pr_edict_oracle_jsonl
    function.argtypes = [ctypes.c_char_p, ctypes.c_int]
    function.restype = ctypes.c_int
    buffer = ctypes.create_string_buffer(65536)
    size = function(buffer, len(buffer))
    destination.write_bytes(buffer.raw[:size])


def candidate(compiler, output, destination):
    executable = output / "pr_edict_minilang.exe"
    shutil.copy2(ROOT / "native/miniquake_native.dll", output / "miniquake_native.dll")
    run(
        [
            sys.executable,
            str(compiler),
            str(ROOT / "tests/pr_edict_differential_fixture.ml"),
            str(executable),
            "-I",
            str(ROOT),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "100",
            "--heap-reserve",
            "512m",
            "--heap-commit",
            "32m",
            "--heap-grow",
            "4m",
        ]
    )
    destination.write_text(run([str(executable)], True), encoding="utf-8", newline="\n")
    return executable


def fatal_processes(dll, executable):
    cases = [
        ("EDICT_NUM", 0, "--error-edict-num"),
        ("NUM_FOR_EDICT", 1, "--error-num-for-edict"),
    ]
    for name, mode, argument in cases:
        code = (
            "import ctypes; "
            f"d=ctypes.WinDLL(r'{dll}'); "
            "d.pr_edict_error_case.argtypes=[ctypes.c_int]; "
            f"d.pr_edict_error_case({mode})"
        )
        reference = subprocess.run(
            [sys.executable, "-c", code],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        mini = subprocess.run(
            [str(executable), argument],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        if reference.returncode == 0 or mini.returncode != 42:
            raise RuntimeError(
                f"{name} fatal process mismatch: "
                f"reference={reference.returncode}, minilang={mini.returncode}"
            )
        print(
            f"pr_edict {name} fatal differential: PASS "
            f"(reference={reference.returncode}, minilang=42)"
        )


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
        default=ROOT / "build/pr_edict_differential",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    if not output.is_relative_to((ROOT / "build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True, exist_ok=True)

    reference = output / "reference.jsonl"
    minilang = output / "minilang.jsonl"
    dll = build(output)
    oracle(dll, reference)
    executable = candidate(args.compiler.resolve(), output, minilang)

    manifest = json.loads(
        (ROOT / "audit/pr_edict_differential_manifest.json").read_text(
            encoding="utf-8"
        )
    )
    events = [
        json.loads(line)
        for line in reference.read_text(encoding="utf-8").splitlines()
        if line
    ]
    if len(events) != manifest["events"]:
        raise RuntimeError(
            f"event count mismatch: reference={len(events)}, manifest={manifest['events']}"
        )
    observed = {event["function"] for event in events}
    expected = {item["name"] for item in manifest["functions"]}
    if observed != expected:
        missing = sorted(expected - observed)
        extra = sorted(observed - expected)
        raise RuntimeError(f"strict function mismatch: missing={missing}, extra={extra}")

    run(
        [
            sys.executable,
            str(ROOT / "tools/parity_oracle.py"),
            "compare-traces",
            str(reference),
            str(minilang),
            "--epsilon",
            "1e-5",
        ]
    )
    fatal_processes(dll, executable)
    print("pr_edict differential: PASS (29 events, epsilon=1e-5)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
