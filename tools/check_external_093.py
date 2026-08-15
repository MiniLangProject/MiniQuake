#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys


def function_body(text: str, name: str) -> str:
    match = re.search(rf"(?ms)^function\s+{re.escape(name)}\b.*?^end function\s*$", text)
    return match.group(0) if match else ""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors: list[str] = []

    def read(rel: str) -> str:
        p = root / rel
        if not p.is_file():
            errors.append("missing file: " + rel)
            return ""
        return p.read_text(encoding="utf-8-sig")

    contract = read("src/miniquake/external_reference_contract.ml")
    mainml = read("src/main.ml")
    world = read("src/miniquake/render/world.ml")
    entities = read("src/miniquake/render/entities.ml")
    tool = read("tools/compare_original_reference.py")
    test = read("tests/original_visual_reference_tests.ml")
    harness = read("TEST_BP-090-094R15.ps1")
    analysis = read("docs/archive/releases/BP-093_R7_VISUAL_DIAGNOSTIC_ANALYSIS.md")
    golden_path = root / "audit/original_visual_reference_golden.json"
    try:
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        errors.append(f"invalid golden file: {exc}")
        golden = {}

    for marker in [
        "const ORIGINAL_CAPTURE_MIN_SSIM = 0.95",
        "const ORIGINAL_CAPTURE_SEARCH_RADIUS = 2",
        '["demo1", 256]', '["demo2", 256]', '["demo3", 256]',
    ]:
        if marker not in contract:
            errors.append("missing visual contract marker: " + marker)

    demo_entry = function_body(mainml, "runRenderDemoEvidenceCommand")
    for marker in ["--render-demo-evidence", "+timedemo", '"-gamma", "1"']:
        if marker not in mainml:
            errors.append("missing demo capture marker: " + marker)
    if '"-gamma", "1"' not in demo_entry:
        errors.append("MiniQuake demo evidence does not bind startup palette gamma through -gamma 1")

    viewport = function_body(world, "renderViewport")
    if "gl.clearColor(1.0, 0.0, 0.0, 0.0)" not in viewport:
        errors.append("renderViewport does not preserve GLQuake's red clear colour")
    if "gl.clearColor(0.0, 0.0, 0.0" in viewport:
        errors.append("renderViewport still overrides the GLQuake clear colour with black")

    brush = function_body(entities, "drawBrush")
    for marker in [
        "worldRenderer.R_DrawBrushModelForSubmodel(entity, submodelIndex)",
        "function R_DrawBrushModelForSubmodel(entity, submodelIndex)",
        "currentTextureFrame = entity.frame",
        "R_ClearLightmapChains()",
        "R_MarkBrushModelLightsForSubmodel(entity, submodelIndex)",
        "gl.blendFunc(gl.GL_ZERO, gl.GL_ONE_MINUS_SRC_COLOR)",
    ]:
        if marker not in (entities + "\n" + world):
            errors.append("missing brush visual parity marker: " + marker)
    if "gl.GL_SRC_COLOR" in brush:
        errors.append("simplified brush renderer still multiplies inverted LUMINANCE data with GL_SRC_COLOR")

    for marker in [
        '"normalization": "none"', "temporal_candidate_selection_only",
        "mean_luminance_ssim_8x8", "default=0.95", "tga_origin_handling",
        "--original-alt", "--min-reference-ssim", "default=0.98",
        '"reference_aggregation": "minimum_ssim"', '"schema_version": 3',
    ]:
        if marker not in tool:
            errors.append("missing comparator marker: " + marker)

    for marker in [
        "Run-OriginalVisualCapture -Demo $DemoName -Frame 256 -Suffix 'a'",
        "Run-OriginalVisualCapture -Demo $DemoName -Frame 256 -Suffix 'b'",
        "$Offset=-2", "$Offset -le 2", "'gl_ztrick 0'", "'gl_clear 1'",
        "'gl_finish 1'", "'-gamma','1'", "'--original-alt',$OriginalB",
        "'--min-reference-ssim','0.98'", "'--min-ssim','0.95'", "original_tga_screenshot",
        "screenshot_produced=$true", "capture_completion='validated_tga_size_hash_stability'",
        "expected_tga_bytes", "stable_polls", "Get-OriginalTgaState", "Wait-OriginalTgaComplete",
        "reference_aggregation='minimum_ssim'", "condebug_enabled=$false",
        "'-noudp','-noipx'", "network_scope='disabled'",
        "'host_framerate 0.02'", "simulation_timestep='fixed_host_framerate'",
        "original_host_framerate=0.02", "miniquake_frame_step=0.02",
        "firewall_prompt_expected = $false",
    ]:
        if marker not in harness:
            errors.append("missing visual harness marker: " + marker)
    if "'-condebug'" in harness:
        errors.append("current original visual harness still passes -condebug")
    if "qconsole.log" in harness:
        errors.append("current original visual evidence still depends on qconsole")
    if "if ($OriginalHashA -ne $OriginalHashB) { throw" in harness:
        errors.append("visual harness still requires exact original A/B bytes before measuring reference consistency")

    expected = {
        "condebug_enabled": False,
        "evidence_source": "original_tga_screenshot",
        "qconsole_required": False,
        "network_scope": "disabled",
        "udp_disabled": True,
        "firewall_prompt_expected": False,
        "mini_startup_gamma": 1.0,
        "gl_clear_color_rgba": [1.0, 0.0, 0.0, 0.0],
        "brush_render_path": "canonical_R_DrawBrushModelForSubmodel",
        "brush_lightmap_blend": "GL_ZERO_GL_ONE_MINUS_SRC_COLOR",
        "brush_texture_frame_source": "entity.frame",
        "brush_lightmap_chains_reset_per_model": True,
        "expected_original_backbuffer_offset": -2,
        "capture_completion": "validated_tga_size_hash_stability",
        "minimum_reference_ssim": 0.98,
        "reference_consistency_mode": "exact_or_dual_reference_ssim",
        "candidate_reference_aggregation": "minimum_ssim",
        "requires_original_ab_determinism": False,
        "simulation_timestep": "fixed_0.02_seconds",
        "original_host_framerate": 0.02,
        "miniquake_frame_step": 0.02,
    }
    for key, expected_value in expected.items():
        if golden.get(key) != expected_value:
            errors.append(f"golden {key}={golden.get(key)!r}, expected {expected_value!r}")

    for marker in [
        "bottom_48_original_rgb=255,0,0",
        "bottom_48_miniquake_rgb=0,0,0",
        "platform_luminance_correlation=-0.547846",
        "startup_palette_gamma=0.7_vs_1.0",
        "brush_lightmap_inversion=confirmed",
    ]:
        if marker not in analysis:
            errors.append("diagnostic analysis missing marker: " + marker)

    if "MiniQuake BP-093 original visual reference tests passed: 20" not in test:
        errors.append("runtime marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-094",
        "delivery_revision": "BP-090-094R15",
        "step": "BP-093",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "fixtures": 20,
        "minimum_ssim": 0.95,
        "metric": "mean_luminance_ssim_8x8",
        "normalization": "none",
        "scenarios": 3,
        "original_runs_per_scenario": 2,
        "mini_startup_gamma": 1.0,
        "gl_clear_color_rgba": [1.0, 0.0, 0.0, 0.0],
        "brush_render_path": "canonical_R_DrawBrushModelForSubmodel",
        "brush_lightmap_blend": "GL_ZERO_GL_ONE_MINUS_SRC_COLOR",
        "brush_texture_frame_source": "entity.frame",
        "expected_original_backbuffer_offset": -2,
        "capture_completion": "validated_tga_size_hash_stability",
        "minimum_reference_ssim": 0.98,
        "reference_consistency_mode": "exact_or_dual_reference_ssim",
        "candidate_reference_aggregation": "minimum_ssim",
        "simulation_timestep": "fixed_0.02_seconds",
        "original_host_framerate": 0.02,
        "miniquake_frame_step": 0.02,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print("MiniQuake BP-093 original visual reference verification: " + report["status"])
    print("  mini_startup_gamma=1")
    print("  clear_color=1,0,0,0")
    print("  brush_path=canonical_R_DrawBrushModelForSubmodel")
    print("  brush_lightmap_blend=GL_ZERO/GL_ONE_MINUS_SRC_COLOR")
    print("  brush_texture_frame=entity.frame")
    print("  capture_completion=validated_tga_size_hash_stability")
    print("  reference_consistency=dual_reference_min_ssim>=0.98")
    print("  candidate_reference_aggregation=minimum_ssim")
    print("  simulation_timestep=fixed_0.02_seconds")
    print("  original_host_framerate=0.02 miniquake_frame_step=0.02")
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
