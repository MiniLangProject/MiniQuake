#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys


def _const_string(source: str, name: str) -> str:
    match = re.search(rf'^const\s+{name}\s*=\s*"([^"]+)"\s*$', source, flags=re.M)
    return match.group(1) if match else ""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', default='.')
    parser.add_argument('--json', default='')
    parser.add_argument('--json-output', default='')
    parser.add_argument(
        '--allow-downstream-package',
        action='store_true',
        help='verify the frozen BP-069 frontend contract inside a later package identity',
    )
    args = parser.parse_args()
    root = pathlib.Path(args.root).resolve()
    errors: list[str] = []

    contract = (root / 'src/miniquake/frontend_contract.ml').read_text(encoding='utf-8-sig')
    build = (root / 'src/miniquake/build_info.ml').read_text(encoding='utf-8-sig')
    test = (root / 'tests/video_frontend_closure_tests.ml').read_text(encoding='utf-8-sig')
    golden = json.loads((root / 'audit/frontend_closure_golden.json').read_text(encoding='utf-8'))

    for marker in (
        'const STATUS = "frontend_109_frozen_v1"',
        'const FINGERPRINT = 0x924251fa',
        'const KEY_COUNT = 256',
        'const CONSOLE_TEXT_BYTES = 16384',
        'const MAX_VIDEO_MODES = 30',
    ):
        if marker not in contract:
            errors.append('frontend_contract.ml missing marker: ' + marker)

    for marker in (
        'const FRONTEND_STATUS = "frontend_109_frozen_v1"',
        'const FRONTEND_FINGERPRINT = 0x924251fa',
    ):
        if marker not in build:
            errors.append('build_info.ml missing marker: ' + marker)

    package_id = _const_string(build, 'PACKAGE_ID')
    parent_package_id = _const_string(build, 'PARENT_PACKAGE_ID')
    block_id = _const_string(build, 'BLOCK_ID')

    # Keep the original BP-069 package-identity check in strict historical mode.  Later delivery
    # blocks carry the frozen frontend contract forward under their own package
    # identity, which is independently bound by tools/verify.py.
    if args.allow_downstream_package:
        if not package_id:
            errors.append('downstream build info has no PACKAGE_ID')
        if not parent_package_id:
            errors.append('downstream build info has no PARENT_PACKAGE_ID')
        if not block_id:
            errors.append('downstream build info has no BLOCK_ID')
    else:
        for marker in (
            'const PACKAGE_ID = "BP-069"',
            'const PARENT_PACKAGE_ID = "BP-068"',
            'const BLOCK_ID = "BP-065-069"',
        ):
            if marker not in build:
                errors.append('build_info.ml missing marker: ' + marker)

    if 'MiniQuake BP-069 frontend closure tests passed: 24' not in test:
        errors.append('fixture count marker missing')
    if golden.get('fixtures') != 24 or golden.get('fingerprint') != '0x924251fa':
        errors.append('golden mismatch')

    report = {
        'schema_version': 1,
        'package': 'BP-069',
        'status': 'PASS' if not errors else 'FAIL',
        'errors': errors,
        'fixtures': 24,
        'contract_status': 'frontend_109_frozen_v1',
        'fingerprint': '0x924251fa',
        'downstream_package': bool(args.allow_downstream_package),
        'build_package_id': package_id,
        'build_parent_package_id': parent_package_id,
        'build_block_id': block_id,
    }
    output = args.json_output or args.json
    if output:
        pathlib.Path(output).write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')

    print('MiniQuake BP-069 frontend closure verification: ' + report['status'])
    for error in errors:
        print('  [FAIL] ' + error)
    if not errors:
        print(
            '  status=frontend_109_frozen_v1 fingerprint=0x924251fa fixtures=24 '
            f'downstream={str(bool(args.allow_downstream_package)).lower()} '
            f'package={package_id} block={block_id}'
        )
    return 0 if not errors else 1


if __name__ == '__main__':
    raise SystemExit(main())
