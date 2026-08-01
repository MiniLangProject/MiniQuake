#!/usr/bin/env python3
import argparse, json, pathlib, re, sys

NAMES = [
    "CDAudio_Eject", "CDAudio_CloseDoor", "CDAudio_GetAudioDiskInfo",
    "CDAudio_MessageHandler",
]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    source = (root / "src/miniquake/sound/cd_audio.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/cd_audio_source_surface_tests.ml").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/cd_audio_source_surface_golden.json").read_text())

    for name in NAMES:
        count = len(re.findall(rf"(?m)^\s*function\s+{re.escape(name)}\s*\(", source))
        if count != 1:
            errors.append(f"{name}: expected one technical-equivalent function, found {count}")
    for marker in [
        "const MCI_NOTIFY_SUCCESSFUL = 1",
        "const MCI_NOTIFY_SUPERSEDED = 2",
        "const MCI_NOTIFY_ABORTED = 4",
        "const MCI_NOTIFY_FAILURE = 8",
        "if not deviceMatches then return 1 end if",
        "state.valid = false",
    ]:
        if marker not in source:
            errors.append("missing source marker: " + marker)
    if golden.get("original_function_names") != NAMES:
        errors.append("golden technical-equivalent list differs")
    if golden.get("fixture_count") != 20:
        errors.append("golden fixture_count must be 20")
    if "MiniQuake BP-081 CD audio source-surface tests passed: 20" not in test:
        errors.append("runtime success marker missing")

    report = {
        "schema_version": 1,
        "package": "BP-081",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "technical_equivalents": len(NAMES),
        "fixtures": 20,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n")
    print("MiniQuake BP-081 CD audio source-surface verification: " + report["status"])
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
