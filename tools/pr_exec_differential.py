#!/usr/bin/env python3
"""Pinned pr_exec.c differential, including isolated fatal-error processes."""
from __future__ import annotations
import argparse
import ctypes
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PIN = "bf4ac424ce754894ac8f1dae6a3981954bc9852d"

def bridge():
    path = ROOT / "native" / "build_bridge.py"
    spec = importlib.util.spec_from_file_location("mq_bridge", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def run(command, capture=False):
    result = subprocess.run(command, cwd=ROOT, check=True, text=True,
        stdout=subprocess.PIPE if capture else None)
    return result.stdout or ""

def build(output):
    compiler, linker, _ = bridge().find_msvc_tools()
    worktree = output / "pinned_quake"
    if worktree.exists():
        run(["git","-C",str(ROOT/"reference/quake"),"worktree","remove","--force",str(worktree)])
    run(["git","-C",str(ROOT/"reference/quake"),"worktree","add","--detach",str(worktree),PIN])
    run(["git","-C",str(worktree),"apply",str(ROOT/"reference/patches/pr_exec_pinned_oracle.patch")])
    common=[compiler,"/nologo","/c","/W4","/GS-","/Zl","/fp:precise","/O2","/Gy",
        f"/I{ROOT/'reference/harness'}"]
    source=output/"pr_exec.obj"; driver=output/"pr_exec_driver.obj"
    run(common+["/DMINIQUAKE_PINNED_ORACLE",f"/Fo{source}",str(worktree/"WinQuake/pr_exec.c")])
    run(common+[f"/Fo{driver}",str(ROOT/"reference/harness/pr_exec_pinned_driver.c")])
    dll=output/"pr_exec_oracle.dll"
    run([linker,"/dll","/noentry","/machine:x64","/nodefaultlib","/opt:ref",
        f"/def:{ROOT/'reference/harness/pr_exec_oracle.def'}",f"/out:{dll}",
        str(source),str(driver),str(ROOT/"native/build/msvcrt.lib"),
        str(ROOT/"native/build/kernel32.lib")])
    return dll

def oracle(dll,destination):
    library=ctypes.WinDLL(str(dll)); function=library.pr_exec_oracle_jsonl
    function.argtypes=[ctypes.c_char_p,ctypes.c_int]; function.restype=ctypes.c_int
    buffer=ctypes.create_string_buffer(65536); size=function(buffer,len(buffer))
    destination.write_bytes(buffer.raw[:size])

def candidate(compiler,output,destination):
    executable=output/"pr_exec_minilang.exe"
    shutil.copy2(ROOT/"native/miniquake_native.dll",output/"miniquake_native.dll")
    run([sys.executable,str(compiler),str(ROOT/"tests/pr_exec_differential_fixture.ml"),
        str(executable),"-I",str(ROOT),"-I",str(ROOT/"src"),"-I",str(compiler.parent),
        "--keep-going","--max-errors","50","--heap-reserve","512m",
        "--heap-commit","32m","--heap-grow","4m"])
    destination.write_text(run([str(executable)],True),encoding="utf-8",newline="\n")
    return executable

def fatal_processes(dll, executable):
    code=("import ctypes; d=ctypes.WinDLL(r'"+str(dll)+
          "'); d.pr_exec_error_case()")
    reference=subprocess.run(
        [sys.executable,"-c",code],cwd=ROOT,
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    mini=subprocess.run(
        [str(executable),"--error"],cwd=ROOT,
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if reference.returncode == 0 or mini.returncode != 42:
        raise RuntimeError(
            f"fatal process mismatch: reference={reference.returncode}, minilang={mini.returncode}")
    print(f"pr_exec fatal differential: PASS (reference={reference.returncode}, minilang=42)")

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--compiler",type=Path,default=ROOT.parent/"MiniLangCompilerPy/mlc_win64.py")
    parser.add_argument("--output",type=Path,default=ROOT/"build/pr_exec_differential")
    args=parser.parse_args(); output=args.output.resolve()
    if not output.is_relative_to((ROOT/"build").resolve()):
        raise RuntimeError("output must remain inside ROOT/build")
    output.mkdir(parents=True,exist_ok=True)
    ref=output/"reference.jsonl"; cand=output/"minilang.jsonl"
    dll=build(output); oracle(dll,ref); exe=candidate(args.compiler.resolve(),output,cand)
    manifest=json.loads((ROOT/"audit/pr_exec_differential_manifest.json").read_text())
    events=[json.loads(line) for line in ref.read_text().splitlines() if line]
    if len(events)!=manifest["events"]: raise RuntimeError("event count mismatch")
    run([sys.executable,str(ROOT/"tools/parity_oracle.py"),"compare-traces",
        str(ref),str(cand),"--epsilon","1e-5"])
    fatal_processes(dll,exe)
    print("pr_exec differential: PASS (7 events, epsilon=1e-5)")
    return 0
if __name__=="__main__": raise SystemExit(main())
