#!/usr/bin/env python3
import argparse, json, pathlib, re, sys

EXPECTED_STATUS = "stability_109_frozen_v1"
EXPECTED_FINGERPRINT = "0xd0e3c03f"
EXPECTED_FIXTURES = 20
MAX_EDICTS = 600
MAX_STATIC_ENTITIES = 128


def fnv1a32(data: bytes) -> int:
    value = 0x811C9DC5
    for byte in data:
        value ^= byte
        value = (value * 0x01000193) & 0xFFFFFFFF
    return value


def client_entity_limit(server_before: int, server_after: int, entities_before: int) -> int:
    if min(server_before, server_after, entities_before) < 0:
        return -1
    if server_before > MAX_EDICTS or server_after > MAX_EDICTS:
        return -1
    maximum = MAX_EDICTS + MAX_STATIC_ENTITIES
    if entities_before > maximum:
        return -1
    server_high = max(server_before, server_after)
    static_offset = max(0, entities_before - server_before)
    return min(max(entities_before, server_high + static_offset), maximum)


def case_stable(case: dict) -> bool:
    limit = client_entity_limit(case['server_before'], case['server_after'], case['entities_before'])
    server_stable = case['server_after'] <= case['server_before'] <= MAX_EDICTS
    return server_stable and limit >= 0 and case['entities_after'] <= limit


def _const_string(source: str, name: str) -> str:
    match = re.search(rf'^const\s+{re.escape(name)}\s*=\s*"([^"]+)"\s*$', source, flags=re.M)
    return match.group(1) if match else ""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--root', default='.')
    ap.add_argument('--json', default='')
    ap.add_argument('--allow-downstream-package', action='store_true')
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    golden_path = root / 'audit/stability_golden.json'
    module_path = root / 'src/miniquake/stability_contract.ml'
    host_path = root / 'src/miniquake/host.ml'
    test_path = root / 'tests/stability_contract_tests.ml'
    build_info_path = root / 'src/miniquake/build_info.ml'
    for path in [golden_path, module_path, host_path, test_path, build_info_path]:
        if not path.is_file():
            errors.append('missing file: ' + str(path.relative_to(root)))
    golden = json.loads(golden_path.read_text(encoding='utf-8-sig')) if golden_path.is_file() else {}
    source = module_path.read_text(encoding='utf-8-sig') if module_path.is_file() else ''
    host = host_path.read_text(encoding='utf-8-sig') if host_path.is_file() else ''
    test = test_path.read_text(encoding='utf-8-sig') if test_path.is_file() else ''
    build_info = build_info_path.read_text(encoding='utf-8-sig') if build_info_path.is_file() else ''
    contract_text = golden.get('contract_text', '')
    calculated = f'0x{fnv1a32(contract_text.encode("utf-8")):08x}'
    if golden.get('status') != EXPECTED_STATUS: errors.append('golden status differs')
    if golden.get('fingerprint') != EXPECTED_FINGERPRINT: errors.append('golden fingerprint differs')
    if calculated != EXPECTED_FINGERPRINT: errors.append(f'fingerprint calculation: expected {EXPECTED_FINGERPRINT}, got {calculated}')
    if golden.get('fixtures') != EXPECTED_FIXTURES: errors.append('golden fixture count differs')
    if golden.get('client_entity_policy') != 'server_high_water_plus_existing_static_offset': errors.append('golden client entity policy differs')
    if golden.get('server_edict_growth_during_idle_soak') != 'rejected': errors.append('server Edict idle-growth policy differs')
    if golden.get('client_entity_absolute_limit') != MAX_EDICTS + MAX_STATIC_ENTITIES: errors.append('client absolute limit differs')

    for marker in [
        f'const FINGERPRINT = {EXPECTED_FINGERPRINT}',
        'const CLIENT_ENTITY_POLICY = "server_high_water_plus_existing_static_offset"',
        'function clientEntityLimit(serverBefore, serverAfter, entitiesBefore)',
        'staticOffset = entitiesBefore - serverBefore',
        'after[4] <= before[4]',
        'entitiesStable = clientEntityHighWaterStable(before[4], after[4], before[5], after[5])',
    ]:
        if marker not in source: errors.append('missing module marker: ' + marker)
    for marker in [
        'import miniquake.stability_contract as stability',
        'return stability.longStable(before, after)',
        'client entity high-water limit=',
        'stability gates: heap=',
    ]:
        if marker not in host: errors.append('missing host marker: ' + marker)
    for marker in [
        '[15/20] client entity high-water catch-up',
        'stability.clientEntityLimit(67, 67, 66) == 67',
        '[16/20] topology growth rejected',
        'not stability.longStable(catchupBefore, serverGrowth)',
        'MiniQuake BP-088 stability tests passed: 20',
    ]:
        if marker not in test: errors.append('missing runtime marker: ' + marker)
    package_id = _const_string(build_info, "PACKAGE_ID")
    parent_package_id = _const_string(build_info, "PARENT_PACKAGE_ID")
    block_id = _const_string(build_info, "BLOCK_ID")
    for marker in [
        'const STABILITY_STATUS = "stability_109_frozen_v1"',
        f'const STABILITY_FINGERPRINT = {EXPECTED_FINGERPRINT}',
    ]:
        if marker not in build_info: errors.append('missing build marker: ' + marker)
    if ns.allow_downstream_package:
        if not package_id: errors.append("downstream build info has no PACKAGE_ID")
        if not parent_package_id: errors.append("downstream build info has no PARENT_PACKAGE_ID")
        if not block_id: errors.append("downstream build info has no BLOCK_ID")
    else:
        for marker in [
            'const PACKAGE_ID = "BP-089"',
            'const PARENT_PACKAGE_ID = "BP-088"',
            'const BLOCK_ID = "BP-085-089"',
        ]:
            if marker not in build_info: errors.append('missing build marker: ' + marker)

    case_results = []
    for case in golden.get('client_entity_cases', []):
        limit = client_entity_limit(case['server_before'], case['server_after'], case['entities_before'])
        stable = case_stable(case)
        case_results.append({'name':case.get('name'),'limit':limit,'stable':stable})
        if limit != case.get('expected_limit') or stable != case.get('stable'):
            errors.append('client entity case differs: ' + str(case.get('name')))

    report = {
        'schema_version': 1,
        'package': package_id if ns.allow_downstream_package else 'BP-088',
        'downstream_package': bool(ns.allow_downstream_package),
        'status': 'PASS' if not errors else 'FAIL',
        'errors': errors,
        'build_package_id': package_id,
        'build_parent_package_id': parent_package_id,
        'build_block_id': block_id,
        'contract_status': golden.get('status'),
        'fingerprint': calculated,
        'fixtures': EXPECTED_FIXTURES,
        'client_entity_policy': golden.get('client_entity_policy'),
        'server_edict_growth_during_idle_soak': golden.get('server_edict_growth_during_idle_soak'),
        'client_entity_cases': case_results,
        'r7_observed_case_passes': any(x['name']=='r7_listen_catch_up' and x['stable'] and x['limit']==67 for x in case_results),
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('MiniQuake BP-088 stability verification: ' + report['status'])
    if not errors:
        print(f'  status={EXPECTED_STATUS} fingerprint={EXPECTED_FINGERPRINT} fixtures={EXPECTED_FIXTURES}')
        print('  client_entity_policy=server_high_water_plus_existing_static_offset')
        print('  server_edict_growth_during_idle_soak=rejected')
        print(f"  downstream={str(bool(ns.allow_downstream_package)).lower()} package={package_id} block={block_id}")
    for error in errors: print('  [FAIL] ' + error)
    return 0 if not errors else 1

if __name__ == '__main__':
    sys.exit(main())
