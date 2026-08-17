#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Analyze opt001cr3r8 audio validation evidence."""

from __future__ import annotations
import argparse, json
from pathlib import Path

def main() -> int:
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser()
    ap.add_argument('--build',required=True)
    ap.add_argument('--prefix',required=True)
    ap.add_argument('--json',required=True)
    args=ap.parse_args()
    build=Path(args.build)
    scenarios=[]; missing=[]
    for map_name in ('e1m1','e1m2'):
        path=build/f'{args.prefix}-{map_name}-render-summary.json'
        if not path.is_file():
            missing.append(path.name); continue
        data=json.loads(path.read_text(encoding='utf-8-sig'))
        totals={item.get('name'):item.get('total_ms',0) for item in data.get('stage_totals',[])}
        total=max(1,data.get('total_ms',0))
        audio=totals.get('audio',0); screen=totals.get('screen',0)
        scenarios.append({'map':map_name,'total_ms':total,'audio_ms':audio,'screen_ms':screen,
                          'audio_percent':audio*100.0/total,'screen_percent':screen*100.0/total,
                          'median_ms':data.get('median_ms',0),'p99_ms':data.get('p99_ms',0)})
    if missing:
        classification='INCOMPLETE'
    else:
        max_audio=max((s['audio_percent'] for s in scenarios),default=0.0)
        max_p99=max((s['p99_ms'] for s in scenarios),default=0)
        if max_audio >= 20.0: classification='AUDIO_CPU_BOUND'
        elif max_p99 >= 80: classification='FRAME_STARVATION_RISK'
        else: classification='AUDIO_COST_OK'
    report={'schema':'MiniQuakeOPT001CR3R8AudioAnalysis/1','classification':classification,
            'prefix':args.prefix,'scenarios':scenarios,'missing':missing}
    Path(args.json).write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('MiniQuake OPT-001D audio cost analysis: '+classification)
    for s in scenarios:
        print(f"  {s['map']}: audio={s['audio_percent']:.3f}% screen={s['screen_percent']:.3f}% median={s['median_ms']} p99={s['p99_ms']}")
    return 0 if classification != 'INCOMPLETE' else 2
if __name__=='__main__': raise SystemExit(main())
