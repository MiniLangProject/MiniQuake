#!/usr/bin/env python3
"""Validate MiniQuake's deterministic render corpus and optional GLQuake refs."""
from __future__ import annotations
import argparse, importlib.util, json, pathlib, sys, tempfile

SCENARIOS = ("start-064", "start-128", "e1m1-128")
MIN_SSIM = 0.95

def load_comparator(root: pathlib.Path):
    path = root / "tools" / "compare_render_evidence.py"
    spec = importlib.util.spec_from_file_location("mq_compare_render_evidence", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module

def validate(root: pathlib.Path, mini: pathlib.Path, original: pathlib.Path | None) -> dict[str, object]:
    comparator = load_comparator(root)
    entries: list[dict[str, object]] = []
    ok = True
    minimum = 1.0
    for name in SCENARIOS:
        a = mini / f"{name}-a.tga"
        b = mini / f"{name}-b.tga"
        if not a.is_file() or not b.is_file():
            entries.append({"scenario": name, "ok": False, "error": "missing MiniQuake pair"})
            ok = False
            continue
        pair = comparator.compare(a, b)
        exact = bool(pair.get("exact", False))
        entry: dict[str, object] = {"scenario": name, "mini_pair": pair, "mini_exact": exact}
        if not exact:
            ok = False
        if original is not None:
            reference = original / f"{name}.tga"
            if not reference.is_file():
                entry["original"] = {"ok": False, "error": "missing original reference"}
                ok = False
            else:
                comparison = comparator.compare(reference, a)
                ssim = float(comparison.get("ssim", 0.0)) if comparison.get("same_dimensions") else 0.0
                comparison["minimum_ssim"] = MIN_SSIM
                comparison["accepted"] = bool(comparison.get("ok")) and ssim >= MIN_SSIM
                entry["original"] = comparison
                minimum = min(minimum, ssim)
                if not comparison["accepted"]:
                    ok = False
        entries.append(entry)
    return {
        "schema": 1,
        "status": "PASS" if ok else "FAIL",
        "accepted": ok,
        "scenario_count": len(SCENARIOS),
        "scenarios": entries,
        "original_reference_supplied": original is not None,
        "original_minimum_ssim": minimum if original is not None else None,
        "required_original_ssim": MIN_SSIM,
    }

def self_test(root: pathlib.Path) -> None:
    comparator = load_comparator(root)
    with tempfile.TemporaryDirectory() as directory:
        base = pathlib.Path(directory)
        mini = base / "mini"; original = base / "original"
        mini.mkdir(); original.mkdir()
        pixels = bytes([0, 0, 0, 255, 0, 0])
        for name in SCENARIOS:
            comparator.make_tga(mini / f"{name}-a.tga", pixels, 2, 1)
            comparator.make_tga(mini / f"{name}-b.tga", pixels, 2, 1)
            comparator.make_tga(original / f"{name}.tga", pixels, 2, 1)
        report = validate(root, mini, original)
        assert report["accepted"] is True
        assert report["original_minimum_ssim"] == 1.0
    print("MiniQuake render-evidence corpus comparator self-test: PASS")

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(pathlib.Path(__file__).resolve().parents[1]))
    parser.add_argument("--mini-dir")
    parser.add_argument("--original-dir")
    parser.add_argument("--json-out")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    root = pathlib.Path(args.root).resolve()
    if args.self_test:
        self_test(root); return 0
    if not args.mini_dir:
        parser.error("--mini-dir is required")
    report = validate(root, pathlib.Path(args.mini_dir), pathlib.Path(args.original_dir) if args.original_dir else None)
    text = json.dumps(report, indent=2, sort_keys=True, allow_nan=False) + "\n"
    print(text, end="")
    if args.json_out:
        pathlib.Path(args.json_out).write_text(text, encoding="utf-8")
    return 0 if report["accepted"] else 1

if __name__ == "__main__":
    raise SystemExit(main())
