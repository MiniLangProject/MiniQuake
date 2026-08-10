#!/usr/bin/env python3
import argparse, json, pathlib, re, sys

EXPECTED_STATUS = 'game_profile_109_frozen_v1'
EXPECTED_FINGERPRINT = '0x7a03b68d'
EXPECTED_FIXTURES = 22

def fnv1a32(data: bytes) -> int:
    value = 0x811C9DC5
    for byte in data:
        value ^= byte
        value = (value * 0x01000193) & 0xFFFFFFFF
    return value

def _const_string(source: str, name: str) -> str:
    match = re.search(rf'^const\s+{re.escape(name)}\s*=\s*"([^"]+)"\s*$', source, flags=re.M)
    return match.group(1) if match else ""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ap.add_argument("--allow-downstream-package", action="store_true")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    golden_path = root / "audit/game_profile_golden.json"
    module_path = root / "src/miniquake/game_profile.ml"
    test_path = root / "tests/game_profile_compat_tests.ml"
    build_info_path = root / "src/miniquake/build_info.ml"
    for path in [golden_path, module_path, test_path, build_info_path]:
        if not path.is_file():
            errors.append("missing file: " + str(path.relative_to(root)))
    golden = {}
    if golden_path.is_file():
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
    source = module_path.read_text(encoding="utf-8-sig") if module_path.is_file() else ""
    test = test_path.read_text(encoding="utf-8-sig") if test_path.is_file() else ""
    build_info = build_info_path.read_text(encoding="utf-8-sig") if build_info_path.is_file() else ""
    contract_text = golden.get("contract_text", "")
    calculated = f"0x{fnv1a32(contract_text.encode('utf-8')):08x}"
    if golden.get("status") != EXPECTED_STATUS: errors.append("golden status differs")
    if golden.get("fingerprint") != EXPECTED_FINGERPRINT: errors.append("golden fingerprint differs")
    if calculated != EXPECTED_FINGERPRINT: errors.append(f"fingerprint calculation: expected {EXPECTED_FINGERPRINT}, got {calculated}")
    if golden.get("fixtures") != EXPECTED_FIXTURES: errors.append("golden fixture count differs")
    for text in [f'const STATUS = "{EXPECTED_STATUS}"', f'const FINGERPRINT = {EXPECTED_FINGERPRINT}']:
        if text not in source: errors.append("missing module marker: " + text)
    if 'MiniQuake BP-085 game-profile tests passed: 22' not in test: errors.append("runtime success marker missing")
    package_id = _const_string(build_info, "PACKAGE_ID")
    parent_package_id = _const_string(build_info, "PARENT_PACKAGE_ID")
    block_id = _const_string(build_info, "BLOCK_ID")
    if ns.allow_downstream_package:
        if not package_id: errors.append("downstream build info has no PACKAGE_ID")
        if not parent_package_id: errors.append("downstream build info has no PARENT_PACKAGE_ID")
        if not block_id: errors.append("downstream build info has no BLOCK_ID")
    else:
        for text in [
            'const PACKAGE_ID = "BP-089"',
            'const PARENT_PACKAGE_ID = "BP-088"',
            'const BLOCK_ID = "BP-085-089"',
        ]:
            if text not in build_info: errors.append("missing build marker: " + text)
    report = {
        "schema_version": 1,
        "package": "BP-094" if ns.allow_downstream_package else "BP-085",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "downstream_package": bool(ns.allow_downstream_package),
        "build_package_id": package_id,
        "build_parent_package_id": parent_package_id,
        "build_block_id": block_id,
        "contract_status": golden.get("status"),
        "fingerprint": calculated,
        "fixtures": EXPECTED_FIXTURES,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake BP-085 game profile verification: " + report["status"])
    if not errors:
        print(
            f"  status={EXPECTED_STATUS} fingerprint={EXPECTED_FINGERPRINT} fixtures={EXPECTED_FIXTURES} "
            f"downstream={str(bool(ns.allow_downstream_package)).lower()} package={package_id} block={block_id}"
        )
    for error in errors: print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
