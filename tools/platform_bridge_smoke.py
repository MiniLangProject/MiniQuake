#!/usr/bin/env python3
"""Read-only/synthetic smoke test for the Windows x64 platform bridge.

The deterministic ABI and message-FIFO checks are hard failures. Display gamma
and WinMM controller availability are reported as hardware gates: their absence
under Remote Desktop, CI, or on a controller-less machine is not fabricated
into a parity pass.
"""

from __future__ import annotations

import argparse
import ctypes
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def bind(dll: ctypes.WinDLL, name: str, restype: object, *argtypes: object):
    function = getattr(dll, name)
    function.restype = restype
    function.argtypes = list(argtypes)
    return function


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--dll", type=Path, default=ROOT / "native" / "miniquake_native.dll"
    )
    parser.add_argument(
        "--output", type=Path, default=ROOT / "build" / "platform_bridge_smoke.json"
    )
    args = parser.parse_args()
    dll_path = args.dll.resolve()
    if not dll_path.is_file():
        raise SystemExit(f"missing native bridge: {dll_path}")
    library = ctypes.WinDLL(str(dll_path))

    desktop_width = bind(library, "mq_win_desktop_width", ctypes.c_int)()
    desktop_height = bind(library, "mq_win_desktop_height", ctypes.c_int)()
    mode_count_fn = bind(library, "mq_win_display_mode_count", ctypes.c_uint)
    mode_width = bind(
        library, "mq_win_display_mode_width", ctypes.c_int, ctypes.c_uint
    )
    mode_height = bind(
        library, "mq_win_display_mode_height", ctypes.c_int, ctypes.c_uint
    )
    mode_bpp = bind(
        library, "mq_win_display_mode_bpp", ctypes.c_int, ctypes.c_uint
    )
    mode_frequency = bind(
        library, "mq_win_display_mode_frequency", ctypes.c_int, ctypes.c_uint
    )
    test_mode = bind(
        library,
        "mq_win_test_display_mode",
        ctypes.c_int,
        ctypes.c_int,
        ctypes.c_int,
        ctypes.c_int,
        ctypes.c_int,
    )
    restore_mode = bind(library, "mq_win_restore_display_mode", None)
    gamma_get = bind(
        library,
        "mq_win_get_gamma_ramp",
        ctypes.c_int,
        ctypes.POINTER(ctypes.c_ubyte),
        ctypes.c_uint,
    )
    joy_startup = bind(library, "mq_win_joy_startup", ctypes.c_int)
    joy_read = bind(library, "mq_win_joy_read", ctypes.c_int)
    joy_axis = bind(
        library, "mq_win_joy_axis", ctypes.c_uint, ctypes.c_uint
    )
    joy_buttons = bind(library, "mq_win_joy_buttons", ctypes.c_uint)
    joy_pov = bind(library, "mq_win_joy_pov", ctypes.c_uint)
    joy_button_count = bind(
        library, "mq_win_joy_button_count", ctypes.c_uint
    )
    joy_has_pov = bind(library, "mq_win_joy_has_pov", ctypes.c_int)
    warrior_curve = bind(
        library, "mq_win_joy_warrior_curve", ctypes.c_int, ctypes.c_int
    )
    event_push = bind(
        library,
        "mq_win_input_test_push",
        None,
        ctypes.c_uint,
        ctypes.c_uint,
        ctypes.c_int,
    )
    event_pop = bind(library, "mq_win_input_event_pop", ctypes.c_uint)

    failures: list[str] = []
    if desktop_width <= 0 or desktop_height <= 0:
        failures.append("GetSystemMetrics returned a non-positive desktop size")

    mode_count = mode_count_fn()
    modes = [
        {
            "width": mode_width(index),
            "height": mode_height(index),
            "bpp": mode_bpp(index),
            "frequency": mode_frequency(index),
        }
        for index in range(mode_count)
    ]
    if any(
        mode["width"] <= 0 or mode["height"] <= 0 or mode["bpp"] < 15
        for mode in modes
    ):
        failures.append("EnumDisplaySettings returned an invalid RGB mode")
    tested_mode = False
    if modes:
        first = modes[0]
        tested_mode = (
            test_mode(first["width"], first["height"], first["bpp"], 0) != 0
        )
        if not tested_mode:
            failures.append("ChangeDisplaySettings(CDS_TEST) rejected enumerated mode")
    restore_mode()

    # Synthetic FIFO proof, including the new GLQuake scan-code event type.
    event_push(5, 30, 1)
    event_push(5, 30, 0)
    expected_events = [(5 << 24) | (30 << 8) | 1, (5 << 24) | (30 << 8)]
    actual_events = [event_pop(), event_pop()]
    if actual_events != expected_events or event_pop() != 0:
        failures.append("ordered input FIFO did not preserve scan-code edges")

    if warrior_curve(800) != 300 or warrior_curve(-800) != -300:
        failures.append("WingMan Warrior response curve changed")

    gamma_ramp = (ctypes.c_ubyte * 1536)()
    gamma_available = gamma_get(gamma_ramp, len(gamma_ramp)) != 0
    gamma_nonzero = gamma_available and any(gamma_ramp)

    controller_present = joy_startup() != 0
    controller_read = False
    controller: dict[str, object] = {"present": controller_present}
    if controller_present:
        controller_read = joy_read() != 0
        controller.update(
            {
                "read": controller_read,
                "axes": [joy_axis(axis) for axis in range(6)],
                "buttons": joy_buttons(),
                "pov": joy_pov(),
                "button_count": joy_button_count(),
                "has_pov": joy_has_pov() != 0,
            }
        )
        if not controller_read:
            failures.append("detected WinMM controller could not be read")
        if int(controller["button_count"]) > 32:
            failures.append("controller button count exceeds DWORD protocol")

    limitations = []
    if not gamma_available:
        limitations.append(
            "GetDeviceGammaRamp unavailable on this display/session; set/restore "
            "requires a physical display test."
        )
    elif not gamma_nonzero:
        limitations.append(
            "Display returned an all-zero gamma ramp; set/restore remains a "
            "physical-display gate."
        )
    else:
        limitations.append(
            "Gamma ramp was read successfully; mutation/visual calibration was "
            "not automated to avoid changing the user's desktop."
        )
    if not controller_present:
        limitations.append(
            "No WinMM controller was attached; live axes/buttons/POV remain a "
            "hardware gate."
        )

    report = {
        "schema": "miniquake.platform-bridge-smoke.v1",
        "status": "passed" if not failures else "failed",
        "dll": str(dll_path),
        "desktop": [desktop_width, desktop_height],
        "display_modes": {
            "count": mode_count,
            "cds_test_first_mode": tested_mode if modes else None,
        },
        "input_fifo": {
            "expected": expected_events,
            "actual": actual_events,
        },
        "gamma": {
            "get_available": gamma_available,
            "nonzero": gamma_nonzero,
        },
        "controller": controller,
        "limitations": limitations,
        "failures": failures,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(
        f"platform bridge smoke: {report['status'].upper()} "
        f"({mode_count} display modes, controller="
        f"{'present' if controller_present else 'not attached'})"
    )
    print(f"report: {args.output}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
