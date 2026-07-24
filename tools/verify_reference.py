#!/usr/bin/env python3
"""Verify the pinned, unmodified GLQuake reference checkout."""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference"
QUAKE = REFERENCE / "quake"
LOCK_PATH = REFERENCE / "quake.lock.json"


def fail(message: str) -> "NoReturn":
    raise SystemExit(f"GLQuake reference verification failed: {message}")


def git(*arguments: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(QUAKE), *arguments],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if result.returncode != 0:
        fail(result.stderr.strip() or "git command failed")
    return result.stdout.strip()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def source_manifest(root: Path, extensions: set[str]) -> tuple[int, str]:
    files = sorted(
        (
            path
            for path in root.rglob("*")
            if path.is_file() and path.suffix.lower() in extensions
        ),
        key=lambda path: path.relative_to(QUAKE).as_posix(),
    )
    lines = [
        f"{sha256_file(path)}  {path.relative_to(QUAKE).as_posix()}"
        for path in files
    ]
    payload = (("\n".join(lines) + "\n") if lines else "").encode("utf-8")
    return len(files), hashlib.sha256(payload).hexdigest()


def main() -> int:
    if not LOCK_PATH.is_file():
        fail(f"missing lock file: {LOCK_PATH}")
    if not (QUAKE / ".git").exists():
        fail("submodule is absent; run `git submodule update --init`")

    lock = json.loads(LOCK_PATH.read_text(encoding="utf-8"))
    commit = git("rev-parse", "HEAD")
    tree = git("rev-parse", "HEAD^{tree}")
    if commit != lock["commit"]:
        fail(f"commit is {commit}, expected {lock['commit']}")
    if tree != lock["tree"]:
        fail(f"tree is {tree}, expected {lock['tree']}")
    if git("status", "--porcelain"):
        fail("submodule has local modifications")

    source = lock["source_scope"]
    source_root = QUAKE / source["root"]
    count, manifest_hash = source_manifest(
        source_root, {value.lower() for value in source["extensions"]}
    )
    if count != source["file_count"]:
        fail(f"source file count is {count}, expected {source['file_count']}")
    if manifest_hash != source["manifest_sha256"]:
        fail(
            "source manifest SHA-256 is "
            f"{manifest_hash}, expected {source['manifest_sha256']}"
        )

    oracle = lock["oracle"]
    executable = QUAKE / oracle["historical_executable"]
    if not executable.is_file():
        fail(f"historical executable is missing: {executable}")
    if executable.stat().st_size != oracle["size"]:
        fail(
            f"historical executable size is {executable.stat().st_size}, "
            f"expected {oracle['size']}"
        )
    executable_hash = sha256_file(executable)
    if executable_hash != oracle["sha256"]:
        fail(
            "historical executable SHA-256 is "
            f"{executable_hash}, expected {oracle['sha256']}"
        )

    print(
        "GLQuake reference verified: "
        f"{commit[:12]}, {count} source files, oracle {executable_hash[:12]}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
