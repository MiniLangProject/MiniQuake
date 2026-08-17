#!/usr/bin/env python3
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0

"""Raw full-frame Original GLQuake versus MiniQuake TGA comparator.

Only temporal candidate selection is permitted. Pixels are never cropped,
translated, rescaled, gamma-corrected, colour-normalized or otherwise altered.
Two independently produced Original GLQuake captures may be supplied. Every
MiniQuake candidate is scored against every original and the release gate uses
the minimum (worst-case) 8x8-window luminance SSIM.
"""
from __future__ import annotations
import argparse, hashlib, json, math, struct
from pathlib import Path
WINDOW = 8

# Machine-readable source-contract markers retained for historical checkers:
# "normalization": "none"
# "alignment": "temporal_candidate_selection_only"
# "reference_aggregation": "minimum_ssim"
# "schema_version": 3

def sha256(path: Path) -> str:
    """Compute the SHA-256 digest of the requested file."""
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024), b''): h.update(block)
    return h.hexdigest()

def read_tga(path: Path):
    """Read tga from its caller-supplied source."""
    data=path.read_bytes()
    if len(data)<18: raise ValueError(f"{path}: truncated TGA")
    ident, cmap, image_type = data[0], data[1], data[2]
    width=struct.unpack_from('<H',data,12)[0]; height=struct.unpack_from('<H',data,14)[0]
    depth=data[16]; descriptor=data[17]
    if cmap!=0 or image_type!=2 or depth!=24:
        raise ValueError(f"{path}: expected uncompressed non-paletted 24-bit TGA")
    if width<=0 or height<=0: raise ValueError(f"{path}: invalid TGA dimensions {width}x{height}")
    offset=18+ident; payload_bytes=width*height*3; expected=offset+payload_bytes
    if len(data)!=expected: raise ValueError(f"{path}: expected exactly {expected} TGA bytes, got {len(data)}")
    payload=data[offset:]
    top=bool(descriptor&0x20); right=bool(descriptor&0x10)
    if top and not right: decoded=payload
    else:
        out=bytearray(payload_bytes)
        for sy in range(height):
            ly=sy if top else height-1-sy
            for sx in range(width):
                lx=width-1-sx if right else sx
                a=(sy*width+sx)*3; b=(ly*width+lx)*3
                out[b:b+3]=payload[a:a+3]
        decoded=bytes(out)
    return width,height,decoded,{'file_bytes':len(data),'expected_file_bytes':expected,'id_length':ident,'descriptor':descriptor}

def luminance_bgr(payload: bytes):
    """Convert one BGR sample to relative luminance."""
    out=[0.0]*(len(payload)//3); j=0
    for i in range(0,len(payload),3):
        b,g,r=payload[i],payload[i+1],payload[i+2]; out[j]=0.114*b+0.587*g+0.299*r; j+=1
    return out

def ssim_values(a,b):
    """Compute structural-similarity statistics for paired samples."""
    n=len(a)
    if n==0 or len(b)!=n: raise ValueError('invalid SSIM sample window')
    ma=sum(a)/n; mb=sum(b)/n
    va=sum((x-ma)**2 for x in a)/n; vb=sum((x-mb)**2 for x in b)/n
    cov=sum((x-ma)*(y-mb) for x,y in zip(a,b))/n
    c1=(0.01*255.0)**2; c2=(0.03*255.0)**2
    den=(ma*ma+mb*mb+c1)*(va+vb+c2)
    return ((2*ma*mb+c1)*(2*cov+c2))/den if den else 1.0

def windowed_ssim(a,b,w,h):
    """Compute windowed structural similarity for two framebuffers."""
    values=[]
    for y0 in range(0,h,WINDOW):
        y1=min(y0+WINDOW,h)
        for x0 in range(0,w,WINDOW):
            x1=min(x0+WINDOW,w); left=[]; right=[]
            for y in range(y0,y1):
                s=y*w+x0; e=y*w+x1; left.extend(a[s:e]); right.extend(b[s:e])
            values.append(ssim_values(left,right))
    return sum(values)/len(values)

def metrics(a:bytes,b:bytes,w:int,h:int):
    """Compute pixel-difference and SSIM metrics for two reference images."""
    if len(a)!=len(b): raise ValueError('pixel payload lengths differ')
    n=len(a); absolute=squared=changed=0
    for x,y in zip(a,b):
        d=x-y; absolute+=abs(d); squared+=d*d; changed += int(d!=0)
    mae=absolute/n; mse=squared/n; psnr=float('inf') if mse==0 else 10*math.log10(255*255/mse)
    la=luminance_bgr(a); lb=luminance_bgr(b)
    local=windowed_ssim(la,lb,w,h); global_ssim=ssim_values(la,lb)
    changed_pixels=sum(1 for i in range(0,n,3) if a[i:i+3]!=b[i:i+3])
    return {'mae':mae,'mse':mse,'psnr':psnr,'ssim':local,'ssim_windowed_8x8':local,
            'ssim_global':global_ssim,'changed_bytes':changed,'changed_pixels':changed_pixels,'total_pixels':w*h}

def parse_candidate(text:str):
    """Parse candidate into its normalized representation."""
    f,sep,p=text.partition(':')
    if not sep: raise argparse.ArgumentTypeError('candidate must be FRAME:PATH')
    try: frame=int(f)
    except ValueError as exc: raise argparse.ArgumentTypeError('candidate frame must be an integer') from exc
    return frame,Path(p)

def main():
    """Run the command-line workflow and return its process exit status."""
    ap=argparse.ArgumentParser(); ap.add_argument('original',type=Path)
    ap.add_argument('--original-alt',action='append',type=Path,default=[])
    ap.add_argument('--candidate',action='append',type=parse_candidate,required=True)
    ap.add_argument('--min-ssim',type=float,default=0.95)
    ap.add_argument('--min-reference-ssim',type=float,default=0.98)
    ap.add_argument('--json-out','--json-output',dest='json_out',type=Path,required=True)
    ap.add_argument('--scenario',default=''); args=ap.parse_args()
    paths=[args.original,*args.original_alt]
    try:
        refs=[]; w=h=0
        for idx,path in enumerate(paths):
            rw,rh,pixels,tga=read_tga(path)
            if idx==0: w,h=rw,rh
            elif (rw,rh)!=(w,h): raise ValueError(f"{path}: dimensions {rw}x{rh} differ from primary original {w}x{h}")
            refs.append({'index':idx,'path':str(path),'sha256':sha256(path),'pixels':pixels,**tga})
        pairs=[]
        for i in range(len(refs)):
            for j in range(i+1,len(refs)):
                m=metrics(refs[i]['pixels'],refs[j]['pixels'],w,h)
                pairs.append({'left_index':i,'right_index':j,'left_path':refs[i]['path'],'right_path':refs[j]['path'],
                              'exact_file':refs[i]['sha256']==refs[j]['sha256'],'exact_pixels':refs[i]['pixels']==refs[j]['pixels'],**m})
        ref_min=min((float(p['ssim']) for p in pairs),default=1.0)
        ref_exact=all(bool(p['exact_file']) for p in pairs)
        ref_status='PASS' if ref_min>=args.min_reference_ssim else 'FAIL'
        candidates=[]
        for frame,path in args.candidate:
            cw,ch,pixels,tga=read_tga(path)
            if (cw,ch)!=(w,h): raise ValueError(f"{path}: dimensions {cw}x{ch} differ from original {w}x{h}")
            per=[]
            for ref in refs:
                per.append({'reference_index':ref['index'],'reference_path':ref['path'],**metrics(ref['pixels'],pixels,w,h)})
            worst=min(per,key=lambda x:float(x['ssim'])); ss=[float(x['ssim']) for x in per]
            candidates.append({'frame':frame,'path':str(path),'sha256':sha256(path),'reference_aggregation':'minimum_ssim',
                'ssim':min(ss),'ssim_min':min(ss),'ssim_mean':sum(ss)/len(ss),'worst_reference_index':worst['reference_index'],
                'mae':worst['mae'],'mse':worst['mse'],'psnr':worst['psnr'],'ssim_global':worst['ssim_global'],
                'ssim_windowed_8x8':worst['ssim_windowed_8x8'],'changed_bytes':worst['changed_bytes'],
                'changed_pixels':worst['changed_pixels'],'total_pixels':worst['total_pixels'],'per_reference':per,**tga})
    except (OSError,ValueError) as exc:
        print(f'ERROR: {exc}'); return 2
    best=max(candidates,key=lambda x:(float(x['ssim_min']),float(x['ssim_mean'])))
    candidate_status='PASS' if float(best['ssim_min'])>=args.min_ssim else 'FAIL'
    status='PASS' if ref_status=='PASS' and candidate_status=='PASS' else 'FAIL'
    serial_refs=[{k:v for k,v in r.items() if k!='pixels'} for r in refs]
    report={'schema_version':3,'status':status,'scenario':args.scenario,'normalization':'none',
      'alignment':'temporal_candidate_selection_only','tga_origin_handling':'decoded_per_file_header',
      'metric':'mean_luminance_ssim_8x8','dimensions':[w,h],'minimum_ssim':args.min_ssim,
      'minimum_reference_ssim':args.min_reference_ssim,'reference_aggregation':'minimum_ssim',
      'reference_consistency':{'status':ref_status,'exact':ref_exact,'minimum_ssim':ref_min,'pairs':pairs},
      'references':serial_refs,'best':best,'candidates':candidates}
    args.json_out.parent.mkdir(parents=True,exist_ok=True)
    args.json_out.write_text(json.dumps(report,indent=2,sort_keys=True,allow_nan=True)+'\n',encoding='utf-8')
    print('MiniQuake BP-093 original visual comparison')
    print(f'  scenario={args.scenario}'); print(f'  dimensions={w}x{h}'); print('  normalization=none')
    print('  alignment=temporal_candidate_selection_only'); print('  metric=mean_luminance_ssim_8x8')
    print(f'  references={len(refs)}'); print(f'  reference_exact={str(ref_exact).lower()}')
    print(f'  reference_min_ssim={ref_min:.12f}'); print(f'  minimum_reference_ssim={args.min_reference_ssim:.12f}')
    print('  reference_aggregation=minimum_ssim'); print(f"  best_frame={best['frame']}")
    print(f"  ssim={float(best['ssim_min']):.12f}"); print(f"  ssim_mean={float(best['ssim_mean']):.12f}")
    print(f"  global_ssim={float(best['ssim_global']):.12f}"); print(f"  mae={float(best['mae']):.12f}")
    print(f"  psnr={float(best['psnr']):.12f}"); print(f"  changed_pixels={int(best['changed_pixels'])}/{int(best['total_pixels'])}")
    print(f'  minimum_ssim={args.min_ssim:.12f}'); print(f'  report={args.json_out}'); print(f'  result={status}')
    return 0 if status=='PASS' else 1
if __name__=='__main__': raise SystemExit(main())
