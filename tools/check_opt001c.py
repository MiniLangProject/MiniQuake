#!/usr/bin/env python3
"""Static OPT-001C frame-allocation and delivery contract checks."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

STATUS = "opt001c_frame_allocation_candidate_v1"
FINGERPRINT = "0x1c001c03"
PARENT = "OPT-001B"


def require(text: str, markers: list[str], label: str, errors: list[str]) -> None:
    for marker in markers:
        if marker not in text:
            errors.append(f"{label} missing marker: {marker}")


def trace_calls(text: str) -> list[tuple[int, str]]:
    result: list[tuple[int, str]] = []
    for number, line in enumerate(text.splitlines(), 1):
        if "traceCommand(" in line and not line.lstrip().startswith("function traceCommand"):
            result.append((number, line.strip()))
    return result


def gl11_guard_errors(text: str) -> tuple[list[str], int]:
    errors: list[str] = []
    calls = trace_calls(text)
    for number, line in calls:
        if "diagnosticTraceEnabled and" not in line:
            errors.append(f"gl11 unguarded trace array at line {number}: {line}")
        if "[" not in line:
            errors.append(f"gl11 trace call at line {number} does not expose argument construction for audit")
    return errors, len(calls)


def world_guard_errors(text: str) -> tuple[list[str], int]:
    errors: list[str] = []
    lines = text.splitlines()
    calls = trace_calls(text)
    for number, line in calls:
        start = max(0, number - 5)
        context = "\n".join(lines[start:number])
        if "gl.traceEnabled()" not in context:
            errors.append(f"world unguarded trace array at line {number}: {line}")
    return errors, len(calls)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", default="")
    parser.add_argument("--allow-downstream-package", action="store_true")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors: list[str] = []

    gl11 = (root / "src/miniquake/render/gl11.ml").read_text(encoding="utf-8-sig")
    world = (root / "src/miniquake/render/world.ml").read_text(encoding="utf-8-sig")
    build_info = (root / "src/miniquake/build_info.ml").read_text(encoding="utf-8-sig")
    build = (root / "build.ps1").read_text(encoding="utf-8-sig")
    downstream_revision = ""
    downstream_parent = ""
    if args.allow_downstream_package:
        if 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R8"' in build_info:
            downstream_revision = "OPT-001CR3R8"
            downstream_parent = "OPT-001CR3R7"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R6"' in build_info:
            downstream_revision = "OPT-001CR3R6"
            downstream_parent = "OPT-001CR3R5"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R4"' in build_info:
            downstream_revision = "OPT-001CR3R4"
            downstream_parent = "OPT-001CR3R3"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R3"' in build_info:
            downstream_revision = "OPT-001CR3R3"
            downstream_parent = "OPT-001CR3R2"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R2"' in build_info:
            downstream_revision = "OPT-001CR3R2"
            downstream_parent = "OPT-001CR3R1"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3R1"' in build_info:
            downstream_revision = "OPT-001CR3R1"
            downstream_parent = "OPT-001CR3"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR3"' in build_info:
            downstream_revision = "OPT-001CR3"
            downstream_parent = "OPT-001CR2"
        elif 'const OPTIMIZATION_DELIVERY_REVISION = "OPT-001CR2"' in build_info:
            downstream_revision = "OPT-001CR2"
            downstream_parent = "OPT-001CR1"
        else:
            downstream_revision = "OPT-001CR1"
            downstream_parent = "OPT-001C"
        runner_name = "TEST_" + downstream_revision + ".ps1"
    else:
        runner_name = "TEST_OPT-001C.ps1"
    runner = (root / "scripts" / runner_name).read_text(encoding="utf-8-sig")
    collector = (root / "scripts" / "COLLECT_RESULTS.ps1").read_text(encoding="utf-8-sig")
    launcher = (root / "scripts" / "test.ps1").read_text(encoding="utf-8-sig")
    contract = (root / "tests/opt001c_contract_tests.ml").read_text(encoding="utf-8-sig")
    comparator = (root / "tools/compare_opt001c_performance.py").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/opt001c_allocation_golden.json").read_text(encoding="utf-8-sig"))
    baseline = json.loads((root / "audit/opt001b_performance_baseline.json").read_text(encoding="utf-8-sig"))

    require(gl11, [
        "function inline traceEnabled()",
        "if diagnosticTraceEnabled and traceCommand(\"vertex\", [x, y, z])",
        "if diagnosticTraceEnabled and traceCommand(\"texcoord\", [s, t])",
        "if diagnosticTraceEnabled and traceCommand(\"color\", [red, green, blue, alpha])",
        "if diagnosticTraceEnabled and traceCommand(\"bind_texture\", [GL_TEXTURE_2D, texture])",
    ], "gl11", errors)
    gl_errors, gl_count = gl11_guard_errors(gl11)
    errors.extend(gl_errors)

    require(world, [
        "if gl.traceEnabled() then gl.traceCommand(\"multitexcoord\"",
        "tracedUpload = false",
        "if gl.traceEnabled() then",
        "gl.traceCommand(\"upload_subimage\"",
        "gl.traceCommand(\"upload_lightmap\"",
    ], "world", errors)
    world_errors, world_count = world_guard_errors(world)
    errors.extend(world_errors)

    # No source file outside the trace implementation may construct a trace
    # argument array without an explicit fast-path guard.
    render_root = root / "src/miniquake/render"
    all_calls = 0
    for path in sorted(render_root.rglob("*.ml")):
        text = path.read_text(encoding="utf-8-sig")
        calls = trace_calls(text)
        all_calls += len(calls)
        if path.name not in {"gl11.ml", "world.ml"} and calls:
            for number, line in calls:
                errors.append(f"unexpected traceCommand caller {path.relative_to(root)}:{number}: {line}")

    if not args.allow_downstream_package:
        require(build_info, [
            f'const OPTIMIZATION_STATUS = "{STATUS}"',
            "const OPTIMIZATION_FINGERPRINT = 0x1c001c03",
            f'const OPTIMIZATION_PARENT = "{PARENT}"',
        ], "build info", errors)
    require(build, [
        "MiniQuakeOPT001CAllocationTests.exe",
        "tests\\opt001c_contract_tests.ml",
    ], "build", errors)
    if args.allow_downstream_package:
        require(runner, [
            f'$DeliveryRevision = "{downstream_revision}"',
            f'$DeliveryParent = "{downstream_parent}"',
            "compare_opt001c_performance.py",
            f"MiniQuake {downstream_revision} acceptance test: PASS",
        ], "runner", errors)
        require(collector, [
            f'$DeliveryRevision = "{downstream_revision}"',
            f"MiniQuake_{downstream_revision}_RESULTS_",
        ], "collector", errors)
        require(launcher, [f"TEST_{downstream_revision}.ps1"], "test.ps1", errors)
    else:
        require(runner, [
            '$DeliveryRevision = "OPT-001C"',
            '$DeliveryParent = "OPT-001B"',
            "compare_opt001c_performance.py",
            "MiniQuake OPT-001C acceptance test: PASS",
        ], "runner", errors)
        require(collector, [
            '$DeliveryRevision = "OPT-001C"',
            "MiniQuake_OPT-001C_RESULTS_",
        ], "collector", errors)
        require(launcher, ["TEST_OPT-001C.ps1"], "test.ps1", errors)
    require(contract, [
        "not gl.traceEnabled()",
        "gl.Trace_Begin()",
        "gl.vertex3(1.0, 2.0, 3.0)",
        "MiniQuake OPT-001C allocation tests passed:",
    ], "contract", errors)
    require(comparator, [
        "TARGET_MET",
        "IMPROVED_BELOW_TARGET",
        "NO_REGRESSION_BELOW_TARGET",
        "REGRESSION",
        "regression_limit_percent",
    ], "performance comparator", errors)

    expected_golden = {
        "status": STATUS,
        "fingerprint": FINGERPRINT,
        "parent": PARENT,
        "trace_fast_path": "short_circuit_before_argument_array",
        "performance_baseline": "OPT-001B",
    }
    for key, expected in expected_golden.items():
        if golden.get(key) != expected:
            errors.append(f"golden {key}={golden.get(key)!r}, expected {expected!r}")
    if baseline.get("source_revision") != "OPT-001B":
        errors.append("performance baseline is not tied to OPT-001B")
    if baseline.get("measurement_frames") != 3000:
        errors.append("performance baseline measurement frame count is not 3000")
    for map_name in ("e1m1", "e1m2"):
        for mode in ("headless", "render"):
            metrics = baseline.get("maps", {}).get(map_name, {}).get(mode, {})
            for field in ("median_ms", "p95_ms", "p99_ms", "max_ms", "total_ms"):
                if not isinstance(metrics.get(field), (int, float)) or metrics[field] <= 0:
                    errors.append(f"missing positive baseline {map_name}/{mode}/{field}")

    report = {
        "schema": "MiniQuakeOPT001CStatic/1",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "checks": {
            "optimization_status": STATUS,
            "optimization_fingerprint": FINGERPRINT,
            "optimization_parent": PARENT,
            "gl11_guarded_trace_calls": gl_count,
            "world_guarded_trace_calls": world_count,
            "all_render_trace_calls": all_calls,
            "unguarded_trace_calls": len(gl_errors) + len(world_errors),
            "baseline_maps": ["e1m1", "e1m2"],
            "baseline_modes": ["headless", "render"],
            "performance_targets": baseline.get("targets", {}),
            "downstream_package": args.allow_downstream_package,
            "delivery_runner": runner_name,
        },
    }
    if args.json:
        Path(args.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake OPT-001C allocation verification: " + report["status"])
    print(f"  gl11_guarded_trace_calls={gl_count}")
    print(f"  world_guarded_trace_calls={world_count}")
    print(f"  unguarded_trace_calls={len(gl_errors) + len(world_errors)}")
    for error in errors:
        print("  error: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
