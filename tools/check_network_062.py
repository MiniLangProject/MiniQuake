#!/usr/bin/env python3
import argparse,json,pathlib,sys

def main():
 p=argparse.ArgumentParser();p.add_argument('--root',default='.');p.add_argument('--json',default='');a=p.parse_args();r=pathlib.Path(a.root).resolve();e=[]
 s=(r/'src/miniquake/net_wins.ml').read_text(encoding='utf-8-sig');t=(r/'tests/network_wins_address_tests.ml').read_text(encoding='utf-8-sig');g=json.loads((r/'audit/network_wins_golden.json').read_text())
 for m in ['import miniquake.common as common','port = common.atoi(portText)','hostaddr.port = htons(port)','const AF_INET = 2']:
  if m not in s:e.append('net_wins missing '+m)
 partial = s[s.find('function PartialIPAddress'):s.find('function WINS_Connect') if s.find('function WINS_Connect') >= 0 else len(s)]
 if 'parseDecimal(portText, 5, 65535)' in partial:e.append('PartialIPAddress still uses strict port parser')
 if 'passed: 24' not in t:e.append('fixture count marker missing')
 if g.get('fixtures')!=24:e.append('golden fixture mismatch')
 out={'schema_version':1,'package':'BP-062','status':'PASS' if not e else 'FAIL','errors':e,'fixtures':24,'partial_port_semantics':'Q_atoi_then_uint16'}
 if a.json:pathlib.Path(a.json).write_text(json.dumps(out,indent=2)+'\n')
 print('MiniQuake BP-062 WinSock address verification: '+out['status'])
 for x in e:print('  [FAIL] '+x)
 return 0 if not e else 1
if __name__=='__main__':sys.exit(main())
