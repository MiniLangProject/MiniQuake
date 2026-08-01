#!/usr/bin/env python3
import argparse, json, pathlib, sys

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    golden=json.loads((root/'audit/gameplay_presentation_golden.json').read_text())
    test=(root/'tests/gameplay_presentation_closure_tests.ml').read_text(encoding='utf-8-sig')
    contract=(root/'src/miniquake/gameplay_presentation_contract.ml').read_text(encoding='utf-8-sig')
    numbers=(root/'src/miniquake/host_command_numbers.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    server=(root/'src/miniquake/server.ml').read_text(encoding='utf-8-sig')
    for marker in ['MiniQuake BP-079 gameplay/presentation closure tests passed: 24','function testHostColorTrailing()','function testServerKickIndexPrefix()']:
        if marker not in test: errors.append('test missing: '+marker)
    for marker in ['const STATUS = "gameplay_presentation_109_frozen_v1"','const FINGERPRINT = 0xad91624c','host_color_parser=atoi','host_edict_parser=q_atoi','host_player_index_parser=q_atof']:
        if marker not in contract: errors.append('contract missing: '+marker)
    for marker in ['return native.trunc(common.atof(text)) - 1','return common.cAtoi(text)','function colorArguments(arguments, firstIndex)']:
        if marker not in numbers: errors.append('numbers missing: '+marker)
    for marker in ['hostNumbers.playerIndex(arguments[2])','hostNumbers.colorArguments(arguments, 1)','common.atoi(arguments[1])']:
        if marker not in host: errors.append('host missing: '+marker)
    for marker in ['hostNumbers.playerIndex(args[2])','hostNumbers.colorArguments(args, 1)','hostNumbers.integer(args[2])']:
        if marker not in server: errors.append('server missing: '+marker)
    for forbidden in ['top = toNumber(arguments[1])','frame = toNumber(arguments[1])','value = toNumber(args[2])']:
        if forbidden in host or forbidden in server: errors.append('legacy numeric parser remains: '+forbidden)
    if golden.get('host_edict_parser') != 'q_atoi': errors.append('golden edict parser mismatch')
    if golden.get('status')!='gameplay_presentation_109_frozen_v1': errors.append('golden status mismatch')
    if golden.get('fingerprint')!='0xad91624c': errors.append('golden fingerprint mismatch')
    if golden.get('fixtures')!=24: errors.append('golden fixtures mismatch')
    for key, value in {'crt_atoi_space_plus':12,'crt_atoi_hex':0,'crt_atoi_character':0,'q_atof_hex':3}.items():
        if golden.get(key) != value: errors.append(f'golden {key}: expected {value}, got {golden.get(key)!r}')
    report={'schema_version':1,'package':'BP-079','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':24,'fingerprint':'0xad91624c'}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-079 gameplay/presentation verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
