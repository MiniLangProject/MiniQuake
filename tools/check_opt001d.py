# Copyright (c) 2026 Nils Kopal
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Validate the current OPT-001D performance contract without false positives."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def has_legacy_window_title(source: str) -> bool:
    """Return true only when executable MiniLang still creates a GLQuake title."""

    patterns = (
        r'(?m)^\s*return\s+"GLQuake(?:\s*-.*?)?"',
        r'(?m)^\s*(?:created\s*=\s*try\()?win\.create\(\s*"GLQuake',
        r'(?m)^\s*win\.setTitle\(\s*"GLQuake',
    )
    return any(re.search(pattern, source) is not None for pattern in patterns)


def main() -> int:
    """Run the OPT-001D static contract checks and optionally write JSON."""

    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    errors: list[str] = []

    audit_path = root / "audit" / "opt001d_60fps_renderer_audio.json"
    if not audit_path.exists():
        errors.append("missing OPT-001D audit")
    else:
        audit = json.loads(audit_path.read_text(encoding="utf-8"))
        if audit.get("revision") != "OPT-001D":
            errors.append("wrong revision")
        if audit.get("goal", {}).get("minimum_render_fps") != 60:
            errors.append("60 FPS target not bound")
        if audit.get("transformations", {}).get("inline_functions_added", 0) < 3:
            errors.append("insufficient safe inline candidates")

    source = "\n".join(
        path.read_text(encoding="utf-8") for path in (root / "src").rglob("*.ml")
    )
    if has_legacy_window_title(source):
        errors.append("production source still contains GLQuake window title")

    runner_path = root / "TEST_OPT-001D.ps1"
    if not runner_path.exists():
        errors.append("missing test runner")
    elif "Test-OPT001D60FpsGate" not in runner_path.read_text(encoding="utf-8"):
        errors.append("missing 60 FPS runtime gate")

    result = {
        "schema": "MiniQuakeOPT001DCheck/1",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
    }
    if args.json:
        Path(args.json).write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    print("MiniQuake OPT-001D verification: " + result["status"])
    for error in errors:
        print("ERROR: " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
