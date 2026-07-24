#!/usr/bin/env python3
"""Direct pinned-source execution differential for 68 active menu.c bodies."""

from __future__ import annotations
import argparse, json, shutil, subprocess, sys, tempfile
from pathlib import Path
from renderer_differential import compile_miniquake, compile_reference, run

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference" / "quake"
COMMIT = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"
CFIX = ROOT / "reference" / "fixtures" / "menu" / "mq_menu_fixture.c"
MLFIX = ROOT / "tests" / "menu_differential_fixture.ml"
MANIFEST = ROOT / "audit" / "menu_differential_manifest.json"

def json_lines(data: bytes) -> bytes:
    lines = [x for x in data.decode().splitlines() if x.startswith("{")]
    return ("\n".join(lines) + "\n").encode()

def main() -> int:
    parser=argparse.ArgumentParser()
    parser.add_argument("--output-dir",type=Path,default=ROOT/"build"/"parity"/"menu")
    out=parser.parse_args().output_dir.resolve(); out.mkdir(parents=True,exist_ok=True)
    run([sys.executable,str(ROOT/"tools"/"verify_reference.py")])
    temp=Path(tempfile.mkdtemp(prefix="glquake-menu-fixture-")); wt=temp/"reference"
    try:
        run(["git","-C",str(REFERENCE),"worktree","add","--detach",str(wt),COMMIT])
        original=compile_reference(wt,out,name="menu",source="menu.c",fixture=CFIX,macro="MINIQUAKE_MENU_FIXTURE",link_libraries=[])
        candidate=compile_miniquake(out,name="menu",source=MLFIX)
        otr=out/"glquake_menu_trace.jsonl"; mtr=out/"miniquake_menu_trace.jsonl"
        otr.write_bytes(json_lines(run([str(original)],capture=True)))
        mtr.write_bytes(json_lines(run([str(candidate)],capture=True)))
        run([sys.executable,str(ROOT/"tools"/"parity_oracle.py"),"compare-traces",str(otr),str(mtr),"--epsilon","0"])
        payload=json.loads(MANIFEST.read_text(encoding="utf-8"))
        events=[json.loads(x) for x in otr.read_text().splitlines() if x]
        observed={x["function"] for x in events}
        claims={x["name"] for x in payload["functions"]}
        if len(events)!=68 or len(claims)!=68 or observed!=claims:
            raise RuntimeError(f"menu inventory mismatch: events={len(events)} claims={len(claims)} observed={len(observed)}")
        print("menu manifest validated: 68/68 active original bodies")
    finally:
        if wt.exists(): subprocess.run(["git","-C",str(REFERENCE),"worktree","remove","--force",str(wt)],cwd=ROOT,check=False)
        shutil.rmtree(temp,ignore_errors=True)
    run([sys.executable,str(ROOT/"tools"/"verify_reference.py")])
    print(f"menu differential passed: {out}")
    return 0

if __name__=="__main__":
    try: raise SystemExit(main())
    except (OSError,RuntimeError,subprocess.CalledProcessError) as exc:
        print(f"menu differential failed: {exc}",file=sys.stderr); raise SystemExit(1)
