#!/usr/bin/env python3
from pathlib import Path
import sys
root=Path(sys.argv[sys.argv.index("--root")+1] if "--root" in sys.argv else ".")
text="\n".join(p.read_text(encoding="utf-8") for p in (root/"src").rglob("*.ml"))
need=["function opt001cr3r5ApplyDefaultWindow(arguments)","result[argumentCount] = \"-window\"","opt001cr3r5HasArgument(arguments, \"-fullscreen\")"]
missing=[x for x in need if x not in text]
print("MiniQuake OPT-001CR3R5 window default verification: "+("PASS" if not missing else "FAIL"))
for x in missing: print("missing: "+x)
raise SystemExit(0 if not missing else 1)
