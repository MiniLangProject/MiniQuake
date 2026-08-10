#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, pathlib, sys

EXPECTED_SHA = "04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588"

def main() -> int:
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default=''); ns=ap.parse_args()
    root=pathlib.Path(ns.root).resolve(); errors=[]
    required=[
        'src/miniquake/external_reference_contract.ml','tests/original_reference_provenance_tests.ml',
        'tools/prepare_original_reference.py','audit/original_reference_golden.json',
        'TEST_BP-090-094R6.ps1'
    ]
    for rel in required:
        if not (root/rel).is_file(): errors.append('missing file: '+rel)
    def read(rel): return (root/rel).read_text(encoding='utf-8-sig') if (root/rel).is_file() else ''
    contract=read(required[0]); test=read(required[1]); tool=read(required[2]); harness=read(required[-1])
    markers=[
        f'const ORIGINAL_GLQUAKE_SHA256 = "{EXPECTED_SHA}"',
        'const ORIGINAL_GLQUAKE_BYTES = 435712','const ORIGINAL_GLQUAKE_PE_MACHINE = 0x014c',
        'const ORIGINAL_REFERENCE_FINGERPRINT = 0xdc355175',
        'function referenceContractText()','function referenceContractHasRequiredFields()',
        'referenceContractHasRequiredFields() and',
    ]
    for marker in markers:
        if marker not in contract: errors.append('missing contract marker: '+marker)
    if 'MiniQuake BP-090 original reference tests passed: 20' not in test: errors.append('runtime marker missing')
    for marker in [f'EXPECTED_SHA256 = "{EXPECTED_SHA}"','EXPECTED_SIZE = 435_712','EXPECTED_MACHINE = 0x014C','EXPECTED_MEMBER = "kit/GLQUAKE.EXE"','legacy_opengl32_staged": False']:
        if marker not in tool: errors.append('stager marker missing: '+marker)
    for marker in ['prepare_original_reference.py','-OriginalQuakeSourceArchive','-OriginalGLQuakeExe','verified original GLQuake reference']:
        if marker not in harness: errors.append('acceptance marker missing: '+marker)
    forbidden=[p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file() and p.name.lower()=='glquake.exe']
    if forbidden: errors.append('original GLQUAKE.EXE must not be redistributed: '+', '.join(forbidden))
    report={'schema_version':1,'package':'BP-094','step':'BP-090','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':20,'reference_sha256':EXPECTED_SHA,'redistributed':False}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2,sort_keys=True)+'\n',encoding='utf-8')
    print('MiniQuake BP-090 original reference verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
