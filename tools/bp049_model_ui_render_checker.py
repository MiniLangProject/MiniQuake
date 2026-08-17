#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the bp049 model ui render checker compatibility and regression contract."""

from __future__ import annotations
import json, pathlib, re, sys
ROOT = pathlib.Path(__file__).resolve().parents[1]
errors: list[str] = []
contract = (ROOT / "src/miniquake/model_ui_render_contract.ml").read_text(encoding="utf-8")
test = (ROOT / "tests/model_ui_render_closure_tests.ml").read_text(encoding="utf-8")
build = (ROOT / "src/miniquake/build_info.ml").read_text(encoding="utf-8")
for marker in (
    'const STATUS = "model_ui_render_109_frozen_v1"',
    'const FINGERPRINT = 0x0a62f5b1',
    'const EVIDENCE_SSIM_MILLI = 950',
    'const CAPTURE_AFTER_UI_BEFORE_SWAP = 1',
    'function verify()',
):
    if marker not in contract: errors.append(f"contract missing {marker!r}")
if "MiniQuake BP-049 model/UI/render closure tests passed: 24" not in test:
    errors.append("BP-049 fixture marker differs")
if test.count("bp049Run(") != 25:
    errors.append("BP-049 test does not contain 24 fixture calls")
# The closure contract remains a frozen parent of later deliveries.  Package
# identity advances from BP-049 onward, so this component checker binds only
# the status and fingerprint; the active delivery verifier owns PACKAGE_ID,
# PARENT_PACKAGE_ID and BLOCK_ID.
for marker in (
    'const MODEL_UI_RENDER_STATUS = "model_ui_render_109_frozen_v1"',
    'const MODEL_UI_RENDER_FINGERPRINT = 0x0a62f5b1',
):
    if marker not in build: errors.append(f"build info missing {marker!r}")
golden_path = ROOT / "audit/model_ui_render_closure_golden.json"
if not golden_path.is_file(): errors.append("closure golden file is missing")
else:
    golden=json.loads(golden_path.read_text(encoding="utf-8"))
    expected={"contract_fingerprint":174257585,"fixtures":24,"evidence_ssim_milli":950}
    for key,wanted in expected.items():
        if golden.get(key)!=wanted: errors.append(f"golden {key} differs")
if errors:
    print("MiniQuake BP-049 model/UI/render closure verification: FAIL")
    for item in errors: print("  "+item)
    raise SystemExit(1)
print("MiniQuake BP-049 model/UI/render closure verification: PASS")
print("  status=model_ui_render_109_frozen_v1 fingerprint=0x0a62f5b1 fixtures=24")
