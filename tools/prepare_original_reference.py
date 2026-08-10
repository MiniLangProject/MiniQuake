#!/usr/bin/env python3
"""Verify and stage the original GLQuake 1.09 binary for external tests.

The binary is read from a user-supplied original Quake source archive (or an
explicit executable), verified by SHA-256/size/PE machine, and copied into a
build-only staging directory.  MiniQuake never redistributes the executable or
Quake game data in its source package.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import struct
import sys
import tempfile
import zipfile
from pathlib import Path

EXPECTED_SHA256 = "04862c835c399bc9184f62101ae0390c2a758c21656ec06dcc0384e0f373d588"
EXPECTED_SIZE = 435_712
EXPECTED_MACHINE = 0x014C
EXPECTED_MEMBER = "kit/GLQUAKE.EXE"
SCHEMA_VERSION = 1


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def pe_machine(data: bytes) -> int:
    if len(data) < 0x40 or data[:2] != b"MZ":
        raise ValueError("reference is not an MZ executable")
    pe_offset = struct.unpack_from("<I", data, 0x3C)[0]
    if pe_offset + 6 > len(data) or data[pe_offset : pe_offset + 4] != b"PE\0\0":
        raise ValueError("reference has no valid PE header")
    return struct.unpack_from("<H", data, pe_offset + 4)[0]


def find_archive_member(zf: zipfile.ZipFile) -> str:
    wanted = EXPECTED_MEMBER.lower()
    matches = [name for name in zf.namelist() if name.replace("\\", "/").lower() == wanted]
    if not matches:
        matches = [name for name in zf.namelist() if Path(name).name.lower() == "glquake.exe"]
    if len(matches) != 1:
        raise ValueError(f"archive must contain exactly one GLQUAKE.EXE, found {len(matches)}")
    return matches[0]


def load_reference(archive: Path | None, executable: Path | None) -> tuple[bytes, str, str]:
    if archive is not None:
        with zipfile.ZipFile(archive) as zf:
            member = find_archive_member(zf)
            return zf.read(member), "archive", member.replace("\\", "/")
    assert executable is not None
    return executable.read_bytes(), "executable", executable.name


def link_or_copy(source: Path, destination: Path) -> str:
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        os.link(source, destination)
        return "hardlink"
    except OSError:
        shutil.copy2(source, destination)
        return "copy"


def main() -> int:
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=False)
    source.add_argument("--archive", type=Path, help="OriginalQuakeSourceCode.zip")
    source.add_argument("--exe", type=Path, help="original GLQUAKE.EXE")
    parser.add_argument("--quake-base", type=Path, required=True)
    parser.add_argument("--stage", type=Path, required=True)
    parser.add_argument("--json", type=Path)
    args = parser.parse_args()

    source_selector = "cli"
    if args.archive is None and args.exe is None:
        env_archive = os.environ.get("MINIQUAKE_ORIGINAL_SOURCE", "").strip()
        env_executable = os.environ.get("MINIQUAKE_ORIGINAL_EXE", "").strip()
        if env_archive and env_executable:
            parser.error(
                "both MINIQUAKE_ORIGINAL_SOURCE and MINIQUAKE_ORIGINAL_EXE are set; "
                "select exactly one original reference"
            )
        if env_archive:
            args.archive = Path(env_archive)
            source_selector = "environment_archive"
        elif env_executable:
            args.exe = Path(env_executable)
            source_selector = "environment_executable"
        else:
            parser.error(
                "one of --archive/--exe is required (or set "
                "MINIQUAKE_ORIGINAL_SOURCE/MINIQUAKE_ORIGINAL_EXE)"
            )
    elif args.archive is not None:
        source_selector = "cli_archive"
    else:
        source_selector = "cli_executable"

    if args.archive is not None and not args.archive.is_file():
        parser.error(f"archive not found: {args.archive}")
    if args.exe is not None and not args.exe.is_file():
        parser.error(f"executable not found: {args.exe}")
    pak0 = args.quake_base / "id1" / "pak0.pak"
    if not pak0.is_file():
        parser.error(f"Quake data not found: {pak0}")

    try:
        data, source_kind, source_member = load_reference(args.archive, args.exe)
        digest = sha256_bytes(data)
        machine = pe_machine(data)
    except (OSError, ValueError, zipfile.BadZipFile) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2

    errors: list[str] = []
    if len(data) != EXPECTED_SIZE:
        errors.append(f"byte count {len(data)} != {EXPECTED_SIZE}")
    if digest != EXPECTED_SHA256:
        errors.append(f"SHA-256 {digest} != {EXPECTED_SHA256}")
    if machine != EXPECTED_MACHINE:
        errors.append(f"PE machine 0x{machine:04x} != 0x{EXPECTED_MACHINE:04x}")
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 3

    stage = args.stage.resolve()
    if stage.exists():
        shutil.rmtree(stage)
    (stage / "bin").mkdir(parents=True)
    (stage / "basedir" / "id1").mkdir(parents=True)
    exe_path = stage / "bin" / "GLQUAKE.EXE"
    exe_path.write_bytes(data)

    pak_records: list[dict[str, object]] = []
    for pak in sorted((args.quake_base / "id1").glob("pak*.pak"), key=lambda p: p.name.lower()):
        destination = stage / "basedir" / "id1" / pak.name
        method = link_or_copy(pak.resolve(), destination)
        pak_records.append(
            {
                "name": pak.name,
                "bytes": pak.stat().st_size,
                "sha256": hashlib.sha256(pak.read_bytes()).hexdigest(),
                "stage_method": method,
            }
        )

    report = {
        "schema_version": SCHEMA_VERSION,
        "status": "PASS",
        "source_kind": source_kind,
        "source_selector": source_selector,
        "source_member": source_member,
        "reference_filename": "GLQUAKE.EXE",
        "reference_sha256": digest,
        "reference_bytes": len(data),
        "reference_pe_machine": f"0x{machine:04x}",
        "expected_sha256": EXPECTED_SHA256,
        "system_opengl": True,
        "legacy_opengl32_staged": False,
        "pak_count": len(pak_records),
        "paks": pak_records,
        "paths": {
            "executable": str(exe_path),
            "basedir": str(stage / "basedir"),
        },
    }
    json_path = args.json or (stage / "provenance.json")
    json_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    print("MiniQuake BP-090 original GLQuake reference")
    print(f"  source={source_kind}:{source_member}")
    print(f"  source_selector={source_selector}")
    print(f"  sha256={digest}")
    print(f"  bytes={len(data)} machine=0x{machine:04x}")
    print(f"  executable={exe_path}")
    print(f"  basedir={stage / 'basedir'}")
    print(f"  pak_count={len(pak_records)}")
    print(f"  provenance={json_path}")
    print("  result=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
