#!/usr/bin/env python3
"""Generate a conservative, function-level GLQuake-to-MiniLang inventory.

The inventory is intentionally not a parity scorer.  A source-location match
only proves that a plausible MiniLang declaration exists.  Behavioral parity
must be established separately by differential tests.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "reference" / "quake" / "WinQuake"
PROJECT = REFERENCE / "WinQuake.dsp"
LOCK = ROOT / "reference" / "quake.lock.json"
JSON_PATH = ROOT / "audit" / "GLQUAKE_PORT_INVENTORY.json"
MARKDOWN_PATH = ROOT / "docs" / "GLQUAKE_PORT_INVENTORY.md"
CONFIGURATION = "winquake - Win32 GL Release"

SOURCE_BLOCK = re.compile(
    r"# Begin Source File\s+(?P<body>.*?)# End Source File", re.DOTALL
)
SOURCE_PATH = re.compile(r"^SOURCE=\.\\(?P<path>.+?)\s*$", re.MULTILINE)
INCLUDE = re.compile(r'^\s*#\s*include\s*[<"]([^>"]+)[>"]', re.MULTILINE)
ML_DECLARATION = re.compile(
    r"^\s*(?:(?P<static>static)\s+)?(?:(?P<extern>extern)\s+)?"
    r"(?P<kind>function|struct|enum|const)\s+"
    r"(?:(?:inline)\s+)?(?P<name>[A-Za-z_][A-Za-z0-9_]*)",
    re.MULTILINE,
)

# The modules are logical counterparts, not parity assertions.  This explicit
# table makes a newly selected GL source fail generation until it is reviewed.
UNIT_MODULES: dict[str, list[str]] = {
    "alias_tables": [
        "src/miniquake/render/alias_normals.ml",
        "src/miniquake/render/alias_mesh.ml",
    ],
    "bsp_format": [
        "src/miniquake/format/bsp.ml",
        "src/miniquake/constants.ml",
        "src/miniquake/types.ml",
    ],
    "cd_audio": [
        "src/miniquake/sound/cd_audio.ml",
        "src/miniquake/sound/mixer.ml",
        "src/miniquake/filesystem.ml",
        "src/miniquake/host.ml",
        "src/miniquake/native.ml",
    ],
    "chase": ["src/miniquake/chase.ml"],
    "cl_demo": [
        "src/miniquake/demo.ml",
        "src/miniquake/demo_player.ml",
        "src/miniquake/client.ml",
    ],
    "cl_input": [
        "src/miniquake/input.ml",
        "src/miniquake/protocol_write.ml",
        "src/miniquake/client.ml",
    ],
    "cl_main": [
        "src/miniquake/client.ml",
        "src/miniquake/client_state.ml",
        "src/miniquake/client_protocol.ml",
        "src/miniquake/client_effects.ml",
        "src/miniquake/demo.ml",
        "src/miniquake/demo_player.ml",
        "src/miniquake/input.ml",
        "src/miniquake/protocol_write.ml",
        "src/miniquake/temp_entities.ml",
        "src/miniquake/particles.ml",
        "src/miniquake/types.ml",
    ],
    "cl_parse": [
        "src/miniquake/client_protocol.ml",
        "src/miniquake/client.ml",
        "src/miniquake/client_effects.ml",
    ],
    "cl_tent": [
        "src/miniquake/temp_entities.ml",
        "src/miniquake/client_effects.ml",
        "src/miniquake/particles.ml",
    ],
    "cmd": ["src/miniquake/cmd.ml", "src/miniquake/host.ml"],
    "common": [
        "src/miniquake/common.ml",
        "src/miniquake/filesystem.ml",
        "src/miniquake/byteio.ml",
        "src/miniquake/message.ml",
        "src/miniquake/sizebuf.ml",
        "src/miniquake/pak.ml",
        "src/miniquake/launch.ml",
    ],
    "conproc": [
        "src/miniquake/conproc.ml",
        "src/miniquake/platform/win32.ml",
        "src/miniquake/native.ml",
    ],
    "console": ["src/miniquake/console.ml", "src/miniquake/screen.ml"],
    "crc": ["src/miniquake/crc.ml"],
    "cvar": ["src/miniquake/cvar.ml"],
    "gl_draw": [
        "src/miniquake/render/draw2d.ml",
        "src/miniquake/render/gl11.ml",
        "src/miniquake/menu.ml",
        "src/miniquake/statusbar.ml",
    ],
    "gl_mesh": [
        "src/miniquake/render/alias_mesh.ml",
        "src/miniquake/render/entities.ml",
    ],
    "gl_model": [
        "src/miniquake/format/bsp.ml",
        "src/miniquake/format/mdl.ml",
        "src/miniquake/format/sprite.ml",
        "src/miniquake/model_registry.ml",
        "src/miniquake/world_bsp.ml",
        "src/miniquake/types.ml",
    ],
    "gl_refrag": [
        "src/miniquake/render/gl_refrag.ml",
        "src/miniquake/render/original.ml",
        "src/miniquake/render/entities.ml",
    ],
    "gl_rlight": [
        "src/miniquake/render/gl_rlight.ml",
        "src/miniquake/render/world.ml",
    ],
    "gl_rmain": [
        "src/miniquake/render/gl_rmain.ml",
        "src/miniquake/render/original.ml",
        "src/miniquake/render/alias_mesh.ml",
        "src/miniquake/render/gl_rlight.ml",
        "src/miniquake/render/gl_warp.ml",
        "src/miniquake/render/gl11.ml",
        "src/miniquake/render/draw2d.ml",
        "src/miniquake/render/world.ml",
        "src/miniquake/render/entities.ml",
        "src/miniquake/render/particles.ml",
        "src/miniquake/view.ml",
        "src/miniquake/types.ml",
    ],
    "gl_rmisc": [
        "src/miniquake/render/gl_rmisc.ml",
        "src/miniquake/render/original.ml",
        "src/miniquake/render/world.ml",
        "src/miniquake/render/entities.ml",
        "src/miniquake/render/particles.ml",
    ],
    "gl_rsurf": ["src/miniquake/render/world.ml"],
    "gl_screen": [
        "src/miniquake/screen.ml",
        "src/miniquake/console.ml",
        "src/miniquake/menu.ml",
        "src/miniquake/statusbar.ml",
    ],
    "gl_test": [
        "src/miniquake/render/gl_test.ml",
        "src/miniquake/gl_smoke.ml",
    ],
    "gl_vidnt": [
        "src/miniquake/gl_vidnt.ml",
        "src/miniquake/platform/win32.ml",
        "src/miniquake/render/gl11.ml",
        "src/miniquake/native.ml",
    ],
    "gl_warp": [
        "src/miniquake/render/gl_warp.ml",
        "src/miniquake/render/world.ml",
    ],
    "host": ["src/miniquake/host.ml", "src/miniquake/host_timing.ml"],
    "host_cmd": [
        "src/miniquake/host.ml",
        "src/miniquake/savegame.ml",
        "src/miniquake/server.ml",
    ],
    "in_win": [
        "src/miniquake/input.ml",
        "src/miniquake/platform/win32.ml",
        "src/miniquake/native.ml",
    ],
    "keys": [
        "src/miniquake/keys.ml",
        "src/miniquake/input.ml",
        "src/miniquake/host.ml",
        "src/miniquake/menu.ml",
        "src/miniquake/console.ml",
    ],
    "mathlib": ["src/miniquake/mathlib.ml"],
    "menu": ["src/miniquake/menu.ml", "src/miniquake/host.ml"],
    "model_format": [
        "src/miniquake/format/mdl.ml",
        "src/miniquake/model_registry.ml",
        "src/miniquake/constants.ml",
        "src/miniquake/types.ml",
    ],
    "net_dgrm": [
        "src/miniquake/net_loop.ml",
        "src/miniquake/net_datagram.ml",
        "src/miniquake/net_udp.ml",
        "src/miniquake/net_control.ml",
    ],
    "net_loop": ["src/miniquake/net_loop.ml"],
    "net_main": [
        "src/miniquake/net_main.ml",
        "src/miniquake/net_wins.ml",
        "src/miniquake/net_loop.ml",
        "src/miniquake/net_datagram.ml",
        "src/miniquake/net_udp.ml",
        "src/miniquake/net_control.ml",
        "src/miniquake/client.ml",
        "src/miniquake/server.ml",
    ],
    "net_vcr": [],
    "net_win": [
        "src/miniquake/net_loop.ml",
        "src/miniquake/net_datagram.ml",
        "src/miniquake/net_udp.ml",
        "src/miniquake/native.ml",
    ],
    "net_wins": [
        "src/miniquake/net_wins.ml",
        "src/miniquake/net_udp.ml",
        "src/miniquake/native.ml",
    ],
    "net_wipx": [],
    "pr_cmds": ["src/miniquake/quakec/builtins.ml"],
    "pr_edict": [
        "src/miniquake/quakec/edict.ml",
        "src/miniquake/savegame.ml",
        "src/miniquake/server.ml",
    ],
    "pr_exec": [
        "src/miniquake/quakec/vm.ml",
        "src/miniquake/quakec/opcodes.ml",
    ],
    "protocol": [
        "src/miniquake/constants.ml",
        "src/miniquake/client_protocol.ml",
        "src/miniquake/protocol_write.ml",
        "src/miniquake/message.ml",
    ],
    "quakec_abi": [
        "src/miniquake/format/progs.ml",
        "src/miniquake/constants.ml",
        "src/miniquake/quakec/opcodes.ml",
        "src/miniquake/quakec/vm.ml",
        "src/miniquake/quakec/edict.ml",
        "src/miniquake/types.ml",
    ],
    "quakedef": [
        "src/miniquake/types.ml",
        "src/miniquake/constants.ml",
        "src/miniquake/host.ml",
        "src/miniquake/server.ml",
        "src/miniquake/client.ml",
        "src/miniquake/input.ml",
        "src/miniquake/console.ml",
        "src/miniquake/screen.ml",
        "src/miniquake/view.ml",
        "src/miniquake/filesystem.ml",
        "src/miniquake/cvar.ml",
        "src/miniquake/cmd.ml",
        "src/miniquake/memory.ml",
        "src/miniquake/audio.ml",
    ],
    "r_part": [
        "src/miniquake/particles.ml",
        "src/miniquake/render/particles.ml",
    ],
    "render_types": [
        "src/miniquake/types.ml",
        "src/miniquake/render/world.ml",
        "src/miniquake/render/entities.ml",
    ],
    "resource": ["src/miniquake/platform/win32.ml"],
    "sbar": ["src/miniquake/statusbar.ml"],
    "serial_network": [],
    "snd_dma": [
        "src/miniquake/sound/snd_dma.ml",
        "src/miniquake/sound/mixer.ml",
        "src/miniquake/audio.ml",
        "src/miniquake/types.ml",
    ],
    "snd_mem": [
        "src/miniquake/sound/snd_mem.ml",
        "src/miniquake/sound/wav.ml",
        "src/miniquake/sound/mixer.ml",
    ],
    "snd_mix": [
        "src/miniquake/sound/snd_mix.ml",
        "src/miniquake/sound/mixer.ml",
    ],
    "snd_win": [
        "src/miniquake/sound/snd_win.ml",
        "src/miniquake/audio.ml",
        "src/miniquake/native.ml",
    ],
    "software_renderer_headers": [],
    "sprite_format": [
        "src/miniquake/format/sprite.ml",
        "src/miniquake/constants.ml",
        "src/miniquake/types.ml",
    ],
    "sv_main": [
        "src/miniquake/sv_main.ml",
        "src/miniquake/sv_user.ml",
        "src/miniquake/server.ml",
        "src/miniquake/server_move.ml",
        "src/miniquake/physics.ml",
        "src/miniquake/server_collision.ml",
        "src/miniquake/world.ml",
        "src/miniquake/types.ml",
    ],
    "sv_move": ["src/miniquake/server_move.ml"],
    "sv_phys": [
        "src/miniquake/physics.ml",
        "src/miniquake/server.ml",
        "src/miniquake/server_collision.ml",
    ],
    "sv_user": [
        "src/miniquake/sv_user.ml",
        "src/miniquake/player_move.ml",
        "src/miniquake/physics.ml",
        "src/miniquake/server.ml",
    ],
    "sys_win": [
        "src/miniquake/sys_win.ml",
        "src/miniquake/host.ml",
        "src/miniquake/platform/win32.ml",
        "src/miniquake/native.ml",
    ],
    "view": ["src/miniquake/view.ml"],
    "wad": ["src/miniquake/wad.ml"],
    "world": [
        "src/miniquake/world.ml",
        "src/miniquake/server_collision.ml",
        "src/miniquake/world_bsp.ml",
        "src/miniquake/world_hull.ml",
    ],
    "zone": [
        "src/miniquake/memory.ml",
        "src/miniquake/zone.ml",
        "src/miniquake/sizebuf.ml",
    ],
}

# Files whose logical implementation unit is not their literal stem.
FILE_UNIT = {
    "anorm_dots.h": "alias_tables",
    "anorms.h": "alias_tables",
    "bspfile.h": "bsp_format",
    "cd_win.c": "cd_audio",
    "cdaudio.h": "cd_audio",
    "client.h": "cl_main",
    "d_iface.h": "software_renderer_headers",
    "dosisms.h": "software_renderer_headers",
    "draw.h": "gl_draw",
    "gl_model.c": "gl_model",
    "gl_model.h": "gl_model",
    "model.h": "gl_model",
    "gl_warp_sin.h": "gl_warp",
    "glquake.h": "gl_rmain",
    "input.h": "in_win",
    "math.s": "mathlib",
    "modelgen.h": "model_format",
    "net.h": "net_main",
    "net_ser.h": "serial_network",
    "pr_comp.h": "quakec_abi",
    "progdefs.h": "quakec_abi",
    "progs.h": "quakec_abi",
    "quakedef.h": "quakedef",
    "r_local.h": "software_renderer_headers",
    "r_shared.h": "software_renderer_headers",
    "render.h": "render_types",
    "resource.h": "resource",
    "screen.h": "gl_screen",
    "server.h": "sv_main",
    "sound.h": "snd_dma",
    "snd_mixa.s": "snd_mix",
    "spritegn.h": "sprite_format",
    "sys.h": "sys_win",
    "sys_wina.s": "sys_win",
    "vid.h": "gl_vidnt",
    "winquake.h": "sys_win",
    "worlda.s": "world",
}

EXCLUDED_UNITS = {
    "net_vcr": "VCR-Netzwerkaufnahme/-wiedergabe ist laut Zieldefinition ausgeschlossen.",
    "net_wipx": "IPX ist laut Zieldefinition ausgeschlossen.",
    "serial_network": "Serial-/Modem-Netzwerk ist laut Zieldefinition ausgeschlossen.",
    "software_renderer_headers": (
        "Nur Software-Renderer-/Assembler-Schnittstellen; Ziel ist GLQuake, "
        "nicht WinQuake-Software-Rendering."
    ),
}

NATIVE_BRIDGE_UNITS = {
    "gl_vidnt",
    "in_win",
    "net_wins",
    "snd_win",
    "sys_win",
}

# Physical CD drive control is deliberately replaced by OGG streaming.  The
# transport-independent commands remain target behavior, while MCI operations
# are explicitly excluded modern deviations.
EXCLUDED_SYMBOLS = {
    ("protocol", "TE_IMPLOSION"): "nur im nicht definierten QUAKE2-Block",
    ("protocol", "TE_RAILTRAIL"): "nur im nicht definierten QUAKE2-Block",
    ("cd_audio", "CDAudio_Eject"): "physisches CD-Laufwerk ausgeschlossen",
    ("cd_audio", "CDAudio_CloseDoor"): "physisches CD-Laufwerk ausgeschlossen",
    ("cd_audio", "CDAudio_GetAudioDiskInfo"): "physisches CD-Laufwerk ausgeschlossen",
    ("cd_audio", "CDAudio_MessageHandler"): "Windows-MCI/CD-Laufwerk ausgeschlossen",
    ("menu", "M_Menu_SerialConfig_f"): "Serial-/Modem-Netzwerk ausgeschlossen",
    ("menu", "M_SerialConfig_Draw"): "Serial-/Modem-Netzwerk ausgeschlossen",
    ("menu", "M_SerialConfig_Key"): "Serial-/Modem-Netzwerk ausgeschlossen",
    ("menu", "M_Menu_ModemConfig_f"): "Serial-/Modem-Netzwerk ausgeschlossen",
    ("menu", "M_ModemConfig_Draw"): "Serial-/Modem-Netzwerk ausgeschlossen",
    ("menu", "M_ModemConfig_Key"): "Serial-/Modem-Netzwerk ausgeschlossen",
    ("menu", "MNET_IPX"): "IPX ist laut Zieldefinition ausgeschlossen",
}

# These definitions are physically present in a selected source file but are
# removed by the exact GL Release preprocessor configuration.  Line-qualified
# entries are necessary where a target and non-target branch reuse a function
# name (notably R_DrawSkyChain).
EXCLUDED_FUNCTION_LINES = {
    ("gl_rsurf", "R_DrawSequentialPoly", 313): "durch #if 0 aus dem GL-Release entfernt",
    ("gl_rsurf", "R_DrawWaterSurfaces", 905): "durch #if 0 aus dem GL-Release entfernt",
    ("gl_test", "Test_Init", 41): "nur im nicht definierten GLTEST-Diagnoseblock",
    ("gl_test", "HitPlane", 48): "nur im nicht definierten GLTEST-Diagnoseblock",
    ("gl_test", "Test_Spawn", 64): "nur im nicht definierten GLTEST-Diagnoseblock",
    ("gl_test", "DrawPuff", 101): "nur im nicht definierten GLTEST-Diagnoseblock",
    ("gl_test", "Test_Draw", 170): "nur im nicht definierten GLTEST-Diagnoseblock",
    ("gl_vidnt", "CheckMultiTextureExtensions", 588): "nur im nicht kompilierten !_WIN32-Zweig",
    ("gl_warp", "LoadPCX", 376): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "fgetLittleShort", 460): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "fgetLittleLong", 470): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "LoadTGA", 488): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "R_LoadSkys", 642): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "DrawSkyPolygon", 717): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "ClipSkyPolygon", 799): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "R_DrawSkyChain", 895): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "R_ClearSkyBox", 927): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "MakeSkyVec", 939): "nur im nicht definierten QUAKE2-Block",
    ("gl_warp", "R_DrawSkyBox", 982): "nur im nicht definierten QUAKE2-Block",
    ("host", "_Host_ServerFrame", 554): "nur im nicht definierten FPS_20-Block",
    ("host", "Host_ServerFrame", 568): "nur im nicht definierten FPS_20-Block",
    ("host_cmd", "SaveGamestate", 710): "nur im nicht definierten QUAKE2-Block",
    ("host_cmd", "LoadGamestate", 761): "nur im nicht definierten QUAKE2-Block",
    ("host_cmd", "Host_Changelevel2_f", 865): "nur im nicht definierten QUAKE2-Block",
    ("host_cmd", "Host_Please_f", 956): "nur im nicht definierten IDGODS-Block",
    ("net_dgrm", "StrAddr", 88): "nur im nicht definierten DEBUG-Block",
    ("net_main", "IsID", 985): "nur im nicht definierten IDGODS-Block",
    ("r_part", "R_DarkFieldParticles", 68): "nur im nicht definierten QUAKE2-Block",
    ("view", "V_UpdatePalette", 614): "nur im nicht kompilierten !GLQUAKE-Zweig",
    ("sv_phys", "SV_PushRotate", 566): "nur im nicht definierten QUAKE2-Block",
    ("sv_phys", "SV_Physics_Follow", 1156): "nur im nicht definierten QUAKE2-Block",
    ("sv_phys", "SV_Physics_Step", 1363): "nur im nicht definierten QUAKE2-Zweig",
    ("sv_phys", "SV_Trace_Toss", 1568): "nur im nicht definierten QUAKE2-Block",
    ("sv_user", "SV_Accelerate", 170): "durch #if 0 aus dem GL-Release entfernt",
    ("pr_cmds", "PF_TraceToss", 641): "nur im nicht definierten QUAKE2-Zweig",
    ("pr_cmds", "PF_etos", 951): "nur im nicht definierten QUAKE2-Zweig",
    ("pr_cmds", "PF_changepitch", 1455): "nur im nicht definierten QUAKE2-Zweig",
    ("pr_cmds", "PF_WaterMove", 1683): "nur im nicht definierten QUAKE2-Zweig",
    ("pr_cmds", "PF_sin", 1808): "nur im nicht definierten QUAKE2-Zweig",
    ("pr_cmds", "PF_cos", 1813): "nur im nicht definierten QUAKE2-Zweig",
    ("pr_cmds", "PF_sqrt", 1818): "nur im nicht definierten QUAKE2-Zweig",
}

# The x86 GL Release links these contracts from the selected assembler files.
# Their guarded C bodies are retained as the portable semantic counterparts
# used by the Windows-x64 MiniLang port, but they are not claimed to be active
# C bodies in the historical executable.
PORTABLE_FALLBACK_FUNCTION_LINES = {
    ("mathlib", "BoxOnPlaneSide", 189): "math.s:x86 export",
    ("mathlib", "Invert24To16", 576): "math.s:x86 export",
    ("snd_mix", "Snd_WriteLinearBlastStereo16", 39): "snd_mixa.s:x86 export",
    ("snd_mix", "SND_PaintChannelFrom8", 346): "snd_mixa.s:x86 export",
    ("sys_win", "Sys_SetFPCW", 275): "sys_wina.s:x86 export",
    ("sys_win", "Sys_PushFPCW_SetHigh", 279): "sys_wina.s:x86 export",
    ("sys_win", "Sys_PopFPCW", 283): "sys_wina.s:x86 export",
    ("sys_win", "MaskExceptions", 287): "sys_wina.s:x86 export",
    ("world", "SV_HullPointContents", 491): "worlda.s:x86 export",
}

MANUAL_MAPPINGS: dict[tuple[str, str], list[tuple[str, str]]] = {
    ("cmd", "Cmd_Wait_f"): [
        ("src/miniquake/host.ml", "executeCommand"),
    ],
    ("cmd", "Cbuf_Init"): [
        ("src/miniquake/cmd.ml", "create"),
    ],
    ("cmd", "Cbuf_AddText"): [
        ("src/miniquake/cmd.ml", "addText"),
    ],
    ("cmd", "Cbuf_InsertText"): [
        ("src/miniquake/cmd.ml", "insertText"),
    ],
    ("cmd", "Cbuf_Execute"): [
        ("src/miniquake/cmd.ml", "executeBuffer"),
    ],
    ("cmd", "Cmd_StuffCmds_f"): [
        ("src/miniquake/common.ml", "stuffCommands"),
        ("src/miniquake/host.ml", "queueStartupCommands"),
    ],
    ("cmd", "Cmd_Exec_f"): [
        ("src/miniquake/host.ml", "executeCommand"),
    ],
    ("cmd", "Cmd_Echo_f"): [
        ("src/miniquake/host.ml", "executeCommand"),
    ],
    ("cmd", "CopyString"): [
        ("src/miniquake/cmd.ml", "terminatedAliasValue"),
    ],
    ("cmd", "Cmd_Alias_f"): [
        ("src/miniquake/cmd.ml", "addAlias"),
        ("src/miniquake/host.ml", "executeCommand"),
    ],
    ("cmd", "Cmd_Init"): [
        ("src/miniquake/cmd.ml", "create"),
        ("src/miniquake/host.ml", "create"),
    ],
    ("cmd", "Cmd_Argc"): [
        ("src/miniquake/cmd.ml", "argc"),
    ],
    ("cmd", "Cmd_Argv"): [
        ("src/miniquake/cmd.ml", "argv"),
    ],
    ("cmd", "Cmd_Args"): [
        ("src/miniquake/cmd.ml", "argsFrom"),
    ],
    ("cmd", "Cmd_TokenizeString"): [
        ("src/miniquake/cmd.ml", "tokenize"),
    ],
    ("cmd", "Cmd_AddCommand"): [
        ("src/miniquake/cmd.ml", "addCommand"),
    ],
    ("cmd", "Cmd_Exists"): [
        ("src/miniquake/cmd.ml", "commandExists"),
    ],
    ("cmd", "Cmd_CompleteCommand"): [
        ("src/miniquake/cmd.ml", "completeCommand"),
    ],
    ("cmd", "Cmd_ExecuteString"): [
        ("src/miniquake/cmd.ml", "executeString"),
        ("src/miniquake/host.ml", "executeCommand"),
    ],
    ("cmd", "Cmd_ForwardToServer"): [
        ("src/miniquake/client.ml", "queueString"),
    ],
    ("cmd", "Cmd_CheckParm"): [
        ("src/miniquake/cmd.ml", "checkParm"),
    ],
    ("common", "Q_memset"): [
        ("src/miniquake/common.ml", "memSet"),
    ],
    ("common", "Q_memcpy"): [
        ("src/miniquake/common.ml", "memCopy"),
    ],
    ("common", "Q_memcmp"): [
        ("src/miniquake/common.ml", "memCompare"),
    ],
    ("common", "Q_strcpy"): [
        ("src/miniquake/common.ml", "stringCopy"),
    ],
    ("common", "Q_strncpy"): [
        ("src/miniquake/common.ml", "stringCopyCount"),
    ],
    ("common", "Q_strlen"): [
        ("src/miniquake/common.ml", "stringLength"),
    ],
    ("common", "Q_strrchr"): [
        ("src/miniquake/common.ml", "stringLastIndex"),
    ],
    ("common", "Q_strcat"): [
        ("src/miniquake/common.ml", "stringConcat"),
    ],
    ("common", "Q_strcmp"): [
        ("src/miniquake/common.ml", "stringCompare"),
    ],
    ("common", "Q_strncmp"): [
        ("src/miniquake/common.ml", "stringCompareCount"),
    ],
    ("common", "Q_strncasecmp"): [
        ("src/miniquake/common.ml", "stringCompareInsensitiveCount"),
    ],
    ("common", "Q_strcasecmp"): [
        ("src/miniquake/common.ml", "stringCompareInsensitive"),
    ],
    ("common", "Q_atoi"): [
        ("src/miniquake/common.ml", "atoi"),
    ],
    ("common", "Q_atof"): [
        ("src/miniquake/common.ml", "atof"),
    ],
    ("common", "MSG_WriteChar"): [
        ("src/miniquake/message.ml", "writeChar"),
    ],
    ("common", "MSG_WriteByte"): [
        ("src/miniquake/message.ml", "writeByte"),
    ],
    ("common", "MSG_WriteShort"): [
        ("src/miniquake/message.ml", "writeShort"),
    ],
    ("common", "MSG_WriteLong"): [
        ("src/miniquake/message.ml", "writeLong"),
    ],
    ("common", "MSG_WriteFloat"): [
        ("src/miniquake/message.ml", "writeFloat"),
    ],
    ("common", "MSG_WriteString"): [
        ("src/miniquake/message.ml", "writeString"),
    ],
    ("common", "MSG_WriteCoord"): [
        ("src/miniquake/message.ml", "writeCoord"),
    ],
    ("common", "MSG_WriteAngle"): [
        ("src/miniquake/message.ml", "writeAngle"),
    ],
    ("common", "MSG_BeginReading"): [
        ("src/miniquake/message.ml", "beginReading"),
    ],
    ("common", "MSG_ReadChar"): [
        ("src/miniquake/message.ml", "readChar"),
    ],
    ("common", "MSG_ReadByte"): [
        ("src/miniquake/message.ml", "readByte"),
    ],
    ("common", "MSG_ReadShort"): [
        ("src/miniquake/message.ml", "readShort"),
    ],
    ("common", "MSG_ReadLong"): [
        ("src/miniquake/message.ml", "readLong"),
    ],
    ("common", "MSG_ReadFloat"): [
        ("src/miniquake/message.ml", "readFloat"),
    ],
    ("common", "MSG_ReadString"): [
        ("src/miniquake/message.ml", "readString"),
    ],
    ("common", "MSG_ReadCoord"): [
        ("src/miniquake/message.ml", "readCoord"),
    ],
    ("common", "MSG_ReadAngle"): [
        ("src/miniquake/message.ml", "readAngle"),
    ],
    ("common", "SZ_Alloc"): [
        ("src/miniquake/sizebuf.ml", "alloc"),
    ],
    ("common", "SZ_Free"): [
        ("src/miniquake/sizebuf.ml", "free"),
    ],
    ("common", "SZ_Clear"): [
        ("src/miniquake/sizebuf.ml", "clear"),
    ],
    ("common", "SZ_GetSpace"): [
        ("src/miniquake/sizebuf.ml", "getSpace"),
    ],
    ("common", "SZ_Write"): [
        ("src/miniquake/sizebuf.ml", "write"),
    ],
    ("common", "SZ_Print"): [
        ("src/miniquake/sizebuf.ml", "printText"),
    ],
    ("common", "COM_SkipPath"): [
        ("src/miniquake/common.ml", "skipPath"),
    ],
    ("common", "COM_StripExtension"): [
        ("src/miniquake/common.ml", "stripExtension"),
    ],
    ("common", "COM_FileExtension"): [
        ("src/miniquake/common.ml", "fileExtension"),
    ],
    ("common", "COM_FileBase"): [
        ("src/miniquake/common.ml", "fileBase"),
    ],
    ("common", "COM_DefaultExtension"): [
        ("src/miniquake/common.ml", "defaultExtension"),
    ],
    ("common", "COM_Parse"): [
        ("src/miniquake/common.ml", "parseToken"),
    ],
    ("common", "COM_CheckParm"): [
        ("src/miniquake/common.ml", "checkParm"),
    ],
    ("common", "COM_CheckRegistered"): [
        ("src/miniquake/filesystem.ml", "checkRegistered"),
    ],
    ("common", "COM_InitArgv"): [
        ("src/miniquake/common.ml", "create"),
    ],
    ("common", "COM_Init"): [
        ("src/miniquake/common.ml", "create"),
        ("src/miniquake/filesystem.ml", "initFilesystem"),
    ],
    ("common", "memsearch"): [
        ("src/miniquake/common.ml", "memorySearch"),
    ],
    ("common", "COM_Path_f"): [
        ("src/miniquake/filesystem.ml", "pathCommandText"),
    ],
    ("common", "COM_WriteFile"): [
        ("src/miniquake/filesystem.ml", "writeFile"),
    ],
    ("common", "COM_CreatePath"): [
        ("src/miniquake/filesystem.ml", "createPath"),
    ],
    ("common", "COM_CopyFile"): [
        ("src/miniquake/filesystem.ml", "copyFile"),
    ],
    ("common", "COM_FindFile"): [
        ("src/miniquake/filesystem.ml", "findFile"),
    ],
    ("common", "COM_OpenFile"): [
        ("src/miniquake/filesystem.ml", "openFile"),
    ],
    ("common", "COM_FOpenFile"): [
        ("src/miniquake/filesystem.ml", "fOpenFile"),
    ],
    ("common", "COM_CloseFile"): [
        ("src/miniquake/filesystem.ml", "closeFile"),
    ],
    ("common", "COM_LoadFile"): [
        ("src/miniquake/filesystem.ml", "loadFile"),
    ],
    ("common", "COM_LoadHunkFile"): [
        ("src/miniquake/filesystem.ml", "loadHunkFile"),
        ("src/miniquake/filesystem.ml", "loadHunkAllocation"),
    ],
    ("common", "COM_LoadTempFile"): [
        ("src/miniquake/filesystem.ml", "loadTempFile"),
        ("src/miniquake/filesystem.ml", "loadTempAllocation"),
    ],
    ("common", "COM_LoadCacheFile"): [
        ("src/miniquake/filesystem.ml", "loadCacheFile"),
        ("src/miniquake/filesystem.ml", "loadCacheAllocation"),
    ],
    ("common", "COM_LoadStackFile"): [
        ("src/miniquake/filesystem.ml", "loadStackFile"),
        ("src/miniquake/filesystem.ml", "loadStackAllocation"),
    ],
    ("common", "COM_LoadPackFile"): [
        ("src/miniquake/pak.ml", "load"),
    ],
    ("common", "COM_AddGameDirectory"): [
        ("src/miniquake/filesystem.ml", "addGameDirectory"),
    ],
    ("common", "COM_InitFilesystem"): [
        ("src/miniquake/filesystem.ml", "initFilesystem"),
    ],
    ("cvar", "Cvar_FindVar"): [
        ("src/miniquake/cvar.ml", "find"),
    ],
    ("cvar", "Cvar_VariableValue"): [
        ("src/miniquake/cvar.ml", "variableValue"),
    ],
    ("cvar", "Cvar_VariableString"): [
        ("src/miniquake/cvar.ml", "variableString"),
    ],
    ("cvar", "Cvar_CompleteVariable"): [
        ("src/miniquake/cvar.ml", "completeVariable"),
    ],
    ("cvar", "Cvar_Set"): [
        ("src/miniquake/cvar.ml", "set"),
    ],
    ("cvar", "Cvar_SetValue"): [
        ("src/miniquake/cvar.ml", "setValue"),
    ],
    ("cvar", "Cvar_RegisterVariable"): [
        ("src/miniquake/cvar.ml", "register"),
    ],
    ("cvar", "Cvar_Command"): [
        ("src/miniquake/host.ml", "cvarCommand"),
    ],
    ("cvar", "Cvar_WriteVariables"): [
        ("src/miniquake/cvar.ml", "archiveText"),
    ],
    ("cd_audio", "CDAudio_Play"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Play"),
    ],
    ("cd_audio", "CDAudio_Stop"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Stop"),
    ],
    ("cd_audio", "CDAudio_Pause"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Pause"),
    ],
    ("cd_audio", "CDAudio_Resume"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Resume"),
    ],
    ("cd_audio", "CD_f"): [
        ("src/miniquake/sound/cd_audio.ml", "CD_f"),
    ],
    ("cd_audio", "CDAudio_Update"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Update"),
    ],
    ("cd_audio", "CDAudio_Init"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Init"),
    ],
    ("cd_audio", "CDAudio_Shutdown"): [
        ("src/miniquake/sound/cd_audio.ml", "CDAudio_Shutdown"),
    ],
}

PREFIXES = (
    "cache",
    "cbuf",
    "cdaudio",
    "chase",
    "com",
    "crc",
    "datagram",
    "draw",
    "hunk",
    "host",
    "key",
    "loop",
    "msg",
    "mod",
    "net",
    "pf",
    "pr",
    "r",
    "scr",
    "sbar",
    "snd",
    "sv",
    "sys",
    "vid",
    "vcr",
    "wins",
    "wipx",
    "cl",
    "cmd",
    "con",
    "cvar",
    "ed",
    "gl",
    "in",
    "m",
    "q",
    "s",
    "sz",
    "v",
    "wad",
    "w",
    "z",
)


def fail(message: str) -> "NoReturn":
    raise SystemExit(f"port inventory generation failed: {message}")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def normalize(name: str) -> str:
    return re.sub(r"[^a-z0-9]", "", name.casefold())


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def mask_comments_and_literals(text: str) -> str:
    """Replace comments/string contents while preserving offsets and lines."""
    result = list(text)
    pattern = re.compile(
        r"//[^\n]*|/\*.*?\*/|\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*'",
        re.DOTALL,
    )
    for match in pattern.finditer(text):
        for index in range(match.start(), match.end()):
            if result[index] not in "\r\n":
                result[index] = " "
    return "".join(result)


def selected_project_sources(suffixes: set[str]) -> list[Path]:
    if not PROJECT.is_file():
        fail(f"missing project file {PROJECT}")
    project_text = PROJECT.read_text(encoding="latin-1")
    selected: list[Path] = []
    for match in SOURCE_BLOCK.finditer(project_text):
        body = match.group("body")
        source_match = SOURCE_PATH.search(body)
        if source_match is None:
            continue
        relative = source_match.group("path").replace("\\", "/")
        if Path(relative).suffix.casefold() not in suffixes:
            continue
        configuration_marker = (
            f'!ELSEIF  "$(CFG)" == "{CONFIGURATION}"'
        )
        if configuration_marker in body:
            configuration_body = body.split(configuration_marker, 1)[1]
            configuration_body = configuration_body.split("!ENDIF", 1)[0]
            if "# PROP Exclude_From_Build 1" in configuration_body:
                continue
        path = REFERENCE / relative
        if not path.is_file():
            fail(f"project-selected source is absent: {relative}")
        selected.append(path)
    if not selected:
        fail(
            f"no {sorted(suffixes)} sources selected for {CONFIGURATION}"
        )
    return sorted(set(selected), key=lambda path: path.name.casefold())


def selected_c_sources() -> list[Path]:
    return selected_project_sources({".c"})


def selected_assembly_sources() -> list[Path]:
    return selected_project_sources({".s"})


def transitive_headers(sources: Iterable[Path]) -> list[Path]:
    queue = list(sources)
    seen: set[Path] = set()
    headers: set[Path] = set()
    by_name = {
        path.name.casefold(): path
        for path in REFERENCE.iterdir()
        if path.is_file() and path.suffix.casefold() == ".h"
    }
    while queue:
        path = queue.pop()
        resolved = path.resolve()
        if resolved in seen:
            continue
        seen.add(resolved)
        text = path.read_text(encoding="latin-1")
        for include in INCLUDE.findall(text):
            included = by_name.get(Path(include).name.casefold())
            if included is not None and included not in headers:
                headers.add(included)
                queue.append(included)
    return sorted(headers, key=lambda path: path.name.casefold())


def parse_c_functions(path: Path) -> list[dict[str, Any]]:
    text = path.read_text(encoding="latin-1")
    masked = mask_comments_and_literals(text)
    # Quake uses conventional ANSI definitions.  The return/declaration prefix
    # is deliberately constrained so calls and control statements do not match.
    pattern = re.compile(
        r"(?m)^[ \t]*"
        r"(?P<prefix>(?:(?:static|extern|inline|__inline)\s+)*"
        r"(?:[A-Za-z_][A-Za-z0-9_]*\s+|[A-Za-z_][A-Za-z0-9_]*\s*\*+\s*)+)"
        r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*"
        r"\((?P<parameters>[^;{}]*)\)\s*\{"
    )
    functions: list[dict[str, Any]] = []
    for match in pattern.finditer(masked):
        prefix = " ".join(match.group("prefix").split())
        name = match.group("name")
        if name in {"if", "for", "while", "switch"}:
            continue
        functions.append(
            {
                "kind": "function-definition",
                "name": name,
                "line": line_number(text, match.start("name")),
                "static": bool(re.search(r"\bstatic\b", prefix)),
            }
        )
    return functions


def parse_assembly_exports(path: Path) -> list[dict[str, Any]]:
    text = path.read_text(encoding="latin-1")
    exports: list[dict[str, Any]] = []
    pattern = re.compile(
        r"(?m)^[ \t]*\.globl[ \t]+C\((?P<name>[A-Za-z_][A-Za-z0-9_]*)\)"
    )
    for match in pattern.finditer(text):
        exports.append(
            {
                "kind": "assembly-export",
                "name": match.group("name"),
                "line": line_number(text, match.start("name")),
            }
        )
    return exports


def parse_header_symbols(path: Path) -> list[dict[str, Any]]:
    text = path.read_text(encoding="latin-1")
    masked = mask_comments_and_literals(text)
    symbols: list[dict[str, Any]] = []

    prototype = re.compile(
        r"(?m)^[ \t]*(?:extern\s+)?"
        r"(?:(?:const|unsigned|signed|struct|enum|volatile|far|near|FAR|PASCAL)\s+)*"
        r"(?:[A-Za-z_][A-Za-z0-9_]*\s+|[A-Za-z_][A-Za-z0-9_]*\s*\*+\s*)+"
        r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*"
        r"\((?P<parameters>[^;{}]*)\)\s*;"
    )
    prototype_ranges: list[tuple[int, int]] = []
    for match in prototype.finditer(masked):
        declaration_prefix = masked[match.start():match.start("name")]
        # A function-pointer typedef such as
        # `typedef void (*xcommand_t) (void);` otherwise looks like a
        # prototype for a function named `void`.
        if re.search(r"\btypedef\b", declaration_prefix):
            continue
        prototype_ranges.append(match.span())
        symbols.append(
            {
                "kind": "function-declaration",
                "name": match.group("name"),
                "line": line_number(text, match.start("name")),
            }
        )

    for match in re.finditer(
        r"(?ms)^[ \t]*extern\s+(?P<body>[^;{}]+);", masked
    ):
        if any(start <= match.start() < end for start, end in prototype_ranges):
            continue
        body = match.group("body")
        if "(" in body:
            continue
        identifiers = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", body)
        if identifiers:
            symbols.append(
                {
                    "kind": "extern",
                    "name": identifiers[-1],
                    "line": line_number(text, match.start("body")),
                }
            )

    # Typedefs frequently contain structs whose fields end in semicolons.
    # A non-greedy regex therefore reported field names as public types.  Scan
    # until a semicolon at balanced brace/paren/bracket depth instead.
    typedef_start = re.compile(r"(?m)^[ \t]*typedef\b")
    for match in typedef_start.finditer(masked):
        brace_depth = 0
        paren_depth = 0
        bracket_depth = 0
        end = None
        for index in range(match.end(), len(masked)):
            char = masked[index]
            if char == "{":
                brace_depth += 1
            elif char == "}":
                brace_depth = max(0, brace_depth - 1)
            elif char == "(":
                paren_depth += 1
            elif char == ")":
                paren_depth = max(0, paren_depth - 1)
            elif char == "[":
                bracket_depth += 1
            elif char == "]":
                bracket_depth = max(0, bracket_depth - 1)
            elif (
                char == ";"
                and brace_depth == 0
                and paren_depth == 0
                and bracket_depth == 0
            ):
                end = index
                break
        if end is None:
            continue
        body = masked[match.end():end]
        if "}" in body:
            tail = body.rsplit("}", 1)[1]
            identifiers = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", tail)
            if not identifiers:
                continue
            name = identifiers[-1]
        else:
            pointer_name = re.search(
                r"\(\s*(?:[A-Za-z_][A-Za-z0-9_]*\s+)*\*\s*"
                r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*\)",
                body,
            )
            if pointer_name is not None:
                name = pointer_name.group("name")
                symbols.append(
                    {
                        "kind": "type",
                        "name": name,
                        "line": line_number(text, match.start()),
                    }
                )
                continue
            # Function-type aliases place the alias immediately before the
            # first parameter list.  Plain and array aliases use the final
            # identifier in the declaration.
            function_alias = re.search(
                r"(?P<name>[A-Za-z_][A-Za-z0-9_]*)\s*\(", body
            )
            if function_alias is not None:
                name = function_alias.group("name")
            else:
                identifiers = re.findall(r"[A-Za-z_][A-Za-z0-9_]*", body)
                if not identifiers:
                    continue
                name = identifiers[-1]
        symbols.append(
            {
                "kind": "type",
                "name": name,
                "line": line_number(text, match.start()),
            }
        )

    guard_names = {
        normalize(path.stem) + "h",
        "_" + normalize(path.stem) + "h",
    }
    for match in re.finditer(
        r"(?m)^[ \t]*#[ \t]*define[ \t]+(?P<name>[A-Za-z_][A-Za-z0-9_]*)",
        masked,
    ):
        name = match.group("name")
        if normalize(name) in guard_names or name.startswith("__"):
            continue
        symbols.append(
            {
                "kind": "macro",
                "name": name,
                "line": line_number(text, match.start("name")),
            }
        )

    unique: dict[tuple[str, str], dict[str, Any]] = {}
    for symbol in symbols:
        unique.setdefault((symbol["kind"], symbol["name"]), symbol)
    return sorted(unique.values(), key=lambda item: (item["line"], item["kind"], item["name"]))


def parse_minilang() -> tuple[
    dict[str, list[dict[str, Any]]],
    dict[str, list[dict[str, Any]]],
]:
    by_path: dict[str, list[dict[str, Any]]] = {}
    by_normalized: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for path in sorted((ROOT / "src").rglob("*.ml")):
        relative = path.relative_to(ROOT).as_posix()
        text = path.read_text(encoding="utf-8")
        declarations: list[dict[str, Any]] = []
        for match in ML_DECLARATION.finditer(text):
            declaration = {
                "path": relative,
                "kind": match.group("kind"),
                "name": match.group("name"),
                "line": line_number(text, match.start("name")),
            }
            declarations.append(declaration)
            by_normalized[normalize(declaration["name"])].append(declaration)
        by_path[relative] = declarations
    return by_path, by_normalized


def stripped_names(name: str) -> list[str]:
    folded = normalize(name)
    candidates: list[str] = []
    for prefix in PREFIXES:
        if folded.startswith(prefix) and len(folded) > len(prefix) + 2:
            candidates.append(folded[len(prefix):])
    return candidates


def resolve_manual(
    unit: str,
    name: str,
    declarations_by_path: dict[str, list[dict[str, Any]]],
) -> list[dict[str, Any]]:
    resolved: list[dict[str, Any]] = []
    for path, target_name in MANUAL_MAPPINGS.get((unit, name), []):
        matches = [
            item
            for item in declarations_by_path.get(path, [])
            if item["name"] == target_name
        ]
        if len(matches) != 1:
            fail(f"manual mapping {unit}:{name} -> {path}:{target_name} is stale")
        resolved.extend(matches)
    return resolved


def map_symbol(
    unit: str,
    symbol: dict[str, Any],
    modules: list[str],
    declarations_by_path: dict[str, list[dict[str, Any]]],
    declarations_by_name: dict[str, list[dict[str, Any]]],
    target_c_function_names: set[str],
) -> dict[str, Any]:
    name = symbol["name"]
    line_excluded_reason = EXCLUDED_FUNCTION_LINES.get(
        (unit, name, symbol.get("line"))
    )
    if line_excluded_reason is not None:
        return {
            **symbol,
            "scope": "excluded-build-configuration",
            "mapping_status": "excluded",
            "evidence_kind": "scope-policy",
            "evidence": [],
            "note": line_excluded_reason,
        }
    excluded_reason = EXCLUDED_SYMBOLS.get((unit, name))
    if excluded_reason is not None:
        return {
            **symbol,
            "scope": "excluded-modern-deviation",
            "mapping_status": "excluded",
            "evidence_kind": "scope-policy",
            "evidence": [],
            "note": excluded_reason,
        }
    if unit in EXCLUDED_UNITS:
        return {
            **symbol,
            "scope": "excluded",
            "mapping_status": "excluded",
            "evidence_kind": "scope-policy",
            "evidence": [],
            "note": EXCLUDED_UNITS[unit],
        }
    if (
        symbol["kind"] == "function-declaration"
        and name not in target_c_function_names
    ):
        return {
            **symbol,
            "scope": "excluded-unlinked-header-declaration",
            "mapping_status": "excluded",
            "evidence_kind": "gl-release-link-scope",
            "evidence": [],
            "note": (
                "Keine Definition dieses lokalen Prototyps wird von der "
                "gepinnten Win32-GL-Release-Konfiguration gebaut."
            ),
        }

    portable_fallback = PORTABLE_FALLBACK_FUNCTION_LINES.get(
        (unit, name, symbol.get("line"))
    )
    target_scope = (
        "target-portable-assembly-counterpart"
        if portable_fallback is not None
        else "target"
    )

    manual = resolve_manual(unit, name, declarations_by_path)
    if manual:
        return {
            **symbol,
            "scope": target_scope,
            "mapping_status": "located",
            "evidence_kind": "reviewed-rename",
            "evidence": manual,
            "note": "Codeort zugeordnet; keine Verhaltensparitätsbehauptung.",
        }

    normalized = normalize(name)
    in_modules = [
        declaration
        for module in modules
        for declaration in declarations_by_path.get(module, [])
        if normalize(declaration["name"]) == normalized
    ]
    # A same-named declaration elsewhere in the project is not evidence that
    # this original unit has a sensible pendant.  Only declarations in the
    # reviewed UNIT_MODULES list (or an explicit manual mapping above) count.
    exact = in_modules
    if exact:
        return {
            **symbol,
            "scope": target_scope,
            "mapping_status": "located",
            "evidence_kind": "normalized-name",
            "evidence": exact,
            "note": "Namensgleicher Codeort; Verhalten nicht automatisch bestätigt.",
        }

    candidate_names = set(stripped_names(name))
    candidates = [
        declaration
        for module in modules
        for declaration in declarations_by_path.get(module, [])
        if normalize(declaration["name"]) in candidate_names
    ]
    if candidates:
        return {
            **symbol,
            "scope": target_scope,
            "mapping_status": "candidate",
            "evidence_kind": "prefix-stripped-name",
            "evidence": candidates,
            "note": "Automatischer Umbenennungskandidat; Review erforderlich.",
        }
    return {
        **symbol,
        "scope": target_scope,
        "mapping_status": "unmapped",
        "evidence_kind": "none",
        "evidence": [],
        "note": "Kein belastbarer MiniLang-Codeort gefunden.",
    }


def unit_for(path: Path) -> str:
    return FILE_UNIT.get(path.name.casefold(), path.stem.casefold())


def build_report() -> dict[str, Any]:
    if not REFERENCE.is_dir():
        fail("reference/quake submodule is absent; run `git submodule update --init`")
    lock = json.loads(LOCK.read_text(encoding="utf-8"))
    sources = selected_c_sources()
    assembly_sources = selected_assembly_sources()
    headers = transitive_headers(sources)
    files = sources + assembly_sources + headers
    groups: dict[str, list[Path]] = defaultdict(list)
    for path in files:
        groups[unit_for(path)].append(path)

    unknown_units = sorted(set(groups) - set(UNIT_MODULES))
    if unknown_units:
        fail("units lack reviewed MiniLang mapping: " + ", ".join(unknown_units))
    for unit, modules in UNIT_MODULES.items():
        if unit not in groups:
            continue
        missing_modules = [module for module in modules if not (ROOT / module).is_file()]
        if missing_modules:
            fail(f"{unit} maps to missing modules: {', '.join(missing_modules)}")

    declarations_by_path, declarations_by_name = parse_minilang()
    target_c_function_names: set[str] = set()
    target_c_function_names_by_unit: dict[str, set[str]] = defaultdict(set)
    for source in sources:
        unit_name = unit_for(source)
        for symbol in parse_c_functions(source):
            if unit_name in EXCLUDED_UNITS:
                continue
            if (unit_name, symbol["name"]) in EXCLUDED_SYMBOLS:
                continue
            if (
                unit_name,
                symbol["name"],
                symbol.get("line"),
            ) in EXCLUDED_FUNCTION_LINES:
                continue
            target_c_function_names.add(symbol["name"])
            target_c_function_names_by_unit[unit_name].add(symbol["name"])
    units: list[dict[str, Any]] = []
    all_function_counts: Counter[str] = Counter()
    all_assembly_counts: Counter[str] = Counter()
    all_header_counts: Counter[str] = Counter()
    source_function_total = 0

    for unit_name in sorted(groups):
        modules = UNIT_MODULES[unit_name]
        original_files: list[dict[str, Any]] = []
        functions: list[dict[str, Any]] = []
        assembly_exports: list[dict[str, Any]] = []
        header_symbols: list[dict[str, Any]] = []
        for path in sorted(groups[unit_name], key=lambda item: item.name.casefold()):
            relative = path.relative_to(REFERENCE).as_posix()
            file_record = {
                "path": relative,
                "kind": path.suffix.casefold().lstrip("."),
                "sha256": sha256(path),
                "lines": len(path.read_text(encoding="latin-1").splitlines()),
            }
            original_files.append(file_record)
            if path.suffix.casefold() == ".c":
                parsed = parse_c_functions(path)
                source_function_total += len(parsed)
                for symbol in parsed:
                    functions.append(
                        {
                            "source": relative,
                            **map_symbol(
                                unit_name,
                                symbol,
                                modules,
                                declarations_by_path,
                                declarations_by_name,
                                target_c_function_names,
                            ),
                        }
                    )
            elif path.suffix.casefold() == ".s":
                for symbol in parse_assembly_exports(path):
                    if (
                        symbol["name"]
                        not in target_c_function_names_by_unit[unit_name]
                    ):
                        assembly_exports.append(
                            {
                                "source": relative,
                                **symbol,
                                "scope": "excluded-unreferenced-assembly-export",
                                "mapping_status": "excluded",
                                "evidence_kind": "gl-release-call-scope",
                                "evidence": [],
                                "note": (
                                    "Der Export ist im gelinkten Assemblerobjekt "
                                    "vorhanden, wird aber vom GL-Release-Pfad "
                                    "nicht aufgerufen."
                                ),
                            }
                        )
                        continue
                    mapped = map_symbol(
                        unit_name,
                        symbol,
                        modules,
                        declarations_by_path,
                        declarations_by_name,
                        target_c_function_names,
                    )
                    assembly_exports.append(
                        {
                            "source": relative,
                            **mapped,
                            "scope": "target-assembly-counterpart",
                            "note": (
                                "x86-Assemblerexport; derselbe logische "
                                "Funktionsvertrag ist über den portablen "
                                "C-/MiniLang-Codeort erfasst."
                            ),
                        }
                    )
            else:
                for symbol in parse_header_symbols(path):
                    header_symbols.append(
                        {
                            "source": relative,
                            **map_symbol(
                                unit_name,
                                symbol,
                                modules,
                                declarations_by_path,
                                declarations_by_name,
                                target_c_function_names,
                            ),
                        }
                    )

        function_counts = Counter(item["mapping_status"] for item in functions)
        assembly_counts = Counter(
            item["mapping_status"] for item in assembly_exports
        )
        header_counts = Counter(item["mapping_status"] for item in header_symbols)
        all_function_counts.update(function_counts)
        all_assembly_counts.update(assembly_counts)
        all_header_counts.update(header_counts)
        target_functions = [
            item for item in functions if item["scope"].startswith("target")
        ]
        target_unmapped = [
            item for item in target_functions if item["mapping_status"] == "unmapped"
        ]
        if unit_name in EXCLUDED_UNITS:
            accounting_status = "out-of-scope"
            note = EXCLUDED_UNITS[unit_name]
        elif unit_name == "cd_audio":
            accounting_status = (
                "modern-replacement-with-gaps" if target_unmapped else "modern-replacement-located"
            )
            note = (
                "Physische CD/MCI-Funktionen sind ausgeschlossen; CD-Kommandos und "
                "Tracknummern werden auf music/trackNN.ogg abgebildet."
            )
        elif unit_name in NATIVE_BRIDGE_UNITS:
            accounting_status = (
                "native-bridge-with-gaps" if target_unmapped else "native-bridge-located"
            )
            note = "Betriebssystem-/ABI-Anteil darf in der nativen Brücke liegen."
        elif not target_functions:
            accounting_status = "header-or-table-unit"
            note = "Keine C-Funktionsdefinition in dieser logischen Einheit."
        elif target_unmapped:
            accounting_status = (
                "partially-located"
                if len(target_unmapped) < len(target_functions)
                else "unmapped"
            )
            note = "Mindestens eine zielrelevante C-Funktion ohne MiniLang-Codeort."
        else:
            accounting_status = "all-function-code-locations-found"
            note = (
                "Alle Ziel-C-Funktionen haben Codeorte; die strikten "
                "Funktionsbelege werden im separaten Paritätsbericht geführt."
            )

        units.append(
            {
                "unit": unit_name,
                "scope": "excluded" if unit_name in EXCLUDED_UNITS else "target",
                "accounting_status": accounting_status,
                "evidence_scope": "code-location-only",
                "note": note,
                "original_files": original_files,
                "minilang_modules": [
                    {
                        "path": module,
                        "sha256": sha256(ROOT / module),
                    }
                    for module in modules
                ],
                "function_counts": {
                    status: function_counts.get(status, 0)
                    for status in ("located", "candidate", "unmapped", "excluded")
                },
                "header_symbol_counts": {
                    status: header_counts.get(status, 0)
                    for status in ("located", "candidate", "unmapped", "excluded")
                },
                "assembly_export_counts": {
                    status: assembly_counts.get(status, 0)
                    for status in ("located", "candidate", "unmapped", "excluded")
                },
                "functions": functions,
                "assembly_exports": assembly_exports,
                "public_header_symbols": header_symbols,
            }
        )

    selected_paths = {path.relative_to(REFERENCE).as_posix() for path in files}
    emitted_paths = {
        item["path"]
        for unit in units
        for item in unit["original_files"]
    }
    if selected_paths != emitted_paths:
        fail(
            "internal file accounting mismatch; missing="
            + repr(sorted(selected_paths - emitted_paths))
            + " extra="
            + repr(sorted(emitted_paths - selected_paths))
        )

    target_units = [unit for unit in units if unit["scope"] == "target"]
    target_functions = [
        function
        for unit in target_units
        for function in unit["functions"]
        if function["scope"].startswith("target")
    ]
    target_assembly_exports = [
        export
        for unit in target_units
        for export in unit["assembly_exports"]
        if export["scope"].startswith("target")
    ]

    return {
        "schema": 2,
        "description": (
            "Code-location inventory only. located/candidate never means "
            "behavioral parity; strict function-level proof is maintained in "
            "audit/BEHAVIORAL_PARITY.json."
        ),
        "source": {
            "repository": lock["repository"],
            "commit": lock["commit"],
            "tree": lock["tree"],
            "project": "WinQuake/WinQuake.dsp",
            "configuration": CONFIGURATION,
        },
        "scope_policy": {
            "target": "GLQuake 1.09, Windows x64, protocol 15",
            "excluded": [
                "WinQuake software renderer and its assembler interfaces",
                "IPX",
                "serial/modem networking",
                "VCR networking",
                "physical CD drive/MCI control (replaced by OGG streaming)",
            ],
        },
        "summary": {
            "selected_c_files": len(sources),
            "selected_assembly_files": len(assembly_sources),
            "transitive_header_files": len(headers),
            "logical_units": len(units),
            "target_units": len(target_units),
            "target_units_with_minilang_counterpart": sum(
                1 for unit in target_units if unit["minilang_modules"]
            ),
            "excluded_units": sum(1 for unit in units if unit["scope"] == "excluded"),
            "c_function_definitions": source_function_total,
            "target_c_function_definitions": len(target_functions),
            "target_c_function_definitions_located": sum(
                1
                for function in target_functions
                if function["mapping_status"] == "located"
            ),
            "function_mapping_counts": {
                status: all_function_counts.get(status, 0)
                for status in ("located", "candidate", "unmapped", "excluded")
            },
            "assembly_export_counts": {
                status: all_assembly_counts.get(status, 0)
                for status in ("located", "candidate", "unmapped", "excluded")
            },
            "target_assembly_exports": len(target_assembly_exports),
            "target_assembly_exports_located": sum(
                1
                for export in target_assembly_exports
                if export["mapping_status"] == "located"
            ),
            "public_header_symbols": sum(all_header_counts.values()),
            "header_mapping_counts": {
                status: all_header_counts.get(status, 0)
                for status in ("located", "candidate", "unmapped", "excluded")
            },
            "strict_function_parity_report": "audit/BEHAVIORAL_PARITY.json",
        },
        "units": units,
    }


def render_markdown(report: dict[str, Any]) -> str:
    summary = report["summary"]
    function_counts = summary["function_mapping_counts"]
    assembly_counts = summary["assembly_export_counts"]
    header_counts = summary["header_mapping_counts"]
    lines = [
        "# GLQuake-Port-Inventur",
        "",
        "Diese Datei wird durch `tools/generate_port_inventory.py` erzeugt. "
        "**`located` und `candidate` sind keine Paritätsnachweise.** Sie belegen "
        "nur einen Codeort beziehungsweise einen zu prüfenden Namenskandidaten.",
        "",
        f"Referenz: `{report['source']['commit']}`, Konfiguration "
        f"`{report['source']['configuration']}`.",
        "",
        "## Zusammenfassung",
        "",
        f"- Ausgewählte C-Dateien: **{summary['selected_c_files']}**",
        f"- Ausgewählte x86-Assemblerdateien: "
        f"**{summary['selected_assembly_files']}**",
        f"- Transitiv benötigte Header: **{summary['transitive_header_files']}**",
        f"- Logische C/H-Einheiten: **{summary['logical_units']}** "
        f"({summary['target_units']} Ziel, {summary['excluded_units']} ausgeschlossen)",
        f"- Ziel-C/H-Einheiten mit bestehendem MiniLang-Pendant: "
        f"**{summary['target_units_with_minilang_counterpart']}/"
        f"{summary['target_units']}**",
        f"- C-Funktionsdefinitionen: **{summary['c_function_definitions']}**",
        f"- Ziel-C-Funktionsdefinitionen mit Codeort: "
        f"**{summary['target_c_function_definitions_located']}/"
        f"{summary['target_c_function_definitions']}**",
        f"- Funktions-Codeorte: **{function_counts['located']} located**, "
        f"**{function_counts['candidate']} candidate**, "
        f"**{function_counts['unmapped']} unmapped**, "
        f"**{function_counts['excluded']} excluded**",
        f"- Assemblerexporte: **{assembly_counts['located']} located**, "
        f"**{assembly_counts['candidate']} candidate**, "
        f"**{assembly_counts['unmapped']} unmapped**, "
        f"**{assembly_counts['excluded']} excluded**",
        f"- Ziel-Assemblerexporte mit Codeort: "
        f"**{summary['target_assembly_exports_located']}/"
        f"{summary['target_assembly_exports']}**",
        f"- Öffentliche Header-Symbole: **{summary['public_header_symbols']}** "
        f"({header_counts['unmapped']} ohne Codeort)",
        "- Strikte Funktionsparität wird getrennt in "
        "`audit/BEHAVIORAL_PARITY.json` und `docs/BEHAVIORAL_PARITY.md` geführt.",
        "",
        "## Logische Einheiten",
        "",
        "| Einheit | Originaldateien | MiniLang-Pendant | Status | Funktionen L/C/U/X | ASM L/C/U/X |",
        "|---|---|---|---|---:|---:|",
    ]
    for unit in report["units"]:
        files = ", ".join(f"`{item['path']}`" for item in unit["original_files"])
        modules = ", ".join(
            f"`{item['path']}`" for item in unit["minilang_modules"]
        ) or "—"
        counts = unit["function_counts"]
        assembly = unit["assembly_export_counts"]
        lines.append(
            f"| `{unit['unit']}` | {files} | {modules} | "
            f"{unit['accounting_status']} | "
            f"{counts['located']}/{counts['candidate']}/"
            f"{counts['unmapped']}/{counts['excluded']} | "
            f"{assembly['located']}/{assembly['candidate']}/"
            f"{assembly['unmapped']}/{assembly['excluded']} |"
        )

    lines.extend(
        [
            "",
            "## Zielrelevante, noch ungemappte C-Funktionen",
            "",
        ]
    )
    unmapped = [
        (unit["unit"], function)
        for unit in report["units"]
        for function in unit["functions"]
        if function["scope"].startswith("target")
        and function["mapping_status"] == "unmapped"
    ]
    if not unmapped:
        lines.append("Keine.")
    else:
        lines.extend(
            [
                "| Einheit | Originalfunktion | Quelle |",
                "|---|---|---|",
            ]
        )
        for unit, function in unmapped:
            lines.append(
                f"| `{unit}` | `{function['name']}` | "
                f"`{function['source']}:{function['line']}` |"
            )

    lines.extend(
        [
            "",
            "## Statusregeln",
            "",
            "- `located`: normalisierter Namensmatch oder explizit geprüfte Umbenennung; "
            "nur Codeortbeleg.",
            "- `candidate`: Präfix-bereinigter Namenskandidat; manuelle Prüfung nötig.",
            "- `unmapped`: kein belastbarer MiniLang-Codeort gefunden.",
            "- `excluded`: durch die verbindliche Zieldefinition ausgeschlossen.",
            "- Die Inventur enthält bewusst keinen zweiten Paritätsstatus. "
            "Strikte Differential- und Kompatibilitätsbelege stehen ausschließlich "
            "im separaten Verhaltensparitätsbericht.",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write",
        action="store_true",
        help="update the tracked JSON and Markdown artifacts",
    )
    args = parser.parse_args()
    report = build_report()
    json_text = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    markdown_text = render_markdown(report)

    if args.write:
        JSON_PATH.parent.mkdir(parents=True, exist_ok=True)
        MARKDOWN_PATH.parent.mkdir(parents=True, exist_ok=True)
        JSON_PATH.write_text(json_text, encoding="utf-8")
        MARKDOWN_PATH.write_text(markdown_text, encoding="utf-8")
        print(
            "wrote GLQuake port inventory: "
            f"{report['summary']['logical_units']} units, "
            f"{report['summary']['c_function_definitions']} C functions"
        )
        return 0

    stale = []
    if not JSON_PATH.is_file() or JSON_PATH.read_text(encoding="utf-8") != json_text:
        stale.append(JSON_PATH.relative_to(ROOT).as_posix())
    if (
        not MARKDOWN_PATH.is_file()
        or MARKDOWN_PATH.read_text(encoding="utf-8") != markdown_text
    ):
        stale.append(MARKDOWN_PATH.relative_to(ROOT).as_posix())
    if stale:
        fail("generated artifacts are stale: " + ", ".join(stale))
    print(
        "GLQuake port inventory verified: "
        f"{report['summary']['logical_units']} units, "
        f"{report['summary']['c_function_definitions']} C functions"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
