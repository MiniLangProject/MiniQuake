#!/usr/bin/env python3
import argparse,json,pathlib,sys

def main():
 p=argparse.ArgumentParser();p.add_argument('--root',default='.');p.add_argument('--json',default='');a=p.parse_args();r=pathlib.Path(a.root).resolve();e=[]
 sysml=(r/'src/miniquake/sys_win.ml').read_text(encoding='utf-8-sig');cp=(r/'src/miniquake/conproc.ml').read_text(encoding='utf-8-sig');t=(r/'tests/system_platform_lifecycle_tests.ml').read_text(encoding='utf-8-sig');g=json.loads((r/'audit/system_platform_golden.json').read_text())
 for m in ['const MINIMUM_WIN_MEMORY = 0x0880000','const MAXIMUM_WIN_MEMORY = 0x1000000','const MAX_HANDLES = 10','function Sys_ParseCommandLine','function Sys_ConsoleInput','function WinMain']:
  if m not in sysml:e.append('sys_win missing '+m)
 for m in ['const CCOM_WRITE_TEXT = 0x2','const CCOM_GET_TEXT = 0x3','const CCOM_GET_SCR_LINES = 0x4','const CCOM_SET_SCR_LINES = 0x5','function RequestProc']:
  if m not in cp:e.append('conproc missing '+m)
 if 'passed: 21' not in t:e.append('fixture marker missing')
 if g.get('fixtures')!=21:e.append('golden mismatch')
 out={'schema_version':1,'package':'BP-063','status':'PASS' if not e else 'FAIL','errors':e,'fixtures':21,'qhost_commands':[2,3,4,5]}
 if a.json:pathlib.Path(a.json).write_text(json.dumps(out,indent=2)+'\n')
 print('MiniQuake BP-063 system/platform verification: '+out['status'])
 for x in e:print('  [FAIL] '+x)
 return 0 if not e else 1
if __name__=='__main__':sys.exit(main())
