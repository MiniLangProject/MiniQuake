#!/usr/bin/env bash
# Copyright (c) 2026 Nils Kopal
# SPDX-License-Identifier: Apache-2.0
# Build the Linux x86-64 MiniQuake executable and its native runtime bridges.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "${script_dir}/.." && pwd)"
output_dir="${root_dir}/build/linux"
compiler_path="${MINILANG_COMPILER:-}"
stdlib_root="${MINILANG_STDLIB:-}"
python_command="${PYTHON:-python3}"
configuration="release"
run_smoke_tests=1

usage() {
  printf '%s\n' \
    'Usage: ./scripts/build_linux.sh [options]' \
    '' \
    'Options:' \
    '  --compiler PATH   Python MiniLang compiler (must support linux-x64)' \
    '  --stdlib PATH     Import root containing std/fs.ml' \
    '  --python COMMAND  Python 3 interpreter (default: python3)' \
    '  --debug           Compile MiniLang with call tracing and C with symbols' \
    '  --skip-tests      Build without the non-graphical smoke tests' \
    '  -h, --help        Show this help'
}

while (($#)); do
  case "$1" in
    --compiler) compiler_path="${2:?missing compiler path}"; shift 2 ;;
    --stdlib) stdlib_root="${2:?missing stdlib path}"; shift 2 ;;
    --python) python_command="${2:?missing Python command}"; shift 2 ;;
    --debug) configuration="debug"; shift ;;
    --skip-tests) run_smoke_tests=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v "$python_command" >/dev/null 2>&1 || {
  printf 'Python 3 was not found: %s\n' "$python_command" >&2
  exit 1
}
command -v gcc >/dev/null 2>&1 || {
  printf '%s\n' 'GCC was not found. Install the distribution C build tools.' >&2
  exit 1
}

if [[ -z "$compiler_path" ]]; then
  for candidate in \
    "${root_dir}/../MiniLangCompilerOptimization/MiniLangCompilerPy/mlc_win64.py" \
    "${root_dir}/../MiniLangCompilerPy/mlc_win64.py"
  do
    if [[ -f "$candidate" ]] && "$python_command" "$candidate" --help 2>&1 | grep -q -- '--target'; then
      compiler_path="$candidate"
      break
    fi
  done
fi
if [[ -z "$compiler_path" || ! -f "$compiler_path" ]]; then
  printf '%s\n' \
    'The Python MiniLang compiler was not found.' \
    'Pass --compiler PATH or set MINILANG_COMPILER.' >&2
  exit 1
fi
if ! "$python_command" "$compiler_path" --help 2>&1 | grep -q -- '--target'; then
  printf 'The selected MiniLang compiler does not support --target linux-x64: %s\n' "$compiler_path" >&2
  exit 1
fi

if [[ -z "$stdlib_root" ]]; then
  compiler_dir="$(cd -- "$(dirname -- "$compiler_path")" && pwd)"
  for candidate in "$compiler_dir" "$(cd -- "${compiler_dir}/.." && pwd)"; do
    if [[ -f "${candidate}/std/fs.ml" ]]; then stdlib_root="$candidate"; break; fi
  done
fi
if [[ -z "$stdlib_root" || ! -f "${stdlib_root}/std/fs.ml" ]]; then
  printf '%s\n' \
    'The MiniLang standard library was not found.' \
    'Pass --stdlib PATH or set MINILANG_STDLIB to the root containing std/fs.ml.' >&2
  exit 1
fi

mkdir -p "$output_dir"

c_flags=(-std=c11 -fPIC -fvisibility=hidden -Wall -Wextra -Wno-unused-parameter -Wno-maybe-uninitialized)
if [[ "$configuration" == debug ]]; then
  c_flags+=(-O0 -g3)
else
  c_flags+=(-O2 -DNDEBUG)
fi

printf '[MiniQuake/Linux] compiler: %s\n' "$compiler_path"
printf '[MiniQuake/Linux] stdlib:   %s\n' "$stdlib_root"
printf '[MiniQuake/Linux] native OpenGL/SDL bridge\n'
gcc "${c_flags[@]}" -shared \
  "${root_dir}/native/miniquake_native.c" \
  "${root_dir}/native/miniquake_linux_platform.c" \
  "${root_dir}/native/miniquake_linux_backends.c" \
  "${root_dir}/native/miniquake_ogg.c" \
  -o "${output_dir}/libminiquake_native.so" \
  -Wl,-z,defs -Wl,--no-as-needed \
  -l:libSDL2-2.0.so.0 -l:libGL.so.1 -lm -ldl

printf '[MiniQuake/Linux] buffered text bridge\n'
gcc "${c_flags[@]}" -shared \
  "${root_dir}/native/miniquake_text.c" \
  -o "${output_dir}/libminiquake_text.so" \
  -Wl,-z,defs -Wl,--no-as-needed -ldl

compiler_args=(
  --target linux-x64
  -I "${root_dir}/src"
  -I "$stdlib_root"
  --keep-going --max-errors 50
  --heap-reserve 2g
  --heap-commit 512m
  --heap-grow 64m
  --gc-limit 256m
)
if [[ "$configuration" == debug ]]; then compiler_args+=(--trace-calls); fi

printf '[MiniQuake/Linux] MiniLang executable\n'
"$python_command" "$compiler_path" \
  "${compiler_args[@]}" \
  "${root_dir}/src/main.ml" \
  "${output_dir}/MiniQuake"
chmod +x "${output_dir}/MiniQuake"

# Keep library lookup independent of the user's current working directory.
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'set -e' \
  'launcher_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"' \
  '# WSLg can silently select the CPU-only llvmpipe driver for compatibility' \
  '# OpenGL. Prefer its accelerated D3D12 Gallium driver when /dev/dxg exists.' \
  'if [[ -e /dev/dxg && -z "${GALLIUM_DRIVER:-}" && -z "${LIBGL_ALWAYS_SOFTWARE:-}" ]]; then' \
  '  export GALLIUM_DRIVER=d3d12' \
  '  if [[ -z "${MESA_D3D12_DEFAULT_ADAPTER_NAME:-}" && -x /usr/lib/wsl/lib/nvidia-smi ]]; then' \
  '    export MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA' \
  '  fi' \
  'fi' \
  'export LD_LIBRARY_PATH="${launcher_dir}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"' \
  'exec "${launcher_dir}/MiniQuake" "$@"' \
  > "${output_dir}/run-miniquake"
chmod +x "${output_dir}/run-miniquake"

if ((run_smoke_tests)); then
  printf '[MiniQuake/Linux] ABI and executable smoke tests\n'
  LD_LIBRARY_PATH="$output_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    "$python_command" - "$output_dir" <<'PY'
import ctypes
import pathlib
import sys

library = ctypes.CDLL(str(pathlib.Path(sys.argv[1]) / "libminiquake_native.so"))
library.mq_win_text_pop.restype = ctypes.c_int32
if library.mq_win_text_pop() != -1:
    raise SystemExit("empty native text queue did not return the -1 sentinel")
PY
  "${output_dir}/run-miniquake" --version
  "${output_dir}/run-miniquake" --udp-smoke 2000
fi

printf 'MiniQuake Linux build: PASS\n'
printf 'Run: %s --play /path/to/Quake\n' "${output_dir}/run-miniquake"
