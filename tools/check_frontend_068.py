#!/usr/bin/env python3
import argparse, json, pathlib, re, sys

EXPECTED_FIXTURES = 24
EXPECTED_VOLUME_BITS = "0x3f4ccccd"
EXPECTED_PITCH_BITS = "0xbcb43958"

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default='')
    ns=ap.parse_args(); root=pathlib.Path(ns.root).resolve(); errors=[]
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8-sig')
    menu=(root/'src/miniquake/menu.ml').read_text(encoding='utf-8-sig')
    test=(root/'tests/menu_lifecycle_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((root/'audit/menu_lifecycle_golden.json').read_text())
    for m in ['function toggleMenu(session)', 'session.menu.page != menu.PAGE_MAIN',
              'direction * 1.0, 0.0, 1.0', 'if name == "togglemenu" then toggleMenu(session)']:
        if m not in host: errors.append('host.ml missing marker: '+m)
    block=re.search(r'if name == "menu_save" then(.*?)\n  end if',host,re.S)
    if not block: errors.append('menu_save command block missing')
    elif block.group(1).count('menu.M_Menu_Save_f(')!=1: errors.append('menu_save invokes M_Menu_Save_f more than once')
    if 'direction * 1.0, 0.0, 1.0' not in menu: errors.append('menu slider CD step is not one full unit')
    for marker in [
        'import miniquake.native as bp068Native',
        'const BP068_FIXTURES = 24',
        'bp068Native.floatBits(soundVolume) == 0x3f4ccccd',
        'variableString(registry, "volume") == "0.800000"',
        'bp068Native.floatBits(invertedPitch) == 0xbcb43958',
        'variableString(registry, "m_pitch") == "-0.022000"',
        'MiniQuake BP-068 menu lifecycle tests passed: 24',
    ]:
        if marker not in test: errors.append('menu fixture missing marker: '+marker)
    expected_golden = {
        'fixtures': EXPECTED_FIXTURES, 'options_items': 14, 'cd_volume_step': 1.0,
        'sound_volume_step': 0.1, 'sound_volume_bits': EXPECTED_VOLUME_BITS,
        'sound_volume_string': '0.800000', 'invert_pitch_bits': EXPECTED_PITCH_BITS,
        'invert_pitch_string': '-0.022000',
    }
    for key, wanted in expected_golden.items():
        if golden.get(key) != wanted: errors.append(f'golden {key} is {golden.get(key)!r}, expected {wanted!r}')
    report={'schema_version':1,'package':'BP-068','status':'PASS' if not errors else 'FAIL','errors':errors,
            'fixtures':EXPECTED_FIXTURES,'options_items':14,'save_single_dispatch':not errors,'cd_volume_step':1.0,
            'sound_volume_bits':EXPECTED_VOLUME_BITS,'invert_pitch_bits':EXPECTED_PITCH_BITS}
    if ns.json: pathlib.Path(ns.json).write_text(json.dumps(report,indent=2)+'\n')
    print('MiniQuake BP-068 menu lifecycle verification: '+report['status'])
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
