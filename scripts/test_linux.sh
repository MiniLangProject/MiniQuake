#!/usr/bin/env bash
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Build and exercise Linux platform, renderer, retail runtime and audio paths.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "${script_dir}/.." && pwd)"
quake_base="${MINIQUAKE_QUAKE_BASE:-}"
skip_build=0
skip_graphics=0
build_args=()

usage() {
  printf '%s\n' \
    'Usage: ./scripts/test_linux.sh [options]' \
    '' \
    'Options:' \
    '  --quake-base PATH  Quake directory containing id1/pak0.pak' \
    '  --skip-build       Test the existing build/linux artifacts' \
    '  --skip-graphics    Omit SDL/OpenGL smoke and retail render tests' \
    '  --compiler PATH    Forward compiler path to build_linux.sh' \
    '  --stdlib PATH      Forward stdlib path to build_linux.sh' \
    '  --python COMMAND   Forward Python command to build_linux.sh' \
    '  --debug            Build a debug executable' \
    '  -h, --help         Show this help'
}

while (($#)); do
  case "$1" in
    --quake-base) quake_base="${2:?missing Quake directory}"; shift 2 ;;
    --skip-build) skip_build=1; shift ;;
    --skip-graphics) skip_graphics=1; shift ;;
    --compiler|--stdlib|--python) build_args+=("$1" "${2:?missing option value}"); shift 2 ;;
    --debug) build_args+=("$1"); shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if ((skip_build == 0)); then "${script_dir}/build_linux.sh" "${build_args[@]}"; fi

launcher="${root_dir}/build/linux/run-miniquake"
[[ -x "$launcher" ]] || { printf 'Linux launcher not found: %s\n' "$launcher" >&2; exit 1; }

"$launcher" --version
"$launcher" --udp-smoke 2000

if ((skip_graphics == 0)); then
  if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    gl_output="$("$launcher" --gl-smoke-frames 10)"
    printf '%s\n' "$gl_output"
    if [[ -e /dev/dxg && -z "${GALLIUM_DRIVER:-}" && -z "${LIBGL_ALWAYS_SOFTWARE:-}" ]] && grep -qi 'llvmpipe' <<< "$gl_output"; then
      printf '%s\n' 'WSLg OpenGL unexpectedly selected the CPU-only llvmpipe driver.' >&2
      exit 1
    fi
  else
    printf '%s\n' 'Linux graphical smoke: SKIP (DISPLAY and WAYLAND_DISPLAY are unset)'
  fi
fi

if [[ -n "$quake_base" ]]; then
  [[ -f "${quake_base}/id1/pak0.pak" ]] || {
    printf 'Quake data not found below: %s\n' "$quake_base" >&2
    exit 1
  }
  "$launcher" --runtime-smoke "$quake_base" e1m1 60
  "$launcher" --music-smoke "$quake_base" id1 2
  "$launcher" -basedir "$quake_base" -game id1 -dedicated 2 -maxframes 30 +map e1m1
  if ((skip_graphics == 0)) && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    "$launcher" --render-smoke "$quake_base" e1m1 30
    "$launcher" --play "$quake_base" e1m1 -window -maxframes 30
    "$launcher" --play "$quake_base" e1m1 -fullscreen -maxframes 10
  fi
fi

printf 'MiniQuake Linux test suite: PASS\n'
