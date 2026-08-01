#!/usr/bin/env python3
import argparse, json, pathlib, sys

EXPECTED_STATUS = 'artifact_compat_109_frozen_v1'
EXPECTED_FINGERPRINT = '0x59531091'
EXPECTED_FIXTURES = 24
EXPECTED_EVIDENCE_REVISION = 'sequential_exact_fixed6_signedzero_v3'


def fnv1a32(data: bytes) -> int:
    value = 0x811C9DC5
    for byte in data:
        value ^= byte
        value = (value * 0x01000193) & 0xFFFFFFFF
    return value


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    golden_path = root / "audit/artifact_compat_golden.json"
    module_path = root / "src/miniquake/artifact_compat.ml"
    test_path = root / "tests/artifact_compat_tests.ml"
    evidence_path = root / "tests/artifact_retail_evidence.ml"
    runtime_path = root / "src/miniquake/savegame_runtime.ml"
    savegame_path = root / "src/miniquake/savegame.ml"
    common_path = root / "src/miniquake/common.ml"
    bsp_path = root / "src/miniquake/format/bsp.ml"
    host_path = root / "src/miniquake/host.ml"
    build_info_path = root / "src/miniquake/build_info.ml"
    native_module_path = root / "src/miniquake/native.ml"
    edict_path = root / "src/miniquake/quakec/edict.ml"
    cvar_path = root / "src/miniquake/cvar.ml"
    text_bridge_path = root / "native/miniquake_text.c"
    text_def_path = root / "native/miniquake_text.def"
    fixed_golden_path = root / "audit/savegame_fixed6_golden.json"
    oracle_path = root / "tools/oracle/savegame_fixed6_oracle.c"
    for path in [golden_path, module_path, test_path, evidence_path, runtime_path, savegame_path, common_path, bsp_path, host_path, build_info_path, native_module_path, edict_path, cvar_path, text_bridge_path, text_def_path, fixed_golden_path, oracle_path]:
        if not path.is_file():
            errors.append("missing file: " + str(path.relative_to(root)))
    golden = {}
    if golden_path.is_file():
        golden = json.loads(golden_path.read_text(encoding="utf-8-sig"))
    source = module_path.read_text(encoding="utf-8-sig") if module_path.is_file() else ""
    test = test_path.read_text(encoding="utf-8-sig") if test_path.is_file() else ""
    evidence = evidence_path.read_text(encoding="utf-8-sig") if evidence_path.is_file() else ""
    runtime = runtime_path.read_text(encoding="utf-8-sig") if runtime_path.is_file() else ""
    savegame = savegame_path.read_text(encoding="utf-8-sig") if savegame_path.is_file() else ""
    common = common_path.read_text(encoding="utf-8-sig") if common_path.is_file() else ""
    bsp_source = bsp_path.read_text(encoding="utf-8-sig") if bsp_path.is_file() else ""
    host = host_path.read_text(encoding="utf-8-sig") if host_path.is_file() else ""
    build_info = build_info_path.read_text(encoding="utf-8-sig") if build_info_path.is_file() else ""
    native_module = native_module_path.read_text(encoding="utf-8-sig") if native_module_path.is_file() else ""
    edict = edict_path.read_text(encoding="utf-8-sig") if edict_path.is_file() else ""
    cvar = cvar_path.read_text(encoding="utf-8-sig") if cvar_path.is_file() else ""
    text_bridge = text_bridge_path.read_text(encoding="utf-8-sig") if text_bridge_path.is_file() else ""
    text_def = text_def_path.read_text(encoding="utf-8-sig") if text_def_path.is_file() else ""
    fixed_golden = json.loads(fixed_golden_path.read_text(encoding="utf-8-sig")) if fixed_golden_path.is_file() else {}
    oracle = oracle_path.read_text(encoding="utf-8-sig") if oracle_path.is_file() else ""
    contract_text = golden.get("contract_text", "")
    calculated = f"0x{fnv1a32(contract_text.encode('utf-8')):08x}"
    if golden.get("status") != EXPECTED_STATUS: errors.append("golden status differs")
    if golden.get("fingerprint") != EXPECTED_FINGERPRINT: errors.append("golden fingerprint differs")
    if calculated != EXPECTED_FINGERPRINT: errors.append(f"fingerprint calculation: expected {EXPECTED_FINGERPRINT}, got {calculated}")
    if golden.get("fixtures") != EXPECTED_FIXTURES: errors.append("golden fixture count differs")
    if golden.get("evidence_revision") != EXPECTED_EVIDENCE_REVISION: errors.append("golden evidence revision differs")
    if golden.get("requires_exact_roundtrip") is not True: errors.append("exact roundtrip requirement missing")
    if golden.get("requires_stable_reserialize") is not True: errors.append("stable reserialize requirement missing")
    if golden.get("preserves_edict_high_water") is not True: errors.append("edict high-water requirement missing")
    if golden.get("live_vm_hashes_are_diagnostic") is not True: errors.append("live VM hash classification missing")
    if golden.get("preserves_signed_zero") is not True: errors.append("signed-zero preservation requirement missing")
    if golden.get("float_parser") != "msvcrt_strtod_f32": errors.append("save float parser classification differs")
    if golden.get("fixed_six_formatter") != "msvcrt_percent_f": errors.append("fixed-six formatter classification differs")
    if golden.get("fixed_six_large_positive") != "4097.000000": errors.append("fixed-six positive golden differs")
    if golden.get("fixed_six_large_negative") != "-4097.000000": errors.append("fixed-six negative golden differs")
    if golden.get("text_bridge_export") != "mqt_f32_to_fixed6": errors.append("fixed-six text bridge export differs")
    if fixed_golden.get("formatter") != "msvcrt_percent_f" or fixed_golden.get("format") != "%.6f":
        errors.append("fixed-six golden metadata differs")
    if len(fixed_golden.get("cases", [])) != 8:
        errors.append("fixed-six golden case count differs")
    for text in [
        f'const STATUS = "{EXPECTED_STATUS}"',
        f'const FINGERPRINT = {EXPECTED_FINGERPRINT}',
        'const SAVE_FLOAT_FORMAT = "msvcrt_percent_f"',
        'function saveSemanticDifference(left, right)',
        'function saveSemanticEqual(left, right)',
        'function firstByteDifference(left, right)',
    ]:
        if text not in source: errors.append("missing module marker: " + text)
    for text in [
        'MiniQuake BP-087 artifact compatibility tests passed: 24',
        '[22/24] save semantic equality',
        '[23/24] save semantic difference',
        '[24/24] byte difference and contract',
    ]:
        if text not in test: errors.append("runtime marker missing: " + text)
    evidence_markers = [
        'cleanA = try(bp087Shutdown(sessionA, "source"))',
        'sessionB = host.create(',
        'cleanB = try(bp087Shutdown(sessionB, "target"))',
        'sessionC = host.create(',
        'saveRuntime.synchronizeLoadedServer(session.server)',
        'semanticDifferenceAB = artifacts.saveSemanticDifference(parsedA, parsedB)',
        'exactFirstPass = artifacts.bytesEqual(saveA, saveB)',
        'stableExact = artifacts.bytesEqual(saveB, saveC)',
        'save byte roundtrip mismatch at offset',
        'save normalized bytes are not stable at offset',
        'runtime_full_hashes source_edicts=',
        'save_float_format=4097:',
        'qcedict.fixedSixDecimals(4097.0)',
        'save_float_parse=-0.000000:',
        'import miniquake.compat_diagnostics as diagnostics',
        'diagnostics.u32Hex(signedZeroBits)',
        'C atof did not preserve negative zero',
    ]
    for text in evidence_markers:
        if text not in evidence: errors.append("retail evidence marker missing: " + text)
    runtime_markers = [
        'function synchronizeLoadedServer(server)',
        'savedCount = server.numEdicts',
        'collision.linkEntity(server, index, false)',
    ]
    for text in runtime_markers:
        if text not in runtime: errors.append("save runtime marker missing: " + text)
    historical_high_water = (
        'runtime.numEdicts = savedCount' in runtime and
        'server.numEdicts = savedCount' in runtime
    )
    stable_high_water = (
        'serverRuntime.syncLoadedQuakeCEdicts(server, savedCount)' in runtime
    )
    if not historical_high_water and not stable_high_water:
        errors.append("save runtime does not restore the saved edict high-water mark")
    if 'server.mapName = saved.mapName' not in savegame:
        errors.append("savegame apply does not restore map name")
    if 'saveRuntime.synchronizeLoadedServer(session.server)' not in host:
        errors.append("host load path bypasses save runtime synchronization")
    if 'server.syncQuakeCEdicts(session.server)' in host[host.find('function loadGame('):host.find('function setPlayerFlag(')]:
        errors.append("host load path still directly trims the saved edict high-water mark")
    pos_shutdown_a = evidence.find('cleanA = try(bp087Shutdown(sessionA, "source"))')
    pos_session_b = evidence.find('sessionB = host.create(')
    pos_shutdown_b = evidence.find('cleanB = try(bp087Shutdown(sessionB, "target"))')
    pos_session_c = evidence.find('sessionC = host.create(')
    if min(pos_shutdown_a, pos_session_b, pos_shutdown_b, pos_session_c) < 0 or not (pos_shutdown_a < pos_session_b < pos_shutdown_b < pos_session_c):
        errors.append("retail evidence sessions are not strictly sequential")
    if 'semantic = sourceEdicts == targetEdicts' in evidence:
        errors.append("retail evidence still treats complete live VM hashes as save semantics")
    fixed_markers = {
        "native module": [
            'symbol "mqt_f32_to_fixed6"',
            'function f32ToFixed6(bits)',
            'function fixedSixText(value)',
        ],
        "edict formatter": [
            'return native.f32ToFixed6(rawWord & 0xffffffff)',
        ],
        "cvar formatter": [
            'return native.fixedSixText(value)',
        ],
        "text bridge": [
            'mqt_f32_to_fixed6',
            'mq_crt_proc("sprintf")',
            '"%.6f"',
        ],
        "text def": ['mqt_f32_to_fixed6'],
        "oracle": ['0x45800800', '0xc5800800', '%.6f'],
    }
    fixed_texts = {
        "native module": native_module,
        "edict formatter": edict,
        "cvar formatter": cvar,
        "text bridge": text_bridge,
        "text def": text_def,
        "oracle": oracle,
    }
    for label, markers in fixed_markers.items():
        for marker in markers:
            if marker not in fixed_texts[label]:
                errors.append(f"{label} missing fixed-six marker: {marker}")
    if 'scaled = native.trunc(magnitude * 1000000.0 + 0.5)' in edict or 'scaled = native.trunc(magnitude * 1000000.0 + 0.5)' in cvar:
        errors.append("legacy i32-overflow fixed-six formatter remains")
    signed_zero_markers = {
        "common": [
            "function cAtof(text)",
            "return native.bitsFloat(native.f32FromText(text))",
        ],
        "edict": [
            "vm.setGlobalFloat(machine, definition.offset, common.cAtof(value))",
            "vm.setEntityFloat(machine, entityIndex, definition.offset, common.cAtof(actualValue))",
        ],
        "bsp": [
            "values[valueCount] = common.cAtof(decode(slice(source, start, i - start)))",
        ],
        "savegame": [
            "return [common.cAtof(line[0]), line[1]]",
        ],
        "test": [
            "retail save signed-zero parse",
        ],
    }
    signed_zero_texts = {
        "common": common, "edict": edict, "bsp": bsp_source,
        "savegame": savegame, "test": test,
    }
    for label, markers in signed_zero_markers.items():
        for marker in markers:
            if marker not in signed_zero_texts[label]:
                errors.append(f"{label} missing signed-zero marker: {marker}")
    for text in ['const PACKAGE_ID = "BP-089"', 'const BLOCK_ID = "BP-085-089"']:
        if text not in build_info: errors.append("missing build marker: " + text)
    report = {
        "schema_version": 1,
        "package": "BP-087",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "contract_status": golden.get("status"),
        "fingerprint": calculated,
        "fixtures": EXPECTED_FIXTURES,
        "evidence_revision": EXPECTED_EVIDENCE_REVISION,
        "fixed_six_formatter": golden.get("fixed_six_formatter"),
        "fixed_six_cases": len(fixed_golden.get("cases", [])),
        "text_bridge_export": golden.get("text_bridge_export"),
        "sequential_sessions": not any("sequential" in e for e in errors),
        "semantic_boundary": "parsed_save_domain",
        "exact_roundtrip_required": True,
        "stable_reserialize_required": True,
        "preserves_edict_high_water": True,
        "high_water_mode": "stable_server_mirror" if stable_high_water else "historical_direct_assignment",
        "preserves_signed_zero": True,
        "float_parser": "msvcrt_strtod_f32",
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("MiniQuake BP-087 artifact compat verification: " + report["status"])
    if not errors:
        print(f"  status={EXPECTED_STATUS} fingerprint={EXPECTED_FINGERPRINT} fixtures={EXPECTED_FIXTURES}")
        print(f"  evidence_revision={EXPECTED_EVIDENCE_REVISION} semantic_boundary=parsed_save_domain exact_roundtrip=true preserves_edict_high_water=true preserves_signed_zero=true sequential_sessions=true")
        print("  float_parser=msvcrt_strtod_f32")
        print("  fixed_six_formatter=msvcrt_percent_f text_bridge_export=mqt_f32_to_fixed6 fixed_six_cases=8")
    for error in errors: print("  [FAIL] " + error)
    return 0 if not errors else 1


if __name__ == "__main__":
    sys.exit(main())
