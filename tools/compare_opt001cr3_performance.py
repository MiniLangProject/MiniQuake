#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Compare deterministic opt001cr3 performance evidence."""

from __future__ import annotations
import argparse,json
from pathlib import Path
from statistics import mean
MAPS=('e1m1','e1m2'); MODES=('headless','render')
def load(p):
    """Load and decode one JSON evidence report."""
    return json.loads(Path(p).read_text(encoding='utf-8-sig'))
def imp(old,new):
    """Compute the percentage improvement from baseline to candidate."""
    return 0.0 if old<=0 else (old-new)*100.0/old
def main():
 """Run the command-line workflow and return its process exit status."""
 ap=argparse.ArgumentParser(); ap.add_argument('--baseline',required=True); ap.add_argument('--build',required=True); ap.add_argument('--prefix',default='opt001cr3'); ap.add_argument('--json',required=True); ap.add_argument('--markdown',required=True); a=ap.parse_args()
 base=load(a.baseline); build=Path(a.build); errors=[]; regress=[]; comps={}; med=[]; p99=[]; throughput=[]
 for m in MAPS:
  comps[m]={}
  for mode in MODES:
   p=build/f'{a.prefix}-{m}-{mode}-summary.json'
   if not p.is_file(): errors.append('missing current summary: '+str(p)); continue
   cur=load(p); old=base['maps'][m][mode]; e={'baseline':old,'current':cur,'median_improvement_percent':imp(float(old['median_ms']),float(cur['median_ms'])),'p99_improvement_percent':imp(float(old['p99_ms']),float(cur['p99_ms'])),'throughput_ratio':float(old['total_ms'])/float(cur['total_ms']) if float(cur['total_ms'])>0 else 0.0}; comps[m][mode]=e
   if e['median_improvement_percent'] < -10: regress.append(f'{m}/{mode} median regressed {-e["median_improvement_percent"]:.3f}%')
   if e['p99_improvement_percent'] < -10: regress.append(f'{m}/{mode} p99 regressed {-e["p99_improvement_percent"]:.3f}%')
   if mode=='render': med.append(e['median_improvement_percent']); p99.append(e['p99_improvement_percent']); throughput.append(e['throughput_ratio'])
 agg={}
 if len(med)==2: agg={'render_median_improvement_percent':mean(med),'render_p99_improvement_percent':mean(p99),'render_throughput_ratio':mean(throughput)}
 if errors: cls='INCOMPLETE'; status='FAIL'
 elif regress: cls='REGRESSION'; status='FAIL'
 elif agg and (agg['render_median_improvement_percent']>2 or agg['render_p99_improvement_percent']>2 or agg['render_throughput_ratio']>1.02): cls='IMPROVED'; status='PASS'
 else: cls='NEUTRAL'; status='PASS'
 report={'schema':'MiniQuakeOPT001CR3IncrementalPerformance/1','status':status,'classification':cls,'baseline_revision':'OPT-001CR2','current_prefix':a.prefix,'aggregate':agg,'comparisons':comps,'regressions':regress,'errors':errors}
 Path(a.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
 lines=['# OPT-001CR3 incremental performance','',f'- Status: **{status}**',f'- Classification: **{cls}**','']
 if agg:
  lines += [f'- Render median improvement: **{agg["render_median_improvement_percent"]:.3f}%**',f'- Render P99 improvement: **{agg["render_p99_improvement_percent"]:.3f}%**',f'- Render throughput ratio: **{agg["render_throughput_ratio"]:.4f}×**']
 Path(a.markdown).write_text('\n'.join(lines)+'\n',encoding='utf-8')
 print('MiniQuake OPT-001CR3 incremental performance comparison: '+cls)
 if agg: print(f'  render_median_improvement_percent={agg["render_median_improvement_percent"]:.3f}\n  render_p99_improvement_percent={agg["render_p99_improvement_percent"]:.3f}\n  render_throughput_ratio={agg["render_throughput_ratio"]:.4f}')
 for x in regress: print('  regression: '+x)
 for x in errors: print('  error: '+x)
 return 0 if status=='PASS' else 2
if __name__=='__main__': raise SystemExit(main())
