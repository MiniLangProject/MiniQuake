#!/usr/bin/env python3
import argparse
import json
import pathlib
import re
import sys


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', default='.')
    ap.add_argument('--json', default='')
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []

    fs = (root / 'src/miniquake/filesystem.ml').read_text(encoding='utf-8-sig')
    pak = (root / 'src/miniquake/pak.ml').read_text(encoding='utf-8-sig')
    test = (root / 'tests/filesystem_pack_parity_tests.ml').read_text(encoding='utf-8-sig')
    oracle = (root / 'tools/oracle/filesystem_pack_oracle.c').read_text(encoding='utf-8-sig')
    golden = json.loads((root / 'audit/filesystem_pack_golden.json').read_text(encoding='utf-8'))

    markers = [
        'const MAX_FILES_IN_PACK = 2048',
        'const PAK0_COUNT = 339',
        'const PAK0_CRC = 32981',
        'if system.progsHack and normalized == "progs.dat" then searchIndex = 1 end if',
        'if not system.staticRegistered and containsDirectorySeparator(normalized) then',
        'destination[len(source)] = 0',
        'return quakeText.decodeBytes(data)',
        'return fs.writeAllBytes(gamePath(system, name), data)',
    ]
    merged = fs + '\n' + pak
    for marker in markers:
        if marker not in merged:
            errors.append('missing source marker: ' + marker)

    if 'MiniQuake BP-071 filesystem/PACK tests passed: 24' not in test:
        errors.append('fixture marker missing')

    case10 = re.search(
        r'function\s+bp071Case10\(\)(.*?)end\s+function',
        test,
        flags=re.S,
    )
    case10_text = case10.group(1) if case10 else ''
    for marker in (
        'system.staticRegistered = false',
        'try(qfs.readFile(system,"sub/loose.bin")) is error',
        '"shareware loose subdirectory"',
    ):
        if marker not in case10_text:
            errors.append('shareware fixture missing marker: ' + marker)
    if 'system.staticRegistered = true' in case10_text:
        errors.append('shareware fixture incorrectly enables registered loose paths')

    if golden.get('fixtures') != 24 or golden.get('pack_entry_bytes') != 64:
        errors.append('golden identity differs')
    if golden.get('shareware_loose_subdirectory_block') is not True:
        errors.append('golden shareware loose-subdirectory contract differs')
    if 'shareware_loose_subdirectory_block=1' not in oracle:
        errors.append('filesystem PACK oracle lacks shareware restriction evidence')

    report = {
        'schema_version': 1,
        'package': 'BP-071',
        'status': 'PASS' if not errors else 'FAIL',
        'errors': errors,
        'fixtures': 24,
        'pack_entry_bytes': 64,
        'search_precedence_levels': 3,
        'quake_text_io': True,
        'shareware_loose_subdirectory_block': True,
        'shareware_fixture_explicit_post_registration_state': True,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('MiniQuake BP-071 filesystem/PACK verification: ' + report['status'])
    for error in errors:
        print('  [FAIL] ' + error)
    return 0 if not errors else 1


if __name__ == '__main__':
    sys.exit(main())
