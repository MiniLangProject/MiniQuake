#!/usr/bin/env python3
"""Verify BP-061 Protocol-3 control and rule-enumeration parity."""
from __future__ import annotations
import argparse, json, pathlib, sys

def main() -> int:
    ap=argparse.ArgumentParser(); ap.add_argument('--root',default='.'); ap.add_argument('--json',default=''); a=ap.parse_args()
    r=pathlib.Path(a.root).resolve(); errors=[]
    loop=(r/'src/miniquake/net_loop.ml').read_text(encoding='utf-8-sig')
    ctl=(r/'src/miniquake/net_control.ml').read_text(encoding='utf-8-sig')
    test=(r/'tests/network_control_parity_tests.ml').read_text(encoding='utf-8-sig')
    golden=json.loads((r/'audit/network_control_golden.json').read_text(encoding='utf-8'))
    oracle=(r/'tools/oracle/network_control_oracle.c').read_text(encoding='utf-8')

    for m in ('const HOST_CACHE_SIZE = 8','len(result) < HOST_CACHE_SIZE','function uniqueHostName','function connectionRequestAction','function nextServerRule'):
        if m not in loop: errors.append('net_loop missing '+m)
    for m in (
        'return error(3437, "unknown previous server rule")',
        'if start >= len(rules) then return ["", ""] end if',
        'rule = try(nextServerRule(state.serverRules, parsed[1][0]))',
        'if rule is not error then',
        'response = control.replyRuleInfo(rule[0], rule[1])',
    ):
        if m not in loop: errors.append('net_loop rule-enumeration contract missing: '+m)
    for m in ('if found < 0 then return void end if','if start >= len(rules) then return void end if','if rule is void then response = control.replyRuleInfo'):
        if m in loop: errors.append('legacy ambiguous rule-enumeration path remains: '+m)

    for m in ('const NET_PROTOCOL_VERSION = 3','const GAME_NAME = "QUAKE"','function requestConnect','function replyServerInfo','function replyRuleInfo','if rule != "" then','if msg.remaining(reader) == 0 then fields = ["", ""]'):
        if m not in ctl: errors.append('net_control missing '+m)

    for m in ('passed: 24','unknownRule = try(netloop.nextServerRule(rules, "missing"))','unknownRule is error','finalRule[0] == "" and finalRule[1] == ""','terminatorPacket = control.parse(control.replyRuleInfo(finalRule[0], finalRule[1]))'):
        if m not in test: errors.append('network-control runtime fixture missing: '+m)

    expected={'first':['deathmatch','1'],'next':['fraglimit','20'],'end':['',''],'unknown_previous':'no_reply'}
    if golden.get('fixtures')!=24 or golden.get('host_cache_size')!=8: errors.append('golden count/host-cache mismatch')
    if golden.get('rule_enumeration')!=expected: errors.append('golden rule-enumeration semantics differ')
    for m in ('rule_first=%s:%s','rule_next=%s:%s','rule_end=%s','rule_unknown=%s','"terminator"','"no_reply"'):
        if m not in oracle: errors.append('network-control C oracle missing: '+m)

    out={'schema_version':2,'package':'BP-061','delivery_revision':'BP-060-064R2','status':'PASS' if not errors else 'FAIL','errors':errors,'fixtures':24,'host_cache_size':8,'rule_end':'command_only_reply','unknown_previous':'no_reply'}
    if a.json: pathlib.Path(a.json).write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake BP-061 network control verification: '+out['status'])
    if not errors: print('  fixtures=24 host_cache_size=8 rule_end=command_only unknown_previous=no_reply')
    for e in errors: print('  [FAIL] '+e)
    return 0 if not errors else 1
if __name__=='__main__': sys.exit(main())
