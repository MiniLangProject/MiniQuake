#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, pathlib

def emit_report(path, name, passed, details, errors):
    if not path:
        return
    payload = {"schema": 1, "check": name, "status": "PASS" if passed else "FAIL", "passed": passed, "details": details, "errors": errors}
    pathlib.Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def _const_string(source: str, name: str) -> str:
    import re
    match = re.search(rf'^const\s+{name}\s*=\s*"([^"]+)"\s*$', source, flags=re.M)
    return match.group(1) if match else ""

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument('--root', default=str(pathlib.Path(__file__).resolve().parents[1]))
    ap.add_argument('--json-output')
    ap.add_argument(
        '--allow-downstream-package',
        action='store_true',
        help='verify the frozen BP-054 semantic contract inside a later package identity',
    )
    a=ap.parse_args(); root=pathlib.Path(a.root).resolve(); errors=[]
    contract=(root/'src/miniquake/render_special_contract.ml').read_text(encoding='utf-8')
    test=(root/'tests/render_special_closure_tests.ml').read_text(encoding='utf-8')
    build=(root/'src/miniquake/build_info.ml').read_text(encoding='utf-8')
    golden=json.loads((root/'audit/render_special_closure_golden.json').read_text(encoding='utf-8'))
    for marker in ('const STATUS = "render_special_109_frozen_v1"','const FINGERPRINT = 0x2a3d8081','const SPECIAL_RENDER_STAGE_COUNT = 12','const ORIGINAL_REFERENCE_EXTERNAL = 1','function verify()'):
        if marker not in contract: errors.append(f'contract missing {marker}')
    if test.count('bp054Run(')!=25: errors.append('BP-054 test does not contain 24 fixture calls')
    if 'MiniQuake BP-054 render-special closure tests passed: 24' not in test: errors.append('BP-054 pass marker differs')
    if 'import miniquake.common as bp054Common' not in test: errors.append('BP-054 cvar fixture does not import the canonical command-line constructor')
    if 'commandLine = bp054Common.create([])' not in test: errors.append('BP-054 cvar fixture does not construct a CommandLine value')
    if 'bp054Host.createCvars(commandLine, true)' not in test: errors.append('BP-054 cvar fixture does not pass the CommandLine struct to host.createCvars')
    if 'bp054Host.createCvars("", true)' in test: errors.append('BP-054 cvar fixture still passes a string to host.createCvars')
    # The logical contract remains BP-054, but later delivery blocks carry it
    # forward under their own package identity.  Bind the historical package
    # identity only when checking BP-054 itself; downstream packages bind the
    # unchanged status and fingerprint while their own identity is verified by
    # tools/verify.py.  This mirrors the accepted QuakeC frozen-contract check.
    package_id = _const_string(build, 'PACKAGE_ID')
    parent_package_id = _const_string(build, 'PARENT_PACKAGE_ID')
    block_id = _const_string(build, 'BLOCK_ID')
    for marker in (
        'const RENDER_SPECIAL_STATUS = "render_special_109_frozen_v1"',
        'const RENDER_SPECIAL_FINGERPRINT = 0x2a3d8081',
    ):
        if marker not in build: errors.append(f'build info missing {marker}')
    if a.allow_downstream_package:
        if not package_id: errors.append('downstream build info has no PACKAGE_ID')
        if not parent_package_id: errors.append('downstream build info has no PARENT_PACKAGE_ID')
        if not block_id: errors.append('downstream build info has no BLOCK_ID')
    else:
        for marker in (
            'const PACKAGE_ID = "BP-054"',
            'const PARENT_PACKAGE_ID = "BP-053"',
            'const BLOCK_ID = "BP-050-054"',
        ):
            if marker not in build: errors.append(f'build info missing {marker}')
    expected={'fixtures':24,'total_block_fixtures':104,'fingerprint':708673665,'special_stage_count':12}
    for k,v in expected.items():
        if golden.get(k)!=v: errors.append(f'BP-054 golden {k} differs')
    details={
        "root": str(root),
        "error_count": len(errors),
        "cvar_fixture_command_line": "miniquake.common.create([])",
        "downstream_package": bool(a.allow_downstream_package),
        "build_package_id": package_id,
        "build_parent_package_id": parent_package_id,
        "build_block_id": block_id,
    }
    if errors:
        emit_report(a.json_output, 'bp054_render_special_closure', False, details, errors)
        print('MiniQuake BP-054 render-special closure verification: FAIL'); [print('  '+e) for e in errors]; return 1
    emit_report(a.json_output, 'bp054_render_special_closure', True, details, [])
    print('MiniQuake BP-054 render-special closure verification: PASS')
    print('  status=render_special_109_frozen_v1 fingerprint=0x2a3d8081 fixtures=24')
    return 0
if __name__=='__main__': raise SystemExit(main())
