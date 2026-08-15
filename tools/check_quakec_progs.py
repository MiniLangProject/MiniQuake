#!/usr/bin/env python3
"""Verify BP-020 dprograms_t ABI, semantic parser guards and runtime CRC."""
from __future__ import annotations
import argparse, hashlib, json, os, shutil, struct, subprocess, tempfile
from pathlib import Path
PACKAGE_ID="BP-020";PARENT_PACKAGE_ID="BP-019";SCHEMA="MiniQuakeQuakeCProgsGolden/1";REPORT="MiniQuakeBP020QuakeCProgsVerification/1"
GOLDEN="audit/quakec_progs_golden.json";ORACLE="tools/oracle/quakec_progs_oracle.c"
def sha(p:Path)->str:return hashlib.sha256(p.read_bytes()).hexdigest()
def crc_block(data:bytes)->int:
    value=0xffff
    for item in data:
        value ^= item<<8
        for _ in range(8):value=((value<<1)^0x1021)&0xffff if value&0x8000 else (value<<1)&0xffff
    return value
def fixture()->bytes:
    strings=b'\0time\0health\0main\0fixture.qc\0';so,gdo,fdo,fo,stro=60,68,84,100,172;go=stro+len(strings);gc=32
    data=bytearray(go+gc*4)
    struct.pack_into('<15i',data,0,6,5927,so,1,gdo,2,fdo,2,fo,2,stro,len(strings),go,gc,4)
    struct.pack_into('<Hhhh',data,so,0,0,0,0)
    struct.pack_into('<HHi',data,gdo,0,0,0);struct.pack_into('<HHi',data,gdo+8,2,28,1)
    struct.pack_into('<HHi',data,fdo,0,0,0);struct.pack_into('<HHi',data,fdo+8,2,1,6)
    struct.pack_into('<7i8B',data,fo,0,0,0,0,0,0,0,*([0]*8))
    struct.pack_into('<7i8B',data,fo+36,0,28,1,0,13,18,0,*([0]*8))
    data[stro:stro+len(strings)]=strings
    return bytes(data)
def rows():
    data=fixture();return [
      {"kind":"case","name":"sizeof_dprograms","value":60},
      {"kind":"case","name":"sizeof_dstatement","value":8},
      {"kind":"case","name":"sizeof_ddef","value":8},
      {"kind":"case","name":"sizeof_dfunction","value":36},
      {"kind":"case","name":"type_size_void","value":1},
      {"kind":"case","name":"type_size_vector","value":3},
      {"kind":"case","name":"type_size_pointer","value":1},
      {"kind":"case","name":"prog_version","value":6},
      {"kind":"case","name":"progheader_crc","value":5927},
      {"kind":"case","name":"fixture_bytes","value":len(data)},
      {"kind":"case","name":"fixture_runtime_crc","value":crc_block(data)},
    ]
def document(root:Path):return {"schema":SCHEMA,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,"sources":["pr_comp.h","progs.h","pr_edict.c","sv_main.c"],"rows":rows(),"reference":{"oracle":ORACLE,"oracle_sha256":sha(root/ORACLE)}}
def compiler():
    for value in ([os.environ['CC']] if os.environ.get('CC') else [])+['cc','gcc','clang']:
        parts=value.split()
        if shutil.which(parts[0]):return parts
    return None
def run_oracle(root:Path):
    cc=compiler()
    if not cc:return True,'not available',[]
    with tempfile.TemporaryDirectory(prefix='mq-bp020-') as td:
        exe=Path(td)/('oracle.exe' if os.name=='nt' else 'oracle')
        build=subprocess.run(cc+['-std=c11','-Wall','-Wextra','-Werror','-O2',str(root/ORACLE),'-o',str(exe)],capture_output=True,text=True)
        if build.returncode:return False,build.stdout+build.stderr,[]
        run=subprocess.run([str(exe)],capture_output=True,text=True)
        return run.returncode==0,' '.join(cc),[json.loads(line) for line in run.stdout.splitlines() if line.strip()]
def contract(root:Path):
    errors=[]
    progs=(root/'src/miniquake/format/progs.ml').read_text(encoding='utf-8-sig')
    edict=(root/'src/miniquake/quakec/edict.ml').read_text(encoding='utf-8-sig')
    server=(root/'src/miniquake/server.ml').read_text(encoding='utf-8-sig')
    svmain=(root/'src/miniquake/sv_main.ml').read_text(encoding='utf-8-sig')
    constants=(root/'src/miniquake/constants.ml').read_text(encoding='utf-8-sig')
    tests=(root/'tests/quakec_progs_tests.ml').read_text(encoding='utf-8-sig')
    stock=(root/'tests/quakec_stock_tests.ml').read_text(encoding='utf-8-sig')
    markers=(
      'const PROGHEADER_CRC = 5927','function validateLoadableProgram(program)','function validateProgram(program)','function runtimeCrc(program)',
      'protocolText.decodeBytes','field definition uses DEF_SAVEGLOBAL','invalid QuakeC opcode',
    )
    for marker in markers:
        if marker not in constants+progs:errors.append('missing BP-020 marker: '+marker)
    if 'program.crc != c.PROGHEADER_CRC' not in edict:errors.append('PR_LoadProgs does not use named ABI CRC')
    if 'progs.runtimeCrc(server.progs)' not in server or 'progs.runtimeCrc(server.progs)' not in svmain:errors.append('serverinfo does not use full-file progs CRC')
    if 'parameterWords > fn.locals' in progs:errors.append('strict audit still imposes the invalid parameterWords <= locals rule')
    parameter_destination_guards = (
        'fn.firstStatement >= 0 and fn.parmStart + parameterWords > len(program.globals)',
        'executableBytecode and fn.parmStart + parameterWords > len(program.globals)',
    )
    if not any(marker in progs for marker in parameter_destination_guards):errors.append('strict audit does not check the actual executable-bytecode parameter destination')
    if 'validation = try(validateLoadableProgram(program))' not in progs:errors.append('normal parsing still invokes the strict audit')
    if 'bytecode-zero-locals.dat' not in tests or 'bytecode parameter storage accepted' not in tests:errors.append('missing qcc bytecode zero-locals regression fixture')
    if 'parameter-storage-outside-globals.dat' not in tests or 'parameter storage outside globals rejected' not in tests:errors.append('missing parameter destination bounds fixture')
    if 'builtin-zero-locals.dat' not in tests or 'builtin signature accepted' not in tests:errors.append('missing qcc builtin zero-locals regression fixture')
    if 'audited = try(progs.validateProgram(program))' not in stock:errors.append('stock progs.dat gate does not execute the explicit strict audit')
    core=(root/'tests/core_tests.ml').read_text(encoding='utf-8-sig')
    if 'bio.putI32(data, 44, 1)' not in core or 'data[sectionEnd] = 0' not in core:errors.append('large synthetic progs fixture lacks the mandatory empty string')
    if tests.count('if run(')!=18 or 'MiniQuake BP-020 QuakeC progs.dat tests passed: 18' not in tests:errors.append('expected 18 BP-020 fixtures')
    return errors
def main()->int:
    ap=argparse.ArgumentParser();ap.add_argument('root',nargs='?',default='.');ap.add_argument('--root',dest='root_flag');ap.add_argument('--write-golden',action='store_true');ap.add_argument('--json-output');a=ap.parse_args();root=Path(a.root_flag or a.root).resolve();doc=document(root);golden=root/GOLDEN
    if a.write_golden:golden.parent.mkdir(parents=True,exist_ok=True);golden.write_text(json.dumps(doc,indent=2)+'\n',encoding='utf-8')
    errors=[]
    if not golden.is_file():errors.append('missing golden document')
    elif json.loads(golden.read_text(encoding='utf-8-sig'))!=doc:errors.append('golden differs from Python model')
    ok,detail,actual=run_oracle(root)
    if not ok:errors.append('C oracle failed: '+detail)
    elif actual and actual!=doc['rows']:errors.append('C oracle differs from Python model')
    errors+=contract(root)
    report={"schema":REPORT,"package_id":PACKAGE_ID,"parent_package_id":PARENT_PACKAGE_ID,"ok":not errors,"oracle":detail,"rows":len(doc['rows']),"runtime_fixtures":18,"errors":errors}
    if a.json_output:Path(a.json_output).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-020 QuakeC progs.dat verification: '+('PASS' if not errors else 'FAIL'));print(f"  rows={len(doc['rows'])} runtime_fixtures=18 oracle={detail}")
    for e in errors:print('  ERROR: '+e)
    return 0 if not errors else 1
if __name__=='__main__':raise SystemExit(main())
