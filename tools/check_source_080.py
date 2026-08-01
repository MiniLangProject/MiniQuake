#!/usr/bin/env python3
import argparse, json, pathlib, re, sys

NAMES = [
    "Cvar_FindVar", "Cvar_VariableValue", "Cvar_VariableString",
    "Cvar_CompleteVariable", "Cvar_Set", "Cvar_SetValue",
    "Cvar_RegisterVariable", "Cvar_Command", "Cvar_WriteVariables",
]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--json", default="")
    ns = ap.parse_args()
    root = pathlib.Path(ns.root).resolve()
    errors = []
    source = (root / "src/miniquake/cvar.ml").read_text(encoding="utf-8-sig")
    test = (root / "tests/cvar_source_surface_tests.ml").read_text(encoding="utf-8-sig")
    golden = json.loads((root / "audit/cvar_source_surface_golden.json").read_text())

    for name in NAMES:
        count = len(re.findall(rf"(?m)^\s*function\s+{re.escape(name)}\s*\(", source))
        if count != 1:
            errors.append(f"{name}: expected one exact-name adapter, found {count}")
    if golden.get("original_function_names") != NAMES:
        errors.append("golden exact-name list differs")
    if golden.get("fixture_count") != 20:
        errors.append("golden fixture_count must be 20")
    if "MiniQuake BP-080 cvar source-surface tests passed: 20" not in test:
        errors.append("runtime success marker missing")
    if "function Cvar_Command(registry, arguments)" not in source:
        errors.append("explicit command context adapter missing")
    if "function Cvar_RegisterVariable(registry, variable, commandExists)" not in source:
        errors.append("explicit command-existence adapter missing")

    report = {
        "schema_version": 1,
        "package": "BP-080",
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "exact_name_adapters": len(NAMES),
        "fixtures": 20,
    }
    if ns.json:
        pathlib.Path(ns.json).write_text(json.dumps(report, indent=2) + "\n")
    print("MiniQuake BP-080 cvar source-surface verification: " + report["status"])
    for error in errors:
        print("  [FAIL] " + error)
    return 0 if not errors else 1

if __name__ == "__main__":
    sys.exit(main())
