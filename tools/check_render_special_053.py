#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, pathlib, subprocess, sys

def emit_report(path, name, passed, details, errors):
    if not path:
        return
    payload = {"schema": 1, "check": name, "status": "PASS" if passed else "FAIL", "passed": passed, "details": details, "errors": errors}
    pathlib.Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def main() -> int:
    ap=argparse.ArgumentParser(); ap.add_argument('--root', default=str(pathlib.Path(__file__).resolve().parents[1])); ap.add_argument('--json-output'); a=ap.parse_args(); root=pathlib.Path(a.root).resolve(); errors=[]
    corpus=(root/'src/miniquake/render_evidence_corpus.ml').read_text(encoding='utf-8')
    test=(root/'tests/render_evidence_corpus_tests.ml').read_text(encoding='utf-8')
    comparator=(root/'tools/compare_render_corpus.py').read_text(encoding='utf-8')
    golden=json.loads((root/'audit/render_evidence_corpus_golden.json').read_text(encoding='utf-8'))
    for marker in ('const CORPUS_SCHEMA = 1','const CAPTURE_WIDTH = 640','const CAPTURE_HEIGHT = 480','const ORIGINAL_SSIM_MILLI = 950','["start-064", "start", 64]','["e1m1-128", "e1m1", 128]'):
        if marker not in corpus: errors.append(f'corpus module missing {marker}')
    for marker in ('SCENARIOS = ("start-064", "start-128", "e1m1-128")','MIN_SSIM = 0.95','original_reference_supplied'):
        if marker not in comparator: errors.append(f'corpus comparator missing {marker}')
    if test.count('bp053Run(')!=19: errors.append('BP-053 test does not contain 18 fixture calls')
    if 'MiniQuake BP-053 render-evidence corpus tests passed: 18' not in test: errors.append('BP-053 pass marker differs')
    if golden.get('fixtures')!=18 or len(golden.get('scenarios',[]))!=3: errors.append('BP-053 golden differs')
    if not errors:
        run=subprocess.run([sys.executable,str(root/'tools/compare_render_corpus.py'),'--root',str(root),'--self-test'],capture_output=True,text=True)
        if run.returncode!=0: errors.append('corpus comparator self-test failed: '+run.stdout+run.stderr)
    details={"root": str(root), "error_count": len(errors)}
    if errors:
        emit_report(a.json_output, 'bp053_render_evidence_corpus', False, details, errors)
        print('MiniQuake BP-053 render-evidence corpus verification: FAIL'); [print('  '+e) for e in errors]; return 1
    emit_report(a.json_output, 'bp053_render_evidence_corpus', True, details, [])
    print('MiniQuake BP-053 render-evidence corpus verification: PASS')
    print('  fixtures=18 scenarios=3 exact_pairs=required original_ssim=0.95')
    return 0
if __name__=='__main__': raise SystemExit(main())
