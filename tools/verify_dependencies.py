#!/usr/bin/env python3
"""Verify pinned build-time third-party source dependencies."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def git(*args: str, cwd: Path) -> str:
    return subprocess.check_output(
        ["git", *args], cwd=cwd, text=True, stderr=subprocess.STDOUT
    ).strip()


def main() -> int:
    lock = json.loads((ROOT / "third_party" / "stb.lock.json").read_text(encoding="utf-8"))
    checkout = ROOT / "third_party" / "stb"
    source = checkout / "stb_vorbis.c"
    if not source.is_file():
        raise SystemExit("stb submodule is not initialized; run git submodule update --init --recursive")
    commit = git("rev-parse", "HEAD", cwd=checkout)
    tree = git("rev-parse", "HEAD^{tree}", cwd=checkout)
    if commit != lock["commit"] or tree != lock["tree"]:
        raise SystemExit(f"stb revision mismatch: {commit} / {tree}")
    expected = lock["files"]["stb_vorbis.c"]
    data = source.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if len(data) != expected["size"] or digest != expected["sha256"]:
        raise SystemExit("stb_vorbis.c checksum mismatch")
    print(f"third-party dependencies verified: stb {commit[:12]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
