#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify the bp048 render evidence checker compatibility and regression contract."""

from __future__ import annotations
import json, pathlib, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
errors: list[str] = []
source = (ROOT / "src/miniquake/render_evidence.ml").read_text(encoding="utf-8")
host = (ROOT / "src/miniquake/host.ml").read_text(encoding="utf-8")
main = (ROOT / "src/main.ml").read_text(encoding="utf-8")
test = (ROOT / "tests/render_evidence_tests.ml").read_text(encoding="utf-8")
for marker in (
    "const EVIDENCE_SCHEMA = 1", "const SAMPLE_GRID = 16",
    "function samplePixelHash", "function captureIfRequested",
    "capture_stage\\\":\\\"after_ui_before_swap",
):
    if marker not in source: errors.append(f"render_evidence.ml missing {marker!r}")
if "renderEvidence.captureIfRequested" not in host:
    errors.append("host render path does not call renderEvidence.captureIfRequested")
else:
    capture = host.index("renderEvidence.captureIfRequested")
    screen = host.rfind("screen.SCR_UpdateScreen", 0, capture)
    swap = host.find("glvid.GL_EndRendering", capture)
    if screen < 0 or swap < 0 or not (screen < capture < swap):
        errors.append("render evidence capture is not ordered after UI and before swap")
if "--render-evidence" not in main or "runRenderEvidenceCommand" not in main:
    errors.append("main command dispatch is missing --render-evidence")
# R3 keeps the rendered window but isolates the evidence session from the
# asynchronous desktop input conveniences used by the interactive port.
for marker in (
    '"-nolan"', '"-nomouse"', '"-nojoy"', '"-noinput"',
):
    if marker not in main:
        errors.append(f"render evidence launch is missing deterministic flag {marker}")
for marker in (
    "function deterministicInputRequested",
    'common.hasParm(session.arguments, "-noinput")',
    "inputSuppressed = deterministicInputRequested(session)",
    "input.IN_ClearStates()",
    "input.clear(command)",
    "pollButtonBindings = not inputSuppressed",
    "deviceActive = not inputSuppressed",
    "keys.Key_ClearStates()",
):
    if marker not in host:
        errors.append(f"host render-evidence input isolation is missing {marker!r}")
if "MiniQuake BP-048 render evidence tests passed: 18" not in test:
    errors.append("BP-048 fixture count marker differs")
if test.count("bp048Run(") != 19:  # definition + 18 calls
    errors.append("BP-048 test does not contain 18 fixture calls")
# R2 binds JSON syntax through the byte-oriented API. String indexing is not a
# byte contract, so the old text[1] == 34 assertion must never return.
for marker in (
    "encoded = bytes(text)",
    "encoded[0], 123",
    "encoded[1], 34",
    "encoded[len(encoded) - 2], 125",
    "encoded[len(encoded) - 1], 10",
):
    if marker not in test:
        errors.append(f"BP-048 R2 summary fixture is missing {marker!r}")
if re.search(r"\btext\s*\[\s*1\s*\]\s*==\s*34\b", test):
    errors.append("BP-048 fixture compares a string element directly with byte value 34")

golden_path = ROOT / "audit/render_evidence_golden.json"
if golden_path.is_file():
    golden = json.loads(golden_path.read_text(encoding="utf-8"))
    for key, wanted in {"schema": 1, "sample_grid": 16, "fixtures": 18}.items():
        if golden.get(key) != wanted: errors.append(f"golden {key} differs")
else:
    errors.append("render evidence golden file is missing")

if errors:
    print("MiniQuake BP-048 render evidence verification: FAIL")
    for item in errors: print("  " + item)
    raise SystemExit(1)
print("MiniQuake BP-048 render evidence verification: PASS")
print("  schema=1 sample_grid=16 fixtures=18 stage=after_ui_before_swap")
