#!/usr/bin/env python3
# Copyright (c) 1996-1997 Id Software, Inc.
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: GPL-2.0-or-later

"""Verify BP-033 WinQuake savegame-v5 byte and parsing contracts."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, struct, subprocess, tempfile
from pathlib import Path
P='BP-033'; PAR='BP-032'; G='audit/savegame_v5_golden.json'; O='tools/oracle/savegame_v5_oracle.c'
def sha(path):
    """Compute the SHA-256 digest of the requested file."""
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def f32(value):
    """Round a value through the IEEE-754 binary32 representation."""
    return struct.unpack('<f', struct.pack('<f', value))[0]
def fbits(value):
    """Return the IEEE-754 binary32 bit pattern for a Python float."""
    return struct.unpack('<I', struct.pack('<f', value))[0]
def fnv(data):
    """Compute the fixture's FNV-1a fingerprint."""
    h=2166136261
    for value in data: h=((h^value)*16777619)&0xffffffff
    return h
def comment(level,killed,total):
    """Encode the fixed-width Quake v5 savegame level comment."""
    out=bytearray(b' '*39); raw=level[:39]; out[:len(raw)]=raw
    kills=f'kills:{killed:3d}/{total:3d}'.encode('latin1'); out[22:22+len(kills)]=kills
    return bytes(95 if value==32 else value for value in out)
def rows(downstream=False):
    """Build the deterministic result rows for this verifier."""
    result=[
      {'kind':'case','name':'savegame_version','value':5},
      {'kind':'case','name':'comment_length','value':39},
      {'kind':'case','name':'comment_fnv1a','value':fnv(comment(b'Start',2,9))},
      {'kind':'case','name':'spawn_0_1_bits','value':fbits(0.100000001)},
    ]
    if downstream:
        result.append({'kind':'case','name':'spawn_negative_zero_bits','value':0x80000000})
    result.extend([
      {'kind':'case','name':'skill_1_9_bits','value':fbits(1.9)},
      {'kind':'case','name':'legacy_skill_result','value':int(f32(f32(1.9)+f32(0.1)))},
      {'kind':'case','name':'time_bits','value':fbits(12.3456789)},
      {'kind':'case','name':'spawn_parms','value':16},
      {'kind':'case','name':'lightstyles','value':64},
      {'kind':'case','name':'fixture_count','value':24},
    ])
    return result
def doc(root,downstream=False):
    """Render the canonical evidence document for this verifier."""
    return {'schema':'MiniQuakeSavegameV5Golden/1','package_id':P,'parent_package_id':PAR,'sources':['host_cmd.c','pr_edict.c'],'rows':rows(downstream),'reference':{'oracle':O,'oracle_sha256':sha(root/O)}}
def compiler():
    """Locate a supported C compiler for the reference oracle."""
    for value in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
        command=value.split()
        if shutil.which(command[0]): return command
    return None
def oracle(root):
    """Compile and run the reference oracle for this verifier."""
    cc=compiler()
    if not cc:return True,'not available',[]
    with tempfile.TemporaryDirectory(prefix='mq-bp033-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        built=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/O),'-o',str(exe)],capture_output=True,text=True)
        if built.returncode:return False,built.stdout+built.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        return run.returncode==0,' '.join(cc),[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
def contract(root,downstream=False):
    """Evaluate the source and runtime evidence for this contract."""
    errors=[]
    save=(root/'src/miniquake/savegame.ml').read_text(encoding='utf-8-sig')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/savegame_v5_parity_tests.ml').read_text(encoding='utf-8-sig')
    common=(root/'src/miniquake/common.ml').read_text(encoding='utf-8-sig')
    for marker in (
      'import miniquake.protocol_text as protocolText',
      'function serializeBytes(server)',
      'function parseBytes(data)',
      'function floatLine(data, offset, label)',
      'function inspectCommentBytes(data)',
      'protocolText.decodeBytes(slice(data, cursor, len(data) - cursor))',
    ):
        if marker not in save: errors.append('missing savegame marker: '+marker)
    if downstream:
        for marker in (
          'import miniquake.common as common',
          'validated = toNumber(line[0])',
          'return [common.cAtof(line[0]), line[1]]',
        ):
            if marker not in save: errors.append('missing downstream savegame marker: '+marker)
        for marker in (
          'function cAtof(text)',
          'return native.bitsFloat(native.f32FromText(text))',
        ):
            if marker not in common: errors.append('missing C atof marker: '+marker)
        for marker in (
          'text = text + "-0.000000\\n"',
          'spawn negative zero binary32',
          '0x80000000',
        ):
            if marker not in test: errors.append('missing signed-zero save fixture: '+marker)
        if 'native.bitsFloat(native.floatBits(parsed[0]))' in save:
            errors.append('legacy toNumber-based float normalization remains')
    else:
        if 'native.bitsFloat(native.floatBits(parsed[0]))' not in save:
            errors.append('missing historical savegame float boundary')
    for marker in (
      'savegame.serializeBytes(session.server)',
      'qfs.writeBytes(session.filesystem, name, data)',
      'qfs.readFile(session.filesystem, name)',
      'savegame.parseBytes(source)',
      'savegame.inspectCommentBytes(source)',
    ):
        if marker not in host: errors.append('missing host savegame marker: '+marker)
    if 'savegame v5 tests passed: 24' not in test: errors.append('expected 24 BP-033 fixtures')
    return errors
def main():
    """Run the command-line workflow and return its process exit status."""
    parser=argparse.ArgumentParser(); parser.add_argument('root',nargs='?',default='.'); parser.add_argument('--root',dest='root_flag'); parser.add_argument('--write-golden',action='store_true'); parser.add_argument('--json-output'); parser.add_argument('--allow-downstream-package',action='store_true')
    args=parser.parse_args(); root=Path(args.root_flag or args.root).resolve(); expected=doc(root,args.allow_downstream_package); golden=root/G
    if args.write_golden: golden.parent.mkdir(parents=True,exist_ok=True); golden.write_text(json.dumps(expected,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file(): errors.append('missing golden')
    elif json.loads(golden.read_text(encoding='utf-8-sig')) != expected: errors.append('golden differs from Python model')
    ok,detail,actual=oracle(root)
    if not ok: errors.append('C oracle failed: '+detail)
    elif actual and actual != expected['rows']: errors.append('C oracle differs from Python model')
    errors += contract(root,args.allow_downstream_package)
    parser_name='native_strtod_f32' if args.allow_downstream_package else 'historical_toNumber_f32'
    result={'schema':'MiniQuakeBP033SavegameV5Verification/1','package_id':P,'parent_package_id':PAR,'downstream_package':args.allow_downstream_package,'float_parser':parser_name,'preserves_signed_zero':args.allow_downstream_package,'ok':not errors,'oracle':detail,'rows':len(expected['rows']),'runtime_fixtures':24,'errors':errors}
    if args.json_output: Path(args.json_output).write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-033 savegame v5 verification: '+('PASS' if not errors else 'FAIL'))
    print(f'  rows={len(expected["rows"])} runtime_fixtures=24 oracle={detail}')
    print(f'  downstream_package={str(args.allow_downstream_package).lower()} float_parser={parser_name} preserves_signed_zero={str(args.allow_downstream_package).lower()}')
    for error in errors: print('  ERROR: '+error)
    return 0 if not errors else 1
if __name__=='__main__': raise SystemExit(main())
