#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, pathlib, sys

def emit_report(path, name, passed, details, errors):
    if not path:
        return
    payload = {"schema": 1, "check": name, "status": "PASS" if passed else "FAIL", "passed": passed, "details": details, "errors": errors}
    pathlib.Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")

def main() -> int:
    ap=argparse.ArgumentParser(); ap.add_argument('--root', default=str(pathlib.Path(__file__).resolve().parents[1])); ap.add_argument('--json-output'); args=ap.parse_args()
    root=pathlib.Path(args.root).resolve(); errors=[]
    special=(root/'src/miniquake/render/special_paths.ml').read_text(encoding='utf-8')
    world=(root/'src/miniquake/render/world.ml').read_text(encoding='utf-8')
    host=(root/'src/miniquake/host.ml').read_text(encoding='utf-8')
    handoff=(root/'src/miniquake/client_render_handoff.ml').read_text(encoding='utf-8')
    test=(root/'tests/mirror_special_render_tests.ml').read_text(encoding='utf-8')
    golden=json.loads((root/'audit/mirror_special_golden.json').read_text(encoding='utf-8'))
    for marker in ('const MIRROR_TEXTURE_PREFIX = "window02_1"','function reflectPoint(','function reflectVector(','function reflectView(','function mirrorProjectionScale('):
        if marker not in special: errors.append(f'special_paths missing {marker}')
    for marker in ('function R_MirrorReady()','function renderMirrorViewport(','function R_DrawMirrorOverlay(','rCompatMirrorChain = chain'):
        if marker not in world: errors.append(f'world renderer missing {marker}')
    for marker in ('r_mirroralpha','worldRenderer.renderMirrorViewport(','worldRenderer.R_DrawMirrorOverlay('):
        if marker not in host: errors.append(f'host integration missing {marker}')
    if 'function submitMirrorEntities(' not in handoff: errors.append('mirror entity handoff is missing')

    def function_body(text: str, name: str) -> str:
        start = text.find(f"function {name}(")
        if start < 0:
            return ""
        end = text.find("end function", start)
        return text[start:end] if end >= 0 else text[start:]
    reflected_body = function_body(world, "renderMirrorViewport")
    overlay_body = function_body(world, "R_DrawMirrorOverlay")
    if 'gl.scale(scale.x, scale.y, scale.z)' not in reflected_body:
        errors.append('reflected mirror scene is missing projection reflection')
    if 'gl.scale(' in overlay_body:
        errors.append('mirror overlay must use the restored base projection without another scale')
    if 'gl.cullFace(gl.GL_FRONT)' not in overlay_body:
        errors.append('mirror overlay is missing front-face culling')
    if test.count('bp050Run(') != 23: errors.append('BP-050 test does not contain 22 fixture calls')
    if 'MiniQuake BP-050 mirror special-render tests passed: 22' not in test: errors.append('BP-050 pass marker differs')
    if golden.get('fixtures') != 22 or golden.get('mirror_prefix_bytes') != 10: errors.append('BP-050 golden differs')
    details={"root": str(root), "error_count": len(errors)}
    if errors:
        emit_report(args.json_output, 'bp050_mirror_special_render', False, details, errors)
        print('MiniQuake BP-050 mirror special-render verification: FAIL')
        for e in errors: print('  '+e)
        return 1
    emit_report(args.json_output, 'bp050_mirror_special_render', True, details, [])
    print('MiniQuake BP-050 mirror special-render verification: PASS')
    print('  fixtures=22 mirror_prefix=window02_1 depth_split=0.5')
    return 0
if __name__=='__main__': raise SystemExit(main())
