#!/usr/bin/env python3
from __future__ import annotations
import argparse,json,pathlib

def main():
 ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json-out','--json-output',dest='out'); ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
 types=(root/'src/miniquake/types.ml').read_text(encoding='utf-8-sig'); client=(root/'src/miniquake/client.ml').read_text(encoding='utf-8-sig'); entities=(root/'src/miniquake/render/entities.ml').read_text(encoding='utf-8-sig'); host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig'); trace=(root/'src/miniquake/compat_trace.ml').read_text(encoding='utf-8-sig'); tests=(root/'tests/sprite_sync_parity_tests.ml').read_text(encoding='utf-8-sig')
 for label,text,marker in [('types',types,'  syncBase\nend struct'),('client',client,'function CL_AssignModelSyncBase(entity, previousModelIndex)'),('entities',entities,'time + entity.syncBase'),('host',host,'client.CL_SetModelSyncTypes(syncTypes)'),('trace',trace,'item.syncBase')]:
  if marker not in text: errors.append(f'{label} missing marker: {marker}')
 if tests.count('if bp046Run(')!=22: errors.append('BP-046 fixture count differs from 22')
 golden=json.loads((root/'audit/sprite_sync_golden.json').read_text()); vals={r['name']:r['value'] for r in golden['rows']}
 if vals.get('first_rand')!=41 or vals.get('first_sync_bits')!=0x3aa40148: errors.append('first random syncbase golden differs')
 report={'schema_version':1,'component':'BP-046','passed':not errors,'fixtures':22,'errors':errors}; out=json.dumps(report,indent=2)+'\n'; print(out,end='')
 if ns.out:pathlib.Path(ns.out).write_text(out)
 return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
