#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,pathlib

def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json-out','--json-output',dest='out'); ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
 contract=(root/'src/miniquake/render_ui_contract.ml').read_text(encoding='utf-8-sig'); screen=(root/'src/miniquake/screen.ml').read_text(encoding='utf-8-sig'); status=(root/'src/miniquake/statusbar.ml').read_text(encoding='utf-8-sig'); entities=(root/'src/miniquake/render/entities.ml').read_text(encoding='utf-8-sig'); tests=(root/'tests/render_ui_hud_parity_tests.ml').read_text(encoding='utf-8-sig')
 for marker in ['function statusbarXOffset(width, gameType)','function overlayOrder(dialog, loading, intermission, gameInput)','function set2dStateOrder()','function tgaByteLength(width, height)','function viewModelDepthMaximum()']:
  if marker not in contract: errors.append('contract missing '+marker)
 for text,marker in [(screen,'return renderUiContract.overlayOrder'),(status,'return renderUiContract.statusbarXOffset'),(entities,'renderUiContract.viewModelDepthMaximum()')]:
  if marker not in text: errors.append('production integration missing '+marker)
 if tests.count('if bp047Run(')!=24: errors.append('BP-047 fixture count differs')
 report={'schema_version':1,'component':'BP-047','passed':not errors,'fixtures':24,'errors':errors}; out=json.dumps(report,indent=2)+'\n'; print(out,end='')
 if ns.out:pathlib.Path(ns.out).write_text(out)
 return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
