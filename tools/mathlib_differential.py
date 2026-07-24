#!/usr/bin/env python3
"""Compare MiniLang mathlib with bodies compiled from pinned GLQuake source."""

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
DRIVER = ROOT / "reference" / "harness" / "mathlib_pinned_driver.c"
DEFINITION = ROOT / "reference" / "harness" / "mathlib_oracle.def"
STUB_INCLUDE = ROOT / "reference" / "harness"
PATCH = ROOT / "reference" / "patches" / "mathlib_pinned_oracle.patch"
FIXTURE = ROOT / "tests" / "mathlib_differential_fixture.ml"
BOPS_FIXTURE = ROOT / "tests" / "mathlib_bops_error_fixture.ml"
MANIFEST = ROOT / "audit" / "mathlib_differential_manifest.json"


class Vec3(ctypes.c_float * 3):
    pass


class MPlane(ctypes.Structure):
    _fields_ = [
        ("normal", Vec3),
        ("dist", ctypes.c_float),
        ("type", ctypes.c_ubyte),
        ("signbits", ctypes.c_ubyte),
        ("pad", ctypes.c_ubyte * 2),
    ]


Matrix3 = (ctypes.c_float * 3) * 3
Matrix34 = (ctypes.c_float * 4) * 3


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
    source_obj = output / "mathlib_pinned.obj"
    driver_obj = output / "mathlib_pinned_driver.obj"
    dll = output / "mathlib_oracle.dll"
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
            str(worktree / "WinQuake" / "mathlib.c"),
        ]
    )
    run(
        common
        + [
            f"/Fo{driver_obj}",
            str(DRIVER),
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
    vector_inputs = [ctypes.POINTER(ctypes.c_float)]
    library.ProjectPointOnPlane.argtypes = vector_inputs * 3
    library.PerpendicularVector.argtypes = vector_inputs * 2
    library.RotatePointAroundVector.argtypes = vector_inputs * 3 + [ctypes.c_float]
    library.anglemod.argtypes = [ctypes.c_float]
    library.anglemod.restype = ctypes.c_float
    library.BoxOnPlaneSide.argtypes = vector_inputs * 2 + [ctypes.POINTER(MPlane)]
    library.BoxOnPlaneSide.restype = ctypes.c_int
    library.AngleVectors.argtypes = vector_inputs * 4
    library.VectorCompare.argtypes = vector_inputs * 2
    library.VectorCompare.restype = ctypes.c_int
    library.VectorMA.argtypes = vector_inputs + [ctypes.c_float] + vector_inputs * 2
    library._DotProduct.argtypes = vector_inputs * 2
    library._DotProduct.restype = ctypes.c_float
    for name in ("_VectorSubtract", "_VectorAdd"):
        function = getattr(library, name)
        function.argtypes = vector_inputs * 3
    library._VectorCopy.argtypes = vector_inputs * 2
    library.CrossProduct.argtypes = vector_inputs * 3
    library.Length.argtypes = vector_inputs
    library.Length.restype = ctypes.c_float
    library.VectorNormalize.argtypes = vector_inputs
    library.VectorNormalize.restype = ctypes.c_float
    library.VectorInverse.argtypes = vector_inputs
    library.VectorScale.argtypes = vector_inputs + [ctypes.c_float] + vector_inputs
    library.Q_log2.argtypes = [ctypes.c_int]
    library.Q_log2.restype = ctypes.c_int
    library.R_ConcatRotations.argtypes = [
        ctypes.POINTER(ctypes.c_float),
        ctypes.POINTER(ctypes.c_float),
        ctypes.POINTER(ctypes.c_float),
    ]
    library.R_ConcatTransforms.argtypes = library.R_ConcatRotations.argtypes
    library.FloorDivMod.argtypes = [
        ctypes.c_double,
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int),
    ]
    library.GreatestCommonDivisor.argtypes = [ctypes.c_int, ctypes.c_int]
    library.GreatestCommonDivisor.restype = ctypes.c_int
    library.Invert24To16.argtypes = [ctypes.c_int]
    library.Invert24To16.restype = ctypes.c_int
    library.BOPS_Error.argtypes = []
    library.mathlib_reset_sys_error.argtypes = []
    library.mathlib_sys_error_calls.argtypes = []
    library.mathlib_sys_error_calls.restype = ctypes.c_int


def vec(value: Vec3) -> dict[str, float]:
    return {"x": float(value[0]), "y": float(value[1]), "z": float(value[2])}


def event(function: str, case: str, **values: object) -> dict[str, object]:
    return {"function": function, "case": case, **values}


def run_oracle(dll_path: Path, destination: Path) -> None:
    library = ctypes.WinDLL(str(dll_path))
    configure(library)
    events: list[dict[str, object]] = []

    point, normal, result = Vec3(3.0, 4.0, 5.0), Vec3(0.0, 0.0, 2.0), Vec3()
    library.ProjectPointOnPlane(result, point, normal)
    events.append(event("ProjectPointOnPlane", "basic", **vec(result)))

    source, result = Vec3(0.6, 0.8, 0.0), Vec3()
    library.PerpendicularVector(result, source)
    events.append(event("PerpendicularVector", "normalized", **vec(result)))

    direction, point, result = Vec3(0.0, 0.0, 1.0), Vec3(1.0, 0.0, 0.0), Vec3()
    library.RotatePointAroundVector(result, direction, point, ctypes.c_float(90.0))
    events.append(event("RotatePointAroundVector", "quarter_turn", **vec(result)))
    events.append(event("anglemod", "negative", value=float(library.anglemod(-45.25))))

    emins, emaxs = Vec3(-2.0, -3.0, -4.0), Vec3(5.0, 6.0, 7.0)
    plane = MPlane(Vec3(0.5, -0.25, 0.75), 1.25, 3, 2, (ctypes.c_ubyte * 2)())
    events.append(
        event(
            "BoxOnPlaneSide",
            "general",
            value=library.BoxOnPlaneSide(emins, emaxs, ctypes.byref(plane)),
        )
    )

    angles, forward, right, up = (
        Vec3(25.0, 130.0, -15.0),
        Vec3(),
        Vec3(),
        Vec3(),
    )
    library.AngleVectors(angles, forward, right, up)
    events.append(
        event(
            "AngleVectors",
            "angles",
            values=[float(item) for value in (forward, right, up) for item in value],
        )
    )

    first, second = Vec3(1.25, -2.5, 3.75), Vec3(-4.0, 5.5, 6.25)
    copied = Vec3()
    library._VectorCopy(first, copied)
    events.append(event("VectorCompare", "equal", value=library.VectorCompare(first, copied)))

    result = Vec3()
    library.VectorMA(first, ctypes.c_float(0.75), second, result)
    events.append(event("VectorMA", "basic", **vec(result)))
    events.append(event("_DotProduct", "basic", value=float(library._DotProduct(first, second))))
    for name in ("_VectorSubtract", "_VectorAdd"):
        result = Vec3()
        getattr(library, name)(first, second, result)
        events.append(event(name, "basic", **vec(result)))
    result = Vec3()
    library._VectorCopy(first, result)
    events.append(event("_VectorCopy", "basic", **vec(result)))
    result = Vec3()
    library.CrossProduct(first, second, result)
    events.append(event("CrossProduct", "basic", **vec(result)))
    events.append(event("Length", "basic", value=float(library.Length(first))))

    normalize_value = Vec3(3.0, 4.0, 12.0)
    normalize_length = float(library.VectorNormalize(normalize_value))
    events.append(
        event(
            "VectorNormalize",
            "basic",
            length=normalize_length,
            **vec(normalize_value),
        )
    )

    inverse = Vec3(1.5, -2.0, 3.25)
    library.VectorInverse(inverse)
    events.append(event("VectorInverse", "basic", **vec(inverse)))
    result = Vec3()
    library.VectorScale(first, ctypes.c_float(-1.5), result)
    events.append(event("VectorScale", "basic", **vec(result)))
    events.append(event("Q_log2", "basic", value=library.Q_log2(1025)))

    rotation_a = Matrix3(
        (ctypes.c_float * 3)(1.0, 2.0, 3.0),
        (ctypes.c_float * 3)(0.0, -1.0, 4.0),
        (ctypes.c_float * 3)(2.0, 1.0, 0.5),
    )
    rotation_b = Matrix3(
        (ctypes.c_float * 3)(-2.0, 1.0, 0.0),
        (ctypes.c_float * 3)(3.0, 0.5, 2.0),
        (ctypes.c_float * 3)(1.0, -1.0, 1.5),
    )
    rotation_out = Matrix3()
    library.R_ConcatRotations(rotation_a[0], rotation_b[0], rotation_out[0])
    events.append(
        event(
            "R_ConcatRotations",
            "basic",
            values=[float(value) for row in rotation_out for value in row],
        )
    )

    transform_a = Matrix34(
        (ctypes.c_float * 4)(1.0, 2.0, 3.0, 4.0),
        (ctypes.c_float * 4)(0.0, -1.0, 4.0, 2.0),
        (ctypes.c_float * 4)(2.0, 1.0, 0.5, -3.0),
    )
    transform_b = Matrix34(
        (ctypes.c_float * 4)(-2.0, 1.0, 0.0, 5.0),
        (ctypes.c_float * 4)(3.0, 0.5, 2.0, -2.0),
        (ctypes.c_float * 4)(1.0, -1.0, 1.5, 3.0),
    )
    transform_out = Matrix34()
    library.R_ConcatTransforms(transform_a[0], transform_b[0], transform_out[0])
    events.append(
        event(
            "R_ConcatTransforms",
            "basic",
            values=[float(value) for row in transform_out for value in row],
        )
    )

    quotient, remainder = ctypes.c_int(), ctypes.c_int()
    library.FloorDivMod(-17.0, 5.0, ctypes.byref(quotient), ctypes.byref(remainder))
    events.append(
        event(
            "FloorDivMod",
            "negative",
            quotient=quotient.value,
            remainder=remainder.value,
        )
    )
    events.append(
        event(
            "GreatestCommonDivisor",
            "basic",
            value=library.GreatestCommonDivisor(462, 1071),
        )
    )
    events.append(
        event("Invert24To16", "basic", value=library.Invert24To16(0x123456))
    )
    library.mathlib_reset_sys_error()
    library.BOPS_Error()
    events.append(
        event(
            "BOPS_Error",
            "dispatch",
            called=library.mathlib_sys_error_calls(),
            error=1,
        )
    )
    destination.write_text(
        "".join(json.dumps(item, separators=(",", ":")) + "\n" for item in events),
        encoding="utf-8",
        newline="\n",
    )


def build_and_run_minilang(compiler: Path, output: Path, destination: Path) -> None:
    executable = output / "mathlib_minilang.exe"
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
            "50",
        ]
    )
    text = run([str(executable)], capture=True)
    destination.write_text(text, encoding="utf-8", newline="\n")
    bops_executable = output / "mathlib_bops_error.exe"
    run(
        [
            sys.executable,
            str(compiler),
            str(BOPS_FIXTURE),
            str(bops_executable),
            "-I",
            str(ROOT / "src"),
            "-I",
            str(compiler.parent),
            "--keep-going",
            "--max-errors",
            "20",
        ]
    )
    bops = subprocess.run(
        [str(bops_executable)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    if (
        bops.returncode == 0
        or "no=2500" not in bops.stdout
        or "BoxOnPlaneSide: Bad signbits" not in bops.stdout
    ):
        raise RuntimeError(
            "MiniLang BOPS_Error did not dispatch the expected fatal error: "
            f"exit={bops.returncode} output={bops.stdout!r}"
        )
    with destination.open("a", encoding="utf-8", newline="\n") as stream:
        stream.write(
            json.dumps(
                event("BOPS_Error", "dispatch", called=1, error=1),
                separators=(",", ":"),
            )
            + "\n"
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
    differential = {
        item["name"]
        for item in manifest["functions"]
        if item["classification"] == "reference-differential"
    }
    missing = differential - observed
    if missing:
        raise RuntimeError(
            f"manifest differential functions lack events: {sorted(missing)}"
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
        default=ROOT / "build" / "mathlib_differential",
    )
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    reference = args.output / "reference.jsonl"
    candidate = args.output / "minilang.jsonl"
    dll = build_oracle(args.output)
    run_oracle(dll, reference)
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
    events = sum(
        1 for line in reference.read_text(encoding="utf-8").splitlines() if line
    )
    print(f"mathlib differential: PASS ({events} JSONL events, epsilon=1e-5)")
    print(f"reference={reference}")
    print(f"candidate={candidate}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
