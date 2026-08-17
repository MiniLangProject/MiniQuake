# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Verify the check opt001d 60fps compatibility and regression contract."""

from __future__ import annotations
import argparse,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument("--build",required=True);p.add_argument("--prefix",default="opt001d");p.add_argument("--json");a=p.parse_args();b=Path(a.build);fail=[];rows=[]
for m in ("e1m1","e1m2"):
 q=b/f"{a.prefix}-{m}-render-summary.json"
 if not q.exists(): fail.append(f"missing {q.name}"); continue
 d=json.loads(q.read_text(encoding="utf-8-sig")); med=float(d.get("median_ms",9999));p95=float(d.get("p95_ms",9999));p99=float(d.get("p99_ms",9999));fps=1000.0/med if med>0 else 0;rows.append({"map":m,"median_ms":med,"p95_ms":p95,"p99_ms":p99,"fps":fps})
 if med>16.67: fail.append(f"{m} median {med}ms > 16.67ms")
 if p95>20: fail.append(f"{m} p95 {p95}ms > 20ms")
 if p99>25: fail.append(f"{m} p99 {p99}ms > 25ms")
r={"schema":"MiniQuakeOPT001D60FpsGate/1","status":"PASS" if not fail else "FAIL","rows":rows,"failures":fail}
if a.json: Path(a.json).write_text(json.dumps(r,indent=2)+"\n",encoding="utf-8")
for x in rows: print(f"{x['map']}: median={x['median_ms']}ms fps={x['fps']:.1f} p95={x['p95_ms']} p99={x['p99_ms']}")
for x in fail: print("FAIL:",x)
raise SystemExit(0 if not fail else 1)
