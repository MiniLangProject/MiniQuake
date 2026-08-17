#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Verify the check opt001cr3r8 compatibility and regression contract."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

REV = "OPT-001D"
PARENT = "OPT-001CR3R7"
STATUS = "opt001d_performance_audio_ui_candidate_v1"
FINGERPRINT = "0x1c001c10"


def marker_errors(text: str, markers: tuple[str, ...], label: str) -> list[str]:
    """Return the contract violations found by the marker guard."""
    return [f"{label} missing marker: {marker}" for marker in markers if marker not in text]


def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", default="")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors: list[str] = []

    def text(rel: str) -> str:
        """Read one repository-relative UTF-8 source file for the enclosing check."""
        return (root / rel).read_text(encoding="utf-8")

    build_info = text("src/miniquake/build_info.ml")
    host = text("src/miniquake/host.ml")
    screen = text("src/miniquake/screen.ml")
    video = text("src/miniquake/gl_vidnt.ml")
    mixer = text("src/miniquake/sound/mixer.ml")
    world = text("src/miniquake/render/world.ml")
    hotpath_test = text("tests/opt001cr3_hotpath_tests.ml")
    runner = text("scripts/TEST_OPT-001D.ps1")
    collector = text("scripts/COLLECT_RESULTS.ps1")

    errors += marker_errors(build_info, (
        f'const OPTIMIZATION_STATUS = "{STATUS}"',
        f"const OPTIMIZATION_FINGERPRINT = {FINGERPRINT}",
        f'const OPTIMIZATION_PARENT = "{PARENT}"',
        f'const OPTIMIZATION_DELIVERY_REVISION = "{REV}"',
        f'const OPTIMIZATION_DELIVERY_PARENT = "{PARENT}"',
    ), "build_info")

    errors += marker_errors(host, (
        'registerCvar(registry, "_snd_mixahead", "0.35", true, false)',
        'mixer.update(session.mixer, session.timing.frameTime, frameMixAhead)',
        'titleFpsInitialized = false',
        'function updateTitle(session)',
        'win.setTitle(glvid.VID_WindowTitleForFps(fps))',
        'session.server.active,\n      session.client.signon',
        'rDrawEntities = cvar.variableValue(session.cvars, "r_drawentities") != 0.0',
    ), "host")
    if 'session.player.origin.x' in host[host.find('function updateTitle(session)'):host.find('end function', host.find('function updateTitle(session)'))]:
        errors.append("host updateTitle still exposes player coordinates")

    errors += marker_errors(video, (
        'function inline VID_WindowTitleForFps(fps)',
        'return "MiniQuake - " + safeFps + " FPS"',
        'win.create(VID_WindowTitleForFps(0), mode.width, mode.height, 0)',
        'win.create(VID_WindowTitleForFps(0), mode.width, mode.height, 1)',
    ), "video")

    errors += marker_errors(screen, (
        'function inline SCR_ShouldDrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive)',
        'if not connected or localServerActive or demoPlayback then return false end if',
        'if lastMessageTime <= 0.0 or realtime - lastMessageTime < 0.3 then return false end if',
        'SCR_DrawNet(realtime, lastMessageTime, demoPlayback, connected, localServerActive)',
    ), "screen")

    errors += marker_errors(mixer, (
        'channelCount = len(mixer.channels)',
        'while channelIndex < channelCount',
        'accumulatorCount = frameCount * 2',
    ), "mixer")
    errors += marker_errors(world, (
        'if currentLeaf == renderer.viewLeaf and len(renderer.visibleFaces) == len(map.faces) then',
        'return countVisibleFaces(renderer.visibleFaces)',
        'renderer.viewLeaf = -1',
    ), "world")

    inline_functions = 0
    inline_files: list[str] = []
    for path in sorted((root / "src").rglob("*.ml")):
        source = path.read_text(encoding="utf-8")
        count = len(re.findall(r"(?m)^\s*(?:static\s+)?function\s+inline\s+", source))
        if count:
            inline_functions += count
            inline_files.append(path.relative_to(root).as_posix())
    if inline_functions < 20:
        errors.append(f"aggressive scalar inline budget too small: {inline_functions} < 20")

    errors += marker_errors(hotpath_test, (
        'opt001dPassed = 0',
        'function opt001dCheck(condition, label)',
        'buildInfo.OPTIMIZATION_DELIVERY_REVISION == "OPT-001D"',
        'buildInfo.OPTIMIZATION_STATUS == "opt001d_performance_audio_ui_candidate_v1"',
        'video.VID_WindowTitleForFps(-10) == "MiniQuake - 0 FPS"',
        'screen.SCR_ShouldDrawNet(10.0, 9.0, false, true, false)',
    ), "hotpath test")
    errors += marker_errors(runner, (
        '$DeliveryRevision = "OPT-001D"',
        '$DeliveryParent = "OPT-001CR3R7"',
        '[int]$TransitionFrames = 256',
        '[int]$E1M2VisibleFrames = 1500',
        'OPT-001D audio cost analysis',
        'output_mode=python_binary_passthrough_named_build_binding',
    ), "runner")
    errors += marker_errors(collector, (
        '$DeliveryRevision = "OPT-001D"',
        '$DeliveryParent = "OPT-001CR3R7"',
        'MiniQuake_OPT-001D_RESULTS_',
    ), "collector")

    report = {
        "schema": "MiniQuakeOPT001CR3R8Static/2",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "delivery_revision": REV,
        "delivery_parent": PARENT,
        "audio_mixahead": 0.35,
        "pre_render_audio_top_up": True,
        "pvs_cache": True,
        "window_title": "MiniQuake - <fps> FPS",
        "disconnect_icon_local_suppressed": True,
        "inline_functions": inline_functions,
        "inline_files": inline_files,
        "transition_frames": 256,
        "visible_frames": 1500,
    }
    if args.json:
        Path(args.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake OPT-001D performance/audio/UI verification: " + report["status"])
    print(f"  inline_functions={inline_functions}")
    print("  audio_mixahead=0.35 pre_render_top_up=true")
    print("  title=MiniQuake - <fps> FPS")
    print("  local_disconnect_icon=false")
    for error in errors:
        print("  error: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
